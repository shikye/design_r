## 端口信号
### Input
1. input wire   [31:0]  if_id_reg_pc_i
   来自if_id_reg模块，获取该条指令的PC值。 
2. input wire   [31:0]  regs_reg1_rdata_i
   input wire   [31:0]  regs_reg2_rdata_i
   来自寄存器组，在当前周期获取当前指令需要的寄存器值。   
3. input wire           dhnf_hazard_sel1_1    
   input wire           dhnf_hazard_sel2_1   
   来自dhnf模块，判断应该选择寄存器数据还是前递的数据。
   input wire   [31:0]  dhnf_forward_data1_i
   input wire   [31:0]  dhnf_forward_data2_i
   来自dhnf模块，前递数据。
4. input wire   [31:0]  Icache_inst_i   
   input wire           Icache_ready_i
   来自Icache模块，表明指令有效。   
5. input wire           fc_jump_flag_i   
   来自Flow_Ctrl模块，表明当前id阶段中的指令需要冲刷，即打拍的指令寄存器输出为0。   
### Output
1. output reg           if_valid_req_o    
   输出到Icache模块，下一周期对Icache中数据进行有效申请。
2. output reg   [31:0]  if_pc_o   
   输出到Icache模块和下一级流水线寄存器中，在下一周期这两个模块获得有效值。

## 内部信号
1. reg start_flag = 1'b1;
   初始化输出信号，若没有该flag，则信号变化为：
   ```
    从rst_n==1'b0的
        if_pc_o <= 32'h0;
        if_valid_req_o <= 1'b0;
    
    转移到最后一个分支
        if_pc_o <= if_pc_o + 32'h4;
        if_valid_req_o <= 1'b1;
    
    即初始对Icache进行有效申请的地址是32'h4。

   ```

# 模块功能
1. 获取op_a和op_b，其中op_a主要为寄存器数据或根据特殊指令的特殊值，op_b主要为寄存器数据或立即数或根据特殊指令的特殊值。  
   特殊值对有：   
   Lui（op_a = 32'h0，op_b = eximm）
   Auipc（op_a = PC，op_b = eximm）
   Jal,Jarl（op_a = PC，op_b = 4） //将PC+4写入xd寄存器
   SLLI，SRLI，SRAI（op_a = reg_a，op_b = shamt）  
   
   
2. 将指令译码给cu模块   
   一条指令译码分解为opcode、rs1、rs2、rd、func3、func7、shamt。   

3. 立即数扩展

4. 判断是否为Jal，Jarl指令，若是，则向Flow_Ctrl模块申请Jtype跳转。   

5. 内置一个触发器，将从Icache模块输入的数据延迟一拍，因为Icache是异步读，在if阶段就能读到数据。    
   
   
   