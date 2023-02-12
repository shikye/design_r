module MEM (
    input   wire                    clk,
    input   wire                    rst_n,
    //from ex_mem_reg
    input   wire            [31:0]  exmem_op_c_i,
    input   wire            [4:0]   exmem_reg_waddr_i,
    input   wire                    exmem_reg_we_i,

    input   wire                    exmem_mtype_i,          
    input   wire                    exmem_mem_rw_i,        
    input   wire            [1:0]   exmem_mem_width_i,      
    input   wire            [31:0]  exmem_mem_wr_data_i, 
    input   wire                    exmem_mem_rdtype_i,    
    input   wire            [31:0]  exmem_mem_addr_i,

    input   wire                    exmem_req_Dcache_i,
    //to mem_wb_reg
    output  wire            [31:0]  mem_op_c_o,
    output  wire            [4:0]   mem_reg_waddr_o,
    output  wire                    mem_reg_we_o,

    output  wire                    mem_mtype_o,
    output  wire            [1:0]   mem_width_o,
    //to Dcache
    output  wire                    mem_rw_o,
    output  wire                    mem_req_Dcache_o,

    output  wire            [31:0]  mem_addr_o,
    output  wire            [1:0]   mem_wrwidth_o,
    output  wire            [31:0]  mem_wr_data_o    
);


    assign mem_mtype_o = exmem_mtype_i;
    assign mem_width_o = exmem_mem_width_i;

    assign mem_req_Dcache_o = exmem_req_Dcache_i;
    assign mem_rw_o = exmem_mem_rw_i;
    assign mem_addr_o = exmem_mem_addr_i;
    assign mem_wrwidth_o = exmem_mem_width_i;
    assign mem_wr_data_o = exmem_mem_wr_data_i;

    
    assign mem_op_c_o = exmem_op_c_i;
    assign mem_reg_waddr_o = exmem_reg_waddr_i;
    assign mem_reg_we_o = exmem_reg_we_i;


endmodule