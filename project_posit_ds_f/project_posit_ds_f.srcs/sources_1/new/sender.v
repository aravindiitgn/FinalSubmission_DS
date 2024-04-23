`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////

// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////

module Sender #(
    parameter integer W5Frequency = 100_000_000,  // System clock frequency
    parameter integer baudRate = 9600,             // Baud rate for serial communication
    parameter integer DATA_WIDTH = 8               // Number of data bits per frame (8-bits per UART spec)
)(
    input wire clk,             // Clock input
    input wire reset,           // Reset input
    output reg TxD,             // Serial data output
    input wire doTransmit,      // Control signal to start transmission
    input wire [2*DATA_WIDTH-1:0] TxData,  // 16-bit Data input split into two frames
    output reg isBusy           // Busy flag
);

    localparam integer samplingInterval = W5Frequency / baudRate;
    localparam integer halfSamplingInterval = samplingInterval / 2;

    reg [31:0] state = 0;
    reg [31:0] sequenceCounter = 0;
    reg frame = 0; // Current frame number, 0 or 1
    reg [DATA_WIDTH-1:0] data = 0;  // Data register with width DATA_WIDTH

    always @(posedge clk) begin
        if (reset) begin
            state <= 0;
            data <= 0;
            sequenceCounter <= 0;
            TxD <= 1;  // Idle state of TxD is high (mark)
            isBusy <= 0;
            frame <= 0;
        end else begin
            case (state)
                0: begin
                    if (doTransmit && !isBusy) begin
                        data <= TxData[DATA_WIDTH-1:0];  // Lower 8 bits for the first frame
                        state <= 1;
                        isBusy <= 1;
                        frame <= 0;
                        TxD <= 0;  // Start bit
                        sequenceCounter <= 0;
                    end
                end
                // Data transmission states for the first frame
                
               DATA_WIDTH + 1: begin
                    // Stop bit for the first frame
                    sequenceCounter <= sequenceCounter + 1;
                    if (sequenceCounter > samplingInterval) begin
                        sequenceCounter <= 0;
                        TxD <= 1;  // Stop bit
                        if (frame == 0) begin
                            state <= 0;  // Prepare for second frame
                            data <= TxData[2*DATA_WIDTH-1:DATA_WIDTH];  // Upper 8 bits for the second frame
                            frame <= 1;  // Switch to next frame
                        end else begin
                            state <= DATA_WIDTH + 2;  // Final reset state
                        end
                    end
                end
                DATA_WIDTH + 2: begin
                    // Reset after second frame
                    sequenceCounter <= sequenceCounter + 1;
                    if (sequenceCounter > halfSamplingInterval) begin
                        sequenceCounter <= 0;
                        state <= 0;
                        isBusy <= 0;
                        frame <= 0;
                    end
                end
               default: begin
                    sequenceCounter <= sequenceCounter + 1;
                    if (sequenceCounter > samplingInterval) begin
                        sequenceCounter <= 0;
                        TxD <= data[state - 1];
                        state <= state + 1;
                    end
                end
                
            endcase
        end
    end
endmodule