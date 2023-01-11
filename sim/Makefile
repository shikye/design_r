src = $(wildcard ../rtl/*.v)
rtl_dir = ../rtl

compile_tb:
	iverilog -s tb -o out.vvp -I $(rtl_dir)  $(src) 


.PHONY: compile_tb
