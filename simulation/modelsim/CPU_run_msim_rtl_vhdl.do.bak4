transcript on
if {[file exists rtl_work]} {
	vdel -lib rtl_work -all
}
vlib rtl_work
vmap work rtl_work

vcom -93 -work work {C:/EE224 project/CPU/clock_divider_tb.vhd}
vcom -93 -work work {C:/EE224 project/CPU/CPU.vhd}
vcom -93 -work work {C:/EE224 project/CPU/ALU.vhd}
vcom -93 -work work {C:/EE224 project/CPU/SE9_shifter.vhd}
vcom -93 -work work {C:/EE224 project/CPU/SE6.vhd}
vcom -93 -work work {C:/EE224 project/CPU/MUX_4x2.vhd}
vcom -93 -work work {C:/EE224 project/CPU/MUX_2x1.vhd}
vcom -93 -work work {C:/EE224 project/CPU/Memory.vhd}
vcom -93 -work work {C:/EE224 project/CPU/SE6_Shifter.vhd}
vcom -93 -work work {C:/EE224 project/CPU/Register File.vhd}
vcom -93 -work work {C:/EE224 project/CPU/Register.vhd}

vcom -93 -work work {C:/EE224 project/CPU/clock_divider_tb.vhd}

vsim -t 1ps -L altera -L lpm -L sgate -L altera_mf -L altera_lnsim -L fiftyfivenm -L rtl_work -L work -voptargs="+acc"  clock_divider_tb

add wave *
view structure
view signals
run -all
