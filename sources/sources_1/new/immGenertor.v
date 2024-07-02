`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/07/01 12:20:28
// Design Name: 
// Module Name: immGenertor
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


module immGenertor(
    input [31:7] instr,
    input [2:0] extOp,
    output [31:0] imm
    );
    wire [31:0] immI = { {20{instr[31]}}, instr[31:20] };
    wire [31:0] immS = { {20{instr[31]}}, instr[31:25], instr[11:7]};
    wire [31:0] immB = { {19{instr[31]}}, instr[31], instr[7], instr[30:25], instr[11:8], 1'b0};
    wire [31:0] immU = { instr[31:12] , 12'b0};
    wire [31:0] immJ = { {19{instr[31]}}, instr[31], instr[19:12], instr[20], instr[30:21], 1'b0};
    
    assign imm = (extOp == 3'b000) ? immI :
                 (extOp == 3'b001) ? immU :
                 (extOp == 3'b010) ? immS :
                 (extOp == 3'b011) ? immB :
                 (extOp == 3'b100) ? immJ : 32'b0;
endmodule
