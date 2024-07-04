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
    input [31:0] csr,
    input [31:0] imm,
    input [31:0] pc,
    input [31:0] rs1,
    input [0:0] PCAsrc,
    input [0:0] PCBsrc,
    input interrupt,
    output [31:0] nextPC
    );
    wire [31:0] asrc = (PCAsrc == 1'b0) ? 32'd4 :
                       (PCAsrc == 1'b1) ? imm : 0;
                       
    wire [31:0] bsrc = (PCBsrc == 1'b0) ? pc :
                       (PCBsrc == 1'b1) ? rs1 : 0;

    assign nextPC = (interrupt) ? csr : asrc + bsrc;
endmodule

