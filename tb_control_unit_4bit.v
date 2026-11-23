`timescale 1ns/1ps
module tb_control_unit_4bit;
 reg clk=0, rst=1; reg [1:0] opcode=0;
 wire [2:0] alu_control; wire write_enable,select_data_source,pc_inc,clr;
 wire [1:0] state; integer errors=0;
 control_unit_4bit dut(clk,rst,opcode,alu_control,write_enable,select_data_source,pc_inc,clr,state);
 always #5 clk=~clk;
 task check(input cond,input [255:0] msg);
 begin if(cond) $display("PASS %0s",msg); else begin $display("FAIL %0s",msg); errors=errors+1; end end
 endtask
 initial begin
  #1; check(clr,"RESET asserts clear");
  @(negedge clk); rst=0;
  @(posedge clk); #1; check(state==1,"RESET to FETCH");
  @(posedge clk); #1; check(state==2,"FETCH to DECODE");
  opcode=0; #1; check(alu_control==0,"AND decode");
  @(posedge clk); #1; check(state==3 && write_enable && pc_inc && !select_data_source,"AND execute controls");
  @(posedge clk); #1; check(state==1,"EXECUTE to FETCH");
  opcode=1; @(posedge clk); #1; // DECODE
  check(alu_control==1,"OR decode");
  @(posedge clk); #1; check(alu_control==1 && write_enable,"OR execute");
  @(posedge clk); #1; opcode=2; @(posedge clk); #1;
  check(alu_control==2,"ADD decode");
  @(posedge clk); #1; check(alu_control==2,"ADD execute");
  @(posedge clk); #1; opcode=3; @(posedge clk); #1;
  check(alu_control==6,"SUB decode");
  @(posedge clk); #1; check(alu_control==6,"SUB execute");
  if(errors==0) $display("TASK 1: ALL TESTS PASSED");
  else $display("TASK 1: %0d ERRORS",errors);
  $finish;
 end
endmodule
