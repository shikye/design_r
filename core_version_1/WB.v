module WB (
    input   wire                    clk,
    input   wire                    rst_n,
    //from mem_wb_reg
    input   wire            [31:0]  memwb_op_c_i,
    input   wire            [4:0]   memwb_reg_waddr_i,
    input   wire                    memwb_reg_we_i,

    input   wire                    memwb_mtype_i,
    input   wire            [1:0]   memwb_width_i,
    //to regs
    output  wire            [31:0]  wb_op_c_o,
    output  wire            [4:0]   wb_reg_waddr_o,
    output  wire                    wb_reg_we_o,

    //from fc
    input   wire                    fc_bk_wb_i
);

    assign wb_op_c_o = memwb_op_c_i;
    assign wb_reg_waddr_o = memwb_reg_waddr_i;
    assign wb_reg_we_o = fc_bk_wb_i ? 1'b0 : memwb_reg_we_i;
    

endmodule