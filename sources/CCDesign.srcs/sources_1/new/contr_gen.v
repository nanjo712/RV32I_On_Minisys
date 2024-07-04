module contr_gen(
    input wire clk,
    input wire rst,

    input wire [31:0] inst,

    input wire ifu_ready,
    input wire lsu_ready,
    
    input wire ext_interrupt,
    input wire sof_interrupt,
    input wire tim_interrupt,

    output wire InsFetch,
    output wire [2:0] ExtOP,
    output wire RegWr,
    output wire ALUAsrc,
    output wire [1:0] ALUBsrc,
    output wire [3:0] ALUctr,
    output wire [2:0] Branch,
    output wire [1:0] toReg,
    output wire MemWr,
    output wire [2:0] MemOP,
    output wire PCInc,
    output wire [1:0] CSROp,
    output wire ecall,
    output wire mret,
    output wire ext,
    output wire sof,
    output wire tim
);

reg [2:0] cycle;

wire W1 = cycle == 3'b001;
wire W2 = cycle == 3'b010;
wire W3 = cycle == 3'b100;

wire [6:0] op = inst[6:0];
wire [2:0] func3 = inst[14:12];
wire [6:0] func7 = inst[31:25];

wire [6:0] ALUOpI = 7'b0010011;
wire [6:0] ALUOpR = 7'b0110011;
wire [6:0] BrcOpB = 7'b1100011; 
wire [6:0] ladOpI = 7'b0000011;
wire [6:0] strOpS = 7'b0100011;
wire [6:0] SysOpI = 7'b1110011;

