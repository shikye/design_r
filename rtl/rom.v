module rom (
    input   wire                    clk,
    input   wire                    rst_n,
    //from rv32core
    input   wire            [31:0]  rv32core_pc_i,
    //to id
    output  reg             [31:0]  rom_inst_o
);


    reg [7:0]  rom_mem[0:4095];

    always @(posedge clk or negedge rst_n) begin
        if(rst_n == 1'b0)begin
            rom_inst_o <= 32'h0;
        end 
        else begin
            // rom_inst_o <= rom_mem[rv32core_pc_i>>2];    //指令长度为定�?4字节，故PC每个周期�?4
            rom_inst_o[7:0]   <= rom_mem[rv32core_pc_i];
            rom_inst_o[15:8]  <= rom_mem[rv32core_pc_i+1];
            rom_inst_o[23:16] <= rom_mem[rv32core_pc_i+2];
            rom_inst_o[31:24] <= rom_mem[rv32core_pc_i+3];
        end
    end


endmodule