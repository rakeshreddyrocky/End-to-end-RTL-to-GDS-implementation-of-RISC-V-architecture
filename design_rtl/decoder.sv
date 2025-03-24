import opcodes::*;

module decoder #(
   parameter broken = "NONE"
 )(
  input logic clk, rst,

  input wire instruction_t instr,
  input logic enable,
  input wire register_t register_bank[32],

  output register_t op1, op2, op3, 
  output register_num_t rd);

  instruction_t instr_reg;
  register_num_t rs1, rs2;
  register_t imm;
  register_num_t rd_reg;

`ifndef SYNTHESIS

  function automatic register_t induce_errors(register_t data);
    if (broken == "DEC") begin
      if ($urandom_range(1,10)==7)   // 10% of the time flip a bit at random
        return data ^ register_t'(32'h1 << $urandom_range(0,31));
    end
    return(data);
  endfunction

  string debug_opcode;

  mnemonic_t opcode;
  assign opcode = opc_base(instr);
 
  assign rd = rd_reg;
`else
  assign rd = rd_reg;
`endif

  assign debug_opcode = decode_instr(instr); 

  always_ff @(posedge clk) begin
    if (rst) begin
      rs1 <= '0;
      rs2 <= '0;
      imm <= '0;
      rd_reg <= '0;
      instr_reg <= '0;
    end else begin 
      if (enable) begin
        rs1 <= get_rs1(instr);
        rs2 <= get_rs2(instr);
        imm <= get_imm(instr);
        rd_reg  <= get_rd(instr);
        instr_reg <= instr;
      end
    end
  end

  always_comb begin
    op1 = '0;
    op2 = '0;
    op3 = '0;
    case (1)
      is_r_type(instr_reg): begin
          op1 = register_bank[rs1];
          op2 = register_bank[rs2];
        end
      is_i_type(instr_reg): begin
          op1 = register_bank[rs1];
          op2 = imm;
        end
      is_si_type(instr_reg): begin
          op1 = register_bank[rs1];
          op2 = imm;
        end
      is_s_type(instr_reg): begin
          op1 = register_bank[rs1]; 
          op2 = imm;                
          op3 = register_bank[rs2]; 
        end
      is_b_type(instr_reg): begin
          op1 = register_bank[rs1];
          op2 = register_bank[rs2];
          op3 = imm;
        end
      is_u_type(instr_reg): begin
          op1 = imm; 
        end
      is_j_type(instr_reg): begin
          op1 = imm; 
        end
      (instr_reg == EBREAK) : op1 = '0;
      //  default: $error("invalid opcode in decoder: %x ", instr);
    endcase
`ifndef SYNTHESIS
    op1 = induce_errors(op1);
    op2 = induce_errors(op2);
    op3 = induce_errors(op3);
`endif
  end 


   covergroup opcodes_cg @(posedge clk);
     coverpoint opcode {
        bins instr[] = {
             ADD, SUB, AND, OR, XOR, SLL, SRA, STL, STLU, 
             ADDI, ANDI, ORI,  XORI, SLLI, SRAI, STL, STLU, LW, LH, LHU, LB, LBU, JALR,
             STLI, STLUI,
             LUI, AUIPC,
             SW, SH, SB,
             BEQ, BNE, BLT, BGE, BLTU, BGEU,
             JAL };
     }
   endgroup

   covergroup regs_cg @(posedge clk);
     coverpoint opcode {
       bins r_type = { ADD, SUB, AND, OR, XOR, SLL, SRA, STL, STLU };
       bins i_type = { ADDI, ANDI, ORI,  XORI, SLLI, SRAI, STL, STLU, LW, LH, LHU, LB, LBU, JALR };
       bins si_type = { STLI, STLUI };
       bins u_type = { LUI, AUIPC };
       bins s_type = { SW, SH, SB };
       bins b_type = { BEQ, BNE, BLT, BGE, BLTU, BGEU };
       bins j_type = { JAL };
     }
     coverpoint rs1 {
       bins n[4] = {[0:31]};
     }
     coverpoint rs2 {
       bins n[4] = {[0:31]};
     }
     coverpoint rd {
       bins n[4] = {[0:31]};
     }
     cross opcode, rs1, rs2, rd;
   endgroup

   covergroup one_operand_cg @(posedge clk);
     coverpoint opcode {
       bins one_operand = { JAL, LUI, AUIPC };
     }
     coverpoint op1 {
       bins negative = {[$:-1]};
       bins zero     = { 0 };
       bins positive = {[1:$]};
     }
     cross opcode, op1;
   endgroup

   covergroup two_operand_cg @(posedge clk);
     coverpoint opcode {
       bins two_operand = {
              ADD, SUB, AND, OR, XOR, SLL, SRA, STL, STLU,
              ADDI, ANDI, ORI,  XORI, SLLI, SRAI, STL, STLU, LW, LH, LHU, LB, LBU, JALR,
              STLI, STLUI };
     }
     coverpoint op1 {
       bins negative = {[$:-1]};
       bins zero     = { 0 };
       bins positive = {[1:$]};
     }
     coverpoint op2 {
       bins negative = {[$:-1]};
       bins zero     = { 0 };
       bins positive = {[1:$]};
     }
     cross opcode, op1, op2;
   endgroup

   covergroup three_operand_cg @(posedge clk);
     coverpoint opcode {
       bins three_operand = { SW, SH, SB, BEQ, BNE, BLT, BGE, BLTU, BGEU };
     }
     coverpoint op1 {
       bins negative = {[$:-1]};
       bins zero     = { 0 };
       bins positive = {[1:$]};
     }
     coverpoint op2 {
       bins negative = {[$:-1]};
       bins zero     = { 0 };
       bins positive = {[1:$]};
     }
     coverpoint op3 {
       bins negative = {[$:-1]};
       bins zero     = { 0 };
       bins positive = {[1:$]};
     }
     cross opcode, op1, op2, op3;
   endgroup

   opcodes_cg        opcodes_inst       = new();
   regs_cg           regs_inst          = new();
   one_operand_cg    one_operand_inst   = new();
   two_operand_cg    two_operand_inst   = new();
   three_operand_cg  three_operand_inst = new();

endmodule

