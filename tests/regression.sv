`timescale 1ns / 1ps

module regression;
reg clk = 0;
reg clk2 = 0;
eight_bit_cpu dut(.clk(clk), .clk2(clk2));

reg [2:0] mux_rd;
reg [2:0] mux_rb;
reg mux_sel;
wire [2:0] mux_out;
mux_2_1_3bit mux_check(.rd_addr(mux_rd), .rb_addr(mux_rb),
                     .sel(mux_sel), .final_addr(mux_out));

function automatic [15:0] r_inst(input [3:0] op, input [2:0] rd,
                                input [2:0] ra, input [2:0] rb,
                                input [2:0] fn);
    r_inst = {op, rd, ra, rb, fn};
endfunction

function automatic [15:0] i_inst(input [3:0] op, input [2:0] ra,
                                input [2:0] rb, input [5:0] imm);
    i_inst = {op, imm[5:3], ra, rb, imm[2:0]};
endfunction

task automatic step(input [7:0] expected_pc);
    #10 clk = 1;
    #1 clk = 0;
    #10 clk2 = 1;
    #6 clk2 = 0;
    if (dut.pc_current !== expected_pc)
        $fatal(1, "Expected PC %0d, got %0d", expected_pc, dut.pc_current);
endtask

task automatic check_register(input [2:0] address, input [7:0] expected);
    if (dut.regfile.reg_array[address] !== expected)
        $fatal(1, "Expected register %0d = %0d, got %0d",
               address, expected, dut.regfile.reg_array[address]);
endtask

integer i;
initial begin
    mux_rd = 3'd5;
    mux_rb = 3'd2;
    mux_sel = 0;
    #1;
    if (mux_out !== 3'd2) $fatal(1, "Wrong initial mux selection");
    mux_sel = 1;
    #1;
    if (mux_out !== 3'd5) $fatal(1, "Mux did not react to selector change");
    for (i = 0; i < 256; i = i + 1) dut.imem.RAM[i] = 16'h2000;
    dut.imem.RAM[0] = i_inst(4'h4, 0, 1, 6'd7);
    dut.imem.RAM[1] = i_inst(4'h4, 0, 2, -6'd3);
    dut.imem.RAM[2] = r_inst(4'h0, 3, 1, 1, 0);
    dut.imem.RAM[3] = r_inst(4'h0, 4, 3, 1, 2);
    dut.imem.RAM[4] = r_inst(4'h0, 5, 3, 2, 4);
    dut.imem.RAM[5] = r_inst(4'h0, 6, 1, 2, 5);
    dut.imem.RAM[6] = r_inst(4'h9, 7, 1, 1, 0);
    dut.imem.RAM[7] = r_inst(4'h3, 4, 7, 1, 0);
    dut.imem.RAM[8] = r_inst(4'hc, 5, 6, 1, 0);
    dut.imem.RAM[9] = r_inst(4'h1, 6, 0, 1, 0);
    dut.imem.RAM[10] = i_inst(4'hf, 1, 3, 6'd1);
    dut.imem.RAM[11] = i_inst(4'hb, 1, 4, 6'd1);
    dut.imem.RAM[12] = i_inst(4'h8, 4, 3, 6'd2);
    dut.imem.RAM[13] = i_inst(4'h4, 0, 5, 6'd1);
    dut.imem.RAM[14] = i_inst(4'h4, 0, 5, 6'd2);
    dut.imem.RAM[15] = r_inst(4'h0, 5, 1, 2, 1);
    dut.imem.RAM[16] = r_inst(4'ha, 5, 1, 2, 0);
    dut.imem.RAM[17] = i_inst(4'h8, 1, 4, 6'd2);
    dut.imem.RAM[18] = 16'h2002;
    dut.imem.RAM[19] = i_inst(4'h4, 0, 5, 6'd1);
    dut.imem.RAM[20] = i_inst(4'h4, 0, 0, -6'd1);
    dut.imem.RAM[21] = 16'h207f;

    step(1); check_register(1, 7);
    step(2); check_register(2, 253);
    step(3); check_register(3, 14);
    step(4); check_register(4, 7);
    step(5); check_register(5, 12);
    step(6); check_register(6, 255);
    step(7); check_register(7, 21);
    step(8); check_register(4, 7);
    step(9); check_register(5, 7);
    step(10); check_register(6, 7);
    step(11);
    if (dut.datamem.register[8] !== 8'd14)
        $fatal(1, "Store did not write the source register value");
    step(12); check_register(4, 14);
    step(14);
    step(15);
    step(16);
    step(17);
    step(18);
    step(20);
    step(21);
    step(20);
    if (dut.regfile.reg_array[0] !== 8'd255 ||
        dut.regfile.reg_array[1] !== 8'd7 ||
        dut.regfile.reg_array[2] !== 8'd253 ||
        dut.regfile.reg_array[3] !== 8'd14 ||
        dut.regfile.reg_array[4] !== 8'd14 ||
        dut.regfile.reg_array[5] !== 8'd2 ||
        dut.regfile.reg_array[6] !== 8'd7 ||
        dut.regfile.reg_array[7] !== 8'd21 ||
        dut.datamem.register[8] !== 8'd14)
        $fatal(1, "Instruction regression produced unexpected CPU state");
    $display("PASS: instruction, memory, branch, jump, and mux regression");
    $finish;
end
endmodule
