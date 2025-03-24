
//------------------------------------------------------
//
// Reference ISS for verification of RISC-V RV32I core
//
//   Has DPI callable interface for reset, step and run
//   Has built in trace the stdout if enabled
//   Processor state accessable through DPI calls
//
//------------------------------------------------------

#include <stdio.h>

static const int i_type = 0;
static const int r_type = 1;
static const int s_type = 2;
static const int b_type = 3;
static const int si_type = 4;
static const int j_type = 5;
static const int u_type = 6;

static unsigned long code_memory[0x4000];
static unsigned long data_memory[0x4000];

static   signed long register_bank[32];
static unsigned long pc;

static unsigned long tr_rd;
static unsigned long wdata;
static unsigned long waddr;
static unsigned long write_op;

static int bypass_mode = 0;
static unsigned long read_value;
static int chatty;
static int run_complete;

// routines to extract parameters from instructions
//   broken down by RISC-V instruciton type formats

static void get_r_type_ops(
    unsigned long instr,
    int *rd,
    int *rs1,
    int *rs2)
{
    struct bit_fields {
      union {
        struct {
          unsigned int opc1 : 7;
          unsigned int rd   : 5;
          unsigned int opc2 : 3;
          unsigned int rs1  : 5;
          unsigned int rs2  : 5;
          unsigned int opc3 : 7;
        };
        unsigned long w;
      };
    };
    struct bit_fields bf;
    bf.w = instr;

    *rd = bf.rd;
    *rs1 = bf.rs1;
    *rs2 = bf.rs2;

    // tracking info
    tr_rd = *rd;
    write_op = 0;
    waddr = 0;
    wdata = 0;
}
    
static void get_i_type_ops(
    unsigned long instr,
    int *rd,
    int *rs1,
    int *imm)
{ 
    struct bit_fields {
      union {
        struct {
          unsigned int opc1 : 7;
          unsigned int rd   : 5;
          unsigned int opc2 : 3;
          unsigned int rs1  : 5;
                   int imm  : 12;
        };
        unsigned long w;
      };
    };
    struct bit_fields bf;
    bf.w = instr;

    *rd = bf.rd;
    *rs1 = bf.rs1;
    *imm = bf.imm;
    if (*imm & 0x800) *imm |= 0xFFFFF000;  // sign extend

    // tracking info
    tr_rd = *rd;
    write_op = 0;
    waddr = 0;
    wdata = 0;
}


static void get_si_type_ops( 
    unsigned long instr,
    int *rd,
    int *rs1,
    int *imm)
{ 
    struct bit_fields {
      union {
        struct {
          unsigned int opc1 : 7;
          unsigned int rd   : 5;
          unsigned int opc2 : 3;
          unsigned int rs1  : 5;
          unsigned int imm  : 5;
          unsigned int opc3 : 7;
        };
        unsigned long w;
      };
    };
    struct bit_fields bf;
    bf.w = instr;

    *rd = bf.rd;
    *rs1 = bf.rs1;
    *imm = bf.imm;  // do not sign extend

    // tracking info
    tr_rd = *rd;
    write_op = 0;
    waddr = 0;
    wdata = 0;
}
       

static void get_s_type_ops(
    unsigned long instr,
    int *rs1,
    int *rs2,
    int *imm)
{
    struct bit_fields {
      union {
        struct {
          unsigned int opc1 : 7;
          unsigned int imm0 : 5;
          unsigned int opc2 : 3;
          unsigned int rs1  : 5;
          unsigned int rs2  : 5;
          unsigned int imm1 : 7;
        };
        unsigned long w;
      };
    };
    struct bit_fields bf;
    bf.w = instr;

    *rs1 = bf.rs1;
    *rs2 = bf.rs2;
    *imm = (bf.imm1 << 5) | bf.imm0;
    if (*imm & 0x800) *imm |= 0xFFFFF000;

    // tracking info
    tr_rd = 0;
    write_op = 1;
}

