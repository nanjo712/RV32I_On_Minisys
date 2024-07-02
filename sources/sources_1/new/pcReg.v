`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/07/01 13:36:14
// Design Name: 
// Module Name: pcReg
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


module pcReg(
    input [31:0] nextPC,
    input clk,
    input rst,
    input PCInc,
    output reg [31:0] PC
    );
    always @(posedge clk) begin
        if (rst) begin
            PC <= 32'h80000000;
        end else begin
            PC <= (PCInc) ? nextPC : PC;
        end
    end
endmodule
