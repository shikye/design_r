//2-way 8-set 
//Cache_Block:16 Byte,Cache_line:16 line
//Cache Memory Mapping:| Tag | Index | Block Offset |
//                       27      3          2  
//Tag Unit:|Valid|Replace|Tag|
//            1      1    27
//Get 4 Btye for each time


//write back and write allocate


//should be a combination circuit?
//no, pipeline is a sequence , and sram is sequence

module ICache (
    input   wire                    clk,
    input   wire                    rst_n,

    //from if
    input   wire            [31:0]  if_pc_i, //from if
    input   wire                    if_valid_req_i,
    //to if
    output  reg                     Icache_ready_o,
    output  reg             [31:0]  Icache_inst_o,

    //to fc

    output  reg                     Icache_pipe_stall_o,
    output  wire                    hit,
    
    //to mem
    output  reg             [31:0]  Icache_addr_o,
    output  reg                     Icache_valid_req_o,

    //from mem
    input   wire                    mem_ready_i,
    input   wire            [127:0] mem_data_i
);
    
//FSM
localparam Idle_or_Compare_Tag  = 0; //Compare and Give data to core
localparam Read_from_Mem        = 1;


reg cur_state;
reg next_state;


//function mapping
localparam Tag_Width        = 25 - 1;
localparam Valid            = 26;
localparam Replace          = 25;


//Data_Block and Tag_Array
reg [127:0] ICache_Data_Block [0:15];
reg [26:0]  ICache_Tag_Array  [0:15];

