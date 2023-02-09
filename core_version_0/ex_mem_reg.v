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
        end
        else if(fc_bk_exmem_i == 1'b1)begin
            exmem_op_c_o <= exmem_op_c_o;
            exmem_reg_waddr_o <= exmem_reg_waddr_o;
            exmem_reg_we_o <= exmem_reg_we_o;

            exmem_mtype_o <= exmem_mtype_o;
            exmem_mem_rw_o <= exmem_mem_rw_o;
            exmem_mem_width_o <= exmem_mem_width_o;
            exmem_mem_wr_data_o <= exmem_mem_wr_data_o;
            exmem_mem_rdtype_o <= exmem_mem_rdtype_o;
            exmem_mem_addr_o <= exmem_mem_addr_o;
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
        end
        
    end



endmodule