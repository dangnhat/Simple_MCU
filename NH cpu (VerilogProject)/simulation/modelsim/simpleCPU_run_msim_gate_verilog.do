transcript on
if {[file exists gate_work]} {
	vdel -lib gate_work -all
}
vlib gate_work
vmap work gate_work

vlog -vlog01compat -work work +incdir+. {simpleCPU.vo}

vlog -vlog01compat -work work +incdir+D:/Study/ComputerEngineering/Verilog-working/simpleCPU {D:/Study/ComputerEngineering/Verilog-working/simpleCPU/testbench_CPU.v}

vsim -t 1ps +transport_int_delays +transport_path_delays -L cycloneii_ver -L gate_work -L work -voptargs="+acc"  testbench_CPU

add wave *
view structure
view signals
run -all
