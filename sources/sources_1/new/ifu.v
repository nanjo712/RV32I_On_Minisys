module ifu(
    input wire clk,
    input wire rst,

    output wire [31:0] araddr,
    output wire arvalid,
    input wire arready,

    input wire [31:0] rdata,
    input wire [1:0] rresp,
    input wire rvalid,
    output wire rready,

    input wire [31:0] pc,
    
    input wire InsFetch,
    output wire ready,

    output wire [31:0] inst
);

typedef enum logic {
    s_wait,
    s_done
} state_t;

reg rstate;
reg [31:0] in_inst;

wire in_arvalid = (rstate == s_wait) & InsFetch;
wire in_rready = rstate == s_done;

wire r_ready = (rstate == s_done) && rvalid && rready;

always @(posedge clk or posedge rst) begin
    if(rst) begin
        rstate <= 0;
    end
    else begin
        case(rstate)
            s_wait: rstate <= (arready & in_arvalid) ? s_done : rstate;
            s_done: rstate <= (rvalid & in_rready) ? s_wait : s_done;
            default: rstate <= s_wait;
        endcase
    end
end

always @(posedge clk or posedge rst) begin
    if(rst) begin
        in_inst <= 0;
    end
    else begin
        in_inst <= (r_ready) ? rdata : in_inst;
    end
end

assign araddr = pc;
assign arvalid = in_arvalid;
assign rready = in_rready;

assign ready = r_ready;
assign inst = in_inst;

endmodule