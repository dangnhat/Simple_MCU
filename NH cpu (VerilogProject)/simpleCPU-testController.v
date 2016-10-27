module simpleCPU (SW, LEDR, LEDG);

input [17 : 0] SW;
output [17 : 0] LEDR;
output [7:0] LEDG;

wire [7:0] StatusOut;
wire [4:0] opcode;
wire [2:0] rd, r1, r2;
wire [1:0] func;
wire [7:0] im;
wire [15:0] IROut;
wire [7:0] SROut;

//assign IROut = {opcode, rd, r1, r2, func};
assign IROut = {opcode, rd, im};
assign opcode = 5'h11;
assign rd = 3'h01;
assign r1 = 3'h00;
assign r2 = 3'h00;
assign func = 2'h00;
assign im = 8'hff;

assign StatusOut = 8'h00;
assign SROut = 8'h00;

controller u1 (
	.clock (SW[17]), .nRst(SW[16]),
	
	.StatusOut (StatusOut),
	.SROut (SROut),
	.IROut (IROut),
	
	.a1(), .a2(), .aWrite(), //RegFile
	.selMuxDataReg(LEDR[0]), //MuxDataReg
	.loadReg(LEDR[1]), //RegFile
	.incPC(LEDR[2]), .loadPCL(LEDR[3]), .loadPCH(LEDR[4]), //PC
	.loadIRL(LEDR[5]), .loadIRH(LEDR[6]), //IR
	.selMux1(LEDR[8:7]), //Mux1
	.selMux2(LEDR[11:9]), //Mux2
	.loadSR(LEDR[12]), //SR
	.iWrite(LEDR[13]), .dWrite(LEDR[14]), // memory
	.loadLEDH(LEDR[15]), .loadLEDL(LEDR[16]), //Led
	.loadB2MB(LEDR[17]), .loadLR(), .loadSR(), //B2MB, LR, SR
	.opcode(LEDG[7:3]), .func(LEDG[2:1]), //ALU
	.loadStatus(LEDG[0]) //status reg
);


endmodule
