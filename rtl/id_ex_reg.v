module id_ex_reg (
    input   wire                    clk,
    input   wire                    rst_n,
    //from cu
    input   wire            [4:0]   cu_ALUCtrl_i,
    //from id
    input   wire            [31:0]  id_op_a_i,
    input   wire            [31:0]  id_op_b_i,
    input   wire            [4:0]   id_reg_waddr_i,
    input   wire                    id_reg_we_i,
    //to ex                 
    output  reg             [31:0]  id_ex_reg_op_a_o,
    output  reg             [31:0]  id_ex_reg_op_b_o,
    output  reg             [4:0]   id_ex_reg_ALUctrl_o,
    output  reg             [4:0]   id_ex_reg_reg_waddr_o,
    output  reg                     id_ex_reg_reg_we_o
);

    


    always @(posedge clk or negedge rst_n)begin
        if(rst_n == 1'b0)begin
            id_ex_reg_op_a_o <= 32'h0;
            id_ex_reg_op_b_o <= 32'h0;
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
        else begin
            id_ex_reg_ALUctrl_o <= cu_ALUctrl_i;
        end
    end


    always @(posedge clk or negedge rst_n)begin
        if(rst_n == 1'b0)begin
            id_ex_reg_reg_waddr_o <= 5'h0;
        end
        else begin
            id_ex_reg_reg_waddr_o <= id_reg_waddr_i;
        end
    end

    always @(posedge clk or negedge rst_n)begin
        if(rst_n == 1'b0)begin
            id_ex_reg_reg_we_o <= 1'b0;
        end
        else begin
            id_ex_reg_reg_we_o <= id_reg_we_i;
        end
    end


endmodule