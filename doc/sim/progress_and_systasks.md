## elaboration

​	在elaboration阶段，会建立起一套scope。从每个root module（例如testbench中，tb就是root module）开始一套scope，每个实例都在其父域中创建一个新域。

​	每个模块、对象，都有从root开始的层级名。

---

## VCD Value Change Dump

用于读取由EDA仿真产生的信号改变信息。

包含：头信息（日期、仿真器、时间精度），变量定义，值变化信息。	

---

### 1.readmemh系统任务

`$readmemh/b("<文件名>","<存储器名>")`

每组数据之间用空格隔开即可，注释用//分开。


### 2.dumpfile系统任务

`$dumpfile`和`$dumpvars`创建并将指定信息导入VCD中。



用法：

1.`$dumpfile("filename")`

2.`$dumpvars(level,module_name)`

- (0,top_module)：top模块及其以下模块中所有信号。

- (1,top_module)：top模块中所有信号。

  (2,top_module)：top模块下一层中所有信号。

- (2,top_module.module1)：module1下一层中所有信号。

- (x,top_module.signal1)：指定top_module中的signal1信号。

- (3,top_module.signal1,top_module.module1)：联合两种方式。

- 只dumpvars，所有参数都记录。



​		