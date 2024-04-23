`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 22.04.2024 00:27:08
// Design Name: 
// Module Name: testbench_final
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


module testbench_final(

    );
  parameter n = 16;
  parameter exp = 5;

  // Signals
  reg signed [n-1:0] A;
  reg signed [n-1:0] B;
  reg [1:0] select;
  wire signed [n-1:0] out;
  // Instantiate the posit_adder module
  top_module uut (.select(select),.A(A),.B(B),.out(out));

  // Testbench Procedure
  initial begin
 
    #10
    select = 2'b10;
    #10
     A = 16'b1001111001010110; // Positive posit number
     B = 16'b1001000010100100;     // Negative posit number
      
    #10
  $finish; // Finish simulation after all test cases
  end

endmodule
