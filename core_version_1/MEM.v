module MEM (
    input   wire                    clk,
    input   wire                    rst_n,
    //from ex_mem_reg
    input   wire            [31:0]  exmem_op_c_i,
    input   wire            [4:0]   exmem_reg_waddr_i,
    input   wire                    exmem_reg_we_i,

    input   wire                    exmem_mtype_i,          
    input   wire                    exmem_mem_rw_i,        
    input   wire            [1:0]   exmem_mem_width_i,  

    //to mem_wb_reg
    output  reg             [31:0]  mem_op_c_o,
    output  wire            [4:0]   mem_reg_waddr_o,
    output  wire                    mem_reg_we_o,
    //from Dcache
    input   wire            [31:0]  Dcache_data_i,

    //from fc
    input   wire                    fc_Dcache_data_valid_i,

    input   wire                    fc_bk_mem_i,
    input   wire                    fc_flush_mem_i
    

);

  
    assign mem_reg_waddr_o = exmem_reg_waddr_i;
    assign mem_reg_we_o = exmem_reg_we_i;



    //------------for stall
    reg [31:0]  Data_Buffer;
    reg         Dcache_in_Buffer;

    always@(posedge clk or negedge rst_n)begin
        if(rst_n == 1'b0)begin
            Data_Buffer <= 32'h0;
            Dcache_in_Buffer <= 1'b0;
        end

        //Icache stall and Dcache need give out data
        else if(fc_bk_mem_i == 1'b1 && fc_Dcache_data_valid_i == 1'b1)begin
            Data_Buffer <= Dcache_data_i;
            Dcache_in_Buffer <= 1'b1;
        end
        else if(fc_bk_mem_i == 1'b1) begin
            Data_Buffer <= Data_Buffer;   //keep
        end
        else if(fc_flush_mem_i == 1'b1)begin
            Data_Buffer <= 32'h0;
        end
        else begin
            Data_Buffer <= exmem_op_c_i;
            
            if(Dcache_in_Buffer == 1'b1)
                Dcache_in_Buffer <= 1'b0;
        end
    end


    //-----------
    always@(*)begin
        if(exmem_mtype_i == 1'b1)begin
            if(fc_Dcache_data_valid_i == 1'b1)begin
                case(exmem_mem_width_i)
                    2'b01: mem_op_c_o = { {24{Dcache_data_i[7]}}, Dcache_data_i[7:0] };
                    2'b10: mem_op_c_o = { {16{Dcache_data_i[15]}}, Dcache_data_i[15:0] };
                    2'b11: mem_op_c_o = Dcache_data_i;
                    default: mem_op_c_o = 32'h0;
                endcase
            end
            else begin
                if(Dcache_in_Buffer == 1'b1) begin
                    case(exmem_mem_width_i)
                        2'b01: mem_op_c_o = { {24{Data_Buffer[7]}}, Data_Buffer[7:0] };
                        2'b10: mem_op_c_o = { {16{Data_Buffer[15]}}, Data_Buffer[15:0] };
                        2'b11: mem_op_c_o = Data_Buffer;
                    default: mem_op_c_o = 32'h0;
                endcase
                
                end
                else
                    mem_op_c_o = 32'h0;
            end
        end

        else
            mem_op_c_o = exmem_op_c_i;
    end








endmodule