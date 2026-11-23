LAB 12 - IMPLEMENTATION OF CONTROL UNIT

Task 1 files:
  control_unit_4bit.v
  tb_control_unit_4bit.v

Task 2 files:
  control_unit_rv32.v
  tb_control_unit_rv32.v

ModelSim commands for Task 1:
  vlib work
  vlog control_unit_4bit.v tb_control_unit_4bit.v
  vsim work.tb_control_unit_4bit
  run -all

ModelSim commands for Task 2 (run separately):
  vdel -lib work -all
  vlib work
  vlog control_unit_rv32.v tb_control_unit_rv32.v
  vsim work.tb_control_unit_rv32
  run -all

Design note:
The earlier 4-bit labs describe a 4-bit ALU and 4x4 register file, but do not
specify an instruction opcode field for a 4-bit instruction. Task 1 therefore
uses a separate 2-bit opcode input: 00 AND, 01 OR, 10 ADD, 11 SUB. These map
to Lab 10's ALU control encodings (000,001,010,110).

Task 2 uses Lab 12's RV32I instruction opcodes and control-signal table.
Both controllers implement the four FSM states RESET, FETCH, DECODE,
EXECUTE. RV32 outputs are asserted during EXECUTE. This sequential FSM is
the lab's FSM implementation; it is not a combinational single-cycle decoder.
Run the testbenches in ModelSim and keep the actual transcript as evidence.
