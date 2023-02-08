module WB (
    input   wire                    clk,
    input   wire                    rst_n,
    //from mem_wb_reg
    input   wire            [31:0]  memwb_op_c_i,
    input   wire            [4:0]   memwb_reg_waddr_i,
    input   wire                    memwb_reg_we_i,
    input   wire                    memwb_mtype_i,
    input   wire            [1:0]   memwb_width_i,
    //to regs
    output  reg             [31:0]  wb_op_c_o,
    output  wire            [4:0]   wb_reg_waddr_o,
    output  reg                     wb_reg_we_o,
    //from Dcache
    input   wire            [31:0]  Dcache_data_i,
    //from fc
    input   wire                    fc_Dcache_data_valid_i,

    input   wire                    fc_flush_wb_i,
    input   wire                    fc_bk_wb_i
);

    assign wb_reg_waddr_o = memwb_reg_waddr_i;

    //---------------for back_and_keep---
    reg [31:0]  Data_Buffer;
    reg         Dcache_in_Buffer;

    always@(posedge clk or negedge rst_n)begin
        if(rst_n == 1'b0)begin
            Data_Buffer <= 32'h0;
            Dcache_in_Buffer <= 1'b0;
        end

        //Icache stall and Dcache need give out data
        else if(fc_bk_wb_i == 1'b1 && fc_Dcache_data_valid_i == 1'b1)begin
            Data_Buffer <= Dcache_data_i;
            Dcache_in_Buffer <= 1'b1;
        end
        else if(fc_bk_wb_i == 1'b1) begin
            Data_Buffer <= Data_Buffer;   //keep
        end
        else if(fc_flush_wb_i == 1'b1)begin
            Data_Buffer <= 32'h0;
        end
        else if(fc_Dcache_data_valid_i == 1'b1) begin
            Data_Buffer <= Dcache_data_i;
        end
        else begin
            Data_Buffer <= memwb_op_c_i;
            
            if(Dcache_in_Buffer == 1'b1)
                Dcache_in_Buffer <= 1'b0;
        end
    end


    always @(*)begin
        if(memwb_mtype_i == 1'b1)begin   //access to Dcache
            if(fc_bk_wb_i == 1'b1)begin
                wb_op_c_o = Data_Buffer;
            end
            else if(fc_flush_wb_i == 1'b1) begin
                wb_op_c_o = 32'h0;
            end
            else begin
                if(fc_Dcache_data_valid_i == 1'b1) begin
                    case(memwb_width_i)
                        2'b01: wb_op_c_o = { {24{Dcache_data_i[7]}}, Dcache_data_i[7:0] };
                        2'b10: wb_op_c_o = { {16{Dcache_data_i[15]}}, Dcache_data_i[15:0] };
                        2'b11: wb_op_c_o = Dcache_data_i;
                        default: wb_op_c_o = 32'h0;
                    endcase
                end
                else begin
                    wb_op_c_o = 32'h0;
                end
            end
        end
        else begin
            if(fc_bk_wb_i == 1'b1)begin
                wb_op_c_o = Data_Buffer;
            end
            else if(fc_flush_wb_i == 1'b1) begin
                wb_op_c_o = 32'h0;
            end
            else begin
                wb_op_c_o = memwb_op_c_i;
            end
        end
    
    end

    always @(*)begin
        if(memwb_mtype_i == 1'b1)begin   //access to Dcache
            if(fc_bk_wb_i == 1'b1)begin
                wb_reg_we_o = 1'b0;
            end
            else if(fc_flush_wb_i == 1'b1) begin
                wb_reg_we_o = 1'b0;
            end
            else begin
                if(fc_Dcache_data_valid_i == 1'b1) begin
                    wb_reg_we_o = memwb_reg_we_i;
                end
                else begin
                    wb_reg_we_o = 32'h0;
                end
            end
        end
        else begin
            if(fc_bk_wb_i == 1'b1)begin
                wb_reg_we_o = 1'b0;
            end
            else if(fc_flush_wb_i == 1'b1) begin
                wb_reg_we_o = 1'b0;
            end
            else begin
                wb_reg_we_o = memwb_reg_we_i;
            end
        end
    
    end



endmodule