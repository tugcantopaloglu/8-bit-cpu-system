# 8 Bit CPU

An educational SystemVerilog CPU with eight 8-bit registers, 256 16-bit instruction words, a 256-byte data memory, an ALU, and separate register-write and program-counter clocks. Arithmetic wraps to 8 bits. Register 0 is writable.

`Only Source Codes` contains the standalone sources and the sample program. `Vivado Files/final_project/final_project.xpr` contains the original Vivado 2020.2 project and matching source copies. The committed Vivado cache and simulation outputs are historical artifacts; regenerate simulation results from the maintained sources.

## Run the simulation

Install [Icarus Verilog](https://steveicarus.github.io/iverilog/) and Python 3, then run from the repository root:

```sh
python tests/run_simulation.py
```

If the simulator executables are outside `PATH`, provide `--iverilog /path/to/iverilog` and `--vvp /path/to/vvp`. The runner compiles with SystemVerilog support, runs the existing `cpu` testbench and the instruction regression against both source copies, and compares the generated register dump with `Only Source Codes/result.dat`. It uses temporary working directories so the tracked files remain unchanged.

To run the sample directly from `Only Source Codes`:

```sh
iverilog -g2012 -Wall -s cpu -o cpu.vvp alu.sv control.sv cpu.sv datamem.sv decoder.sv eight_bit_cpu.sv imem.sv mux_2_1.sv mux_2_1_3bit.sv reg_file.sv
vvp cpu.vvp
```

`imem` reads `memfile.dat` relative to the simulator's working directory. Each binary word encodes one instruction; `$readmemb` also accepts hexadecimal address directives such as `@ff`. The sample loads 30 into registers 1 and 0, adds them into register 2, and holds the PC at instruction 3 with a zero-offset jump. The dump at 700 ns contains `[30, 30, 60, 0, 0, 0, 0, 0]`, and the testbench finishes at 701 ns after checking that state. The `@ff` entry defines the final memory location without executing it. Other unused instruction and data memory locations are uninitialized.

For Vivado, open the `.xpr` project, select `cpu` as the simulation top, and run behavioral simulation through 701 ns. The instruction file is included in the project's simulation source set. Vivado itself and FPGA synthesis, timing, pin constraints, and physical hardware have not been validated by the Icarus tests.

## Implemented instruction encoding

The maintained decoder and control modules define the encoding below. The original diagrams at the end of this README differ from the source for immediate fields and custom opcodes.

| Format | Fields |
| --- | --- |
| Register | opcode `[15:12]`, destination `[11:9]`, source A `[8:6]`, source B `[5:3]`, function `[2:0]` |
| Immediate | opcode `[15:12]`, immediate high bits `[11:9]`, source A `[8:6]`, register B `[5:3]`, immediate low bits `[2:0]` |
| Jump | opcode `[15:12]`, signed 7-bit offset `[6:0]`; other bits are ignored |

Immediate values are signed 6-bit values split between `[11:9]` and `[2:0]`, then sign-extended to 8 bits. Immediate arithmetic and loads write register B; stores read register B; branches compare source A with register B. Branch and jump offsets are relative to the current instruction address. Unsupported opcodes/functions perform no register or memory write and advance the PC by one.

| Instruction | Opcode / function | Operation |
| --- | --- | --- |
| ADD | `0000 / 000` | destination = A + B |
| SUB | `0000 / 010` | destination = A - B |
| AND | `0000 / 100` | destination = A & B |
| OR | `0000 / 101` | destination = A &#124; B |
| ADDI | `0100` | B = A + immediate |
| LW | `1011` | B = memory[A + immediate] |
| SW | `1111` | memory[A + immediate] = B |
| BEQ | `1000` | if A == B, PC = PC + immediate; otherwise PC = PC + 1 |
| J | `0010` | PC = PC + offset |
| DADD | `1001` | destination = A + 2 * B |
| DSUB | `0011` | destination = A - 2 * B |
| DAND | `1100` | destination = A & B & B |
| DOR | `0001` | destination = A &#124; B &#124; B |

`clk` writes registers and data memory on its rising edge. Data memory reads are combinational so loads are available for that register-write edge. `clk2` advances the PC after the model's existing 5 ns delay. The sample testbench provides one register-write edge before each PC-update edge; preserve that sequencing in other testbenches. The model contains simulation initialization, delays, console output, and a timed file dump.

The regression covers arithmetic and custom operations, signed immediates, a store/load round trip, taken and untaken branches, clearing a previous branch decision, forward and backward jumps, unsupported instructions, and a mux selector change with stable address inputs.

## Original project diagrams

Instruction table:

![Original instruction table](https://user-images.githubusercontent.com/53763911/132833594-acda55d7-9f2d-4e6d-890f-a92437cb1f98.PNG)

Instruction format:

![Original instruction format](https://user-images.githubusercontent.com/53763911/132833598-f7867326-dcdc-4b8e-9eba-f17723a738c4.PNG)

Block design:

![Original block design](https://user-images.githubusercontent.com/53763911/132834772-8fb7ebd8-4111-40ff-a932-60d092ae140f.jpg)

