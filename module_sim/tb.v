module tb;

reg clk;
reg rst_n;

reg [31:0]  core_inst_addr_i;
reg         core_valid_req_i;

wire        Icache_ready_o;
wire[31:0]  Icache_inst_o;

wire        hit;
wire        pipe_stall;

wire[31:0]  Icache_addr_o;
wire        Icache_valid_req_o;

reg         mem_ready_i;
reg [127:0] mem_data_i;


always #5 clk = ~clk;

initial begin
    clk <= 1'b0;
    rst_n <= 1'b0;
    core_inst_addr_i <= 32'h0000_0001;
    core_valid_req_i <= 1'b0;
    mem_ready_i <= 1'b0;
    mem_data_i <= 128'h1111_0000_1111_0000_1011_0000_1111_0000;
    #10
    rst_n <= 1'b1;
    #10

    @(posedge clk) begin
    core_inst_addr_i <= 32'h0000_0001;
    core_valid_req_i <= 1'b1;
    end
    @(posedge clk)
    core_valid_req_i <= 1'b0;
    #30
    @(posedge clk)begin
    mem_ready_i <= 1'b1;
    mem_data_i <= 128'h1111_0000_1111_0000_1011_0000_1111_0000;
    end
    @(posedge clk)
    mem_ready_i <= 1'b0;
    #30
    @(posedge clk)begin
    core_inst_addr_i <= 32'h0000_0021;
    core_valid_req_i <= 1'b1;
    end
    @(posedge clk)
    core_valid_req_i <= 1'b0;
    #40
    @(posedge clk)begin
    mem_ready_i <= 1'b1;
    mem_data_i <= 128'h1111_0000_1111_0000_1011_0010_1111_0000;
    end
    @(posedge clk)
    mem_ready_i <= 1'b0;
    $finish;
end

initial begin
    $dumpfile("dump.vcd");
    $dumpvars(0,tb.Icache_ins,tb.Icache_ins.ICache_Tag_Array[0],tb.Icache_ins.ICache_Tag_Array[1]);
end



ICache Icache_ins(
    .clk(clk),
    .rst_n(rst_n),
    .core_inst_addr_i(core_inst_addr_i),
    .core_valid_req_i(core_valid_req_i),
    .Icache_ready_o(Icache_ready_o),
    .Icache_inst_o(Icache_inst_o),
    .hit(hit),
    .pipe_stall(pipe_stall),
    .Icache_addr_o(Icache_addr_o),
    .Icache_valid_req_o(Icache_valid_req_o),
    .mem_ready_i(mem_ready_i),
    .mem_data_i(mem_data_i)
);



endmodule