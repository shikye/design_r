all:
	iverilog -s tb -o out.vvp ICache.v tb.v
	vvp out.vvp 
	gtkwave dump.vcd 

.PHONY:all
