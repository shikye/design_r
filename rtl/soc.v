module soc(
    input   wire                    clk,
    input   wire                    rst_n
    );
    
    
    //source 
    //rom
    wire    [31:0]  rom_inst_o;
    //rv32core
    wire    [31:0]  rv32core_pc_o;
    
    rom rom_inst(
        .clk(clk),
        .rst_n(rst_n),
        .rv32core_pc_i(rv32core_pc_o),
        .rom_inst_o(rom_inst_o)
    );
    
    rv32core rv32core_ins(
        .clk(clk),
        .rst_n(rst_n),
        .rv32core_pc_o(rv32core_pc_o),
        .rom_inst_i(rom_inst_o)
    );
    
    
endmodule
