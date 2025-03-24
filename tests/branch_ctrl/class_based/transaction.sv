package pkg;

import opcodes::*;
	
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
   

class transaction;
    
	rand register_num_t rs1, rs2,rd;
    rand int imm;
	rand mnemonic_t        mnemonic; 
	rand instruction_t instr;
	rand register_t op1,op2,op3;
	logic enable; 
	rand int op_index;
	opcode_mask_t opcode;
    register_t pc_out, ret_addr;
	
	constraint op_c {
		instr inside {[0:10]};
		op1 inside {[0:31]};
		op2 inside {[0:31]};
		op3 inside {[0:31]};
  }
  
  constraint c1 { op_index inside {[0:opcode_list.size-1]};}
  /*
  function void post_randomize(); 

    instr = encode_instr(opcode_list[op_index], .rd(rd), .rs1(rs1), .rs2(rs2), .imm(imm));
endfunction
	*/
function void display();
      $display("instr=%0d,op1=%0d,op2=%0d,op3=%0d,enable=%0d", instr, op1, op2, op3,enable);
 endfunction
	
endclass

endpackage
