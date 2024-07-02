`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/07/01 12:58:26
// Design Name: 
// Module Name: registerFile
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


module registerFile(
    input wire clk,             
    input wire rst,           
    input wire [4:0] ra,        
    input wire [4:0] rb,        
    input wire [4:0] rw,        
    input wire wen,             
    input wire [31:0] wdata,    
    output wire [31:0] rs1,     
    output wire [31:0] rs2      
);

    reg [31:0] registers [31:0];  

    assign rs1 = (ra != 5'b0) ? registers[ra] : 32'b0;
    assign rs2 = (rb != 5'b0) ? registers[rb] : 32'b0;

    integer i;
    always @(posedge clk) begin
        if (rst) begin
            for (i = 0; i < 32; i = i + 1) begin
                registers[i] <= 32'b0;
            end
        end else if (wen) begin
            if (rw != 5'd0) registers[rw] <= wdata;
        end
    end
endmodule

