`include "define.v"

module id_ex_reg (
    input   wire                    clk,
    input   wire                    rst_n,
    //from cu
    input   wire            [4:0]   cu_ALUctrl_i,
    //from id
    input   wire            [31:0]  id_op_a_i,
    input   wire            [31:0]  id_op_b_i,
    input   wire            [4:0]   id_reg_waddr_i,
    input   wire                    id_reg_we_i,
    input   wire                    id_btype_flag_i,
    input   wire            [31:0]  id_btype_jump_pc_i,

    input   wire                    id_mtype_i,  
    input   wire                    id_mem_rw_i, 
    input   wire            [1:0]   id_mem_width_i,
    input   wire            [31:0]  id_mem_wr_data_i,
    input   wire                    id_mem_rdtype_i,
    //to ex                 
    output  reg             [31:0]  id_ex_reg_op_a_o,
    output  reg             [31:0]  id_ex_reg_op_b_o,
    output  reg             [4:0]   id_ex_reg_ALUctrl_o,
    output  reg             [4:0]   id_ex_reg_reg_waddr_o,
    output  reg                     id_ex_reg_reg_we_o,

    output  reg                     id_ex_reg_btype_flag_o,
    output  reg             [31:0]  id_ex_reg_btype_jump_pc_o,

    output  reg                     id_ex_mtype_o,       
    output  reg                     id_ex_mem_rw_o,        
    output  reg             [1:0]   id_ex_mem_width_o,     
    output  reg             [31:0]  id_ex_mem_wr_data_o,  
    output  reg                     id_ex_mem_rdtype_o,  



    //from fc
    input   wire                    fc_flush_btype_flag_i,
    input   wire                    fc_flush_jtype_flag_i,

    input   wire                    fc_Dcache_stall_flag_i

);

    always @(posedge clk or negedge rst_n)begin
        if(rst_n == 1'b0)begin
            id_ex_mtype_o       <= 1'b0;    
            id_ex_mem_rw_o      <= 1'b0;
            id_ex_mem_width_o   <= 2'd0;
            id_ex_mem_wr_data_o <= 32'h0;
            id_ex_mem_rdtype_o  <= 1'b0;
        end
        else if(fc_flush_btype_flag_i == 1'b1) begin
            id_ex_mtype_o       <= 1'b0;    
            id_ex_mem_rw_o      <= 1'b0;
            id_ex_mem_width_o   <= 2'd0;
            id_ex_mem_wr_data_o <= 32'h0;
            id_ex_mem_rdtype_o  <= 1'b0;
        end
        else if(fc_Dcache_stall_flag_i == 1'b1)begin
            id_ex_mtype_o       <= id_ex_mtype_o;          
            id_ex_mem_rw_o      <= id_ex_mem_rw_o;     
            id_ex_mem_width_o   <= id_ex_mem_width_o;  
            id_ex_mem_wr_data_o <= id_ex_mem_wr_data_o;
            id_ex_mem_rdtype_o  <= id_ex_mem_rdtype_o; 
        end
        else begin
            id_ex_mtype_o       <= id_mtype_i;    
            id_ex_mem_rw_o      <= id_mem_rw_i;
            id_ex_mem_width_o   <= id_mem_width_i;
            id_ex_mem_wr_data_o <= id_mem_wr_data_i;
            id_ex_mem_rdtype_o  <= id_mem_rdtype_i;
        end
    end





    always @(posedge clk or negedge rst_n)begin
        if(rst_n == 1'b0)begin
            id_ex_reg_btype_flag_o <= 1'b0;
        end
        else if(fc_flush_btype_flag_i == 1'b1) begin
            id_ex_reg_btype_flag_o <= 1'b0;
        end
        else if(fc_Dcache_stall_flag_i == 1'b1)begin
            id_ex_reg_btype_flag_o <= id_ex_reg_btype_flag_o;
        end
        else begin
            id_ex_reg_btype_flag_o <= id_btype_flag_i;
        end
    end

    always @(posedge clk or negedge rst_n)begin
        if(rst_n == 1'b0)begin
            id_ex_reg_btype_jump_pc_o <= 32'h0;
        end
        else if(fc_flush_btype_flag_i == 1'b1) begin
            id_ex_reg_btype_jump_pc_o <= 32'h0;
        end
        else if(fc_Dcache_stall_flag_i == 1'b1)begin
            id_ex_reg_btype_jump_pc_o <= id_ex_reg_btype_jump_pc_o;
        end
        else begin
            id_ex_reg_btype_jump_pc_o <= id_btype_jump_pc_i;
        end
    end




    always @(posedge clk or negedge rst_n)begin
        if(rst_n == 1'b0)begin
            id_ex_reg_op_a_o <= 32'h0;
            id_ex_reg_op_b_o <= 32'h0;
        end
        else if(fc_flush_btype_flag_i == 1'b1) begin
            id_ex_reg_op_a_o <= 32'h0;
            id_ex_reg_op_b_o <= 32'h0;
        end
        else if(fc_Dcache_stall_flag_i == 1'b1)begin
            id_ex_reg_op_a_o <= id_ex_reg_op_a_o;
            id_ex_reg_op_b_o <= id_ex_reg_op_b_o;
        end
        else begin
            id_ex_reg_op_a_o <= id_op_a_i;
            id_ex_reg_op_b_o <= id_op_b_i;
        end
    end


    always @(posedge clk or negedge rst_n)begin
        if(rst_n == 1'b0)begin
            id_ex_reg_ALUctrl_o <= `NO_OP;
        end
        else if(fc_flush_btype_flag_i == 1'b1) begin
            id_ex_reg_ALUctrl_o <= `NO_OP;
        end
        else if(fc_Dcache_stall_flag_i == 1'b1)begin
            id_ex_reg_ALUctrl_o <= id_ex_reg_ALUctrl_o;
        end
        else begin
            id_ex_reg_ALUctrl_o <= cu_ALUctrl_i;
        end
    end


    always @(posedge clk or negedge rst_n)begin
        if(rst_n == 1'b0)begin
            id_ex_reg_reg_waddr_o <= 5'h0;
        end
        else if(fc_flush_btype_flag_i == 1'b1) begin
            id_ex_reg_reg_waddr_o <= 5'h0;
        end
        else if(fc_Dcache_stall_flag_i == 1'b1)begin
            id_ex_reg_reg_waddr_o <= id_ex_reg_reg_waddr_o;
        end
        else begin
            id_ex_reg_reg_waddr_o <= id_reg_waddr_i;
        end
    end

    always @(posedge clk or negedge rst_n)begin
        if(rst_n == 1'b0)begin
            id_ex_reg_reg_we_o <= 1'b0;
        end
        else if(fc_flush_btype_flag_i == 1'b1) begin
            id_ex_reg_reg_we_o <= 1'b0;
        end
        else if(fc_Dcache_stall_flag_i == 1'b1)begin
            id_ex_reg_reg_we_o <= id_ex_reg_reg_we_o;
        end
        else begin
            id_ex_reg_reg_we_o <= id_reg_we_i;
        end
    end


endmodule