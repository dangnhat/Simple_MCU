module RegFile (a1, a2, aWrite, dataIn, out1, out2, load, clk, nRst);
parameter AddrBusWidth = 3;
parameter DataBusWidth = 8;

input [AddrBusWidth-1:0] a1, a2, aWrite;
input load, clk, nRst;
input [DataBusWidth-1:0] dataIn;
output [DataBusWidth-1:0] out1, out2;

reg [DataBusWidth-1:0] data0, data1, data2, data3, data4, data5, data6, data7;
reg [DataBusWidth-1:0] out1, out2;

always @ (data0 or data1 or data2 or data3 or data4 or data5 or data6 or data7 or a1 or a2)
begin
	case (a1)
	0 : out1 = data0;
	1 : out1 = data1;
	2 : out1 = data2;
	3 : out1 = data3;
	4 : out1 = data4;
	5 : out1 = data5;
	6 : out1 = data6;
	7 : out1 = data7;
	endcase
	
	case (a2)
	0 : out2 = data0;
	1 : out2 = data1;
	2 : out2 = data2;
	3 : out2 = data3;
	4 : out2 = data4;
	5 : out2 = data5;
	6 : out2 = data6;
	7 : out2 = data7;
	endcase
end

always @ (posedge clk)
begin
	if (nRst == 0) 
		begin 
		data0 <= 0;
		data1 <= 0;
		data2 <= 0;
		data3 <= 0;
		data4 <= 0;
		data5 <= 0;
		data6 <= 0;
		data7 <= 0;
		end
	else
		begin
		if (load == 1)
			begin
			case (aWrite)
			0 : data0 <= dataIn;
			1 : data1 <= dataIn;
			2 : data2 <= dataIn;
			3 : data3 <= dataIn;
			4 : data4 <= dataIn;
			5 : data5 <= dataIn;
			6 : data6 <= dataIn;
			7 : data7 <= dataIn;				
			endcase
			
			end /* end if */
		
		end /* end if */
	
end/* end always */

endmodule