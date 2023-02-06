`include "define.v"
module rv32core(
    input   wire                    clk,
    input   wire                    rst_n,

    //to rom
    output  wire            [31:0]  rv32core_addr_o,
    output  wire                    rv32core_valid_req_o,
    //from rom
    input   wire                    rom_ready_i,
    input   wire            [127:0] rom_data_i,    //to Icache
    //to ram
    output  wire                    rv32core_Dcache_rd_req_o,
    output  wire            [31:0]  rv32core_Dcahce_rd_addr_o,
    output  wire                    rv32core_Dcache_wb_req_o,
    output  wire            [31:0]  rv32core_Dcache_wb_addr_o,
    output  wire            [127:0] rv32core_Dcache_data_ram_o,
    //from ram
    input   wire            [127:0] ram_data_i,
    input   wire                    ram_ready_i

);

    assign rv32core_addr_o = Icache_addr_o;
    assign rv32core_valid_req_o = Icache_valid_req_o;

    assign rv32core_Dcache_rd_req_o = Dcache_rd_req_o;
    assign rv32core_Dcahce_rd_addr_o = Dcache_rd_addr_o;
    assign rv32core_Dcache_wb_req_o = Dcache_wb_req_o;
    assign rv32core_Dcache_wb_addr_o = Dcache_wb_addr_o;
    assign rv32core_Dcache_data_ram_o = Dcache_data_ram_o;

    //source
    //if
    wire    [31:0]  if_pc_o;
    wire            if_valid_req_o;
    wire            if_jump_stop_Icache_o;
    //if_id_reg
    wire    [31:0]  if_id_reg_pc_o;
    //regs
    wire    [31:0]  regs_reg1_rdata_o;
    wire    [31:0]  regs_reg2_rdata_o;
    //id
    wire    [4:0]   id_reg1_raddr_o;
    wire    [4:0]   id_reg2_raddr_o;
    wire    [31:0]  id_op_a_o;
    wire    [31:0]  id_op_b_o;
    wire    [4:0]   id_reg_waddr_o;
    wire    [4:0]   id_ALUctrl_o;
    wire            id_reg_we_o;
    wire            id_btype_flag_o;
    wire    [31:0]  id_btype_jump_pc_o;
    wire            id_mtype_o;
    wire            id_mem_rw_o;
    wire    [1:0]   id_mem_width_o;
    wire    [31:0]  id_mem_wr_data_o;
    wire            id_mem_rdtype_o;

    wire            id_reg1_RE_o;
    wire            id_reg2_RE_o;
    wire    [31:0]  id_jump_pc_o;
    wire            id_jump_flag_o;
    //id_ex_reg
    wire    [31:0]  id_ex_reg_op_a_o;
    wire    [31:0]  id_ex_reg_op_b_o;
    wire    [4:0]   id_ex_reg_ALUctrl_o;
    wire    [4:0]   id_ex_reg_reg_waddr_o;
    wire            id_ex_reg_reg_we_o;

    wire            id_ex_reg_btype_flag_o;
    wire    [31:0]  id_ex_reg_btype_jump_pc_o;

    wire            id_ex_reg_mtype_o;       
    wire            id_ex_reg_mem_rw_o;        
    wire    [1:0]   id_ex_reg_mem_width_o;     
    wire    [31:0]  id_ex_reg_mem_wr_data_o;  
    wire            id_ex_reg_mem_rdtype_o;  
    //ex
    wire    [31:0]  ex_op_c_o;
    wire    [4:0]   ex_reg_waddr_o;
    wire            ex_reg_we_o;
    wire            ex_branch_flag_o;
    wire    [31:0]  ex_jump_pc_o;

    wire            ex_mtype_o;  
    wire            ex_mem_rw_o; 
    wire    [1:0]   ex_mem_width_o;
    wire    [31:0]  ex_mem_wr_data_o;
    wire            ex_mem_rdtype_o;
    wire    [31:0]  ex_mem_addr_o;

    //ex_mem_reg
    wire    [31:0]  ex_mem_reg_op_c_o;
    wire    [4:0]   ex_mem_reg_reg_waddr_o;
    wire            ex_mem_reg_reg_we_o;

    wire            ex_mem_reg_mtype_o;  
    wire            ex_mem_reg_mem_rw_o; 
    wire    [1:0]   ex_mem_reg_mem_width_o;
    wire    [31:0]  ex_mem_reg_mem_wr_data_o;
    wire            ex_mem_reg_mem_rdtype_o;
    wire    [31:0]  ex_mem_reg_mem_addr_o;


    //mem
    wire    [31:0]  mem_op_c_o;
    wire    [4:0]   mem_reg_waddr_o;
    wire            mem_reg_we_o;

    wire            mem_mtype_o;
    wire    [1:0]   mem_width_o;

    wire            mem_rw_o;
    wire            mem_valid_req_o;
    wire    [31:0]  mem_addr_o;
    wire    [1:0]   mem_wrwidth_o;
    wire    [31:0]  mem_wr_data_o;
    //mem_wb_reg
    wire    [31:0]  mem_wb_reg_op_c_o;
    wire    [4:0]   mem_wb_reg_reg_waddr_o;
    wire            mem_wb_reg_reg_we_o;

    wire            mem_wb_reg_mtype_o;
    wire    [1:0]   mem_wb_reg_width_o;            
    //wb
    wire    [31:0]  wb_op_c_o;
    wire    [4:0]   wb_reg_waddr_o;
    wire            wb_reg_we_o;
    //dhnf
    wire            dhnf_harzard_sel1_o;
    wire            dhnf_harzard_sel2_o;
    wire    [31:0]  dhnf_forward_data1_o;
    wire    [31:0]  dhnf_forward_data2_o;
    //fc
    wire            fc_jump_stop_Icache_o;
    wire            fc_flush_btype_flag_o;
    wire            fc_flush_jtype_flag_o;
    wire            fc_Icache_stall_flag_o;
    wire            fc_jump_flag_o;
    wire    [31:0]  fc_jump_pc_o;
    wire            fc_Icache_data_valid_o;
    wire            fc_Dcache_stall_flag_o;
    wire            fc_Dcache_data_valid_o;
    //Icache
    wire            Icache_ready_o;
    wire    [31:0]  Icache_inst_o;
    wire            Icache_hit_o;
    wire    [31:0]  Icache_addr_o;
    wire            Icache_valid_req_o;
    //Dcache
    wire    [31:0]  Dcache_data_o;

    wire            Dcache_ready_o;
    wire            Dcache_hit_o;

    wire            Dcache_rd_req_o;
    wire    [31:0]  Dcache_rd_addr_o;
    wire            Dcache_wb_req_o;
    wire    [31:0]  Dcache_wb_addr_o;
    wire    [127:0] Dcache_data_ram_o;




    if_stage if_stage_ins(
        .clk(clk),
        .rst_n(rst_n),
        .if_pc_o(if_pc_o),
        .if_valid_req_o(if_valid_req_o),
        .fc_Icache_stall_flag_i(fc_Icache_stall_flag_o),
        .fc_Dcache_stall_flag_i(fc_Dcache_stall_flag_o),
        .fc_jump_pc_i(fc_jump_pc_o),
        .fc_jump_flag_i(fc_jump_flag_o),
        .if_jump_stop_Icache_o(if_jump_stop_Icache_o)
    );

    if_id_reg if_id_reg_ins(
        .clk(clk),
        .rst_n(rst_n),
        .if_pc_i(if_pc_o),
        .if_id_reg_pc_o(if_id_reg_pc_o),
        .fc_flush_btype_flag_i(fc_flush_btype_flag_o),
        .fc_flush_jtype_flag_i(fc_flush_jtype_flag_o)
    );

    id_stage id_stage_ins(
        .clk(clk),
        .rst_n(rst_n),
        .if_id_reg_pc_i(if_id_reg_pc_o),
        .regs_reg1_rdata_i(regs_reg1_rdata_o),
        .regs_reg2_rdata_i(regs_reg2_rdata_o),
        .id_reg1_raddr_o(id_reg1_raddr_o),
        .id_reg2_raddr_o(id_reg2_raddr_o),
        .id_op_a_o(id_op_a_o),
        .id_op_b_o(id_op_b_o),
        .id_reg_waddr_o(id_reg_waddr_o),
        .id_ALUctrl_o(id_ALUctrl_o),
        .id_reg_we_o(id_reg_we_o),
        .id_btype_flag_o(id_btype_flag_o),
        .id_btype_jump_pc_o(id_btype_jump_pc_o),
        .id_mtype_o(id_mtype_o),
        .id_mem_rw_o(id_mem_rw_o),
        .id_mem_width_o(id_mem_width_o),
        .id_mem_wr_data_o(id_mem_wr_data_o),
        .id_mem_rdtype_o(id_mem_rdtype_o),
        .dhnf_harzard_sel1_i(dhnf_harzard_sel1_o),
        .dhnf_harzard_sel2_i(dhnf_harzard_sel2_o),
        .dhnf_forward_data1_i(dhnf_forward_data1_o),
        .dhnf_forward_data2_i(dhnf_forward_data2_o),
        .id_reg1_RE_o(id_reg1_RE_o),
        .id_reg2_RE_o(id_reg2_RE_o),
        .Icache_inst_i(Icache_inst_o),
        .fc_jump_flag_i(fc_jump_flag_o),
        .fc_Icache_data_valid_i(fc_Icache_data_valid_o),
        .fc_Dcache_stall_flag_i(fc_Dcache_stall_flag_o),
        .id_jump_flag_o(id_jump_flag_o),
        .id_jump_pc_o(id_jump_pc_o)
    );

    regs regs_ins(
        .clk(clk),
        .rst_n(rst_n),
        .id_reg1_raddr_i(id_reg1_raddr_o),
        .id_reg2_raddr_i(id_reg2_raddr_o),
        .regs_reg1_rdata_o(regs_reg1_rdata_o),
        .regs_reg2_rdata_o(regs_reg2_rdata_o),
        .wb_op_c_i(wb_op_c_o),
        .wb_reg_waddr_i(wb_reg_waddr_o),
        .wb_reg_we_i(wb_reg_we_o)
    );

    id_ex_reg id_ex_reg_ins(
        .clk(clk),
        .rst_n(rst_n),
        .cu_ALUctrl_i(id_ALUctrl_o),
        .id_op_a_i(id_op_a_o),
        .id_op_b_i(id_op_b_o),
        .id_reg_waddr_i(id_reg_waddr_o),
        .id_reg_we_i(id_reg_we_o),
        .id_btype_flag_i(id_btype_flag_o),
        .id_btype_jump_pc_i(id_btype_jump_pc_o),

        .id_mtype_i(id_mtype_o),
        .id_mem_rw_i(id_mem_rw_o),
        .id_mem_width_i(id_mem_width_o),
        .id_mem_wr_data_i(id_mem_wr_data_o),
        .id_mem_rdtype_i(id_mem_rdtype_o),

        .id_ex_reg_op_a_o(id_ex_reg_op_a_o),
        .id_ex_reg_op_b_o(id_ex_reg_op_b_o),
        .id_ex_reg_ALUctrl_o(id_ex_reg_ALUctrl_o),
        .id_ex_reg_reg_waddr_o(id_ex_reg_reg_waddr_o),
        .id_ex_reg_reg_we_o(id_ex_reg_reg_we_o),
        .id_ex_reg_btype_flag_o(id_ex_reg_btype_flag_o),
        .id_ex_reg_btype_jump_pc_o(id_ex_reg_btype_jump_pc_o),

        .id_ex_reg_mtype_o(id_ex_reg_mtype_o),
        .id_ex_reg_mem_rw_o(id_ex_reg_mem_rw_o),     
        .id_ex_reg_mem_width_o(id_ex_reg_mem_width_o),  
        .id_ex_reg_mem_wr_data_o(id_ex_reg_mem_wr_data_o),
        .id_ex_reg_mem_rdtype_o(id_ex_reg_mem_rdtype_o), 


        .fc_flush_btype_flag_i(fc_flush_btype_flag_o),
        .fc_flush_jtype_flag_i(fc_flush_jtype_flag_o),

        .fc_Dcache_stall_flag_i(fc_Dcache_stall_flag_o)
    );

    ex_stage ex_stage_ins(
        .clk(clk),
        .rst_n(rst_n),
        .id_ex_reg_op_a_i(id_ex_reg_op_a_o),
        .id_ex_reg_op_b_i(id_ex_reg_op_b_o),
        .id_ex_reg_ALUctrl_i(id_ex_reg_ALUctrl_o),
        .id_ex_reg_reg_waddr_i(id_ex_reg_reg_waddr_o),
        .id_ex_reg_reg_we_i(id_ex_reg_reg_we_o),
        .id_ex_reg_btype_flag_i(id_ex_reg_btype_flag_o),
        .id_ex_reg_btype_jump_pc_i(id_ex_reg_btype_jump_pc_o),

        .id_ex_reg_mtype_i(id_ex_reg_mtype_o),
        .id_ex_reg_mem_rw_i(id_ex_reg_mem_rw_o),
        .id_ex_reg_mem_width_i(id_ex_reg_mem_width_o),
        .id_ex_reg_mem_wr_data_i(id_ex_reg_mem_wr_data_o),
        .id_ex_reg_mem_rdtype_i(id_ex_reg_mem_rdtype_o),



        .ex_op_c_o(ex_op_c_o),
        .ex_reg_waddr_o(ex_reg_waddr_o),
        .ex_reg_we_o(ex_reg_we_o),

        .ex_mtype_o(ex_mtype_o),  
        .ex_mem_rw_o(ex_mem_rw_o), 
        .ex_mem_width_o(ex_mem_width_o),
        .ex_mem_wr_data_o(ex_mem_wr_data_o),
        .ex_mem_rdtype_o(ex_mem_rdtype_o),
        .ex_mem_addr_o(ex_mem_addr_o),



        .ex_branch_flag_o(ex_branch_flag_o),
        .ex_jump_pc_o(ex_jump_pc_o)
    );

    ex_mem_reg ex_mem_reg_ins(
        .clk(clk),
        .rst_n(rst_n),
        .ex_op_c_i(ex_op_c_o),
        .ex_reg_waddr_i(ex_reg_waddr_o),
        .ex_reg_we_i(ex_reg_we_o),


        .ex_mtype_i(ex_mtype_o),
        .ex_mem_rw_i(ex_mem_rw_o),
        .ex_mem_width_i(ex_mem_width_o),
        .ex_mem_wr_data_i(ex_mem_wr_data_o),
        .ex_mem_rdtype_i(ex_mem_rdtype_o),
        .ex_mem_addr_i(ex_mem_addr_o),



        .ex_mem_reg_op_c_o(ex_mem_reg_op_c_o),
        .ex_mem_reg_reg_waddr_o(ex_mem_reg_reg_waddr_o),
        .ex_mem_reg_reg_we_o(ex_mem_reg_reg_we_o),

        .ex_mem_reg_mtype_o(ex_mem_reg_mtype_o),
        .ex_mem_reg_mem_rw_o(ex_mem_reg_mem_rw_o),
        .ex_mem_reg_mem_width_o(ex_mem_reg_mem_width_o),
        .ex_mem_reg_mem_wr_data_o(ex_mem_reg_mem_wr_data_o),
        .ex_mem_reg_mem_rdtype_o(ex_mem_reg_mem_rdtype_o),
        .ex_mem_reg_mem_addr_o(ex_mem_reg_mem_addr_o),

        .fc_Dcache_stall_flag_i(fc_Dcache_stall_flag_o)
    );

    mem_stage mem_stage_ins(
        .clk(clk),
        .rst_n(rst_n),
        .ex_mem_reg_op_c_i(ex_mem_reg_op_c_o),
        .ex_mem_reg_reg_waddr_i(ex_mem_reg_reg_waddr_o),
        .ex_mem_reg_reg_we_i(ex_mem_reg_reg_we_o),

        .ex_mem_reg_mtype_i(ex_mem_reg_mtype_o),
        .ex_mem_reg_mem_rw_i(ex_mem_reg_mem_rw_o),
        .ex_mem_reg_mem_width_i(ex_mem_reg_mem_width_o),
        .ex_mem_reg_mem_wr_data_i(ex_mem_reg_mem_wr_data_o),
        .ex_mem_reg_mem_rdtype_i(ex_mem_reg_mem_rdtype_o),
        .ex_mem_reg_mem_addr_i(ex_mem_reg_mem_addr_o),


        .mem_op_c_o(mem_op_c_o),
        .mem_reg_waddr_o(mem_reg_waddr_o),
        .mem_reg_we_o(mem_reg_we_o),

        .mem_mtype_o(mem_mtype_o),
        .mem_width_o(mem_width_o),

        .mem_rw_o(mem_rw_o),
        .mem_valid_req_o(mem_valid_req_o),
        .mem_addr_o(mem_addr_o),
        .mem_wrwidth_o(mem_wrwidth_o),
        .mem_wr_data_o(mem_wr_data_o)
    );

    mem_wb_reg mem_wb_reg_ins(
        .clk(clk),
        .rst_n(rst_n),
        .mem_op_c_i(mem_op_c_o),
        .mem_reg_waddr_i(mem_reg_waddr_o),
        .mem_reg_we_i(mem_reg_we_o),

        .mem_mtype_i(mem_mtype_o),
        .mem_width_i(mem_width_o),


        .mem_wb_reg_op_c_o(mem_wb_reg_op_c_o),
        .mem_wb_reg_reg_waddr_o(mem_wb_reg_reg_waddr_o),
        .mem_wb_reg_reg_we_o(mem_wb_reg_reg_we_o),

        .mem_wb_reg_mtype_o(mem_wb_reg_mtype_o),
        .mem_wb_reg_width_o(mem_wb_reg_width_o),
        .fc_Dcache_stall_flag_i(fc_Dcache_stall_flag_o)
    );

    wb_stage wb_stage_ins(
        .clk(clk),
        .rst_n(rst_n),
        .mem_wb_reg_op_c_i(mem_wb_reg_op_c_o),
        .mem_wb_reg_reg_waddr_i(mem_wb_reg_reg_waddr_o),
        .mem_wb_reg_reg_we_i(mem_wb_reg_reg_we_o),
        .mem_wb_reg_mtype_i(mem_wb_reg_mtype_o),
        .mem_wb_reg_width_i(mem_wb_reg_width_o),

        .wb_op_c_o(wb_op_c_o),
        .wb_reg_waddr_o(wb_reg_waddr_o),
        .wb_reg_we_o(wb_reg_we_o),

        .Dcache_data_i(Dcache_data_o),
        .fc_Dcache_data_valid_i(fc_Dcache_data_valid_o)
    );
    
    Data_Hazard_N_Forward dhnf_ins(
        .id_reg1_raddr_i(id_reg1_raddr_o),
        .id_reg2_raddr_i(id_reg2_raddr_o),
        .cu_reg1_RE_i(id_reg1_RE_o),
        .cu_reg2_RE_i(id_reg2_RE_o),

        .ex_reg_waddr_i(ex_reg_waddr_o),
        .ex_op_c_i(ex_op_c_o),
        .ex_reg_we_i(ex_reg_we_o),

        .mem_reg_waddr_i(mem_reg_waddr_o),
        .mem_op_c_i(mem_op_c_o),
        .mem_reg_we_i(mem_reg_we_o),

        .wb_reg_waddr_i(wb_reg_waddr_o),
        .wb_op_c_i(wb_op_c_o),
        .wb_reg_we_i(wb_reg_we_o),

        .dhnf_harzard_sel1_o(dhnf_harzard_sel1_o),
        .dhnf_harzard_sel2_o(dhnf_harzard_sel2_o),
        .dhnf_forward_data1_o(dhnf_forward_data1_o),
        .dhnf_forward_data2_o(dhnf_forward_data2_o)
    );

    Flow_Ctrl fc_ins(
        .clk(clk),
        .rst_n(rst_n),
        .ex_branch_flag_i(ex_branch_flag_o),
        .ex_jump_pc_i(ex_jump_pc_o),
        .id_jump_pc_i(id_jump_pc_o),
        .id_jump_flag_i(id_jump_flag_o),
        .Icache_ready_i(Icache_ready_o),
        .Icache_hit_i(Icache_hit_o),
        .fc_jump_stop_Icache_o(fc_jump_stop_Icache_o),
        .if_valid_req_i(if_valid_req_o),
        .if_jump_stop_Icache_i(if_jump_stop_Icache_o),
        .fc_flush_btype_flag_o(fc_flush_btype_flag_o),
        .fc_flush_jtype_flag_o(fc_flush_jtype_flag_o),
        .fc_Icache_stall_flag_o(fc_Icache_stall_flag_o),
        .fc_jump_flag_o(fc_jump_flag_o),
        .fc_jump_pc_o(fc_jump_pc_o),
        .fc_Icache_data_valid_o(fc_Icache_data_valid_o),
        .rom_ready_i(rom_ready_i),
        .ram_ready_i(ram_ready_i),
        .mem_valid_req_i(mem_valid_req_o),
        .Dcache_ready_i(Dcache_ready_o),
        .Dcache_hit_i(Dcache_hit_o),
        .fc_Dcache_stall_flag_o(fc_Dcache_stall_flag_o),
        .fc_Dcache_data_valid_o(fc_Dcache_data_valid_o)
    );

    ICache Icache_ins(
        .clk(clk),
        .rst_n(rst_n),
        .if_pc_i(if_pc_o),
        .if_valid_req_i(if_valid_req_o),
        .Icache_ready_o(Icache_ready_o),
        .Icache_inst_o(Icache_inst_o),
        .Icache_hit_o(Icache_hit_o),
        .fc_jump_stop_Icache_i(fc_jump_stop_Icache_o),
        .Icache_addr_o(Icache_addr_o),
        .Icache_valid_req_o(Icache_valid_req_o),
        .mem_ready_i(rom_ready_i),
        .mem_data_i(rom_data_i)
    );

    Dcache Dcache_ins(
        .clk(clk),
        .rst_n(rst_n),
        .mem_rw_i(mem_rw_o),
        .mem_valid_req_i(mem_valid_req_o),
        .mem_addr_i(mem_addr_o),
        .mem_wrwidth_i(mem_wrwidth_o),
        .mem_wr_data_i(mem_wr_data_o),
        .Dcache_data_o(Dcache_data_o),
        .Dcache_ready_o(Dcache_ready_o),
        .Dcache_hit_o(Dcache_hit_o),
        .Dcache_rd_req_o(Dcache_rd_req_o),
        .Dcache_rd_addr_o(Dcache_rd_addr_o),
        .Dcache_wb_req_o(Dcache_wb_req_o),
        .Dcache_wb_addr_o(Dcache_wb_addr_o),
        .Dcache_data_ram_o(Dcache_data_ram_o),
        .ram_data_i(ram_data_i),
        .ram_ready_i(ram_ready_i)
    );

endmodule