import matlab.engine

# Start MATLAB engine
eng = matlab.engine.start_matlab()

# Add the directory containing your .m file to MATLAB's path
eng.addpath(r'pos2dec.m')  # Adjust the path as necessary

# Define your posit, bit length, and exponent length
posit = '0100101100000000'  # Example posit
bit_length = 16
exp_length = 3

# Call the MATLAB function
decimal_result = eng.pos2dec(posit, bit_length, exp_length, nargout=1)

# Print the result
print("Decimal representation:", decimal_result)

# Stop MATLAB engine
eng.quit()