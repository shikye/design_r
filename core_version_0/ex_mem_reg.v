module ex_mem_reg (
    input   wire                    clk,
    input   wire                    rst_n,
    //from ex
    input   wire            [31:0]  ex_op_c_i,
    input   wire            [4:0]   ex_reg_waddr_i,
    input   wire                    ex_reg_we_i,

    input   wire                    ex_mtype_i,  
    input   wire                    ex_mem_rw_i, 
    input   wire            [1:0]   ex_mem_width_i,
    input   wire            [31:0]  ex_mem_wr_data_i,
    input   wire                    ex_mem_rdtype_i,
    input   wire            [31:0]  ex_mem_addr_i,

    //to mem
    output  reg             [31:0]  exmem_op_c_o,
    output  reg             [4:0]   exmem_reg_waddr_o,
    output  reg                     exmem_reg_we_o,


    output  reg                     exmem_mtype_o,          
    output  reg                     exmem_mem_rw_o,        
    output  reg             [1:0]   exmem_mem_width_o,      
    output  reg             [31:0]  exmem_mem_wr_data_o, 
    output  reg                     exmem_mem_rdtype_o,    
    output  reg             [31:0]  exmem_mem_addr_o,

    //from fc
    input   wire                    fc_flush_exmem_i,
    input   wire                    fc_bk_exmem_i
);


    reg [31:0] Op_C_Buffer;
    reg [4:0]  Reg_Waddr_Buffer;
    reg        Reg_We_Buffer;

    reg        Mtype_Buffer;
    reg        Mem_Rw_Buffer;
    reg [1:0]  Mem_Width_Buffer;
    reg [31:0] Mem_Wr_Data_Buffer;
    reg        Mem_Rdtype_Buffer;
    reg [31:0] Mem_Addr_Buffer;



    always@(posedge clk or negedge rst_n)begin

        if(rst_n == 1'b0)begin
            exmem_op_c_o <= 32'h0;
            exmem_reg_waddr_o <= 5'h0;
            exmem_reg_we_o <= 1'b0;

            exmem_mtype_o <= 1'b0;
            exmem_mem_rw_o <= 1'b0;
            exmem_mem_width_o <= 2'b0;
            exmem_mem_wr_data_o <= 32'h0;
            exmem_mem_rdtype_o <= 1'b0;
            exmem_mem_addr_o <= 32'h0;



            Op_C_Buffer <= 32'h0;
            Reg_Waddr_Buffer <= 5'h0;
            Reg_We_Buffer <= 1'b0;

            Mtype_Buffer <= 1'b0;
            Mem_Rw_Buffer <= 1'b0;
            Mem_Width_Buffer <= 2'b0;
            Mem_Wr_Data_Buffer <= 32'h0;
            Mem_Rdtype_Buffer <= 1'b0;
            Mem_Addr_Buffer <= 32'h0;
        end
        else if(fc_bk_exmem_i == 1'b1)begin
            exmem_op_c_o <= Op_C_Buffer;
            exmem_reg_waddr_o <= Reg_Waddr_Buffer;
            exmem_reg_we_o <= Reg_We_Buffer;

            exmem_mtype_o <= Mtype_Buffer;
            exmem_mem_rw_o <= Mem_Rw_Buffer;
            exmem_mem_width_o <= Mem_Width_Buffer;
            exmem_mem_wr_data_o <= Mem_Wr_Data_Buffer;
            exmem_mem_rdtype_o <= Mem_Rdtype_Buffer;
            exmem_mem_addr_o <= Mem_Addr_Buffer;


            
            Op_C_Buffer <= Op_C_Buffer;
            Reg_Waddr_Buffer <= Reg_Waddr_Buffer;
            Reg_We_Buffer <= Reg_We_Buffer;

            Mtype_Buffer <= Mtype_Buffer;
            Mem_Rw_Buffer <= Mem_Rw_Buffer;
            Mem_Width_Buffer <= Mem_Width_Buffer;
            Mem_Wr_Data_Buffer <= Mem_Wr_Data_Buffer;
            Mem_Rdtype_Buffer <= Mem_Rdtype_Buffer;
            Mem_Addr_Buffer <= Mem_Addr_Buffer;
        end
        else if(fc_flush_exmem_i == 1'b1)begin
            exmem_op_c_o <= 32'h0;
            exmem_reg_waddr_o <= 5'h0;
            exmem_reg_we_o <= 1'b0;

            exmem_mtype_o <= 1'b0;
            exmem_mem_rw_o <= 1'b0;
            exmem_mem_width_o <= 2'b0;
            exmem_mem_wr_data_o <= 32'h0;
            exmem_mem_rdtype_o <= 1'b0;
            exmem_mem_addr_o <= 32'h0;



            Op_C_Buffer <= 32'h0;
            Reg_Waddr_Buffer <= 5'h0;
            Reg_We_Buffer <= 1'b0;

            Mtype_Buffer <= 1'b0;
            Mem_Rw_Buffer <= 1'b0;
            Mem_Width_Buffer <= 2'b0;
            Mem_Wr_Data_Buffer <= 32'h0;
            Mem_Rdtype_Buffer <= 1'b0;
            Mem_Addr_Buffer <= 32'h0;
        end
        else begin
            exmem_op_c_o <= ex_op_c_i;
            exmem_reg_waddr_o <= ex_reg_waddr_i;
            exmem_reg_we_o <= ex_reg_we_i;

            exmem_mtype_o <= ex_mtype_i;
            exmem_mem_rw_o <= ex_mem_rw_i;
            exmem_mem_width_o <= ex_mem_width_i;
            exmem_mem_wr_data_o <= ex_mem_wr_data_i;
            exmem_mem_rdtype_o <= ex_mem_rdtype_i;
            exmem_mem_addr_o <= ex_mem_addr_i;


            
            Op_C_Buffer <= exmem_op_c_o;
            Reg_Waddr_Buffer <= exmem_reg_waddr_o;
            Reg_We_Buffer <= exmem_reg_we_o;

            Mtype_Buffer <= exmem_mtype_o;
            Mem_Rw_Buffer <= exmem_mem_rw_o;
            Mem_Width_Buffer <= exmem_mem_width_o;
            Mem_Wr_Data_Buffer <= exmem_mem_wr_data_o;
            Mem_Rdtype_Buffer <= exmem_mem_rdtype_o;
            Mem_Addr_Buffer <= exmem_mem_addr_o;
        end

    end



endmodule