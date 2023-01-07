//inst_type according to opcode
`define Itype_J 7'b1100_111   //jalr
`define Itype_L 7'b0000_011   //load
`define Itype_A 7'b0010_011   //alu
`define Itype_F 7'b0001_111   //fence
`define Itype_C 7'b1110_011   //csr

`define Utype_L 7'b0110_111   //lui
`define Utype_A 7'b0010_111   //auipc

`define Jtype_J 7'b1101_111   //jal

`define Btype   7'b1100_011

`define Stype   7'b0100_011

`define Rtype   7'b0110_011
