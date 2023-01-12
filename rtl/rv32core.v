`include "define.v"
module rv32core(
    input   wire                    clk,
    input   wire                    rst_n,

    //to rom
    output  wire            [31:0]  rv32core_pc_o,
    //from rom
    input   wire            [31:0]  rom_inst_i

);

    //source
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
    wire            id_reg1_RE_o;
    wire            id_reg2_RE_o;
    //id_ex_reg
    wire    [31:0]  id_ex_reg_op_a_o;
    wire    [31:0]  id_ex_reg_op_b_o;
    wire    [4:0]   id_ex_reg_ALUctrl_o;
    wire    [4:0]   id_ex_reg_reg_waddr_o;
    wire            id_ex_reg_reg_we_o;
    //ex
    wire    [31:0]  ex_op_c_o;
    wire    [4:0]   ex_reg_waddr_o;
    wire            ex_reg_we_o;
    //ex_mem_reg
    wire    [31:0]  ex_mem_reg_op_c_o;
    wire    [4:0]   ex_mem_reg_reg_waddr_o;
    wire            ex_mem_reg_reg_we_o;
    //mem
    wire    [31:0]  mem_op_c_o;
    wire    [4:0]   mem_reg_waddr_o;
    wire            mem_reg_we_o;
    //mem_wb_reg
    wire    [31:0]  mem_wb_reg_op_c_o;
    wire    [4:0]   mem_wb_reg_reg_waddr_o;
    wire            mem_wb_reg_reg_we_o;
    //wb
    wire    [31:0]  wb_op_c_o;
    wire    [4:0]   wb_reg_waddr_o;
    wire            wb_reg_we_o;
    //dhnf
    wire            dhnf_harzard_sel1_o;
    wire            dhnf_harzard_sel2_o;
    wire    [31:0]  dhnf_forward_data1_o;
    wire    [31:0]  dhnf_forward_data2_o;



    if_stage if_stage_ins(
        .clk(clk),
        .rst_n(rst_n),
        .if_pc_o(rv32core_pc_o)
    );

    if_id_reg if_id_reg_ins(
        .clk(clk),
        .rst_n(rst_n),
        .if_pc_i(rv32core_pc_o),
        .if_id_reg_pc_o(if_id_reg_pc_o)
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
        .dhnf_harzard_sel1_i(dhnf_harzard_sel1_o),
        .dhnf_harzard_sel2_i(dhnf_harzard_sel2_o),
        .dhnf_forward_data1_i(dhnf_forward_data1_o),
        .dhnf_forward_data2_i(dhnf_forward_data2_o),
        .id_reg1_RE_o(id_reg1_RE_o),
        .id_reg2_RE_o(id_reg2_RE_o),
        .rom_inst_i(rom_inst_i)
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
        .id_ex_reg_op_a_o(id_ex_reg_op_a_o),
        .id_ex_reg_op_b_o(id_ex_reg_op_b_o),
        .id_ex_reg_ALUctrl_o(id_ex_reg_ALUctrl_o),
        .id_ex_reg_reg_waddr_o(id_ex_reg_reg_waddr_o),
        .id_ex_reg_reg_we_o(id_ex_reg_reg_we_o)
    );

    ex_stage ex_stage_ins(
        .clk(clk),
        .rst_n(rst_n),
        .id_ex_reg_op_a_i(id_ex_reg_op_a_o),
        .id_ex_reg_op_b_i(id_ex_reg_op_b_o),
        .id_ex_reg_ALUctrl_i(id_ex_reg_ALUctrl_o),
        .id_ex_reg_reg_waddr_i(id_ex_reg_reg_waddr_o),
        .id_ex_reg_reg_we_i(id_ex_reg_reg_we_o),
        .ex_op_c_o(ex_op_c_o),
        .ex_reg_waddr_o(ex_reg_waddr_o),
        .ex_reg_we_o(ex_reg_we_o)
    );

    ex_mem_reg ex_mem_reg_ins(
        .clk(clk),
        .rst_n(rst_n),
        .ex_op_c_i(ex_op_c_o),
        .ex_reg_waddr_i(ex_reg_waddr_o),
        .ex_reg_we_i(ex_reg_we_o),
        .ex_mem_reg_op_c_o(ex_mem_reg_op_c_o),
        .ex_mem_reg_reg_waddr_o(ex_mem_reg_reg_waddr_o),
        .ex_mem_reg_reg_we_o(ex_mem_reg_reg_we_o)
    );

    mem_stage mem_stage_ins(
        .clk(clk),
        .rst_n(rst_n),
        .ex_mem_reg_op_c_i(ex_mem_reg_op_c_o),
        .ex_mem_reg_reg_waddr_i(ex_mem_reg_reg_waddr_o),
        .ex_mem_reg_reg_we_i(ex_mem_reg_reg_we_o),
        .mem_op_c_o(mem_op_c_o),
        .mem_reg_waddr_o(mem_reg_waddr_o),
        .mem_reg_we_o(mem_reg_we_o)
    );

    mem_wb_reg mem_wb_reg_ins(
        .clk(clk),
        .rst_n(rst_n),
        .mem_op_c_i(mem_op_c_o),
        .mem_reg_waddr_i(mem_reg_waddr_o),
        .mem_reg_we_i(mem_reg_we_o),
        .mem_wb_reg_op_c_o(mem_wb_reg_op_c_o),
        .mem_wb_reg_reg_waddr_o(mem_wb_reg_reg_waddr_o),
        .mem_wb_reg_reg_we_o(mem_wb_reg_reg_we_o)
    );

    wb_stage wb_stage_ins(
        .clk(clk),
        .rst_n(rst_n),
        .mem_wb_reg_op_c_i(mem_wb_reg_op_c_o),
        .mem_wb_reg_reg_waddr_i(mem_wb_reg_reg_waddr_o),
        .mem_wb_reg_reg_we_i(mem_wb_reg_reg_we_o),
        .wb_op_c_o(wb_op_c_o),
        .wb_reg_waddr_o(wb_reg_waddr_o),
        .wb_reg_we_o(wb_reg_we_o)
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

endmodule