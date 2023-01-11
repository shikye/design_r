module tb;

    reg     clk;
    reg     rst_n;

    always #10 clk = ~clk;

    initial begin
        clk <= 1'b0;
        rst_n <= 1'b0;

        #30 
        rst_n <= 1'b1;
    end

    initial begin
        $readmemb("../sim/inst",tb.soc_ins.rom_ins.rom_mem);
    end


    initial begin
        $dumpvars(0,tb.soc_ins);
        $dumpfile("tb.vcd");
    end


    always @(posedge clk) begin
        $display("x27 is %d", tb.soc_ins.rv32core_ins.regs_ins.regs[27]);
        $display("x28 is %d", tb.soc_ins.rv32core_ins.regs_ins.regs[28]);
        $display("x29 is %d", tb.soc_ins.rv32core_ins.regs_ins.regs[29]);
    end

    soc soc_ins(
        .clk(clk),
        .rst_n(rst_n)
    );











endmodule