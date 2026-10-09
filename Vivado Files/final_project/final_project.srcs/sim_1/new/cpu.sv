`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 06.07.2021 19:50:34
// Design Name: 
// Module Name: cpu
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module cpu();
//clk'larý 8 bit cpuya atýyor (tb inputlarý dosyadan okunuyor)
reg clk,clk2;

eight_bit_cpu cpu(.clk(clk),.clk2(clk2));

initial
	begin
		clk<=0;
		clk2<=0;
		#699
		if (cpu.regfile.reg_array[0] !== 8'd30 ||
		    cpu.regfile.reg_array[1] !== 8'd30 ||
		    cpu.regfile.reg_array[2] !== 8'd60 ||
		    cpu.regfile.reg_array[3] !== 8'd0 ||
		    cpu.regfile.reg_array[4] !== 8'd0 ||
		    cpu.regfile.reg_array[5] !== 8'd0 ||
		    cpu.regfile.reg_array[6] !== 8'd0 ||
		    cpu.regfile.reg_array[7] !== 8'd0 ||
		    cpu.pc_current !== 8'd3)
		    $fatal(1, "Sample program produced unexpected CPU state");
		#2
		$display("PASS: sample program");
		$finish;
	end
always 
	begin
		#5 clk = ~clk;
		#30 clk2 = ~clk2;
	end
endmodule
