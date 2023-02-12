module mem_wb_reg (
    input   wire                    clk,
    input   wire                    rst_n,
    //from mem
    input   wire            [31:0]  mem_op_c_i,
    input   wire            [4:0]   mem_reg_waddr_i,
    input   wire                    mem_reg_we_i,

    //to wb
    output  reg             [31:0]  memwb_op_c_o,
    output  reg             [4:0]   memwb_reg_waddr_o,
    output  reg                     memwb_reg_we_o,
    //from fc
    input   wire                    fc_flush_memwb_i,
    input   wire                    fc_bk_memwb_i
);



    always@(posedge clk or negedge rst_n)begin

        if(rst_n == 1'b0)begin
            memwb_op_c_o <= 32'h0;
            memwb_reg_waddr_o <= 5'h0;
            memwb_reg_we_o <= 1'b0;
        end
        else if(fc_bk_memwb_i == 1'b1)begin
            memwb_op_c_o <= memwb_op_c_o;
            memwb_reg_waddr_o <= memwb_reg_waddr_o;
            memwb_reg_we_o <= memwb_reg_we_o;  
        end
        else if(fc_flush_memwb_i == 1'b1)begin
            memwb_op_c_o <= 32'h0;
            memwb_reg_waddr_o <= 5'h0;
            memwb_reg_we_o <= 1'b0;
        end
        else begin
            memwb_op_c_o <= mem_op_c_i;
            memwb_reg_waddr_o <= mem_reg_waddr_i;
            memwb_reg_we_o <= mem_reg_we_i;
        end
    end
    


endmodule