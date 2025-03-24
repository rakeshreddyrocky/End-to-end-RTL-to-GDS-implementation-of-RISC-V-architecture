package opcodes;

localparam XLEN = 32;

typedef logic [6:0] base_opcode_t;
typedef logic [4:0] register_num_t;
typedef logic [2:0] funct3_t;
typedef logic [6:0] funct7_t;
typedef logic        [4:0]  tiny_imm_t;
typedef logic signed [11:0] short_imm_t;
typedef logic signed [13:0] b_imm_t;
typedef logic signed [19:0] long_imm_t;
typedef logic signed [20:0] j_imm_t;
typedef logic signed [XLEN-1:0] register_t;

typedef struct packed {
   funct7_t        opcode3;
   register_num_t  rs2;
   register_num_t  rs1;
   funct3_t        opcode2;
   register_num_t  rd;
   base_opcode_t   opcode1;
} r_type;

typedef struct packed {
   logic [11:0]    imm;
   register_num_t  rs1;
   funct3_t        opcode2;
   register_num_t  rd;
   base_opcode_t   opcode1;
} i_type;

typedef struct packed {
   funct7_t        opcode3;
   tiny_imm_t      imm;
   register_num_t  rs1;
   funct3_t        opcode2;
   register_num_t  rd;
   base_opcode_t   opcode1;
} short_i_type;

typedef struct packed {
   logic [6:0]     imm1;
   register_num_t  rs2;
   register_num_t  rs1;
   funct3_t        opcode2;
   logic [4:0]     imm0;
   base_opcode_t   opcode1;
} s_type;

typedef struct packed {
   logic           imm3;
   logic [5:0]     imm1;
   register_num_t  rs2;
   register_num_t  rs1;
   funct3_t        opcode2;
   logic [3:0]     imm0;
   logic           imm2;
   base_opcode_t   opcode1;
} b_type;

typedef struct packed {
   logic [19:0]    imm;
   register_num_t  rd;
   base_opcode_t   opcode1;
} u_type;

typedef struct packed {
   logic           imm3;
   logic [9:0]     imm0;
   logic           imm1;
   logic [7:0]     imm2;
   register_num_t  rd;
   base_opcode_t   opcode1;
} j_type;

typedef union packed {
  r_type  r;
  i_type  i;
  short_i_type si;
  s_type  s;
  b_type  b;
  u_type  u;
  j_type  j;
} instruction_t;

const instruction_t HALT = 32'h00010073;

typedef enum logic [5:0] { 
    ADDI, STLI, STLUI, ANDI, ORI,  XORI, SLLI, SRLI, SRAI, LUI, AUIPC,
    ADD,  SUB,  STL,   STLU, AND,  OR,   XOR,  SLL,  SRL,  SRA,
    JAL,  JALR, BEQ,   BNE,  BLT,  BLTU, BGE,  BGEU,
    LW,   LH,   LB,    LHU,   LBU,  SW,   SH,   SB 
  } mnemonic_t;

typedef enum logic [2:0] {
    R_TYPE, I_TYPE, SI_TYPE, S_TYPE, B_TYPE, U_TYPE, J_TYPE 
  } op_type_t;

typedef enum logic [2:0] {
    ALU, BRU, MAU
  } proc_unit_t;

