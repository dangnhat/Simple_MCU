/****************** program_counter ***********************/
module program_counter (data_in, loadL, loadH, increase, clock, n_reset, data_out);
parameter databus_width = 16;
parameter dataWord_width = 8;

input [databus_width-1 : 0] data_in;
input loadL, loadH, increase;
input clock, n_reset;
output [databus_width-1 : 0] data_out;

reg [databus_width-1 : 0] data_internal;

assign data_out = data_internal;

always @ (posedge clock)
	begin
	if (n_reset == 0)
		data_internal <= 0;
	else
		begin
		if ((loadL == 1) || (loadH == 1))
			begin
				if (loadL == 1) data_internal[7:0] <= data_in[7:0];
				else data_internal[7:0] <= data_internal[7:0] ;
				
				if (loadH == 1) data_internal[15:8] <= data_in[15:8];
				else data_internal[15:8] <= data_internal[15:8];
			end
		else
			begin
			if (increase == 1)
				data_internal <= data_internal + 16'd2;
			else data_internal <= data_internal;
			end /* end else */
		end /* end else */

	end /* end always */
	
endmodule

/****************** status_reg ***************************/
module status_reg (data_in, load, clock, n_reset, data_out);
parameter bus_width = 8;

input [bus_width-1 : 0] data_in;
input load;
input clock, n_reset;
output [bus_width-1 : 0] data_out;

simple_reg_8b u0 (data_in, load, clock, n_reset, data_out);

endmodule

/****************** link_reg *****************************/
module linkReg (data_in, load, clock, n_reset, data_out);
parameter bus_width = 16;

input [bus_width-1 : 0] data_in;
input load;
input clock, n_reset;
output [bus_width-1 : 0] data_out;

simple_reg_8b uL (data_in[7:0], load, clock, n_reset, data_out[7:0]);
simple_reg_8b uH (data_in[15:8], load, clock, n_reset, data_out[15:8]);

endmodule

/****************** data_buffer **************************/
module data_buffer (data_in, load, clock, n_reset, data_out);
parameter bus_width = 8;

input [bus_width-1 : 0] data_in;
input load;
input clock, n_reset;
output [bus_width-1 : 0] data_out;

simple_reg_8b u0 (data_in, load, clock, n_reset, data_out);

endmodule

/****************** segReg **************************/
module segReg (data_in, load, clock, n_reset, data_out);
parameter bus_width = 8;

input [bus_width-1 : 0] data_in;
input load;
input clock, n_reset;
output [bus_width-1 : 0] data_out;

simple_reg_8b u0 (data_in, load, clock, n_reset, data_out);

endmodule

/****************** LEDH_reg *****************************/
module LEDH_reg (data_in, load, clock, n_reset, data_out);
parameter bus_width = 8;

input [bus_width-1 : 0] data_in;
input load;
input clock, n_reset;
output [bus_width-1 : 0] data_out;

simple_reg_8b u0 (data_in, load, clock, n_reset, data_out);

endmodule

/****************** LEDL_reg *****************************/
module LEDL_reg (data_in, load, clock, n_reset, data_out);
parameter bus_width = 8;

input [bus_width-1 : 0] data_in;
input load;
input clock, n_reset;
output [bus_width-1 : 0] data_out;

simple_reg_8b u0 (data_in, load, clock, n_reset, data_out);

endmodule

/****************** BtnH_reg *****************************/
module BtnH_reg (data_in, load, clock, n_reset, data_out);
parameter bus_width = 8;

input [bus_width-1 : 0] data_in;
input load;
input clock, n_reset;
output [bus_width-1 : 0] data_out;

simple_reg_8b u0 (data_in, load, clock, n_reset, data_out);

endmodule

/****************** BtnL_reg *****************************/
module BtnL_reg (data_in, load, clock, n_reset, data_out);
parameter bus_width = 8;

input [bus_width-1 : 0] data_in;
input load;
input clock, n_reset;
output [bus_width-1 : 0] data_out;

simple_reg_8b u0 (data_in, load, clock, n_reset, data_out);

endmodule

/****************** instruction_reg **********************/
module instruction_reg (data_in, load_H, load_L, clock, n_reset, data_out);
parameter bus_width = 16;

input [bus_width-1 : 0] data_in;
input load_H, load_L;
input clock, n_reset;
output reg [bus_width-1 : 0] data_out;

always @ (posedge clock)
begin
	if (n_reset == 0)
		data_out <= 0;
	else
	begin
		if (load_L == 1) data_out[7:0] <= data_in[7:0];
		else data_out[7:0] <= data_out[7:0] ;
		
		if (load_H == 1) data_out[15:8] <= data_in[15:8];
		else data_out[15:8] <= data_out[15:8];
	end

end

//simple_reg_8b uH ( data_in[bus_width-1 : bus_width-8], load_H, clock, n_reset, data_out[bus_width-1 : bus_width-8] );
//simple_reg_8b uL ( data_in[bus_width-9 : bus_width-16], load_L, clock, n_reset, data_out[bus_width-9 : bus_width-16] );

endmodule


/****************** simple_reg_8b *****************************/	
module simple_reg_8b (data_in, load, clock, n_reset, data_out);
parameter databus_width = 8;

input [databus_width-1 : 0] data_in;
input load;
input clock, n_reset;
output [databus_width-1 : 0] data_out;

reg [databus_width-1 : 0] data_out;

always @ (posedge clock)
	begin
	if (n_reset == 0)
		data_out = 0;
	else
		if (load == 1)
			data_out <= data_in;
		else
			data_out <= data_out;
	end

endmodule

