module rvcore(
    input   wire                    clk,
    input   wire                    rst_n,

    //from rom 
    input   wire                    rom_ready_i, 
    input   wire            [127:0] rom_data_i,

    //from ram
    input   wire                    ram_ready_i,
    input   wire            [127:0] ram_data_i,

    //to rom
    output  reg                     rvcore_req_rom_o,
    output  reg             [31:0]  rvcore_addr_rom_o,

    //to ram
    output  reg                     rvcore_Dcache_rd_req_o,
    output  reg             [31:0]  rvcore_Dcache_rd_addr_o,
    output  reg                     rvcore_Dcache_wb_req_o,
    output  reg             [31:0]  rvcore_Dcache_wb_addr_o,
    output  reg             [127:0] rvcore_Dcache_wb_data_o
);

    //source 
    //IF
    wire    [31:0]  if_pc_o;

    wire            if_req_Icache_o;
    wire            if_jump_Icache_o;

    //if_id_reg
    wire    [31:0]  ifid_pc_o;

    //ID
    
    wire    [4:0]   id_reg1_raddr_o;
    wire    [4:0]   id_reg2_raddr_o;

    wire    [31:0]  id_op_a_o;
    wire    [31:0]  id_op_b_o;
    wire    [4:0]   id_reg_waddr_o;
    wire            id_reg_we_o;
    wire    [4:0]   id_ALUctrl_o;
    wire            id_btype_flag_o;
    wire    [31:0]  id_btype_jump_pc_o;
    wire            id_mtype_o;  
    wire            id_mem_rw_o;  
    wire    [1:0]   id_mem_width_o; 
    wire    [31:0]  id_mem_wr_data_o;
    wire            id_mem_rdtype_o;  

    wire            id_reg1_RE_o;
    wire            id_reg2_RE_o;
    wire            id_jump_flag_o;
    wire    [31:0]  id_jump_pc_o;

    //id_ex_reg
    wire    [31:0]  idex_op_a_o;
    wire    [31:0]  idex_op_b_o;
    wire    [4:0]   idex_reg_waddr_o;
    wire            idex_reg_we_o;
    wire    [4:0]   idex_ALUctrl_o;
    wire            idex_btype_flag_o;
    wire    [31:0]  idex_btype_jump_pc_o;

    wire            idex_mtype_o;          
    wire            idex_mem_rw_o;          
    wire    [1:0]   idex_mem_width_o;      
    wire    [31:0]  idex_mem_wr_data_o;   
    wire            idex_mem_rdtype_o;  


    //EX
    wire     [31:0]  ex_op_c_o;
    wire     [4:0]   ex_reg_waddr_o;
    wire             ex_reg_we_o;

    wire             ex_mtype_o;  
    wire             ex_mem_rw_o; 
    wire     [1:0]   ex_mem_width_o;
    wire     [31:0]  ex_mem_wr_data_o;
    wire             ex_mem_rdtype_o;
    wire     [31:0]  ex_mem_addr_o;

    wire             ex_branch_flag_o;
    wire     [31:0]  ex_branch_pc_o;

    //ex_mem_reg
    wire     [31:0]  exmem_op_c_o;
    wire     [4:0]   exmem_reg_waddr_o;
    wire             exmem_reg_we_o;

    wire             exmem_mtype_o;          
    wire             exmem_mem_rw_o;        
    wire     [1:0]   exmem_mem_width_o;      
    wire     [31:0]  exmem_mem_wr_data_o; 
    wire             exmem_mem_rdtype_o;    
    wire     [31:0]  exmem_mem_addr_o;

    //MEM
    wire     [31:0]  mem_op_c_o;
    wire     [4:0]   mem_reg_waddr_o;
    wire             mem_reg_we_o;
    wire             mem_mtype_o;
    wire     [1:0]   mem_width_o;

    wire             mem_rw_o;
    wire             mem_req_Dcache_o;
    wire     [31:0]  mem_addr_o;
    wire     [1:0]   mem_wrwidth_o;
    wire     [31:0]  mem_wr_data_o;


    //mem_wb_reg
    wire     [31:0]  memwb_op_c_o;
    wire     [4:0]   memwb_reg_waddr_o;
    wire             memwb_reg_we_o;
    wire             memwb_mtype_o;
    wire     [1:0]   memwb_mem_width_o;


    //WB
    wire     [31:0]  wb_op_c_o;
    wire     [4:0]   wb_reg_waddr_o;
    wire             wb_reg_we_o;


    //dhnf
    wire             dhnf_harzard_sel1_o;
    wire             dhnf_harzard_sel2_o;
    wire     [31:0]  dhnf_forward_data1_o;
    wire     [31:0]  dhnf_forward_data2_o;

    //regs
    wire     [31:0]  regs_reg1_rdata_o;
    wire     [31:0]  regs_reg2_rdata_o;


    //Icache
    wire             [31:0]  Icache_inst_o;

    wire                     Icache_ready_o;
    wire                     Icache_hit_o;

    wire             [31:0]  Icache_addr_o;
    wire                     Icache_valid_req_o;

    //Dcache
    wire             [31:0]  Dcache_data_o;  
    wire                     Dcache_ready_o;   
    wire                     Dcache_hit_o;
    wire                     Dcache_rd_req_o; 
    wire             [31:0]  Dcache_rd_addr_o;
    wire             [31:0]  Dcache_wb_addr_o;
    wire             [127:0] Dcache_data_ram_o;

    //FC
    wire                     fc_Icache_data_valid_o;
    wire                     fc_Dcache_data_valid_o;

    wire                     fc_flush_ifid_o;
    wire                     fc_flush_idex_o;
    wire                     fc_flush_id_o;
    
    wire             [31:0]  fc_jump_pc_if_o;
    wire                     fc_jump_flag_if_o;
    wire                     fc_jump_flag_Icache_o;
    
    wire                     fc_bk_if_o;
    wire                     fc_bk_id_o;
    wire                     fc_bk_ifid_o;
    wire                     fc_bk_idex_o;
    wire                     fc_bk_exmem_o;
    wire                     fc_bk_memwb_o;



























    
endmodule