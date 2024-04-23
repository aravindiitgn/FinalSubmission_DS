import matlab.engine

# Start MATLAB engine
eng = matlab.engine.start_matlab()

# Add the directory containing your .m file to MATLAB's path
eng.addpath(r'dec2pos.m')  # Replace this path with the actual path to your .m file

# Define your decimal number, bit length, and exponent length
decimal_number = 100
bit_length = 20
exp_length = 5

# Call the MATLAB function
posit_result = eng.dec2pos(decimal_number, bit_length, exp_length, nargout=1)

# Print the result
print("Posit representation:", posit_result)

# Stop MATLAB engine
eng.quit()