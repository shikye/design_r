module IF(
    input                       clk,
    input                       rst_n,

    //from fc
    input   wire                fc_bk_if_i,  //back_and_keep
    input   wire        [31:0]  fc_jump_pc_if_i,
    input   wire                fc_jump_flag_if_i,

    //from Icache
    input   wire                Icache_req_again_if_i,

    //to Icache, if_id_reg
    output  reg         [31:0]  if_pc_o,

    //to Icache
    output  reg                 if_req_Icache_o,

    //to fc
    output  reg                 if_jump_Icache_o
);

    reg start_flag; //need a start state


    always@(posedge clk or negedge rst_n)begin
        if(rst_n == 1'b0)begin      //start state
            if_pc_o <= 32'h0;
            if_req_Icache_o <= 1'b0;
            start_flag <= 1'b1;
            if_jump_Icache_o <= 1'b0;
        end
        else if(start_flag == 1'b1)begin
            if_pc_o <= 32'h0;
            if_req_Icache_o <= 1'b1;
            start_flag <= 1'b0;
            if_jump_Icache_o <= 1'b0;
        end
        else if(fc_jump_flag_if_i == 1'b1)begin  //priority of jump is higher than bk
            if_pc_o <= fc_jump_pc_if_i;             //when present inst need to bk
            if_req_Icache_o <= 1'b1;                //but last inst is a jump
            start_flag <= 1'b0;                     //present inst don't need to excute
            if_jump_Icache_o <= 1'b1;
        end

        else if(fc_bk_if_i == 1'b1)begin
            if_pc_o <= if_pc_o;       
            start_flag <= 1'b0;
            if_jump_Icache_o <= 1'b0;

            if(Icache_req_again_if_i == 1'b1)
                if_req_Icache_o <= 1'b1;
            else 
                if_req_Icache_o <= 1'b0;

        end
        
        else begin
            if_pc_o <= if_pc_o + 32'd4;
            if_req_Icache_o <= 1'b1;
            start_flag <= 1'b0;
            if_jump_Icache_o <= 1'b0;
        end
    end


endmodule