
import opcodes::*;

// interface for memory controller

interface decoder_if_i(input logic clk, rst);
  instruction_t   instr;
  register_t      register_bank[32];
  register_t      op1, op2, op3;
  register_num_t  rd;
  logic           enable;
  int             instr_id;
endinterface
