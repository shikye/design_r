module ex_stage (
    input   wire                    clk,
    input   wire                    rst_n,
    //from id_ex_reg
    input   wire            [31:0]  id_ex_reg_op_a_i,
    input   wire            [31:0]  id_ex_reg_op_b_i,            
    input   wire            [4:0]   id_ex_reg_ALUctrl_i,
    input   wire            [4:0]   id_ex_reg_reg_waddr_i,
    input   wire                    id_ex_reg_reg_we_i,

    input   wire                    id_ex_reg_btype_i,
    input   wire            [31:0]  id_ex_reg_next_pc_i,
    //to ex_mem_reg
    output  reg             [31:0]  ex_op_c_o,
    output  wire            [4:0]   ex_reg_waddr_o,
    output  wire                    ex_reg_we_o,
    //to fnb
    output  wire                    ex_branch_o,
    //to pc
    output  wire            [31:0]  ex_next_pc_o,
    //to id
    output  wire                    ex_ins_flush_o
);

    wire [31:0] op_a = id_ex_reg_op_a_i;
    wire [31:0] op_b = id_ex_reg_op_b_i;

    reg  [31:0] op_c_buff;

    always @(*) begin
        case(id_ex_reg_ALUctrl_i)
            `ADD:   ex_op_c_o = op_a + op_b;
            `SUB:   ex_op_c_o = op_a - op_b;
            `EQU:   ex_op_c_o = ((op_a ^ op_b) == 32'h0) ? 32'b1 : 32'b0;
            `NEQ:   ex_op_c_o = ((op_a ^ op_b) == 32'h0) ? 32'b0 : 32'b1;
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

    assign ex_reg_waddr_o = id_ex_reg_reg_waddr_i;

    assign ex_reg_we_o = id_ex_reg_reg_we_i;

    assign ex_branch_o = ex_op_c_o && id_ex_reg_btype_i; 
    //when op == 1 && is a branch inst
    assign ex_ins_flush_o = ex_op_c_o && id_ex_reg_btype_i; 

    assign ex_next_pc_o = id_ex_reg_next_pc_i;
    
    

endmodule