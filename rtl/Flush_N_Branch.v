module Flush_N_Branch(
    //from ex_ALU
    input   wire                    ex_branch_i,
    //to if_id_reg and id_ex_reg
    output  wire                    fnb_flush_o,
    //to if_pc
    output  wire                    fnb_jump_o
);

    assign fnb_flush_o = ex_branch_i;

    assign fnb_jump_o = ex_branch_i;


endmodule