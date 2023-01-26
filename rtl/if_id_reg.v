module if_id_reg (
    input   wire                    clk,
    input   wire                    rst_n,
    //from if_stage
    input   wire            [31:0]  if_pc_i,
    //to id_stage
    output  reg             [31:0]  if_id_reg_pc_o,
    //from fc
    input   wire                    fc_flush_btype_flag_i,
    input   wire                    fc_flush_jtype_flag_i,
    input   wire                    fc_stall_flag_i
);

    always @(posedge clk or negedge rst_n) begin
        if(rst_n == 1'b0)begin
            if_id_reg_pc_o <= 32'h0;
        end
        else if(fc_flush_btype_flag_i == 1'b1 || fc_flush_jtype_flag_i == 1'b1) begin
            if_id_reg_pc_o <= 32'h0;
        end
        else if(fc_stall_flag_i == 1'b1)
            if_id_reg_pc_o <= if_id_reg_pc_o;
        else begin 
            if_id_reg_pc_o <= if_pc_i;
        end
    end



endmodule