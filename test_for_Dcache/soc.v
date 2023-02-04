module soc(
    input   wire                    clk,
    input   wire                    rst_n
    );
    
    
    //source 
    //rom
    wire    [127:0] mem_data_o;
    wire            mem_ready_o;
    //rv32core
    wire    [31:0]  rv32core_addr_o;
    wire            rv32core_valid_req_o;

    wire            rv32core_Dcache_rd_req_o;
    wire    [31:0]  rv32core_Dcache_rd_addr_o;
    wire            rv32core_Dcache_wb_req_o;
    wire    [31:0]  rv32core_Dcache_wb_addr_o;
    wire    [127:0] rv32core_Dcache_data_ram_o;
    //ram
    wire    [127:0] ram_data_o;
    wire            ram_ready_o;



    wire    [31:0]  Dcache_rd_addr_i;
    wire    [31:0]  Dcache_wb_addr_i;

    assign  Dcache_rd_addr_i = rv32core_Dcache_rd_addr_o - 32'h1000_0000;
    assign  Dcache_wb_addr_i = rv32core_Dcache_wb_addr_o - 32'h1000_0000;

    
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
        .rom_data_i(mem_data_o),

        .rv32core_Dcache_rd_req_o(rv32core_Dcache_rd_req_o),
        .rv32core_Dcahce_rd_addr_o(rv32core_Dcache_rd_addr_o),
        .rv32core_Dcache_wb_req_o(rv32core_Dcache_wb_req_o),
        .rv32core_Dcache_wb_addr_o(rv32core_Dcache_wb_addr_o),
        .rv32core_Dcache_data_ram_o(rv32core_Dcache_data_ram_o),

        .ram_data_i(ram_data_o),
        .ram_ready_i(ram_ready_o)
    );

    ram ram_ins(
        .clk(clk),
        .rst_n(clk),
        .Dcache_rd_req_i(rv32core_Dcache_rd_req_o),
        .Dcache_rd_addr_i(Dcache_rd_addr_i),
        .Dcache_wb_req_i(rv32core_Dcache_wb_req_o),
        .Dcache_wb_addr_i(Dcache_wb_addr_i),
        .Dcache_data_ram_i(rv32core_Dcache_data_ram_o),
        .ram_data_o(ram_data_o),
        .ram_ready_o(ram_ready_o)     
    );
    
    
endmodule
