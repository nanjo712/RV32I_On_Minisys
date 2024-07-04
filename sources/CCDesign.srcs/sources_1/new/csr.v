`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 07/03/2024 03:09:48 PM
// Design Name: 
// Module Name: csr
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


module csr(
    input wire clk,
    input wire rst,
    
    input wire ext_interrupt,
    input wire sof_interrupt,
    input wire tim_interrupt,
    
    input wire [31:0] epc,
    input wire [31:0] cause,
    
    input wire [11:0] waddr,
    input wire [31:0] wdata,
    
    input wire [1:0] CSROp,
    input wire ecall,
    input wire mret,
    
    output wire [31:0] CSRout,
    
    output wire interrupt
);

typedef enum logic[1:0] {
    mtsetup,
    mthand,
    inv
} type_t;

reg [31:0] mts [6:0]; // Machine Trap Setup (excluding mstatush)
reg [31:0] mth [4:0]; // Machine Trap Handling(excluding mtinst and mtval2)

wire [1:0] type_sel = (waddr[11:4] == 8'h30) ? mtsetup :
                      (waddr[11:4] == 8'h34) ? mthand : inv;

wire enable = mts[0][3];      
wire ext = mts[4][11] & (mth[4][11] | ext_interrupt);
wire sof = mts[4][3] & (mth[4][3] | sof_interrupt);
wire tim = mts[4][7] & (mth[4][7] | tim_interrupt);

wire interrupt_enter = (ext ? 1 :
                        sof ? 1 :
                        tim ? 1 : 
                        ecall ? 1 : 0) & enable;
                          
wire interrupt_quit = mret;

integer i;
always @(posedge clk or posedge rst) begin
    if(rst) begin
        for(i = 0; i <= 6; i++)
            mts[i] <= 0;
        for(i = 0; i <= 4; i++)
            mth[i] <= 0;
    end
    else begin
        case(CSROp)
            2'b01: begin
                mts[waddr[3:0]] <= (type_sel == mtsetup) ? wdata : mts[waddr[3:0]];
                mth[waddr[3:0]] <= (type_sel == mthand)  ? wdata : mth[waddr[3:0]];
            end
            2'b10: begin
                mts[waddr[3:0]] <= (type_sel == mtsetup) ? mts[waddr[3:0]] | wdata : mts[waddr[3:0]];
                mth[waddr[3:0]] <= (type_sel == mthand) ? mth[waddr[3:0]] | wdata : mth[waddr[3:0]];
            end
            2'b11: begin
                mts[waddr[3:0]] <= (type_sel == mtsetup) ? mts[waddr[3:0]] & ~wdata : mts[waddr[3:0]];
                mth[waddr[3:0]] <= (type_sel == mthand) ? mth[waddr[3:0]] & ~wdata : mth[waddr[3:0]];
            end
            default: begin                
                mts[0][3] <= (interrupt_enter) ? 0 :
                             (interrupt_quit) ? 1 : mts[0][3];
                             
                mth[1] <= (interrupt_enter) ? epc : mth[1];
                mth[4][11] <= ext_interrupt;
                mth[4][3] <= sof_interrupt;
                mth[4][7] <= tim_interrupt;
                mth[2] <= (ext & enable) ? {1'b1, 31'd11} :
                          (sof & enable) ? {1'b1, 31'd3} :
                          (tim & enable) ? {1'b1, 31'd7} : 
                          (ecall) ? cause : mth[2];
            end
        endcase
    end
end

assign CSRout = (interrupt_enter) ? mts[5] : //mtvec
                (interrupt_quit) ? mth[1] : //mepc
                (type_sel == mtsetup) ? mts[waddr[3:0]] :
                (type_sel == mthand) ? mth[waddr[3:0]] : 0;

assign interrupt = interrupt_enter | interrupt_quit;

endmodule
