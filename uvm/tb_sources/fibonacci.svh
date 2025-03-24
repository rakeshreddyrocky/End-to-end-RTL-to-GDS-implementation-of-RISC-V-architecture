
class fibonacci extends execute_test_c;
  `uvm_component_utils(fibonacci)

  int program_size;
  int data_size = 'h10000;

  virtual function int load_program();

   virtual interface cpu_state_i cs_vif;
   `uvm_info(get_type_name(), "Loading program to design memory", UVM_MEDIUM);
   if (!uvm_config_db#(virtual interface cpu_state_i)::get(this, "", "cpu_state_if", cs_vif))
     `uvm_error(get_type_name, "Failed to get cpu_state interface");

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
       set_instr(0,  encode_instr(M_ADDI, .rd(1),  .rs1(0), .imm(1)), cs_vif);    // x1 = 1
       set_instr(1,  encode_instr(M_SW,   .rs1(0), .rs2(1), .imm(0)), cs_vif);    // store x1 @0
       set_instr(2,  encode_instr(M_SW,   .rs1(0), .rs2(1), .imm(4)), cs_vif);    // store x1 @4
       set_instr(3,  encode_instr(M_ADDI, .rd(8),  .rs1(0), .imm(0)), cs_vif);    // x8 = 0
       set_instr(4,  encode_instr(M_ADDI, .rd(9),  .rs1(0), .imm(48)), cs_vif);   // x9 = 48
   // loop: 
       set_instr(5,  encode_instr(M_LW,   .rd(4),  .rs1(8), .imm(0)), cs_vif);    // load r4, @(x8)
       set_instr(6,  encode_instr(M_LW,   .rd(5),  .rs1(8), .imm(4)), cs_vif);    // load r5, @(x8)+4
       set_instr(7,  encode_instr(M_ADD,  .rd(6),  .rs1(5), .rs2(4)), cs_vif);    // add x6, x5 + x4
       set_instr(8,  encode_instr(M_SW,   .rs1(8), .rs2(6), .imm(8)), cs_vif);    // store x8 @(x8)+8
       set_instr(9,  encode_instr(M_ADDI, .rd(8),  .rs1(8), .imm(4)), cs_vif);    // add r8, r8 + 4
       set_instr(10, encode_instr(M_BLT,  .rs1(8), .rs2(9), .imm(-20)), cs_vif);  // if x8<x9 jump loop
   // check result
       set_instr(11, encode_instr(M_ADDI, .rd(10), .rs1(0), .imm(377)), cs_vif);  // x10 = 377
       set_instr(12, encode_instr(M_BNE,  .rs1(6), .rs2(10),.imm(5<<2)), cs_vif); // if (x6 != x10) jump BAD
   // good
       set_instr(13, encode_instr(M_LUI,  .rd(10), .imm('h600D0)), cs_vif);       // x10 = 600D0
       set_instr(14, encode_instr(M_SRLI, .rd(9),  .rs1(10), .imm(16)), cs_vif);  // x9 = x10 >> 16 
       set_instr(15, encode_instr(M_OR,   .rd(10), .rs1(10), .rs2(9)), cs_vif);   // x10 = x10 | x9
       set_instr(16, EBREAK, cs_vif);                                             // done
   //bad
       set_instr(17, encode_instr(M_LUI,  .rd(10), .imm('hDEAD0)), cs_vif);       // x10 = DEAD0
       set_instr(18, encode_instr(M_SRLI, .rd(9),  .rs1(10), .imm(16)), cs_vif);  // x9 = x10 >> 16 
       set_instr(19, encode_instr(M_OR,   .rd(10), .rs1(10), .rs2(9)), cs_vif);   // x10 = x10 | x9
       set_instr(20, EBREAK, cs_vif);                                             // done
   // done

    return (20); // size of program
  endfunction

  function new(string name = "finonacci",uvm_component parent=null);
    super.new(name, parent);
    `uvm_info(get_type_name(), "In the contructor", UVM_DEBUG);
  endfunction : new

endclass : fibonacci

