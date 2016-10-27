module simpleCPU (SW, LEDR, LEDG, CLOCK_50, CLOCK_27, TD_RESET);

input [17 : 0] SW;
input CLOCK_50, CLOCK_27;
output TD_RESET;
output [17 : 0] LEDR;
output [7:0] LEDG;

wire [2:0] a1 , a2, aWrite; //RegFile
wire selMuxDataReg; //MuxDataReg
wire loadReg; //RegFile
wire incPC, loadPCL, loadPCH; //PC
wire loadIRL, loadIRH; //IR
wire [1:0] selMux1; //Mux1
wire [2:0] selMux2; //Mux2
wire iWrite, dWrite; // memory
wire loadLEDH, loadLEDL; //Led
wire [7:0] BTNHDin, BTNLDin; //Btn
wire loadB2MB, loadLR, loadSR; //B2MB, LR, SR
wire [4:0] opcode;
wire [1:0] func; //ALU
wire loadStatus; //status reg
wire flag;
wire clock, nRst;

wire [7:0] StatusOut;
wire [7:0] SROut;
wire [15:0] IROut;
wire [7:0] LEDHROut, LEDLROut;

assign clock = CLOCK_27;
assign TD_RESET = 1;
//assign LEDR[16] = CLOCK_27;
//clockdiv2 uClock (CLOCK_50, nRst, clock);
assign nRst = SW[16];
assign BTNHDin = SW[15:8];
assign BTNLDin = SW[7:0];
//assign LEDG[7:0] = StatusOut;
assign LEDR[15:8] = LEDHROut;
assign LEDR[7:0] = LEDLROut;
assign LEDR[17] = flag;

controller u1 (
	clock , nRst,
	
	StatusOut,
	SROut,
	IROut,
	
	a1, a2, aWrite, //RegFile
	selMuxDataReg, //MuxDataReg
	loadReg, //RegFile
	incPC, loadPCL, loadPCH, //PC
	loadIRL, loadIRH, //IR
	selMux1, //Mux1
	selMux2, //Mux2
	iWrite, dWrite, // memory
	loadLEDH, loadLEDL, //Led
	loadB2MB, loadLR, loadSR, //B2MB, LR, SR
	opcode, func, //ALU
	loadStatus, //status reg
	flag
);

datapath u2 (
	clock, nRst,
	a1, a2, aWrite, //RegFile
	selMuxDataReg, //MuxDataReg
	loadReg, //RegFile
	incPC, loadPCL, loadPCH, //PC
	loadIRL, loadIRH, //IR
	selMux1, //Mux1
	selMux2, //Mux2
	iWrite, dWrite, // memory
	loadLEDH, loadLEDL, //Led
	BTNHDin, BTNLDin, //Btn
	loadB2MB, loadLR, loadSR, //B2MB, LR, SR
	opcode, func, //ALU
	loadStatus, //status reg
	
	StatusOut,
	SROut,
	IROut,
	LEDHROut, LEDLROut
);

endmodule

//module clockdiv2 (clockin, clockout);
//	input clockin;
//	output reg clockout;
//	
//	always @ (posedge clockin)
//		begin
//		if (nRst == 0)
//			clockout = 0;
//		else
//			clockout <= ~clockout;
//		end
//		
//endmodule
