module DSP48A1(CLK,CEA,CEB,CEM,CEP,CEC,CED,CECARRYIN,CEOPMODE,
	RSTA,RSTB,RSTC,RSTCARRYIN,RSTD,RSTM,RSTOPMODE,RSTP,
	CARRYIN,OPMODE,A,B,D,C,BCIN,PCIN,M,P,CARRYOUT,CARRYOUTF,BCOUT,PCOUT);

//Parameters Definitions
parameter A0REG = 0;
parameter A1REG = 1;
parameter B0REG = 0;
parameter B1REG = 1;

parameter CREG = 1;
parameter DREG = 1;
parameter MREG = 1;
parameter PREG = 1;
parameter CARRYINREG = 1;
parameter CARRYOUTREG = 1;
parameter OPMODEREG = 1;

parameter CARRYINSEL = "OPMODE5";

parameter B_INPUT = "DIRECT";

parameter RSTTYPE = "SYNC";

//Inputs and Outputs Definitions
input CLK,CEA,CEB,CEM,CEP,CEC,CED,CECARRYIN,CEOPMODE;
input RSTA,RSTB,RSTC,RSTCARRYIN,RSTD,RSTM,RSTOPMODE,RSTP;
input CARRYIN;
input [7:0] OPMODE;

input [17:0] A,B,D;
input [47:0] C;

input [17:0] BCIN;
input [47:0] PCIN;

output reg [35:0] M;
output reg [47:0] P;

output reg CARRYOUT,CARRYOUTF;

output reg [17:0] BCOUT;
output reg [47:0] PCOUT;

//regs & wires Definitions
reg [17:0] A0reg,B0reg,Dreg,B1reg,A1reg,A0mux,B0mux,Dmux,B1mux,A1mux;
reg [47:0] Creg,Cmux;
reg [7:0] OPMODEreg,OPMODEmux;
reg [17:0] preAS,preASmux;
reg [36:0] mul_out,Mreg,Mmux;
reg CImux,CYIreg,CYImux;
reg CYO,CYOreg;
reg [47:0] Xmux,Zmux;
reg [47:0] POUT;
reg [47:0] postAS;
reg [47:0] Preg;

/*RTL Code*/

