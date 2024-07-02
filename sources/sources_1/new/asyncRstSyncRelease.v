`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/07/01 14:01:57
// Design Name: 
// Module Name: asyncRstSyncRelease
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


module asyncRstSyncRelease(
    input rst,
    input clk,
    output sync_rst
    );
    reg reset_sync1, reset_sync2;
    assign sync_rst = reset_sync2;
    always @(posedge clk, posedge rst) begin
        if (rst) begin
            reset_sync1 <= 1'b1;
            reset_sync2 <= 1'b1;
        end else begin
            reset_sync1 <= 1'b0;
            reset_sync2 <= reset_sync1;
        end
    end
endmodule
