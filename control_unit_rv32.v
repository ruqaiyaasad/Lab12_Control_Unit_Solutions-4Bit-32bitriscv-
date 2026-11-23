// Task 2: RV32I FSM Control Unit. Outputs are active in EXECUTE state.
// ALUSel encodings follow Lab 12 pages 6-7.
module control_unit_rv32(
 input wire clk,rst,
 input wire [31:0] i_inst,
 input wire i_br_eq,i_br_lt,
 output reg o_pc_sel,
 output reg [2:0] o_imm_sel,
 output reg o_reg_wen,o_br_un,o_b_sel,o_a_sel,
 output reg [3:0] o_alu_sel,
 output reg o_mem_rw,
 output reg [1:0] o_wb_sel,
 output reg [1:0] state
);
 localparam RESET=0,FETCH=1,DECODE=2,EXECUTE=3;
 localparam ADD=0,SUB=1,AND_=2,OR_=3,XOR_=4,SLL=5,SRL=6,SRA=7,SLT=8,SLTU=9,BSEL=10;
 wire [6:0] opcode=i_inst[6:0];
 wire [2:0] funct3=i_inst[14:12];
 wire f7_5=i_inst[30];
 reg [1:0] next_state;
 reg take_branch;
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
  o_pc_sel=0; o_imm_sel=0; o_reg_wen=0; o_br_un=0;
  o_b_sel=0; o_a_sel=0; o_alu_sel=ADD; o_mem_rw=0; o_wb_sel=1;
  take_branch=0;
  if(state==EXECUTE) begin
   case(opcode)
    7'b0110011: begin // R-type
     o_reg_wen=1;
     case(funct3)
      0:o_alu_sel=f7_5?SUB:ADD;
      1:o_alu_sel=SLL; 2:o_alu_sel=SLT; 3:o_alu_sel=SLTU;
      4:o_alu_sel=XOR_; 5:o_alu_sel=f7_5?SRA:SRL;
      6:o_alu_sel=OR_; 7:o_alu_sel=AND_;
     endcase
    end
    7'b0010011: begin // I-type ALU
     o_reg_wen=1; o_b_sel=1; o_imm_sel=3'b000;
     case(funct3)
      0:o_alu_sel=ADD; 2:o_alu_sel=SLT; 3:o_alu_sel=SLTU;
      4:o_alu_sel=XOR_; 6:o_alu_sel=OR_; 7:o_alu_sel=AND_;
      1:o_alu_sel=SLL; 5:o_alu_sel=f7_5?SRA:SRL;
     endcase
    end
    7'b0000011: begin // loads
     o_reg_wen=1; o_b_sel=1; o_imm_sel=0; o_alu_sel=ADD; o_wb_sel=0;
    end
    7'b0100011: begin // stores
     o_b_sel=1; o_imm_sel=1; o_alu_sel=ADD; o_mem_rw=1;
    end
    7'b1100011: begin // branches
     o_imm_sel=2; o_a_sel=1; o_b_sel=1; o_alu_sel=ADD;
     case(funct3)
      0:take_branch=i_br_eq;       // BEQ
      1:take_branch=~i_br_eq;      // BNE
      4:take_branch=i_br_lt;       // BLT
      5:take_branch=~i_br_lt;      // BGE
      6:begin o_br_un=1; take_branch=i_br_lt; end // BLTU
      7:begin o_br_un=1; take_branch=~i_br_lt; end // BGEU
      default:take_branch=0;
     endcase
     o_pc_sel=take_branch;
    end
    7'b1101111: begin // JAL
     o_pc_sel=1; o_imm_sel=4; o_a_sel=1; o_b_sel=1;
     o_reg_wen=1; o_alu_sel=ADD; o_wb_sel=2;
    end
    7'b1100111: begin // JALR
     o_pc_sel=1; o_imm_sel=0; o_b_sel=1;
     o_reg_wen=1; o_alu_sel=ADD; o_wb_sel=2;
    end
    7'b0110111: begin // LUI
     o_reg_wen=1; o_imm_sel=3; o_b_sel=1; o_alu_sel=BSEL;
    end
    7'b0010111: begin // AUIPC
     o_reg_wen=1; o_imm_sel=3; o_a_sel=1; o_b_sel=1; o_alu_sel=ADD;
    end
    default: begin end // unsupported instruction: no side effects
   endcase
  end
 end
endmodule
