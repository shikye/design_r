//2way 8-set,Cache_line:16 line
//Cache_Block:16Byte
//Cache Memory Mapping:| Tag | Index | Block Offset | Byte Offset      --Byte Offset:Used by write, like sh.        
//                       25       3          2             2     
//                                                            

//Tag Unit:|Valid|Dirty|Replace|Tag|
//            1     1      1    25


//write back and write allocate


module Dcache(
    input   wire                    clk,
    input   wire                    rst_n,

    //from mem
    input   wire                    mem_rw_i, //0-w,1-r
    input   wire                    mem_req_Dcache_i,  //include read and write req

    input   wire            [31:0]  mem_addr_i,  //include read addr and write addr
    input   wire            [1:0]   mem_wrwidth_i, //write width
                                                   //    0               1                            2                            3                                 
                                                   //  none     31:8--0 7:0--valid data      31:16--0 15:0--valid data      31:0--valid data       
    
    input   wire            [31:0]  mem_wr_data_i,       //write:1,2,4byte
    
    //to mem
    output  reg             [31:0]  Dcache_data_o,   //read:4byte each time

    //to fc
    output  reg                     Dcache_ready_o,   //read out valid or write over
    output  wire                    Dcache_hit_o,

    //to ram
    output  reg                     Dcache_rd_req_o, 
    output  reg             [31:0]  Dcache_rd_addr_o,

    
    output  reg                     Dcache_wb_req_o,  //write back
    output  reg             [31:0]  Dcache_wb_addr_o,
    output  reg             [127:0] Dcache_wb_data_o,


    //from ram
    input   wire            [127:0] ram_data_i,
    input   wire                    ram_ready_i
);

//FSM
localparam Idle_or_Compare_Tag = 0;
localparam Write_Back          = 1;
localparam Read_from_Ram       = 2;
//Idle_or_Compare_Tag:
//1.Idle
//2.Read Hit:ready
//3.Write Hit:ready, Dirty
//4.Read Miss:not ready, choose a victim, and buffer for Block offset、
//Byte offset、Index、Tag, 
//set Ram_req <= 1, if has a clean --to Read_from_Ram
//if no clean --to Write_Back
//4.Read Miss:not ready, choose a victim, and buffer for Block offset、
//Byte offset、Index、Tag, 
//set Ram_req <= 1, if has a clean --to Read_from_Ram
//if no clean --to Write_Back


//Write_Back
//Write victim back to Ram, and wait for ready, then to Read_from_Mem

//Read_from_Ram
//set valid, change replace
//1.Read Miss:Read from Ram, set Dirty = 0
//2.1Write Miss and clean:Read from Ram
//2.2Write Miss and dirty:Write back and read from ram


reg [1:0] cur_state;


//bit position mapping
localparam Tag_Width = 25 - 1;
localparam Valid     = 27;
localparam Dirty     = 26;
localparam Replace   = 25;

//Data_Block and Tag_Array
reg [127:0] Dcache_Data_Block [0:15];
reg [27:0]  Dcache_Tag_Array  [0:15];

