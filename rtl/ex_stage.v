module ex_stage (
    input   wire                    clk,
    input   wire                    rst_n,
    //from id_ex_reg
    input   wire            [31:0]  id_ex_reg_op_a_i,
    input   wire            [31:0]  id_ex_reg_op_b_i,            
    input   wire            [4:0]   id_ex_reg_ALUctrl_i,
    input   wire            [4:0]   id_ex_reg_reg_waddr_i,
    input   wire                    id_ex_reg_reg_we_i,
    //to ex_mem_reg
    output  reg             [31:0]  ex_op_c_o,
    output  reg             [4:0]   ex_reg_waddr_o,
    output  reg                     ex_reg_we_o
);

    wire [31:0] op_a = id_ex_reg_op_a_i;
    wire [31:0] op_b = id_ex_reg_op_b_i;


    always @(*) begin
        case(id_ex_reg_ALUctrl_i)
            `ADD:   ex_op_c_o = op_a + op_b;
            `SUB:   ex_op_c_o = op_a - op_b;
            `EQU:   ex_op_c_o = (op_a ^ op_b == 32'h0) ? 32'b1 : 32'b0;
            `NEQ:   ex_op_c_o = (op_a ^ op_b == 32'h0) ? 32'b0 : 32'b1;
            `SLT:   ex_op_c_o = ($signed(op_a) < $signed(op_b)) ? 32'b1 : 32'b0;
            `SGE:   ex_op_c_o = ($signed(op_a) < $signed(op_b)) ? 32'b0 : 32'b1;
            `SLTU:  ex_op_c_o = ($unsigned(op_a) < $unsigned(op_b)) ? 32'b1 : 32'b0;
            `SGEU:  ex_op_c_o = ($unsigned(op_a) < $unsigned(op_b)) ? 32'b0 : 32'b1;
            `XOR:   ex_op_c_o = op_a ^ op_b;
            `OR:    ex_op_c_o = op_a | op_b;
            `SLL:   ex_op_c_o = op_a << op_b[4:0];
            `SRL:   ex_op_c_o = op_a >> op_b[4:0];
            `SRA:   ex_op_c_o = op_a >>> op_b[4:0];   
            `AND:   ex_op_c_o = op_a & op_b;         
            `NO_OP: ex_op_c_o = 32'h0;
            default:ex_op_c_o = 32'h0;
        endcase
    end


    always @(posedge clk or negedge rst_n)begin
        if(rst_n == 1'b0)begin
            ex_reg_waddr_o <= 5'h0;
        end
        else begin
            ex_reg_waddr_o <= id_ex_reg_reg_waddr_i;
        end
    end

    always @(posedge clk or negedge rst_n)begin
        if(rst_n == 1'b0)begin
            ex_reg_we_o <= 1'b0;
        end
        else begin
            ex_reg_we_o <= id_ex_reg_reg_we_i;
        end
    end

endmodule