
import opcodes::*;

// interface for memory controller

interface mem_if_i(input logic clk, rst);
  instruction_t   instr;
  register_t      op1, op2, op3, result;
  logic           enable;
  logic           result_valid;
  logic [31:0]    address;
  logic [31:0]    read_data;
  logic           read_enable;
  logic [31:0]    write_data;
  logic [3:0]     byte_enables;
  logic           write_enable;
  int             instr_id;
endinterface
