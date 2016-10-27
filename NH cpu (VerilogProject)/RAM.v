module RAM (address, write, clock, data_in, data_out);
parameter address_width = 16;
parameter data_width = 8;

input [address_width-1 : 0] address;
input write, clock;
input [data_width-1 : 0] data_in;
output [data_width-1 : 0] data_out;

ram_16_8 u0 (address[9:0], clock, data_in, write, data_out);

endmodule
