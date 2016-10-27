//module testbench_PC ();
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
//
//endmodule

module testbench_PC ();



endmodule