typedef enum logic [31:0] {

   M_ADDI  = 32'bzzzz_zzzz_zzzz_zzzz_z000_zzzz_z001_0011,
   M_STLI  = 32'bzzzz_zzzz_zzzz_zzzz_z010_zzzz_z001_0011,
   M_STLUI = 32'bzzzz_zzzz_zzzz_zzzz_z011_zzzz_z001_0011,
   M_ANDI  = 32'bzzzz_zzzz_zzzz_zzzz_z111_zzzz_z001_0011,
   M_ORI   = 32'bzzzz_zzzz_zzzz_zzzz_z110_zzzz_z001_0011,
   M_XORI  = 32'bzzzz_zzzz_zzzz_zzzz_z100_zzzz_z001_0011,
   M_SLLI  = 32'b0000_000z_zzzz_zzzz_z001_zzzz_z001_0011,
   M_SRLI  = 32'b0000_000z_zzzz_zzzz_z101_zzzz_z001_0011,
   M_SRAI  = 32'b0100_000z_zzzz_zzzz_z101_zzzz_z001_0011,
   M_LUI   = 32'bzzzz_zzzz_zzzz_zzzz_zzzz_zzzz_z011_0111,
   M_AUIPC = 32'bzzzz_zzzz_zzzz_zzzz_zzzz_zzzz_z001_0111,

   M_ADD   = 32'b0000_000z_zzzz_zzzz_z000_zzzz_z011_0011,
   M_SUB   = 32'b0100_000z_zzzz_zzzz_z000_zzzz_z011_0011,
   M_STL   = 32'b0000_000z_zzzz_zzzz_z010_zzzz_z011_0011,
   M_STLU  = 32'b0000_000z_zzzz_zzzz_z011_zzzz_z011_0011,
   M_AND   = 32'b0000_000z_zzzz_zzzz_z111_zzzz_z011_0011,
   M_OR    = 32'b0000_000z_zzzz_zzzz_z110_zzzz_z011_0011,
   M_XOR   = 32'b0000_000z_zzzz_zzzz_z100_zzzz_z011_0011,
   M_SLL   = 32'b0000_000z_zzzz_zzzz_z001_zzzz_z011_0011,
   M_SRL   = 32'b0000_000z_zzzz_zzzz_z101_zzzz_z011_0011,
   M_SRA   = 32'b0100_000z_zzzz_zzzz_z101_zzzz_z011_0011,

   M_JAL   = 32'bzzzz_zzzz_zzzz_zzzz_zzzz_zzzz_z110_1111,
   M_JALR  = 32'bzzzz_zzzz_zzzz_zzzz_z000_zzzz_z110_0111,
   M_BEQ   = 32'bzzzz_zzzz_zzzz_zzzz_z000_zzzz_z110_0011,
   M_BNE   = 32'bzzzz_zzzz_zzzz_zzzz_z001_zzzz_z110_0011,
   M_BLT   = 32'bzzzz_zzzz_zzzz_zzzz_z100_zzzz_z110_0011,
   M_BLTU  = 32'bzzzz_zzzz_zzzz_zzzz_z110_zzzz_z110_0011,
   M_BGE   = 32'bzzzz_zzzz_zzzz_zzzz_z101_zzzz_z110_0011,
   M_BGEU  = 32'bzzzz_zzzz_zzzz_zzzz_z111_zzzz_z110_0011,
   
   M_LW    = 32'bzzzz_zzzz_zzzz_zzzz_z010_zzzz_z000_0011,
   M_LH    = 32'bzzzz_zzzz_zzzz_zzzz_z001_zzzz_z000_0011,
   M_LHU   = 32'bzzzz_zzzz_zzzz_zzzz_z101_zzzz_z000_0011,
   M_LB    = 32'bzzzz_zzzz_zzzz_zzzz_z000_zzzz_z000_0011,
   M_LBU   = 32'bzzzz_zzzz_zzzz_zzzz_z100_zzzz_z000_0011,

   M_SW    = 32'bzzzz_zzzz_zzzz_zzzz_z010_zzzz_z010_0011,
   M_SH    = 32'bzzzz_zzzz_zzzz_zzzz_z001_zzzz_z010_0011,
   M_SB    = 32'bzzzz_zzzz_zzzz_zzzz_z000_zzzz_z010_0011

} opcode_mask_t;

function automatic logic is_r_type(input instruction_t instr);

   casez (instr)
    M_ADD, M_SUB, M_STL, M_STLU, M_AND, M_OR, M_XOR, M_SLL, M_SRL, M_SRA : return 1;
    default : return 0;
   endcase

