

// randomized class for generating a
// memory instruction with random data

class rand_testcase_c;
  rand logic signedness;
  rand logic[2:0] size;
  rand register_t base, offset, w_data, imm;
  rand register_num_t rs1, rs2, rd;
  opcode_mask_t rd_opcode, wr_opcode;
  instruction_t rd_instr,  wr_instr;
  logic [3:0] byte_enables;
  logic chatty = 1;
  int i;

  // constrain to legal memory transaction
  // constrain address to 0-64K   
  constraint c0 { size inside {1, 2, 4};}
  constraint c2 { base inside {[0:'h8000]}; }
  constraint c3 { offset inside {[0:'h8000]}; }
  constraint c4 { base + offset inside { [0:'hFFFF]}; }  // note: this does not work

  // postrandomize to ensure proper size and alignemnt

  function void post_randomize(); 

    // align on words for word access
    if (size == 4) begin
      offset = offset & 32'hFFFFFFFC;
      base   = base   & 32'hFFFFFFFC;
      imm    = imm    & 32'hFFFFFFFC;
    end

    // align on half-word for half-word access
    if (size == 2) begin
      offset = offset & 32'hFFFFFFFE;
      base   = base   & 32'hFFFFFFFE;
      imm    = imm    & 32'hFFFFFFFE;
    end

    // set byte_enables based on access size and offset
    case (size)
     4 : byte_enables = 4'b1111;
     2 : byte_enables = 4'b0011 << ((base + offset) & 2);
     1 : byte_enables = 4'b0001 << ((base + offset) & 3);
    endcase

    // select write instruction based on size
    case (size)
     4: wr_opcode = M_SW;
     2: wr_opcode = M_SH;
     1: wr_opcode = M_SB;
    endcase;

    // select read instruciton based on size
    // for sub-word size, randomly select signed or unsigned read
    case (size)
     4: rd_opcode = M_LW;
     2: case (signedness) 
         0: rd_opcode = M_LHU;
         1: rd_opcode = M_LH;
        endcase
     1: case (signedness)
         0: rd_opcode = M_LBU;
         1: rd_opcode = M_LB;
        endcase
    endcase

    // encode read and write opcode pair (only read from locations written to)
    wr_instr = encode_instr(wr_opcode, .rd(rd), .rs1(rs1), .rs2(rs2), .imm(imm));
    rd_instr = encode_instr(rd_opcode, .rd(rd), .rs1(rs1), .rs2(rs2), .imm(imm));

    if (chatty) begin
      $display("New instruction created: %s ", decode_instr(wr_instr));
      $display("                         %s ", decode_instr(rd_instr));
      $display("base = %x offset = %x address = %x  ", base, offset, base + offset);
    end

  endfunction
endclass

typedef enum {Sequential_Test=0, Random_Test} mem_test_t;

// generator for testing memory controller
// with a sequence of reads and writes of 
// monotoncally increasing data and addresses

class generator_c;
  stimulus_c            inputs;
  mailbox#(stimulus_c)  gen2drv;
  int                   test_count;
  int                   test_index;

  logic                 chatty = 1;

  // constructor
  function new(
       mailbox#(stimulus_c) mb, 
       int num_tests = 100);
    if (chatty) $display("generator: started");

    gen2drv           = mb;
    test_count        = num_tests; 
    test_index        = 0;
  endfunction

  // creates a sequence of "count" transactions
  // at "base" address of a given "size"
  // for a read or write "instr"

  task memory_loop(
      input instruction_t instr,
      input int base, size, count);

    stimulus_c inputs;
    int i;

    for (i=0; i<count; i++) begin
      inputs = new();

      inputs.instr    = instr;
      inputs.op1      = '0;
      inputs.op2      = base + i * size;
      inputs.op3      = i;
      inputs.instr_id = test_index++;

      if (verbose) $display("[GENERATOR  ] %5d instruction: %-25s op1: %x op2: %x op3: %x ",
                              inputs.instr_id, decode_instr(inputs.instr), inputs.op1, inputs.op2, inputs.op3); 

      gen2drv.put(inputs);
    end
  endtask

  // sends a break instruciton to end simulation
  task done_stim;
    stimulus_c inputs = new();

    inputs.instr = EBREAK;
    inputs.op1   = '0;
    inputs.op2   = '0;
    inputs.op3   = '0;
    
    if (verbose) $display("[GENERATOR  ] --- end of test sent");
    if (chatty) $display("Sending EBREAK");
    gen2drv.put(inputs);
  endtask

  rand rand_testcase_c   testcase;

  task random_tests;
    if (chatty) $display("generator: in main");

    // generate random testcase
    // perform a write, then a read
    // from the same location

    testcase = new();

    repeat(test_count) begin

      assert(testcase.randomize());

      inputs = new();

      inputs.instr        = testcase.wr_instr;
      inputs.op1          = testcase.base;
      inputs.op2          = testcase.offset;
      inputs.op3          = testcase.w_data;
      inputs.instr_id     = test_index++;

      if (verbose) $display("[GENERATOR  ] %5d instruction: %-25s op1: %x op2: %x op3: %x ",
                              inputs.instr_id, decode_instr(inputs.instr), inputs.op1, inputs.op2, inputs.op3); 

      gen2drv.put(inputs);

      inputs = new();

      inputs.instr        = testcase.rd_instr;
      inputs.op1          = testcase.base;
      inputs.op2          = testcase.offset;
      inputs.op3          = '0;
      inputs.instr_id     = test_index++;

      if (verbose) $display("[GENERATOR  ] %5d instruction: %-25s op1: %x op2: %x op3: %x ",
                              inputs.instr_id, decode_instr(inputs.instr), inputs.op1, inputs.op2, inputs.op3); 

      gen2drv.put(inputs);

    end

    done_stim;

  endtask;

  task sequential_tests;
    int i = 0;

    if (chatty) $display("generator: in sequential_tests");

    // store bytes, then read back as bytes and signed bytes
    memory_loop(encode_instr(M_SB, 1, 2, 3, 4), 0, 1, 256);
    memory_loop(encode_instr(M_LB, 1, 2, 3, 4), 0, 1, 256);
    memory_loop(encode_instr(M_LBU, 1, 2, 3, 4), 0, 1, 256);

    // store halfword and then read back as unsigned and signed
    memory_loop(encode_instr(M_SH, 1, 2, 3, 4), 32'h1000, 2, 256);
    memory_loop(encode_instr(M_LH, 1, 2, 3, 4), 32'h1000, 2, 256);
    memory_loop(encode_instr(M_LHU, 1, 2, 3, 4), 32'h1000, 2, 256);

    // store word then read back
    memory_loop(encode_instr(M_SW, 1, 2, 3, 4), 32'h2000, 4, 256);
    memory_loop(encode_instr(M_LW, 1, 2, 3, 4), 32'h2000, 4, 256);
 
    done_stim;

    if (chatty) $display("generator: finished");
  endtask

  task main(mem_test_t test_type);

    case (test_type)
     Sequential_Test : sequential_tests;
     Random_Test     : random_tests;
     default         : $error("Unknown test");
    endcase
  endtask
endclass

