`include "define.v"
module eximm(
    //from id
    input   wire            [31:0]  id_inst_i,
    //to id
    output  wire            [31:0]  eximm_eximm_o
);

    wire [6:0]  opcode = id_inst_i[6:0];

    always @(*) begin
        case(opcode)
            `Utype_A,`Utype_L:begin
                eximm_eximm_o = {id_inst_i[31:12] , {12{1'b0}}};
            end
            `Itype_J,`Itype_L,`Itype_A:begin
                eximm_eximm_o = { {20{id_inst_i[11]}} , id_inst_i[11:0]}
            end
            default:eximm_eximm_o = 32'h0;
        endcase
    end


endmodule