static void get_b_type_ops(
    unsigned long instr,
    int *rs1,
    int *rs2,
    int *imm)
{
    struct bit_fields {
      union {
        struct {
          unsigned int opc1 : 7;
          unsigned int imm2 : 1;
          unsigned int imm0 : 4;
          unsigned int opc2 : 3;
          unsigned int rs1  : 5;
          unsigned int rs2  : 5;
          unsigned int imm1 : 6;
          unsigned int imm3 : 1;
        };
        unsigned long w;
      };
    };
    struct bit_fields bf;
    bf.w = instr;

    *rs1 = bf.rs1;
    *rs2 = bf.rs2;
    *imm = (bf.imm3 << 12) | (bf.imm2 << 11) | (bf.imm1 << 5) | (bf.imm0 << 1);
    if (*imm & 0x1000) *imm |= 0xFFFFE000;

    // tracking info
    tr_rd = 0;
    write_op = 0;
    waddr = 0;
    wdata = 0;
}


static void get_j_type_ops(
    unsigned long instr,
    int *rd,
    int *imm)
{
    struct bit_fields {
      union {
        struct {
          unsigned int opc1 : 7;
          unsigned int rd   : 5;
          unsigned int imm2 : 8;
          unsigned int imm1 : 1;
          unsigned int imm0 : 10;
          unsigned int imm3 : 1;
        };
        unsigned long w;
      };
    };
    struct bit_fields bf;
    bf.w = instr;
    
    *rd = bf.rd;
    *imm = (bf.imm3 << 20 ) | (bf.imm3 << 12) | (bf.imm1 << 11) | (bf.imm0 << 1);

    // tracking info
    tr_rd = *rd;
    write_op = 0;
    waddr = 0;
    wdata = 0;

}


static void get_u_type_ops(
    unsigned long instr,
    int *rd,
    int *imm)
{
    struct bit_fields {
      union {
        struct {
          unsigned int opc1 : 7;
          unsigned int rd   : 5;
          unsigned int imm  : 20;
        };
        unsigned long w;
      };
    };
    struct bit_fields bf;
    bf.w = instr;

    *rd = bf.rd;
    *imm = bf.imm << 12;

    // tracking info
    tr_rd = *rd;
    write_op = 0;
    waddr = 0;
    wdata = 0;
}

unsigned long get_read_value(unsigned long address)
{
   if (bypass_mode) return read_value;
   else return data_memory[address];
}

//
// Functional routines for executing instructions with tracing 
//
// I-Type instrucitons - immediate operands
//

static int addi(unsigned long instr, char *mnemonic, char *trace)
{
   int rd, rs1, imm;
   
   get_i_type_ops(instr, &rd, &rs1, &imm);
   
   register_bank[rd] = register_bank[rs1] + imm;
  
   sprintf(trace, "%-6s  x%d, x%d, %d            ", mnemonic, rd, rs1, imm);
   sprintf(trace+27, "x%d = %08x ", rd, register_bank[rd]);
   return 0;
}

static int andi(unsigned long instr, char *mnemonic, char *trace)
{
   int rd, rs1, imm;
   
   get_i_type_ops(instr, &rd, &rs1, &imm);
   
   register_bank[rd] = register_bank[rs1] & imm;
  
   sprintf(trace, "%-6s  x%d, x%d, %d            ", mnemonic, rd, rs1, imm);
   sprintf(trace+27, "x%d = %08x ", rd, register_bank[rd]);
   return 0;
}


static int ori(unsigned long instr, char *mnemonic, char *trace)
{
   int rd, rs1, imm;
   
   get_i_type_ops(instr, &rd, &rs1, &imm);
   
   register_bank[rd] = register_bank[rs1] | imm;
  
   sprintf(trace, "%-6s  x%d, x%d, %d            ", mnemonic, rd, rs1, imm);
   sprintf(trace+27, "x%d = %08x ", rd, register_bank[rd]);
   return 0;
}


static int xori(unsigned long instr, char *mnemonic, char *trace)
{
   int rd, rs1, imm;
   
   get_i_type_ops(instr, &rd, &rs1, &imm);
   
   register_bank[rd] = register_bank[rs1] ^ imm;
  
   sprintf(trace, "%-6s  x%d, x%d, %d            ", mnemonic, rd, rs1, imm);
   sprintf(trace+27, "x%d = %08x ", rd, register_bank[rd]);
   return 0;
}


static int stli(unsigned long instr, char *mnemonic, char *trace)
{
   int rd, rs1, imm;
   
   get_i_type_ops(instr, &rd, &rs1, &imm);
   
   register_bank[rd] = (register_bank[rs1] < imm) ? 1 : 0;
  
   sprintf(trace, "%-6s  x%d, x%d, %d            ", mnemonic, rd, rs1, imm);
   sprintf(trace+27, "x%d = %08x ", rd, register_bank[rd]);
   return 0;
}

