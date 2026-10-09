`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 06.07.2021 19:45:09
// Design Name: 
// Module Name: control
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


module control (
				input [3:0] opcode,
				input [2:0] func,
				output reg reg_dst,
				output reg reg_write,
				output reg alusrc,
				output reg [3:0]alufn,
				output reg mem_write, 
				output reg mem_read,
				output reg mem_to_reg,
				output reg nia);
//decoder ile ayýrdýðýmýz bitleri burada instruction set'e göre iþlemlere sokup deðerleri belirliyoruz
always @(*) 
begin
	alufn = 4'b0000;
	alusrc = 1'b0;
	mem_to_reg = 1'b1;
	reg_dst = 1'b0;
	reg_write = 1'b0;
	mem_read = 1'b0;
	mem_write = 1'b0;
	nia = 1'b1;
	if (opcode == 4'b0000) 
	begin
		if (func == 3'b000)
		begin
		alufn		= 4'b0000; //alu function'nu seçiyor yani hangi iþlemin yapýlacaðý
		alusrc		= 1'b0; //bu iþlem hemen mi yapýlacak yoksa kayýt mý edilecek
		mem_to_reg 	= 1'b1; //kayýt dosyasýna yazýlan veriler bellekten mi yoksa ALU'nun çýktýsýndan mý geliyor onun deðeri 1 ise bellekten 0 ise alu çýktýsý
		reg_dst		= 1'b1; //kaydýn nasýl belirlendiðini belirler -ra veya rb-
		reg_write	= 1'b1; //kayýt yazýlýp yazýlmayacaðý 
		mem_read	= 1'b0; //bellekten okuma var mý
		mem_write	= 1'b0; //mevcut iþlem belleðe yazýlacak mý onun deðeri
		nia			= 1'b1; //jump mý deðil mi j addr yapýsý sadece son 0010 instructionunda 0 7 bitten 8 bite jump çünkü address*2 yapýyor
		end
		if (func == 3'b010) 
		begin
		alufn		= 4'b0001;
		alusrc		= 1'b0;
		mem_to_reg 	= 1'b1;
		reg_dst		= 1'b1;
		reg_write	= 1'b1;
		mem_read	= 1'b0;
		mem_write	= 1'b0;
		nia			= 1'b1;
		end
		if (func == 3'b100) 
		begin
		alufn		= 4'b0010;
		alusrc		= 1'b0;
		mem_to_reg 	= 1'b1;
		reg_dst		= 1'b1;
		reg_write	= 1'b1;
		mem_read	= 1'b0;
		mem_write	= 1'b0;
		nia			= 1'b1;
		end
		if (func == 3'b101) 
		begin
		alufn		= 4'b0011;
		alusrc		= 1'b0;
		mem_to_reg 	= 1'b1;
		reg_dst		= 1'b1;
		reg_write	= 1'b1;
		mem_read	= 1'b0;
		mem_write	= 1'b0;
		nia			= 1'b1;
		end
	end
	else if (opcode==4'b0100)
		begin
		alufn		= 4'b0100;
		alusrc		= 1'b1;
		mem_to_reg 	= 1'b1;
		reg_dst		= 1'b0;
		reg_write	= 1'b1;
		mem_read	= 1'b0;
		mem_write	= 1'b0;
		nia			= 1'b1;	
		end
	else if (opcode==4'b1011)
		begin
		alufn		= 4'b0101;
		alusrc		= 1'b1;
		mem_to_reg 	= 1'b0;
		reg_dst		= 1'b0;
		reg_write	= 1'b1;
		mem_read	= 1'b1;
		mem_write	= 1'b0;
		nia			= 1'b1;	
		end
	else if (opcode==4'b1111)
		begin
		alufn		= 4'b0110;
		alusrc		= 1'b1;
		reg_dst		= 1'b0;
		reg_write	= 1'b0;
		mem_read	= 1'b0;
		mem_write	= 1'b1;
		nia			= 1'b1;	
		end
	else if (opcode==4'b1000)
		begin
		alufn		= 4'b0111;
		alusrc		= 1'b0;
		reg_write	= 1'b0;
		mem_read	= 1'b0;
		mem_write	= 1'b0;
		nia			= 1'b1;	
		end
	else if (opcode==4'b0010)
		begin
		alusrc		= 1'b1;
		reg_write	= 1'b0;
		mem_read	= 1'b0;
		mem_write	= 1'b0;
		nia			= 1'b0;	
		end
	//özel instruction atamalarý
	//double add
	else if (opcode==4'b1001)
		begin
		alufn		= 4'b1100;
		alusrc		= 1'b0;
		mem_to_reg 	= 1'b1;
		reg_dst		= 1'b1;
		reg_write	= 1'b1;
		mem_read	= 1'b0;
		mem_write	= 1'b0;
		nia			= 1'b1;	
		end
	//double sub
	else if (opcode==4'b0011)
		begin
		alufn		= 4'b1001;
		alusrc		= 1'b0;
		mem_to_reg 	= 1'b1;
		reg_dst		= 1'b1;
		reg_write	= 1'b1;
		mem_read	= 1'b0;
		mem_write	= 1'b0;
		nia			= 1'b1;		
		end
	//double and
	else if (opcode==4'b1100)
		begin
		alufn		= 4'b1010;
		alusrc		= 1'b0;
		mem_to_reg 	= 1'b1;
		reg_dst		= 1'b1;
		reg_write	= 1'b1;
		mem_read	= 1'b0;
		mem_write	= 1'b0;
		nia			= 1'b1;	;	
		end
	//double or
	else if (opcode==4'b0001)
		begin
		alufn		= 4'b1011;
		alusrc		= 1'b0;
		mem_to_reg 	= 1'b1;
		reg_dst		= 1'b1;
		reg_write	= 1'b1;
		mem_read	= 1'b0;
		mem_write	= 1'b0;
		nia			= 1'b1;	
		end
		
end
endmodule