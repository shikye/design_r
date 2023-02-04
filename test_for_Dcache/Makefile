src = $(wildcard ./*.v)
rtl_dir = ../rtl

compile_tb:
	iverilog -s tb -o out.vvp -I $(rtl_dir)  $(src) 

run:
	vvp out.vvp

clean:
	rm -rf *.vvp *.vcd

.PHONY: compile_tb clean run
