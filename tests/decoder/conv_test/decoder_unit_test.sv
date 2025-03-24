
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
  
  string instr_str;

  function automatic void oracle(
      input  instruction_t   instr, 
      input  register_t      r[32],
      output register_t      ex_op1, ex_op2, ex_op3,
      output register_num_t  ex_rd);

    opcode_mask_t op;

    ex_op1 = '0;
    ex_op2 = '0;
    ex_op3 = '0;
    ex_rd  = '0;

    // do not copy or reuse decode routines (does not really test anything)
    op = opc_base(instr);

    // set op1
    if (op inside {
     /* R  */ M_ADD, M_SUB, M_AND, M_OR, M_XOR, M_SLL, M_SRL, M_SRA, M_STL, M_STLU, 
     /* I  */ M_ADDI, M_ANDI, M_ORI, M_XORI, M_SLLI, M_SRLI, M_SRAI, M_LW, M_LH, M_LHU, M_LB, M_LBU, M_JALR,
     /* SI */ M_STLI, M_STLUI,
     /* S  */ M_SW, M_SH, M_SB,
     /* B  */ M_BEQ, M_BNE, M_BLT, M_BGE, M_BLTU, M_BGEU }) ex_op1 = r[get_rs1(instr)]; 
    if (op inside {
     /* J  */ M_JAL, 
     /* U  */ M_LUI, M_AUIPC }) ex_op1 = get_imm(instr);

    // set op2
    if (op inside {
     /* R  */ M_ADD, M_SUB, M_AND, M_OR, M_XOR, M_SLL, M_SRL, M_SRA, M_STL, M_STLU, 
     /* B  */ M_BEQ, M_BNE, M_BLT, M_BGE, M_BLTU, M_BGEU}) ex_op2 = r[get_rs2(instr)];
    if (op inside {
     /* I  */ M_ADDI, M_ANDI, M_ORI, M_XORI, M_SLLI, M_SRLI, M_SRAI, M_LW, M_LH, M_LHU, M_LB, M_LBU, M_JALR,
     /* S  */ M_SW, M_SH, M_SB, 
     /* SI */ M_STLI, M_STLUI })  ex_op2 = get_imm(instr);

    // set op3
    if (op inside {
     /* B  */ M_BEQ, M_BNE, M_BLT, M_BGE, M_BLTU, M_BGEU}) ex_op3 = get_imm(instr);
    if (op inside {
     /* S  */ M_SW, M_SH, M_SB })  ex_op3 = r[get_rs2(instr)];
 
    if (op inside {
     /* R  */ M_ADD, M_SUB, M_AND, M_OR, M_XOR, M_SLL, M_SRL, M_SRA, M_STL, M_STLU, 
     /* I  */ M_ADDI, M_ANDI, M_ORI, M_XORI, M_SLLI, M_SRLI, M_SRAI, M_LW, M_LH, M_LHU, M_LB, M_LBU, M_JALR,
     /* SI */ M_STLI, M_STLUI,
     /* J  */ M_JAL, 
     /* U  */ M_LUI, M_AUIPC }) ex_rd = get_rd(instr);
  endfunction

  instruction_t  instr;
  logic          instr_exec;
  register_t     op1, op2, op3, ex_op1, ex_op2, ex_op3;
  register_num_t rd, ex_rd;
  logic          enable;
  register_t     register_bank[32];
 
  int           i, rs1n, rs2n, rdn;
  int           errors;  

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

  opcode_mask_t op_type_list[] = {M_ADD, M_ADDI, M_STLI, M_LUI, M_AUIPC, M_SW, M_BEQ, M_JAL };

  task automatic basic_tests;
    // test each opcode

    logic oops, chatty = 1;

    foreach (opcode_list[i]) begin
      instr = encode_instr(opcode_list[i], .rd(5), .rs1(1), .rs2(2), .imm(32'h12345678));   
      oracle(instr, register_bank, ex_op1, ex_op2, ex_op3, ex_rd);

      enable = 1;
      @(posedge clk);
      enable = 0;
      @(posedge clk);

      repeat (5) @(posedge clk);

      oops = ((op1 != ex_op1) || (op2 != ex_op2) || (op3 != ex_op3) || (rd != ex_rd)) ? 1 : 0;
      
      if (oops || chatty) begin
        $display("instruction: %s ", decode_instr(instr));
        $display("  expected:  op1: %x op2: %x op3: %x rd: %0d ", ex_op1, ex_op2, ex_op3, ex_rd);
        $display("  actual:    op1: %x op2: %x op3: %x rd: %0d ", op1, op2, op3, rd);
      end 
      if (oops) begin
        $display(">>> wrong!  \n");   
        errors++;
      end else begin
        if (chatty) $display(">>> correct! \n");
      end
    end
  endtask

  task automatic reg_tests;
    // test all register combinations for one of each type of instruciton

    logic oops, chatty = 1;    

    foreach (op_type_list[i]) begin
      for (rs1n = 0; rs1n<32; rs1n++) begin
        for (rs2n = 0; rs2n<32; rs2n++) begin
          for (rdn = 0; rdn<32; rdn++) begin
            instr = encode_instr(op_type_list[i], .rd(rdn), .rs1(rs1n), .rs2(rs2n), .imm(32'h76543210));
            oracle(instr, register_bank, ex_op1, ex_op2, ex_op3, ex_rd);
      
            enable = 1;
            @(posedge clk);
            enable = 0;
            @(posedge clk);

            repeat (5) @(posedge clk);
      
            oops = ((op1 != ex_op1) || (op2 != ex_op2) || (op3 != ex_op3) || (rd != ex_rd)) ? 1 : 0;
      
            if (oops || chatty) begin
              $display("instruction: %s ", decode_instr(instr));
              $display("  expected:  op1: %x op2: %x op3: %x rd: %0d ", ex_op1, ex_op2, ex_op3, ex_rd);
              $display("  actual:    op1: %x op2: %x op3: %x rd: %0d ", op1, op2, op3, rd);
            end 
            if (oops) begin
              $display(">>> wrong!  \n");   
              errors++;
            end else begin
              if (chatty) $display(">>> correct! \n");
            end
          end
        end
      end
    end
  endtask

  task automatic random_tests(input int num_tests);
    // test all register combinations for one of each type of instruciton
   
    opcode_mask_t op;
    int op_index;
    int imm;
    logic oops;
    logic chatty = 1;

    for (i=0; i<num_tests; i++) begin
      op_index = $urandom_range(0, opcode_list.size-1);
      op = opcode_list[op_index];
      rdn = $urandom_range(0,31);
      rs1n = $urandom_range(0,31);
      rs2n = $urandom_range(0,31);
      imm = $urandom();

      instr = encode_instr(op, .rd(rdn), .rs1(rs1n), .rs2(rs2n), .imm(imm)); 

      oracle(instr, register_bank, ex_op1, ex_op2, ex_op3, ex_rd);
      
      enable = 1;
      @(posedge clk);
      enable = 0;
      @(posedge clk);

      repeat (5) @(posedge clk);
      
      oops = ((op1 != ex_op1) || (op2 != ex_op2) || (op3 != ex_op3) || (rd != ex_rd)) ? 1 : 0;
      
      if (oops || chatty) begin
        $display("instruction: %s ", decode_instr(instr));
        $display("  expected:  op1: %x op2: %x op3: %x rd: %0d ", ex_op1, ex_op2, ex_op3, ex_rd);
        $display("  actual:    op1: %x op2: %x op3: %x rd: %0d ", op1, op2, op3, rd);
      end 
      if (oops) begin
        $display(">>> wrong!  \n");   
        errors++;
      end else begin
        if (chatty) $display(">>> correct! \n");
      end
    end
  endtask

  initial begin

    // deassert all inputs
    enable = 0;
    instr  = NO_OP;

    // initialize register bank
    foreach (register_bank[i]) register_bank[i] = i;

    // wait for reset
    @(posedge clk);
    wait (!rst);
    errors = 0;

    basic_tests;
    reg_tests;
    random_tests(1000);
      
    $write("\n\nDecoder unit test complete -- ");
    if (errors == 0) $display("Passed!\n\n");
    else begin
      $display("Failed!");
      $display("error count: %d \n\n", errors);
    end
    $finish;
  end

  assign instr_str = decode_instr(instr);

  decoder u_decoder(.*);

endmodule         
