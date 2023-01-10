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
    output  wire                    cu_reg_we_o
    
);                                                         //CU应该是组合逻辑


wire [6:0]  op_code = id_opcode_i;
wire [2:0]  func3   = id_func3_i;
wire [6:0]  func7   = id_func7_i;

//ALUCtrl Unit


    always @(*) begin
        case(op_code)
            `Itype_J:begin
                cu_ALUctrl_o = `ADD;
                cu_reg_we_o = 1'b1;
            end

            `Itype_L:begin
                cu_ALUctrl_o = `ADD;
                cu_reg_we_o = 1'b1;
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
                    default:    cu_ALUctrl_o = `NO_OP;
                endcase

                cu_reg_we_o = 1'b1;
            end

            `Itype_F:begin
                cu_ALUctrl_o = `NO_OP;
                cu_reg_we_o = 1'b0;
            end

            `Itype_C:begin
                cu_ALUctrl_o = `NO_OP;
                cu_reg_we_o = 1'b0;
            end

            `Utype_L:begin
                cu_ALUctrl_o = `ADD;
                cu_reg_we_o = 1'b1;
            end

            `Utype_A:begin
                cu_ALUctrl_o = `ADD;
                cu_reg_we_o = 1'b1;
            end

            `Jtype_J:begin
                cu_ALUctrl_o = `ADD;
                cu_reg_we_o = 1'b1;
            end

            `Btype:begin
                case(func3)
                    `BEQ:       cu_ALUctrl_o = `EQU;
                    `BNE:       cu_ALUctrl_o = `NEQ;
                    `BLT:       cu_ALUctrl_o = `SLT;
                    `BGE:       cu_ALUctrl_o = `SGE;
                    `BLTU:      cu_ALUctrl_o = `SLTU;
                    `BGEU:      cu_ALUctrl_o = `SGEU;
                    default:    cu_ALUctrl_o = `NO_OP;
                endcase

                cu_reg_we_o = 1'b0;
            end

            `Stype:begin
                cu_ALUctrl_o = `ADD;
                cu_reg_we_o = 1'b0;
            end

            `Rtype:begin
                case(func3)
                    `ADD_SUB: begin
                        case(func7)
                            `ADD:  cu_ALUctrl_o = `ADD;
                            `SUB:  cu_ALUctrl_o = `SUB;
                            default:cu_ALUctrl_o = `NO_OP;
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
                            default:cu_ALUctrl_o = `NO_OP;
                        endcase
                    end

                    `OR:        cu_ALUctrl_o = `OR;
                    `AND:       cu_ALUctrl_o = `AND;
                    default:    cu_ALUctrl_o = `NO_OP;
                endcase

                cu_reg_we_o = 1'b1;
            end

        default:begin
            cu_ALUctrl_o = `NO_OP;
            cu_reg_we_o  = 1'b0;
        end
        endcase
    end