wire lui = (op == 7'b0110111);
wire auipc = (op == 7'b0010111);
wire addi = ({func3, op} == {3'b000, ALUOpI});
wire slti = ({func3, op} == {3'b010, ALUOpI});
wire sltiu = ({func3, op} == {3'b011, ALUOpI});
wire xori = ({func3, op} == {3'b100, ALUOpI});
wire ori = ({func3, op} == {3'b110, ALUOpI});
wire andi = ({func3, op} == {3'b111, ALUOpI});
wire slli = ({func3, op} == {3'b001, ALUOpI});
wire srli = ({func7[5], func3, op} == {1'b0, 3'b101, ALUOpI});
wire srai = ({func7[5], func3, op} == {1'b1, 3'b101, ALUOpI});

wire add = ({func7[5], func3, op} == {1'b0, 3'b000, ALUOpR});
wire sub = ({func7[5], func3, op} == {1'b1, 3'b000, ALUOpR});
wire sll = ({func3, op} == {3'b001, ALUOpR});
wire slt = ({func3, op} == {3'b010, ALUOpR});
wire sltu = ({func3, op} == {3'b011, ALUOpR});
wire _xor = ({func3, op} == {3'b100, ALUOpR});
wire srl = ({func7[5], func3, op} == {1'b0, 3'b101, ALUOpR});
wire sra = ({func7[5], func3, op} == {1'b1, 3'b101, ALUOpR});
wire _or =({func3, op} == {3'b110, ALUOpR});
wire _and = ({func3, op} == {3'b111, ALUOpR});

wire jal = op == 7'b1101111;
wire jalr = op == 7'b1100111;

wire beq = ({func3, op} == {3'b000, BrcOpB});
wire bne = ({func3, op} == {3'b001, BrcOpB});
wire blt = ({func3, op} == {3'b100, BrcOpB});
wire bge = ({func3, op} == {3'b101, BrcOpB});
wire bltu = ({func3, op} == {3'b110, BrcOpB});
wire bgeu = ({func3, op} == {3'b111, BrcOpB});

wire lb = ({func3, op} == {3'b000, ladOpI});
wire lh = ({func3, op} == {3'b001, ladOpI});
wire lw = ({func3, op} == {3'b010, ladOpI});
wire lbu = ({func3, op} == {3'b100, ladOpI});
wire lhu = ({func3, op} == {3'b101, ladOpI});

wire sb = ({func3, op} == {3'b000, strOpS});
wire sh = ({func3, op} == {3'b001, strOpS});
wire sw = ({func3, op} == {3'b010, strOpS});

wire csrrw = ({func3, op} == {3'b001, SysOpI});
wire csrrs = ({func3, op} == {3'b010, SysOpI});
wire csrrc = ({func3, op} == {3'b011, SysOpI});
wire csrrwi = ({func3, op} == {3'b101, SysOpI});
wire csrrsi = ({func3, op} == {3'b110, SysOpI});
wire csrrci = ({func3, op} == {3'b111, SysOpI});

wire in_ecall = inst == 32'b00000000000000000000000001110011;
wire in_mret = inst == 32'b00110000001000000000000001110011;

wire csrType = csrrw || csrrs || csrrc || csrrwi || csrrsi || csrrci;

always @(posedge clk or posedge rst) begin
    if(rst) begin
        cycle <= 3'b001;
    end
    else begin
        case(cycle)
            3'b001: cycle <= (ifu_ready) ? 3'b010 : cycle;
            3'b010: cycle <= ((op == ladOpI) && lsu_ready) ? 3'b100 : 
                             ((op == ladOpI || op == strOpS) && ~lsu_ready) ? cycle : 3'b001;
            3'b100: cycle <= 3'b001;
            default: cycle <= 3'b000;
        endcase
    end
end

wire in_InsFetch = 1;

wire [2:0] in_ExtOP = ((op == ALUOpI || op == ladOpI || jalr || csrType)) ? 3'b000 : // I type
                      ((lui || auipc)) ? 3'b001 : // U type
                      ((op == strOpS)) ? 3'b010 : // S type
                      ((op == BrcOpB)) ? 3'b011 : // B type
                      (jal) ? 3'b100 : // J type
                      3'b111;

wire in_RegWr = (lui || auipc || jal || jalr || op == ALUOpI || op == ALUOpR || op == ladOpI || csrType);

wire in_ALUAsrc = auipc || jal || jalr;

wire [1:0] in_ALUBsrc = ((op == ALUOpR) || (op == BrcOpB)) ? 2'b00 :
                        (lui || auipc || (op == ALUOpI) || (op == ladOpI) || (op == strOpS)) ? 2'b01 :
                        (jal || jalr) ? 2'b10 : 2'b11;
                 
wire [3:0] in_ALUctr = (auipc || addi || add || jal || jalr || (op == ladOpI) || (op == strOpS)) ? 4'b0000 :
                       (slli || sll) ? 4'b0001 :
                       (slti || slt || beq || bne || blt || bge) ? 4'b0010 :
                       (lui) ? 4'b0011 :
                       (xori || _xor) ? 4'b0100 :
                       (srli || srl) ? 4'b0101 :
                       (ori || _or) ? 4'b0110 :
                       (andi || _and) ? 4'b0111 :
                       (sub) ? 4'b1000 :
                       (sltiu || sltu || bgeu || bltu) ? 4'b1010 :
                       (srai || sra) ? 4'b1101 : 4'b1111; 
                 
wire [2:0] in_Branch = (jal) ? 3'b001 :
                       (jalr) ? 3'b010 :
                       (ecall || mret) ? 3'b011 :
                       (beq) ? 3'b100 :
                       (bne) ? 3'b101 :
                       (blt || bltu) ? 3'b110 :
                       (bge || bgeu) ? 3'b111 : 3'b000;
                 
wire [1:0] in_toReg = (op == ladOpI) ? 2'b01 :
                      (csrType) ? 2'b10 : 2'b00;

wire in_MemWr = (op == strOpS);

wire [2:0] in_MemOP = (lb || sb) ? 3'b000 :
                      (lh || sh) ? 3'b001 :
                      (lw || sw) ? 3'b010 :
                      (lbu) ? 3'b100 :
                      (lhu) ? 3'b101 : 3'b111;
                
wire in_PCInc = 1;

wire [1:0] in_CSROp = (csrrw || csrrwi) ? 2'b01 :
                (csrrs || csrrsi) ? 2'b10 :
                (csrrc || csrrci) ? 2'b11 : 2'b00;

wire endofInst = (W2) ? 
                    (op == strOpS) ? 
                        lsu_ready :
                    (op == ladOpI) ? 
                        0 : 
                    1 :
                 (W3);

assign InsFetch = (W1) ? in_InsFetch : 0;
assign ExtOP = (W2) ? in_ExtOP : 3'b000;

assign RegWr =  (endofInst) ? in_RegWr : 0;

assign ALUAsrc = (W2) ? in_ALUAsrc : 0;

assign ALUBsrc = (W2) ? in_ALUBsrc : 2'b00;

assign ALUctr = (W2) ? in_ALUctr : 4'b0000;

assign Branch = (W2) ? in_Branch : 3'b000;

assign toReg = (endofInst) ? in_toReg : 2'b00;

assign MemWr = (W2) ? in_MemWr : 0;

assign MemOP = (W2) ? in_MemOP : 3'b111;

assign PCInc = (endofInst) ? in_PCInc : 0;

assign CSROp = (endofInst) ? in_CSROp : 2'b00;

assign ecall = (endofInst) ? in_ecall : 0;

assign mret = (endofInst) ? in_mret : 0;

assign ext = (endofInst) ? ext_interrupt : 0;

assign sof = (endofInst) ? sof_interrupt : 0;

assign tim = (endofInst) ? tim_interrupt : 0;

endmodule