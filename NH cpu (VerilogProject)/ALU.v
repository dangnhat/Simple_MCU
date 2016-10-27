module ALU (in1, in2, opcode, func, Cin, nRst, result, OV, C, B, T, Z, DIV0);

	parameter word_size = 8; 
	
	input [word_size-1:0] in1, in2; //8bits
	input [4:0] opcode;
	input [1:0] func;
	input Cin, nRst;
	
	output OV, C;
	output B, T, Z, DIV0;
	output reg [word_size*2-1:0] result; //16bits
	wire aeb, aneb, agb, alb;
	wire ov, c, br; //borrow.
	wire [word_size-1:0] sum, sub, quotient, remain, l_shift, r_shift;
	wire [word_size*2-1:0] product;
	
	parameter ADDp 		= 5'B00001; //1 
	parameter SUBp 		= 5'B00010; //2
	parameter MULp 		= 5'B00011; //3
	parameter DIVp 		= 5'B00100; //4
	parameter ANDp 		= 5'B00101; //5
	parameter ORp 			= 5'B00110; //6
	parameter NOTp 		= 5'B00111; //7
	parameter XORp 		= 5'B01000; //8
	parameter S_LEFTp 	= 5'B01001; //9
	parameter S_RIGHTp 	= 5'B01010; //A
	parameter COMPp 		= 5'B01011; //B
	
	ADD	 		U0(.cin(Cin), .dataa(in1), .datab(in2), .cout(c), .overflow(ov), .result(sum));
	SUB			U1(.dataa(in1), .datab(in2), .result(sub));
	MUL		 	U2(.dataa(in1), .datab(in2), .result(product));
	DIV 			U3(.numer(in1), .denom(in2), .quotient(quotient), .remain(remain));
	COMP 			U4(.dataa(in1), .datab(in2), .aeb(aeb), .aneb(aneb), .agb(agb), .alb(alb));
	SHIFT_LEFT  U5(.dataa(in1), .datab(in2), .result(l_shift));
	SHIFT_RIGHT U6(.dataa(in1), .datab(in2), .result(r_shift));
	
	assign B = nRst == 0 ? 1'b0 : ( opcode == 5'B00010 ? ( in2 > in1 ? 1'b1 : 1'b0) : B );
	assign T = nRst == 0 ? 1'b0 : ( opcode == 5'B01011 ? ( func == 2'B00 ? agb : ( func == 2'B01 ? alb : ( func == 2'B10 ? aeb : aneb ) ) ) : T );
	assign Z = nRst == 0 ? 1'b0 : ( opcode == 5'B00100 ? ~|quotient : ~|result );
	assign DIV0 = nRst == 0 ? 1'b0 : ( opcode == 5'B00100 ? (in2 == 8'H00 ? 1'b1 : 1'b0) : DIV0 );
	assign OV = nRst == 0 ? 1'b0 : (opcode == ADDp ? ov : OV );
	assign C = nRst == 0 ? 1'b0 : (opcode == ADDp ? c : C);
 
	always @(in1 or in2 or opcode or sum or sub or product or quotient or remain or l_shift or r_shift)
		begin				
		case(opcode)
			ADDp:
				begin result = sum; end
			SUBp:
				begin result = sub; end
			MULp: 
				begin result = product; end
			DIVp: 
				begin result = {remain, quotient}; end
			ANDp: 
				begin result = in1&in2; end
			ORp:
				begin result = in1|in2; end
			NOTp:
				begin result = {8'H00, ~in1}; end
			XORp:
				begin result = in1^in2; end
			S_LEFTp: 
				begin result = l_shift; end
			S_RIGHTp:
				begin result = r_shift; end
			default: begin result = 8'Hxx; end
		endcase
		end
		
//		function zero;
//			input [4:0] opcode;
//			input nRst;
//			
//			if (nRst == 0)
//				zero = 0;
//			else
//				if(opcode == 5'B00100) zero = ~|quotient;
//				else zero = ~|result;
//		endfunction
		
//		function compare; 
//			input [4:0] opcode;
//			input nRst;
//			
//			if (nRst == 0)
//				compare = 0;
//			
//			else
//				if(opcode == 5'B01011)
//					begin
//						if(func == 2'B00) compare = agb;
//						else if(func == 2'B01) compare = alb;
//						else if(func == 2'B10) compare = aeb;
//						else compare = aneb;
//					end
//				else compare = compare;
//		endfunction
//		
//		function divide_by_0;
//			input [4:0] opcode;
//			input nRst;
//			
//			if (nRst == 0)
//				divide_by_0 = 0;
//			else
//				if(opcode == 5'B00100 && in2 == 8'H00) divide_by_0 = 1;
//				else divide_by_0 = divide_by_0;
//		endfunction
//
//		function borrow;
//			input [4:0] opcode;
//			input nRst;
//			
//			if (nRst == 0)
//				borrow = 0;
//			else
//				if(opcode == 5'B00010 && in2 > in1) borrow = 1;
//				else borrow = borrow;
//		endfunction		
		
endmodule
	