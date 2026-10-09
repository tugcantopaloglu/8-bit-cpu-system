`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 06.07.2021 19:34:50
// Design Name: 
// Module Name: alu
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


module alu(
	input [3:0] alufn,
	input [7:0] ra,
	input [7:0] rb_or_imm,
	output reg [7:0] aluout,
	output reg br);
//iþlemlerin bit karþýlýlarýný atayýp iþlemleri yapýyoruz
parameter	ALU_OP_ADD	= 4'b0000,
			ALU_OP_SUB	= 4'b0001,
			ALU_OP_AND	= 4'b0010,
			ALU_OP_OR	= 4'b0011,
			ALU_OP_ADDI	= 4'b0100,
			ALU_OP_LW	= 4'b0101,
			ALU_OP_SW	= 4'b0110,
			ALU_OP_BEQ	= 4'b0111,
			//özel iþlem atamalarý
            ALU_OP_DADD = 4'b1100,
            ALU_OP_DSUB = 4'b1001,
            ALU_OP_DAND = 4'b1010,
            ALU_OP_DOR  = 4'b1011;
            
always @(*) 
begin
	aluout = 8'd0;
	br = 1'b0;
	case(alufn)
			ALU_OP_ADD 	: aluout = ra + rb_or_imm;
			ALU_OP_SUB 	: aluout = ra - rb_or_imm;
			ALU_OP_AND 	: aluout = ra & rb_or_imm;
			ALU_OP_OR	: aluout = ra | rb_or_imm;
			ALU_OP_ADDI	: aluout = ra + rb_or_imm;
			ALU_OP_LW	: aluout = ra + rb_or_imm;
			ALU_OP_SW	: aluout = ra + rb_or_imm;
			ALU_OP_BEQ	: begin
							br = (ra==rb_or_imm)?1'b1:1'b0; 
						  end
		    //özel iþlem atamalarý
		    ALU_OP_DADD 	: aluout = ra + (rb_or_imm + rb_or_imm);
		    ALU_OP_DSUB 	: aluout = ra - (rb_or_imm + rb_or_imm);
		    ALU_OP_DAND     : aluout = ra & rb_or_imm & rb_or_imm;
            ALU_OP_DOR      : aluout = ra | rb_or_imm | rb_or_imm;
		    
	endcase
end

endmodule
