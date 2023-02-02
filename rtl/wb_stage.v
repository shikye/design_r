module wb_stage (
    input   wire                    clk,
    input   wire                    rst_n,
    //from mem_wb_reg
    input   wire            [31:0]  mem_wb_reg_op_c_i,
    input   wire            [4:0]   mem_wb_reg_reg_waddr_i,
    input   wire                    mem_wb_reg_reg_we_i,
    input   wire                    mem_wb_reg_mtype_i,
    input   wire            [1:0]   mem_wb_reg_width_i,
    //to regs
    output  reg             [31:0]  wb_op_c_o,
    output  wire            [4:0]   wb_reg_waddr_o,
    output  reg                     wb_reg_we_o,

    //from Dcache
    input   wire            [31:0]  Dcache_data_i,

    //from fc
    input   wire                    fc_Dcache_data_valid_i
);

    assign wb_reg_waddr_o = mem_wb_reg_reg_waddr_i;


    always @(*) begin
        if(mem_wb_reg_mtype_i == 1'b1) begin
            case(mem_wb_reg_width_i)
                2'b01: wb_op_c_o = { {24{Dcache_data_i[7]}}, Dcache_data_i[7:0] };
                2'b10: wb_op_c_o = { {16{Dcache_data_i[15]}}, Dcache_data_i[15:0] };
                2'b11: wb_op_c_o = Dcache_data_i;
                default: wb_op_c_o = 32'h0;
            endcase
        end
        else
            wb_reg_we_o = mem_wb_reg_op_c_i;
    end


    always @(*) begin
        if(mem_wb_reg_mtype_i == 1'b1) begin
            if(fc_Dcache_data_valid_i == 1'b1)
                wb_reg_we_o = mem_wb_reg_reg_we_i;
            else 
                wb_reg_we_o = 1'b0;
        end
        else
            wb_reg_we_o = mem_wb_reg_reg_we_i;
    end


endmodule