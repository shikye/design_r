module Flow_Ctrl(                  //Flush, Stall, Jump

    input   wire                    clk,
    input   wire                    rst_n,
    

//-------------------------jump
    //from id
    input   wire                    id_jump_flag_i,
    input   wire            [31:0]  id_jump_pc_i,
    //from ex
    input   wire                    ex_branch_flag_i,
    input   wire            [31:0]  ex_branch_pc_i,
//-------------------------------

    //from if
    input   wire                    if_req_Icache_i,
    input   wire                    if_jump_Icache_i,


    //from Icache
    input   wire                    Icache_ready_i,
    input   wire                    Icache_hit_i,
    //to id
    output  wire                    fc_Icache_data_valid_o,


    //from Dcache
    input   wire                    Dcache_ready_i,
    input   wire                    Dcache_hit_i,
    //to wb
    output  wire                    fc_Dcache_data_valid_o,


    //from rom
    input   wire                    rom_ready_i,

    //from ram
    input   wire                    ram_ready_i,

    //from mem
    input   wire                    mem_req_Dcache_i,


//-------Flush: Jal,Jalr,Btype ------- to if_id_reg, id_ex_reg, 
//pc, Icache, id_inst(to clean)
    
    
    output  reg                     fc_flush_ifid_o,
    output  reg                     fc_flush_idex_o,
    output  reg                     fc_flush_exmem_o,
    output  reg                     fc_flush_memwb_o,
    output  reg                     fc_flush_id_o,


    output  wire            [31:0]  fc_jump_pc_if_o,
    output  wire                    fc_jump_flag_if_o,

    output  wire                    fc_jump_flag_Icache_o,



//-------Stall(Back) and Keep: Icache miss, Dcache miss ------- to pc, id_inst, if_id_reg,
//id_ex_reg, ex_mem_reg, mem_wb_reg

    output  reg                     fc_bk_if_o,
    output  reg                     fc_bk_id_o,

    output  reg                     fc_bk_ifid_o,
    output  reg                     fc_bk_idex_o,
    output  reg                     fc_bk_exmem_o,
    output  reg                     fc_bk_memwb_o
);

assign fc_jump_flag_Icache_o = if_jump_Icache_i;   //Icache jump


//----------------from Icache  -- for stall
reg rom_ready_buffer;

reg Icache_stall_flag;

    always@(posedge clk or negedge rst_n) begin  //lap one cycle to find up edge of rom
        if(rst_n == 1'b0) begin                  
            rom_ready_buffer <= 1'b0;
        end
        else begin
            rom_ready_buffer <= rom_ready_i;
        end
    
    end 

    always@(*) begin
        if(rst_n == 1'b0) begin
            Icache_stall_flag = 1'b0;
        end
        if( (rom_ready_buffer == 1'b0 && rom_ready_i == 1'b1) || (if_jump_Icache_i == 1'b1 && Icache_hit_i == 1'b1))
            Icache_stall_flag = 1'b0;
        else if(if_req_Icache_i == 1'b1 && Icache_hit_i == 1'b0)  // hit can be get instantly
            Icache_stall_flag = 1'b1;
    end

assign fc_Icache_data_valid_o = Icache_ready_i;

//-------------from Dcache   --for stall
reg ram_ready_buffer;

reg Dcache_stall_flag;

always@(posedge clk or negedge rst_n) begin  //lap one cycle to find up edge,for proper cycle
    if(rst_n == 1'b0) begin
        ram_ready_buffer <= 1'b0;
    end
    else begin
        ram_ready_buffer <= ram_ready_i;
    end
end 

always@(*) begin
    if(rst_n == 1'b0)
        Dcache_stall_flag = 1'b0;
    else if(mem_req_Dcache_i == 1'b1 && Dcache_hit_i == 1'b0)
        Dcache_stall_flag = 1'b1;
    else if(ram_ready_buffer == 1'b0 && ram_ready_i == 1'b1)  // one open condition
        Dcache_stall_flag = 1'b0;
end

assign fc_Dcache_data_valid_o = Dcache_ready_i;



//--------------for stall
always@(*)begin
    fc_bk_if_o = 1'b0;
    fc_bk_id_o = 1'b0;

    fc_bk_ifid_o = 1'b0;
    fc_bk_idex_o = 1'b0;
    fc_bk_exmem_o = 1'b0;
    fc_bk_memwb_o = 1'b0;

    if(Icache_stall_flag == 1'b1)begin
        fc_bk_if_o = 1'b1;
        fc_bk_id_o = 1'b1;

        fc_bk_ifid_o = 1'b1;
    end

    if(Dcache_stall_flag == 1'b1)begin
        fc_bk_if_o = 1'b1;
        fc_bk_id_o = 1'b1;

        fc_bk_ifid_o = 1'b1;
        fc_bk_idex_o = 1'b1;
        fc_bk_exmem_o = 1'b1;
        fc_bk_memwb_o = 'b1;
    end

end






//------------------- for flush

always@(*)begin

    fc_flush_ifid_o = 1'b0;
    fc_flush_idex_o = 1'b0;
    fc_flush_exmem_o = 1'b0;
    fc_flush_memwb_o = 1'b0;
    fc_flush_id_o = 1'b0; 

    if(id_jump_flag_i == 1'b1)begin  //jtype
        fc_flush_ifid_o = 1'b1;
        fc_flush_id_o = 1'b1;
    end
    else if(ex_branch_flag_i == 1'b1)begin //btype
        fc_flush_ifid_o = 1'b1;
        fc_flush_idex_o = 1'b1;
        fc_flush_id_o = 1'b1; 
    end
    
end


endmodule