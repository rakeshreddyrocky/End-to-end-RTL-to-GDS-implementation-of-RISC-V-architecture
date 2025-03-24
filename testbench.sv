import opcodes::*;

const logic [2:0] BREAK = 3'b110;

module dut(
    input logic clk, rst
  );

  logic [31:0] reg_file [31:0];
  logic [2:0] state = BREAK;

  initial foreach (reg_file[i]) reg_file[i] = '0;

endmodule

module top;

  instruction_t instr;

  instruction_t code_memory ['h10000];

  /*
    initial begin // example of encoding function
      instr = encode_rtype(M_ADD, 3, 5, 17);
      print_opcode(instr);
      $display("instr = %x ", instr);
      $finish;
    end
  */

  logic clk, rst, core_rst;
   
  initial begin
    clk = 1;
    forever clk = #1 !clk;
  end

  initial begin
    rst = 0;
    rst = #1 1;
    rst = #20 0;
  end
  int errors = 0;

  task reset_core;

    core_rst = 1;
  
    repeat (3) @(posedge clk);
   
    core_rst = 0;

    @(posedge clk);

  endtask

  struct {
    opcode_mask_t opcode; 
    int op1;
    int op2;
    int expected_result;
    int rs1;
    int rs2;
    int rd;
  } testcase[] = '{
    '{ M_ADD,  10,  20,   30,  2,  3,  1 },
    '{ M_ADD,  -3,   3,    0,  4,  5,  6 },
    '{ M_ADD, 100, -101,  -1,  7,  8,  2 },
    '{ M_ADD, -22,  -22, -44,  7,  8,  2 },

    '{ M_SUB,  10,    5,   5,  2,  3,  1 },
    '{ M_SUB,  32,   76, -44,  1,  2,  3 },
    '{ M_SUB, -10,  -20,  10,  8,  7,  6 }
    // add more here
  };

  int rd, rs1, rs2, op1, op2;

  initial begin 
    @(posedge clk);
    wait (rst == 0);
    foreach (testcase[i]) begin

      rs1 = testcase[i].rs1;
      rs2 = testcase[i].rs2;
      op1 = testcase[i].op1;
      op2 = testcase[i].op2;

      // set input values into registers

      force stub.reg_file[rs1] = op1;
      force stub.reg_file[rs2] = op2;

      // put opcode into memory[0];

      code_memory[0] = encode_rtype(testcase[i].opcode, rd, rs1, rs2);
      code_memory[1] = HALT;

      // reset core

      reset_core;

      wait (stub.state == BREAK);  // wait for state to reach end of program 

      $write("instruction: ");
      print_opcode(code_memory[0]); 
      $display("  reg[%0d] = %0d reg[%0d] = %0d reg[%0d] = %0d ", rs1, op1, rs2, op2, rd,  stub.reg_file[rd]);

      $write("  >>> expected: %0d actual: %0d ", testcase[i].expected_result, stub.reg_file[rd]);
      if (testcase[i].expected_result != stub.reg_file[rd]) begin // handle errors
        $display (" === Fail! \n");
        errors ++;
      end else begin
        $display (" === Pass \n");
      end
    end
    $display("quick test complete... errors = %d \n", errors); 
    $finish;
  end 



  dut stub (
    .clk  (clk),
    .rst  (core_rst)

    // more signals...
  );    
    

endmodule
