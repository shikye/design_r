`include "define.v"
module cu (
    input   wire                    clk,
    input   wire                    rst_n,
    //from id
    input   wire            [6:0]   id_opcode_i,
    input   wire            [2:0]   id_func3_i,
    input   wire            [6:0]   id_func7_i,
    //to id_ex_reg
    output  reg             [4:0]   cu_ALUctrl_o,
    output  reg                     cu_reg_we_o,
    //to id
    output  reg                     cu_op_b_sel_o,
    //to dhnf
    output  reg                     cu_reg1_RE_o,
    output  reg                     cu_reg2_RE_o
);                                                      


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
                    `I_ADDI:      cu_ALUctrl_o = `ADD;
                    `I_SLTI:      cu_ALUctrl_o = `SLT;
                    `I_SLTIU:     cu_ALUctrl_o = `SLT;
                    `I_XORI:      cu_ALUctrl_o = `XOR;
                    `I_ORI:       cu_ALUctrl_o = `OR;
                    `I_ANDI:      cu_ALUctrl_o = `AND;
                    `I_SLLI:      cu_ALUctrl_o = `SLL;
                    `I_SRLI_SRAI: begin
                        case(func7)
                            `I_SRLI:  cu_ALUctrl_o = `SRL;
                            `I_SRAI:  cu_ALUctrl_o = `SRA;
                            default:cu_ALUctrl_o = `NO_OP;
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
                    `B_BEQ:       cu_ALUctrl_o = `EQU;
                    `B_BNE:       cu_ALUctrl_o = `NEQ;
                    `B_BLT:       cu_ALUctrl_o = `SLT;
                    `B_BGE:       cu_ALUctrl_o = `SGE;
                    `B_BLTU:      cu_ALUctrl_o = `SLTU;
                    `B_BGEU:      cu_ALUctrl_o = `SGEU;
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
                    `R_ADD_SUB: begin
                        case(func7)
                            `R_ADD:  cu_ALUctrl_o = `ADD;
                            `R_SUB:  cu_ALUctrl_o = `SUB;
                            default:cu_ALUctrl_o = `NO_OP;
                        endcase
                    end

                    `R_SLL:      cu_ALUctrl_o = `SLL;
                    `R_SLT:     cu_ALUctrl_o = `SLT;
                    `R_SLTU:      cu_ALUctrl_o = `SLT;
                    `R_XOR:       cu_ALUctrl_o = `XOR;
                    `R_SRL_SRA: begin
                        case(func7)
                            `R_SRL:  cu_ALUctrl_o = `SRL;
                            `R_SRA:  cu_ALUctrl_o = `SRA;
                            default:cu_ALUctrl_o = `NO_OP;
                        endcase
                    end

                    `R_OR:        cu_ALUctrl_o = `OR;
                    `R_AND:       cu_ALUctrl_o = `AND;
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




//op_b_sel 0-reg, 1-imm

    always @(*) begin
        case(op_code)
            
            `Itype_J,`Itype_L,`Itype_A,`Utype_A,`Utype_L,`Jtype_J,`Btype,`Stype:begin
                cu_op_b_sel_o = 1'b1;
            end
            
            default:cu_op_b_sel_o = 1'b0;
        endcase
    end


//cu_reg1_RE_o cu_reg2_RE_o 1-RE, 0-NRE

    always @(*) begin
        case(op_code)

            `Itype_J,`Itype_L,`Itype_A,`Btype,`Stype,`Rtype:begin
                cu_reg1_RE_o = 1'b1;
            end
            
            default:cu_reg1_RE_o = 1'b0;
        endcase
    end

    always @(*) begin
        case(op_code)

            `Btype,`Stype,`Rtype:begin
                cu_reg2_RE_o = 1'b1;
            end
            
            default:cu_reg2_RE_o = 1'b0;
        endcase
    end





endmodule
