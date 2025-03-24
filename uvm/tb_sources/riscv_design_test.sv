
import uvm_pkg::*;
`include "uvm_macros.svh"

import opcodes::*;
import riscv_test_pkg::*;

module top;

  parameter clock_period = 4;
  parameter BROKEN=0;

  import uvm_pkg::*;
  `include "uvm_macros.svh"

  initial `uvm_info("Start", "Hello, World!", UVM_INFO);

  // signals

  logic          clk, rst, halted;

  string         program_name = "execute_test";
  string         program_filename;
  int            program_size;

  // debug

  string instr_str;

  // interface instantiations and connections

  code_memory_i  code_memory_if(u_cpu_design.u_code_memory.memory);
  cpu_if_i       cpu_if(clk, rst);
  cpu_trace_i    cpu_trace_if();
  cpu_state_i    cpu_state_if(
                     .code_memory(u_cpu_design.u_code_memory.memory), 
                     .data_memory(u_cpu_design.u_data_memory.memory), 
                     .register_bank(u_cpu_design.u_cpu.register_bank),
                     .pc(u_cpu_design.u_cpu.pc));

  // configuration class

  config_data_i config_data_if(
      .program_name(program_name),
      .program_filename(program_filename),
      .program_size(program_size));

  // connect it all up

  assign cpu_if.instruction_address    = u_cpu_design.u_cpu.instruction_address;
  assign cpu_if.instruction_enable     = u_cpu_design.u_cpu.instruction_enable;
  assign cpu_if.instr                  = u_cpu_design.u_cpu.instr;
  assign cpu_if.address                = u_cpu_design.u_cpu.data_address;
  assign cpu_if.enable                 = u_cpu_design.u_cpu.data_read_enable;
  assign cpu_if.read_data              = u_cpu_design.u_cpu.data_read_data;
  assign cpu_if.write_enable           = u_cpu_design.u_cpu.data_write_enable;
  assign cpu_if.byte_enables           = u_cpu_design.u_cpu.data_write_byte_enable;
  assign cpu_if.write_data             = u_cpu_design.u_cpu.data_write_data;
  assign cpu_if.halted                 = u_cpu_design.u_cpu.halted;

  assign cpu_trace_if.clk              = u_cpu_design.u_cpu.clk;
  assign cpu_trace_if.rst              = u_cpu_design.u_cpu.rst;
  assign cpu_trace_if.fetch            = u_cpu_design.u_cpu.fetch;
  assign cpu_trace_if.decode           = u_cpu_design.u_cpu.decode;
  assign cpu_trace_if.execute          = u_cpu_design.u_cpu.execute;
  assign cpu_trace_if.write_back       = u_cpu_design.u_cpu.write_back;
  assign cpu_trace_if.address          = u_cpu_design.u_cpu.data_address;
  assign cpu_trace_if.byte_enable      = u_cpu_design.u_cpu.data_write_byte_enable;
  assign cpu_trace_if.write_data       = u_cpu_design.u_cpu.data_write_data;
  assign cpu_trace_if.instr            = u_cpu_design.u_cpu.instr;
  assign cpu_trace_if.rd               = u_cpu_design.u_cpu.rd;
  assign cpu_trace_if.rs1              = u_cpu_design.u_cpu.u_decoder.rs1;
  assign cpu_trace_if.rs2              = u_cpu_design.u_cpu.u_decoder.rs2;
  assign cpu_trace_if.op1              = u_cpu_design.u_cpu.op1;
  assign cpu_trace_if.op2              = u_cpu_design.u_cpu.op2;
  assign cpu_trace_if.op3              = u_cpu_design.u_cpu.op3;
  assign cpu_trace_if.pc               = u_cpu_design.u_cpu.pc;
  assign cpu_trace_if.result           = u_cpu_design.u_cpu.result;

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

  always @(posedge clk) instr_str = decode_instr(u_cpu_design.code_read_data);

  initial begin 

    uvm_config_db#(string)::set(null, "*", "greeting", "hello, world"); 

    // add interfaces to config db

    uvm_config_db#(virtual interface cpu_if_i)::set(null, "*", "cpu_if", cpu_if);
    uvm_config_db#(virtual interface code_memory_i)::set(null, "*", "code_memory_if", code_memory_if);
    uvm_config_db#(virtual interface cpu_trace_i)::set(null, "*", "cpu_trace_if", cpu_trace_if);
    uvm_config_db#(virtual interface cpu_state_i)::set(null, "*", "cpu_state_if", cpu_state_if);
    uvm_config_db#(virtual interface config_data_i)::set(null, "*", "config_data_if", config_data_if);

    // and away we go...

    run_test();
  end

  // instantiate DUT

  cpu_design#(.BROKEN(BROKEN)) u_cpu_design(.*);

endmodule
