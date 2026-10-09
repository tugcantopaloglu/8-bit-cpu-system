`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 06.07.2021 19:45:24
// Design Name: 
// Module Name: datamem
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


module datamem (
				input [7:0] read_addr,
				input [7:0] write_addr,
				input [7:0] write_data,
				input mem_write,
				input mem_read,
				input clk, 
				output [7:0] read_data
				);

reg [7:0] register [255:0];
//herhangi bir döngüde adress bus tarafýndan verilen adresle ya okuyoruz ya da ona yazýyoruz bir okuma/yükleme veya kayýt 
//talimatý olmasý durumunda adres immediate veya ALU'nun çýktýsýdýr DMEM'in veri çýkýþý her zaman rd tarafýndan seçilen
//kayýt dosyasýna gider
always@(posedge clk) 
begin
	if(mem_write) register[write_addr] <= write_data;
end

assign read_data = mem_read ? register[read_addr] : 8'd0;
endmodule 
