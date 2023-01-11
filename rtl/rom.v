module rom (
    input   wire                    clk,
    input   wire                    rst_n,
    //from rv32core
    input   wire            [31:0]  rv32core_pc_i,
    //to if_id_reg
    output  reg             [31:0]  rom_inst_o
);


    reg [31:0]  rom_mem[0:1023];

    always @(posedge clk or negedge rst_n) begin
        if(rst_n == 1'b0)begin
            rom_inst_o <= 32'h0;
        end 
        else begin
            rom_inst_o <= rom_mem[rv32core_pc_i>>2];    //指令长度为定�?4字节，故PC每个周期�?4
        end
    end


endmodule