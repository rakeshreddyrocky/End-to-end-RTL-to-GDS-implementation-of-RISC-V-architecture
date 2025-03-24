
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

  function automatic register_t oracle(
      input instruction_t i,
      input register_t op1, op2);

      casez (i)
        M_ADD, M_ADDI  : return op1 + op2;
        M_SUB          : return op1 - op2;
        M_STL, M_STLI  : return (unsigned'(op1) < unsigned'(op2)) ? 1 : 0;
        M_STLU, M_STLUI: return (op1 < op2) ? 1 : 0;
        M_AND, M_ANDI  : return op1 & op2;
        M_OR,  M_ORI   : return op1 | op2;
        M_XOR, M_XORI  : return op1 ^ op2;
        M_SLL, M_SLLI  : return op1 << op2[4:0];
        M_SRL, M_SRLI  : return unsigned'(op1) >> op2[4:0];
        M_SRA, M_SRAI  : return op1 >> op2[4:0];
        M_LUI          : return op1;
        M_AUIPC        : return op1;
      endcase

  endfunction

  instruction_t instr;
  logic         instr_exec;
  register_t    op1, op2, result, expected_result;
  logic         enable;
 
  int           errors;  

  register_t operands[] = { -3, -2, -1, 0, 1, 2, 3, 4, 100, 128, 16000,
                            32'hFFFFFFFF, 32'h00000000, 32'hAAAA5555, 32'h5555AAAA,
                            32'hFFFF0000, 32'h0000FFFF, 32'hF0F0F0F0, 32'h0F0F0F0F,
                            32'h55AA55AA, 32'hAA55AA55, 32'h12345678, 32'h90ABCDEF };

  opcode_mask_t ops [] = { M_ADD, M_AND, M_OR, M_XOR, M_SRL, M_SLL };

  initial begin
    @(posedge clk);
    wait (!rst);
    errors = 0;

    foreach (operands[a]) begin
      foreach (operands[b]) begin
        foreach (ops[c]) begin
          
          instr = encode_rtype(ops[c], 1, 2, 3);
          op1 = operands[a];
          op2 = operands[b];
          enable = 1;
          @(posedge clk);
          enable = 0;
          @(posedge clk);
          expected_result = oracle(instr, op1, op2);

          print_opcode(instr);
          $display("   operand 0: %x operand 1: %x ", op1, op2);
          $write  ("   expected result: %x actual result: %x ", expected_result, result);
          if (result == expected_result) $display("correct \n");
          else begin
            $display("wrong!  \n");   
            errors++;
          end
          repeat (5) @(posedge clk);
        end
      end
    end
    
    $write("\n\nALU unit test complete -- ");
    if (errors == 0) $display("Passed!\n\n");
    else begin
      $display("Failed!");
      $display("error count: %d \n\n", errors);
    end
    $finish;
  end

  alu u_alu(.*);

endmodule         
