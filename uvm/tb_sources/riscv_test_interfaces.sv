
  import opcodes::*;

  // interfaces needed for stimulus, response and checking

  // DUT signal interface, for driving and sampling 
  // boundary of CPU core

  interface cpu_if_i(input logic clk, rst);
    logic [31:0]    instruction_address;
    logic           instruction_enable;
    instruction_t   instr;
    logic           enable;
    logic           result_valid;
    logic [31:0]    address;
    logic [31:0]    read_data;
    logic           read_enable;
    logic [31:0]    write_data;
    logic [3:0]     byte_enables;
    logic           write_enable;
    logic           halted;
  endinterface


  // code memory interface, for loading/modifying 
  // programs running on the core

  interface code_memory_i(ref logic [31:0] memory['h10000]);
    //instruction_t memory ['h10000];
  
    function void set(input logic [15:0] address, instruction_t data);
      memory[address] = data;
    endfunction
  
    function instruction_t get(input logic [15:0] address);
      return memory[address];
    endfunction;
  endinterface


  // whitebox interface for accessing internal states 
  // of the core for tracing execution

  interface cpu_trace_i;
    logic clk;
    logic rst;
    logic fetch, decode, write_back, execute;
    logic [3:0] byte_enable;
    instruction_t instr;
    register_num_t rd, rs1, rs2; 
    register_t result, op1, op2, op3, address, pc, write_data;
  endinterface

 
  // cpu state interface, use to set conditions for 
  // tests and for checking state during and after 
  // test code execuiton
  
  interface cpu_state_i(
    ref logic [31:0] code_memory ['h10000],
    ref logic [31:0] data_memory ['h10000],
    ref register_t register_bank[32],
    ref register_t pc);
    int program_size;
  endinterface

  interface config_data_i(
    ref string program_name,
    ref string program_filename,
    ref int program_size);
  endinterface
