module soc(
    input   wire                    clk,
    input   wire                    rst_n
    );
    
    
    //source 
    //rom
    wire    [127:0] mem_data_o;
    wire            mem_ready_o;
    //rvcore
    wire    [31:0]  rvcore_addr_rom_o;
    wire            rvcore_req_rom_o;

    wire            rvcore_Dcache_rd_req_o;
    wire    [31:0]  rvcore_Dcache_rd_addr_o;
    wire            rvcore_Dcache_wb_req_o;
    wire    [31:0]  rvcore_Dcache_wb_addr_o;
    wire    [127:0] rvcore_Dcache_wb_data_o;
    //ram
    wire    [127:0] ram_data_o;
    wire            ram_ready_o;



    wire    [31:0]  Dcache_rd_addr_i;
    wire    [31:0]  Dcache_wb_addr_i;

    assign  Dcache_rd_addr_i = rvcore_Dcache_rd_addr_o - 32'h1000_0000;
    assign  Dcache_wb_addr_i = rvcore_Dcache_wb_addr_o - 32'h1000_0000;

    
    rom rom_ins(
        .clk(clk),
        .rst_n(rst_n),
        .Icache_addr_i(rvcore_addr_rom_o),
        .Icache_valid_req_i(rvcore_req_rom_o),
        .mem_data_o(mem_data_o),
        .mem_ready_o(mem_ready_o)
    );
    
    rvcore rvcore_ins(
        .clk(clk),
        .rst_n(rst_n),

        .rom_ready_i(mem_ready_o),
        .rom_data_i(mem_data_o),

        .ram_data_i(ram_data_o),
        .ram_ready_i(ram_ready_o),

        .rvcore_addr_rom_o(rvcore_addr_rom_o),
        .rvcore_req_rom_o(rvcore_req_rom_o),
        

        .rvcore_Dcache_rd_req_o(rvcore_Dcache_rd_req_o),
        .rvcore_Dcache_rd_addr_o(rvcore_Dcache_rd_addr_o),
        .rvcore_Dcache_wb_req_o(rvcore_Dcache_wb_req_o),
        .rvcore_Dcache_wb_addr_o(rvcore_Dcache_wb_addr_o),
        .rvcore_Dcache_wb_data_o(rvcore_Dcache_wb_data_o)
    );

    ram ram_ins(
        .clk(clk),
        .rst_n(rst_n),
        .Dcache_rd_req_i(rvcore_Dcache_rd_req_o),
        .Dcache_rd_addr_i(Dcache_rd_addr_i),
        .Dcache_wb_req_i(rvcore_Dcache_wb_req_o),
        .Dcache_wb_addr_i(Dcache_wb_addr_i),
        .Dcache_wb_data_i(rvcore_Dcache_wb_data_o),
        .ram_data_o(ram_data_o),
        .ram_ready_o(ram_ready_o)     
    );
    
    
endmodule
