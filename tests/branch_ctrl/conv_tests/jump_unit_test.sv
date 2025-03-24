

import opcodes::*;

module top;

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
  register_t     pc_out;
  register_t     ret_addr;

  int            errors;  
  int            i;

  task branch_test(input opcode_mask_t i, input int p1, p2, p3);
    register_t start_pc, expected_ret_addr, branch_target;

    $display("Testing conditional branch ");
    
    op1 = p1;
    op2 = p2;
    op3 = p3;  // offset branch target, will branch to PC + op3

    branch_target = pc_out + p3;
 
    instr = encode_btype(i, 1, 2, p3);

    $write("Testing instruction: ");
    print_opcode(instr);

    expected_ret_addr = pc_out + 4;
    start_pc = pc_out;

    enable = 1;
    @(posedge clk);
    enable = 0;
    @(posedge clk);

    $display("jump to %08x: old PC=%08x new PC=%08x ", branch_target, start_pc, pc_out);
    if (pc_out != branch_target) begin 
      $display("step failed: expected new PC: %08x read PC=%08x ", branch_target, pc_out);
      errors++;
    end

    $display("return address: %08x", ret_addr);
    if (ret_addr != expected_ret_addr) begin
      $display("step failed: expected return address: %08x read ret_addr=%08x ", expected_ret_addr, ret_addr);
      errors++;
    end

    repeat (8) @(posedge clk);    

    $display(" ");

  endtask

  task jalr_test();
    register_t start_pc, expected_ret_addr;

    $display("Testing JALR ");

    op1 = 32'h00040000;    // jump address
    op2 = 32'h00000000;    // jump offset
    op3 = 32'h00000000;    // branch offset

    instr = encode_itype(M_JALR, op1, op2, op3);  // jump
    $write("Instruction: ");
    print_opcode(instr);

    expected_ret_addr = pc_out + 4;
    start_pc = pc_out;

    enable = 1;
    @(posedge clk);
    enable = 0;
    @(posedge clk);

    $display("jump to %08x: old PC=%08x new PC=%08x ", op3, start_pc, pc_out);
    if (op1 != pc_out) begin 
      $display("step failed: expected new PC: %08x read PC=%08x ", op1, pc_out);
      errors++;
    end

    $display("return address: %08x", ret_addr);
    if (ret_addr != expected_ret_addr) begin
      $display("step failed: expected return address: %08x read ret_addr=%08x ", expected_ret_addr, ret_addr);
      errors++;
    end

    repeat (8) @(posedge clk);    

    $display(" ");

  endtask


  task jal_test();
    register_t start_pc, expected_ret_addr;

    $display("Testing JAL ");

    op1 = 32'h00020000;    // jump address
    op2 = 32'h00000000;    // jump offset
    op3 = 32'h00000000;    // branch offset

    instr = encode_jtype(M_JAL, op1, op2);  // jump
    $write("Instruction: ");
    print_opcode(instr);

    expected_ret_addr = pc_out + 4;
    start_pc = pc_out;

    enable = 1;
    @(posedge clk);
    enable = 0;
    @(posedge clk);

    $display("jump to %08x: old PC=%08x new PC=%08x ", op1, start_pc, pc_out);
    if (op1 != pc_out) begin 
      $display("step failed: expected new PC: %08x read PC=%08x ", op1, pc_out);
      errors++;
    end

    $display("return address: %08x", ret_addr);
    if (ret_addr != expected_ret_addr) begin
      $display("step failed: expected return address: %08x read ret_addr=%08x ", expected_ret_addr, ret_addr);
      errors++;
    end

    repeat (8) @(posedge clk);    

    $display(" ");

  endtask


  task pc_advance_test(input int steps);
    register_t start_pc;

    $display("Testing PC advance: %d steps", steps);

    for (i = 0; i < steps; i++) begin
      op1 = 0;    // jump address
      op2 = 0;    // jump offset
      op3 = 0;    // branch offset

      instr = encode_rtype(M_XOR, 0, 0, 0);  // no-op
      enable = 0;

      start_pc = pc_out;
      enable = 1;
      @(posedge clk);
      enable = 0;
      @(posedge clk);

      $display("step: old PC=%08x new PC=%08x ", start_pc, pc_out);
      if (start_pc != pc_out - 4) begin 
        $display("step failed: expected new PC: %08x read PC=%08x ", start_pc + 4, pc_out);
        errors++;
      end

      repeat (8) @(posedge clk);    
    end 

    $display(" ");

  endtask

  // ===============================
  // main branch/PC test
  // ===============================

  initial begin

    @(posedge clk);
    wait (!rst);
    errors = 0;

    // PC advance test
    pc_advance_test(10);

    // Jump test
    jal_test();
    jalr_test();

    // Conditional branch test
    branch_test(M_BEQ,  1, 1, 32'h00000100);
    branch_test(M_BNE,  1, 2, 32'h00000200);
    branch_test(M_BLT,  1, 2, 32'h00000300);
    branch_test(M_BLTU, 1, 2, 32'h00000400);
    branch_test(M_BGE,  3, 1, 32'h00000500);
    branch_test(M_BGEU, 3, 1, 32'h00000600);
   
    $display("branch/PC test complete ");
   
    if (errors==0) $display("\nTest Passed! \n");
    else           $display("\nTest Failed! \n");

    $finish;
  end

  // instantiate DUT and memory

  branch_unit u_bcu(.*);

endmodule         

