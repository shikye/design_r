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
        $readmemh("../sim/inst",tb.soc_ins.rom_ins.rom_mem);
    end


    initial begin
        $dumpvars(0,tb.soc_ins);
        $dumpfile("tb.vcd");
    end


    initial begin

        wait(tb.soc_ins.rv32core_ins.regs_ins.regs[26] == 32'd1) begin
            #100
            if(tb.soc_ins.rv32core_ins.regs_ins.regs[27] == 32'd1) begin
                $display("PASS");
                $display("t4 = %d",tb.soc_ins.rv32core_ins.regs_ins.regs[29]);
                $display("gp = %d",tb.soc_ins.rv32core_ins.regs_ins.regs[3]);
                $display("pc = %x",tb.soc_ins.rv32core_ins.if_stage_ins.if_pc_o);

            end
            else begin
                $display("test %d fail",tb.soc_ins.rv32core_ins.regs_ins.regs[3]);
                $display("t4 = %d",tb.soc_ins.rv32core_ins.regs_ins.regs[29]);
                $display("ra = %d",tb.soc_ins.rv32core_ins.regs_ins.regs[1]);
                $display("pc = %x",tb.soc_ins.rv32core_ins.if_stage_ins.if_pc_o);
            end
            $finish;
        end


    end

    soc soc_ins(
        .clk(clk),
        .rst_n(rst_n)
    );











endmodule
