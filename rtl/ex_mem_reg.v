module ex_mem_reg (
    input   wire                    clk,
    input   wire                    rst_n,
    //from ex
    input   wire            [31:0]  ex_op_c_i,
    input   wire            [4:0]   ex_reg_waddr_i,
    input   wire                    ex_reg_we_i,
    //to mem
    output  reg             [31:0]  ex_mem_reg_op_c_o,
    output  reg             [4:0]   ex_mem_reg_reg_waddr_o,
    output  reg                     ex_mem_reg_reg_we_o
);

    

    always @(posedge clk or negedge rst_n)begin
        if(rst_n == 1'b0)begin
            ex_mem_reg_op_c_o <= 32'h0;
        end
        else begin
            ex_mem_reg_op_c_o <= ex_op_c_i;
        end
    end

    always @(posedge clk or negedge rst_n)begin
        if(rst_n == 1'b0)begin
            ex_mem_reg_reg_waddr_o <= 5'h0;
        end
        else begin
            ex_mem_reg_reg_waddr_o <= ex_reg_waddr_i;
        end
    end

    always @(posedge clk or negedge rst_n)begin
        if(rst_n == 1'b0)begin
            ex_mem_reg_reg_we_o <= 1'b0;
        end
        else begin
            ex_mem_reg_reg_we_o <= ex_reg_we_i;
        end
    end


endmodule