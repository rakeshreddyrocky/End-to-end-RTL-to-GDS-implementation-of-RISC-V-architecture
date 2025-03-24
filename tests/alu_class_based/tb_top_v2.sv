`include "environment_v2.sv"
import trans_v1::*;

module tb_top();
  bit clk, rst;
  
  initial begin 
    clk = 0;
   forever #5 clk = ~clk; // Clock toggles every 5 time units
  end
  
  initial begin
    rst = 1;
    #10 rst = 0;
    #500 $finish; // Ensure test runs long enough
  end

  intf intf_top(clk, rst);
  environment env;
  
  initial begin
    env = new(intf_top);
    env.run(); // Start the test
  end
  
  alu dut (
    .clk(intf_top.clk), 
    .rst(intf_top.rst), 
    .instr(intf_top.instr), 
    .op1(intf_top.op1), 
    .op2(intf_top.op2), 
    .enable(intf_top.enable), 
    .instr_exec(intf_top.instr_exec), 
    .result(intf_top.result)
  );
endmodule
