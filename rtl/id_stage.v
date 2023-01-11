module id_stage (
    input   wire                    clk,
    input   wire                    rst_n,
    //from if_id_reg
    input   wire            [31:0]  if_id_reg_pc_i,
    input   wire            [31:0]  if_id_reg_inst_i,
    //from regs
    input   wire            [31:0]  regs_reg1_rdata_i,
    input   wire            [31:0]  regs_reg2_rdata_i,
    //to regs
    output  wire            [4:0]   id_reg1_raddr_o,
    output  wire            [4:0]   id_reg2_raddr_o,
    //to id_ex_reg
    output  wire            [31:0]  id_op_a_o,
    output  wire            [31:0]  id_op_b_o,
    output  wire            [4:0]   id_reg_waddr_o,

    output  wire            [4:0]   id_ALUctrl_o,
    output  wire                    id_reg_we_o,
    //to eximm
    output  wire            [31:0]  id_inst_o
);

    wire [6:0]  opcode = if_id_reg_inst_i[6:0];
    wire [4:0]  rd     = if_id_reg_inst_i[11:7];
    wire [2:0]  func3  = if_id_reg_inst_i[14:12];
    wire [4:0]  rs1    = if_id_reg_inst_i[19:15];
    wire [4:0]  rs2    = if_id_reg_inst_i[24:20];
    wire [6:0]  func7  = if_id_reg_inst_i[31:25];

    //I-type
    wire [11:0] imm_itype = if_id_reg_inst_i[31:20];

    //S-type
    wire [11:0] imm_stype = {if_id_reg_inst_i[31:25],if_id_reg_inst_i[11:7]};

    //U-type
    wire [19:0] imm_utype = if_id_reg_inst_i[31:12];



    assign id_reg1_raddr_o = rs1;
    assign id_reg2_raddr_o = rs2;
    assign id_reg_waddr_o  = rd;


    assign id_op_a_o = regs_reg1_rdata_i;
    assign id_op_b_o = regs_reg2_rdata_i;

    assign id_inst_o = if_id_reg_inst_i;


    cu ins_cu(
        .clk(clk),
        .rst_n(rst_n),
        .id_opcode_i(opcode),
        .id_func3_i(func3),
        .id_func7_i(func7),
        .cu_ALUctrl_o(id_ALUctrl_o),
        .cu_reg_we_o(id_reg_we_o)
    );


endmodule