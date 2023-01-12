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
    //from dhnf
    input   wire                    dhnf_harzard_sel1_i,
    input   wire                    dhnf_harzard_sel2_i,
    input   wire            [31:0]  dhnf_forward_data1_i,
    input   wire            [31:0]  dhnf_forward_data2_i,
    //to dhnf
    output  wire                    id_reg1_RE_o,
    output  wire                    id_reg2_RE_o,
    //from rom
    input   wire            [31:0]  rom_inst_i
);

    wire [6:0]  opcode = rom_inst_i[6:0];
    wire [4:0]  rd     = rom_inst_i[11:7];
    wire [2:0]  func3  = rom_inst_i[14:12];
    wire [4:0]  rs1    = rom_inst_i[19:15];
    wire [4:0]  rs2    = rom_inst_i[24:20];
    wire [6:0]  func7  = rom_inst_i[31:25];

    //to eximm
    wire [31:0] id_inst_o = rom_inst_i;
    //from eximm
    wire [31:0] eximm_eximm_i;

    //from cu
    wire        cu_op_b_sel_o;



    //I-type
    wire [11:0] imm_itype = rom_inst_i[31:20];

    //S-type
    wire [11:0] imm_stype = {rom_inst_i[31:25],rom_inst_i[11:7]};

    //U-type
    wire [19:0] imm_utype = rom_inst_i[31:12];



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