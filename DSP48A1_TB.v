module DSP48A1_TB();

reg CLK,CEA,CEB,CEM,CEP,CEC,CED,CECARRYIN,CEOPMODE;
reg RSTA,RSTB,RSTC,RSTCARRYIN,RSTD,RSTM,RSTOPMODE,RSTP;
reg CARRYIN;
reg [7:0] OPMODE;

reg [17:0] A,B,D;
reg [47:0] C;

reg [17:0] BCIN;
reg [47:0] PCIN;

wire [35:0] M;
wire [47:0] P;

wire CARRYOUT,CARRYOUTF;

wire [17:0] BCOUT;
wire [47:0] PCOUT;

//DUT instantiation
DSP48A1 DUT(CLK,CEA,CEB,CEM,CEP,CEC,CED,CECARRYIN,CEOPMODE,
	RSTA,RSTB,RSTC,RSTCARRYIN,RSTD,RSTM,RSTOPMODE,RSTP,
	CARRYIN,OPMODE,A,B,D,C,BCIN,PCIN,M,P,CARRYOUT,CARRYOUTF,BCOUT,PCOUT);

//clk generation
initial begin
	CLK = 0;
	forever
		#1 CLK = ~CLK; 
end

//test
initial begin
	//2.1. Reset Functionality
	RSTA = 1;RSTB = 1;RSTC = 1;
	RSTCARRYIN = 1;RSTD = 1;
	RSTM = 1;RSTOPMODE = 1;RSTP = 1;

	CLK = $random;CEA = $random;
	CEB = $random;CEM = $random;
	CEP = $random;CEC = $random;
	CED = $random;CECARRYIN = $random;
	CEOPMODE = $random;

	CARRYIN = $random;OPMODE = $random;

	A = $random;B = $random;
	C = $random;D = $random;

	BCIN = $random;PCIN = $random;

	@(negedge CLK);

	if ((M != 0) || (P != 0) || (CARRYOUT != 0) || (CARRYOUTF != 0) || (PCOUT != 0) || (BCOUT != 0)) begin
		$display("error");
		$stop;
	end

	RSTA = 0;RSTB = 0;RSTC = 0;
	RSTCARRYIN = 0;RSTD = 0;
	RSTM = 0;RSTOPMODE = 0;RSTP = 0;

	CLK = 1;CEA = 1;
	CEB = 1;CEM = 1;
	CEP = 1;CEC = 1;
	CED = 1;CECARRYIN = 1;
	CEOPMODE = 1;

	//2.2. DSP path 1 
	A = 18'd20;B = 18'd10;
	C = 48'd350;D = 18'd25;

	OPMODE = 8'b11011101;

	BCIN = $random;PCIN = $random;CARRYIN = $random;

	repeat(4) @(negedge CLK);

	if ((M != 36'h12c) || (P != 48'h32) || (CARRYOUT != 0) || (CARRYOUTF != 0) || (PCOUT != 48'h32) || (BCOUT != 18'hf)) begin
		$display("error");
		$stop;
	end

	//2.3. DSP path 2 
	OPMODE = 8'b00010000;

	BCIN = $random;PCIN = $random;CARRYIN = $random;

	repeat(3) @(negedge CLK);

	if ((M != 36'h2bc) || (P != 48'h0) || (CARRYOUT != 0) || (CARRYOUTF != 0) || (PCOUT != 48'h0) || (BCOUT != 18'h23)) begin
		$display("error");
		$stop;
	end

	//2.4. DSP path 3 
	OPMODE = 8'b00001010;

	BCIN = $random;PCIN = $random;CARRYIN = $random;

	repeat(3) @(negedge CLK);

	if ((M != 36'hc8) || (P != 48'h0) || (CARRYOUT != 0) || (CARRYOUTF != 0) || (PCOUT != 48'h0) || (BCOUT != 18'ha)) begin
		$display("error");
		$stop;
	end

	//2.5. DSP path 4
	A = 18'd5;B = 18'd6;

	OPMODE = 8'b10100111;PCIN = 48'd3000;

	BCIN = $random;CARRYIN = $random;

	repeat(3) @(negedge CLK);

	if ((M != 36'h1e) || (P != 48'hfe6fffec0bb1) || (CARRYOUT != 1) || (CARRYOUTF != 1) || (PCOUT != 48'hfe6fffec0bb1) || (BCOUT != 18'h6)) begin
		$display("error");
		$stop;
	end
	$stop;
end

endmodule