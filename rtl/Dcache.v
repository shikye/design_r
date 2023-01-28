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

    input   wire            [31:0]  mem_addr_i,

    input   wire            [1:0]   mem_wrwidth_i, //write width
                                                   //    0               1                            2                            3                                 
                                                   //  none     31:8--0 7:0--valid data      31:16--0 15:0--valid data      31:0--valid data       
           

    input   wire            [31:0]  mem_data_i,       //write:1,2,4byte
    input   wire                    mem_valid_req_i,  //include read and write req
    //to mem
    output  reg             [31:0]  Dcache_data_o,   //read:4byte each time
    output  reg                     Dcache_ready_o,

    //to fc
    output  reg                     Dcache_pipe_stall_o,
    output  wire                    hit,

    //to ram
    output  reg                     Dcache_rw_o, //0-w,1-r
    output  reg             [127:0] Dcache_data_ram_o,


    output  reg             [31:0]  Dcache_waddr_o,

    output  reg             [31:0]  Dcache_req_addr_o,

    output  reg                     Dcache_valid_req_o,   //include read and write req
    //from ram
    input   wire            [127:0] ram_data_i,
    input   wire                    ram_ready_i
);

//FSM
localparam Idle_or_Compare_Tag = 0;
localparam Read_from_Ram       = 1;
//Idle_or_Compare_Tag:
//1.Idle
//2.Read Hit:no stall
//3.Write Hit:no stall, Dirty
//4.Read Miss:stall and transfer to Read_from_Ram
//5.Write Miss:stall and transfer to Read_from_Ram, Dirty

//Read_from_Ram
//1.Read Miss:Read from Ram
//2.1Write Miss and clean:Read from Ram
//2.2Write Miss and dirty:Write back and read from ram


reg cur_state;
reg next_state;


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


