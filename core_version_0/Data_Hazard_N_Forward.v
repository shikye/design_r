module Data_Hazard_N_Forward(
    //from id
    input   wire            [4:0]   id_reg1_raddr_i,
    input   wire            [4:0]   id_reg2_raddr_i,
    input   wire                    id_reg1_RE_i,
    input   wire                    id_reg2_RE_i,
    //from ex
    input   wire            [4:0]   ex_reg_waddr_i,
    input   wire            [31:0]  ex_op_c_i,
    input   wire                    ex_reg_we_i,
    //from mem
    input   wire            [4:0]   mem_reg_waddr_i,
    input   wire            [31:0]  mem_op_c_i,
    input   wire                    mem_reg_we_i,
    //from wb
    input   wire            [4:0]   wb_reg_waddr_i,
    input   wire            [31:0]  wb_op_c_i,
    input   wire                    wb_reg_we_i,
    //to id
    output  wire                    dhnf_harzard_sel1_o,
    output  wire                    dhnf_harzard_sel2_o,
    
    output  wire            [31:0]  dhnf_forward_data1_o,
    output  wire            [31:0]  dhnf_forward_data2_o
);


    //1-hazard 0-nohazard
    wire    reg1_id_ex_hazard = (id_reg1_raddr_i != 5'b0) && id_reg1_RE_i && ex_reg_we_i &&    
        (id_reg1_raddr_i == ex_reg_waddr_i);


    wire    reg2_id_ex_hazard = (id_reg2_raddr_i != 5'b0) && id_reg2_RE_i && ex_reg_we_i && 
        (id_reg2_raddr_i == ex_reg_waddr_i);

    
    wire    reg1_id_mem_hazard = (id_reg1_raddr_i != 5'b0) && id_reg1_RE_i && mem_reg_we_i &&    
        (id_reg1_raddr_i == mem_reg_waddr_i);


    wire    reg2_id_mem_hazard = (id_reg2_raddr_i != 5'b0) && id_reg2_RE_i && mem_reg_we_i && 
        (id_reg2_raddr_i == mem_reg_waddr_i);

    wire    reg1_id_wb_hazard = (id_reg1_raddr_i != 5'b0) && id_reg1_RE_i && wb_reg_we_i &&    
        (id_reg1_raddr_i == wb_reg_waddr_i);


    wire    reg2_id_wb_hazard = (id_reg2_raddr_i != 5'b0) && id_reg2_RE_i && wb_reg_we_i && 
        (id_reg2_raddr_i == wb_reg_waddr_i);

    
    assign dhnf_harzard_sel1_o = reg1_id_ex_hazard | reg1_id_mem_hazard |
        reg1_id_wb_hazard;

    assign dhnf_harzard_sel2_o = reg2_id_ex_hazard | reg2_id_mem_hazard |
        reg2_id_wb_hazard;

    
    //notice the complex way
    assign dhnf_forward_data1_o = reg1_id_ex_hazard ? ex_op_c_i : 
        reg1_id_mem_hazard ? mem_op_c_i :
        reg1_id_wb_hazard ? wb_op_c_i : 32'b0;

    assign dhnf_forward_data2_o = reg2_id_ex_hazard ? ex_op_c_i : 
        reg2_id_mem_hazard ? mem_op_c_i :
        reg2_id_wb_hazard ? wb_op_c_i : 32'b0;




endmodule