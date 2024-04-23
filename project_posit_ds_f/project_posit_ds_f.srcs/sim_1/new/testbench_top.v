`timescale 1ns / 1ps

module top_module_tb;

// Parameters
parameter n = 16;
parameter exp = 5;

// Testbench Signals
reg clk;
reg reset;
reg RxD;
wire TxD;
wire signed [n-1:0] out;
// Internal Signals for Simulation
reg [n-1:0] test_data [1:0]; // Array to hold test data
integer i;

// Instantiate the Unit Under Test (UUT)
top_module #(
    .exp(exp), 
    .n(n)
) uut (
    .clk(clk),
    .reset(reset),
    .RxD(RxD),
    .TxD(TxD),
    .out(out)
);

// Clock Generation
initial begin
    clk = 0;
    forever #5 clk = ~clk; // Generate a 100MHz clock (10 ns period)
end

// Test Sequence
initial begin
    // Initialize Inputs
    reset = 1;
    RxD = 1;
    
    // Reset the system
    #10;
    reset = 0;
    #10;
    reset = 1;
    #20;

    // Load test data
    test_data[0] = 16'b0100001001001001; // Example data
    test_data[1] = 16'b0100011000000011; // Example data

    // Send test data over RxD
    

    // Additional time for observing outputs
    #500;
    
    $finish; // End simulation
end


endmodule