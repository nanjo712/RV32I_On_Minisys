module alu(
    A, B, ALUctr, ALUout, Zero, Less
);
    input [31:0] A, B;
    input  [3:0] ALUctr;
    output [31:0] ALUout;         
    output Less;
    output Zero;
    reg [31:0] Ans;
    reg [31:0] ALUout;
    reg Less;
    reg Zero;
    always @(*)              
        begin
            case(ALUctr)
                4'b0000: 
                    begin
                        Ans = A + B;
                        Less = 0;
                        ALUout = Ans;
                    end
                4'b1000:
                    begin
                        Ans = A - B;
                        Less = 0;
                        ALUout = Ans;
                    end
                4'b1110:
                    begin
                        Ans = A | B;
                        Less = 0;
                        ALUout = Ans;
                    end
                4'b0110: 
                    begin
                        Ans = A | B;
                        Less = 0;
                        ALUout = Ans;
                    end
                4'b0111: 
                    begin
                        Ans = A & B;
                        Less = 0;
                        ALUout = Ans;
                    end
                4'b1111: 
                    begin
                        Ans = A & B;
                        Less = 0;
                        ALUout = Ans;
                    end
                4'b0100:
                    begin
                        Ans = A ^ B;
                        Less = 0;
                        ALUout = Ans;
                    end
                4'b1100:
                    begin
                        Ans = A ^ B;
                        Less = 0;
                        ALUout = Ans;
                    end
                4'b0010:
                    begin
                        Less = ($signed(A) < $signed(B)) ? 1 : 0;
                        Ans = A - B;
                        ALUout = {31'b0, Less};
                    end
                4'b1010: 
                    begin
                        Less = (A < B) ? 1 : 0;
                        Ans = A - B;
                        ALUout = {31'b0, Less};
                    end
                4'b0001:
                    begin
                        Ans = A << B[4:0];
                        Less = 0;
                        ALUout = Ans;
                    end
                4'b1001:
                    begin
                        Ans = A << B[4:0];
                        Less = 0;
                        ALUout = Ans;
                    end
                4'b0011:
                    begin
                        Ans = B;
                        Less = 0;
                        ALUout = Ans;
                    end
                4'b1011:
                    begin
                        Ans = B;
                        Less = 0;
                        ALUout = Ans;
                    end
                4'b0101:
                    begin
                        Ans = A >> B[4:0];
                        Less = 0;
                        ALUout = Ans;
                    end
                4'b1101:
                    begin
                        Ans = $signed(A) >>> B[4:0];
                        Less = 0;
                        ALUout = Ans;
                    end
            endcase
            Zero = Ans == 0;
        end
endmodule
