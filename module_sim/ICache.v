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

    //from core
    input   wire            [31:0]  core_inst_addr_i, //from core
    input   wire                    core_valid_req_i,
    //to core
    output  reg                     Icache_ready_o,
    output  reg             [31:0]  Icache_inst_o,

    output  wire                    hit,
    output  reg                     pipe_stall,
    
    //to mem
    output  reg             [31:0]  Icache_addr_o,
    output  reg                     Icache_valid_req_o,

    //from mem
    input   wire                    mem_ready_i,
    input   wire            [127:0] mem_data_i

    
);
    
//FSM
localparam Idle             = 0;
localparam Compare_Tag      = 1;   //Compare and Give data to core
localparam Read_from_Mem    = 2;


reg [1:0]   cur_state;
reg [1:0]   next_state;


//function mapping
localparam Tag_Width        = 27 - 1;
localparam Valid            = 28;
localparam Replace          = 27;


//Data_Block and Tag_Array
reg [127:0] ICache_Data_Block [0:15];
reg [29:0]  ICache_Tag_Array  [0:15];

//Mapping Decord
wire [26:0] Icache_tag   = core_inst_addr_i[31:5];
wire [2:0]  Icache_index = core_inst_addr_i[4:2];
wire [1:0]  Icache_off   = core_inst_addr_i[1:0];

//Buffer
reg [127:0] Mem_Data_Buffer_i;