//Mapping Decord   --from the addr
wire [24:0] Dcache_Tag      = mem_addr_i[31:7];
wire [3:0]  Dcache_Index    = {{1'b0},mem_addr_i[6:4]};
wire [1:0]  Dcache_Block_Off      = mem_addr_i[3:2];
wire [1:0]  Dcache_Byte_Off       = mem_addr_i[1:0];


//when in Read_from_Mem, still need old parameter
reg [24:0]  Tag_Buffer;
reg [3:0]   Index_Buffer;
reg [1:0]   Block_Off_Buffer;
reg [1:0]   Byte_Off_Buffer;
reg [1:0]   Rd_Width_Buffer;
reg         rw_Buffer;
reg [31:0]  Mem_Data_Buffer;


//hit  2ways
wire [1:0]  Dcache_Tag_Hit;   //for right-now inst
assign Dcache_Tag_Hit[0] = ( (Dcache_Tag == Dcache_Tag_Array[Dcache_Index << 1][Tag_Width:0]) 
                        && Dcache_Tag_Array[Dcache_Index << 1][Valid] == 1'b1 );
assign Dcache_Tag_Hit[1] = ( (Dcache_Tag == Dcache_Tag_Array[(Dcache_Index << 1) + 1][Tag_Width:0]) 
                        && Dcache_Tag_Array[(Dcache_Index << 1) + 1][Valid] == 1'b1 );

assign Dcache_hit_o               = (Dcache_Tag_Hit != 2'b00);

//replace number
reg    victim_number;



//initial
always @(*) begin
    if(rst_n == 1'b0) begin
        Dcache_Tag_Array[0]    = 28'h0;
        Dcache_Tag_Array[1]    = 28'h0;
        Dcache_Tag_Array[2]    = 28'h0;
        Dcache_Tag_Array[3]    = 28'h0;
        Dcache_Tag_Array[4]    = 28'h0;
        Dcache_Tag_Array[5]    = 28'h0;
        Dcache_Tag_Array[6]    = 28'h0;
        Dcache_Tag_Array[7]    = 28'h0;
        Dcache_Tag_Array[8]    = 28'h0;
        Dcache_Tag_Array[9]    = 28'h0;
        Dcache_Tag_Array[10]   = 28'h0;
        Dcache_Tag_Array[11]   = 28'h0;
        Dcache_Tag_Array[12]   = 28'h0;
        Dcache_Tag_Array[13]   = 28'h0;
        Dcache_Tag_Array[14]   = 28'h0;
        Dcache_Tag_Array[15]   = 28'h0;

    end
end


//FSM
always @ (posedge clk or negedge rst_n)begin   //the key judge conditions

    if(rst_n == 1'b0) begin
        Dcache_data_o <= 32'h0;

        Dcache_ready_o <= 1'b0;

        Dcache_rd_req_o <= 1'b0;
        Dcache_rd_addr_o <= 32'h0;

        Dcache_wb_req_o <= 1'b0;
        Dcache_wb_addr_o <= 32'h0;
        Dcache_wb_data_o <= 128'h0;   


        cur_state <= Idle_or_Compare_Tag;
    end

    else begin
        case(cur_state)

            Idle_or_Compare_Tag:begin
                
                if(mem_req_Dcache_i == 1'b1) begin

                    if(Dcache_hit_o == 1'b1)begin   //write hit or read hit

                        cur_state <= Idle_or_Compare_Tag;
                        Dcache_ready_o <= 1'b1;                //ready

                        Dcache_wb_req_o <= 1'b0;
                        Dcache_rd_req_o <= 1'b0;

                        case(mem_rw_i)
                            1'b0:begin  //write hit. 1.replace 2.dirty
                                if(Dcache_Tag_Hit[0] == 1'b1) begin //way0


                                    Dcache_Tag_Array[Dcache_Index << 1][Replace] <= 1'b0;
                                    Dcache_Tag_Array[(Dcache_Index << 1) + 1][Replace] <= 1'b1;

                                    Dcache_Tag_Array[Dcache_Index << 1][Dirty] <= 1'b1;


                                    case(Dcache_Block_Off)
                                        2'b00:begin
                                            case(mem_wrwidth_i)  //how many byte need to write
                                                2'd1:begin
                                                    case(Dcache_Byte_Off)
                                                        2'b00:Dcache_Data_Block[Dcache_Index << 1][7:0] <= mem_wr_data_i[7:0];
                                                        2'b01:Dcache_Data_Block[Dcache_Index << 1][15:8] <= mem_wr_data_i[7:0];
                                                        2'b10:Dcache_Data_Block[Dcache_Index << 1][23:16] <= mem_wr_data_i[7:0];
                                                        2'b11:Dcache_Data_Block[Dcache_Index << 1][31:24] <= mem_wr_data_i[7:0];
                                                        default:;
                                                    endcase
                                                end

                                                2'd2:begin
                                                    case(Dcache_Byte_Off)   //有对齐要求
                                                        2'b00:Dcache_Data_Block[Dcache_Index << 1][15:0] <= mem_wr_data_i[15:0];
                                                        2'b10:Dcache_Data_Block[Dcache_Index << 1][31:16] <= mem_wr_data_i[15:0];
                                                        default:;
                                                    endcase
                                                end

                                                2'd3:Dcache_Data_Block[Dcache_Index << 1][31:0] <= mem_wr_data_i;

                                                default:;
                                            endcase
                                        end

                                        2'b01:begin
                                            case(mem_wrwidth_i)  //how many byte need to write
                                                2'd1:begin
                                                    case(Dcache_Byte_Off)
                                                        2'b00:Dcache_Data_Block[Dcache_Index << 1][39:32] <= mem_wr_data_i[7:0];
                                                        2'b01:Dcache_Data_Block[Dcache_Index << 1][47:40] <= mem_wr_data_i[7:0];
                                                        2'b10:Dcache_Data_Block[Dcache_Index << 1][55:48] <= mem_wr_data_i[7:0];
                                                        2'b11:Dcache_Data_Block[Dcache_Index << 1][63:56] <= mem_wr_data_i[7:0];
                                                        default:;
                                                    endcase
                                                end

                                                2'd2:begin
                                                    case(Dcache_Byte_Off)   //有对齐要求
                                                        2'b00:Dcache_Data_Block[Dcache_Index << 1][47:32] <= mem_wr_data_i[15:0];
                                                        2'b10:Dcache_Data_Block[Dcache_Index << 1][63:48] <= mem_wr_data_i[15:0];
                                                        default:;
                                                    endcase
                                                end

                                                2'd3:Dcache_Data_Block[Dcache_Index << 1][63:32] <= mem_wr_data_i;

                                                default:;
                                            endcase
                                        end

                                        2'b10:begin
                                            case(mem_wrwidth_i)  //how many byte need to write
                                                2'd1:begin
                                                    case(Dcache_Byte_Off)
                                                        2'b00:Dcache_Data_Block[Dcache_Index << 1][71:64] <= mem_wr_data_i[7:0];
                                                        2'b01:Dcache_Data_Block[Dcache_Index << 1][79:72] <= mem_wr_data_i[7:0];
                                                        2'b10:Dcache_Data_Block[Dcache_Index << 1][87:80] <= mem_wr_data_i[7:0];
                                                        2'b11:Dcache_Data_Block[Dcache_Index << 1][95:88] <= mem_wr_data_i[7:0];
                                                        default:;
                                                    endcase
                                                end

                                                2'd2:begin
                                                    case(Dcache_Byte_Off)   //有对齐要求
                                                        2'b00:Dcache_Data_Block[Dcache_Index << 1][79:64] <= mem_wr_data_i[15:0];
                                                        2'b10:Dcache_Data_Block[Dcache_Index << 1][95:80] <= mem_wr_data_i[15:0];
                                                        default:;
                                                    endcase
                                                end

                                                2'd3:Dcache_Data_Block[Dcache_Index << 1][95:64] <= mem_wr_data_i;

                                                default:;
                                            endcase
                                        end

                                        2'b11:begin
                                            case(mem_wrwidth_i)  //how many byte need to write
                                                2'd1:begin
                                                    case(Dcache_Byte_Off)
                                                        2'b00:Dcache_Data_Block[Dcache_Index << 1][103:96] <= mem_wr_data_i[7:0];
                                                        2'b01:Dcache_Data_Block[Dcache_Index << 1][111:104] <= mem_wr_data_i[7:0];
                                                        2'b10:Dcache_Data_Block[Dcache_Index << 1][119:112] <= mem_wr_data_i[7:0];
                                                        2'b11:Dcache_Data_Block[Dcache_Index << 1][127:120] <= mem_wr_data_i[7:0];
                                                        default:;
                                                    endcase
                                                end

                                                2'd2:begin
                                                    case(Dcache_Byte_Off)   //有对齐要求
                                                        2'b00:Dcache_Data_Block[Dcache_Index << 1][111:96] <= mem_wr_data_i[15:0];
                                                        2'b10:Dcache_Data_Block[Dcache_Index << 1][127:112] <= mem_wr_data_i[15:0];
                                                        default:;
                                                    endcase
                                                end

                                                2'd3:Dcache_Data_Block[Dcache_Index << 1][127:96] <= mem_wr_data_i;

                                                default:;
                                            endcase
                                        end

                                        default:;
                                    endcase
                                end

                                else begin   //way1


                                    Dcache_Tag_Array[Dcache_Index << 1][Replace] <= 1'b1;
                                    Dcache_Tag_Array[(Dcache_Index << 1) + 1][Replace] <= 1'b0;

                                    Dcache_Tag_Array[(Dcache_Index << 1) + 1][Dirty] <= 1'b1;


                                    case(Dcache_Block_Off)
                                        2'b00:begin
                                            case(mem_wrwidth_i)  //how many byte need to write
                                                2'd1:begin
                                                    case(Dcache_Byte_Off)
                                                        2'b00:Dcache_Data_Block[(Dcache_Index << 1) + 1][7:0] <= mem_wr_data_i[7:0];
                                                        2'b01:Dcache_Data_Block[(Dcache_Index << 1) + 1][15:8] <= mem_wr_data_i[7:0];
                                                        2'b10:Dcache_Data_Block[(Dcache_Index << 1) + 1][23:16] <= mem_wr_data_i[7:0];
                                                        2'b11:Dcache_Data_Block[(Dcache_Index << 1) + 1][31:24] <= mem_wr_data_i[7:0];
                                                        default:;
                                                    endcase
                                                end

                                                2'd2:begin
                                                    case(Dcache_Byte_Off)   //有对齐要求
                                                        2'b00:Dcache_Data_Block[(Dcache_Index << 1) + 1][15:0] <= mem_wr_data_i[15:0];
                                                        2'b10:Dcache_Data_Block[(Dcache_Index << 1) + 1][31:16] <= mem_wr_data_i[15:0];
                                                        default:;
                                                    endcase
                                                end

                                                2'd3:Dcache_Data_Block[(Dcache_Index << 1) + 1][31:0] <= mem_wr_data_i;

                                                default:;
                                            endcase
                                        end

                                        2'b01:begin
                                            case(mem_wrwidth_i)  //how many byte need to write
                                                2'd1:begin
                                                    case(Dcache_Byte_Off)
                                                        2'b00:Dcache_Data_Block[(Dcache_Index << 1) + 1][39:32] <= mem_wr_data_i[7:0];
                                                        2'b01:Dcache_Data_Block[(Dcache_Index << 1) + 1][47:40] <= mem_wr_data_i[7:0];
                                                        2'b10:Dcache_Data_Block[(Dcache_Index << 1) + 1][55:48] <= mem_wr_data_i[7:0];
                                                        2'b11:Dcache_Data_Block[(Dcache_Index << 1) + 1][63:56] <= mem_wr_data_i[7:0];
                                                        default:;
                                                    endcase
                                                end

                                                2'd2:begin
                                                    case(Dcache_Byte_Off)   //有对齐要求
                                                        2'b00:Dcache_Data_Block[(Dcache_Index << 1) + 1][47:32] <= mem_wr_data_i[15:0];
                                                        2'b10:Dcache_Data_Block[(Dcache_Index << 1) + 1][63:48] <= mem_wr_data_i[15:0];
                                                        default:;
                                                    endcase
                                                end

                                                2'd3:Dcache_Data_Block[(Dcache_Index << 1) + 1][63:32] <= mem_wr_data_i;

                                                default:;
                                            endcase
                                        end

                                        2'b10:begin
                                            case(mem_wrwidth_i)  //how many byte need to write
                                                2'd1:begin
                                                    case(Dcache_Byte_Off)
                                                        2'b00:Dcache_Data_Block[(Dcache_Index << 1) + 1][71:64] <= mem_wr_data_i[7:0];
                                                        2'b01:Dcache_Data_Block[(Dcache_Index << 1) + 1][79:72] <= mem_wr_data_i[7:0];
                                                        2'b10:Dcache_Data_Block[(Dcache_Index << 1) + 1][87:80] <= mem_wr_data_i[7:0];
                                                        2'b11:Dcache_Data_Block[(Dcache_Index << 1) + 1][95:88] <= mem_wr_data_i[7:0];
                                                        default:;
                                                    endcase
                                                end

                                                2'd2:begin
                                                    case(Dcache_Byte_Off)   //有对齐要求
                                                        2'b00:Dcache_Data_Block[(Dcache_Index << 1) + 1][79:64] <= mem_wr_data_i[15:0];
                                                        2'b10:Dcache_Data_Block[(Dcache_Index << 1) + 1][95:80] <= mem_wr_data_i[15:0];
                                                        default:;
                                                    endcase
                                                end

                                                2'd3:Dcache_Data_Block[(Dcache_Index << 1) + 1][95:64] <= mem_wr_data_i;

                                                default:;
                                            endcase
                                        end

                                        2'b11:begin
                                            case(mem_wrwidth_i)  //how many byte need to write
                                                2'd1:begin
                                                    case(Dcache_Byte_Off)
                                                        2'b00:Dcache_Data_Block[(Dcache_Index << 1) + 1][103:96] <= mem_wr_data_i[7:0];
                                                        2'b01:Dcache_Data_Block[(Dcache_Index << 1) + 1][111:104] <= mem_wr_data_i[7:0];
                                                        2'b10:Dcache_Data_Block[(Dcache_Index << 1) + 1][119:112] <= mem_wr_data_i[7:0];
                                                        2'b11:Dcache_Data_Block[(Dcache_Index << 1) + 1][127:120] <= mem_wr_data_i[7:0];
                                                        default:;
                                                    endcase
                                                end

                                                2'd2:begin
                                                    case(Dcache_Byte_Off)   //有对齐要求
                                                        2'b00:Dcache_Data_Block[(Dcache_Index << 1) + 1][111:96] <= mem_wr_data_i[15:0];
                                                        2'b10:Dcache_Data_Block[(Dcache_Index << 1) + 1][127:112] <= mem_wr_data_i[15:0];
                                                        default:;
                                                    endcase
                                                end

                                                2'd3:Dcache_Data_Block[(Dcache_Index << 1) + 1][127:96] <= mem_wr_data_i;

                                                default:;
                                            endcase
                                        end

                                        default:;
                                    endcase

                                end
                            end

                            1'b1:begin //read hit. 1.replace
                                if(Dcache_Tag_Hit[0] == 1'b1) begin //way0
                                    case(Dcache_Block_Off)
                                        2'b00:Dcache_data_o <= Dcache_Data_Block[Dcache_Index << 1][31:0];
                                        2'b01:Dcache_data_o <= Dcache_Data_Block[Dcache_Index << 1][63:32];
                                        2'b10:Dcache_data_o <= Dcache_Data_Block[Dcache_Index << 1][95:64];
                                        2'b11:Dcache_data_o <= Dcache_Data_Block[Dcache_Index << 1][127:96];
                                        default:Dcache_data_o <= 32'h0;
                                    endcase

                               
                                    Dcache_Tag_Array[Dcache_Index << 1][Replace] <= 1'b0;
                                    Dcache_Tag_Array[(Dcache_Index << 1) + 1][Replace] <= 1'b1;
                                end

                                else begin  //way1
                                    case(Dcache_Block_Off)
                                        2'b00:Dcache_data_o <= Dcache_Data_Block[(Dcache_Index << 1) + 1][31:0];
                                        2'b01:Dcache_data_o <= Dcache_Data_Block[(Dcache_Index << 1) + 1][63:32];
                                        2'b10:Dcache_data_o <= Dcache_Data_Block[(Dcache_Index << 1) + 1][95:64];
                                        2'b11:Dcache_data_o <= Dcache_Data_Block[(Dcache_Index << 1) + 1][127:96];
                                        default:Dcache_data_o <= 32'h0;
                                    endcase

                                
                                    Dcache_Tag_Array[Dcache_Index << 1][Replace] <= 1'b1;
                                    Dcache_Tag_Array[(Dcache_Index << 1) + 1][Replace] <= 1'b0;
                                end

                            end

                            default:;

                        endcase

                    end

                    else begin   //miss --need to choose a victim according to replace,clean prior
                        Dcache_ready_o <= 1'b0;

                        //for Read_from_Ram
                        Tag_Buffer <= Dcache_Tag;
                        Index_Buffer <= Dcache_Index;
                        Block_Off_Buffer <= Dcache_Block_Off;
                        Byte_Off_Buffer <= Dcache_Byte_Off;
                        rw_Buffer <= mem_rw_i;      
                        Mem_Data_Buffer <= mem_wr_data_i;             

                        
                        //no matter write or read

                        case( {Dcache_Tag_Array[(Dcache_Index << 1) + 1][Dirty], Dcache_Tag_Array[Dcache_Index << 1][Dirty]} )
                        
                            2'b00:begin //all clean --choose way0

                                cur_state <= Read_from_Ram;
                                victim_number <= 1'b0;

                                Dcache_rd_req_o <= 1'b1;
                                Dcache_rd_addr_o <= (mem_addr_i >> 4) << 4;

                                Dcache_wb_req_o <= 1'b0;

                            end

                            2'b01:begin
                                cur_state <= Read_from_Ram;
                                victim_number <= 1'b1;

                                Dcache_rd_req_o <= 1'b1;
                                Dcache_rd_addr_o <= (mem_addr_i >> 4) << 4;

                                Dcache_wb_req_o <= 1'b0;

                            end

                            2'b10:begin
                                cur_state <= Read_from_Ram;
                                victim_number <= 1'b0;

                                Dcache_rd_req_o <= 1'b1;
                                Dcache_rd_addr_o <= (mem_addr_i >> 4) << 4;

                                Dcache_wb_req_o <= 1'b0;
                                
                            end

                            2'b11:begin
                                cur_state <= Write_Back;

                                Dcache_rd_req_o <= 1'b0;
                                Dcache_rd_addr_o <= (mem_addr_i >> 4) << 4;
                                
                                Dcache_wb_req_o <= 1'b1;

                                case( {Dcache_Tag_Array[(Dcache_Index << 1) + 1][Replace],Dcache_Tag_Array[Dcache_Index << 1][Replace]} )
                                            
                                    //repalce :00 -> 10, write 0
                                    2'b00:begin
                                        victim_number = 0;

                                        Dcache_wb_addr_o = {Dcache_Tag_Array[Dcache_Index << 1][Tag_Width:0], 
                                                Dcache_Index[2:0], {4{1'b0}}  };
                                    end

                                    2'b01:begin
                                        victim_number = 0;

                                        Dcache_wb_addr_o = {Dcache_Tag_Array[Dcache_Index << 1][Tag_Width:0], 
                                                Dcache_Index[2:0], {4{1'b0}}  };
                                    end

                                    2'b10:begin
                                        victim_number = 1;

                                        Dcache_wb_addr_o = {Dcache_Tag_Array[(Dcache_Index << 1) + 1][Tag_Width:0], 
                                                Dcache_Index[2:0], {4{1'b0}}  };
                                    end

                                    default:begin
                                        victim_number = 0;
                                        Dcache_wb_addr_o =32'h0;
                                    end

                                endcase  

                            end
                        
                        
                        endcase


                    end

                    
                end
                
                else begin        
                    Dcache_ready_o <= 1'b0;

                    Dcache_rd_req_o <= 1'b0;
                    Dcache_wb_req_o <= 1'b0;
        
                    cur_state <= Idle_or_Compare_Tag;
                end
                
            end

            Write_Back:begin
                Dcache_ready_o <= 1'b0;
                Dcache_wb_req_o <= 1'b0;
                
                if(ram_ready_i == 1'b1) begin
                    cur_state <= Read_from_Ram;

                    Dcache_rd_req_o <= 1'b1;
                    Dcache_rd_addr_o <= { Tag_Buffer, Index_Buffer, {4{1'b0}} };
                end
                else begin
                    cur_state <= Write_Back;
                end
            end

            Read_from_Ram:begin

                Dcache_rd_req_o <= 1'b0;

                if(ram_ready_i == 1'b1) begin //change Valid, Dirty, Replace, AND Tag

                    Dcache_Data_Block[(Index_Buffer << 1) + victim_number] = ram_data_i;
                    Dcache_Tag_Array[(Index_Buffer << 1) + victim_number][Valid] = 1'b1;

                    Dcache_ready_o <= 1'b1;

                    cur_state <= Idle_or_Compare_Tag;

                    if(victim_number == 1'b0) begin
                        Dcache_Tag_Array[Index_Buffer << 1][Replace] <= 1'b0;
                        Dcache_Tag_Array[(Index_Buffer << 1) + 1][Replace] <= 1'b1;

                        Dcache_Tag_Array[Index_Buffer << 1][Tag_Width:0] <= Tag_Buffer;
                    end
                    else begin
                        Dcache_Tag_Array[Index_Buffer << 1][Replace] <= 1'b1;
                        Dcache_Tag_Array[(Index_Buffer << 1) + 1][Replace] <= 1'b0;

                        Dcache_Tag_Array[(Index_Buffer << 1) + 1][Tag_Width:0] <= Tag_Buffer;
                    end

                    case(rw_Buffer) 
                        1'b0:begin //write cache

                            Dcache_Tag_Array[(Index_Buffer << 1) + victim_number][Dirty] = 1'b1;


                            case(Dcache_Block_Off)
                                2'b00:begin
                                    case(Rd_Width_Buffer)  //how many byte need to write
                                        2'd1:begin
                                            case(Dcache_Byte_Off)
                                                2'b00:Dcache_Data_Block[(Index_Buffer << 1) + victim_number][7:0] = Mem_Data_Buffer[7:0];
                                                2'b01:Dcache_Data_Block[(Index_Buffer << 1) + victim_number][15:8] = Mem_Data_Buffer[7:0];
                                                2'b10:Dcache_Data_Block[(Index_Buffer << 1) + victim_number][23:16] = Mem_Data_Buffer[7:0];
                                                2'b11:Dcache_Data_Block[(Index_Buffer << 1) + victim_number][31:24] = Mem_Data_Buffer[7:0];
                                                default:;
                                            endcase
                                        end

                                        2'd2:begin
                                            case(Dcache_Byte_Off)   //有对齐要求
                                                2'b00:Dcache_Data_Block[(Index_Buffer << 1) + victim_number][15:0] = Mem_Data_Buffer[15:0];
                                                2'b10:Dcache_Data_Block[(Index_Buffer << 1) + victim_number][31:16] = Mem_Data_Buffer[15:0];
                                                default:;
                                            endcase
                                        end

                                        2'd3:Dcache_Data_Block[(Index_Buffer << 1) + victim_number][31:0] = Mem_Data_Buffer;

                                        default:;
                                    endcase
                                end

                                2'b01:begin
                                    case(Rd_Width_Buffer)  //how many byte need to write
                                        2'd1:begin
                                            case(Dcache_Byte_Off)
                                                2'b00:Dcache_Data_Block[(Index_Buffer << 1) + victim_number][39:32] = Mem_Data_Buffer[7:0];
                                                2'b01:Dcache_Data_Block[(Index_Buffer << 1) + victim_number][47:40] = Mem_Data_Buffer[7:0];
                                                2'b10:Dcache_Data_Block[(Index_Buffer << 1) + victim_number][55:48] = Mem_Data_Buffer[7:0];
                                                2'b11:Dcache_Data_Block[(Index_Buffer << 1) + victim_number][63:56] = Mem_Data_Buffer[7:0];
                                                default:;
                                            endcase
                                        end

                                        2'd2:begin
                                            case(Dcache_Byte_Off)   //有对齐要求
                                                2'b00:Dcache_Data_Block[(Index_Buffer << 1) + victim_number][47:32] = Mem_Data_Buffer[15:0];
                                                2'b10:Dcache_Data_Block[(Index_Buffer << 1) + victim_number][63:48] = Mem_Data_Buffer[15:0];
                                                default:;
                                            endcase
                                        end

                                        2'd3:Dcache_Data_Block[(Index_Buffer << 1) + victim_number][63:32] = Mem_Data_Buffer;

                                        default:;
                                    endcase
                                end

                                2'b10:begin
                                    case(Rd_Width_Buffer)  //how many byte need to write
                                        2'd1:begin
                                            case(Dcache_Byte_Off)
                                                2'b00:Dcache_Data_Block[(Index_Buffer << 1) + victim_number][71:64] = Mem_Data_Buffer[7:0];
                                                2'b01:Dcache_Data_Block[(Index_Buffer << 1) + victim_number][79:72] = Mem_Data_Buffer[7:0];
                                                2'b10:Dcache_Data_Block[(Index_Buffer << 1) + victim_number][87:80] = Mem_Data_Buffer[7:0];
                                                2'b11:Dcache_Data_Block[(Index_Buffer << 1) + victim_number][95:88] = Mem_Data_Buffer[7:0];
                                                default:;
                                            endcase
                                        end

                                        2'd2:begin
                                            case(Dcache_Byte_Off)   //有对齐要求
                                                2'b00:Dcache_Data_Block[(Index_Buffer << 1) + victim_number][79:64] = Mem_Data_Buffer[15:0];
                                                2'b10:Dcache_Data_Block[(Index_Buffer << 1) + victim_number][95:80] = Mem_Data_Buffer[15:0];
                                                default:;
                                            endcase
                                        end

                                        2'd3:Dcache_Data_Block[(Index_Buffer << 1) + victim_number][95:64] = Mem_Data_Buffer;

                                        default:;
                                    endcase
                                end

                                2'b11:begin
                                    case(Rd_Width_Buffer)  //how many byte need to write
                                        2'd1:begin
                                            case(Dcache_Byte_Off)
                                                2'b00:Dcache_Data_Block[(Index_Buffer << 1) + victim_number][103:96] = Mem_Data_Buffer[7:0];
                                                2'b01:Dcache_Data_Block[(Index_Buffer << 1) + victim_number][111:104] = Mem_Data_Buffer[7:0];
                                                2'b10:Dcache_Data_Block[(Index_Buffer << 1) + victim_number][119:112] = Mem_Data_Buffer[7:0];
                                                2'b11:Dcache_Data_Block[(Index_Buffer << 1) + victim_number][127:120] = Mem_Data_Buffer[7:0];
                                                default:;
                                            endcase
                                        end

                                        2'd2:begin
                                            case(Dcache_Byte_Off)   //有对齐要求
                                                2'b00:Dcache_Data_Block[(Index_Buffer << 1) + victim_number][111:96] = Mem_Data_Buffer[15:0];
                                                2'b10:Dcache_Data_Block[(Index_Buffer << 1) + victim_number][127:112] = Mem_Data_Buffer[15:0];
                                                default:;
                                            endcase
                                        end

                                        2'd3:Dcache_Data_Block[(Index_Buffer << 1) + victim_number][127:96] = Mem_Data_Buffer;

                                        default:;
                                    endcase
                                end

                                default:;
                            endcase

                        end

                        1'b1:begin//read cache
                            
                            Dcache_Tag_Array[(Index_Buffer << 1) + victim_number][Dirty] = 1'b0;

                            case(Block_Off_Buffer)
                                2'b00:Dcache_data_o <= ram_data_i[31:0];
                                2'b01:Dcache_data_o <= ram_data_i[63:32];
                                2'b10:Dcache_data_o <= ram_data_i[95:64];
                                2'b11:Dcache_data_o <= ram_data_i[127:96];
                                default:Dcache_data_o <= 32'h0;
                            endcase
                        end

                        default:;
                    endcase

                end

                else begin

                    Dcache_ready_o <= 1'b0;
                    cur_state <= Read_from_Ram;
                
                end
         
            end

            default:begin
                cur_state <= Idle_or_Compare_Tag;
                
                Dcache_ready_o <= 1'b0;
                Dcache_rd_req_o <= 1'b0;
                Dcache_wb_req_o <= 1'b0;

                victim_number <= 1'b0;
            end
        
        
        
        endcase


    end

end


endmodule









