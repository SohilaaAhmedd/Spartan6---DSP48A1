# Spartan6---DSP48A1
The Spartan-6 family offers a high ratio of DSP48A1 slices to logic, making it ideal for math intensive applications. Design DSP48A1 slice of the spartan6 FPGAs. 
General Notes: 
1. The 18-bit A, B, and D buses are concatenated in the following order: D[11:0], A[17:0], 
B[17:0]. 
2. The X and Z multiplexers are 48-bit designs. Multiplexer inputs less than 48-bits should 
be extended with zeros. 
3. The multiply-accumulate path for P is through the Z multiplexer. The P feedback 
through the X multiplexer enables accumulation of P cascade when the multiplier is 
not used. 
4. The gray-colored multiplexers are programmed at configuration time using parameters. 
The clear multiplexers are controlled by OPMODE inputs, allowing dynamic changes to 
functionality. 
5. The C register supports multiply-add or wide addition operations. 
6. Enabling SUBTRACT implements Z – (X + CIN) at the output of the post-adder/ 
subtracter. 
7. B input can be added or subtracted from the D input using the pre-adder/subtracter. 
Enabling SUBTRACT implements D – B at the output of the pre-adder/subtracter. 
8. CARRYOUTF is a copy of CARRYOUT but dedicated to applications in the FPGA 
logic, whereas CARRYOUT is the dedicated route to the adjacent DSP48A1 slice. 
9. The registered output of the multiplier or its direct output can be routed to the FPGA 
logic through a 36-bit vector called M. 
10. The BCIN input is the direct cascade from the adjacent DSP48A1 BCOUT.