endfunction

function automatic logic is_i_type(input instruction_t instr);  

   casez (instr)
    M_ADDI, M_STLI, M_STLUI, M_ANDI, M_ORI, M_XORI, /* M_SLLI,
    M_SRLI, M_SRAI, */ M_LW, M_LH, M_LHU, M_LB, M_LBU, M_JALR : return 1;
    default : return 0;
   endcase

endfunction

function automatic logic is_si_type(input instruction_t instr);

   casez (instr) 
    M_SLLI, M_SRLI, M_SRAI : return 1;
    default : return 0;
   endcase

endfunction 

function automatic logic is_s_type(input instruction_t instr);  

   casez (instr)
    M_SW, M_SH, M_SB : return 1;
    default : return 0;
   endcase

endfunction
 
function automatic logic is_b_type(input instruction_t instr);  

   casez (instr)
    M_BEQ, M_BNE, M_BLT, M_BLTU, M_BGE, M_BGEU : return 1;
    default : return 0;
   endcase

endfunction
 
function automatic logic is_u_type(input instruction_t instr);  

   casez (instr)
    M_AUIPC, M_LUI : return 1;
    default : return 0;
   endcase

endfunction
 
function automatic logic is_j_type(input instruction_t instr);  

   casez (instr)
    M_JAL : return 1;
    default : return 0;
   endcase

endfunction

function automatic logic is_alu_op(input instruction_t instr);
  
   casez(instr)
    M_ADD, M_SUB, M_STL, M_STLU, M_AND, M_OR, M_XOR, M_SLL, M_SRL, 
    M_SRA, M_ADDI, M_STLI, M_STLUI, M_ANDI, M_ORI, M_XORI, M_SLLI,
    M_SRLI, M_SRAI, M_LUI, M_AUIPC : return 1;
    default: return 0;
   endcase
     
endfunction

function automatic logic is_branch_op(input instruction_t instr);

   casez(instr)
    M_JAL, M_JALR, M_BEQ, M_BNE, M_BLT, M_BLTU, M_BGE, M_BGEU: return 1;
    default: return 0;
   endcase

endfunction

function automatic logic is_memory_op(input instruction_t instr);
  
   casez(instr) 
    M_LW, M_LH, M_LHU, M_LB, M_LBU, M_SW, M_SH, M_SB: return 1;
    default: return 0;
   endcase

endfunction

function automatic register_num_t get_rd(instruction_t instr);
  case (1) 
   is_r_type(instr) : return instr.r.rd;
   is_i_type(instr) : return instr.i.rd;
   is_si_type(instr) : return instr.i.rd;
   is_u_type(instr) : return instr.u.rd;
   is_j_type(instr) : return instr.j.rd;
   default : return 0;
  endcase
endfunction

function automatic register_num_t get_rs1(instruction_t instr);
  case (1) 
   is_r_type(instr) : return instr.r.rs1;
   is_i_type(instr) : return instr.i.rs1;
   is_si_type(instr) : return instr.i.rs1;
   is_s_type(instr) : return instr.s.rs1;
   is_b_type(instr) : return instr.b.rs1;
   default : return 0;
  endcase
endfunction

function automatic register_num_t get_rs2(instruction_t instr);
  case (1) 
   is_r_type(instr) : return instr.r.rs2;
   is_s_type(instr) : return instr.s.rs2;
   is_b_type(instr) : return instr.b.rs2;
   default : return 0;
  endcase
endfunction

function automatic register_t get_imm(instruction_t instr);
  case(1)
   is_i_type(instr) : return get_i_imm(instr);
   is_si_type(instr) : return get_si_imm(instr);
   is_s_type(instr) : return get_s_imm(instr);
   is_b_type(instr) : return get_b_imm(instr);
   is_u_type(instr) : return get_u_imm(instr);
   is_j_type(instr) : return get_j_imm(instr);
   default : return 0;
  endcase
