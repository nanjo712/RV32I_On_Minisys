`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/07/04 07:32:43
// Design Name: 
// Module Name: decoder
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


module decoder(
    input wire [3:0] bcd,
    output reg [7:0] dig
);
always @(*) begin
    case(bcd)
        4'h0: dig = 8'b00000011;
        4'h1: dig = 8'b10011111;
        4'h2: dig = 8'b00100101;
        4'h3: dig = 8'b00001101;
        4'h4: dig = 8'b10011001;
        4'h5: dig = 8'b01001001;
        4'h6: dig = 8'b01000001;
        4'h7: dig = 8'b00011111;
        4'h8: dig = 8'b00000001;
        4'h9: dig = 8'b00001001;
        4'ha: dig = 8'b00010001;
        4'hb: dig = 8'b11000001;
        4'hc: dig = 8'b01100011;
        4'hd: dig = 8'b10000101;
        4'he: dig = 8'b01100001;
        4'hf: dig = 8'b01110001;
    endcase
end

endmodule

