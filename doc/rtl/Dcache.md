# 模块功能
## 面向core
### 需要完成load/store指令
1. 对于load指令，每次可以都读出4个字节，即自己规定的一个Block，之后再由core自己选择需要的数据。    
2. 对于store指令，每次写入的数据宽度不同，虽然硬件线宽为32位，但有效位数可能为8、16、32,所以需要一个信号来通知有效位宽   
   若core只写入8位，即32位的硬件位宽中只有低8位有效，则如果还将32位都视为有效，就会导致覆盖Dcache中不应改变的内容。   

## 面向Ram
1. store指令在miss时，需要从Ram读取128位。   
2. load指令在miss时，可能需要先向Ram写回128位，然后再从Ram读取128位。  


# 状态机
1. Idle_or_Compare_Tag:  //修改Replace位和Dirty位
   - 空闲等待。
   - 命中：
     - 读命中：改变Replace位
     - 写命中：改变Replace位，置为脏位
   - Miss：需要选择一个victim块置换出去
     - 读Miss：
       - 有clean行：进入Read_from_Ram状态，修改Replace位
       - 无clean行：进入Write_Back状态，修改Replace位、重置Dirty位
     - 写Miss：
       - 有clean行：进入Read_from_Ram状态，修改Replace位、置为脏位
       - 无clean行：进入Write_Back状态，修改Replace位、Dirty位不变（因为马上要写入新数据到Cache中）
  
2. Write_Back:
   - 向Ram写回一行的数据
  

3. Read_from_Ram:
   - 读：
     - 从Ram读出对应行，修改Valid位，输出行中某个Block
   - 写：
     - 从Ram读出对应行，修改Valid位，修改行中某些数据