//hit  2ways
wire [1:0]  Dcache_Tag_Hit;
assign Dcache_Tag_Hit[0] = ( (Dcache_Tag == Dcache_Tag_Array[Dcache_Index << 1][Tag_Width:0]) 
                        && Dcache_Tag_Array[Dcache_Index << 1][Valid] == 1'b1 );
assign Dcache_Tag_Hit[1] = ( (Dcache_Tag == Dcache_Tag_Array[(Dcache_Index << 1) + 1][Tag_Width:0]) 
                        && Dcache_Tag_Array[(Dcache_Index << 1) + 1][Valid] == 1'b1 );

assign hit               = (Dcache_Tag_Hit != 2'b00);

//replace number
reg    victim_number;

//write back bit
reg    write_back;


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
always @(posedge clk or negedge rst_n) begin
    if(rst_n == 1'b0) begin
        cur_state <= Idle_or_Compare_Tag;
        next_state <= Idle_or_Compare_Tag;
    end
    else 
        cur_state <= next_state;
end


always @(*)begin
    //avoid latch
    //to Wb
    Dcache_ready_o = 1'b0;
    Dcache_data_o  = 32'h0;

    //to fc
    Dcache_pipe_stall_o = 1'b0;
    //to Ram
    Dcache_valid_req_o  = 1'b0;
    Dcache_req_addr_o       = 32'h0;

    case(cur_state)
        Idle_or_Compare_Tag:begin
            if(mem_valid_req_i == 1'b1)begin
                Dcache_ready_o = hit;

                if(Dcache_ready_o == 1'b1)begin //hit
                    victim_number = victim_number;
                    write_back    = 1'b0;

                    next_state = Idle_or_Compare_Tag;

                    case(mem_rw_i) 
                        1'b0:begin //write hit:1.Replace bit 2.Dirty bit            //accurate to byte

                            if(Dcache_Tag_Hit[0] == 1'b1) begin //way0
                                case(Dcache_Block_Off)
                                    2'b00:begin
                                        case(mem_wrwidth_i)  //how many byte need to write
                                            2'd1:begin
                                                case(Dcache_Byte_Off)
                                                    2'b00:Dcache_Data_Block[Dcache_Index << 1][7:0] = mem_data_i[7:0];
                                                    2'b01:Dcache_Data_Block[Dcache_Index << 1][15:8] = mem_data_i[7:0];
                                                    2'b10:Dcache_Data_Block[Dcache_Index << 1][23:16] = mem_data_i[7:0];
                                                    2'b11:Dcache_Data_Block[Dcache_Index << 1][31:24] = mem_data_i[7:0];
                                                    default:;
                                                endcase
                                            end

                                            2'd2:begin
                                                case(Dcache_Byte_Off)   //有对齐要求
                                                    2'b00:Dcache_Data_Block[Dcache_Index << 1][15:0] = mem_data_i[15:0];
                                                    2'b10:Dcache_Data_Block[Dcache_Index << 1][31:16] = mem_data_i[15:0];
                                                    default:;
                                                endcase
                                            end

                                            2'd3:Dcache_Data_Block[Dcache_Index << 1][31:0] = mem_data_i;

                                            default:;
                                        endcase
                                    end

                                    2'b01:begin
                                        case(mem_wrwidth_i)  //how many byte need to write
                                            2'd1:begin
                                                case(Dcache_Byte_Off)
                                                    2'b00:Dcache_Data_Block[Dcache_Index << 1][39:32] = mem_data_i[7:0];
                                                    2'b01:Dcache_Data_Block[Dcache_Index << 1][47:40] = mem_data_i[7:0];
                                                    2'b10:Dcache_Data_Block[Dcache_Index << 1][55:48] = mem_data_i[7:0];
                                                    2'b11:Dcache_Data_Block[Dcache_Index << 1][63:56] = mem_data_i[7:0];
                                                    default:;
                                                endcase
                                            end

                                            2'd2:begin
                                                case(Dcache_Byte_Off)   //有对齐要求
                                                    2'b00:Dcache_Data_Block[Dcache_Index << 1][47:32] = mem_data_i[15:0];
                                                    2'b10:Dcache_Data_Block[Dcache_Index << 1][63:48] = mem_data_i[15:0];
                                                    default:;
                                                endcase
                                            end

                                            2'd3:Dcache_Data_Block[Dcache_Index << 1][63:32] = mem_data_i;

                                            default:;
                                        endcase
                                    end

                                    2'b10:begin
                                        case(mem_wrwidth_i)  //how many byte need to write
                                            2'd1:begin
                                                case(Dcache_Byte_Off)
                                                    2'b00:Dcache_Data_Block[Dcache_Index << 1][71:64] = mem_data_i[7:0];
                                                    2'b01:Dcache_Data_Block[Dcache_Index << 1][79:72] = mem_data_i[7:0];
                                                    2'b10:Dcache_Data_Block[Dcache_Index << 1][87:80] = mem_data_i[7:0];
                                                    2'b11:Dcache_Data_Block[Dcache_Index << 1][95:88] = mem_data_i[7:0];
                                                    default:;
                                                endcase
                                            end

                                            2'd2:begin
                                                case(Dcache_Byte_Off)   //有对齐要求
                                                    2'b00:Dcache_Data_Block[Dcache_Index << 1][79:64] = mem_data_i[15:0];
                                                    2'b10:Dcache_Data_Block[Dcache_Index << 1][95:80] = mem_data_i[15:0];
                                                    default:;
                                                endcase
                                            end

                                            2'd3:Dcache_Data_Block[Dcache_Index << 1][95:64] = mem_data_i;

                                            default:;
                                        endcase
                                    end

                                    2'b11:begin
                                        case(mem_wrwidth_i)  //how many byte need to write
                                            2'd1:begin
                                                case(Dcache_Byte_Off)
                                                    2'b00:Dcache_Data_Block[Dcache_Index << 1][103:96] = mem_data_i[7:0];
                                                    2'b01:Dcache_Data_Block[Dcache_Index << 1][111:104] = mem_data_i[7:0];
                                                    2'b10:Dcache_Data_Block[Dcache_Index << 1][119:112] = mem_data_i[7:0];
                                                    2'b11:Dcache_Data_Block[Dcache_Index << 1][127:120] = mem_data_i[7:0];
                                                    default:;
                                                endcase
                                            end

                                            2'd2:begin
                                                case(Dcache_Byte_Off)   //有对齐要求
                                                    2'b00:Dcache_Data_Block[Dcache_Index << 1][111:96] = mem_data_i[15:0];
                                                    2'b10:Dcache_Data_Block[Dcache_Index << 1][127:112] = mem_data_i[15:0];
                                                    default:;
                                                endcase
                                            end

                                            2'd3:Dcache_Data_Block[Dcache_Index << 1][127:96] = mem_data_i;

                                            default:;
                                        endcase
                                    end

                                    default:;
                                endcase

                                Dcache_Tag_Array[Dcache_Index << 1][Replace] = 1'b0;
                                Dcache_Tag_Array[(Dcache_Index << 1) + 1][Replace] = 1'b1;

                                Dcache_Tag_Array[Dcache_Index << 1][Dirty] = 1'b1;
                            end

                            else begin   //way1
                                case(Dcache_Block_Off)
                                    2'b00:begin
                                        case(mem_wrwidth_i)  //how many byte need to write
                                            2'd1:begin
                                                case(Dcache_Byte_Off)
                                                    2'b00:Dcache_Data_Block[(Dcache_Index << 1) + 1][7:0] = mem_data_i[7:0];
                                                    2'b01:Dcache_Data_Block[(Dcache_Index << 1) + 1][15:8] = mem_data_i[7:0];
                                                    2'b10:Dcache_Data_Block[(Dcache_Index << 1) + 1][23:16] = mem_data_i[7:0];
                                                    2'b11:Dcache_Data_Block[(Dcache_Index << 1) + 1][31:24] = mem_data_i[7:0];
                                                    default:;
                                                endcase
                                            end

                                            2'd2:begin
                                                case(Dcache_Byte_Off)   //有对齐要求
                                                    2'b00:Dcache_Data_Block[(Dcache_Index << 1) + 1][15:0] = mem_data_i[15:0];
                                                    2'b10:Dcache_Data_Block[(Dcache_Index << 1) + 1][31:16] = mem_data_i[15:0];
                                                    default:;
                                                endcase
                                            end

                                            2'd3:Dcache_Data_Block[(Dcache_Index << 1) + 1][31:0] = mem_data_i;

                                            default:;
                                        endcase
                                    end

                                    2'b01:begin
                                        case(mem_wrwidth_i)  //how many byte need to write
                                            2'd1:begin
                                                case(Dcache_Byte_Off)
                                                    2'b00:Dcache_Data_Block[(Dcache_Index << 1) + 1][39:32] = mem_data_i[7:0];
                                                    2'b01:Dcache_Data_Block[(Dcache_Index << 1) + 1][47:40] = mem_data_i[7:0];
                                                    2'b10:Dcache_Data_Block[(Dcache_Index << 1) + 1][55:48] = mem_data_i[7:0];
                                                    2'b11:Dcache_Data_Block[(Dcache_Index << 1) + 1][63:56] = mem_data_i[7:0];
                                                    default:;
                                                endcase
                                            end

                                            2'd2:begin
                                                case(Dcache_Byte_Off)   //有对齐要求
                                                    2'b00:Dcache_Data_Block[(Dcache_Index << 1) + 1][47:32] = mem_data_i[15:0];
                                                    2'b10:Dcache_Data_Block[(Dcache_Index << 1) + 1][63:48] = mem_data_i[15:0];
                                                    default:;
                                                endcase
                                            end

                                            2'd3:Dcache_Data_Block[(Dcache_Index << 1) + 1][63:32] = mem_data_i;

                                            default:;
                                        endcase
                                    end

                                    2'b10:begin
                                        case(mem_wrwidth_i)  //how many byte need to write
                                            2'd1:begin
                                                case(Dcache_Byte_Off)
                                                    2'b00:Dcache_Data_Block[(Dcache_Index << 1) + 1][71:64] = mem_data_i[7:0];
                                                    2'b01:Dcache_Data_Block[(Dcache_Index << 1) + 1][79:72] = mem_data_i[7:0];
                                                    2'b10:Dcache_Data_Block[(Dcache_Index << 1) + 1][87:80] = mem_data_i[7:0];
                                                    2'b11:Dcache_Data_Block[(Dcache_Index << 1) + 1][95:88] = mem_data_i[7:0];
                                                    default:;
                                                endcase
                                            end

                                            2'd2:begin
                                                case(Dcache_Byte_Off)   //有对齐要求
                                                    2'b00:Dcache_Data_Block[(Dcache_Index << 1) + 1][79:64] = mem_data_i[15:0];
                                                    2'b10:Dcache_Data_Block[(Dcache_Index << 1) + 1][95:80] = mem_data_i[15:0];
                                                    default:;
                                                endcase
                                            end

                                            2'd3:Dcache_Data_Block[(Dcache_Index << 1) + 1][95:64] = mem_data_i;

                                            default:;
                                        endcase
                                    end

                                    2'b11:begin
                                        case(mem_wrwidth_i)  //how many byte need to write
                                            2'd1:begin
                                                case(Dcache_Byte_Off)
                                                    2'b00:Dcache_Data_Block[(Dcache_Index << 1) + 1][103:96] = mem_data_i[7:0];
                                                    2'b01:Dcache_Data_Block[(Dcache_Index << 1) + 1][111:104] = mem_data_i[7:0];
                                                    2'b10:Dcache_Data_Block[(Dcache_Index << 1) + 1][119:112] = mem_data_i[7:0];
                                                    2'b11:Dcache_Data_Block[(Dcache_Index << 1) + 1][127:120] = mem_data_i[7:0];
                                                    default:;
                                                endcase
                                            end

                                            2'd2:begin
                                                case(Dcache_Byte_Off)   //有对齐要求
                                                    2'b00:Dcache_Data_Block[(Dcache_Index << 1) + 1][111:96] = mem_data_i[15:0];
                                                    2'b10:Dcache_Data_Block[(Dcache_Index << 1) + 1][127:112] = mem_data_i[15:0];
                                                    default:;
                                                endcase
                                            end

                                            2'd3:Dcache_Data_Block[(Dcache_Index << 1) + 1][127:96] = mem_data_i;

                                            default:;
                                        endcase
                                    end

                                    default:;
                                endcase

                                Dcache_Tag_Array[Dcache_Index << 1][Replace] = 1'b1;
                                Dcache_Tag_Array[(Dcache_Index << 1) + 1][Replace] = 1'b0;

                                Dcache_Tag_Array[(Dcache_Index << 1) + 1][Dirty] = 1'b1;
                            end
                        end


                        1'b1:begin //read hit:1.Replace bit


                            //data_o and replace
                            if(Dcache_Tag_Hit[0] == 1'b1) begin //way0
                                case(Dcache_Block_Off)
                                    2'b00:Dcache_data_o = Dcache_Data_Block[Dcache_Index << 1][31:0];
                                    2'b01:Dcache_data_o = Dcache_Data_Block[Dcache_Index << 1][63:32];
                                    2'b10:Dcache_data_o = Dcache_Data_Block[Dcache_Index << 1][95:64];
                                    2'b11:Dcache_data_o = Dcache_Data_Block[Dcache_Index << 1][127:96];
                                    default:Dcache_data_o = 32'h0;
                                endcase

                               
                                Dcache_Tag_Array[Dcache_Index << 1][Replace] = 1'b0;
                                Dcache_Tag_Array[(Dcache_Index << 1) + 1][Replace] = 1'b1;
            
                            end

                            else begin  //way1
                                case(Dcache_Block_Off)
                                    2'b00:Dcache_data_o = Dcache_Data_Block[(Dcache_Index << 1) + 1][31:0];
                                    2'b01:Dcache_data_o = Dcache_Data_Block[(Dcache_Index << 1) + 1][63:32];
                                    2'b10:Dcache_data_o = Dcache_Data_Block[(Dcache_Index << 1) + 1][95:64];
                                    2'b11:Dcache_data_o = Dcache_Data_Block[(Dcache_Index << 1) + 1][127:96];
                                    default:Dcache_data_o = 32'h0;
                                endcase

                                
                                Dcache_Tag_Array[Dcache_Index << 1][Replace] = 1'b1;
                                Dcache_Tag_Array[(Dcache_Index << 1) + 1][Replace] = 1'b0;

                            end
                        end
                        
                    
                        default:;
                    endcase
                end
            
                else begin //miss   --need to choose a victim to replace out, dirty prior

                    Dcache_pipe_stall_o = 1'b1;

                    Dcache_valid_req_o = 1'b1;
                    Dcache_req_addr_o = (mem_addr_i >> 4) << 4;

                    next_state = Read_from_Ram;

                    case(mem_rw_i)
                        1'b0:begin     //write miss

                            case( {Dcache_Tag_Array[(Dcache_Index << 1) + 1][Dirty], Dcache_Tag_Array[Dcache_Index << 1][Dirty]} )



                                2'b00:begin  //all clean   --need to change dirty bit

                                    write_back    = 1'b0; //no need to write back

                                    case( {Dcache_Tag_Array[(Dcache_Index << 1) + 1][Replace],Dcache_Tag_Array[Dcache_Index << 1][Replace]} )
                                            
                                        //repalce :00 -> 10, write 0
                                        2'b00:begin
                                            Dcache_Tag_Array[Dcache_Index << 1][Replace] = 1'b0;
                                            Dcache_Tag_Array[(Dcache_Index << 1) + 1][Replace] = 1'b1;
                                            victim_number = 0;

                                            Dcache_Tag_Array[Dcache_Index << 1][Dirty] = 1'b1;
                                        end

                                        2'b01:begin
                                            Dcache_Tag_Array[Dcache_Index << 1][Replace] = 1'b0;
                                            Dcache_Tag_Array[(Dcache_Index << 1) + 1][Replace] = 1'b1;
                                            victim_number = 0;

                                            Dcache_Tag_Array[(Dcache_Index << 1) + 1][Dirty] = 1'b1;
                                        end

                                        2'b10:begin
                                            Dcache_Tag_Array[Dcache_Index << 1][Replace] = 1'b1;
                                            Dcache_Tag_Array[(Dcache_Index << 1) + 1][Replace] = 1'b0;
                                            victim_number = 1;

                                            Dcache_Tag_Array[Dcache_Index << 1][Dirty] = 1'b1;
                                        end

                                        default:begin
                                            Dcache_Tag_Array[Dcache_Index << 1][Replace] = 1'b1;
                                            Dcache_Tag_Array[(Dcache_Index << 1) + 1][Replace] = 1'b0;
                                            victim_number = 1;
                                        end

                                    endcase  

                                end


                                2'b01:begin  //1clean 0dirty   --need to change 1 to dirty bit   //no need to analyse replace bits, dirty is prior

                                    write_back    = 1'b0; //no need to write back

                                    Dcache_Tag_Array[Dcache_Index << 1][Replace] = 1'b1;
                                    Dcache_Tag_Array[(Dcache_Index << 1) + 1][Replace] = 1'b0;
                                    victim_number = 1;

                                    Dcache_Tag_Array[(Dcache_Index << 1) + 1][Dirty] = 1'b1;
 
                                end

                                2'b10:begin  //1dirty 0clean   --need to change 0 to dirty bit

                                    write_back    = 1'b0; //no need to write back

                                    Dcache_Tag_Array[Dcache_Index << 1][Replace] = 1'b0;
                                    Dcache_Tag_Array[(Dcache_Index << 1) + 1][Replace] = 1'b1;
                                    victim_number = 0;

                                    Dcache_Tag_Array[Dcache_Index << 1][Dirty] = 1'b1;
 
                                end


                                2'b11:begin  ////all dirty   --no need to change dirty bit

                                    write_back    = 1'b1; //need to write back
                                    


                                    case( {Dcache_Tag_Array[(Dcache_Index << 1) + 1][Replace],Dcache_Tag_Array[Dcache_Index << 1][Replace]} )
                                            
                                            //repalce :00 -> 10, write 0
                                            2'b00:begin
                                                Dcache_Tag_Array[Dcache_Index << 1][Replace] = 1'b0;
                                                Dcache_Tag_Array[(Dcache_Index << 1) + 1][Replace] = 1'b1;
                                                victim_number = 0;

                                                Dcache_waddr_o = {Dcache_Tag_Array[Dcache_Index << 1][Tag_Width:0], 
                                                        Dcache_Index[2:0], {4{1'b0}}  };
                                            end

                                            2'b01:begin
                                                Dcache_Tag_Array[Dcache_Index << 1][Replace] = 1'b0;
                                                Dcache_Tag_Array[(Dcache_Index << 1) + 1][Replace] = 1'b1;
                                                victim_number = 0;

                                                Dcache_waddr_o = {Dcache_Tag_Array[Dcache_Index << 1][Tag_Width:0], 
                                                        Dcache_Index[2:0], {4{1'b0}}  };
                                            end

                                            2'b10:begin
                                                Dcache_Tag_Array[Dcache_Index << 1][Replace] = 1'b1;
                                                Dcache_Tag_Array[(Dcache_Index << 1) + 1][Replace] = 1'b0;
                                                victim_number = 1;

                                                Dcache_waddr_o = {Dcache_Tag_Array[(Dcache_Index << 1) + 1][Tag_Width:0], 
                                                        Dcache_Index[2:0], {4{1'b0}}  };
                                            end

                                            default:begin
                                                Dcache_Tag_Array[Dcache_Index << 1][Replace] = 1'b1;
                                                Dcache_Tag_Array[(Dcache_Index << 1) + 1][Replace] = 1'b0;
                                                victim_number = 1;

                                                Dcache_waddr_o = {Dcache_Tag_Array[Dcache_Index << 1][Tag_Width:0], 
                                                        Dcache_Index[2:0], {4{1'b0}}  };
                                            end

                                        endcase  

                                end
                                
                                
                                default:;
                            endcase


                        end

                        1'b1:begin     //read miss, no need to change dirty bit


                        
                            case( {Dcache_Tag_Array[(Dcache_Index << 1) + 1][Dirty], Dcache_Tag_Array[Dcache_Index << 1][Dirty]} )


                                2'b00:begin  //all clean   --need to change dirty bit

                                    write_back    = 1'b0; //no need to write back

                                    case( {Dcache_Tag_Array[(Dcache_Index << 1) + 1][Replace],Dcache_Tag_Array[Dcache_Index << 1][Replace]} )
                                            
                                        //repalce :00 -> 10, write 0
                                        2'b00:begin
                                            Dcache_Tag_Array[Dcache_Index << 1][Replace] = 1'b0;
                                            Dcache_Tag_Array[(Dcache_Index << 1) + 1][Replace] = 1'b1;
                                            victim_number = 0;

                                            Dcache_Tag_Array[Dcache_Index << 1][Dirty] = 1'b1;
                                        end

                                        2'b01:begin
                                            Dcache_Tag_Array[Dcache_Index << 1][Replace] = 1'b0;
                                            Dcache_Tag_Array[(Dcache_Index << 1) + 1][Replace] = 1'b1;
                                            victim_number = 0;

                                            Dcache_Tag_Array[(Dcache_Index << 1) + 1][Dirty] = 1'b1;
                                        end

                                        2'b10:begin
                                            Dcache_Tag_Array[Dcache_Index << 1][Replace] = 1'b1;
                                            Dcache_Tag_Array[(Dcache_Index << 1) + 1][Replace] = 1'b0;
                                            victim_number = 1;

                                            Dcache_Tag_Array[Dcache_Index << 1][Dirty] = 1'b1;
                                        end

                                        default:begin
                                            Dcache_Tag_Array[Dcache_Index << 1][Replace] = 1'b1;
                                            Dcache_Tag_Array[(Dcache_Index << 1) + 1][Replace] = 1'b0;
                                            victim_number = 1;
                                        end

                                    endcase  

                                end


                                2'b01:begin  //1clean 0dirty   --need to change 1 to dirty bit   //no need to analyse replace bits, dirty is prior

                                    write_back    = 1'b0; //no need to write back

                                    Dcache_Tag_Array[Dcache_Index << 1][Replace] = 1'b1;
                                    Dcache_Tag_Array[(Dcache_Index << 1) + 1][Replace] = 1'b0;
                                    victim_number = 1;

                                    Dcache_Tag_Array[(Dcache_Index << 1) + 1][Dirty] = 1'b1;
 
                                end

                                2'b10:begin  //1dirty 0clean   --need to change 0 to dirty bit

                                    write_back    = 1'b0; //no need to write back

                                    Dcache_Tag_Array[Dcache_Index << 1][Replace] = 1'b0;
                                    Dcache_Tag_Array[(Dcache_Index << 1) + 1][Replace] = 1'b1;
                                    victim_number = 0;

                                    Dcache_Tag_Array[Dcache_Index << 1][Dirty] = 1'b1;
 
                                end


                                2'b11:begin  ////all dirty   --no need to change dirty bit

                                    write_back    = 1'b1; //need to write back

                                    case( {Dcache_Tag_Array[(Dcache_Index << 1) + 1][Replace],Dcache_Tag_Array[Dcache_Index << 1][Replace]} )
                                            
                                            //repalce :00 -> 10, write 0
                                            2'b00:begin
                                                Dcache_Tag_Array[Dcache_Index << 1][Replace] = 1'b0;
                                                Dcache_Tag_Array[(Dcache_Index << 1) + 1][Replace] = 1'b1;
                                                victim_number = 0;

                                                Dcache_waddr_o = {Dcache_Tag_Array[Dcache_Index << 1][Tag_Width:0], 
                                                        Dcache_Index[2:0], {4{1'b0}}  };
                                            end

                                            2'b01:begin
                                                Dcache_Tag_Array[Dcache_Index << 1][Replace] = 1'b0;
                                                Dcache_Tag_Array[(Dcache_Index << 1) + 1][Replace] = 1'b1;
                                                victim_number = 0;

                                                Dcache_waddr_o = {Dcache_Tag_Array[Dcache_Index << 1][Tag_Width:0], 
                                                        Dcache_Index[2:0], {4{1'b0}}  };
                                            end

                                            2'b10:begin
                                                Dcache_Tag_Array[Dcache_Index << 1][Replace] = 1'b1;
                                                Dcache_Tag_Array[(Dcache_Index << 1) + 1][Replace] = 1'b0;
                                                victim_number = 1;

                                                Dcache_waddr_o = {Dcache_Tag_Array[(Dcache_Index << 1) + 1][Tag_Width:0], 
                                                        Dcache_Index[2:0], {4{1'b0}}  };
                                            end

                                            default:begin
                                                Dcache_Tag_Array[Dcache_Index << 1][Replace] = 1'b1;
                                                Dcache_Tag_Array[(Dcache_Index << 1) + 1][Replace] = 1'b0;
                                                victim_number = 1;

                                                Dcache_waddr_o = {Dcache_Tag_Array[Dcache_Index << 1][Tag_Width:0], 
                                                        Dcache_Index[2:0], {4{1'b0}}  };
                                            end

                                        endcase  

                                end
                                
                                
                                default:;
                            endcase




                        end

                        default:;

                    endcase

                end 
            end
            else begin
                next_state = Idle_or_Compare_Tag;
                victim_number = victim_number;   // need to keep, so in every state need to have a value to set up
                write_back    = 1'b0;            //
            end



        end

        Read_from_Ram:begin




            


        
        end

        default:;
    endcase
end



endmodule