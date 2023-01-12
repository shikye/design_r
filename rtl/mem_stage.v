module mem_stage (
    input   wire                    clk,
    input   wire                    rst_n,
    //from ex_mem_reg
    input   wire            [31:0]  ex_mem_reg_op_c_i,
    input   wire            [4:0]   ex_mem_reg_reg_waddr_i,
    input   wire                    ex_mem_reg_reg_we_i,
    //to mem_wb_reg
    output  wire            [31:0]  mem_op_c_o,
    output  wire            [4:0]   mem_reg_waddr_o,
    output  wire                    mem_reg_we_o
);

    // always @(posedge clk or negedge rst_n)begin
    //     if(rst_n == 1'b0)begin
    //         mem_op_c_o <= 32'h0;
    //     end
    //     else begin
    //         mem_op_c_o <= ex_mem_reg_op_c_i;
    //     end
    // end


    // always @(posedge clk or negedge rst_n)begin
    //     if(rst_n == 1'b0)begin
    //         mem_reg_waddr_o <= 5'h0;
    //     end
    //     else begin
    //         mem_reg_waddr_o <= ex_mem_reg_reg_waddr_i;
    //     end
    // end

    // always @(posedge clk or negedge rst_n)begin
    //     if(rst_n == 1'b0)begin
    //         mem_reg_we_o <= 1'b0;
    //     end
    //     else begin
    //         mem_reg_we_o <= ex_mem_reg_reg_we_i;
    //     end
    // end

    assign mem_op_c_o = ex_mem_reg_op_c_i;
    assign mem_reg_waddr_o = ex_mem_reg_reg_waddr_i;
    assign mem_reg_we_o = ex_mem_reg_reg_we_i;



endmodule