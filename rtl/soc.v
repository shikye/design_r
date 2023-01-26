module soc(
    input   wire                    clk,
    input   wire                    rst_n
    );
    
    
    //source 
    //rom
    wire    [127:0]  mem_data_o;
    wire            mem_ready_o;
    //rv32core
    wire    [31:0]  rv32core_addr_o;
    wire            rv32core_valid_req_o;
    
    rom rom_ins(
        .clk(clk),
        .rst_n(rst_n),
        .Icache_addr_i(rv32core_addr_o),
        .Icache_valid_req_i(rv32core_valid_req_o),
        .mem_data_o(mem_data_o),
        .mem_ready_o(mem_ready_o)
    );
    
    rv32core rv32core_ins(
        .clk(clk),
        .rst_n(rst_n),
        .rv32core_addr_o(rv32core_addr_o),
        .rv32core_valid_req_o(rv32core_valid_req_o),
        .rom_ready_i(mem_ready_o),
        .rom_data_i(mem_data_o)
    );
    
    
endmodule
