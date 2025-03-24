`include "test.sv"
module tb;

  logic clk;
  logic rst;
  branch_if vif (clk, rst);
  base_test t1;

  always #5 clk = ~clk;

  initial begin
    clk = 0;
    rst = 1;
    #20;
    rst = 0;
    #25;
    
    // Instantiate test
    t1 = new(vif);
    
    // Run test
    t1.run();
    //$display("[TB] Test finished. PC=%0h, Ret Addr=%0h", vif.pc_out, vif.ret_addr);

    #500;
	   $display("[TB] Test finished. PC=%0h, Ret Addr=%0h", vif.pc_out, vif.ret_addr);
    $finish;
  end

  branch_unit uut (
    .clk(vif.clk),
    .rst(vif.rst),
    .instr(vif.instr),
    .op1(vif.op1),
    .op2(vif.op2),
    .op3(vif.op3),
    .enable(vif.enable),
    .pc_out(vif.pc_out),
    .ret_addr(vif.ret_addr)
  );

endmodule
