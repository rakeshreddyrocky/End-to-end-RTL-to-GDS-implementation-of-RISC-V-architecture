
import opcodes::*;

module branch_unit #(
   broken = "NONE"
 ) (
   input logic          clk, rst,

   input wire instruction_t  instr,
   input register_t     op1, op2, op3,
   input logic          enable,        
   output register_t    pc_out,
   output register_t    ret_addr);

   register_t pc, next_pc;

`ifndef SYNTHESIS

   function automatic register_t induce_errors(register_t data);
     if (broken == "BCU") begin
       if ($urandom_range(1,10)==5) begin   // 10% of the time flip a bit at random begin
         return data ^ register_t'(32'h1 << $urandom_range(0,15));
       end
     end
     return(data);
   endfunction

   // assign pc_out = (count< 10) ?  pc : induce_errors(pc);
   assign pc_out = induce_errors(pc);
`else
   assign pc_out = pc;
`endif

   assign pc = next_pc;

   always_ff @(posedge clk) begin
     if (rst) next_pc <= '0;
     else begin
       if (enable) begin
         ret_addr <= pc + 4;
	//	 $display("[DUT] Enable=%0b, instr=%0d, op1=%0d, op2=%0d, op3=%0d", enable, instr, op1, op2, op3);
         casez (instr) 
		   // Standard RISC-V Jump Instructions
           M_JAL  : next_pc <= op1;
           M_JALR : next_pc <= op1 + op2;
		   
		   // Standard RISC-V Branch Instructions
           M_BEQ  : next_pc <= (op1 == op2) ? pc + op3 : pc + 4;
           M_BNE  : next_pc <= (op1 != op2) ? pc + op3 : pc + 4;
           M_BLT  : next_pc <= (op1 < op2)  ? pc + op3 : pc + 4;
           M_BLTU : next_pc <= (unsigned'(op1) < unsigned'(op2)) ? pc + op3 : pc + 4;
           M_BGE  : next_pc <= (op1 >= op2) ? pc + op3 : pc + 4;
           M_BGEU : next_pc <= (unsigned'(op1) >= unsigned'(op2)) ? pc + op3 : pc + 4;
           default : next_pc <= pc + 4;
         endcase
	 //	 $display("[DUT] PC Updated: pc=%0h, ret_addr=%0h", pc, ret_addr);
       end
     end
   end
   mnemonic_t opcode;
   assign opcode = opc_base(instr);
 

   //--------------------------------------------------------------------------
   // Covergroup for branch instructions and resulting PC (pc_out)
   //--------------------------------------------------------------------------
   covergroup branch_cg @(posedge clk);
     
     coverpoint opcode {
       bins instr[] = {JAL,JALR,BEQ,BNE,BLT,BLTU,BGE,BGEU};
     }
     // Cover the new PC (next_pc).
     coverpoint next_pc {
       ignore_bins zero = {0};   // branch of zero is pointless
       bins positive = { [1:$] };
       bins negative = { [$:-1] };
     }
     // Cross coverage 
     cross opcode, next_pc;
   endgroup

   // Instantiate the covergroups
   branch_cg branch_cg_inst = new();

endmodule
