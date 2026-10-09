`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 06.07.2021 19:51:17
// Design Name: 
// Module Name: mux_2_1_3bit
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


module mux_2_1_3bit (
    input [2:0] rd_addr,
    input [2:0] rb_addr,
    input sel,
    output reg [2:0] final_addr
    ); 
    //0 veya 1 durumuna göre farklý atamalarý yapýyoruz

    always @(*)
    begin
        if(sel == 0) 
            final_addr = rb_addr; 
        else
            final_addr = rd_addr;
    end
    
endmodule
