`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 07/01/2024 08:35:08 PM
// Design Name: 
// Module Name: lsu
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


module lsu(
    input wire clk,
    input wire rst,
    
    input wire MemWr,
    input wire [2:0] MemOP,
    input wire [31:0] ALU_Result,
    input wire [31:0] Reg_Bport,
    output wire [31:0] DataOut,

    output wire [31:0] araddr,
    output wire arvalid,
    input wire arready,

    input wire [31:0] rdata,
    input wire [1:0] rresp,
    input wire rvalid,
    output wire rready,

    output wire [31:0] awaddr,
    output wire awvalid,
    input wire awready,

    output wire [31:0] wdata,
    output wire [3:0] wstrb,
    output wire wvalid,
    input wire wready,

    input wire [1:0] bresp,
    input wire bvalid,
    output wire bready,
    
    output ready
);

typedef enum logic[1:0] {
    s_wait,
    s_data,
    s_done
} state_t;

wire is_valid = ~MemOP[1] | (~MemOP[2] & ~MemOP[0]);

//--read-state--

reg [1:0] rstate;
reg [31:0] in_rdata;
wire [31:0] fix_data;

wire in_arvalid = (rstate == s_wait) & is_valid & ~MemWr;
wire in_rready = rstate == s_done;

wire r_ready = (rstate == s_done) && rvalid && in_rready;

always @(posedge clk or posedge rst) begin
    if(rst) begin
        rstate <= 0;
    end
    else begin
        case(rstate)
            s_wait: rstate <= (arready & in_arvalid) ? s_done : rstate;
            s_done: rstate <= (rvalid & in_rready) ? s_wait : rstate;
        endcase
    end
end

always @(posedge clk or posedge rst) begin
    if(rst) begin
        in_rdata <= 0;
    end
    else begin
        in_rdata <= (r_ready) ? fix_data : in_rdata;
    end
end
//--write-state--

reg [1:0] wstate;

wire in_awvalid = (wstate == s_wait) & MemWr & is_valid;
wire in_wvalid = ((wstate == s_wait) & MemWr & is_valid) | (wstate == s_data);
wire in_bready = wstate == s_done;

wire w_ready = (wstate == s_done) && bvalid && in_bready;

always @(posedge clk or posedge rst) begin
    if(rst) begin
        wstate <= 0;
    end
    else begin
        case(wstate)
            s_wait: wstate <= (awready & in_awvalid) ? 
                              ((wready & in_wvalid) ? s_done : s_data) : wstate;
            s_data: wstate <= (wready & in_wvalid) ? s_done : wstate;
            s_done: wstate <= (bvalid & in_bready) ? s_wait : wstate;
        endcase
    end
end



// fix
wire [31:0] ori_1b = (ALU_Result[1:0] == 2'b00) ? {24'b0, rdata[7:0]} :  
                     (ALU_Result[1:0] == 2'b01) ? {24'b0, rdata[15:8]} :
                     (ALU_Result[1:0] == 2'b10) ? {24'b0, rdata[23:16]} :
                                                  {24'b0, rdata[31:24]};
                                                  
wire [31:0] ori_2b = (ALU_Result[1] == 1'b0) ? {16'b0, rdata[15:0]} :
                                               {16'b0, rdata[31:16]};
                                           

wire [31:0] fix_1b = (ALU_Result[1:0] == 2'b00) ? {{25{rdata[7]}}, rdata[6:0]} :  
                     (ALU_Result[1:0] == 2'b01) ? {{25{rdata[15]}}, rdata[14:8]} :
                     (ALU_Result[1:0] == 2'b10) ? {{25{rdata[23]}}, rdata[22:16]} :
                                                  {{25{rdata[31]}}, rdata[30:24]};
                                              
wire [31:0] fix_2b = (ALU_Result[1] == 1'b0) ? {{17{rdata[15]}}, rdata[14:0]} :
                                               {{17{rdata[31]}}, rdata[30:16]};
                                           
wire [3:0] mask_1b = (ALU_Result[1:0] == 2'b00) ? 4'b0001 :
                     (ALU_Result[1:0] == 2'b01) ? 4'b0010 :
                     (ALU_Result[1:0] == 2'b10) ? 4'b0100 :
                                                  4'b1000;
                                                  
wire [3:0] mask_2b = (ALU_Result[1] == 1'b0) ? 4'b0011 :
                                               4'b1100;
                                               
wire [31:0] wdata_1b = (ALU_Result[1:0] == 2'b00) ? {24'b0, Reg_Bport[7:0]} :
                       (ALU_Result[1:0] == 2'b01) ? {16'b0, Reg_Bport[7:0], 8'b0} :
                       (ALU_Result[1:0] == 2'b10) ? {8'b0, Reg_Bport[7:0], 16'b0} :
                                                    {Reg_Bport[7:0], 24'b0};
                                                    
wire [31:0] wdata_2b = (ALU_Result[1] == 1'b0) ? {16'b0, Reg_Bport[15:0]} :
                                                 {Reg_Bport[15:0], 16'b0};

assign araddr = ALU_Result & 32'hfffffffc;
assign arvalid = in_arvalid;
assign rready = in_rready;

                                            
assign awaddr = ALU_Result & 32'hfffffffc;
assign awvalid = in_awvalid;
assign wdata = (MemOP == 3'b000) ? wdata_1b :
               (MemOP == 3'b001) ? wdata_2b :
               (MemOP == 3'b010) ? Reg_Bport : 0;
assign wstrb = (MemOP == 3'b000) ? mask_1b :
               (MemOP == 3'b001) ? mask_2b :
               (MemOP == 3'b010) ? 4'b1111 : 0;
assign wvalid = in_wvalid;
assign bready = in_bready;

assign fix_data = (MemOP == 3'b000) ? fix_1b :
                 (MemOP == 3'b001) ? fix_2b :
                 (MemOP == 3'b010) ? rdata :
                 (MemOP == 3'b100) ? ori_1b :
                 (MemOP == 3'b101) ? ori_2b : 0;
assign DataOut = in_rdata;
                 
assign ready = r_ready | w_ready;
endmodule