endfunction


function void print_opcode(instruction_t instr);
   $display(decode_instr(instr));
endfunction

function string frc(input int r);
  return (r<10) ? $sformatf(" x%0d,", r) :
                  $sformatf("x%0d,", r);
endfunction

function string fr(input int r);
  return (r<10) ? $sformatf(" x%0d", r) :
                  $sformatf("x%0d", r);
endfunction

function string fri(input int r);
  return $sformatf("x%0d", r);
endfunction

function string fi(input int i);
  return $sformatf("%0d", i);
endfunction

const instruction_t EBREAK = 32'h00100073;

function string decode_instr(instruction_t instr);

   casez (instr) 
     // R-Type Instructions
     M_ADD   : return $sformatf("ADD   %s %s %s", frc(instr.r.rd), frc(instr.r.rs1), fr(instr.r.rs2));
     M_SUB   : return $sformatf("SUB   %s %s %s", frc(instr.r.rd), frc(instr.r.rs1), fr(instr.r.rs2));
     M_AND   : return $sformatf("AND   %s %s %s", frc(instr.r.rd), frc(instr.r.rs1), fr(instr.r.rs2));
     M_OR    : return $sformatf("OR    %s %s %s", frc(instr.r.rd), frc(instr.r.rs1), fr(instr.r.rs2));
     M_XOR   : return $sformatf("XOR   %s %s %s", frc(instr.r.rd), frc(instr.r.rs1), fr(instr.r.rs2));
     M_SLL   : return $sformatf("SLL   %s %s %s", frc(instr.r.rd), frc(instr.r.rs1), fr(instr.r.rs2));
     M_SRL   : return $sformatf("SRL   %s %s %s", frc(instr.r.rd), frc(instr.r.rs1), fr(instr.r.rs2));
     M_SRA   : return $sformatf("SRA   %s %s %s", frc(instr.r.rd), frc(instr.r.rs1), fr(instr.r.rs2));
     M_STL   : return $sformatf("STL   %s %s %s", frc(instr.r.rd), frc(instr.r.rs1), fr(instr.r.rs2));
     M_STLU  : return $sformatf("STLU  %s %s %s", frc(instr.r.rd), frc(instr.r.rs1), fr(instr.r.rs2));

     // I-Type Instructions
     M_ADDI  : return $sformatf("ADDI  %s %s %s", frc(instr.i.rd), frc(instr.i.rs1), fi(instr.i.imm));
     M_ANDI  : return $sformatf("ANDI  %s %s %s", frc(instr.i.rd), frc(instr.i.rs1), fi(instr.i.imm));
     M_ORI   : return $sformatf("ORI   %s %s %s", frc(instr.i.rd), frc(instr.i.rs1), fi(instr.i.imm));
     M_XORI  : return $sformatf("XORI  %s %s %s", frc(instr.i.rd), frc(instr.i.rs1), fi(instr.i.imm));
     M_SLLI  : return $sformatf("SLLI  %s %s %s", frc(instr.i.rd), frc(instr.i.rs1), fi(instr.i.imm));
     M_SRLI  : return $sformatf("SRLI  %s %s %s", frc(instr.i.rd), frc(instr.i.rs1), fi(instr.i.imm));
     M_SRAI  : return $sformatf("SRAI  %s %s %s", frc(instr.i.rd), frc(instr.i.rs1), fi(instr.i.imm));

     // SI-Type Instructions
     M_STLI  : return $sformatf("STLI  %s %s %s", frc(instr.si.rd), frc(instr.si.rs1), fi(instr.si.imm));
     M_STLUI : return $sformatf("STLUI %s %s %s", frc(instr.si.rd), frc(instr.si.rs1), fi(instr.si.imm));

     // U-Type Instructions
     M_LUI   : return $sformatf("LUI   %s %s", frc(instr.u.rd), fi(instr.u.imm));
     M_AUIPC : return $sformatf("AUIPC %s %s", frc(instr.u.rd), fi(instr.u.imm));

     // S-Type Instructions
     M_SW    : return $sformatf("SW    %s %s(%s)", frc(instr.s.rs2), fi({instr.s.imm1, instr.s.imm0}), fri(instr.s.rs1));
     M_SH    : return $sformatf("SH    %s %s(%s)", frc(instr.s.rs2), fi({instr.s.imm1, instr.s.imm0}), fri(instr.s.rs1));
     M_SB    : return $sformatf("SB    %s %s(%s)", frc(instr.s.rs2), fi({instr.s.imm1, instr.s.imm0}), fri(instr.s.rs1));

     // B-Type Instructions
     M_BEQ   : return $sformatf("BEQ   %s %s %s", frc(instr.b.rs1), frc(instr.b.rs2), fi({instr.b.imm3, instr.b.imm2, instr.b.imm1, instr.b.imm0}));
     M_BNE   : return $sformatf("BNE   %s %s %s", frc(instr.b.rs1), frc(instr.b.rs2), fi({instr.b.imm3, instr.b.imm2, instr.b.imm1, instr.b.imm0}));
     M_BLT   : return $sformatf("BLT   %s %s %s", frc(instr.b.rs1), frc(instr.b.rs2), fi({instr.b.imm3, instr.b.imm2, instr.b.imm1, instr.b.imm0}));
     M_BGE   : return $sformatf("BGE   %s %s %s", frc(instr.b.rs1), frc(instr.b.rs2), fi({instr.b.imm3, instr.b.imm2, instr.b.imm1, instr.b.imm0}));
     M_BLTU  : return $sformatf("BLTU  %s %s %s", frc(instr.b.rs1), frc(instr.b.rs2), fi({instr.b.imm3, instr.b.imm2, instr.b.imm1, instr.b.imm0}));
     M_BGEU  : return $sformatf("BGEU  %s %s %s", frc(instr.b.rs1), frc(instr.b.rs2), fi({instr.b.imm3, instr.b.imm2, instr.b.imm1, instr.b.imm0}));

     // J-Type Instructions
     M_JAL   : return $sformatf("JAL   %s %s",     frc(instr.j.rd), fi({instr.j.imm3, instr.j.imm2, instr.j.imm1, instr.j.imm0}));
     M_JALR  : return $sformatf("JALR  %s %s(%s)", frc(instr.i.rd), fi(instr.i.imm), fri(instr.i.rs1));

     // Load Instructions
     M_LW    : return $sformatf("LW    %s %s(%s)", frc(instr.i.rd), fi(instr.i.imm), fri(instr.i.rs1));
     M_LH    : return $sformatf("LH    %s %s(%s)", frc(instr.i.rd), fi(instr.i.imm), fri(instr.i.rs1));
     M_LHU   : return $sformatf("LHU   %s %s(%s)", frc(instr.i.rd), fi(instr.i.imm), fri(instr.i.rs1));
     M_LB    : return $sformatf("LB    %s %s(%s)", frc(instr.i.rd), fi(instr.i.imm), fri(instr.i.rs1));
     M_LBU   : return $sformatf("LBU   %s %s(%s)", frc(instr.i.rd), fi(instr.i.imm), fri(instr.i.rs1));

     // Default Case
     EBREAK  : return "EBREAK";
     default : begin 
                return $sformatf("unable to decode: 0x%x (%b) ", instr, instr);
               end
               
   endcase 