generate
	//////Sync RST//////
	if (RSTTYPE == "SYNC") begin
		always @(posedge CLK) begin
			if (RSTA) begin
				A0reg <= 0;
			end
			else if (CEA) begin
				A0reg <= A;
			end
			if (RSTB) begin
				B0reg <= 0;
			end
			else if (CEB) begin
				case(B_INPUT)
					"DIRECT": B0reg <= B;
					"CASCADE": B0reg <= BCIN;
					default: B0reg <= B;
				endcase
			end
			if (RSTC) begin
				Creg <= 0;
			end
			else if (CEC) begin
				Creg <= C;
			end
			if (RSTD) begin
				Dreg <= 0;
			end
			else if (CED) begin
				Dreg <= D;
			end
			if (RSTOPMODE) begin
				OPMODEreg <= 0;
			end
			else if (CEOPMODE) begin
				OPMODEreg <= OPMODE;
			end
		end

		always @(*) begin
			if (A0REG) begin
				A0mux = A0reg;
			end
			else begin
				A0mux = A;
			end
			if (B0REG) begin
				B0mux = B0reg;
			end
			else begin
				case(B_INPUT)
					"DIRECT": B0mux = B;
					"CASCADE": B0mux = BCIN;
					default: B0mux = B;
				endcase
			end
			if (CREG) begin
				Cmux = Creg;
			end
			else begin
				Cmux = C;
			end
			if (DREG) begin
				Dmux = Dreg;
			end
			else begin
				Dmux = D;
			end
			if (OPMODEREG) begin
				OPMODEmux = OPMODEreg;
			end
			else begin
				OPMODEmux = OPMODE;
			end
			if (OPMODEmux[6]) begin
				preAS = Dmux - B0mux;
			end
			else begin
				preAS = Dmux + B0mux;
			end
			if (OPMODEmux[4]) begin
				preASmux = preAS;
			end
			else begin
				preASmux = B0mux;
			end
		end

		always @(posedge CLK) begin
			if (RSTB) begin
				B1reg <= 0;
			end
			else if (CEB) begin
				B1reg <= preASmux;
			end
			if (RSTA) begin
				A1reg <= 0;
			end
			else if (CEA) begin
				A1reg <= A0mux;
			end
		end

		always @(*) begin
			if (B1REG) begin
				B1mux = B1reg;
			end
			else begin
				B1mux = preASmux;
			end
			BCOUT = B1mux;
			if (A1REG) begin
				A1mux = A1reg;
			end
			else begin
				A1mux = A0mux;
			end
			mul_out = B1mux * A1mux;
		end

		always @(posedge CLK) begin
			if (RSTM) begin
				Mreg <= 0;
			end
			else if (CEM) begin
				Mreg <= mul_out;
			end
		end

		always @(*) begin
			if (MREG) begin
				Mmux = Mreg;
			end
			else begin
				Mmux = mul_out;
			end
			M = Mmux;
		end

		always @(*) begin
			case(CARRYINSEL)
				"OPMODE5": CImux = OPMODEmux[5];
				"CARRYIN": CImux = CARRYIN;
				default: CImux = OPMODEmux[5];
			endcase
		end

		always @(posedge CLK) begin
			if (RSTCARRYIN) begin
				CYIreg <= 0;
			end
			else if (CECARRYIN) begin
				CYIreg <= CImux;
			end
		end

		always @(*) begin
			if (CARRYINREG) begin
				CYImux = CYIreg;
			end
			else begin
				CYImux = CImux;
			end
		end

		always @(*) begin
			POUT = PCOUT;
			case(OPMODEmux[1:0])
				2'b00: Xmux = 48'b0;
				2'b01: Xmux = Mmux;
				2'b10: Xmux = POUT;
				2'b11: Xmux = {Dmux[11:0],A1mux,B1mux};
			endcase

			case(OPMODEmux[3:2])
				2'b00: Zmux = 48'b0;
				2'b01: Zmux = PCIN;
				2'b10: Zmux = POUT;
				2'b11: Zmux = Cmux;
			endcase

			if (OPMODEmux[7]) begin
				{CYO,postAS} = Zmux - Xmux - CYImux;
			end
			else begin
				{CYO,postAS} = Zmux + Xmux + CYImux;
			end
		end

		always @(posedge CLK) begin
			if (RSTCARRYIN) begin
				CYOreg <= 0;
			end
			else if (CECARRYIN) begin
				CYOreg <= CYO;
			end
		end

		always @(*) begin
			if (CARRYOUTREG) begin
				CARRYOUT = CYOreg;
				CARRYOUTF = CYOreg;
			end
			else begin
				CARRYOUT = CYO;
				CARRYOUTF = CYO;
			end
		end

		always @(posedge CLK) begin
			if (RSTP) begin
				Preg <= 0;
			end
			else if (CEP) begin
				Preg <= postAS;
			end
		end

		always @(*) begin
			if (PREG) begin
				P = Preg;
				PCOUT = Preg;
			end
			else begin
				P = postAS;
				PCOUT = postAS;
			end
		end
	end

	//////Async RST//////
	else if (RSTTYPE == "ASYNC") begin
		always @(posedge CLK or posedge RSTA or posedge RSTB or posedge RSTC or posedge RSTD or posedge RSTOPMODE) begin
			if (RSTA) begin
				A0reg <= 0;
			end
			else if (CEA) begin
				A0reg <= A;
			end
			if (RSTB) begin
				B0reg <= 0;
			end
			else if (CEB) begin
				case(B_INPUT)
					"DIRECT": B0reg <= B;
					"CASCADE": B0reg <= BCIN;
					default: B0reg <= B;
				endcase
			end
			if (RSTC) begin
				Creg <= 0;
			end
			else if (CEC) begin
				Creg <= C;
			end
			if (RSTD) begin
				Dreg <= 0;
			end
			else if (CED) begin
				Dreg <= D;
			end
			if (RSTOPMODE) begin
				OPMODEreg <= 0;
			end
			else if (CEOPMODE) begin
				OPMODEreg <= OPMODE;
			end
		end

		always @(*) begin
			if (A0REG) begin
				A0mux = A0reg;
			end
			else begin
				A0mux = A;
			end
			if (B0REG) begin
				B0mux = B0reg;
			end
			else begin
				case(B_INPUT)
					"DIRECT": B0mux = B;
					"CASCADE": B0mux = BCIN;
					default: B0mux = B;
				endcase
			end
			if (CREG) begin
				Cmux = Creg;
			end
			else begin
				Cmux = C;
			end
			if (DREG) begin
				Dmux = Dreg;
			end
			else begin
				Dmux = D;
			end
			if (OPMODEREG) begin
				OPMODEmux = OPMODEreg;
			end
			else begin
				OPMODEmux = OPMODE;
			end
			if (OPMODEmux[6]) begin
				preAS = Dmux - B0mux;
			end
			else begin
				preAS = Dmux + B0mux;
			end
			if (OPMODEmux[4]) begin
				preASmux = preAS;
			end
			else begin
				preASmux = B0mux;
			end
		end

		always @(posedge CLK or posedge RSTB or posedge RSTA) begin
			if (RSTB) begin
				B1reg <= 0;
			end
			else if (CEB) begin
				B1reg <= preASmux;
			end
			if (RSTA) begin
				A1reg <= 0;
			end
			else if (CEA) begin
				A1reg <= A0mux;
			end
		end

		always @(*) begin
			if (B1REG) begin
				B1mux = B1reg;
			end
			else begin
				B1mux = preASmux;
			end
			BCOUT = B1mux;
			if (A1REG) begin
				A1mux = A1reg;
			end
			else begin
				A1mux = A0mux;
			end
			mul_out = B1mux * A1mux;
		end

		always @(posedge CLK or posedge RSTM) begin
			if (RSTM) begin
				Mreg <= 0;
			end
			else if (CEM) begin
				Mreg <= mul_out;
			end
		end

		always @(*) begin
			if (MREG) begin
				Mmux = Mreg;
			end
			else begin
				Mmux = mul_out;
			end
			M = Mmux;
		end

		always @(*) begin
			case(CARRYINSEL)
				"OPMODE5": CImux = OPMODEmux[5];
				"CARRYIN": CImux = CARRYIN;
				default: CImux = OPMODEmux[5];
			endcase
		end

		always @(posedge CLK or posedge RSTCARRYIN) begin
			if (RSTCARRYIN) begin
				CYIreg <= 0;
			end
			else if (CECARRYIN) begin
				CYIreg <= CImux;
			end
		end

		always @(*) begin
			if (CARRYINREG) begin
				CYImux = CYIreg;
			end
			else begin
				CYImux = CImux;
			end
		end

		always @(*) begin
			POUT = PCOUT;
			case(OPMODEmux[1:0])
				2'b00: Xmux = 48'b0;
				2'b01: Xmux = Mmux;
				2'b10: Xmux = POUT;
				2'b11: Xmux = {Dmux[11:0],A1mux,B1mux};
			endcase

			case(OPMODEmux[3:2]) 
				2'b00: Zmux = 48'b0;
				2'b01: Zmux = PCIN;
				2'b10: Zmux = POUT;
				2'b11: Zmux = Cmux;
			endcase

			if (OPMODEmux[7]) begin
				{CYO,postAS} = Zmux - Xmux - CYImux;
			end
			else begin
				{CYO,postAS} = Zmux + Xmux + CYImux;
			end
		end

		always @(posedge CLK or posedge RSTCARRYIN) begin
			if (RSTCARRYIN) begin
				CYOreg <= 0;
			end
			else if (CECARRYIN) begin
				CYOreg <= CYO;
			end
		end

		always @(*) begin
			if (CARRYOUTREG) begin
				CARRYOUT = CYOreg;
				CARRYOUTF = CYOreg;
			end
			else begin
				CARRYOUT = CYO;
				CARRYOUTF = CYO;
			end
		end

		always @(posedge CLK or posedge RSTP) begin
			if (RSTP) begin
				Preg <= 0;
			end
			else if (CEP) begin
				Preg <= postAS;
			end
		end

		always @(*) begin
			if (PREG) begin
				P = Preg;
				PCOUT = Preg;
			end
			else begin
				P = postAS;
				PCOUT = postAS;
			end
		end
	end
endgenerate

endmodule