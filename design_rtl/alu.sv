
import opcodes::*;

module alu #(
    parameter trace = 0,
    broken = "NONE"
  ) (
    input logic clk,
    input logic rst,
    input var instruction_t instr,  // Current instruction
    input register_t op1,           // Operand 1 (from register/immediate)
    input register_t op2,           // Operand 2 (from register/immediate)
    input logic enable,             // enable signal
    output logic instr_exec,        // opcode was executed
    output register_t result        // ALU result
  );

  register_t result_reg;

`ifndef SYNTHESIS
  function automatic register_t induce_errors(register_t data);
    if (broken == "ALU") begin
      if ($urandom_range(1,10)==7)   // 10% of the time flip a bit at random
        return data ^ register_t'(32'h1 << $urandom_range(0,31));
    end
    return(data);
  endfunction

  assign result = induce_errors(result_reg);
`else
  assign result = result_reg;
`endif

  always_ff @(posedge clk) begin
    if (rst) result_reg <= 0;
    else if (enable) begin
   
`ifndef SYNTHESIS
        // trace of code execution
        if (trace) if (enable && is_alu_op(instr))
            $display("%t executed: %s ", $time, decode_instr(instr));
`endif 
      instr_exec <= 1;

      casez (instr)
        // Arithmetic Operations
        M_ADD, M_ADDI  : result_reg <= op1 + op2;
        M_SUB          : result_reg <= op1 - op2;
            
        // Comparisons
        M_STLU, M_STLUI: result_reg <= ($unsigned(op1) < $unsigned(op2)) ? 1 : 0;
        M_STL, M_STLI  : result_reg <=   ($signed(op1) <   $signed(op2)) ? 1 : 0;
            
        // Logical Operations
        M_AND, M_ANDI  : result_reg <= op1 & op2;
        M_OR, M_ORI    : result_reg <= op1 | op2;
        M_XOR, M_XORI  : result_reg <= op1 ^ op2;
            
        // Shifts
        M_SLL, M_SLLI  : result_reg <= op1 << op2[4:0];
        M_SRL, M_SRLI  : result_reg <= $unsigned(op1) >>  op2[4:0];
        M_SRA, M_SRAI  : result_reg <=   $signed(op1) >>> op2[4:0];
            
        // Upper Immediate
        M_LUI          : result_reg <= op1;               // op1 = immediate
        M_AUIPC        : result_reg <= op1 + op2;         // op1 = immediate
          
        default: instr_exec <= 0;   // silently ignore bad opcodes, hold prior output

      endcase
    end else instr_exec <= 0;
  end

  mnemonic_t opcode;
  assign opcode = opc_base(instr);

  //--------------------------------------------------------------------------
  // Covergroup for ALU instructions and op1, op2
  //--------------------------------------------------------------------------
  covergroup alu_cg @(posedge clk);

    coverpoint opcode {
      bins instr[] = {ADD,  STLU,  STL,  AND,  OR,  XOR,  SLL,  SRL,  SRA,  SUB,
                      ADDI, STLUI, STLI, ANDI, ORI, XORI, SLLI, SRLI, SRAI,
                      LUI,  AUIPC};
    }
    // Cover op1 and op2
    coverpoint op1 {
      bins zero     = {0};
      bins positive = {[1:$]};
      bins negative = {[$:-1]};
    }
    coverpoint op2 {
      bins zero     = {0};
      bins positive = {[1:$]};
      bins negative = {[$:-1]};
    }
    // Cross coverage
    cross opcode, op1, op2;
  endgroup

  // Instantiate the covergroups
  alu_cg alu_cg_inst = new();

endmodule
 
