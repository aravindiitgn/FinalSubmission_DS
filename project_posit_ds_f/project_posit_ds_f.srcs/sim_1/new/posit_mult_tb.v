`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 15.03.2024 19:30:31
// Design Name: 
// Module Name: posit_mult_tb
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module posit_mult_tb(

    );
    
  parameter N = 16;
  parameter es = 5;

  // Signals
  reg signed [N-1:0] in1, in2;
  wire signed [N-1:0] out;
  wire inf, zero;

  // Instantiate the posit_adder module
  posit_mult uut (
    .in1(in1),
    .in2(in2),
    .out(out),
    .inf(inf),
    .zero(zero)
  );

  // Clock Generation
  reg clk = 0;
  always #5 clk = ~clk;

  // Testbench Procedure
  initial begin
    // Initialize inputs
 //   input1 = 8'b0; // Example posit numbers
  //  input2 = 8'b0;

    // Apply stimulus
 
    #10
   #10
     in1 = 16'b1001111001010110; // Positive posit number
     in2 = 16'b100100001010010;     // Negative posit number

   
    
   
    #10
  $finish; // Finish simulation after all test cases
  end

endmodule
