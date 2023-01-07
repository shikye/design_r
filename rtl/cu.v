module cu (
    input   wire                    clk,
    input   wire                    rst_n,
    //from id
    input   wire            [6:0]   id_opcode_i,
    input   wire            [2:0]   id_func3_i,
    input   wire            [6:0]   id_func7_i,
    //to id_ex_reg
    output  wire                    cu_ALUctrl_o
);                                                         //CU应该是组合逻辑

    assign cu_ALUctrl_o = 
