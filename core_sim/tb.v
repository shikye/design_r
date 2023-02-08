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
        $readmemh("./inst",tb.soc_ins.rom_ins.rom_mem);
    end


    initial begin
        $dumpvars(0,tb.soc_ins
        // ,tb.soc_ins.rvcore_ins.Icache_ins.ICache_Tag_Array[0],
        // tb.soc_ins.rvcore_ins.Icache_ins.ICache_Tag_Array[1],
        //  tb.soc_ins.rvcore_ins.Icache_ins.ICache_Tag_Array[2],
        //  tb.soc_ins.rvcore_ins.Icache_ins.ICache_Tag_Array[3]
        // tb.soc_ins.rvcore_ins.Icache_ins.ICache_Data_Block[0]
        );
        $dumpfile("tb.vcd");
    end


    initial begin

        wait(tb.soc_ins.rvcore_ins.regs_ins.regs[26] == 32'd1) begin
            #100
            if(tb.soc_ins.rvcore_ins.regs_ins.regs[27] == 32'd1) begin
                $display("PASS");

            end
            else begin
                $display("FAIL");
                $display("gp = %d",tb.soc_ins.rvcore_ins.regs_ins.regs[3]);
                $display("t4 = %d",tb.soc_ins.rvcore_ins.regs_ins.regs[29]);
                $display("t5 = %d",tb.soc_ins.rvcore_ins.regs_ins.regs[30]);
            end
            $finish;
        end


    end

    always@(posedge clk) begin
        $display("pc = %x",tb.soc_ins.rvcore_ins.IF_ins.if_pc_o);
        $display("t4 = %d",tb.soc_ins.rvcore_ins.regs_ins.regs[29]);
        $display("t5 = %d",tb.soc_ins.rvcore_ins.regs_ins.regs[30]);
        $display("--------------------------------------------------");
    end


    initial begin
        #100000
        $display("timeout");
        $finish;
    end



    soc soc_ins(
        .clk(clk),
        .rst_n(rst_n)
    );


endmodule
