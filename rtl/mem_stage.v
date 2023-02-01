module mem_stage (
    input   wire                    clk,
    input   wire                    rst_n,
    //from ex_mem_reg
    input   wire            [31:0]  ex_mem_reg_op_c_i,
    input   wire            [4:0]   ex_mem_reg_reg_waddr_i,
    input   wire                    ex_mem_reg_reg_we_i,
    //to mem_wb_reg
    output  wire            [31:0]  mem_op_c_o,
    output  wire            [4:0]   mem_reg_waddr_o,
    output  wire                    mem_reg_we_o
);

    

    assign mem_op_c_o = ex_mem_reg_op_c_i;
    assign mem_reg_waddr_o = ex_mem_reg_reg_waddr_i;
    assign mem_reg_we_o = ex_mem_reg_reg_we_i;



endmodule