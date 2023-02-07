`include "define.v"

module id_ex_reg (
    input   wire                    clk,
    input   wire                    rst_n,
    //from id
    input   wire            [31:0]  id_op_a_i,
    input   wire            [31:0]  id_op_b_i,
    input   wire            [4:0]   id_reg_waddr_i,
    input   wire                    id_reg_we_i,

    input   wire            [4:0]   id_ALUctrl_i,
    input   wire                    id_btype_flag_i,
    input   wire            [31:0]  id_btype_jump_pc_i,

    input   wire                    id_mtype_i,  
    input   wire                    id_mem_rw_i, 
    input   wire            [1:0]   id_mem_width_i,
    input   wire            [31:0]  id_mem_wr_data_i,
    input   wire                    id_mem_rdtype_i,
    //to ex                 
    output  reg             [31:0]  idex_op_a_o,
    output  reg             [31:0]  idex_op_b_o,
    output  reg             [4:0]   idex_reg_waddr_o,
    output  reg                     idex_reg_we_o,

    output  reg             [4:0]   idex_ALUctrl_o,
    output  reg                     idex_btype_flag_o,
    output  reg             [31:0]  idex_btype_jump_pc_o,

    output  reg                     idex_mtype_o,          
    output  reg                     idex_mem_rw_o,          
    output  reg             [1:0]   idex_mem_width_o,      
    output  reg             [31:0]  idex_mem_wr_data_o,   
    output  reg                     idex_mem_rdtype_o,    
    //from fc
    input   wire                    fc_flush_idex_i,
    input   wire                    fc_bk_idex_i
);


    reg [31:0] Op_A_Buffer;
    reg [31:0] Op_B_Buffer;
    reg [4:0]  Reg_Waddr_Buffer;
    reg        Reg_We_Buffer;
    reg [4:0]  ALUctrl_Buffer;
    reg        Btype_Flag_Buffer;
    reg [31:0] Btype_Jump_PC_Buffer;
    reg        Mtype_Buffer;
    reg        Mem_Rw_Buffer;
    reg [1:0]  Mem_Width_Buffer;
    reg [31:0] Mem_Wr_Data_Buffer;
    reg        Mem_Rdtype_Buffer;





    always@(posedge clk or negedge rst_n)begin

        if(rst_n == 1'b0)begin
            idex_op_a_o <= 32'h0;
            idex_op_b_o <= 32'h0;
            idex_reg_waddr_o <= 5'h0;
            idex_reg_we_o <= 1'b0;

            idex_ALUctrl_o <= 5'b0;
            idex_btype_flag_o <= 1'b0;
            idex_btype_jump_pc_o <= 32'h0;

            idex_mtype_o <= 1'b0;
            idex_mem_rw_o <= 1'b0;
            idex_mem_width_o <= 2'b0;
            idex_mem_wr_data_o <= 32'h0;
            idex_mem_rdtype_o <= 1'b0;


            Op_A_Buffer <= 32'h0;
            Op_B_Buffer <= 32'h0;
            Reg_Waddr_Buffer <= 5'h0;
            Reg_We_Buffer <= 1'b0;
            ALUctrl_Buffer <= 5'b0;
            Btype_Flag_Buffer <= 1'b0;
            Btype_Jump_PC_Buffer <= 32'h0;
            Mtype_Buffer <= 1'b0;
            Mem_Rw_Buffer <= 1'b0;
            Mem_Width_Buffer <= 2'b0;
            Mem_Wr_Data_Buffer <= 32'h0;
            Mem_Rdtype_Buffer <= 1'b0;
        end
        else if(fc_bk_idex_i == 1'b1)begin
            idex_op_a_o <= Op_A_Buffer;
            idex_op_b_o <= Op_B_Buffer;
            idex_reg_waddr_o <= Reg_Waddr_Buffer;
            idex_reg_we_o <= Reg_We_Buffer;

            idex_ALUctrl_o <= ALUctrl_Buffer;
            idex_btype_flag_o <= Btype_Flag_Buffer;
            idex_btype_jump_pc_o <= Btype_Jump_PC_Buffer;

            idex_mtype_o <= Mtype_Buffer;
            idex_mem_rw_o <= Mem_Rw_Buffer;
            idex_mem_width_o <= Mem_Width_Buffer;
            idex_mem_wr_data_o <= Mem_Wr_Data_Buffer;
            idex_mem_rdtype_o <= Mem_Rdtype_Buffer;


            Op_A_Buffer <= Op_A_Buffer;
            Op_B_Buffer <= Op_B_Buffer;
            Reg_Waddr_Buffer <= Reg_Waddr_Buffer;
            Reg_We_Buffer <= Reg_We_Buffer;
            ALUctrl_Buffer <= ALUctrl_Buffer;
            Btype_Flag_Buffer <= Btype_Flag_Buffer;
            Btype_Jump_PC_Buffer <= Btype_Jump_PC_Buffer;
            Mtype_Buffer <= Mtype_Buffer;
            Mem_Rw_Buffer <= Mem_Rw_Buffer;
            Mem_Width_Buffer <= Mem_Width_Buffer;
            Mem_Wr_Data_Buffer <= Mem_Wr_Data_Buffer;
            Mem_Rdtype_Buffer <= Mem_Rdtype_Buffer;
        end
        else if(fc_flush_idex_i == 1'b1)begin
            idex_op_a_o <= 32'h0;
            idex_op_b_o <= 32'h0;
            idex_reg_waddr_o <= 5'h0;
            idex_reg_we_o <= 1'b0;

            idex_ALUctrl_o <= 5'b0;
            idex_btype_flag_o <= 1'b0;
            idex_btype_jump_pc_o <= 32'h0;

            idex_mtype_o <= 1'b0;
            idex_mem_rw_o <= 1'b0;
            idex_mem_width_o <= 2'b0;
            idex_mem_wr_data_o <= 32'h0;
            idex_mem_rdtype_o <= 1'b0;


            Op_A_Buffer <= 32'h0;
            Op_B_Buffer <= 32'h0;
            Reg_Waddr_Buffer <= 5'h0;
            Reg_We_Buffer <= 1'b0;
            ALUctrl_Buffer <= 5'b0;
            Btype_Flag_Buffer <= 1'b0;
            Btype_Jump_PC_Buffer <= 32'h0;
            Mtype_Buffer <= 1'b0;
            Mem_Rw_Buffer <= 1'b0;
            Mem_Width_Buffer <= 2'b0;
            Mem_Wr_Data_Buffer <= 32'h0;
            Mem_Rdtype_Buffer <= 1'b0;
        end
        else begin
            idex_op_a_o <= id_op_a_i;
            idex_op_b_o <= id_op_b_i;
            idex_reg_waddr_o <= id_reg_waddr_i;
            idex_reg_we_o <= id_reg_we_i;

            idex_ALUctrl_o <= id_ALUctrl_i;
            idex_btype_flag_o <= id_btype_flag_i;
            idex_btype_jump_pc_o <= id_btype_jump_pc_i;

            idex_mtype_o <= id_mtype_i;
            idex_mem_rw_o <= id_mem_rw_i;
            idex_mem_width_o <= id_mem_width_i;
            idex_mem_wr_data_o <= id_mem_wr_data_i;
            idex_mem_rdtype_o <= id_mem_rdtype_i;


            Op_A_Buffer <= idex_op_a_o;
            Op_B_Buffer <= idex_op_b_o;
            Reg_Waddr_Buffer <= idex_reg_waddr_o;
            Reg_We_Buffer <= idex_reg_we_o;
            ALUctrl_Buffer <= idex_ALUctrl_o;
            Btype_Flag_Buffer <= idex_btype_flag_o;
            Btype_Jump_PC_Buffer <= idex_btype_jump_pc_o;
            Mtype_Buffer <= idex_mtype_o;
            Mem_Rw_Buffer <= idex_mem_rw_o;
            Mem_Width_Buffer <= idex_mem_width_o;
            Mem_Wr_Data_Buffer <= idex_mem_wr_data_o;
            Mem_Rdtype_Buffer <= idex_mem_rdtype_o;
        end

    end



endmodule