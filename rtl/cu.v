`include "define.v"


module cu (
    input   wire                    clk,
    input   wire                    rst_n,
    //from id
    input   wire            [6:0]   id_opcode_i,
    input   wire            [2:0]   id_func3_i,
    input   wire            [6:0]   id_func7_i,
    //to id_ex_reg
    output  wire            [4:0]   cu_ALUctrl_o
);                                                         //CU应该是组合逻辑


wire [6:0]  op_code = id_opcode_i;
wire [2:0]  func3   = id_func3_i;
wire [6:0]  func7   = id_func7_i;

//ALUCtrl Unit


    always @(*) begin
        case(op_code)
            `Itype_J:begin
                cu_ALUctrl_o = `ADD;
            end

            `Itype_L:begin
                cu_ALUctrl_o = `NO_OP;
            end

            `Itype_A:begin
                case(func3)
                    `ADDI:      cu_ALUctrl_o = `ADD;
                    `SLTI:      cu_ALUctrl_o = `SLT;
                    `SLTIU:     cu_ALUctrl_o = `SLT;
                    `XORI:      cu_ALUctrl_o = `XOR;
                    `ORI:       cu_ALUctrl_o = `OR;
                    `ANDI:      cu_ALUctrl_o = `AND;
                    `SLLI:      cu_ALUctrl_o = `SLL;
                    `SRLI_SRAI: begin
                        case(func7)
                            `SRLI:  cu_ALUctrl_o = `SRL;
                            `SRAI:  cu_ALUctrl_o = `SRA;
                            defualt:cu_ALUctrl_o = `NO_OP;
                        endcase
                    end
                    defualt:    cu_ALUctrl_o = `NO_OP;
                endcase
            end

            `Btype:begin
                case(func3)
                    `BEQ:       cu_ALUctrl_o = `EQU;
                    `BNE:       cu_ALUctrl_o = `NEQ;
                    `BLT:       cu_ALUctrl_o = `SLT;
                    `BGE:       cu_ALUctrl_o = `SGE;
                    `BLTU:      cu_ALUctrl_o = `SLTU;
                    `BGEU:      cu_ALUctrl_o = `SGEU;
                    defualt:    cu_ALUctrl_o = `NO_OP;
                endcase
            end

            `Rtype:begin
                case(func3)
                    `ADD_SUB: begin
                        case(func7)
                            `ADD:  cu_ALUctrl_o = `ADD;
                            `SUB:  cu_ALUctrl_o = `SUB;
                            defualt:cu_ALUctrl_o = `NO_OP;
                        endcase
                    end

                    `SLL:      cu_ALUctrl_o = `SLL;
                    `SLT:     cu_ALUctrl_o = `SLT;
                    `SLTU:      cu_ALUctrl_o = `SLT;
                    `XOR:       cu_ALUctrl_o = `XOR;
                    `SRL_SRA: begin
                        case(func7)
                            `SRLI:  cu_ALUctrl_o = `SRL;
                            `SRAI:  cu_ALUctrl_o = `SRA;
                            defualt:cu_ALUctrl_o = `NO_OP;
                        endcase
                    end

                    `OR:      cu_ALUctrl_o = `OR;
                    `AND:       cu_ALUctrl_o = `AND;
                    defualt:    cu_ALUctrl_o = `NO_OP;
                endcase
            end


        endcase
    end

