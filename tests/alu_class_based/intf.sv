
import opcodes::*;

interface intf(input logic clk,rst);
  register_t op1,op2,result;
  instruction_t instr;
  logic enable, instr_exec;

    modport Dut (input clk, rst, instr, op1, op2, enable, output instr_exec, result );
    modport tb (output clk,rst,instr, op1, op2, enable, input instr_exec, result);

endinterface