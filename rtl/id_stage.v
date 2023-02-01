`include "define.v"

module id_stage (
    input   wire                    clk,
    input   wire                    rst_n,
    //from if_id_reg
    input   wire            [31:0]  if_id_reg_pc_i,
    //from regs
    input   wire            [31:0]  regs_reg1_rdata_i,
    input   wire            [31:0]  regs_reg2_rdata_i,
    //to regs and dhnf
    output  wire            [4:0]   id_reg1_raddr_o,
    output  wire            [4:0]   id_reg2_raddr_o,
    //to id_ex_reg
    output  wire            [31:0]  id_op_a_o,
    output  wire            [31:0]  id_op_b_o,
    output  wire            [4:0]   id_reg_waddr_o,

    output  wire            [4:0]   id_ALUctrl_o,
    output  wire                    id_reg_we_o,

    output  wire                    id_btype_flag_o,
    output  wire            [31:0]  id_btype_jump_pc_o,


    output  wire                    id_mtype_o,  //load/store type
    output  wire                    id_mem_rw_o,  //0--wr, 1--rd
    output  wire            [1:0]   id_mem_width_o, //0--byte, 1--hw, 2--word
    output  wire            [31:0]  id_mem_wr_data_o,
    output  wire                    id_mem_rdtype_o,   //signed --0, unsigned --1

    //from dhnf
    input   wire                    dhnf_harzard_sel1_i,
    input   wire                    dhnf_harzard_sel2_i,
    input   wire            [31:0]  dhnf_forward_data1_i,
    input   wire            [31:0]  dhnf_forward_data2_i,
    //to dhnf
    output  wire                    id_reg1_RE_o,
    output  wire                    id_reg2_RE_o,
    //from Icache
    input   wire            [31:0]  Icache_inst_i,
    //from fc
    input   wire                    fc_jump_flag_i,
    input   wire                    fc_Icache_data_valid_i,
    //to fc
    output  wire                    id_jump_flag_o,
    output  wire            [31:0]  id_jump_pc_o
);


    wire [31:0] Icache_inst_buffer_from_Icache = fc_Icache_data_valid_i ? Icache_inst_i : 32'h0;

    wire [31:0] inst = delay_flag ? 32'h0 : Icache_inst_buffer_from_Icache;

    reg delay_flag;

    always @(posedge clk or negedge rst_n) begin
        if(rst_n == 1'b0)
            delay_flag <= 1'b0;
        else if(fc_jump_flag_i)
            delay_flag <= 1'b1;
        else
            delay_flag <= 1'b0;
    end



    wire [6:0]  opcode = inst[6:0];
    wire [4:0]  rd     = inst[11:7];
    wire [2:0]  func3  = inst[14:12];
    wire [4:0]  rs1    = inst[19:15];
    wire [4:0]  rs2    = inst[24:20];
    wire [6:0]  func7  = inst[31:25];
    wire [5:0]  shamt  = inst[25:20];

    //to eximm
    wire [31:0] id_inst_o = inst;
    //from eximm
    wire [31:0] eximm_eximm_i;

    //from cu
    wire        cu_op_b_sel_o;

    //from regs
    wire [31:0] rd1_after_hazard = dhnf_harzard_sel1_i ? dhnf_forward_data1_i : regs_reg1_rdata_i;
    wire [31:0] rd2_after_hazard = dhnf_harzard_sel2_i ? dhnf_forward_data2_i : regs_reg2_rdata_i;

    
    assign id_btype_flag_o = (opcode == `Btype) ? 1'b1 : 1'b0;
    assign id_btype_jump_pc_o = if_id_reg_pc_i + eximm_eximm_i;  //only btype


    assign id_reg1_raddr_o = rs1;
    assign id_reg2_raddr_o = rs2;
    assign id_reg_waddr_o  = rd;


    //need to be modify

    // assign id_op_a_o = dhnf_harzard_sel1_i ? dhnf_forward_data1_i : 
    //     (opcode == `Utype_L) ? 32'h0 : (opcode == `Utype_A) ? if_id_reg_pc_i : 
    //         (opcode == `Jtype_J) ? 32'd0 : regs_reg1_rdata_i;        //from reg


    assign id_op_a_o = (opcode == `Utype_L) ? 32'h0 : 
                        (opcode == `Utype_A) ? if_id_reg_pc_i :
                        (opcode == `Jtype_J || opcode == `Itype_J) ? if_id_reg_pc_i :
                        rd1_after_hazard;

    assign id_op_b_o = (opcode == `Jtype_J || opcode == `Itype_J) ? 32'd4 :
                        (opcode == `Itype_A && (func3 == `I_SLLI || func3 == `I_SRLI_SRAI) ) ? shamt :
                        cu_op_b_sel_o ? eximm_eximm_i :
                        rd2_after_hazard; 

    
    assign id_mem_wr_data_o = rd2_after_hazard; //Stype


    // assign id_op_b_o = dhnf_harzard_sel2_i ? dhnf_forward_data2_i :  //from reg or imm
    //     (opcode == `Jtype_J) ? if_id_reg_pc_i + 32'd4 :
    //     cu_op_b_sel_o ? eximm_eximm_i : regs_reg2_rdata_i;

    
    assign id_jump_flag_o = (opcode == `Jtype_J || opcode == `Itype_J) ? 1'b1 : 1'b0;   //jal and jalr
    assign id_jump_pc_o   = (opcode == `Jtype_J ) ? (if_id_reg_pc_i + eximm_eximm_i) : (rd1_after_hazard + eximm_eximm_i);

    


    cu cu_ins(
        .clk(clk),
        .rst_n(rst_n),
        .id_opcode_i(opcode),
        .id_func3_i(func3),
        .id_func7_i(func7),
        .cu_ALUctrl_o(id_ALUctrl_o),
        .cu_reg_we_o(id_reg_we_o),
        .cu_op_b_sel_o(cu_op_b_sel_o),

        .cu_mtype_o(id_mtype_o),
        .cu_mem_rw_o(id_mem_rw_o),
        .cu_mem_width_o(id_mem_width_o),
        .cu_mem_rdtype_o(id_mem_rdtype_o),

        .cu_reg1_RE_o(id_reg1_RE_o),
        .cu_reg2_RE_o(id_reg2_RE_o)
    );

    eximm eximm_ins(
        .id_inst_i(id_inst_o),
        .eximm_eximm_o(eximm_eximm_i)
    );


endmodule