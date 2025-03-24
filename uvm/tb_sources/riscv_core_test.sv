
import uvm_pkg::*;
`include "uvm_macros.svh"

import opcodes::*;
import riscv_opcode_test_pkg::*;

module top;

  parameter clock_period = 4;
  parameter BROKEN=0;

  import uvm_pkg::*;
  `include "uvm_macros.svh"

  initial `uvm_info("Start", "Hello, World!", UVM_INFO);

  // signals

  logic          clk;
  logic          rst;

  register_t     instruction_address;
  logic          instruction_enable;
  instruction_t  instr;
  register_t     data_address;
  logic          data_read_enable;
  register_t     data_read_data;
  logic          data_read_rdy = 1;
  logic          data_write_enable;
  logic [3:0]    data_write_byte_enable;
  register_t     data_write_data;
  logic          data_write_rdy = 1;
  logic          halted;

  string         program_name = "opcode_test";
  string         program_filename;
  int            program_size;

  // stub memories

  logic [31:0] code_memory ['h10000];
  logic [31:0] data_memory ['h10000];

  // debug

  string instr_str;

  // interface instantiations and connections

  cpu_if_i       cpu_if(clk, rst);
  cpu_trace_i    cpu_trace_if();
  cpu_state_i    cpu_state_if(
                     .code_memory(code_memory), 
                     .data_memory(data_memory), 
                     .register_bank(u_cpu.register_bank),
                     .pc(u_cpu.u_branch_unit.next_pc));

  // configuration class

  config_data_i config_data_if(
      .program_name(program_name),
      .program_filename(program_filename),
      .program_size(program_size));

  // connect it all up

  assign cpu_if.instruction_address    = u_cpu.instruction_address;
  assign cpu_if.instruction_enable     = u_cpu.instruction_enable;
  assign instr                         = cpu_if.instr;
  assign cpu_if.address                = u_cpu.data_address;
  assign cpu_if.enable                 = u_cpu.data_read_enable;
  assign data_read_data                = cpu_if.read_data;
  assign cpu_if.write_enable           = u_cpu.data_write_enable;
  assign cpu_if.byte_enables           = u_cpu.data_write_byte_enable;
  assign cpu_if.write_data             = u_cpu.data_write_data;
  assign cpu_if.halted                 = u_cpu.halted;

  assign cpu_trace_if.clk              = u_cpu.clk;
  assign cpu_trace_if.rst              = u_cpu.rst;
  assign cpu_trace_if.fetch            = u_cpu.fetch;
  assign cpu_trace_if.decode           = u_cpu.decode;
  assign cpu_trace_if.execute          = u_cpu.execute;
  assign cpu_trace_if.write_back       = u_cpu.write_back;
  assign cpu_trace_if.address          = u_cpu.data_address;
  assign cpu_trace_if.byte_enable      = u_cpu.data_write_byte_enable;
  assign cpu_trace_if.write_data       = u_cpu.data_write_data;
  assign cpu_trace_if.instr            = u_cpu.instr;
  assign cpu_trace_if.rd               = u_cpu.rd;
  assign cpu_trace_if.rs1              = u_cpu.u_decoder.rs1;
  assign cpu_trace_if.rs2              = u_cpu.u_decoder.rs2;
  assign cpu_trace_if.op1              = u_cpu.op1;
  assign cpu_trace_if.op2              = u_cpu.op2;
  assign cpu_trace_if.op3              = u_cpu.op3;
  assign cpu_trace_if.pc               = u_cpu.pc;
  assign cpu_trace_if.result           = u_cpu.result;

  // clock and reset logic

  initial begin
    rst = 0;
    rst = #(clock_period/2) 1;
    rst = #(clock_period * 20) 0;
  end

  initial begin
    clk = 1;
    forever clk = #(clock_period/2) ~clk;
  end

  always @(posedge clk) instr_str = decode_instr(instr);

  initial force u_cpu.u_branch_unit.pc = 0;

  initial begin 

    uvm_config_db#(string)::set(null, "*", "greeting", "hello, world"); 

    // add interfaces to config db

    uvm_config_db#(virtual interface cpu_if_i)::set(null, "*", "cpu_if", cpu_if);
    uvm_config_db#(virtual interface cpu_trace_i)::set(null, "*", "cpu_trace_if", cpu_trace_if);
    uvm_config_db#(virtual interface cpu_state_i)::set(null, "*", "cpu_state_if", cpu_state_if);
    uvm_config_db#(virtual interface config_data_i)::set(null, "*", "config_data_if", config_data_if);

    // and away we go...

    run_test();
  end

  // instantiate DUT

  riscv_rv32i#(.BROKEN(BROKEN)) u_cpu(.*);

endmodule
