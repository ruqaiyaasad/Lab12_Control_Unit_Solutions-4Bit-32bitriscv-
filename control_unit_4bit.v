// Task 1: FSM control unit for the 4-bit datapath.
// Lab 7/10 do not specify an opcode field, so opcode is a separate input:
// 00 AND, 01 OR, 10 ADD, 11 SUB.
module control_unit_4bit(
 input wire clk, rst,
 input wire [1:0] opcode,
 output reg [2:0] alu_control,
 output reg write_enable, select_data_source, pc_inc, clr,
 output reg [1:0] state
);
 localparam RESET=2'b00, FETCH=2'b01, DECODE=2'b10, EXECUTE=2'b11;
 reg [1:0] next_state;
 always @(posedge clk or posedge rst)
   if(rst) state<=RESET; else state<=next_state;
 always @(*) begin
   case(state)
    RESET: next_state=FETCH;
    FETCH: next_state=DECODE;
    DECODE: next_state=EXECUTE;
    EXECUTE: next_state=FETCH;
    default: next_state=RESET;
   endcase
 end
 always @(*) begin
   alu_control=3'b000; write_enable=0; select_data_source=0;
   pc_inc=0; clr=0;
   case(state)
    RESET: clr=1;
    DECODE,EXECUTE: begin
      case(opcode)
       2'b00: alu_control=3'b000; // AND
       2'b01: alu_control=3'b001; // OR
       2'b10: alu_control=3'b010; // ADD
       2'b11: alu_control=3'b110; // SUB
      endcase
      if(state==EXECUTE) begin
        write_enable=1;
        select_data_source=0; // write ALU result
        pc_inc=1;
      end
    end
   endcase
 end
endmodule
