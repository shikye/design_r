module if_stage (
    input   wire                    clk,
    input   wire                    rst_n,

    //to rom, if_id_reg
    output  reg             [31:0]  if_pc_o
    
);


    always @(posedge clk or negedge rst_n) begin
        if(rst_n == 1'b0)begin
            if_pc_o <= 32'h0;
        end
        else begin
            if_pc_o <= if_pc_o + 32'h4;
        end
    end


    
endmodule
