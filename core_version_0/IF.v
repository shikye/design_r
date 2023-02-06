module IF(
    input                       clk,
    input                       rst_n,

    //from fc
    input   wire                fc_bk_if_i,  //back_and_keep
    input   wire        [31:0]  fc_jump_pc_if_i,
    input   wire                fc_jump_flag_if_i,

    //to Icache, if_id_reg
    output  reg         [31:0]  if_pc_o,

    //to Icache
    output  reg                 if_req_Icache_o
);

    reg start_flag; //need a start state

    reg [31:0]  PC_Buffer;  //for back_and_keep

    always@(posedge clk or negedge rst_n)begin
        if(rst_n == 1'b0)begin      //start state
            if_pc_o <= 32'h0;
            if_req_Icache_o <= 1'b0;
            start_flag <= 1'b1;
            PC_Buffer <= 32'h0;
        end
        else if(start_flag == 1'b1)begin
            if_pc_o <= 32'h0;
            if_req_Icache_o <= 1'b1;
            start_flag <= 1'b0;
            PC_Buffer <= if_pc_o;
        end
        else if(fc_bk_if_i == 1'b1)begin
            if_pc_o <= PC_Buffer;       //back
            if_req_Icache_o <= 1'b0;
            start_flag <= 1'b0;
            PC_Buffer <= PC_Buffer;    //to keep
        end
        else if(fc_jump_flag_if_i == 1'b1)begin
            if_pc_o <= fc_jump_pc_if_i;
            if_req_Icache_o <= 1'b1;
            start_flag <= 1'b0;
            PC_Buffer <= if_pc_o;
        end
        else begin
            if_pc_o <= if_pc_o + 32'd4;
            if_req_Icache_o <= 1'b1;
            start_flag <= 1'b0;
            PC_Buffer <= if_pc_o;
        end
    end


endmodule