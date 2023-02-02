module mem_stage (
    input   wire                    clk,
    input   wire                    rst_n,
    //from ex_mem_reg
    input   wire            [31:0]  ex_mem_reg_op_c_i,
    input   wire            [4:0]   ex_mem_reg_reg_waddr_i,
    input   wire                    ex_mem_reg_reg_we_i,

    input   wire                    ex_mem_reg_mtype_i,          
    input   wire                    ex_mem_reg_mem_rw_i,        
    input   wire            [1:0]   ex_mem_reg_mem_width_i,      
    input   wire            [31:0]  ex_mem_reg_mem_wr_data_i, 
    input   wire                    ex_mem_reg_mem_rdtype_i,    
    input   wire            [31:0]  ex_mem_reg_mem_addr_i   
    //to mem_wb_reg
    output  wire            [31:0]  mem_op_c_o,
    output  wire            [4:0]   mem_reg_waddr_o,
    output  wire                    mem_reg_we_o,

    output  wire                    mem_mtype_o,
    output  wire            [1:0]   mem_width_o,


    //to Dcache
    output  wire                    mem_rw_o,
    output  wire                    mem_valid_req_o,

    output  wire            [31:0]  mem_addr_o,
    output  wire            [1:0]   mem_wrwidth_o,
    output  wire            [31:0]  mem_wr_data_o
);

    //mem inst
    assign mem_mtype_o = ex_mem_reg_mtype_i;
    assign mem_width_o = ex_mem_reg_mem_width_i;

    assign mem_valid_req_o = ex_mem_reg_mtype_i;
    assign mem_rw_o = ex_mem_reg_mem_rw_i;
    assign mem_addr_o = ex_mem_reg_mem_addr_i;
    assign mem_wrwidth_o = ex_mem_reg_mem_width_i;
    assign mem_wr_data_o = ex_mem_reg_mem_wr_data_i;

    

    assign mem_op_c_o = ex_mem_reg_op_c_i;
    assign mem_reg_waddr_o = ex_mem_reg_reg_waddr_i;
    assign mem_reg_we_o = ex_mem_reg_reg_we_i;



endmodule