static int stlui(unsigned long instr, char *mnemonic, char *trace)
{
   int rd, rs1, imm;
   
   get_i_type_ops(instr, &rd, &rs1, &imm);
   
   register_bank[rd] = (((signed) register_bank[rs1]) < ((unsigned) imm)) ? 1 : 0;
  
   sprintf(trace, "%-6s  x%d, x%d, %d            ", mnemonic, rd, rs1, imm);
   sprintf(trace+27, "x%d = %08x ", rd, register_bank[rd]);
   return 0;
}


// Load instructions (I-Type)

static int lw(unsigned long instr, char *mnemonic, char *trace)
{
   int rd, rs1, imm;
   unsigned long address;
   
   get_i_type_ops(instr, &rd, &rs1, &imm);
   
   address = (register_bank[rs1] + imm) >> 2;
   register_bank[rd] = get_read_value(address); // data_memory[address];
  
   sprintf(trace, "%-6s  x%d, x%d, %d            ", mnemonic, rd, rs1, imm);
   sprintf(trace+27, "x%d = %08x ", rd, register_bank[rd]);
   return 0;
}


static int lh(unsigned long instr, char *mnemonic, char *trace)
{
   int rd, rs1, imm;
   unsigned long address;
   int offset;
   
   get_i_type_ops(instr, &rd, &rs1, &imm);
   
   address = (register_bank[rs1] + imm) >> 2;
   offset = (register_bank[rs1] + imm) & 2;
   // register_bank[rd] = ((data_memory[address]) >> (offset * 8)) & 0xFFFF;
   register_bank[rd] = ((get_read_value(address)) >> (offset * 8)) & 0xFFFF;
   if (register_bank[rd] & 0x00008000) register_bank[rd] |= 0xFFFF0000;
  
   sprintf(trace, "%-6s  x%d, x%d, %d            ", mnemonic, rd, rs1, imm);
   sprintf(trace+27, "x%d = %08x ", rd, register_bank[rd]);
   return 0;
}


static int lhu(unsigned long instr, char *mnemonic, char *trace)
{
   int rd, rs1, imm;
   unsigned long address;
   int offset;
   
   get_i_type_ops(instr, &rd, &rs1, &imm);
   
   address = (register_bank[rs1] + imm) >> 2;
   offset = (register_bank[rs1] + imm) & 2;
   // register_bank[rd] = ((data_memory[address]) >> (offset * 8)) & 0xFFFF;
   register_bank[rd] = ((get_read_value(address)) >> (offset * 8)) & 0xFFFF;
  
   sprintf(trace, "%-6s  x%d, x%d, %d            ", mnemonic, rd, rs1, imm);
   sprintf(trace+27, "x%d = %08x ", rd, register_bank[rd]);
   return 0;
}


static int lb(unsigned long instr, char *mnemonic, char *trace)
{
   int rd, rs1, imm;
   unsigned long address;
   int offset;
   
   get_i_type_ops(instr, &rd, &rs1, &imm);
   
   address = (register_bank[rs1] + imm) >> 2;
   offset = (register_bank[rs1] + imm) & 3;
   // register_bank[rd] = ((data_memory[address]) >> (offset * 8)) & 0xFF;
   register_bank[rd] = ((get_read_value(address)) >> (offset * 8)) & 0xFF;
   if (register_bank[rd] & 0x00000080) register_bank[rd] |= 0xFFFFFF00;
  
   sprintf(trace, "%-6s  x%d, x%d, %d            ", mnemonic, rd, rs1, imm);
   sprintf(trace+27, "x%d = %08x ", rd, register_bank[rd]);
   return 0;
}


static int lbu(unsigned long instr, char *mnemonic, char *trace)
{
   int rd, rs1, imm;
   unsigned long address;
   int offset;
   
   get_i_type_ops(instr, &rd, &rs1, &imm);
   
   address = (register_bank[rs1] + imm) >> 2;
   offset = (register_bank[rs1] + imm) & 3;
   // register_bank[rd] = ((data_memory[address]) >> (offset * 8)) & 0xFF;
   register_bank[rd] = ((get_read_value(address)) >> (offset * 8)) & 0xFF;
  
   sprintf(trace, "%-6s  x%d, x%d, %d            ", mnemonic, rd, rs1, imm);
   sprintf(trace+27, "x%d = %08x ", rd, register_bank[rd]);
   return 0;
}

