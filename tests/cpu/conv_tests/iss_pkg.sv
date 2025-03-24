package iss_pkg;

// memory access routines

import "DPI-C" function void iss_set_instruction(int address, int instr);
import "DPI-C" function void iss_set_memory_word(int address, int data);
import "DPI-C" function void iss_set_memory_halfword(int address, int data);
import "DPI-C" function void iss_set_memory_byte(int address, int data);
import "DPI-C" function int  iss_get_instruction(int address);
import "DPI-C" function int  iss_get_memory_word(int address);
import "DPI-C" function int  iss_get_memory_halfword(int address);
import "DPI-C" function int  iss_get_memory_byte(int address);

// processor state access routines

import "DPI-C" function void iss_reset();
import "DPI-C" function void iss_set_pc(int pc);
import "DPI-C" function int  iss_get_pc();
import "DPI-C" function void iss_set_register(int address, int data);
import "DPI-C" function int  iss_get_register(int address);

// run control routines

import "DPI-C" function void iss_step();
import "DPI-C" function void iss_run();
 
// debug routines

import "DPI-C" function void iss_enable_trace();
import "DPI-C" function void iss_disable_trace();

endpackage
