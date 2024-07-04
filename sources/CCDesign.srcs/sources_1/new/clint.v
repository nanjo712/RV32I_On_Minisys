`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 07/03/2024 11:35:21 PM
// Design Name: 
// Module Name: clint
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


module clint(
    input wire clk,
    input wire rst,
    
    input wire [31:0] araddr,
    input wire arvalid,
    output wire arready,

    output wire [31:0] rdata,
    output wire [1:0] rresp,
    output wire rvalid,
    input wire rready,
    
    input wire [31:0] awaddr,
    input wire awvalid,
    output wire awready,
    
    input wire [31:0] wdata,
    input wire [3:0] wstrb,
    input wire wvalid,
    output wire wready,
    
    output wire [1:0] bresp,
    output wire bvalid,
    input wire bready,
    
    output wire sof_interrupt,
    output wire tim_interrupt
);

localparam s_wait = 2'b00;
localparam s_data = 2'b01;
localparam s_done = 2'b10;

//--rstate--
reg [1:0] rstate;

wire in_arready = rstate == s_wait;
wire in_rvalid = rstate == s_done;

wire ar_ready = arvalid && in_arready;

always @(posedge clk or posedge rst) begin
    if(rst) begin
        rstate <= s_wait;
    end
    else begin
        case(rstate)
            s_wait: rstate <= (ar_ready) ? s_done : rstate;
            s_done: rstate <= (rready && in_rvalid) ? s_wait : rstate;
            default: rstate <= s_wait;
        endcase
    end
end

//--wstate--
reg [1:0] wstate;

wire in_awready = wstate == s_wait;
wire in_wready = (wstate == s_wait) || (wstate == s_data);
wire in_bvalid = wstate == s_done;

wire aw_ready = awvalid && in_awready;
wire w_ready = wvalid && in_wready;

always @(posedge clk or posedge rst) begin
    if(rst) begin
        wstate <= s_wait;
    end
    else begin
        case(wstate)
            s_wait: wstate <= (aw_ready && w_ready) ? s_done :
                              (aw_ready) ? s_data : wstate;
            s_data: wstate <= (w_ready) ? s_done : wstate;
            s_done: wstate <= (bready && bvalid) ? s_wait : wstate;
            default: wstate <= s_wait;
        endcase
    end
end

//--io--
reg [31:0] clint [7:0];
reg [31:0] in_rdata;

always @(posedge clk or posedge rst) begin
    if(rst) begin
        in_rdata <= 0;
    end
    else begin
        if(ar_ready) begin
            in_rdata <= clint[araddr[4:2]];
        end
    end
end

reg [3:0] in_awaddr;

always @(posedge clk or posedge rst) begin
    if(rst) begin
        in_awaddr <= 0;
    end
    else begin
        if(aw_ready) begin
            in_awaddr <= awaddr[4:2];
        end
    end
end

always @(posedge clk or posedge rst) begin
    if(rst) begin
        clint[0] <= 0;
        clint[2] <= 32'hffffffff;
        clint[3] <= 32'hffffffff;
        clint[4] <= 0;
        clint[5] <= 0;
    end
    else begin
        {clint[5], clint[4]} <= {clint[5], clint[4]} + 1;
        if(aw_ready && w_ready) begin
            if(awaddr[4:2] >= 3'd0 && awaddr[4:2] <= 3'd3) begin
                clint[awaddr[4:2]] <= wdata;
            end
        end
        else if(w_ready) begin
            if(in_awaddr >= 3'd0 && in_awaddr <= 3'd3) begin
                clint[in_awaddr] <= wdata;
            end
        end
    end
end

assign arready = in_arready;
assign rdata = in_rdata;
assign rresp = 0;
assign rvalid = in_rvalid;

assign awready = in_awready;
assign wready = in_wready;
assign bresp = 0;
assign bvalid = in_bvalid;

assign sof_interrupt = clint[0][0];

assign tim_interrupt = {clint[3], clint[2]} < {clint[5], clint[4]};

endmodule
