
# Convert to IEEE 754 binary string for FP32
import bitstring
import numpy as np
import serial
import struct
import numpy as np
import bitstring
import cv2

def setup_serial_connection():
    """ Setup serial port for communication """
    ser = serial.Serial(
        port='COM13',
        baudrate=9600,
        parity=serial.PARITY_ODD,
        stopbits=serial.STOPBITS_ONE,
        bytesize=serial.EIGHTBITS,
        timeout=5
    )
    return ser
def binary_string_to_int(binary_string):
    num_chunks = (len(binary_string) + 15) // 16  # Calculate the number of 16-bit chunks
    result = 0
    for i in range(num_chunks):
        chunk = binary_string[i*16 : (i+1)*16]  # Extract 16-bit chunk
        result <<= 16  # Shift result by 16 bits
        result |= int(chunk, 2)  # Convert chunk to integer and OR with result
    return result

def send_data_to_fpga(ser, local_var_bin, noise_var_bin):
    # Convert binary string to bytes
    print(local_var_bin)
    local_var_int = binary_string_to_int(local_var_bin)
    noise_var_int = binary_string_to_int(noise_var_bin)
    num_bytes_local_var = (len(local_var_bin) + 15) // 16
    num_bytes_noise_var = (len(noise_var_bin) + 15) // 16
# Convert integers to bytes
    local_var_bytes = local_var_int.to_bytes(num_bytes_local_var * 2, byteorder='big')
    noise_var_bytes = noise_var_int.to_bytes(num_bytes_noise_var * 2, byteorder='big')
    # Send data over serial connection to FPGA
    ser.write(local_var_bytes)
    ser.write(noise_var_bytes)


import struct

def receive_data_from_fpga(ser):
    try:
        # Read the processed data from FPGA
        data = ser.read(2)  # Assuming 2 bytes for each number
        print(data)
        if len(data) != 2:
            raise ValueError("Received incomplete data from FPGA")
        
        # Unpack the bytes to an integer
        number = struct.unpack('>H', data)[0]
        
        # Convert the integer to a binary string
        binary_string = format(number, '016b')  # Format as a 16-bit binary
        return binary_string
    except Exception as e:
        print(f"Error receiving data from FPGA: {e}")
        return None


    

def float_to_binary_with_bitstring(value,width):
    if width==32:
    # Create a bitstring for FP32
        fp32 = bitstring.BitArray(float=value, length=32)
        binary = fp32.bin
    elif width==16:
    # Create a bitstring for FP16
        fp16 = bitstring.BitArray(float=value, length=16)
        binary = fp16.bin
    
    return binary

def binary_to_float(binary,width):
    """Convert binary representation back to float values for FP32 and FP16."""
    # Convert FP32 binary to float
    if width==32:
        fp32 = bitstring.BitArray(bin=binary)
        float_val = fp32.float

    elif width==16:
    # Convert FP16 binary to float
        fp16 = bitstring.BitArray(bin=binary)
        float_val = fp16.float
    return float_val

# Example usage
def wiener_filter_fpga(image, kernel_size, noise_variance):
    rows, cols = image.shape
    filtered_image = np.zeros_like(image, dtype=np.uint16)
    noise_var_bin=float_to_binary_with_bitstring(noise_variance,16)
    print(noise_var_bin)
    with setup_serial_connection() as ser:
        for i in range(rows):
            for j in range(cols):
                # Extract local region
                r_min, r_max = max(i - kernel_size // 2, 0), min(i + kernel_size // 2 + 1, rows)
                c_min, c_max = max(j - kernel_size // 2, 0), min(j + kernel_size // 2 + 1, cols)
                local_region = image[r_min:r_max, c_min:c_max].astype(np.uint16)

                # Calculate local mean and variance in Python
                local_mean = np.mean(local_region)
                local_var = np.var(local_region)
                print(local_var)
                local_var_bin=float_to_binary_with_bitstring(local_var,16)
                print(local_var_bin)
                # Offload only the multiplication to FPGA
                send_data_to_fpga(ser, local_var_bin, noise_var_bin)
                print("sending")
                multiplied_result = receive_data_from_fpga(ser)  # Receive the product of local_var and noise_variance
                print("receving")
                multiplied_result_float=binary_to_float(multiplied_result,16)

                if multiplied_result_float is None:
                    continue  # Handle communication errors by skipping the pixel

                # Subtract the mean and scale by the result, then add the mean back in Python
                pixel_value = image[i, j]
                adjusted_pixel_value = pixel_value - local_mean  # Subtract mean
                filtered_pixel = adjusted_pixel_value * (multiplied_result_float / local_var) + local_mean  # Apply the filter gain and add mean

                # Store the filtered pixel value back to the image
                filtered_image[i, j] = int(filtered_pixel)

    return filtered_image



image_path = 'dog.png'
image = cv2.imread(image_path, cv2.IMREAD_GRAYSCALE)

# Apply filter
kernel_size = 3
noise_variance = 10  # Assumed or estimated noise variance
filtered_image = wiener_filter_fpga(image, kernel_size, noise_variance)

# Save filtered image
cv2.imwrite('filtered_image.png', filtered_image)