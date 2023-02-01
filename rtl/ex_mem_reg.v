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
    output  reg             [31:0]  ex_mem_reg_op_c_o,
    output  reg             [4:0]   ex_mem_reg_reg_waddr_o,
    output  reg                     ex_mem_reg_reg_we_o,


    output  reg                     ex_mem_reg_mtype_i,          
    output  reg                     ex_mem_reg_mem_rw_i,        
    output  reg             [1:0]   ex_mem_reg_mem_width_i,      
    output  reg             [31:0]  ex_mem_reg_mem_wr_data_i, 
    output  reg                     ex_mem_reg_mem_rdtype_i,    
    output  reg             [31:0]  ex_mem_reg_mem_addr_i   
);

    always @(posedge clk or negedge rst_n)begin
        if(rst_n == 1'b0)begin
            ex_mem_reg_mtype_i          <= 1'b0;
            ex_mem_reg_mem_rw_i         <= 1'b0;
            ex_mem_reg_mem_width_i      <= 1'b0;
            ex_mem_reg_mem_wr_data_i    <= 32'h0;
            ex_mem_reg_mem_rdtype_i     <= 1'b0;
            ex_mem_reg_mem_addr_i       <= 32'h0;
        end
        else begin
            ex_mem_reg_mtype_i          <= ex_mtype_i;
            ex_mem_reg_mem_rw_i         <= ex_mem_rw_i;
            ex_mem_reg_mem_width_i      <= ex_mem_width_i;
            ex_mem_reg_mem_wr_data_i    <= ex_mem_wr_data_i;
            ex_mem_reg_mem_rdtype_i     <= ex_mem_rdtype_i;
            ex_mem_reg_mem_addr_i       <= ex_mem_addr_i;
        end
    end





    always @(posedge clk or negedge rst_n)begin
        if(rst_n == 1'b0)begin
            ex_mem_reg_op_c_o <= 32'h0;
        end
        else begin
            ex_mem_reg_op_c_o <= ex_op_c_i;
        end
    end

    always @(posedge clk or negedge rst_n)begin
        if(rst_n == 1'b0)begin
            ex_mem_reg_reg_waddr_o <= 5'h0;
        end
        else begin
            ex_mem_reg_reg_waddr_o <= ex_reg_waddr_i;
        end
    end

    always @(posedge clk or negedge rst_n)begin
        if(rst_n == 1'b0)begin
            ex_mem_reg_reg_we_o <= 1'b0;
        end
        else begin
            ex_mem_reg_reg_we_o <= ex_reg_we_i;
        end
    end


endmodule