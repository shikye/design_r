`include "define.v"
module ID (
    input   wire                    clk,
    input   wire                    rst_n,
    //from if_id_reg
    input   wire            [31:0]  ifid_pc_i,
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
    output  wire                    id_reg_we_o,

    output  wire            [4:0]   id_ALUctrl_o,
    output  wire                    id_btype_flag_o,
    output  wire            [31:0]  id_btype_jump_pc_o,

//----------for load/store inst-------
    output  wire                    id_mtype_o,  //load/store type
    output  wire                    id_mem_rw_o,  //0--wr, 1--rd
    output  wire            [1:0]   id_mem_width_o, //1--byte, 2--hw, 3--word
    output  wire            [31:0]  id_mem_wr_data_o,
    output  wire                    id_mem_rdtype_o,   //signed --0, unsigned --1
 //-----------------------------------

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
    input   wire                    fc_Icache_data_valid_i,

    input   wire                    fc_flush_id_i,
    input   wire                    fc_bk_id_i,
    //to fc
    output  wire                    id_jump_flag_o,
    output  wire            [31:0]  id_jump_pc_o
);


//-----------------------------------------seen as part of if_id_reg

//------for flush btype or jump_inst
    reg delay_flag;
    
    always @(posedge clk or negedge rst_n) begin
        if(rst_n == 1'b0)
            delay_flag <= 1'b0;
        else if(fc_flush_id_i)
            delay_flag <= 1'b1;
        else
            delay_flag <= 1'b0;
    end
//----------------------------------------------




//-----for back_and_keep------
    reg [31:0]  Inst_Buffer;
    reg         Icache_in_Buffer;


    always @(posedge clk or negedge rst_n) begin
        if(rst_n == 1'b0)begin
            Inst_Buffer <= 32'h0;
            Icache_in_Buffer <= 1'b0;
        end

        //Dcache stall and Icache need give out data
        else if(fc_bk_id_i == 1'b1 && fc_Icache_data_valid_i == 1'b1)begin
            Inst_Buffer <= Icache_inst_i;
            Icache_in_Buffer <= 1'b1;
        end
        else if(fc_bk_id_i == 1'b1) begin
            Inst_Buffer <= Inst_Buffer;   //keep
        end
        else if(fc_flush_id_i == 1'b1)begin
            Inst_Buffer <= 32'h0;
        end
        else begin
            Inst_Buffer <= Icache_inst_i;
            
            if(Icache_in_Buffer == 1'b1)
                Icache_in_Buffer <= 1'b0;

        end
    end

//-----------------------------------------

    reg [31:0] inst;

    always@(*)begin
        case( {fc_bk_id_i, Icache_in_Buffer} )
            2'b00:begin
                if(delay_flag == 1'b1)
                    inst = 32'h0;
                else begin
                    if(fc_Icache_data_valid_i == 1'b1)
                        inst = Icache_inst_i;
                    else 
                        inst = 32'h0;
                end
            end


            2'b01:begin   //Dcache complete

                if(delay_flag == 1'b1)
                    inst = 32'h0;
                else
                    inst = Inst_Buffer;
                    
            end
            
            2'b10:begin

                if(delay_flag == 1'b1)
                    inst = 32'h0;
                else
                    inst = Inst_Buffer;
                
            end

            2'b11:begin

                if(delay_flag == 1'b1)
                    inst = 32'h0;
                else
                    inst = Inst_Buffer;

            end

            default:;
        
        endcase
        
    end





//  wire [31:0] inst = fc_bk_id_i ? Inst_Buffer : delay_flag ? 32'h0 : Icache_inst;
//                                    back           flush
    

//----------------------------------------------



//-----------decode


    wire [6:0]  opcode = inst[6:0];
    wire [4:0]  rd     = inst[11:7];
    wire [2:0]  func3  = inst[14:12];
    wire [4:0]  rs1    = inst[19:15];
    wire [4:0]  rs2    = inst[24:20];
    wire [6:0]  func7  = inst[31:25];
    wire [5:0]  shamt  = inst[25:20];
//--------------------------------------



//---------------control unit

    wire [4:0] cu_ALUctrl_o;
    wire       cu_reg_we_o;
    wire       cu_op_b_sel_o;

    wire       cu_reg1_RE_o;
    wire       cu_reg2_RE_o;

    wire       cu_mtype_o;
    wire       cu_mem_rw_o;
    wire [1:0] cu_mem_width_o;
    wire       cu_mem_rdtype_o;


    cu cu_ins(
        .clk(clk),
        .rst_n(rst_n),
        .id_opcode_i(opcode),
        .id_func3_i(func3),
        .id_func7_i(func7),

        .cu_ALUctrl_o(cu_ALUctrl_o),
        .cu_reg_we_o(cu_reg_we_o),
        .cu_op_b_sel_o(cu_op_b_sel_o),

        .cu_mtype_o(cu_mtype_o),
        .cu_mem_rw_o(cu_mem_rw_o),
        .cu_mem_width_o(cu_mem_width_o),
        .cu_mem_rdtype_o(cu_mem_rdtype_o),

        .cu_reg1_RE_o(cu_reg1_RE_o),
        .cu_reg2_RE_o(cu_reg2_RE_o)
    );

    assign id_ALUctrl_o = cu_ALUctrl_o;
    assign id_reg_we_o = cu_reg_we_o;
    assign id_mtype_o = cu_mtype_o;
    assign id_mem_rw_o = cu_mem_rw_o;
    assign id_mem_width_o = cu_mem_width_o;
    assign id_mem_rdtype_o = cu_mem_rdtype_o;
    assign id_reg1_RE_o = cu_reg1_RE_o;
    assign id_reg2_RE_o = cu_reg2_RE_o;

//-----------------------------


//----------eximm
wire [31:0] id_inst_o = inst;
wire [31:0] eximm_eximm_o;


eximm eximm_ins(
    .id_inst_i(id_inst_o),
    .eximm_eximm_o(eximm_eximm_o)
);
//-----------------------------------------
    


//----------------------from regs
    wire [31:0] rd1_after_hazard = dhnf_harzard_sel1_i ? dhnf_forward_data1_i : regs_reg1_rdata_i;
    wire [31:0] rd2_after_hazard = dhnf_harzard_sel2_i ? dhnf_forward_data2_i : regs_reg2_rdata_i;

//-------------------------------------


//------------btype_flag
    assign id_btype_flag_o = (opcode == `Btype) ? 1'b1 : 1'b0;
    assign id_btype_jump_pc_o = ifid_pc_i + eximm_eximm_o;  //only btype
//---------------------------



//---------other output signals
    assign id_reg1_raddr_o = rs1;
    assign id_reg2_raddr_o = rs2;
    assign id_reg_waddr_o  = rd;


    assign id_op_a_o = (opcode == `Utype_L) ? 32'h0 : 
                        (opcode == `Utype_A) ? ifid_pc_i :
                        (opcode == `Jtype_J || opcode == `Itype_J) ? ifid_pc_i :
                        rd1_after_hazard;         //most from regs

    assign id_op_b_o = (opcode == `Jtype_J || opcode == `Itype_J) ? 32'd4 :
                        (opcode == `Itype_A && (func3 == `I_SLLI || func3 == `I_SRLI_SRAI) ) ? shamt :
                        cu_op_b_sel_o ? eximm_eximm_o :
                        rd2_after_hazard;           //most from regs or eximm

    
    assign id_mem_wr_data_o = rd2_after_hazard; //Stype

  
    assign id_jump_flag_o = (opcode == `Jtype_J || opcode == `Itype_J) ? 1'b1 : 1'b0;   //jal and jalr
    assign id_jump_pc_o   = (opcode == `Jtype_J ) ? (ifid_pc_i + eximm_eximm_o) : (rd1_after_hazard + eximm_eximm_o);


endmodule