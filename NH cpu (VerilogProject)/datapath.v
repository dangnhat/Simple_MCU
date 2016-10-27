module datapath (
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

parameter regFile_addrSize = 3;
parameter busSize = 16;
parameter dataWordSize = 8;

/* Inputs from controller and external components */
input clock, nRst;

input [regFile_addrSize-1 : 0] a1, a2, aWrite; //RegFile
input selMuxDataReg; //MuxDataReg
input loadB2MB; //bus2MuxBuffer
input loadReg; //RegFile
input incPC, loadPCL, loadPCH; //PC
input loadIRL, loadIRH; //IR
input [1:0] selMux1; //Mux1
input [2:0] selMux2; //Mux2
input loadLR, loadSR; //LR, SR
input iWrite, dWrite; // memory
input loadLEDH, loadLEDL; //Led
input [dataWordSize-1:0]BTNHDin, BTNLDin; //Btn
input [4:0] opcode; //ALU
input [1:0] func; //ALU
input loadStatus; //Status

/* output to controller or external components */
output [dataWordSize-1 : 0] SROut;
output [busSize-1 : 0] IROut;
output [busSize-1 : 0] LEDHROut, LEDLROut;
output [dataWordSize-1 : 0] StatusOut;

wire [dataWordSize - 1 : 0] out1, out2; // RegFile
wire [dataWordSize - 1 : 0] muxDataRegDin0, muxDataRegDin1, muxDataRegOut; //muxDataReg
wire [dataWordSize - 1 : 0] bus2MSBBuffDin, bus2MSBBuffOut; // bus2MSBBuffDin
wire [busSize - 1 : 0] PCOut; // PC, IR
wire [busSize - 1 : 0] mux1_din0, mux1_din1, mux1_din2, mux1_din3, mux1Out; //mux1
wire [busSize - 1 : 0] bus1, bus2; // bus
wire [dataWordSize - 1 : 0] SROut; //SR
wire [busSize - 1 : 0] LROut; // LR
wire [8:0] iAddr; //memory
wire [9:0] dAddr; //memory
wire [busSize - 1 : 0] iDin, iOut; //memory
wire [dataWordSize - 1 : 0] dDin, dOut; //memory;

wire [busSize - 1 : 0] mux2_din0, mux2_din1, mux2_din2, mux2_din3, mux2_din4, mux2_din5, mux2_din6, mux2_din7; // mux2
wire [busSize - 1 : 0] mux2Out; // mux2

wire [dataWordSize-1 : 0] BTNHOut, BTNLOut; //btn
wire loadBTNH, loadBTNL;

wire [busSize-1 : 0] ALUOut; //ALU
wire cin, OV, C, B, T, Z, DIV0; //ALU
wire [dataWordSize-1 : 0] StatusDin;

/* connect datapath components */
assign bus2MSBBuffDin = bus2 [15:8];
data_buffer bus2MSBBuff (bus2MSBBuffDin, loadB2MB, clock, nRst, bus2MSBBuffOut);
Mux_data_reg muxDataReg (bus2[7:0], bus2MSBBuffOut, selMuxDataReg, muxDataRegOut);
RegFile regFile (a1, a2, aWrite, muxDataRegOut, out1, out2, loadReg, clock, nRst);
program_counter PC (bus2, loadPCL, loadPCH, incPC, clock, nRst, PCOut);
instruction_reg IR (bus2, loadIRH, loadIRL, clock, nRst, IROut);

assign mux1_din0 = {8'h00, out2};
assign mux1_din1 = PCOut;
assign mux1_din2 = {8'h00, IROut[dataWordSize-1:0]};
assign mux1_din3 = 8'h00;
assign mux1Out = bus1;
Mux_x mux1 (mux1_din0, mux1_din1, mux1_din2, mux1_din3, selMux1, mux1Out);

segReg SR (bus1[dataWordSize-1:0], loadSR, clock, nRst, SROut);
linkReg LR (bus1, loadLR, clock, nRst, LROut);
LEDL_reg LEDHR (bus2[7:0], loadLEDH, clock, nRst, LEDHROut);
LEDL_reg LEDLR (bus2[7:0], loadLEDL, clock, nRst, LEDLROut);
BtnH_reg BTNHR (BTNHDin, loadBTNH, clock, nRst, BTNHOut);
BtnL_reg BTNLR (BTNLDin, loadBTNL, clock, nRst, BTNLOut);
assign loadBTNH = 1'b1;
assign loadBTNL = 1'b1;

assign iAddr = PCOut [9:1];
assign dAddr = { SROut[1:0], IROut [7:0] };
assign iDin = 16'h0000;
assign dDin = bus1[7:0];
RAM2port memory (iAddr, dAddr, clock, iDin, dDin, iWrite, dWrite, iOut, dOut);

ALU dpALU (out1, bus1[7:0], opcode, func, cin, nRst, ALUOut, OV, C, B, T, Z, DIV0);

assign StatusDin = {2'h00, OV, C, B, T, Z, DIV0};
status_reg Status (StatusDin, loadStatus, clock, nRst, StatusOut);

assign mux2_din0 = ALUOut;
assign mux2_din1 = {8'h00, BTNLOut};
assign mux2_din2 = {8'h00, BTNHOut};
assign mux2_din3 = {SROut, 8'h00};
assign mux2_din4 = bus1;
assign mux2_din5 = LROut;
assign mux2_din6 = iOut;
assign mux2_din7 = {8'h00, dOut};
assign bus2 = mux2Out;
Mux_y mux2 (mux2_din0, mux2_din1, mux2_din2, mux2_din3, mux2_din4, mux2_din5, mux2_din6, mux2_din7, selMux2, mux2Out);

endmodule
