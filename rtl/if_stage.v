module if_stage (
    input   wire                    clk,
    input   wire                    rst_n,

    //to rom, if_id_reg
    output  reg             [31:0]  if_pc_o,
    //from fnb
    input   wire                    fnb_jump_i,
    //from ex
    input   wire            [31:0]  ex_next_pc_i,
    //from id
    input   wire            [31:0]  id_jump_pc_i,
    input   wire                    id_jump_en_i
    
);


    always @(posedge clk or negedge rst_n) begin
        if(rst_n == 1'b0)begin
            if_pc_o <= 32'h0;
        end
        else if(id_jump_en_i == 1'b1) begin
            if_pc_o <= id_jump_pc_i;
        end
        else if(fnb_jump_i == 1'b1) begin
            if_pc_o <= ex_next_pc_i;
        end
        else begin
            if_pc_o <= if_pc_o + 32'h4;
        end
    end


    
endmodule