static int jalr(unsigned long instr, char *mnemonic, char *trace)
{
   int rd, rs1, imm;
   
   get_i_type_ops(instr, &rd, &rs1, &imm);
   
   register_bank[rd] = pc + 4;
   pc = (data_memory[rs1] + imm) & 0xFFFFFFFC;
  
   sprintf(trace, "%-6s  x%d, %d(x%d) ", mnemonic, rd, imm, rs1);
   return 1;
}

// 
// R-Type instructions - register/register instructions
//

static int add(unsigned long instr, char *mnemonic, char *trace)
{
   int rd, rs1, rs2;
   
   get_r_type_ops(instr, &rd, &rs1, &rs2);
   
   register_bank[rd] = register_bank[rs1] + register_bank[rs2];
  
   sprintf(trace, "%-6s  x%d, x%d, x%d           ", mnemonic, rd, rs1, rs2);
   sprintf(trace+27, "x%d = %08x ", rd, register_bank[rd]);
   return 0;
}

static int sub(unsigned long instr, char *mnemonic, char *trace)
{
   int rd, rs1, rs2;
   
   get_r_type_ops(instr, &rd, &rs1, &rs2);
   
   register_bank[rd] = register_bank[rs1] - register_bank[rs2];
  
   sprintf(trace, "%-6s  x%d, x%d, x%d           ", mnemonic, rd, rs1, rs2);
   sprintf(trace+27, "x%d = %08x ", rd, register_bank[rd]);
   return 0;
}

static int stl(unsigned long instr, char *mnemonic, char *trace)
{
   int rd, rs1, rs2;
   
   get_r_type_ops(instr, &rd, &rs1, &rs2);
   
   register_bank[rd] = (register_bank[rs1] < register_bank[rs2]) ? 1 : 0;
  
   sprintf(trace, "%-6s  x%d, x%d, x%d           ", mnemonic, rd, rs1, rs2);
   sprintf(trace+27, "x%d = %08x ", rd, register_bank[rd]);
   return 0;
}

static int stlu(unsigned long instr, char *mnemonic, char *trace)
{
   int rd, rs1, rs2;
   
   get_r_type_ops(instr, &rd, &rs1, &rs2);
   
   register_bank[rd] = ((unsigned long) register_bank[rs1] < (unsigned long) register_bank[rs2]) ? 1 : 0;
  
   sprintf(trace, "%-6s  x%d, x%d, x%d           ", mnemonic, rd, rs1, rs2);
   sprintf(trace+27, "x%d = %08x ", rd, register_bank[rd]);
   return 0;
}

static int and_(unsigned long instr, char *mnemonic, char *trace)
{
   int rd, rs1, rs2;
   
   get_r_type_ops(instr, &rd, &rs1, &rs2);
   
   register_bank[rd] = register_bank[rs1] & register_bank[rs2];
  
   sprintf(trace, "%-6s  x%d, x%d, x%d           ", mnemonic, rd, rs1, rs2);
   sprintf(trace+27, "x%d = %08x ", rd, register_bank[rd]);
   return 0;
}

static int or_(unsigned long instr, char *mnemonic, char *trace)
{
   int rd, rs1, rs2;
   
   get_r_type_ops(instr, &rd, &rs1, &rs2);
   
   register_bank[rd] = register_bank[rs1] | register_bank[rs2];
  
   sprintf(trace, "%-6s  x%d, x%d, x%d           ", mnemonic, rd, rs1, rs2);
   sprintf(trace+27, "x%d = %08x ", rd, register_bank[rd]);
   return 0;
}

static int xor_(unsigned long instr, char *mnemonic, char *trace)
{
   int rd, rs1, rs2;
   
   get_r_type_ops(instr, &rd, &rs1, &rs2);
   
   register_bank[rd] = register_bank[rs1] ^ register_bank[rs2];
  
   sprintf(trace, "%-6s  x%d, x%d, x%d           ", mnemonic, rd, rs1, rs2);
   sprintf(trace+27, "x%d = %08x ", rd, register_bank[rd]);
   return 0;
}

