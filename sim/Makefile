src = $(wildcard ~/design_r/rtl/*.v)

dir = ~/design_r/rtl

out.vvp:
	iverilog -s soc -o out.vvp -I $(dir) -L $(dir) $(src) 
