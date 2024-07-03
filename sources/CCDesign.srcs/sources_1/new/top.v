`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 07/01/2024 05:34:10 PM
// Design Name: 
// Module Name: top
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


module top(
    input wire clock,
    input wire reset,
    
    input rx,
    output tx
);
wire clk_10Mhz;
wire clk_30Mhz;
wire clk_50Mhz;
wire clk_100Mhz;

wire clk = clk_50Mhz;
wire rst;

wire [31:0] araddr;
wire arvalid;
wire arready;

wire [31:0] rdata;
wire [1:0] rresp;
wire rvalid;
wire rready;

wire [31:0] awaddr;
wire awvalid;
wire awready;

wire [31:0] wdata;
wire [3:0] wstrb;
wire wvalid;
wire wready;

wire [1:0] bresp;
wire bvalid;
wire bready;


clk_wiz_0 u_clk_wiz(
  // Clock out ports
  .clk_10Mhz(clk_10Mhz),
  .clk_30Mhz(clk_30Mhz),
  .clk_50Mhz(clk_50Mhz),
  .clk_100Mhz(clk_100Mhz),
  // Status and control signals
  .reset(reset),
  .locked(),
 // Clock in ports
  .clk_in(clock)
 );

AXI_Interconnect u_AXI(
    .clk(clk),
    .rst_n(~rst),
    .core_araddr(araddr),
    .core_arvalid(arvalid),
    .core_arready(arready),
    .core_rdata(rdata),
    .core_rresp(rresp),
    .core_rvalid(rvalid),
    .core_rready(rready),
    .core_awaddr(awaddr),
    .core_awvalid(awvalid),
    .core_awready(awready),
    .core_wdata(wdata),
    .core_wstrb(wstrb),
    .core_wvalid(wvalid),
    .core_wready(wready),
    .core_bresp(bresp),
    .core_bvalid(bvalid),
    .core_bready(bready),
    .rx(rx),
    .tx(tx)
);

core u_core(
    .clk(clk),
    .rst(rst),
    .araddr(araddr),
    .arvalid(arvalid),
    .arready(arready),
    .rdata(rdata),
    .rresp(rresp),
    .rvalid(rvalid),
    .rready(rready),
    .awaddr(awaddr),
    .awvalid(awvalid),
    .awready(awready),
    .wdata(wdata),
    .wstrb(wstrb),
    .wvalid(wvalid),
    .wready(wready),
    .bresp(bresp),
    .bvalid(bvalid),
    .bready(bready)
);

asyncRstSyncRelease u_arsr(
    .clk(clk),
    .rst(reset),
    .sync_rst(rst)
);

endmodule