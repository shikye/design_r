module rom (
    input   wire                    clk,
    input   wire                    rst_n,
    //from Icache
    input   wire            [31:0]  Icache_addr_i,
    input   wire                    Icache_valid_req_i,
    //to Icache
    output  reg             [127:0] mem_data_o,
    output  reg                     mem_ready_o  
);


    reg [7:0]  rom_mem[0:4095];

    wire [31:0] base_addr = {Icache_addr_i[31:4],{4{1'b0}}};

    always @(posedge clk or negedge rst_n) begin
        if(rst_n == 1'b0)begin
            mem_data_o <= 32'h0;
            mem_ready_o <= 1'b0;
        end 
        else if(Icache_valid_req_i == 1'b1) begin
            mem_data_o[7:0]     <= rom_mem[base_addr];
            mem_data_o[15:8]    <= rom_mem[base_addr+1];
            mem_data_o[23:16]   <= rom_mem[base_addr+2];
            mem_data_o[31:24]   <= rom_mem[base_addr+3];
            mem_data_o[39:32]   <= rom_mem[base_addr+4];
            mem_data_o[47:40]   <= rom_mem[base_addr+5];
            mem_data_o[55:48]   <= rom_mem[base_addr+6];
            mem_data_o[63:56]   <= rom_mem[base_addr+7];
            mem_data_o[71:64]   <= rom_mem[base_addr+8];
            mem_data_o[79:72]   <= rom_mem[base_addr+9];
            mem_data_o[87:80]   <= rom_mem[base_addr+10];
            mem_data_o[95:88]   <= rom_mem[base_addr+11];
            mem_data_o[103:96]  <= rom_mem[base_addr+12];
            mem_data_o[111:104] <= rom_mem[base_addr+13];
            mem_data_o[119:112] <= rom_mem[base_addr+14];
            mem_data_o[127:120] <= rom_mem[base_addr+15];

            mem_ready_o <= 1'b1;
        end
        else begin
            mem_data_o <= 128'h0;
            mem_ready_o <= 1'b0;
        end
    end


endmodule