static int sll(unsigned long instr, char *mnemonic, char *trace)
{
   int rd, rs1, rs2;
   
   get_r_type_ops(instr, &rd, &rs1, &rs2);
   
   register_bank[rd] = register_bank[rs1] << (register_bank[rs2] & 0x1F);
  
   sprintf(trace, "%-6s  x%d, x%d, x%d           ", mnemonic, rd, rs1, rs2);
   sprintf(trace+27, "x%d = %08x ", rd, register_bank[rd]);
   return 0;
}

static int srl(unsigned long instr, char *mnemonic, char *trace)
{
   int rd, rs1, rs2;
   
   get_r_type_ops(instr, &rd, &rs1, &rs2);
   
   register_bank[rd] = ((unsigned int) (register_bank[rs1] & 0xFFFFFFFF))  >> (register_bank[rs2] & 0x1F);
  
   sprintf(trace, "%-6s  x%d, x%d, x%d           ", mnemonic, rd, rs1, rs2);
   sprintf(trace+27, "x%d = %08x ", rd, register_bank[rd]);
   return 0;
}

static int sra(unsigned long instr, char *mnemonic, char *trace)
{
   int rd, rs1, rs2;
   
   get_r_type_ops(instr, &rd, &rs1, &rs2);
   
   register_bank[rd] = register_bank[rs1] >> (register_bank[rs2] & 0x1F);
  
   sprintf(trace, "%-6s  x%d, x%d, x%d           ", mnemonic, rd, rs1, rs2);
   sprintf(trace+27, "x%d = %08x ", rd, register_bank[rd]);
   return 0;
}


// 
// J-Type instrucitons - Jump instructions
//

static int jal(unsigned long instr, char *mnemonic, char *trace)
{
   int rd, imm;
   
   get_j_type_ops(instr, &rd, &imm);
   
   if (rd) register_bank[rd] = pc + 4;
   pc = imm >> 2;
  
   sprintf(trace, "%-6s  x%d, %d ", mnemonic, rd, imm);
   return 1;
}

// 
// B-Type instrucitons - COnditional branch instructions
//

static int beq(unsigned long instr, char *mnemonic, char *trace)
{
   int rs1, rs2, imm;
   
   get_b_type_ops(instr, &rs1, &rs2, &imm);
   
   sprintf(trace, "%-6s  x%d, x%d, %d ", mnemonic, rs1, rs2, imm);

   if (register_bank[rs1] == register_bank[rs2]) {
     pc += (imm >> 2);  
     return 1;
   } else {
     return 0;
   }
}


static int bne(unsigned long instr, char *mnemonic, char *trace)
{
   int rs1, rs2, imm;
   
   get_b_type_ops(instr, &rs1, &rs2, &imm);
   
   sprintf(trace, "%-6s  x%d, x%d, %d ", mnemonic, rs1, rs2, imm);

   if (register_bank[rs1] != register_bank[rs2]) {
     pc += (imm >> 2);
     return 1;
   } else {
     return 0;
   }
}


static int blt(unsigned long instr, char *mnemonic, char *trace)
{
   int rs1, rs2, imm;
   
   get_b_type_ops(instr, &rs1, &rs2, &imm);
   
   sprintf(trace, "%-6s  x%d, x%d, %d ", mnemonic, rs1, rs2, imm);

   if (register_bank[rs1] < register_bank[rs2]) {
     pc += (imm>>2);
     return 1;
   } else {
     return 0;
   }
}


static int bltu(unsigned long instr, char *mnemonic, char *trace)
{
   int rs1, rs2, imm;
   
   get_b_type_ops(instr, &rs1, &rs2, &imm);
   
   sprintf(trace, "%-6s  x%d, x%d, %x ", mnemonic, rs1, rs2, imm);

   if ((unsigned long) register_bank[rs1] < (unsigned long) register_bank[rs2]) {
     pc += (imm>>2);
     return 1;
   } else {
     return 0;
   }
}


static int bge(unsigned long instr, char *mnemonic, char *trace)
{
   int rs1, rs2, imm;
   
   get_b_type_ops(instr, &rs1, &rs2, &imm);
   
   sprintf(trace, "%-6s  x%d, x%d, %d ", mnemonic, rs1, rs2, imm);

   if (register_bank[rs1] >= register_bank[rs2]) {
     pc += (imm>>2);
     return 1;
   } else {
     return 0;
   }
}


