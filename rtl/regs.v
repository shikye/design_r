module regs(
    input   wire                    clk,
    input   wire                    rst_n,
    //from id_stage
    input   wire            [4:0]   id_reg1_raddr_i,
    input   wire            [4:0]   id_reg2_raddr_i,  
    //to id_stage
    output  wire            [31:0]  regs_reg1_rdata_o,
    output  wire            [31:0]  regs_reg2_rdata_o
);

    reg [31:0]  regs[0:31]; //先不初始化全为0试一试


    // always @(posedge clk or negedge rst_n)begin
    //     if(rst_n == 1'b0)begin
    //         regs_reg1_rdata_o <= 32'h0;
    //         regs_reg2_rdata_o <= 32'h0;
    //     end
    //     else begin
    //         regs_reg1_rdata_o <= regs[id_reg1_raddr_i];
    //         regs_reg2_rdata_o <= regs[id_reg2_raddr_i];
    //     end
    // end


    assign regs_reg1_rdata_o = regs[id_reg1_raddr_i];
    assign regs_reg2_rdata_o = regs[id_reg2_raddr_i];

endmodule