module Flow_Ctrl(                  //Flush, Stall, Jump
    


//-------Flush: Jal,Jalr,Btype ------- to if_id_reg, id_ex_reg, 
//pc, Icache, id_inst(to clean)
    
    
    output  wire                    fc_flush_ifid_o,
    output  wire                    fc_flush_idex_o,
    output  wire                    fc_flush_id_o,


    output  wire            [31:0]  fc_jump_pc_if_o,
    output  wire                    fc_jump_flag_if_o,

    output  wire                    fc_jump_flag_Icache_o



//-------Stall(Back) and Keep: Icache miss, Dcache miss ------- to pc, id_inst, if_id_reg,
//id_ex_reg, ex_mem_reg, mem_wb_reg

    output  wire                    fc_bk_if_o,
    output  wire                    fc_bk_id_o,

    output  wire                    fc_bk_ifid_o,
    output  wire                    fc_bk_idex_o,
    output  wire                    fc_bk_exmem_o,
    output  wire                    fc_bk_memwb_o,



//-------Jump: Jal,Jalr ------- to pc, Icache, id(to clean inst)
    
);




endmodule