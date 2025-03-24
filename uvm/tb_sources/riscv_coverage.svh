
`uvm_analysis_imp_decl(_rtl_coverage_port)

class riscv_coverage_c extends uvm_scoreboard;
  virtual interface cpu_state_i   cs_vif;
  cpu_exec_record_c rtl_exec;
  real cov;
  mnemonic_t opcode;
  register_num_t rd, rs1, rs2;
  register_t result;
  op_type_t op_type;

  uvm_analysis_imp_rtl_coverage_port#(cpu_exec_record_c, riscv_coverage_c) rtl_coverage_port;

  `uvm_component_utils(riscv_coverage_c)

  //--------------------------------------------------------------------------
  // Covergroup for UVM interface
  //--------------------------------------------------------------------------
  covergroup uvm_cg;

    coverpoint opcode {
      bins instr[] = {ADD,  STLU,  STL,  AND,  OR,  XOR,  SLL,  SRL,  SRA,  SUB,
                      ADDI, STLUI, STLI, ANDI, ORI, XORI, SLLI, SRLI, SRAI,
                      LUI,  AUIPC, JAL,  JALR, BEQ, BNE,  BLT,  BLTU, BGE,  BGEU,
                      LW,   LH,    LHU,  LB,   LBU, SW,   SH,   SB};
    }
    cp_opt_r: coverpoint op_type {
      bins opt_r[] = { R_TYPE }; 
    } 
    cp_opt_is: coverpoint op_type {
      bins opt_is[] = { I_TYPE, SI_TYPE};
    }
    cp_opt_bs: coverpoint op_type {
      bins opt_bs[] = { B_TYPE, S_TYPE };
    }
    cp_opt_uj: coverpoint op_type {
      bins opt_uj[] = { U_TYPE, J_TYPE };
    }
    cp_rd: coverpoint rd {
      bins n[4] = {[0:31]};
    }
    cp_rs1: coverpoint rs1 {
      bins b[4] = {[0:31]};
    }
    cp_rs2: coverpoint rs2 {
      bins b[4] = {[0:31]};
    }
    coverpoint result {
      bins n[2] = {[$:$]};
    }
    // Cross coverage
    cross cp_opt_r,  cp_rd,  cp_rs1, cp_rs2;
    cross cp_opt_is, cp_rd,  cp_rs1;
    cross cp_opt_bs, cp_rs1, cp_rs2;
    cross cp_opt_uj, cp_rd;

  endgroup

  function new(string name, uvm_component parent);
    super.new(name, parent);

    rtl_coverage_port = new("rtl_coverage_port", this);
    uvm_cg = new();
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);

    rtl_exec = cpu_exec_record_c::type_id::create("rtl_exec");
  endfunction

  virtual function void write_rtl_coverage_port( // how is this not named "read"???
    cpu_exec_record_c exec_rec);

    opcode = opc_base(exec_rec.instr);
    op_type = opc_type(exec_rec.instr);
    rs1 = get_rs1(exec_rec.instr);
    rs2 = get_rs2(exec_rec.instr);
    rd = exec_rec.rd;
    result = exec_rec.result;

    uvm_cg.sample();
  endfunction

  virtual function void report_phase(uvm_phase phase);
    super.report_phase(phase);

    `uvm_info(get_type_name(), $sformatf("Coverage percentage: %f ", uvm_cg.get_coverage()), UVM_NONE);
  endfunction
endclass

