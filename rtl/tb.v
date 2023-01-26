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
        $dumpvars(0,tb.soc_ins,
        tb.soc_ins.rv32core_ins.Icache_ins.ICache_Tag_Array[0],
        tb.soc_ins.rv32core_ins.Icache_ins.ICache_Tag_Array[1],
        tb.soc_ins.rv32core_ins.Icache_ins.ICache_Tag_Array[2],
        tb.soc_ins.rv32core_ins.Icache_ins.ICache_Tag_Array[3]);
        $dumpfile("tb.vcd");
    end


    initial begin

        wait(tb.soc_ins.rv32core_ins.regs_ins.regs[26] == 32'd1) begin
            #100
            if(tb.soc_ins.rv32core_ins.regs_ins.regs[27] == 32'd1) begin
                $display("PASS");
                $display("gp = %d",tb.soc_ins.rv32core_ins.regs_ins.regs[3]);
                $display("pc = %x",tb.soc_ins.rv32core_ins.if_stage_ins.if_pc_o);

            end
            else begin
                $display("test %d fail",tb.soc_ins.rv32core_ins.regs_ins.regs[3]);
                $display("gp = %d",tb.soc_ins.rv32core_ins.regs_ins.regs[3]);
                $display("pc = %x",tb.soc_ins.rv32core_ins.if_stage_ins.if_pc_o);
                $display("t4 = %x",tb.soc_ins.rv32core_ins.regs_ins.regs[29]);
                $display("t5 = %x",tb.soc_ins.rv32core_ins.regs_ins.regs[30]);
                $display("sp = %x",tb.soc_ins.rv32core_ins.regs_ins.regs[2]);
                $display("replace bits is %d,%d",tb.soc_ins.rv32core_ins.Icache_ins.ICache_Tag_Array[3][25],
                    tb.soc_ins.rv32core_ins.Icache_ins.ICache_Tag_Array[2][25] );
            end
            $finish;
        end

        // wait(tb.soc_ins.rv32core_ins.regs_ins.regs[3] == 32'd2)begin
        //     $display("t5 = %d",tb.soc_ins.rv32core_ins.regs_ins.regs[30]);
        // end


    end

    always@(posedge clk) begin
        $display("in test %d",tb.soc_ins.rv32core_ins.regs_ins.regs[3]);
        $display("pc = %x",tb.soc_ins.rv32core_ins.if_stage_ins.if_pc_o);
        $display("t4 = %x",tb.soc_ins.rv32core_ins.regs_ins.regs[29]);
        $display("t5 = %x",tb.soc_ins.rv32core_ins.regs_ins.regs[30]);
        $display("sp = %x",tb.soc_ins.rv32core_ins.regs_ins.regs[2]);
        $display("replace bits is %d,%d",tb.soc_ins.rv32core_ins.Icache_ins.ICache_Tag_Array[3][25],
                    tb.soc_ins.rv32core_ins.Icache_ins.ICache_Tag_Array[2][25] );
    
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
