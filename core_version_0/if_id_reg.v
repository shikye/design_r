module if_id_reg (
    input   wire                    clk,
    input   wire                    rst_n,

    //from IF
    input   wire            [31:0]  if_pc_i,
    //from fc
    input   wire                    fc_flush_ifid_i,
    input   wire                    fc_bk_ifid_i,


    //to ID
    output  reg             [31:0]  ifid_pc_o
    
);


//-----for back_and_keep------
    reg [31:0]  Ifid_PC_Buffer;


    always @(posedge clk or negedge rst_n) begin
        if(rst_n == 1'b0)begin
            ifid_pc_o <= 32'h0;
            Ifid_PC_Buffer <= 32'h0;
        end
        else if(fc_bk_ifid_i == 1'b1) begin
            ifid_pc_o <= Ifid_PC_Buffer;             //back
            Ifid_PC_Buffer <= Ifid_PC_Buffer;     //keep
        end 
        else if(fc_flush_ifid_i == 1'b1) begin
            ifid_pc_o <= 32'h0;
            Ifid_PC_Buffer <= 32'h0;
        end
        else begin 
            ifid_pc_o <= if_pc_i;
            Ifid_PC_Buffer <= ifid_pc_o;
        end
    end



endmodule