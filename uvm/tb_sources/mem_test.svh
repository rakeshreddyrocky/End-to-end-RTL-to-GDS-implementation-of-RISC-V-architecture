
class mem_test extends execute_test_c;
  `uvm_component_utils(mem_test)

  int program_size;
  int data_size = 'h10000;

  virtual function int load_program();

   virtual interface cpu_state_i cs_vif;
   `uvm_info(get_type_name(), "Loading program to design memory", UVM_MEDIUM);
   if (!uvm_config_db#(virtual interface cpu_state_i)::get(this, "", "cpu_state_if", cs_vif))
     `uvm_error(get_type_name, "Failed to get cpu_state interface");

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
       set_instr(0,  encode_instr(M_ADDI, .rd(1),  .rs1(0), .imm(1)), cs_vif);    // x1 = 1

       set_instr(0, encode_instr(M_ADDI, .rd(1),  .rs1(0), .imm(0)), cs_vif);    // x1 = 0
       set_instr(1, encode_instr(M_ADDI, .rd(2),  .rs1(0), .imm(0)), cs_vif);    // x2 = 0
       set_instr(2, encode_instr(M_ADDI, .rd(3),  .rs1(0), .imm(16)), cs_vif);   // x3 = 16
       set_instr(3, encode_instr(M_ADDI, .rd(4),  .rs1(0), .imm(1)), cs_vif);    // x4 = 1
   // byte write loop
       set_instr(4, encode_instr(M_SB,   .rs1(1), .rs2(2), .imm(0)), cs_vif);    // store x1 @x2
       set_instr(5, encode_instr(M_ADDI, .rd(1),  .rs1(1), .imm(1)), cs_vif);    // x1 = x1 + 1
       set_instr(6, encode_instr(M_ADD,  .rd(2),  .rs1(2), .rs2(4)), cs_vif);    // x2 = x2 + x4
       set_instr(7, encode_instr(M_BLT,  .rs1(1), .rs2(3), .imm(-12)), cs_vif);  // if (x1<x3) jump byte_write_loop
   // set up byte read
       set_instr(8, encode_instr(M_ADDI, .rd(1),  .rs1(0), .imm(0)), cs_vif);    // x1 = 0
       set_instr(9, encode_instr(M_ADDI, .rd(2),  .rs1(0), .imm(0)), cs_vif);    // x2 = 0
   // byte read loop
       set_instr(10, encode_instr(M_LB,   .rd(5),  .rs1(2), .imm(0)), cs_vif);    // load x5 @x2
       set_instr(11, encode_instr(M_BNE,  .rs1(5), .rs2(1), .imm(79<<2)), cs_vif);// if (x5 != x1) jump BAD
       set_instr(12, encode_instr(M_ADDI, .rd(1),  .rs1(1), .imm(1)), cs_vif);    // x1 = x1 + 1
       set_instr(13, encode_instr(M_ADD,  .rd(2),  .rs1(2), .rs2(4)), cs_vif);    // x2 = x2 + x4
       set_instr(14, encode_instr(M_BLT,  .rs1(1), .rs2(3), .imm(-16)), cs_vif);  // if (x1<x3) jump byte_write_loop
   
   // set up halfword write
       set_instr(15, encode_instr(M_ADDI, .rd(1),  .rs1(0), .imm(0)), cs_vif);    // x1 = 0
       set_instr(16, encode_instr(M_ADDI, .rd(2),  .rs1(0), .imm(32)), cs_vif);   // x2 = 32
       set_instr(17, encode_instr(M_ADDI, .rd(3),  .rs1(0), .imm(16)), cs_vif);   // x3 = 16
       set_instr(18, encode_instr(M_ADDI, .rd(4),  .rs1(0), .imm(2)), cs_vif);    // x4 = 2
   // halfword write loop
       set_instr(19, encode_instr(M_SH,   .rs1(2), .rs2(1), .imm(0)), cs_vif);    // store x1 @x2
       set_instr(20, encode_instr(M_ADDI, .rd(1),  .rs1(1), .imm(1)), cs_vif);    // x1 = x1 + 1
       set_instr(21, encode_instr(M_ADD,  .rd(2),  .rs1(2), .rs2(4)), cs_vif);    // x2 = x2 + x4
       set_instr(22, encode_instr(M_BLT,  .rs1(1), .rs2(3), .imm(-12)), cs_vif);  // if (x1<x3) jump byte_write_loop
   // set up halfword read
       set_instr(23, encode_instr(M_ADDI, .rd(1),  .rs1(0), .imm(0)), cs_vif);    // x1 = 0
       set_instr(24, encode_instr(M_ADDI, .rd(2),  .rs1(0), .imm(32)), cs_vif);   // x2 = 32
   // half read loop
       set_instr(25, encode_instr(M_LH,   .rd(5),  .rs1(2), .imm(0)), cs_vif);    // load x5 @x2
       set_instr(26, encode_instr(M_BNE,  .rs1(5), .rs2(1), .imm(64<<2)), cs_vif);// if (x5 != x1) jump BAD
       set_instr(27, encode_instr(M_ADDI, .rd(1),  .rs1(1), .imm(1)), cs_vif);    // x1 = x1 + 1
       set_instr(28, encode_instr(M_ADD,  .rd(2),  .rs1(2), .rs2(4)), cs_vif);    // x2 = x2 + x4
       set_instr(29, encode_instr(M_BLT,  .rs1(1), .rs2(3), .imm(-16)), cs_vif);  // if (x1<x3) jump byte_write_loop
   
   // set up word write
       set_instr(30, encode_instr(M_ADDI, .rd(1),  .rs1(0), .imm(0)), cs_vif);    // x1 = 0
       set_instr(31, encode_instr(M_ADDI, .rd(2),  .rs1(0), .imm(128)), cs_vif);  // x2 = 128
       set_instr(32, encode_instr(M_ADDI, .rd(3),  .rs1(0), .imm(16)), cs_vif);   // x3 = 16
       set_instr(33, encode_instr(M_ADDI, .rd(4),  .rs1(0), .imm(4)), cs_vif);    // x4 = 4
   // word write loop
       set_instr(34, encode_instr(M_SW,   .rs1(2), .rs2(1), .imm(0)), cs_vif);    // store x1 @x2
       set_instr(35, encode_instr(M_ADDI, .rd(1),  .rs1(1), .imm(1)), cs_vif);    // x1 = x1 + 1
       set_instr(36, encode_instr(M_ADD,  .rd(2),  .rs1(2), .rs2(4)), cs_vif);    // x2 = x2 + x4
       set_instr(37, encode_instr(M_BLT,  .rs1(1), .rs2(3), .imm(-12)), cs_vif);  // if (x1<x3) jump byte_write_loop
   // set up word read
       set_instr(38, encode_instr(M_ADDI, .rd(1),  .rs1(0), .imm(0)), cs_vif);    // x1 = 0
       set_instr(39, encode_instr(M_ADDI, .rd(2),  .rs1(0), .imm(128)), cs_vif);  // x2 = 128
   // word read loop
       set_instr(40, encode_instr(M_LW,   .rd(5),  .rs1(2), .imm(0)), cs_vif);    // load x5 @x2
       set_instr(41, encode_instr(M_BNE,  .rs1(5), .rs2(1), .imm(49<<2)), cs_vif);// if (x5 != x1) jump BAD
       set_instr(42, encode_instr(M_ADDI, .rd(1),  .rs1(1), .imm(1)), cs_vif);    // x1 = x1 + 1
       set_instr(43, encode_instr(M_ADD,  .rd(2),  .rs1(2), .rs2(4)), cs_vif);    // x2 = x2 + x4
       set_instr(44, encode_instr(M_BLT,  .rs1(1), .rs2(3), .imm(-16)), cs_vif);  // if (x1<x3) jump byte_write_loop
       
       set_instr(45, encode_instr(M_JAL,  .imm(80<<2)), cs_vif);                  // jump GOOD
   
   // GOOD 
       set_instr(80, encode_instr(M_LUI,  .rd(10), .imm('h600D0)), cs_vif);       // x10 = 600D0
       set_instr(81, encode_instr(M_SRLI, .rd(9),  .rs1(10), .imm(16)), cs_vif);  // x9 = x10 >> 16 
       set_instr(82, encode_instr(M_OR,   .rd(10), .rs1(10), .rs2(9)), cs_vif);   // x10 = x10 | x9
       set_instr(83, EBREAK, cs_vif);                                             // done
   
   // BAD 
       set_instr(90, encode_instr(M_LUI,  .rd(10), .imm('hDEAD0)), cs_vif);       // x10 = DEAD0
       set_instr(91, encode_instr(M_SRLI, .rd(9),  .rs1(10), .imm(16)), cs_vif);  // x9 = x10 >> 16 
       set_instr(92, encode_instr(M_OR,   .rd(10), .rs1(10), .rs2(9)), cs_vif);   // x10 = x10 | x9
       set_instr(93, EBREAK, cs_vif);                                             // done
     
    return (93); // size of program
  endfunction

  function new(string name = "mem_test",uvm_component parent=null);
    super.new(name, parent);
    `uvm_info(get_type_name(), "In the contructor", UVM_DEBUG);
  endfunction : new

endclass : mem_test

