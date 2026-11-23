`timescale 1ns/1ps
module tb_control_unit_rv32;
 reg clk=0,rst=1; reg [31:0] inst=0; reg br_eq=0,br_lt=0;
 wire pc_sel,reg_wen,br_un,b_sel,a_sel,mem_rw;
 wire [2:0] imm_sel; wire [3:0] alu_sel; wire [1:0] wb_sel,state;
 integer errors=0;
 control_unit_rv32 dut(clk,rst,inst,br_eq,br_lt,pc_sel,imm_sel,reg_wen,br_un,b_sel,a_sel,alu_sel,mem_rw,wb_sel,state);
 always #5 clk=~clk;
 task check(input cond,input [255:0] msg);
 begin if(cond) $display("PASS %0s",msg); else begin $display("FAIL %0s",msg); errors=errors+1; end end
 endtask
 task to_execute;
 begin @(posedge clk); #1; @(posedge clk); #1; end
 endtask
 task finish_inst;
 begin @(posedge clk); #1; end
 endtask
 initial begin
  #1; check(state==0,"asynchronous RESET");
  @(negedge clk); rst=0;
  @(posedge clk); #1; check(state==1,"RESET to FETCH");
  @(posedge clk); #1; check(state==2,"FETCH to DECODE");
  @(posedge clk); #1; check(state==3,"DECODE to EXECUTE");
  check(!reg_wen&&!mem_rw,"NOP has no side effects"); finish_inst();

  inst=32'h00500093; to_execute(); // ADDI x1,x0,5
  check(reg_wen&&b_sel&&imm_sel==0&&alu_sel==0&&wb_sel==1,"ADDI controls"); finish_inst();

  inst=32'h402081B3; to_execute(); // SUB
  check(reg_wen&&!b_sel&&alu_sel==1,"SUB controls"); finish_inst();

  inst=32'h0020A023; to_execute(); // SW
  check(mem_rw&&!reg_wen&&b_sel&&imm_sel==1&&alu_sel==0,"SW controls"); finish_inst();

  inst=32'h00208463; br_eq=1; to_execute(); // BEQ taken
  check(pc_sel&&imm_sel==2&&a_sel&&b_sel,"BEQ taken"); finish_inst();

  inst=32'h00209463; br_eq=1; to_execute(); // BNE not taken
  check(!pc_sel,"BNE not taken when equal"); finish_inst();

  inst=32'h0020E463; br_lt=1; to_execute(); // BLTU
  check(pc_sel&&br_un,"BLTU unsigned compare"); finish_inst();

  inst=32'h008000EF; to_execute(); // JAL
  check(pc_sel&&reg_wen&&wb_sel==2&&imm_sel==4,"JAL controls"); finish_inst();

  inst=32'h000080E7; to_execute(); // JALR
  check(pc_sel&&reg_wen&&wb_sel==2&&imm_sel==0,"JALR controls"); finish_inst();

  inst=32'h123450B7; to_execute(); // LUI
  check(reg_wen&&alu_sel==10&&imm_sel==3,"LUI controls"); finish_inst();

  inst=32'h12345097; to_execute(); // AUIPC
  check(reg_wen&&a_sel&&b_sel&&alu_sel==0&&imm_sel==3,"AUIPC controls"); finish_inst();

  if(errors==0) $display("TASK 2: ALL TESTS PASSED");
  else $display("TASK 2: %0d ERRORS",errors);
  $finish;
 end
endmodule
