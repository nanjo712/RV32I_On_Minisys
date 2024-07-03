`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 07/02/2024 12:03:20 PM
// Design Name: 
// Module Name: testbench_top
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


module testbench_top();

reg clock;
reg reset;
    
reg rx;
wire tx;

top u_top(
    .clock(clock),
    .reset(reset),
    .rx(rx),
    .tx(tx)
);

initial begin
    rx = 1'b1;
    clock = 1'b0;
    reset = 1'b1;
    #50 reset = 1'b0;
end

always begin
    #5 clock = 1;
    #5 clock = 0;
end

endmodule
