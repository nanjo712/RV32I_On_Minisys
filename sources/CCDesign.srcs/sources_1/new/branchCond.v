`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/07/01 18:01:12
// Design Name: 
// Module Name: branchCond
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


module branchCond(
    input [2:0] branch,
    input less,
    input zero,
    output PCAsrc,
    output PCBsrc
    );

    assign PCAsrc = branch == 3'b000 ? 0 :
                    branch == 3'b001 ? 1 :
                    branch == 3'b010 ? 1 :
                    branch == 3'b100 ? zero :
                    branch == 3'b101 ? ~zero :
                    branch == 3'b110 ? less :
                    branch == 3'b111 ? ~less : 0;

    assign PCBsrc = branch == 3'b010 ? 1 : 0;
endmodule
