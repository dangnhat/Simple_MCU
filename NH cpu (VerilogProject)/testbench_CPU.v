module testbench_CPU ();
//parameter databus_width = 16;
//
//reg [databus_width-1 : 0] data_in;
//reg load, increase;
//reg clock, n_reset;
//wire [databus_width-1 : 0] data_out;
//
//program_counter u0 (data_in, load, increase, clock, n_reset, data_out);
//
//always #3 clock = ~clock;
//
//initial
//	begin
//	clock = 0;
//	data_in = 0;
//	load = 0;
//	increase = 0;
//	n_reset = 0;
//	
//	#1
//	n_reset = 1;
//	
//	#1 
//	load = 1;
//	
//	#1
//	data_in = 23;
//	
//	#3
//	load = 0;
//	increase = 1;
//	
//	#10
//	n_reset = 0;
//
//	#10
//	$stop;
//	end

reg in, clk;
reg out;
reg start;

always @(clk)
begin
start = 0;
end

always @(start)
begin
if (in == 1)
out =0;
end

always #3 clk = ~clk;

initial
begin
clk = 0;
in = 0;

#1
in = 1;

#10 
in = 0;
end

endmodule