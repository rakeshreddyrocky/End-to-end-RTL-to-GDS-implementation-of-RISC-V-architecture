import opcodes::*;
import iss_pkg::*;

module cpu_tb;

  parameter clock_period = 4;
  parameter string testname = "fibonacci";

  logic clk, rst, halted;

  initial begin
    clk = 1;
    forever clk = #(clock_period/2) !clk;
  end

  initial begin
    rst = 0;
    rst = #(clock_period/2) 1;
    rst = #(clock_period*10) 0;
  end

  cpu_design u_cpu_design(
    .clk    (clk),
    .rst    (rst),
    .halted (halted)
  );

  task load_fibonacci;
   // fiboancci program
   //  computes 12 iterations of a fibbonacci series
   // 
   //        x4 = first term
   //        x5 = second term
   //        x6 = sum
   //        x8 = address 
   //        x9 = interation count
   //        x10: test result
   //
   //     00:   addi x1, x0, 0      // x1 = 0
   //     01:   sw x1, 0(x0)        // store x1 @ 0
   //     02:   sw x1, 4(x0)        // store x1 @ 4
   //     03:   addi x8, x0, 0      // x8 = 0
   //     04:   addi x9, x0, 12     // x9 = 12
   //      loop:
   //     05:   lw x4, 0(x8)        // load x4 @(0+x8)
   //     06:   lw x5, 4(x8)        // load x5 @(4+x8)
   //     07:   add x6, x5, x4      // x6 = a5 + x4
   //     08:   sw x6, 8(x8)        // store x6 @(8+x8)
   //     09:   addi x8, x8, 4      // x8 += 4
   //     10:   ble x8, x9, -20(x0) // if (x8<12) jump loop
   //      done: 
   //     11:   addi x10, x0, 377   // x10 = 377
   //     12:   bne x6, x10, 20     // if (x6 != x10) jump bad
   //      good 
   //     13:   lui x10, 0x600D0    // x10 = 0x600D0000
   //     14:   srli x9, x10, 16    // x9 = x10 >> 16
   //     15:   or x10, x10, x9     // x10 = x10 | x9
   //     16:   break
   //      bad:
   //     18:   lui x10, 0xDEAD0    // x10 = 0xDEAD0000
   //     19:   slri x9, x10, 16    // x9 = x10 >> 16
   //     20:   or x10, x10, x9     // x10 = x10 | x9
   //     21:   break

   // init:
       u_cpu_design.u_code_memory.memory[0]  = encode_instr(M_ADDI, .rd(1),  .rs1(0), .imm(1));    // x1 = 1
       u_cpu_design.u_code_memory.memory[1]  = encode_instr(M_SW,   .rs1(0), .rs2(1), .imm(0));    // store x1 @0
       u_cpu_design.u_code_memory.memory[2]  = encode_instr(M_SW,   .rs1(0), .rs2(1), .imm(4));    // store x1 @4
       u_cpu_design.u_code_memory.memory[3]  = encode_instr(M_ADDI, .rd(8),  .rs1(0), .imm(0));    // x8 = 0
       u_cpu_design.u_code_memory.memory[4]  = encode_instr(M_ADDI, .rd(9),  .rs1(0), .imm(48));   // x9 = 48
   // loop: 
       u_cpu_design.u_code_memory.memory[5]  = encode_instr(M_LW,   .rd(4),  .rs1(8), .imm(0));    // load r4, @(x8)
       u_cpu_design.u_code_memory.memory[6]  = encode_instr(M_LW,   .rd(5),  .rs1(8), .imm(4));    // load r5, @(x8)+4
       u_cpu_design.u_code_memory.memory[7]  = encode_instr(M_ADD,  .rd(6),  .rs1(5), .rs2(4));    // add x6, x5 + x4
       u_cpu_design.u_code_memory.memory[8]  = encode_instr(M_SW,   .rs1(8), .rs2(6), .imm(8));    // store x8 @(x8)+8
       u_cpu_design.u_code_memory.memory[9]  = encode_instr(M_ADDI, .rd(8),  .rs1(8), .imm(4));    // add r8, r8 + 4
       u_cpu_design.u_code_memory.memory[10] = encode_instr(M_BLT,  .rs1(8), .rs2(9), .imm(-20));  // if x8<x9 jump loop
   // check result
       u_cpu_design.u_code_memory.memory[11] = encode_instr(M_ADDI, .rd(10), .rs1(0), .imm(377));  // x10 = 377
       u_cpu_design.u_code_memory.memory[12] = encode_instr(M_BNE,  .rs1(6), .rs2(10),.imm(5<<2)); // if (x6 != x10) jump BAD
   // good
       u_cpu_design.u_code_memory.memory[13] = encode_instr(M_LUI,  .rd(10), .imm('h600D0));       // x10 = 600D0
       u_cpu_design.u_code_memory.memory[14] = encode_instr(M_SRLI, .rd(9),  .rs1(10), .imm(16));  // x9 = x10 >> 16 
       u_cpu_design.u_code_memory.memory[15] = encode_instr(M_OR,   .rd(10), .rs1(10), .rs2(9));   // x10 = x10 | x9
       u_cpu_design.u_code_memory.memory[16] = EBREAK;                                             // done
   //bad
       u_cpu_design.u_code_memory.memory[17] = encode_instr(M_LUI,  .rd(10), .imm('hDEAD0));       // x10 = DEAD0
       u_cpu_design.u_code_memory.memory[18] = encode_instr(M_SRLI, .rd(9),  .rs1(10), .imm(16));  // x9 = x10 >> 16 
       u_cpu_design.u_code_memory.memory[19] = encode_instr(M_OR,   .rd(10), .rs1(10), .rs2(9));   // x10 = x10 | x9
       u_cpu_design.u_code_memory.memory[20] = EBREAK;                                             // done
   // done


  endtask

  task load_mem_test;
   //
   //  memory test, bytes, halfwords, words
   // 
   //        x1: loop counter
   //        x2: address
   //        x3: loop extent
   //        x4: size
   //        x5: read data
   //        x10: test result
   //
   //      set_up_write:
   //     00:   addi x1, x0, 0       // x1 = 0
   //     01:   addi x2, x0, 0       // x2 = 0
   //     02:   addi x3, x0, 0x10    // x3 = 16
   //     03:   addi x4, x0, 1       // x4 = 1
   //      byte_write_loop:
   //     04:   sb   x1, 0(x2)       // store x1 @x2
   //     05:   addi x1, x1, 1       // x1 = x1 + 1
   //     06:   add  x2, x2, x4      // x2 = x2 + x4
   //     07:   ble  x1, x3, -12(x0) // if (x1<x3) jump byte_write_loop
   //      set_up_read:
   //     08:   addi x1, x0, 0       // x1 = 0
   //     09:   addi x2, x0, 0       // x2 = 0
   //      byte_read_loop:
   //     10:   lb   x5, 0(x2)       // load x5 from @x2
   //     11:   bne  x1, x5, 316(x0) // if (x5 != x1) jump fail
   //     12:   addi x1, x1, 1       // x1 = x1 + 1
   //     13:   addi x2, x2, x4      // x2 = x2 + x4
   //     14:   ble  x1, x3, -16(x0) // if (x1<x3) jump byte_read_loop
   //      set_up_write:
   //     15:   addi x1, x0, 0       // x1 = 0
   //     16:   addi x2, x0, 32      // x2 = 32
   //     17:   addi x3, x0, 0x10    // x3 = 16
   //     18:   addi x4, x0, 2       // x4 = 2
   //      halfword_write_loop:
   //     19:   sh   x1, 0(x2)       // store x1 @x2
   //     20:   addi x1, x1, 1       // x1 = x1 + 1
   //     21:   add  x2, x2, x4      // x2 = x2 + x4
   //     22:   ble  x1, x3, -12(x0) // if (x1<x3) jump byte_write_loop
   //      set_up_read:
   //     23:   addi x1, x0, 0       // x1 = 0
   //     24:   addi x2, x0, 32      // x2 = 32
   //      halfword_read_loop:
   //     25:   lh   x5, 0(x2)       // load x5 from @x2
   //     26:   bne  x1, x5, 256(x0) // if (x5 != x1) jump fail
   //     27:   addi x1, x1, 1       // x1 = x1 + 1
   //     28:   addi x2, x2, x4      // x2 = x2 + x4
   //     29:   ble  x1, x3, -16(x0) // if (x1<x3) jump byte_read_loop
   //      set_up_write:
   //     30:   addi x1, x0, 0       // x1 = 0
   //     31:   addi x2, x0, 128     // x2 = 128
   //     32:   addi x3, x0, 0x10    // x3 = 16
   //     33:   addi x4, x0, 4       // x4 = 4
   //      word_write_loop:
   //     34:   sw   x1, 0(x2)       // store x1 @x2
   //     35:   addi x1, x1, 1       // x1 = x1 + 1
   //     36:   add  x2, x2, x4      // x2 = x2 + x4
   //     37:   ble  x1, x3, -12(x0) // if (x1<x3) jump byte_write_loop
   //      set_up_read:
   //     38:   addi x1, x0, 0       // x1 = 0
   //     39:   addi x2, x0, 128     // x2 = 128
   //      word_read_loop:
   //     40:   lw   x5, 0(x2)       // load x5 from @x2
   //     41:   bne  x1, x5, 196(x0) // if (x5 != x1) jump fail
   //     42:   addi x1, x1, 1       // x1 = x1 + 1
   //     43:   addi x2, x2, x4      // x2 = x2 + x4
   //     44:   ble  x1, x3, -16(x0) // if (x1<x3) jump byte_read_loop
   //     45:   jal good
   //
   //      good:
   //     80:   lui x10, 0x600D0    // x10 = 0x600D0000
   //     81:   srli x9, x10, 16    // x9 = x10 >> 16
   //     82:   or x10, x10, x9     // x10 = x10 | x9
   //     83:   break
   //
   //      bad:
   //     90:   lui x10, 0xDEAD0    // x10 = 0xDEAD0000
   //     91:   slri x9, x10, 16    // x9 = x10 >> 16
   //     92:   or x10, x10, x9     // x10 = x10 | x9
   //     93:   break

   
   // set up byte write
       u_cpu_design.u_code_memory.memory[0]  = encode_instr(M_ADDI, .rd(1),  .rs1(0), .imm(0));    // x1 = 0
       u_cpu_design.u_code_memory.memory[1]  = encode_instr(M_ADDI, .rd(2),  .rs1(0), .imm(0));    // x2 = 0
       u_cpu_design.u_code_memory.memory[2]  = encode_instr(M_ADDI, .rd(3),  .rs1(0), .imm(16));   // x3 = 16
       u_cpu_design.u_code_memory.memory[3]  = encode_instr(M_ADDI, .rd(4),  .rs1(0), .imm(1));    // x4 = 1
   // byte write loop
       u_cpu_design.u_code_memory.memory[4]  = encode_instr(M_SB,   .rs1(1), .rs2(2), .imm(0));    // store x1 @x2
       u_cpu_design.u_code_memory.memory[5]  = encode_instr(M_ADDI, .rd(1),  .rs1(1), .imm(1));    // x1 = x1 + 1
       u_cpu_design.u_code_memory.memory[6]  = encode_instr(M_ADD,  .rd(2),  .rs1(2), .rs2(4));    // x2 = x2 + x4
       u_cpu_design.u_code_memory.memory[7]  = encode_instr(M_BLT,  .rs1(1), .rs2(3), .imm(-12));  // if (x1<x3) jump byte_write_loop
   // set up byte read
       u_cpu_design.u_code_memory.memory[8]  = encode_instr(M_ADDI, .rd(1),  .rs1(0), .imm(0));    // x1 = 0
       u_cpu_design.u_code_memory.memory[9]  = encode_instr(M_ADDI, .rd(2),  .rs1(0), .imm(0));    // x2 = 0
   // byte read loop
       u_cpu_design.u_code_memory.memory[10] = encode_instr(M_LB,   .rd(5),  .rs1(2), .imm(0));    // load x5 @x2
       u_cpu_design.u_code_memory.memory[11] = encode_instr(M_BNE,  .rs1(5), .rs2(1), .imm(79<<2));// if (x5 != x1) jump BAD
       u_cpu_design.u_code_memory.memory[12] = encode_instr(M_ADDI, .rd(1),  .rs1(1), .imm(1));    // x1 = x1 + 1
       u_cpu_design.u_code_memory.memory[13] = encode_instr(M_ADD,  .rd(2),  .rs1(2), .rs2(4));    // x2 = x2 + x4
       u_cpu_design.u_code_memory.memory[14] = encode_instr(M_BLT,  .rs1(1), .rs2(3), .imm(-16));  // if (x1<x3) jump byte_write_loop
   
   // set up halfword write
       u_cpu_design.u_code_memory.memory[15] = encode_instr(M_ADDI, .rd(1),  .rs1(0), .imm(0));    // x1 = 0
       u_cpu_design.u_code_memory.memory[16] = encode_instr(M_ADDI, .rd(2),  .rs1(0), .imm(32));   // x2 = 32
       u_cpu_design.u_code_memory.memory[17] = encode_instr(M_ADDI, .rd(3),  .rs1(0), .imm(16));   // x3 = 16
       u_cpu_design.u_code_memory.memory[18] = encode_instr(M_ADDI, .rd(4),  .rs1(0), .imm(2));    // x4 = 2
   // halfword write loop
       u_cpu_design.u_code_memory.memory[19] = encode_instr(M_SH,   .rs1(2), .rs2(1), .imm(0));    // store x1 @x2
       u_cpu_design.u_code_memory.memory[20] = encode_instr(M_ADDI, .rd(1),  .rs1(1), .imm(1));    // x1 = x1 + 1
       u_cpu_design.u_code_memory.memory[21] = encode_instr(M_ADD,  .rd(2),  .rs1(2), .rs2(4));    // x2 = x2 + x4
       u_cpu_design.u_code_memory.memory[22] = encode_instr(M_BLT,  .rs1(1), .rs2(3), .imm(-12));  // if (x1<x3) jump byte_write_loop
   // set up halfword read
       u_cpu_design.u_code_memory.memory[23] = encode_instr(M_ADDI, .rd(1),  .rs1(0), .imm(0));    // x1 = 0
       u_cpu_design.u_code_memory.memory[24] = encode_instr(M_ADDI, .rd(2),  .rs1(0), .imm(32));   // x2 = 32
   // half read loop
       u_cpu_design.u_code_memory.memory[25] = encode_instr(M_LH,   .rd(5),  .rs1(2), .imm(0));    // load x5 @x2
       u_cpu_design.u_code_memory.memory[26] = encode_instr(M_BNE,  .rs1(5), .rs2(1), .imm(64<<2));// if (x5 != x1) jump BAD
       u_cpu_design.u_code_memory.memory[27] = encode_instr(M_ADDI, .rd(1),  .rs1(1), .imm(1));    // x1 = x1 + 1
       u_cpu_design.u_code_memory.memory[28] = encode_instr(M_ADD,  .rd(2),  .rs1(2), .rs2(4));    // x2 = x2 + x4
       u_cpu_design.u_code_memory.memory[29] = encode_instr(M_BLT,  .rs1(1), .rs2(3), .imm(-16));  // if (x1<x3) jump byte_write_loop
   
   // set up word write
       u_cpu_design.u_code_memory.memory[30] = encode_instr(M_ADDI, .rd(1),  .rs1(0), .imm(0));    // x1 = 0
       u_cpu_design.u_code_memory.memory[31] = encode_instr(M_ADDI, .rd(2),  .rs1(0), .imm(128));  // x2 = 128
       u_cpu_design.u_code_memory.memory[32] = encode_instr(M_ADDI, .rd(3),  .rs1(0), .imm(16));   // x3 = 16
       u_cpu_design.u_code_memory.memory[33] = encode_instr(M_ADDI, .rd(4),  .rs1(0), .imm(4));    // x4 = 4
   // word write loop
       u_cpu_design.u_code_memory.memory[34] = encode_instr(M_SW,   .rs1(2), .rs2(1), .imm(0));    // store x1 @x2
       u_cpu_design.u_code_memory.memory[35] = encode_instr(M_ADDI, .rd(1),  .rs1(1), .imm(1));    // x1 = x1 + 1
       u_cpu_design.u_code_memory.memory[36] = encode_instr(M_ADD,  .rd(2),  .rs1(2), .rs2(4));    // x2 = x2 + x4
       u_cpu_design.u_code_memory.memory[37] = encode_instr(M_BLT,  .rs1(1), .rs2(3), .imm(-12));  // if (x1<x3) jump byte_write_loop
   // set up word read
       u_cpu_design.u_code_memory.memory[38] = encode_instr(M_ADDI, .rd(1),  .rs1(0), .imm(0));    // x1 = 0
       u_cpu_design.u_code_memory.memory[39] = encode_instr(M_ADDI, .rd(2),  .rs1(0), .imm(128));  // x2 = 128
   // word read loop
       u_cpu_design.u_code_memory.memory[40] = encode_instr(M_LW,   .rd(5),  .rs1(2), .imm(0));    // load x5 @x2
       u_cpu_design.u_code_memory.memory[41] = encode_instr(M_BNE,  .rs1(5), .rs2(1), .imm(49<<2));// if (x5 != x1) jump BAD
       u_cpu_design.u_code_memory.memory[42] = encode_instr(M_ADDI, .rd(1),  .rs1(1), .imm(1));    // x1 = x1 + 1
       u_cpu_design.u_code_memory.memory[43] = encode_instr(M_ADD,  .rd(2),  .rs1(2), .rs2(4));    // x2 = x2 + x4
       u_cpu_design.u_code_memory.memory[44] = encode_instr(M_BLT,  .rs1(1), .rs2(3), .imm(-16));  // if (x1<x3) jump byte_write_loop
       
       u_cpu_design.u_code_memory.memory[45] = encode_instr(M_JAL,  .imm(80<<2));                  // jump GOOD
   
   // GOOD 
       u_cpu_design.u_code_memory.memory[80] = encode_instr(M_LUI,  .rd(10), .imm('h600D0));       // x10 = 600D0
       u_cpu_design.u_code_memory.memory[81] = encode_instr(M_SRLI, .rd(9),  .rs1(10), .imm(16));  // x9 = x10 >> 16 
       u_cpu_design.u_code_memory.memory[82] = encode_instr(M_OR,   .rd(10), .rs1(10), .rs2(9));   // x10 = x10 | x9
       u_cpu_design.u_code_memory.memory[83] = EBREAK;                                             // done
   
   // BAD 
       u_cpu_design.u_code_memory.memory[90] = encode_instr(M_LUI,  .rd(10), .imm('hDEAD0));       // x10 = DEAD0
       u_cpu_design.u_code_memory.memory[91] = encode_instr(M_SRLI, .rd(9),  .rs1(10), .imm(16));  // x9 = x10 >> 16 
       u_cpu_design.u_code_memory.memory[92] = encode_instr(M_OR,   .rd(10), .rs1(10), .rs2(9));   // x10 = x10 | x9
       u_cpu_design.u_code_memory.memory[93] = EBREAK;                                             // done
     
  endtask

  task run_iss;
  // set up tracking ISS
    iss_enable_trace();
    for (int i=0; i<100; i++) iss_set_instruction(i, u_cpu_design.u_code_memory.memory[i]);
    iss_reset();
    iss_run();
    $display("\n\n\n");
  endtask

  initial begin
    if (testname == "memory_test") load_mem_test;
    if (testname == "fibonacci")   load_fibonacci;
    run_iss;
  end

  function int compare_register_state; // compare tracking ISS and RTL for consistent register state
    register_t expected_value, actual_value;
    int i, errors;

    errors = 0;

    foreach(u_cpu_design.u_cpu.register_bank[i]) begin
      expected_value = iss_get_register(i);
      actual_value = u_cpu_design.u_cpu.register_bank[i];
      $write("reg[%2d] iss: %x rtl: %x ", i, expected_value, actual_value);
      if (actual_value == expected_value) $display(" matches! ");
      else begin
        $display(" ERROR: does not match ");
        errors++;
      end
    end
    $display("");
    return errors;
  endfunction

  function int compare_memory_state(int start_address, end_address);
    register_t expected_value, actual_value;
    int i, errors;

    errors = 0;

    for (i=start_address; i<end_address; i+=4) begin
      expected_value = iss_get_memory_word(i);
      actual_value   = u_cpu_design.u_data_memory.memory[i>>2];
      $write("memory[%x] iss: %x rtl: %x ", i, expected_value, actual_value);
      if (actual_value == expected_value) $display("matches! ");
      else begin
        $display(" ERROR: does not match ");
        errors++;
      end
    end
    $display("");
    return errors;
  endfunction

  int errors;
  always @(posedge clk) if (halted) begin
    errors = 0;

    $display("\n\n%s test finished ", testname);

    if (testname == "memory_test") begin
      errors += compare_register_state;
      errors += compare_memory_state('h00, 'h0C);
      errors += compare_memory_state('h20, 'h3C);
      errors += compare_memory_state('h80, 'hBC);
    end

    if (testname == "fibonacci") begin

      errors += compare_register_state;
      errors += compare_memory_state(0, 'h38);
    end

    if (errors > 0) $display("Processor state and tracking ISS not consistent, Test failed, %0d errors ", errors);
    else begin
      if ('h600D == (u_cpu_design.u_cpu.register_bank[10] & 'hFFFF)) $display("\n\n>>> Test passed\n");
      else $display("\n\n>>> Test failed: code %x", u_cpu_design.u_cpu.register_bank[10] >> 16);
    end
    $finish;
  end

endmodule
