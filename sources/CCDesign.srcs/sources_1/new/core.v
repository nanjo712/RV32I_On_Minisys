`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 07/01/2024 07:38:00 PM
// Design Name: 
// Module Name: core
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


module core(
    input wire clk,
    input wire rst,
    
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
    
    input wire extIntr
);

wire [31:0] pc;
wire [31:0] inst;
wire [31:0] nextPC;

wire ecall;
wire mret;

wire InsFetch;
wire [2:0] ExtOP;
wire RegWr;
wire ALUAsrc;
wire [1:0] ALUBsrc;
wire [3:0] ALUctr;
wire [2:0] Branch;
wire [1:0] toReg;
wire MemWr;
wire [2:0] MemOP;
wire [0:0] PCAsrc;
wire [0:0] PCBsrc;
wire PCInc;
wire [1:0] CSROp;

wire ifu_ready;
wire lsu_ready;

wire [31:0] RegBusA;
wire [31:0] RegBusB;
wire [31:0] a7;

wire [31:0] imm;

wire [31:0] ALU_A = (ALUAsrc) ? pc : RegBusA; 
wire [31:0] ALU_B = (ALUBsrc == 2'b00) ? RegBusB :
                    (ALUBsrc == 2'b01) ? imm :
                    (ALUBsrc == 2'b10) ? 32'd4 : 0;
                    
wire [31:0] ALUout;
wire Less;
wire Zero;

wire [31:0] DataOut;

wire [31:0] CSRout;

wire [31:0] wbdata = (toReg == 2'b01) ? DataOut : 
                     (toReg == 2'b10) ? CSRout : ALUout;
                     
wire [31:0] csrwdata = (inst[14]) ? {27'b0, inst[19:15]} : RegBusA;

wire csr_intr;

wire ext_interrupt = extIntr;
wire sof_interrupt;
wire tim_interrupt;
wire ext;
wire sof;
wire tim;

// AXI for IFU(R)
wire [31:0] ifu_araddr;
wire ifu_arvalid;
wire ifu_arready;

wire [31:0] ifu_rdata;
wire [1:0] ifu_rresp;
wire ifu_rvalid;
wire ifu_rready;

// AXI for LSU(RW)
wire [31:0] lsu_araddr;
wire lsu_arvalid;
wire lsu_arready;

wire [31:0] lsu_rdata;
wire [1:0] lsu_rresp;
wire lsu_rvalid;
wire lsu_rready;

wire [31:0] lsu_awaddr;
wire lsu_awvalid;
wire lsu_awready;

wire [31:0] lsu_wdata;
wire [3:0] lsu_wstrb;
wire lsu_wvalid;
wire lsu_wready;

wire [1:0] lsu_bresp;
wire lsu_bvalid;
wire lsu_bready;

// AXI for CLINT(RW)
wire [31:0] clint_araddr;
wire clint_arvalid;
wire clint_arready;

wire [31:0] clint_rdata;
wire [1:0] clint_rresp;
wire clint_rvalid;
wire clint_rready;

wire [31:0] clint_awaddr;
wire clint_awvalid;
wire clint_awready;

wire [31:0] clint_wdata;
wire [3:0] clint_wstrb;
wire clint_wvalid;
wire clint_wready;

wire [1:0] clint_bresp;
wire clint_bvalid;
wire clint_bready;

coreAXI u_coreAXI(
    .clk(clk),
    .coreOut_araddr(araddr),
    .coreOut_arprot(),
    .coreOut_arready(arready),
    .coreOut_arvalid(arvalid),
    .coreOut_awaddr(awaddr),
    .coreOut_awprot(),
    .coreOut_awready(awready),
    .coreOut_awvalid(awvalid),
    .coreOut_bready(bready),
    .coreOut_bresp(bresp),
    .coreOut_bvalid(bvalid),
    .coreOut_rdata(rdata),
    .coreOut_rready(rready),
    .coreOut_rresp(rresp),
    .coreOut_rvalid(rvalid),
    .coreOut_wdata(wdata),
    .coreOut_wready(wready),
    .coreOut_wstrb(wstrb),
    .coreOut_wvalid(wvalid),
    .ifu_araddr(ifu_araddr),
    .ifu_arprot(0),
    .ifu_arready(ifu_arready),
    .ifu_arvalid(ifu_arvalid),
    .ifu_rdata(ifu_rdata),
    .ifu_rready(ifu_rready),
    .ifu_rresp(ifu_rresp),
    .ifu_rvalid(ifu_rvalid),
    .lsu_araddr(lsu_araddr),
    .lsu_arprot(0),
    .lsu_arready(lsu_arready),
    .lsu_arvalid(lsu_arvalid),
    .lsu_awaddr(lsu_awaddr),
    .lsu_awprot(0),
    .lsu_awready(lsu_awready),
    .lsu_awvalid(lsu_awvalid),
    .lsu_bready(lsu_bready),
    .lsu_bresp(lsu_bresp),
    .lsu_bvalid(lsu_bvalid),
    .lsu_rdata(lsu_rdata),
    .lsu_rready(lsu_rready),
    .lsu_rresp(lsu_rresp),
    .lsu_rvalid(lsu_rvalid),
    .lsu_wdata(lsu_wdata),
    .lsu_wready(lsu_wready),
    .lsu_wstrb(lsu_wstrb),
    .lsu_wvalid(lsu_wvalid),
    .rstn(~rst),
    .rst(rst),
    .sof(sof_interrupt),
    .tim(tim_interrupt)
);

csr u_csr(
    .clk(clk),
    .rst(rst),
    .ext_interrupt(ext),
    .sof_interrupt(sof),
    .tim_interrupt(tim),
    .epc(pc),
    .cause(a7),
    .waddr(inst[31:20]),
    .wdata(csrwdata),
    .CSROp(CSROp),
    .ecall(ecall),
    .mret(mret),
    .CSRout(CSRout),
    .interrupt(csr_intr)
);

pcReg u_pcReg(
    .clk(clk),
    .rst(rst),
    .PCInc(PCInc),
    .nextPC(nextPC),
    .PC(pc)
);

jumpCalc u_jumpCalc(
    .interrupt(csr_intr),
    .csr(CSRout),
    .imm(imm),
    .pc(pc),
    .rs1(RegBusA),
    .PCAsrc(PCAsrc),
    .PCBsrc(PCBsrc),
    .nextPC(nextPC)
);

branchCond u_branchCond(
    .branch(Branch),
    .less(Less),
    .zero(Zero),
    .PCAsrc(PCAsrc),
    .PCBsrc(PCBsrc)
);

lsu u_lsu(
    .clk(clk),
    .rst(rst),
    .MemWr(MemWr),
    .MemOP(MemOP),
    .ALU_Result(ALUout),
    .Reg_Bport(RegBusB),
    .DataOut(DataOut),
    .araddr(lsu_araddr),
    .arvalid(lsu_arvalid),
    .arready(lsu_arready),
    .rdata(lsu_rdata),
    .rresp(lsu_rresp),
    .rvalid(lsu_rvalid),
    .rready(lsu_rready),
    .awaddr(lsu_awaddr),
    .awvalid(lsu_awvalid),
    .awready(lsu_awready),
    .wdata(lsu_wdata),
    .wstrb(lsu_wstrb),
    .wvalid(lsu_wvalid),
    .wready(lsu_wready),
    .bresp(lsu_bresp),
    .bvalid(lsu_bvalid),
    .bready(lsu_bready),
    .ready(lsu_ready)
);

alu u_alu(
    .A(ALU_A),
    .B(ALU_B),
    .ALUctr(ALUctr),
    .ALUout(ALUout),
    .Less(Less),
    .Zero(Zero)
);

immGenertor u_immGen(
    .instr(inst[31:7]),
    .extOp(ExtOP),
    .imm(imm)
);

registerFile u_registerFile(
    .clk(clk),
    .rst(rst),
    .ra(inst[19:15]),
    .rb(inst[24:20]),
    .rw(inst[11:7]),
    .wen(RegWr),
    .wdata(wbdata),
    .rs1(RegBusA),
    .rs2(RegBusB),
    .a7(a7)
);

contr_gen u_contr_gen(
    .clk(clk),
    .rst(rst),
    .inst(inst),
    .ifu_ready(ifu_ready),
    .lsu_ready(lsu_ready),
    .ext_interrupt(ext_interrupt),
    .sof_interrupt(sof_interrupt),
    .tim_interrupt(tim_interrupt),
    .InsFetch(InsFetch),
    .ExtOP(ExtOP),
    .RegWr(RegWr),
    .ALUAsrc(ALUAsrc),
    .ALUBsrc(ALUBsrc),
    .ALUctr(ALUctr),
    .Branch(Branch),
    .toReg(toReg),
    .MemWr(MemWr),
    .MemOP(MemOP),
    .PCInc(PCInc),
    .CSROp(CSROp),
    .ecall(ecall),
    .mret(mret),
    .ext(ext),
    .sof(sof),
    .tim(tim)
);

ifu u_ifu(
    .clk(clk),
    .rst(rst),
    .araddr(ifu_araddr),
    .arvalid(ifu_arvalid),
    .arready(ifu_arready),
    .rdata(ifu_rdata),
    .rresp(ifu_rresp),
    .rvalid(ifu_rvalid),
    .rready(ifu_rready),
    .pc(pc),
    .InsFetch(InsFetch),
    .ready(ifu_ready),
    .inst(inst)
);


endmodule
