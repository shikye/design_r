## 端口信号
### Input
1. input wire           fc_stall_flag_i
   来自Flow_Ctrl模块，控制取指模块的PC值在下一周期保持不变。    
   且由于PC值保持上一周期的值，上一周期已经申请了Icache，在之后的保持阶段中不再申请。 
2. input wire           fc_jump_flag_i
   input wire   [31:0]  fc_jump_pc_i   
   来自Flow_Ctrl模块，控制取值模块的PC值在下一周期跳转，并申请Icache中的指令。
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
每周期获取当前指令的PC值并输出到Icache模块，以在下一周期正常情况下inst能传递到id模块。