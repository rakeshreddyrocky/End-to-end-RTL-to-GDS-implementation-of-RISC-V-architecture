

import opcodes::*;

module top;

  parameter broken = 0;

  logic clk, rst;

  initial begin
    clk = 1;
    forever clk = #2 !clk;
  end

  initial begin
    rst = 0;
    rst = #1 1;
    rst = #20 0;
  end

  instruction_t  instr;
  register_t     op1, op2, op3;
  logic          enable;
  register_t     result;
  logic          result_valid;

  logic [31:0]   address;
  logic          read_enable;
  logic [31:0]   read_data;
  logic          read_ack = 1;
  logic          write_enable;
  logic [3:0]    write_byte_enable;
  logic [31:0]   write_data;
  logic          write_ack = 1;

  register_t     expected_result;
 
  int            errors;  
  int            i;

  task memory_test(input int size, count);

    case (size) 
      1: instr = encode_rtype(M_SB, 1, 2, 3);
      2: instr = encode_rtype(M_SH, 1, 2, 3);
      4: instr = encode_rtype(M_SW, 1, 2, 3);
      default: $display("Bad size: %d in memory test ", size);
    endcase 

    $display("Memory Test: size: %d count: %d ", size, count);
    $write("Testing opcode: ");
    print_opcode(instr);

    // write data into memory

    for (i = 0; i < count; i++) begin
      op1 = 0;
      op2 = i*size;  // write_address
      op3 = i;       // write data 

      case(size) 
        1: $display("write of %02x to address %x ", op3, unsigned'(op1 + op2));
        2: $display("write of %04x to address %x ", op3, unsigned'(op1 + op2));
        4: $display("write of %08x to address %x ", op3, unsigned'(op1 + op2));
      endcase

      enable = 1;
      @(posedge clk);
      enable = 0;
      @(posedge clk);
      //while(!result_valid) @(posedge clk);
      repeat (8) @(posedge clk);
    end
    
    // read data back from memory, compare to what was written

    case (size) 
      1: instr = encode_rtype(M_LB, 1, 2, 3);
      2: instr = encode_rtype(M_LH, 1, 2, 3);
      4: instr = encode_rtype(M_LW, 1, 2, 3);
      default: $display("Bad size: %d in memory test ", size);
    endcase 

    $write("Testing opcode: ");
    print_opcode(instr);

    for (i = 0; i < count; i++) begin
      op1 = 0;
      op2 = i*size;   // read_address
      expected_result = i;

      enable = 1;
      @(posedge clk);
      enable = 0;
      @(posedge clk);
      while(!result_valid) @(posedge clk);
 
      case (size) 
        1: $display("read %02x from address %x ", result, unsigned'(op1 + op2));
        2: $display("read %04x from address %x ", result, unsigned'(op1 + op2));
        4: $display("read %08x from address %x ", result, unsigned'(op1 + op2));
      endcase

      if (result != expected_result) begin
         $display("  Expected: %d actual: %d -- wrong!! ", expected_result, result);
         errors ++;
      end
      repeat (8) @(posedge clk);
    end
    
    $display("memory test finished \n");
  endtask

  // ===============================
  // main memory test
  // ===============================

  initial begin

    @(posedge clk);
    wait (!rst);
    errors = 0;

    // word test 
    memory_test(4, 16);

    // short test
    memory_test(2, 32);

    // byte test
    memory_test(1, 64);
    
    $display("memory test complete ");
   
    if (errors==0) $display("\nTest Passed! \n");
    else           $display("\nTest Failed! \n");

    $finish;
  end

  // instantiate DUT and memory

  memory_ctrl #(.random_errors(broken))u_mcu(.*);

  ssram u_mem(.*);

endmodule         
