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
`define NO_OP   5'd31
//-------------------------------------------------

//RV32I/Itype_J - ALU_operation according to func3 
`define JALR    3'b000

//RV32I/Itype_L - ALU_operation according to func3 
`define LB      3'b000  //Load Byte 读取一个字节，经符号位扩展后写入寄存器
`define LH      3'b001
`define LW      3'b010
`define LBU     3'b100  //Load Byte， Unsigned 读取一个字节，经零扩展后写入寄存器
`define LHU     3'b101

//RV32I/Itype_A - ALU_operation according to func3 
`define ADDI    3'b000
`define SLTI    3'b010
`define SLTIU   3'b011
`define XORI    3'b100
`define ORI     3'b110
`define ANDI    3'b111
`define SLLI    3'b001
`define SRLI_SRAI    3'b101

//-----according to func7
`define SRLI    7'b0000000
`define SRAI    7'b0100000 

//-------------------------------------------------

//RV32I/Btype - ALU_operation according to func3 
`define BEQ     3'b000
`define BNE     3'b001
`define BLT     3'b100
`define BGE     3'b101
`define BLTU    3'b110
`define BGEU    3'b111

//-------------------------------------------------

//RV32I/Stype - ALU_operation according to func3 
`define SB      3'b000  
`define SH      3'b001
`define SW      3'b010

//-------------------------------------------------

//RV32I/Rtype - ALU_operation according to func3 
`define ADD_SUB     3'b000
`define SLL     3'b001
`define SLT     3'b010
`define SLTU    3'b011
`define XOR     3'b100
`define SRL_SRA     3'b101
`define OR      3'b110
`define AND     3'b111

//-----according to func7
`define ADD    7'b0000000
`define SUB    7'b0100000
`define SRL    7'b0000000
`define SRA    7'b0100000