static int bgeu(unsigned long instr, char *mnemonic, char *trace)
{
   int rs1, rs2, imm;
   
   get_b_type_ops(instr, &rs1, &rs2, &imm);
   
   sprintf(trace, "%-6s  x%d, x%d, %d ", mnemonic, rs1, rs2, imm);

   if ((unsigned long) register_bank[rs1] >= (unsigned long) register_bank[rs2]) {
     pc += (imm>>2);
     return 1;
   } else {
     return 0;
   }
}

// 
// S-Type instructions - Store instructions
//

static int sw(unsigned long instr, char *mnemonic, char *trace)
{
   int rs1, rs2, imm;
   unsigned long address;

   get_s_type_ops(instr, &rs1, &rs2, &imm);

   address = (register_bank[rs1] + imm) >> 2;   
   data_memory[address] = register_bank[rs2]; 
  
   sprintf(trace, "%-6s  x%d, %d(x%d)           ", mnemonic, rs2, imm, rs1);
   sprintf(trace+27, "write @%08x = %08x ", address*4, register_bank[rs2]);

   // tracking info
   wdata = register_bank[rs2];
   waddr = (register_bank[rs1] + imm) & 0xFFFFFFFC;
 
   return 0;
}


static int sh(unsigned long instr, char *mnemonic, char *trace)
{
   int rs1, rs2, imm;
   unsigned long address;
   int offset;

   get_s_type_ops(instr, &rs1, &rs2, &imm);

   address = (register_bank[rs1] + imm) >> 2;  
   offset = (register_bank[rs1] + imm) & 2; 
   if (offset == 0) data_memory[address] = (data_memory[address] & 0xFFFF0000) | ((register_bank[rs2] & 0xFFFF) <<  0);
   if (offset == 2) data_memory[address] = (data_memory[address] & 0x0000FFFF) | ((register_bank[rs2] & 0xFFFF) << 16);
  
   sprintf(trace, "%-6s  x%d, %d(x%d)           ", mnemonic, rs2, imm, rs1);
   sprintf(trace+27, "write @%08x = %04x ", address*4+offset, register_bank[rs2] & 0xFFFF);

   // tracking info
   wdata = register_bank[rs2] & 0x0000FFFF;
   waddr = (register_bank[rs1] + imm) & 0xFFFFFFFE;
 
   return 0;
}


static int sb(unsigned long instr, char *mnemonic, char *trace)
{
   int rs1, rs2, imm;
   unsigned long address;
   int offset;

   get_s_type_ops(instr, &rs1, &rs2, &imm);

   address = (register_bank[rs1] + imm) >> 2;  
   offset = (register_bank[rs1] + imm) & 3; 
   if (offset == 3) data_memory[address] = (data_memory[address] & 0x00FFFFFF) | ((register_bank[rs2] & 0xFF) << 24);
   if (offset == 2) data_memory[address] = (data_memory[address] & 0xFF00FFFF) | ((register_bank[rs2] & 0xFF) << 16);
   if (offset == 1) data_memory[address] = (data_memory[address] & 0xFFFF00FF) | ((register_bank[rs2] & 0xFF) <<  8);
   if (offset == 0) data_memory[address] = (data_memory[address] & 0xFFFFFF00) | ((register_bank[rs2] & 0xFF) <<  0);
  
   sprintf(trace, "%-6s  x%d, %d(x%d)           ", mnemonic, rs2, imm, rs1);
   sprintf(trace+27, "write @%08x = %02x ", address*4+offset, register_bank[rs2] & 0xFF);

   // tracking info
   wdata = register_bank[rs2] & 0x000000FF;
   waddr = (register_bank[rs1] + imm) & 0xFFFFFFFF;
 
   return 0;
}

// 
// U-Type instructions - Upper word operations
//

static int auipc(unsigned long instr, char *mnemonic, char *trace)
{
   int rd;
   int imm;

   get_u_type_ops(instr, &rd, &imm);
 
   register_bank[rd] = pc + imm;

   sprintf(trace, "%-6s  x%d, %d                ", mnemonic, rd, imm);
   sprintf(trace+27, "x%d = %08x ", rd, register_bank[rd]);
   return 0;
}

static int lui(unsigned long instr, char *mnemonic, char *trace)
{
   int rd;
   int imm;

   get_u_type_ops(instr, &rd, &imm);
 
   register_bank[rd] = imm;

   sprintf(trace, "%-6s  x%d, %d                ", mnemonic, rd, imm);
   sprintf(trace+27, "x%d = %08x ", rd, register_bank[rd]);
   return 0;
}

