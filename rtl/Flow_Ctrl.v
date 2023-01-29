module Flow_Ctrl(                  //Flush, Stall, Jump
    //from ex
    input   wire                    ex_branch_flag_i,
    input   wire            [31:0]  ex_jump_pc_i,   //Branch
    //from id
    input   wire            [31:0]  id_jump_pc_i,      //Jal,jarl
    input   wire                    id_jump_flag_i,    
    //from Icache
    input   wire                    Icache_ready_i,   //Icache miss stall
    
    
    //to if_id_reg and id_ex_reg
    output  wire                    fc_flush_btype_flag_o,
    //to if_id_reg
    output  wire                    fc_flush_jtype_flag_o,
    //to if_id_reg and if_pc
    output  reg                     fc_Icache_stall_flag_o,
    //to if_pc and id(keep inst zero)
    output  wire                    fc_jump_flag_o,
    output  wire            [31:0]  fc_jump_pc_o,

    output  wire                    fc_Icache_data_valid_o,

    //from mem
    input   wire                    rom_ready_i

);


    //branch and jal,jarl
    assign fc_flush_btype_flag_o = ex_branch_flag_i;
    assign fc_flush_jtype_flag_o = id_jump_flag_i;

    assign fc_jump_flag_o = ex_branch_flag_i | id_jump_flag_i;
    assign fc_jump_pc_o = ex_branch_flag_i ? ex_jump_pc_i :
                            id_jump_flag_i ? id_jump_pc_i : 32'h0;

       
    assign fc_Icache_data_valid_o = Icache_ready_i;

    always@(*) begin
        if(Icache_ready_i == 1'b0)
            fc_Icache_stall_flag_o = 1'b1;
        else 
            fc_Icache_stall_flag_o = 1'b0;
    end



endmodule