# design_r
1.
输入输出端口命名方式：所在模块+功能+输入/输出  
所在模块：若为输入，描述从哪里入，若为输出，描述从哪里出


2.
每个段所需要的数据主要从流水线寄存器获取

3.
reg不代表是寄存器，只是一个标识符
不同的输入输出格式
reg格式可以保留输出值，输出并保持
wire格式随着输入值的变化而变化

边沿敏感寄存器就是由触发器构成的

4.
指令的类型看格式而不是看功能，比如jalr按格式是I型，但是是一条跳转指令

5.基础指令功能
lui:Load Upper Immediate
lui rd,immediate
将符号位扩展的20位立即数左移12位，并将低12位置零，写入x[rd]中。

auipc:Add Upper immediate to PC
auipc rd,immediate
把符号位扩展的20位立即数左移12位，与PC值相加，结果写入x[rd]中。

jal:Jump and Link
jal rd,offset
把下一条指令的地址(PC+4)写入x[rd]中，然后把PC设置成当前值(PC)加上符号位扩展的offset，rd默认为x1。

jalr:Jump and Link Register
jalr rd,offset(rs1)
把下一条指令的地址(PC+4)写入x[rd]中，然后把PC设置成x[rs1]加上符号位扩展的offset，并把计算结果的最低有效位设为0。


6.
每个阶段内部是组合逻辑

例如id阶段需要读寄存器数据，此时为了在一个周期内完成，读寄存器组应该使用组合逻辑，且寄存器组的数据在一个周期内能稳定地
给wire提供数据
时序逻辑是为了完成同步

什么东西应该放在组合逻辑里：任何时候都根据输入产出输出的逻辑不变
什么东西应该放在时序逻辑里：流水线寄存器相关的数据
core的时序由流水线寄存器控制


7.为什么要设置时钟同步即时序逻辑
类比一个工厂，有多个操作车间
组合逻辑即， 每个车间之间互相通知各自的情况，比较混乱
时序逻辑即，每个车间按照时间安排完成自己的任务，更有序


8.ALUCtrl应该为几位，根据指令怎么分类
由opcode分出类型
每个类型由func3（大多），少数由func7决定出ALU操作
ALU操作可分为ADD、SUB、NOTEQ、XOR、OR、AND
SLT：Set Less Than 左小于右则置位
SLTU：无符号比较
SGE：反SLT
SGEU
SLL：Shift Left Logical 逻辑左移
SRL：Shift Right Logical
SRA：Shift Right Arithmatic
JUMP

9.如果寄存器组是读写时序逻辑，就会延迟
如果寄存器组读是组合，写是时序，则不会延迟

但是为什么通常写逻辑应该是时序逻辑？

解决：即使使用同步写异步读
第一，读不会影响机器状态，即不会造成根本性的影响，而写会
第二，如果存储器的写端口不止一个，有多个部件会进行写操作，那么如果不同步写，很可能造成覆盖等问题
第三，同步会更加稳定，且对于寄存器堆而言，同步写不会造成延迟影响

10.写寄存器的指令包含（RV32I）
Itype_J、Itype_L、Itype_A、Utype_L、Utype_A、Jtype_J、Rtype