// 
// SI-Type instrucitons (not a real category, but needed for short immediate operands
// 

static int slli(unsigned long instr, char *mnemonic, char *trace)
{
   int rd;
   int rs1;
   int imm;

   get_si_type_ops(instr, &rd, &rs1, &imm);
 
   register_bank[rd] = register_bank[rs1] << imm;

   sprintf(trace, "%-6s  x%d, x%d, %d            ", mnemonic, rd, rs1, imm);
   sprintf(trace+27, "x%d = %08x ", rd, register_bank[rd]);
   return 0;
}

static int srli(unsigned long instr, char *mnemonic, char *trace)
{
   int rd;
   int rs1;
   int imm;

   get_si_type_ops(instr, &rd, &rs1, &imm);
 
   register_bank[rd] = ((unsigned int) (register_bank[rs1] & 0xFFFFFFFF))  >> imm;

   sprintf(trace, "%-6s  x%d, x%d, %d            ", mnemonic, rd, rs1, imm);
   sprintf(trace+27, "x%d = %08x ", rd, register_bank[rd]);
   return 0;
}
   
static int srai(unsigned long instr, char *mnemonic, char *trace)
{
   int rd;
   int rs1;
   int imm;

   get_si_type_ops(instr, &rd, &rs1, &imm);
 
   register_bank[rd] = ((signed) register_bank[rs1]) >> imm;

   sprintf(trace, "%-6s  x%d, x%d, %d            ", mnemonic, rd, rs1, imm);
   sprintf(trace+27, "x%d = %08x ", rd, register_bank[rd]);
   return 0;
}

// 
// Break instruction - used to halt test runs
//

static int halt(unsigned long instr, char *mnemonic, char *trace)
{
   run_complete = 1;
   sprintf(trace, "EBREAK - Machine Halted");
   return 0;
}

// Opcode jump table

static struct opcode_table_s {
   char mnemonic[16];
   unsigned long mask;
   unsigned long opcode;
   int (*op_fn)(unsigned long op, char* name, char* trace);
} opcode_table[] = {

   { "ADDI",   0x0000707F, 0x00000013, addi   },
   { "STLI",   0x0000707F, 0x00002013, stli   },
   { "STLUI",  0x0000707F, 0x00003013, stlui  },
   { "ANDI",   0x0000707F, 0x00007013, andi   },
   { "ORI",    0x0000707F, 0x00006013, ori    },
   { "XORI",   0x0000707F, 0x00004013, xori   },
   { "SLLI",   0xFE00707F, 0x00001013, slli   },
   { "SRLI",   0xFE00707F, 0x00005013, srli   },
   { "SRAI",   0xFE00707F, 0x40005013, srai   },
   { "LUI",    0x0000007F, 0x00000037, lui    },
   { "AUIPC",  0x0000007F, 0x00000017, auipc  },

   { "ADD",    0xFE00707F, 0x00000033, add    },
   { "SUB",    0xFE00707F, 0x40000033, sub    },
   { "STL",    0xFE00707F, 0x00002033, stl    },
   { "STLU",   0xFE00707F, 0x00003033, stlu   },
   { "AND",    0xFE00707F, 0x00007033, and_   },
   { "OR",     0xFE00707F, 0x00006033, or_    },
   { "XOR",    0xFE00707F, 0x00004033, xor_   },
   { "SLL",    0xFE00707F, 0x00001033, sll    },
   { "SRL",    0xFE00707F, 0x00005033, srl    },
   { "SRA",    0xFE00707F, 0x40005033, sra    },

   { "JAL",    0x0000007F, 0x0000006F, jal    },
   { "JALR",   0x0000707F, 0x00000067, jalr   },
   { "BEQ",    0x0000707F, 0x00000063, beq    },
   { "BNE",    0x0000707F, 0x00001063, bne    },
   { "BLT",    0x0000707F, 0x00004063, blt    },
   { "BLTU",   0x0000707F, 0x00006063, bltu   },
   { "BGE",    0x0000707F, 0x00005063, bge    },
   { "BGEU",   0x0000707F, 0x00007063, bgeu   },

   { "LW",     0x0000707F, 0x00002003, lw     },
   { "LH",     0x0000707F, 0x00001003, lh     },
   { "LHU",    0x0000707F, 0x00005003, lhu    },
   { "LB",     0x0000707F, 0x00000003, lb     },
   { "LBU",    0x0000707F, 0x00004003, lbu    },

   { "SW",     0x0000707F, 0x00002023, sw     },
   { "SH",     0x0000707F, 0x00001023, sh     },
   { "SB",     0x0000707F, 0x00000023, sb     },

   { "EBREAK", 0xFFFFFFFF, 0x00100073, halt }
  };

