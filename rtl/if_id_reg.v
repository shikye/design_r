module if_id_reg (
    input   wire                    clk,
    input   wire                    rst_n,
    //from if_stage
    input   wire            [31:0]  if_pc_i,
    //from rom
    input   wire            [31:0]  rom_inst_i,
    //to id_stage
    output  reg             [31:0]  if_id_reg_inst_o,
    output  reg             [31:0]  if_id_reg_pc_o                    
);

    always @(posedge clk or negedge rst_n) begin
        if(rst_n == 1'b0)begin
            if_id_reg_inst_o <= 32'h0;
        end
        else begin 
            if_id_reg_inst_o <= rom_inst_i;
        end
    end

    always @(posedge clk or negedge rst_n) begin
        if(rst_n == 1'b0)begin
            if_id_reg_pc_o <= 32'h0;
        end
        else begin 
            if_id_reg_pc_o <= if_pc_i;
        end
    end



endmodule