//Mapping Decord
wire [24:0] Icache_tag   = if_pc_i[31:7];
wire [3:0]  Icache_index = {{1'b0},if_pc_i[6:4]};   // when Icache_index 3bits, if << , will overflow,Icache_index should be 4bits.
wire [1:0]  Icache_off   = if_pc_i[3:2];     //notice the width!!! [3:2]

wire [3:0]  Icache_line_base = {if_pc_i[6:4],{1'b0}};
//Buffer
reg [127:0] Mem_Data_Buffer_i;


//hit --regardless of ready
wire [1:0] ICache_Tag_hit;
assign ICache_Tag_hit[0] = ( (Icache_tag == ICache_Tag_Array[Icache_index << 1][Tag_Width:0]) && ICache_Tag_Array[Icache_index << 1][Valid] == 1'b1 );
assign ICache_Tag_hit[1] = ( (Icache_tag == ICache_Tag_Array[(Icache_index << 1) + 1][Tag_Width:0]) && ICache_Tag_Array[(Icache_index << 1) + 1][Valid] == 1'b1 );

assign hit              = (ICache_Tag_hit != 2'b00);



//replace algorithm
reg         victim_number;


//initial
always @(*) begin
    if(rst_n == 1'b0)begin
        ICache_Tag_Array[0]    = 27'h0;
        ICache_Tag_Array[1]    = 27'h0;
        ICache_Tag_Array[2]    = 27'h0;
        ICache_Tag_Array[3]    = 27'h0;
        ICache_Tag_Array[4]    = 27'h0;
        ICache_Tag_Array[5]    = 27'h0;
        ICache_Tag_Array[6]    = 27'h0;
        ICache_Tag_Array[7]    = 27'h0;
        ICache_Tag_Array[8]    = 27'h0;
        ICache_Tag_Array[9]    = 27'h0;
        ICache_Tag_Array[10]   = 27'h0;
        ICache_Tag_Array[11]   = 27'h0;
        ICache_Tag_Array[12]   = 27'h0;
        ICache_Tag_Array[13]   = 27'h0;
        ICache_Tag_Array[14]   = 27'h0;
        ICache_Tag_Array[15]   = 27'h0;
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


always @(cur_state,Icache_index,if_valid_req_i,mem_ready_i,if_pc_i,Icache_off,if_valid_req_i,ICache_Tag_hit) begin   //used to be * //no use if_pc_i //matters a lot
    //avoid latch
    //Replace 
    //victim_number = 1'b0;
    //to core
    Icache_ready_o = 1'b0;
    Icache_inst_o  = 32'h0;

    Icache_pipe_stall_o = 1'b0;
    //to mem
    Icache_addr_o  = 32'h0;
    Icache_valid_req_o = 1'b0;


    case(cur_state)
        Idle_or_Compare_Tag:begin

            if(if_valid_req_i == 1'b1)begin

                Icache_ready_o = hit;   //need to read then hit

                if(Icache_ready_o == 1'b1)begin   //hit then change Replace

                    victim_number = victim_number;



                    if(ICache_Tag_hit[0] == 1'b1) begin

                        case(Icache_off)
                            2'b00:Icache_inst_o = ICache_Data_Block[Icache_index << 1][31:0];
                            2'b01:Icache_inst_o = ICache_Data_Block[Icache_index << 1][63:32];
                            2'b10:Icache_inst_o = ICache_Data_Block[Icache_index << 1][95:64];
                            2'b11:Icache_inst_o = ICache_Data_Block[Icache_index << 1][127:96];
                            default:Icache_inst_o = 32'h0;
                        endcase

                        if(ICache_Tag_Array[Icache_index << 1][Replace] == 1'b1) begin
                            ICache_Tag_Array[Icache_index << 1][Replace] = 1'b0;
                            ICache_Tag_Array[(Icache_index << 1) + 1][Replace] = 1'b1;
                        end
                        else begin
                            ICache_Tag_Array[Icache_index << 1][Replace] = 1'b0;
                            ICache_Tag_Array[(Icache_index << 1) + 1][Replace] = 1'b1;
                        end
                    end

                    else begin

                        case(Icache_off)
                            2'b00:Icache_inst_o = ICache_Data_Block[(Icache_index << 1) + 1][31:0];
                            2'b01:Icache_inst_o = ICache_Data_Block[(Icache_index << 1) + 1][63:32];
                            2'b10:Icache_inst_o = ICache_Data_Block[(Icache_index << 1) + 1][95:64];
                            2'b11:Icache_inst_o = ICache_Data_Block[(Icache_index << 1) + 1][127:96];
                            default:Icache_inst_o = 32'h0;
                        endcase

                        if(ICache_Tag_Array[(Icache_index << 1) + 1][Replace] == 1'b1) begin
                            ICache_Tag_Array[(Icache_index << 1) + 1][Replace] = 1'b0;
                            ICache_Tag_Array[Icache_index << 1][Replace] = 1'b1;
                        end
                        else begin
                            ICache_Tag_Array[(Icache_index << 1) + 1][Replace] = 1'b0;
                            ICache_Tag_Array[Icache_index << 1][Replace] = 1'b1;
                        end
                    end
                end

                else begin                    //Cache Miss

                    Icache_valid_req_o = 1'b1;
                    Icache_addr_o = (if_pc_i >> 4) << 4;

                    
                    Icache_pipe_stall_o = 1'b1;

                    case( {ICache_Tag_Array[(Icache_index << 1) + 1][Replace],ICache_Tag_Array[Icache_index << 1][Replace]} )
                        2'b00:begin
                            victim_number = 1'b0;
                            ICache_Tag_Array[Icache_index << 1][Replace] = 1'b0;
                            ICache_Tag_Array[(Icache_index << 1) + 1][Replace] = 1'b1;
                        end
                        2'b01:begin
                            victim_number = 1'b0;
                            ICache_Tag_Array[Icache_index << 1][Replace] = 1'b0;
                            ICache_Tag_Array[(Icache_index << 1) + 1][Replace] = 1'b1;
                        end
                        2'b10:begin
                            victim_number = 1'b1;
                            ICache_Tag_Array[Icache_index << 1][Replace] = 1'b1;
                            ICache_Tag_Array[(Icache_index << 1) + 1][Replace] = 1'b0;
                        end
                        default:begin
                            victim_number = 1'b0;
                            ICache_Tag_Array[Icache_index << 1][Replace] = 1'b0;
                            ICache_Tag_Array[(Icache_index << 1) + 1][Replace] = 1'b0;
                        end
                    endcase

                    next_state = Read_from_Mem;
                end
            end

            else begin
                next_state = Idle_or_Compare_Tag;
                victim_number = victim_number;
            end
        end


        Read_from_Mem:begin
            // Icache_valid_req_o = 1'b1;            valid should be 1 for only 1 cycle
            // Icache_addr_o = (if_pc_i >> 4) << 4;
            Mem_Data_Buffer_i = mem_data_i;

            Icache_pipe_stall_o = 1'b1;

            victim_number = victim_number;

            if(mem_ready_i == 1'b1) begin
                ICache_Data_Block[(Icache_index << 1) + victim_number] = Mem_Data_Buffer_i;
                ICache_Tag_Array[(Icache_index << 1) + victim_number][Valid] = 1'b1;

                Icache_ready_o = 1'b1;

                Icache_pipe_stall_o = 1'b0;

                

                case(Icache_off)
                    2'b00:Icache_inst_o = ICache_Data_Block[(Icache_index << 1) + victim_number][31:0];
                    2'b01:Icache_inst_o = ICache_Data_Block[(Icache_index << 1) + victim_number][63:32];
                    2'b10:Icache_inst_o = ICache_Data_Block[(Icache_index << 1) + victim_number][95:64];
                    2'b11:Icache_inst_o = ICache_Data_Block[(Icache_index << 1) + victim_number][127:96];
                    default:Icache_inst_o = 32'h0;
                endcase

                next_state = Idle_or_Compare_Tag;
            end
            else begin
                Icache_ready_o = 1'b0; 
                next_state = Read_from_Mem;   
            end
        
        end


        default: begin
            next_state = Idle_or_Compare_Tag;
            victim_number = victim_number;
        end
    endcase
end



endmodule