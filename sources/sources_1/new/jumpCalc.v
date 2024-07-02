`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/07/01 17:32:44
// Design Name: 
// Module Name: jumpCalc
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


module jumpCalc(
    input [31:0] imm,
    input [31:0] pc,
    input [31:0] rs1,
    input PCAsrc,
    input PCBsrc,
    output [31:0] nextPC
    );
    wire [1:0] cond = {PCAsrc, PCBsrc};

    assign nextPC = (cond == 2'b00) ? pc + 4 :
                    (cond == 2'b10) ? pc + imm :
                    (cond == 2'b11) ? rs1 + imm : 0;
endmodule

