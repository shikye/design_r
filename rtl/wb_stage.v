module wb_stage (
    input   wire                    clk,
    input   wire                    rst_n,
    //from mem_wb_reg
    input   wire            [31:0]  mem_wb_reg_op_c_i,
    input   wire            [4:0]   mem_wb_reg_reg_waddr_i,
    input   wire                    mem_wb_reg_reg_we_i,
    //to regs
    output  reg             [31:0]  wb_op_c_o,
    output  reg             [4:0]   wb_reg_waddr_o,
    output  reg                     wb_reg_we_o
);

    always @(posedge clk or negedge rst_n)begin
        if(rst_n == 1'b0)begin
            wb_op_c_o <= 32'h0;
        end
        else begin
            wb_op_c_o <= mem_wb_reg_op_c_i;
        end
    end

    always @(posedge clk or negedge rst_n)begin
        if(rst_n == 1'b0)begin
            wb_reg_waddr_o <= 32'h0;
        end
        else begin
            wb_reg_waddr_o <= mem_wb_reg_reg_waddr_i;
        end
    end

    always @(posedge clk or negedge rst_n)begin
        if(rst_n == 1'b0)begin
            wb_reg_we_o <= 1'b0;
        end
        else begin
            wb_reg_we_o <= mem_wb_reg_reg_we_i;
        end
    end



endmodule