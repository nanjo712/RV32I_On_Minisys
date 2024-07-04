`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/07/04 07:32:43
// Design Name: 
// Module Name: digital
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


module digital(
    input  wire clock,
    input  wire reset,
    
    input  wire [3:0] dig0,
    input  wire [3:0] dig1,
    input  wire [3:0] dig2,
    input  wire [3:0] dig3,
    input  wire [3:0] dig4,
    input  wire [3:0] dig5,
    input  wire [3:0] dig6,
    input  wire [3:0] dig7,
    output reg  [7:0] dig_en,
    output reg  [7:0] dig_cx
);
reg [17:0] counter; //2ms
reg [7:0]  en; // 8 leds

wire [7:0] dig;
wire [3:0] bcd = ~en[0] ? dig0 :
                 ~en[1] ? dig1 : 
                 ~en[2] ? dig2 : 
                 ~en[3] ? dig3 : 
                 ~en[4] ? dig4 : 
                 ~en[5] ? dig5 : 
                 ~en[6] ? dig6 : 
                 ~en[7] ? dig7 : dig0;

always @(posedge clock, posedge reset) begin
    if(reset) begin
        counter <= 0;
        en <= 8'b11111110;
        dig_en <= 8'hff;
        dig_cx <= 8'hff;
    end
    else begin
        if(counter == 18'd99999) begin // 2ms
            counter <= 0;
            en[7:1] <= en[6:0];
            en[0] <= en[7]; 
        end
        else begin
            counter <= counter + 1;
            en <= en;
        end
        dig_en <= en;
        dig_cx <= dig;
    end
end

decoder u_decoder(
    .bcd(bcd),
    .dig(dig)
);

endmodule

