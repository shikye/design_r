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

    output  wire                    id_btype_o,
    output  wire            [31:0]  id_next_pc_o,
    //from dhnf
    input   wire                    dhnf_harzard_sel1_i,
    input   wire                    dhnf_harzard_sel2_i,
    input   wire            [31:0]  dhnf_forward_data1_i,
    input   wire            [31:0]  dhnf_forward_data2_i,
    //to dhnf
    output  wire                    id_reg1_RE_o,
    output  wire                    id_reg2_RE_o,
    //from rom
    input   wire            [31:0]  rom_inst_i,
    //from ex
    input   wire                    ex_ins_flush_i
);


    wire [31:0] inst = delay_flush ? 32'h0 : rom_inst_i;

    reg delay_flush;

    always @(posedge clk or negedge rst_n) begin
        if(rst_n == 1'b0)
            delay_flush <= 1'b0;
        else if((ex_ins_flush_i == 1'b1) || (j_jump == 1'b1))
            delay_flush <= 1'b1;
        else
            delay_flush <= 1'b0;
    end

    

    wire        j_jump = (opcode == `Jtype_J) ? 1'b1 : 1'b0;


    wire [6:0]  opcode = inst[6:0];
    wire [4:0]  rd     = inst[11:7];
    wire [2:0]  func3  = inst[14:12];
    wire [4:0]  rs1    = inst[19:15];
    wire [4:0]  rs2    = inst[24:20];
    wire [6:0]  func7  = inst[31:25];

    //to eximm
    wire [31:0] id_inst_o = inst;
    //from eximm
    wire [31:0] eximm_eximm_i;

    //from cu
    wire        cu_op_b_sel_o;

    
    assign id_btype_o = (opcode == `Btype) ? 1'b1 : 1'b0;
    assign id_next_pc_o = if_id_reg_pc_i + eximm_eximm_i;  //only btype


    assign id_reg1_raddr_o = rs1;
    assign id_reg2_raddr_o = rs2;
    assign id_reg_waddr_o  = rd;


    assign id_op_a_o = dhnf_harzard_sel1_i ? dhnf_forward_data1_i : regs_reg1_rdata_i;
    assign id_op_b_o = dhnf_harzard_sel2_i ? dhnf_forward_data2_i : 
        cu_op_b_sel_o ? eximm_eximm_i : regs_reg2_rdata_i;

    


    cu cu_ins(
        .clk(clk),
        .rst_n(rst_n),
        .id_opcode_i(opcode),
        .id_func3_i(func3),
        .id_func7_i(func7),
        .cu_ALUctrl_o(id_ALUctrl_o),
        .cu_reg_we_o(id_reg_we_o),
        .cu_op_b_sel_o(cu_op_b_sel_o),
        .cu_reg1_RE_o(id_reg1_RE_o),
        .cu_reg2_RE_o(id_reg2_RE_o)
    );

    eximm eximm_ins(
        .id_inst_i(id_inst_o),
        .eximm_eximm_o(eximm_eximm_i)
    );


endmodule