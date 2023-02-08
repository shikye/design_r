src = $(wildcard ../core_version_0/*.v)
rtl_dir = ../core_version_0
tb_dir = .

compile_tb:
	iverilog -s tb -o out.vvp -I $(rtl_dir)  $(src) tb.v 

run:
	vvp out.vvp

clean:
	rm -rf *.vvp *.vcd

.PHONY: compile_tb clean run
