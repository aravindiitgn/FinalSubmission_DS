`timescale 1ns / 1ps

module posit_adder_tb;

  // Parameters
  parameter N = 16;
  parameter es = 3;

  // Signals
  reg signed [N-1:0] in1, in2;
  wire signed [N-1:0] out;
  wire inf, zero;

  // Instantiate the posit_adder module
  posit_adder uut (
    .input1(in1),
    .input2(in2),
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
     in1 = 16'b1001111001010110; // Positive posit number
    in2 = 16'b1001000010100100;     // Negative posit number

   
    #10
  $finish; // Finish simulation after all test cases
  end

endmodule
