/********************** Mux_x *********************************************/
module Mux_x (data_in_0, data_in_1, data_in_2, data_in_3, select, data_out);
parameter bus_width = 16;
parameter select_width = 2;

input [bus_width-1:0] data_in_0, data_in_1, data_in_2, data_in_3;
input [select_width-1:0] select;
output [bus_width-1:0] data_out;

mux_x u0 (data_in_0, data_in_1, data_in_2, data_in_3, select, data_out);

endmodule

/********************* Mux_y ***********************************************/
module Mux_y (data_in_0, data_in_1, data_in_2, data_in_3, data_in_4, data_in_5, data_in_6, data_in_7,
select, data_out);
parameter bus_width = 16;
parameter select_width = 4;

input [bus_width-1:0] data_in_0, data_in_1, data_in_2, data_in_3, data_in_4, data_in_5, data_in_6, data_in_7;
input [select_width-1:0] select;
output [bus_width-1:0] data_out;

//wire [bus_width-1:0] data_in_9, data_in_10, data_in_11, data_in_12, data_in_13, data_in_14, data_in_15;

mux8_16b u0 (data_in_0, data_in_1, data_in_2, data_in_3, data_in_4, data_in_5, data_in_6, data_in_7,
select, data_out);
//mux16_16b u0 (data_in_0, data_in_1, data_in_2, data_in_3, data_in_4, data_in_5, data_in_6, data_in_7, data_in_8,
//data_in_9, data_in_10, data_in_11, data_in_12, data_in_13, data_in_14, data_in_15,


endmodule

/********************* Mux_data_reg ****************************************/

module Mux_data_reg (data_in_0, data_in_1, select, data_out);
parameter bus_width = 8;
parameter select_width = 1;

input [bus_width-1:0] data_in_0, data_in_1;
input [select_width-1:0] select;
output [bus_width-1:0] data_out;

mux2_8b u0 (data_in_0, data_in_1, select, data_out);

endmodule

