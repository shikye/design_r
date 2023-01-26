module if_stage (
    input   wire                    clk,
    input   wire                    rst_n,

    //to Icache, if_id_reg
    output  reg             [31:0]  if_pc_o,
    //to Icache
    output  reg                     if_valid_req_o,
    //from fc
    input   wire                    fc_stall_flag_i,

    input   wire            [31:0]  fc_jump_pc_i,
    input   wire                    fc_jump_flag_i
    
);

    reg start_flag = 1'b1;


    always @(posedge clk or negedge rst_n) begin
        if(rst_n == 1'b0)begin
            if_pc_o <= 32'h0;
            if_valid_req_o <= 1'b0;
        end
        else if(fc_jump_flag_i == 1'b1) begin
            if_pc_o <= fc_jump_pc_i;
            if_valid_req_o <= 1'b1;
        end
        else if(fc_stall_flag_i == 1'b1) begin
            if_pc_o <= if_pc_o;
            if_valid_req_o <= 1'b0;             //if miss, req only once
        end
        else if(start_flag == 1'b1) begin 
            if_pc_o <= 32'h0;
            if_valid_req_o <= 1'b1;
            start_flag <= 1'b0;
        end 
        else begin
            if_pc_o <= if_pc_o + 32'h4;
            if_valid_req_o <= 1'b1;
        end
    end


    
endmodule
