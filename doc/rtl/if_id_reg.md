## 端口信号
### Input
1. input wire   [31:0]  if_pc_i   
   来自if模块，携带PC值。   

2. input wire           fc_flush_btype_flag_i   
   来自Flow_Ctrl模块，表明当前执行阶段判断出在执行部件中的指令流为Btype且需要跳转，则if_id流水线寄存器需要冲刷，流水线寄存器下一周期所有数据的输出值为重置值。   

   input wire           fc_flush_jtype_flag_i      
   来自Flow_Ctrl模块，表明当前译码阶段判断出在译码部件中的指令流为jal或jarl，则if_id流水线寄存器需要冲刷，流水线寄存器下一周期所有数据的输出值为重置值。   

   input wire           fc_flush_stall_flag_i   
   来自Flow_Ctrl模块，表明当前Icache模块有stall申请，则if_id流水线寄存器需要保持，流水线寄存器下一周期所有数据的输出值保持不变。

### Output
1. output reg   [31:0]  if_id_reg_pc_o   
   输出到id模块，输出PC值。

# 模块功能
传递if模块中指令必要信息给id模块。