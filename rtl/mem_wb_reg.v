module mem_wb_reg (
    input   wire                    clk,
    input   wire                    rst_n,
    //from mem
    input   wire            [31:0]  mem_op_c_i,
    input   wire            [4:0]   mem_reg_waddr_i,
    input   wire                    mem_reg_we_i,
    //to wb
    output  reg             [31:0]  mem_wb_reg_op_c_o,
    output  reg             [4:0]   mem_wb_reg_reg_waddr_o,
    output  reg                     mem_wb_reg_reg_we_o
);

    always @(posedge clk or negedge rst_n)begin
        if(rst_n == 1'b0)begin
            mem_wb_reg_op_c_o <= 32'h0;
        end
        else begin
            mem_wb_reg_op_c_o <= mem_op_c_i;
        end
    end

    always @(posedge clk or negedge rst_n)begin
        if(rst_n == 1'b0)begin
            mem_wb_reg_reg_waddr_o <= 5'h0;
        end
        else begin
            mem_wb_reg_reg_waddr_o <= mem_reg_waddr_i;
        end
    end

    always @(posedge clk or negedge rst_n)begin
        if(rst_n == 1'b0)begin
            mem_wb_reg_reg_we_o <= 1'b0;
        end
        else begin
            mem_wb_reg_reg_we_o <= mem_reg_we_i;
        end
    end
    


endmodule