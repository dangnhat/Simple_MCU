module testbench_Reg ();
parameter AddrBusWidth = 2;
parameter DataBusWidth = 8;

reg [AddrBusWidth-1:0] a1, a2, aWrite;
reg load, clk, nRst;
reg [DataBusWidth-1:0] dataIn;
wire [DataBusWidth-1:0] out1, out2;

always #3 clk = ~clk;

RegFile u1 (a1, a2, aWrite, dataIn, load, out1, out2, clk, nRst);

initial
	begin
	clk = 0;
	a1 = 1; a2 = 2; load = 0; dataIn = 7'h0; aWrite = 2;
	#5 nRst = 0;
	#5 nRst = 1;
	#5 a1 = 3;
	#10 dataIn = 7'h56; aWrite = 2; load = 1;
	#3 load = 0;
	
	#20
	$stop;
	end

endmodule