endfunction


function automatic op_type_t opc_type(instruction_t instr);
  case(1)
   is_r_type(instr) : return R_TYPE;
   is_i_type(instr) : return I_TYPE;
   is_si_type(instr) : return SI_TYPE;
   is_s_type(instr) : return S_TYPE;
   is_b_type(instr) : return B_TYPE;
   is_u_type(instr) : return U_TYPE;
   is_j_type(instr) : return J_TYPE;
   default : return op_type_t'(0);
  endcase
endfunction


function mnemonic_t opc_base(instruction_t instr);

   casez (instr) 
     // R-Type Instructions
     M_ADD   : return ADD;
     M_SUB   : return SUB;
     M_AND   : return AND;
     M_OR    : return OR;
     M_XOR   : return XOR;
     M_SLL   : return SLL;
     M_SRL   : return SRL;
     M_SRA   : return SRA;
     M_STL   : return STL;
     M_STLU  : return STLU;

     // I-Type Instructions
     M_ADDI  : return ADDI;
     M_ANDI  : return ANDI;
     M_ORI   : return ORI;
     M_XORI  : return XORI;
     M_SLLI  : return SLLI;
     M_SRLI  : return SRLI;
     M_SRAI  : return SRAI;

     // SI-Type Instructions
     M_STLI  : return STLI;
     M_STLUI : return STLUI;

     // U-Type Instructions
     M_LUI   : return LUI;
     M_AUIPC : return AUIPC;

     // S-Type Instructions
     M_SW    : return SW;
     M_SH    : return SH;
     M_SB    : return SB;

     // B-Type Instructions
     M_BEQ   : return BEQ;
     M_BNE   : return BNE;
     M_BLT   : return BLT;
     M_BGE   : return BGE;
     M_BLTU  : return BLTU;
     M_BGEU  : return BGEU;

     // J-Type Instructions
     M_JAL   : return JAL;
     M_JALR  : return JALR;

     // Load Instructions
     M_LW    : return LW;
     M_LH    : return LH;
     M_LHU   : return LHU;
     M_LB    : return LB;
     M_LBU   : return LBU;

     // Default Case
     // default : $error("Unknown instruction ");
   endcase 

