

// randomized class for generating a
// memory instruction with random data

opcode_mask_t opcode_list [] =
 {
     // R-Type Instructions
     M_ADD, M_SUB, M_AND, M_OR, M_XOR, M_SLL, M_SRL, M_SRA, M_STL, M_STLU,

     // I-Type Instructions
     M_ADDI, M_ANDI, M_ORI, M_XORI, M_SLLI, M_SRLI, M_SRAI, M_LW, M_LH, M_LHU, M_LB, M_LBU, M_JALR,

     // SI-Type Instructions
     M_STLI, M_STLUI,

     // U-Type Instructions
     M_LUI, M_AUIPC,

     // S-Type Instructions
     M_SW, M_SH, M_SB,

     // B-Type Instructions
     M_BEQ, M_BNE, M_BLT, M_BGE, M_BLTU, M_BGEU,

     // J-Type Instructions
     M_JAL
 };

class rand_testcase_c;
  rand register_num_t rs1, rs2, rd;
  rand int imm;
  rand register_t register_bank[32];
  rand int op_index;
  opcode_mask_t opcode;
  instruction_t instr;
  logic chatty = 1;

  constraint c1 { op_index inside {[0:opcode_list.size-1]};}

  function void post_randomize(); 

    register_bank[0] = '0; // must be 0;

    instr = encode_instr(opcode_list[op_index], .rd(rd), .rs1(rs1), .rs2(rs2), .imm(imm));

    if (chatty) begin
      $display("New instruction created: %s ", decode_instr(instr));
    end

  endfunction
endclass

typedef enum {Instruciton_Test=0, Random_Test} decoder_test_t;

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

  // sends a break instruciton to end simulation
  task done_stim;
    stimulus_c inputs = new();

    inputs.instr = EBREAK;
    foreach(inputs.register_bank[i]) inputs.register_bank[i]  = '0;
    
    if (chatty) $display("Sending EBREAK");
    if (verbose) $display("[GENERATOR  ] --- end of test sent");

    gen2drv.put(inputs);
  endtask

  rand rand_testcase_c   testcase;

  task random_tests;
    if (chatty) $display("generator: in main");

    // generate random testcase

    testcase = new();

    repeat(test_count) begin

      assert(testcase.randomize());

      inputs = new();

      inputs.instr = testcase.instr;
      foreach (inputs.register_bank[i]) inputs.register_bank[i] = testcase.register_bank[i];
      inputs.instr_id = test_index++;

      if (verbose) $display("[GENERATOR  ] %5d instruction: %-25s register[1]: %x register[2]: %x register[3]: %x ",
                              inputs.instr_id, decode_instr(inputs.instr), inputs.register_bank[1],
                              inputs.register_bank[1], inputs.register_bank[2]);

      gen2drv.put(inputs);
    end

    done_stim;

  endtask;


  task instruction_tests;
    instruction_t instr;
    int i = 0;

    if (chatty) $display("generator: in instruction_tests");

    foreach (opcode_list[i]) begin
      instr = encode_instr(opcode_list[i], .rd(5), .rs1(1), .rs2(2), .imm(32'h12345678));

      inputs = new();

      foreach (inputs.register_bank[i]) inputs.register_bank[i] = i;
      inputs.instr = instr;
      inputs.instr_id = test_index++;

      if (verbose) $display("[GENERATOR  ] %5d instruction: %-25s register[1]: %x register[2]: %x register[3]: %x ",
                              inputs.instr_id, decode_instr(inputs.instr), inputs.register_bank[1],
                              inputs.register_bank[1], inputs.register_bank[2]);

      gen2drv.put(inputs);
    end
 
    done_stim;

    if (chatty) $display("generator: finished");
  endtask

  task main(decoder_test_t test_type);

    case (test_type)
     Instruciton_Test : instruction_tests;
     Random_Test      : random_tests;
     default          : $error("Unknown test");
    endcase
  endtask
endclass

