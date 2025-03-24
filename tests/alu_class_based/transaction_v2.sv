package trans_v1;
import opcodes::*;

// Define the opcode list for ALU operations
opcode_mask_t opcode_list [] =
 {
     // R-Type Instructions
     M_ADD, M_SUB, M_AND, M_OR, M_XOR, M_SLL, M_SRL, M_SRA, M_STL, M_STLU,

     // I-Type Instructions
     M_ADDI, M_ANDI, M_ORI, M_XORI, M_SLLI, M_SRLI, M_SRAI,

     // SI-Type Instructions
     M_STLI, M_STLUI,

     // U-Type Instructions
     M_LUI, M_AUIPC
 };

class transaction;
    rand register_num_t rs1, rs2, rd;  // Source and destination registers
    rand int imm;                      // Immediate value
    rand instruction_t instr;           // Encoded instruction
    rand int op_index;                   // Randomly chosen instruction index
    register_t op1, op2;                // Operands for ALU
    register_t result;                   // ALU result
    logic instr_exec;
    bit enable;

    // Constraints to select a valid instruction
    constraint c1 { op_index inside {[0:opcode_list.size-1]}; }
    constraint c2 { imm inside {[0:31]}; }  // Limit immediate range

    function void post_randomize();
        // Encode the selected instruction
        instr = encode_instr(opcode_list[op_index], .rd(rd), .rs1(rs1), .rs2(rs2), .imm(imm));

        // Assign operands based on instruction type
        if (is_r_type(instr)) begin
            op1 = rs1;   // For R-type, op1 is value of rs1
            op2 = rs2;   // For R-type, op2 is value of rs2
        end else if (is_i_type(instr) || is_si_type(instr)) begin
            op1 = rs1;   // For I-type, op1 is rs1
            op2 = imm;   // For I-type, op2 is immediate
        end else if (is_u_type(instr)) begin
            op1 = imm;   // For U-type, op1 is the immediate
            op2 = 0;     // Unused, default to 0
        end else begin
            op1 = rs1;   // Default case
            op2 = rs2;
        end
    endfunction

    function void print();
        $display("Transaction -> instr=%s | rs1=%0d | rs2=%0d | rd=%0d | imm=%0d | op1=%0d | op2=%0d | result=%0h",
                 decode_instr(instr), rs1, rs2, rd, imm, op1, op2, result);
    endfunction
endclass
endpackage
