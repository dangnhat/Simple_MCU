module controller (
	clock, nRst,
	
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

	/* Parameters */

	/* opcode */
	parameter NOP = 5'h00;
	parameter ADD = 5'h01;
	parameter SUB = 5'h02;
	parameter MUL = 5'h03;
	parameter DIV = 5'h04;
	parameter AND = 5'h05;
	parameter OR = 5'h06;
	parameter NOT = 5'h07;
	parameter XOR = 5'h08;
	parameter SHL = 5'h09;
	parameter SHR = 5'h0A;
	parameter CMP = 5'h0B;
	parameter JMP = 5'h0C;
	parameter JR = 5'h0D;
	parameter JAL = 5'h0E;
	parameter BT = 5'h0F;
	parameter BF = 5'h10;
	parameter LI = 5'h11;
	parameter LD = 5'h12;
	parameter STR = 5'h13;
	parameter RET = 5'h14;
	parameter RSEG = 5'h15;
	parameter WSEG = 5'h16;

	/******************* states *******************/
	parameter S_Idle = 0, S_IF1 = 1, S_DecEx = 2, S_MulDiv2 = 3, S_J2 = 4, S_Jal2 = 5, S_Halt = 6;

	/******************* IOs, SFRs addr ***********/
	parameter IOSegAddr = 8'h3;
	parameter LEDLAddr = 8'h00;
	parameter LEDHAddr = 8'h01;
	parameter BTNLAddr = 8'h02;
	parameter BTNHAddr = 8'h03;
	parameter StatusAddr = 8'h10;

	/******************* sizes ********************/
	parameter regFile_addrSize = 3;
	parameter busSize = 16;
	parameter dataWordSize = 8;

	/******************* output *******************/
	output reg [regFile_addrSize-1 : 0] a1, a2, aWrite; //RegFile
	output reg selMuxDataReg; //MuxDataReg
	output reg loadB2MB; //bus2MuxBuffer
	output reg loadReg; //RegFile
	output reg incPC, loadPCL, loadPCH; //PC
	output reg loadIRL, loadIRH; //IR
	output [1:0] selMux1; //Mux1
	output [2:0] selMux2; //Mux2
	output reg loadLR, loadSR; //LR, SR
	output reg iWrite, dWrite; // memory
	output reg loadLEDH, loadLEDL; //Led
	output [4:0] opcode; //ALU
	output [1:0] func; //ALU
	output reg loadStatus; //Status
	
	output reg flag; // for debug purpose

	/****************** inputs ********************/
	input clock, nRst;

	input [dataWordSize-1 : 0] SROut;
	input [busSize-1 : 0] IROut;
	input [dataWordSize-1 : 0] StatusOut;

	/****************** wire **********************/
	reg [3:0] state, next_state;
	wire OV, C, B, T, Z, DIV0;
	wire [2:0] rd, r1, r2;
	wire [7:0] im;
	reg selOut2, selPC, selIRL; // mux1
	reg selALUOut, selBTNL, selBTNH, selSR, selBus1, selLR, selIMem, selDMem; // mux2
	
	assign opcode = IROut [15 : 11];
	assign rd = IROut [10:8];
	assign r1 = IROut [7:5];
	assign r2 = IROut [4:2];
	assign func = IROut [1:0];
	assign im = IROut[7:0];
	
	assign DIV0 = StatusOut [0];
	assign Z = StatusOut [1];
	assign T = StatusOut [2];
	assign B = StatusOut [3];
	assign C = StatusOut [4];
	assign OV = StatusOut [5];
	
	assign selMux1 = selOut2 ? 2'd0 : selPC ? 2'd1 : selIRL ? 2'd2 : 2'd3;
	assign selMux2 = 	selALUOut ? 3'd0 :
							selBTNL ? 3'd1 :
							selBTNH ? 3'd2 :
							selSR ? 3'd3 :
							selBus1 ? 3'd4 :
							selLR ? 3'd5 :
							selIMem ? 3'd6 :
							selDMem ? 3'd7 : 3'd0;
	
	always @ (posedge clock)
	begin
		if (nRst == 0) state <= S_Idle;
		else
			state <= next_state;	
	end
	
	always @ (state or opcode or r1 or r2 or rd or T or SROut or im)	
	begin 
		/* reset all control pin */
		a1 = 0; a2 = 0; aWrite = 0; loadReg = 0; selMuxDataReg = 0; loadB2MB = 0;
		incPC = 0; loadPCL = 0; loadPCH = 0;
		loadIRH = 0; loadIRL = 0;
		selOut2 = 0; selPC = 0; selIRL = 0;
		selALUOut = 0; selBTNL = 0; selBTNH = 0; selSR = 0; selBus1 = 0; selLR = 0; selIMem = 0; selDMem = 0;
		loadSR = 0;
		loadLR = 0;
		iWrite = 0; dWrite = 0;
		loadLEDL = 0; loadLEDH = 0;
		loadStatus = 0;
		flag = 1;
		
		case (state)
			S_Idle : next_state = S_IF1;
			S_IF1 : 
				begin
				next_state = S_DecEx;
				
				selIMem = 1;
				loadIRH = 1;
				loadIRL = 1;
				incPC = 1;
				end
			S_DecEx :
				begin
				case (opcode) 
					NOP : next_state = S_IF1;
					
					ADD, SUB, AND, OR, XOR, SHR, SHL:
						begin
						next_state = S_IF1;
						
						a1 = r1;
						a2 = r2;
						aWrite = rd;
						loadStatus = 1;
						selOut2 = 1;
						selALUOut = 1;
						selMuxDataReg = 0;
						loadReg = 1;
						end
					
					NOT:
						begin
						next_state = S_IF1;
						
						a1 = r1;
						aWrite = rd;
						loadStatus = 1;
						loadReg = 1;
						selMuxDataReg = 0;
						selALUOut = 1;
						end
					
					MUL, DIV:
						begin 
						next_state = S_MulDiv2;
						
						a1 = r1;
						a2 = r2;
						aWrite = rd;
						selMuxDataReg = 0;
						loadB2MB = 1;
						loadReg = 1;
						selOut2 = 1;
						selALUOut = 1; // fixed
						loadStatus = 1;
						
						end
					
					CMP:
						begin
						next_state = S_IF1;
						
						a1 = r1;
						a2 = r2;
						loadStatus = 1;
						selOut2 = 1;
						
						end
					
					JMP:
						begin
						next_state = S_J2;
						
						selIRL = 1;
						selBus1 = 1;
						loadPCL = 1;
					
						end
					
					JR:
						begin
						next_state = S_J2;
						
						a2 = rd;
						selOut2 = 1;
						selBus1 = 1;
						loadPCL = 1;					
						end
					
					JAL:
						begin
						next_state = S_Jal2;
						
						selPC = 1;
						loadLR = 1;
						end
					
					BT :
						begin
						if (T == 1)
							begin
							selIRL = 1;
							selBus1 = 1;
							loadPCL = 1;
							
							next_state = S_J2;
							end
						else
							next_state = S_IF1;
						end
					
					BF :
						begin
						if (T == 0)
							begin
							selIRL = 1;
							selBus1 = 1;
							loadPCL = 1;
							
							next_state = S_J2;
							end
						
						else
							next_state = S_IF1;
						end	
					
					LI :
						begin
						selIRL = 1;
						selBus1 = 1;
						selMuxDataReg = 0;
						aWrite = rd;
						loadReg = 1;
						
						next_state = S_IF1;						
						end
					
					STR:
						begin
						if ( SROut == IOSegAddr )
							begin
							if ( (im == LEDLAddr) || (im == LEDHAddr) )
								begin
								a2 = rd;
								selOut2 = 1;
								selBus1 = 1;
								if (im == LEDLAddr) loadLEDL = 1;
								else begin  loadLEDH = 1; flag = 1; /* debug */ end
							
								next_state = S_IF1;
								end
							
							else 
								next_state = S_IF1;
						
							end //end IOSegAddr
						
						else //memAddr
							begin
							a2 = rd;
							selOut2 = 1;
							dWrite = 1;
						
							next_state = S_IF1;
							end
						end // end STR
					
					LD:
						begin
						if (SROut == IOSegAddr)
							begin
							if ( (im == BTNLAddr) || (im == BTNHAddr) )
								begin
								next_state = S_IF1;
								
								if (im == BTNLAddr) selBTNL = 1;
								else selBTNH = 1;									
								aWrite = rd;
								selMuxDataReg = 0;
								loadReg = 1;
							
								end
							
							else 
								next_state = S_IF1;
							
							end// end IOAddr
						
						else // memAddr
							begin
							next_state = S_IF1;
							
							selDMem = 1;
							selMuxDataReg = 0;
							aWrite = rd;
							loadReg = 1;
						
							end
					
						end // end LD
					
					RET:
						begin
						next_state = S_IF1;
						
						selLR = 1;
						loadPCL = 1;
						loadPCH = 1;
						end
					
					RSEG:
						begin
						next_state = S_IF1;
						
						selSR = 1;
						aWrite = rd;
						loadReg = 1;
						
						end
					
					WSEG:
						begin
						next_state = S_IF1;
						
						a2 = rd;
						selOut2 = 1;
						loadSR = 1;
						
						end					
					default:
						next_state = S_Halt;
						
				endcase //opcode					
				end //end S_DecEx
				
				S_MulDiv2:
					begin
					next_state = S_IF1;
					
					aWrite = r1; //fixed
					selMuxDataReg = 1;
					loadReg = 1;
					
					end // end S_MulDiv2
					
				S_J2:
					begin
					next_state = S_IF1;
					
					selSR = 1;
					loadPCH = 1;
					
					end // end S_J2
				
				S_Jal2:
					begin
					next_state = S_J2;
					
					selIRL = 1;
					selBus1 = 1;
					loadPCL = 1;
					
					end // end S_Jal2
				
				S_Halt: next_state = S_Halt;
				default: next_state = S_Idle;
		endcase
	end // end always
endmodule





   