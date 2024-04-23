`timescale 1ns / 1ps

module top_module#(
    parameter exp = 5, 
    parameter n = 16
) (
    input clk,
    input reset,
    input RxD,
    output TxD
    
    //input [1:0] select,   // Select line to choose the multiplier type
     // Signal for new data 2
);
wire isNewData1;// Signal for new data 1
wire isNewData2;
wire [n-1:0] out;
// Intermediary Signals
wire Exception1, Exception2, Overflow, Underflow;
wire infinity1, zero1, infinity2, zero2;
wire signed [n-1:0] float_add_out, float_mult_out, p_add_out, p_mult_out;
wire [n-1:0] RxData1, RxData2; // Separate data receivers
reg [n-1:0] A, B;  // Variables to store received data
wire doTransmit, isBusy;
wire [n-1:0] TxData;

// Receiver instantiations
receiver receiver_data_1 (
    .clk(clk), 
    .reset(reset), 
    .RxD(RxD), 
    .RxData(RxData1), 
    .isNewData(isNewData1)
);

receiver receiver_data_2 (
    .clk(clk), 
    .reset(reset), 
    .RxD(RxD), 
    .RxData(RxData2), 
    .isNewData(isNewData2)
);

// Posit and Floating Point Modules
posit_mult #(.N(n), .es(exp)) p_mult (.in1(A), .in2(B), .out(p_mult_out), .inf(infinity1), .zero(zero1));
posit_adder #(.N(n), .es(exp)) p_add (.input1(A), .input2(B), .out(p_add_out), .inf(infinity2), .zero(zero2));
Multiplication #(.n(n), .exp(exp)) float_mult (.A(A), .B(B), .Exception(Exception1), .Overflow(Overflow), .Underflow(Underflow), .out(float_mult_out));
Addition #(.n(n), .exp(exp)) float_add (.A(A), .B(B), .Exception(Exception2), .out(float_add_out));

// Data reception and operation selection
reg dataSelect; // Control to switch between RxData1 and RxData2

always @(posedge clk) begin
    if (reset) begin
        dataSelect <= 0;
        A <= 0;
        B <= 0;
    end else begin
        if (isNewData1 && !dataSelect) begin
            A <= RxData1;
            dataSelect <= 1; // Switch to expect second data
        end
        if (isNewData2 && dataSelect) begin
            B <= RxData2;
            dataSelect <= 0; // Reset for next operation
        end
    end
end

// Output Mux
assign out = float_mult_out;
    
//    case (select)
//        2'b00: out = p_mult_out;   // Posit multiplier
//        2'b01: out = p_add_out;    // Posit adder
//        2'b10: out = float_mult_out; // Floating point multiplier
//        2'b11: out = float_add_out; // Floating point adder
//        default: out = {n{1'b0}};  // Default case
//    endcase


// UART Transmission module
Sender sender_data(
    .clk(clk),
    .reset(reset),
    .TxD(TxD),
    .doTransmit(doTransmit),
    .TxData(out),
    .isBusy(isBusy)
);

endmodule