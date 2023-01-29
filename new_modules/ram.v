module ram (
    input   wire                    clk,
    input   wire                    rst_n,
    //from Dcache
    input   wire                    Dcache_rd_req_i,
    input   wire            [31:0]  Dcache_rd_addr_i,
    
    input   wire                    Dcache_wb_req_i,
    input   wire            [31:0]  Dcache_wb_addr_i,
    input   wire            [127:0] Dcache_data_ram_i,
    //to Dcache
    output  reg             [127:0] ram_data_o,
    output  reg                     ram_ready_o
);


    reg [7:0]   ram_mem[0:4095];

    always@(posedge clk or rst_n) begin
        if(rst_n == 1'b0) begin
            ram_data_o <= 128'h0;
            ram_ready_o <= 1'b0;
        end
        else begin
            
            if(Dcache_rd_req_i == 1'b1) begin
                ram_data_o[7:0]     <= ram_mem[Dcache_rd_addr_i];    
                ram_data_o[15:8]    <= ram_mem[Dcache_rd_addr_i+1];  
                ram_data_o[23:16]   <= ram_mem[Dcache_rd_addr_i+2];  
                ram_data_o[31:24]   <= ram_mem[Dcache_rd_addr_i+3];  
                ram_data_o[39:32]   <= ram_mem[Dcache_rd_addr_i+4];  
                ram_data_o[47:40]   <= ram_mem[Dcache_rd_addr_i+5];  
                ram_data_o[55:48]   <= ram_mem[Dcache_rd_addr_i+6];  
                ram_data_o[63:56]   <= ram_mem[Dcache_rd_addr_i+7];  
                ram_data_o[71:64]   <= ram_mem[Dcache_rd_addr_i+8];  
                ram_data_o[79:72]   <= ram_mem[Dcache_rd_addr_i+9];  
                ram_data_o[87:80]   <= ram_mem[Dcache_rd_addr_i+10];  
                ram_data_o[95:88]   <= ram_mem[Dcache_rd_addr_i+11];  
                ram_data_o[103:96]  <= ram_mem[Dcache_rd_addr_i+12];  
                ram_data_o[111:104] <= ram_mem[Dcache_rd_addr_i+13];  
                ram_data_o[119:112] <= ram_mem[Dcache_rd_addr_i+14];  
                ram_data_o[127:120] <= ram_mem[Dcache_rd_addr_i+15];  

                ram_ready_o <= 1'b1;
            end
            else if (Dcache_wb_req_i == 1'b1) begin
                ram_mem[Dcache_wb_addr_i]       <=  Dcache_data_ram_i[7:0];
                ram_mem[Dcache_wb_addr_i+1]     <=  Dcache_data_ram_i[15:8];
                ram_mem[Dcache_wb_addr_i+2]     <=  Dcache_data_ram_i[23:16];
                ram_mem[Dcache_wb_addr_i+3]     <=  Dcache_data_ram_i[31:24];
                ram_mem[Dcache_wb_addr_i+4]     <=  Dcache_data_ram_i[39:32];
                ram_mem[Dcache_wb_addr_i+5]     <=  Dcache_data_ram_i[47:40];
                ram_mem[Dcache_wb_addr_i+6]     <=  Dcache_data_ram_i[55:48];
                ram_mem[Dcache_wb_addr_i+7]     <=  Dcache_data_ram_i[63:56];
                ram_mem[Dcache_wb_addr_i+8]     <=  Dcache_data_ram_i[71:64];
                ram_mem[Dcache_wb_addr_i+9]     <=  Dcache_data_ram_i[79:72];
                ram_mem[Dcache_wb_addr_i+10]    <=  Dcache_data_ram_i[87:80];
                ram_mem[Dcache_wb_addr_i+11]    <=  Dcache_data_ram_i[95:88];
                ram_mem[Dcache_wb_addr_i+12]    <=  Dcache_data_ram_i[103:96];
                ram_mem[Dcache_wb_addr_i+13]    <=  Dcache_data_ram_i[111:104];
                ram_mem[Dcache_wb_addr_i+14]    <=  Dcache_data_ram_i[119:112];
                ram_mem[Dcache_wb_addr_i+15]    <=  Dcache_data_ram_i[127:120];
            end
            else begin
                ram_data_o <= 128'h0;
                ram_ready_o <= 1'b0;
            end
        end
    end


endmodule