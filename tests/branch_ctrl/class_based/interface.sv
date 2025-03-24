import opcodes::*;

interface branch_if(input logic clk, rst);

    instruction_t instr;
    register_t op1, op2, op3;
	logic enable;
    register_t pc_out, ret_addr;
    modport Dut (input clk, rst, instr, op1, op2, op3, enable, output pc_out, ret_addr);
    modport tb (output instr, op1, op2, op3, enable, input pc_out, ret_addr);
endinterface