//hit --regardless of ready
wire [1:0] ICache_Tag_hit;
assign ICache_Tag_hit[0] = ( (Icache_tag == ICache_Tag_Array[Icache_index << 1][Tag_Width:0]) && ICache_Tag_Array[Icache_index << 1][Valid] == 1'b1 );
assign ICache_Tag_hit[1] = ( (Icache_tag == ICache_Tag_Array[Icache_index << 1 + 1][Tag_Width:0]) && ICache_Tag_Array[Icache_index << 1 + 1][Valid] == 1'b1 );

assign hit              = (ICache_Tag_hit != 2'b00);



//replace algorithm
reg         victim_number;


//initial
always @(*) begin
    if(rst_n == 1'b0)begin
        ICache_Tag_Array[0]    = 30'h0;
        ICache_Tag_Array[1]    = 30'h0;
        ICache_Tag_Array[2]    = 30'h0;
        ICache_Tag_Array[3]    = 30'h0;
        ICache_Tag_Array[4]    = 30'h0;
        ICache_Tag_Array[5]    = 30'h0;
        ICache_Tag_Array[6]    = 30'h0;
        ICache_Tag_Array[7]    = 30'h0;
        ICache_Tag_Array[8]    = 30'h0;
        ICache_Tag_Array[9]    = 30'h0;
        ICache_Tag_Array[10]   = 30'h0;
        ICache_Tag_Array[11]   = 30'h0;
        ICache_Tag_Array[12]   = 30'h0;
        ICache_Tag_Array[13]   = 30'h0;
        ICache_Tag_Array[14]   = 30'h0;
        ICache_Tag_Array[15]   = 30'h0;

    end
end




//FSM
always @(posedge clk or negedge rst_n) begin
    if(rst_n == 1'b0) begin
        cur_state <= Idle;
        next_state <= Idle;
    end
    else 
        cur_state <= next_state;
end


always @(*) begin
    //avoid latch
    //Replace 
    victim_number = 1'b0;
    //to core
    Icache_ready_o = 1'b0;
    Icache_inst_o  = 32'h0;
    pipe_stall     = 1'b0;
    //to mem
    Icache_addr_o  = 32'h0;
    Icache_valid_req_o = 1'b0;


    case(cur_state)
        Idle:begin
            if(core_valid_req_i == 1'b1)
                next_state = Compare_Tag;
            else 
                next_state = Idle;
        end

        Compare_Tag:begin
            Icache_ready_o = hit;   //need to read then hit

            if(Icache_ready_o == 1'b1)begin   //hit then change Replace

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
                        ICache_Tag_Array[Icache_index << 1 + 1][Replace] = 1'b1;
                    end
                    else begin
                        ICache_Tag_Array[Icache_index << 1][Replace] = 1'b0;
                        ICache_Tag_Array[Icache_index << 1 + 1][Replace] = 1'b1;
                    end
                end

                else begin

                    case(Icache_off)
                        2'b00:Icache_inst_o = ICache_Data_Block[Icache_index << 1 + 1][31:0];
                        2'b01:Icache_inst_o = ICache_Data_Block[Icache_index << 1 + 1][63:32];
                        2'b10:Icache_inst_o = ICache_Data_Block[Icache_index << 1 + 1][95:64];
                        2'b11:Icache_inst_o = ICache_Data_Block[Icache_index << 1 + 1][127:96];
                        default:Icache_inst_o = 32'h0;
                    endcase

                    if(ICache_Tag_Array[Icache_index << 1 + 1][Replace] == 1'b1) begin
                        ICache_Tag_Array[Icache_index << 1 + 1][Replace] = 1'b0;
                        ICache_Tag_Array[Icache_index << 1][Replace] = 1'b1;
                    end
                    else begin
                        ICache_Tag_Array[Icache_index << 1 + 1][Replace] = 1'b0;
                        ICache_Tag_Array[Icache_index << 1][Replace] = 1'b1;
                    end
                end
            end

            else begin                    //Cache Miss
                pipe_stall = 1'b1;

                case( {ICache_Tag_Array[Icache_index << 1 + 1][Replace],ICache_Tag_Array[Icache_index << 1][Replace]} )
                    2'b00:begin
                        victim_number = 1'b0;
                        ICache_Tag_Array[Icache_index << 1][Replace] = 1'b0;
                        ICache_Tag_Array[Icache_index << 1 + 1][Replace] = 1'b1;
                    end
                    2'b01:begin
                        victim_number = 1'b1;
                        ICache_Tag_Array[Icache_index << 1][Replace] = 1'b1;
                        ICache_Tag_Array[Icache_index << 1 + 1][Replace] = 1'b0;
                    end
                    2'b10:begin
                        victim_number = 1'b0;
                        ICache_Tag_Array[Icache_index << 1][Replace] = 1'b0;
                        ICache_Tag_Array[Icache_index << 1 + 1][Replace] = 1'b1;
                    end
                    default:begin
                        victim_number = 1'b0;
                        ICache_Tag_Array[Icache_index << 1][Replace] = 1'b0;
                        ICache_Tag_Array[Icache_index << 1 + 1][Replace] = 1'b0;
                    end
                endcase

                next_state = Read_from_Mem;
            end
        end


        Read_from_Mem:begin
            Icache_valid_req_o = 1'b1;
            Icache_addr_o = (core_inst_addr_i >> 4) << 4;
            Mem_Data_Buffer_i = mem_data_i;


            if(mem_ready_i == 1'b1) begin
                ICache_Data_Block[Icache_index << 1 + victim_number] = Mem_Data_Buffer_i;
                Icache_ready_o = 1'b1;

                case(Icache_off)
                    2'b00:Icache_inst_o = ICache_Data_Block[Icache_index << 1 + victim_number][31:0];
                    2'b01:Icache_inst_o = ICache_Data_Block[Icache_index << 1 + victim_number][63:32];
                    2'b10:Icache_inst_o = ICache_Data_Block[Icache_index << 1 + victim_number][95:64];
                    2'b11:Icache_inst_o = ICache_Data_Block[Icache_index << 1 + victim_number][127:96];
                    default:Icache_inst_o = 32'h0;
                endcase

                next_state = Idle;
            end
            else begin
                pipe_stall = 1'b1;
                Icache_ready_o = 1'b0; 
                next_state = Read_from_Mem;   
            end
        
        end


        default:next_state = Idle;
    endcase
end



endmodule