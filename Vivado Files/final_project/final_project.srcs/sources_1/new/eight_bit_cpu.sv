`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 06.07.2021 19:39:50
// Design Name: 
// Module Name: eight_bit_cpu
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


module eight_bit_cpu(input clk,input clk2);
//genel olarak dosyayý açýp atamalarý yapýp clk1 ve clk2'nin tetiklenmesi ile iþlemlerin gerçekleþmesini saðlýyoruz
wire [7:0] addr;
wire [2:0] func;
wire [15:0] inst;
wire [7:0] imm;
wire [3:0] opcode;

wire br;
wire nia;                                  

wire [2:0] ra_addr;
wire [2:0] rb_addr;
wire [2:0] rd_addr;

wire [7:0] ra;
wire [7:0] rb;
wire [7:0] rd;
wire [7:0] rb_or_imm;

wire reg_dst;
wire reg_write;
wire alusrc;
wire [3:0] alufn;
wire [7:0] aluout;
wire mem_read;
wire mem_write;
wire mem_to_reg;
wire [7:0] mem_out;

reg [7:0] pc_current;
wire [2:0] rd_or_rb_addr;

 initial 
 begin
  pc_current <= 8'd0;
 end

imem imem(.addr(pc_current),.inst(inst));

decoder decoder(.inst(inst),
		.ra_addr(ra_addr),
		.rb_addr(rb_addr),
		.rd_addr(rd_addr),
		.imm(imm),
		.opcode(opcode),
		.func(func),
		.addr(addr)
		);


control  control(
		 .opcode(opcode),
		 .func(func),
		 .reg_dst(reg_dst),
		 .reg_write(reg_write),
		 .alusrc(alusrc),
		 .alufn(alufn),
		 .mem_write(mem_write),
		 .mem_read(mem_read),
		 .mem_to_reg(mem_to_reg),
		 .nia(nia)
		 );

mux_2_1_3bit mux_2_1_3bit (
			.rb_addr(rb_addr),
			.rd_addr(rd_addr),
			.sel(reg_dst),
			.final_addr(rd_or_rb_addr)
			);

regfile  regfile(
		.clk(clk),
		.reg1_read_addr(ra_addr),
		.reg1_read_data(ra),
		.reg2_read_addr(rb_addr),
		.reg2_read_data(rb),
		.reg_write_addr(rd_or_rb_addr),
		.reg_write_data(rd),
		.reg_write_en(reg_write)
		);

mux_2_1 mux_2_1(
	    .Data_in_0(rb),
		.Data_in_1(imm),
		.sel(alusrc),
		.Data_out(rb_or_imm)
		);

alu  alu (
	.alufn(alufn),
	.ra(ra),
	.rb_or_imm(rb_or_imm),
	.aluout(aluout),
	.br(br)
	);

datamem datamem(
		.read_addr(aluout),
		.write_addr(aluout),
		.write_data(rb),
		.clk(clk),
		.mem_write(mem_write),
		.mem_read(mem_read),
		.read_data(mem_out)
		);

mux_2_1 mux_2_1_v2(
		.Data_in_0(mem_out),
		.Data_in_1(aluout),
		.sel(mem_to_reg),
		.Data_out(rd)	
		);

always @(posedge clk2) 
begin
	#5
    if(nia == 1'b0)
        pc_current = pc_current + addr;
    else if (br == 1'b1)
        pc_current = pc_current + imm;
    else 
        pc_current = pc_current + 8'd1;
end

always@(posedge clk2) 
begin
	$display ("inst=%b",inst);	
end

endmodule
