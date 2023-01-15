module if_id_reg (
    input   wire                    clk,
    input   wire                    rst_n,
    //from if_stage
    input   wire            [31:0]  if_pc_i,
    //to id_stage
    output  reg             [31:0]  if_id_reg_pc_o,
    //from fnb
    input   wire                    fnb_flush_i                
);

    always @(posedge clk or negedge rst_n) begin
        if(rst_n == 1'b0)begin
            if_id_reg_pc_o <= 32'h0;
        end
        else if(fnb_flush_i == 1'b1) begin
            if_id_reg_pc_o <= 32'h0;
        end
        else begin 
            if_id_reg_pc_o <= if_pc_i;
        end
    end



endmodule