module SHIFT_LEFT (dataa, datab, result);
	parameter word_size = 8;
	input [word_size-1:0] dataa, datab;
	output [word_size-1:0] result;
	
	assign result = dataa<<datab;

endmodule
