1. 编译器iverilog完成的工作：

   将rtl源代码编译成可用于仿真的可执行文件(vvp)/netlist/可用于综合的fpga类型文件。   

---

2. iverilog常用选项

- -c  $\underline{file}$，-f  $\underline{file}$。file中存储源文件名



- -D $\underline{macro}$。将文件中定义的$\underline{macro}$置为1，用于配合``ifdef`。

  -D $\underline{macro=defn}$，用于在命令行中定义宏。



- -P $\underline{parameter=value}$。覆写root模块中某parameter的值。



- -d $\underline{name}$。调试相关。



- -E。预处理，将include和宏替换。



- -g $\underline{xx}$。选择verilog语法版本。



- -I$\underline{includedir}$。将includedir包含进头文件搜索目录中。



- -L $\underline{path}$。path用于定位VPI模块。

  VPI：Verilog Procedural Interface，针对C的verilog接口，提供一套C函数来为Verilog相关功能提供服务，如$xx也是VPI。



- -l $\underline{file}$。标志file为库模块，不会单独elaborate，只有当其他模块实例化它时，才会层次化。



- -y $\underline{libdir}$。将libdir加入库模块搜索路径。



- -S 综合。

- -s 设置root模块。

