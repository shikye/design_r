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

`define Notype  7'b0000_000

//-------------------------------------------------

//ALUctrl operations
`define ADD     5'd0
`define SUB     5'd1
`define MUL     5'd2
`define DIV     5'd3
`define REM     5'd4
`define EQU     5'd5
`define NEQ     5'd6
`define SLT     5'd7 //Set Less Than
`define SGE     5'd8
`define SLTU    5'd9
`define SGEU    5'd10
`define XOR     5'd11
`define OR      5'd12
`define SLL     5'd13
`define SRL     5'd14
`define SRA     5'd15
`define AND     5'd16
`define NO_OP   5'd31
//-------------------------------------------------

//RV32I/Itype_J - ALU_operation according to func3 
`define I_JALR    3'b000

//RV32I/Itype_L - ALU_operation according to func3 
`define I_LB      3'b000  //Load Byte 读取�?个字节，经符号位扩展后写入寄存器
`define I_LH      3'b001
`define I_LW      3'b010
`define I_LBU     3'b100  //Load Byte�? Unsigned 读取�?个字节，经零扩展后写入寄存器
`define I_LHU     3'b101

//RV32I/Itype_A - ALU_operation according to func3 
`define I_ADDI    3'b000
`define I_SLTI    3'b010
`define I_SLTIU   3'b011
`define I_XORI    3'b100
`define I_ORI     3'b110
`define I_ANDI    3'b111
`define I_SLLI    3'b001
`define I_SRLI_SRAI    3'b101

//-----according to func7
`define I_SRLI    7'b0000000
`define I_SRAI    7'b0100000 

//-------------------------------------------------

//RV32I/Btype - ALU_operation according to func3 
`define B_BEQ     3'b000
`define B_BNE     3'b001
`define B_BLT     3'b100
`define B_BGE     3'b101
`define B_BLTU    3'b110
`define B_BGEU    3'b111

//-------------------------------------------------

//RV32I/Stype - ALU_operation according to func3 
`define S_SB      3'b000  
`define S_SH      3'b001
`define S_SW      3'b010

//-------------------------------------------------

//RV32I/Rtype - ALU_operation according to func3 
`define R_ADD_SUB     3'b000
`define R_SLL     3'b001
`define R_SLT     3'b010
`define R_SLTU    3'b011
`define R_XOR     3'b100
`define R_SRL_SRA     3'b101
`define R_OR      3'b110
`define R_AND     3'b111

//-----according to func7
`define R_ADD    7'b0000000
`define R_SUB    7'b0100000
`define R_SRL    7'b0000000
`define R_SRA    7'b0100000