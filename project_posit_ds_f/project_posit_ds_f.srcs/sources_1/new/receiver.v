`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////

// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: This module receives serial data for configurable 'n' bits width over two 8-bit frames.
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////

module receiver #(
    parameter integer W5Frequency = 100_000_000,  // System clock frequency
    parameter integer baudRate = 9600,             // Baud rate for serial communication
    parameter integer DATA_WIDTH = 8               // Number of data bits per frame (8-bits per UART spec)
)(
    input wire clk,            // Clock input
    input wire reset,          // Reset input
    input wire RxD,            // Serial data input
    output reg [2*DATA_WIDTH-1:0] RxData,  // 16-bit Data output
    output reg isNewData       // Flag to indicate new data has been received
);

    localparam integer samplingInterval = W5Frequency / baudRate;
    localparam integer halfSamplingInterval = samplingInterval / 2;

    reg [31:0] state = 0;
    reg [31:0] sequenceCounter = 0;
    reg [DATA_WIDTH-1:0] data = 0;  // Data register with width DATA_WIDTH
    reg [DATA_WIDTH-1:0] tempData = 0;  // Temporary storage for first 8 bits
    reg frame = 0; // Current frame number, 0 or 1

    always @(posedge clk) begin
        if (reset) begin
            state <= 0;
            data <= 0;
            tempData <= 0;
            sequenceCounter <= 0;
            isNewData <= 0;
            RxData <= 0;
            frame <= 0;
        end else begin
            case (state)
                0: begin
                    // Waiting for start bit
                    if (RxD == 0) begin
                        state <= 1;
                        sequenceCounter <= 0;
                    end
                end
                1: begin
                    // Confirm start bit
                    sequenceCounter <= sequenceCounter + 1;
                    if (sequenceCounter > halfSamplingInterval) begin
                        sequenceCounter <= 0;
                        state <= 2;
                    end
                end
                
                DATA_WIDTH + 2: begin
                    // Finish reading the frame
                    if (frame == 0) begin
                        tempData <= data;  // Store first 8 bits
                        frame <= 1;        // Switch to next frame
                        state <= 0;        // Restart state machine for next frame
                    end else begin
                        RxData <= {tempData, data};  // Combine two 8-bit frames into one 16-bit
                        isNewData <= !isNewData;     // Toggle isNewData flag
                        frame <= 0;                  // Reset frame count
                        state <= 0;                  // Reset state machine
                    end
                    end
                default: begin
                    // Read data bits
                    sequenceCounter <= sequenceCounter + 1;
                    if (sequenceCounter > samplingInterval) begin
                        sequenceCounter <= 0;
                        data[state - 2] <= RxD;  // Store bit
                        state <= state + 1;
                    end
                end
                
               
            endcase
        end
    end
endmodule