static const int num_ops = sizeof(opcode_table)/sizeof(opcode_table[0]);


//---------------------------------------------------------
//
// Functions below are exported to the DPI for use by  
// the SystemVerilog testbench as a reference ISS
//
// --------------------------------------------------------
 
void iss_reset()
{
   int i;

   pc = 0;
   for (i=0; i<32; i++) register_bank[i] = 0;
   bypass_mode = 0;
   read_value = 0;
}

void iss_step()
{
   int i;
   int branched;
   char decode[100];
   unsigned long instr = code_memory[pc];
   unsigned long old_pc = pc;

   branched = 0;

   for (i=0; i<num_ops; i++) { 
     if ((instr & opcode_table[i].mask) == opcode_table[i].opcode) {
       branched = opcode_table[i].op_fn(instr, opcode_table[i].mnemonic, decode);
       break;
     }
   }
   if (i>=num_ops) {
     run_complete = 1;
     printf("unknown opcode: %08x \n", instr);
   }

   if (chatty) printf("[ISS] trace: %08x: %08x : %s \n", old_pc * 4, instr, decode);
   if (!branched) pc ++;
}

void iss_run()
{
   run_complete = 0;
   while (!run_complete) iss_step();
}

void iss_set_instruction(unsigned long address, unsigned long instr)
{
   code_memory[address] = instr;
}

void iss_set_memory_word(unsigned long address, unsigned long data)
{ 
   data_memory[address>>2] = data;
}

void iss_set_memory_halfword(unsigned long address, unsigned long data)
{
   if (address & 2) data_memory[address>>2] = (data_memory[address>>2] & 0x0000FFFF) | data << 16;
   else data_memory[address>>2] = (data_memory[address>>2] & 0xFFFF0000) | (data  & 0x0000FFFF);
}

void iss_set_memory_byte(unsigned long address, unsigned long data)
{
   int offset = address & 3;
   address = address >> 2;

   if (offset == 3) data_memory[address] = (data_memory[address] & 0x00FFFFFF) | ((data << 24) & 0xFF000000);
   if (offset == 2) data_memory[address] = (data_memory[address] & 0xFF00FFFF) | ((data << 16) & 0x00FF0000);
   if (offset == 1) data_memory[address] = (data_memory[address] & 0xFFFF00FF) | ((data <<  8) & 0x0000FF00);
   if (offset == 0) data_memory[address] = (data_memory[address] & 0xFFFFFF00) | ((data <<  0) & 0x000000FF);
}

unsigned long iss_get_instruction(unsigned long address)
{
  return code_memory[address];
}

unsigned long iss_get_memory_word(unsigned long address)
{
  return data_memory[address>>2];
}

unsigned short iss_get_memory_halfword(unsigned long address)
{
  return (data_memory[address>>2] >> ((address & 2) * 8)) & 0xFFFF;
}

unsigned char iss_get_memory_byte(unsigned long address)
{
  return (data_memory[address>>2] >> ((address & 3) * 8)) & 0xFF;
}

void iss_set_pc(unsigned long new_pc)
{
   pc = new_pc;
}

unsigned long iss_get_pc()
{
   return pc;
}

unsigned long iss_set_register(unsigned long address, unsigned long new_value)
{
   register_bank[address & 0x1F] = new_value;
}

unsigned long iss_get_register(unsigned long address)
{
   return register_bank[address & 0x1F];
}

void iss_set_read_value(unsigned long value)
{
   bypass_mode = 1;
   read_value = value;
}

void iss_enable_data_bypass()
{
   bypass_mode = 1;
}

void iss_disable_data_bypass()
{
   bypass_mode = 0;
}

void iss_enable_trace()
{
   chatty = 1;
}

void iss_disable_trace()
{
   chatty = 0;
}

unsigned long iss_get_rd()
{
   return(tr_rd);
}

unsigned long iss_get_wdata()
{ 
   return(wdata);
}

unsigned long iss_get_waddr()
{
   return(waddr);
}

unsigned long iss_get_write_op()
{
   return(write_op);
}
