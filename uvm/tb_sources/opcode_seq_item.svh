
class opcode_seq_item_c extends uvm_sequence_item;
  `uvm_object_utils(opcode_seq_item_c)

  function new(string name="opcode_seq_item_c");
    super.new(name);
  endfunction

  rand int            opcode_index;
  rand register_num_t rs1, rs2, rd;
  rand register_t     register_bank[32];
  rand register_t     read_data;
  rand register_t     imm;
  instruction_t       instr;
  opcode_mask_t       opcode;
  register_t          result;
  logic               write_op;
  register_t          waddr;
  register_t          wdata;
  register_t          next_pc;

  opcode_mask_t opcode_list [] = {
    /* R Type */   M_ADD, M_SUB, M_AND, M_OR, M_XOR, M_SLL, M_SRA, M_STL, M_STLU, M_SRL,
    /* I Type */   M_ADDI, M_ANDI, M_ORI,  M_XORI, M_SLLI, M_SRAI, M_STL, M_SRLI, M_LW, M_LH, M_LHU, M_LB, M_LBU, M_JALR,
    /* SI Type*/   M_STLI, M_STLUI,
    /* U Type */   M_LUI, M_AUIPC,
    /* S Type */   M_SW, M_SH, M_SB,
    /* B Type */   M_BEQ, M_BNE, M_BLT, M_BGE, M_BLTU, M_BGEU,
    /* J Type */   M_JAL };

  // opcode limited to list of available codes to test
  constraint c_op_idx {opcode_index inside {[0:opcode_list.size-1]}; }

  // destinaiton register cannot be 0
  constraint c_rd { rd > 0; }

  // register 0 must be 0
  constraint c_r0 { register_bank[0] == 0; }

  function void post_randomize();

    opcode = opcode_list[opcode_index];

    if ((opcode === M_LW) || (opcode === M_SW)) begin // align and trim word accesses 
      register_bank[rs1] = register_bank[rs1] & 'h7FFC;
      imm = imm & 'h7FFC;
    end

    if ((opcode === M_LH) || (opcode === M_LHU) || (opcode === M_SH)) begin // align and trim half word access
      register_bank[rs1] = register_bank[rs1] & 'h7FFE;
      imm = imm & 'h7FFE;
    end

    if ((opcode === M_LB) || (opcode === M_LBU) || (opcode === M_SB)) begin // trim byte access
      register_bank[rs1] = register_bank[rs1] & 'h7FFF;
      imm = imm & 'h7FFF;
    end

    instr  = encode_instr(opcode, .rd(rd), .rs1(rs1), .rs2(rs2), .imm(imm));
  endfunction

endclass

