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
        end
        else if(fc_bk_idex_i == 1'b1)begin
            idex_op_a_o <= idex_op_a_o;
            idex_op_b_o <= idex_op_b_o;
            idex_reg_waddr_o <= idex_reg_waddr_o;
            idex_reg_we_o <= idex_reg_we_o;

            idex_ALUctrl_o <= idex_ALUctrl_o;
            idex_btype_flag_o <= idex_btype_flag_o;
            idex_btype_jump_pc_o <= idex_btype_jump_pc_o;

            idex_mtype_o <= idex_mtype_o;
            idex_mem_rw_o <= idex_mem_rw_o;
            idex_mem_width_o <= idex_mem_width_o;
            idex_mem_wr_data_o <= idex_mem_wr_data_o;
            idex_mem_rdtype_o <= idex_mem_rdtype_o;
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
        end

    end



endmodule