endfunction

// functions to assemble opcodes

function instruction_t encode_rtype(opcode_mask_t base_opcode, int dest, int rs1, int rs2);
   instruction_t instr;

   instr = base_opcode;

   instr.r.rd  = register_num_t'(dest);
   instr.r.rs1 = register_num_t'(rs1);
   instr.r.rs2 = register_num_t'(rs2);
 
   return instr;
endfunction

function instruction_t encode_itype(opcode_mask_t base_opcode, int dest, int rs1, int imm);
   instruction_t instr;
   
   instr = base_opcode;
   instr.i.rd  = register_num_t'(dest);
   instr.i.rs1 = register_num_t'(rs1);
   set_i_imm(instr, short_imm_t'(imm));

   return instr;
endfunction

function instruction_t encode_sitype(opcode_mask_t base_opcode, int dest, int rs1, int imm);
   instruction_t instr;
   
   instr = base_opcode;
   instr.i.rd  = register_num_t'(dest);
   instr.i.rs1 = register_num_t'(rs1);
   set_si_imm(instr, short_imm_t'(imm));

   return instr;
endfunction

function instruction_t encode_stype(opcode_mask_t base_opcode, int rs1, int rs2, int imm);
   instruction_t instr;
   
   instr = base_opcode;

   instr.s.rs1 = register_num_t'(rs1);
   instr.s.rs2 = register_num_t'(rs2);
   set_s_imm(instr, short_imm_t'(imm));

   return instr;
endfunction

function instruction_t encode_btype(opcode_mask_t base_opcode, int rs1, int rs2, int imm);
   instruction_t instr;
   
   instr = base_opcode;

   instr.b.rs1 = register_num_t'(rs1);
   instr.b.rs2 = register_num_t'(rs2);
   set_b_imm(instr, b_imm_t'(imm));
   return instr;
endfunction

function instruction_t encode_utype(opcode_mask_t base_opcode, int dest, int imm);
   instruction_t instr;
   
   instr = base_opcode;

   instr.u.rd = register_num_t'(dest);
   set_u_imm(instr, long_imm_t'(imm));

   return instr;
endfunction

function instruction_t encode_jtype(opcode_mask_t base_opcode, int dest, int imm);
   instruction_t instr;
   
   instr = base_opcode;

   instr.j.rd = register_num_t'(dest);
   set_j_imm(instr, j_imm_t'(imm));

   return instr;
endfunction

function automatic instruction_t encode_instr(opcode_mask_t opcode, int rd=0, int rs1=0, int rs2=0, int imm=0);
   
   instruction_t instr = opcode;

   if (is_r_type(instr)) return encode_rtype(opcode, rd,  rs1, rs2);
   if (is_i_type(instr)) return encode_itype(opcode, rd,  rs1, imm);
   if (is_si_type(instr)) return encode_sitype(opcode, rd,  rs1, imm);
   if (is_s_type(instr)) return encode_stype(opcode, rs1, rs2, imm);
   if (is_b_type(instr)) return encode_btype(opcode, rs1, rs2, imm);
   if (is_u_type(instr)) return encode_utype(opcode, rd,  imm);
   if (is_j_type(instr)) return encode_jtype(opcode, rd,  imm);
   assert(0) $error("Unknown opcode: %x ", opcode);

endfunction

const instruction_t NO_OP = encode_instr(M_ADDI, .rd(0), .rs1(0), .imm(0));

// retrieve immediate values from opcodes 

function tiny_imm_t get_si_imm(input instruction_t instr);
   return (instr.i.imm);
endfunction

function short_imm_t get_i_imm(input instruction_t instr);
   return (instr.i.imm);
endfunction

function short_imm_t get_s_imm(input instruction_t instr);
   return ({instr.s.imm1, instr.s.imm0});
endfunction

function short_imm_t get_b_imm(input instruction_t instr);
   return({instr.b.imm3, instr.b.imm2, instr.b.imm1, instr.b.imm0, 1'b0});
endfunction

function register_t get_u_imm(input instruction_t instr);
   return(register_t'(instr.u.imm) << 12);
endfunction

function long_imm_t get_j_imm(input instruction_t instr);
   return({instr.j.imm3, instr.j.imm2, instr.j.imm1, instr.j.imm0, 1'b0});
endfunction

// set immediate values in opcodes

function automatic void set_i_imm(ref instruction_t instr, input short_imm_t imm);
   instr.i.imm = imm & 32'h00000FFF;
endfunction

function automatic void set_si_imm(ref instruction_t instr, input short_imm_t imm);
   instr.si.imm = imm & 32'h0000001F;
endfunction

function automatic void set_s_imm(ref instruction_t instr, input short_imm_t imm);
   {instr.s.imm1, instr.s.imm0} = imm & 32'h00000FFF;
endfunction

function automatic void set_b_imm(ref instruction_t instr, input b_imm_t imm);
   {instr.b.imm3, instr.b.imm2, instr.b.imm1, instr.b.imm0} = (imm >> 1) & 32'h00001FFE;   
endfunction

function automatic void set_u_imm(ref instruction_t instr, input long_imm_t imm);
   instr.u.imm = imm; // & 32'h000FFFFF;
endfunction

function automatic void set_j_imm(ref instruction_t instr, input j_imm_t imm);
   {instr.j.imm3, instr.j.imm2, instr.j.imm1, instr.j.imm0} = (imm>>1) &32'h000FFFFF;
endfunction

function automatic void check_encode_decode();
   opcode_mask_t opcode;
   instruction_t instr;
   int i;

   opcode = opcode.first;

   $display("\n\nTest opcode encoding and decoding\n");

   for (i=0; i<opcode.num-1; i++) begin
     $write("opcode_index: %2d opcode_name: %6s === ", i, opcode.name);
     print_opcode(opcode);
     instr = encode_instr(opcode);
     $write("encoding: ");
     print_opcode(instr);
     $display("");
     opcode = opcode.next;
   end
endfunction

endpackage
