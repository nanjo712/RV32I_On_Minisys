`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/07/04 07:32:43
// Design Name: 
// Module Name: gpio
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


module gpio(
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
    
    output wire [7:0] dig_en,
    output wire [7:0] dig_cx,
    
    output wire [31:0] led,
    input wire [31:0] sw
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

//gpio

reg [31:0] in_dig; // w
reg [31:0] in_led; // w
reg [31:0] in_sw; // r

reg [31:0] in_rdata;

always @(posedge clk or posedge rst) begin
    if(rst) begin
        in_rdata <= 0;
    end
    else begin
        if(ar_ready) begin
            if(araddr[3:2] == 2'b10) begin
                in_rdata <= in_sw;
            end
        end
    end
end

always @(posedge clk or posedge rst) begin
    if(rst) begin
        in_sw <= 0;
    end
    else begin
        in_sw <= sw;
    end
end

reg [1:0] in_awaddr;

always @(posedge clk or posedge rst) begin
    if(rst) begin
        in_awaddr <= 0;
    end
    else begin
        if(aw_ready) begin
            in_awaddr <= awaddr[3:2];
        end
    end
end

always @(posedge clk or posedge rst) begin
    if(rst) begin
        in_dig <= 0;
        in_led <= 0;
    end
    else begin
        if(aw_ready && w_ready) begin
            if(awaddr[3:2] == 2'b00) begin
                in_dig <= wdata;
            end
            else if(awaddr[3:2] == 2'b01) begin
                in_led <= wdata;
            end
        end
        else if(w_ready) begin
            if(in_awaddr == 2'b00) begin
                in_dig <= wdata;
            end
            else if(in_awaddr == 2'b01) begin
                in_led <= wdata;
            end
        end
    end
end

digital u_digital(
    .clock(clk),
    .reset(rst),
    .dig0(in_dig[3:0]),
    .dig1(in_dig[7:4]),
    .dig2(in_dig[11:8]),
    .dig3(in_dig[15:12]),
    .dig4(in_dig[19:16]),
    .dig5(in_dig[23:20]),
    .dig6(in_dig[27:24]),
    .dig7(in_dig[31:28]),
    .dig_en(dig_en),
    .dig_cx(dig_cx)
);

assign led = in_led;

assign arready = in_arready;
assign rdata = in_rdata;
assign rresp = 0;
assign rvalid = in_rvalid;

assign awready = in_awready;
assign wready = in_wready;
assign bresp = 0;
assign bvalid = in_bvalid;

endmodule
