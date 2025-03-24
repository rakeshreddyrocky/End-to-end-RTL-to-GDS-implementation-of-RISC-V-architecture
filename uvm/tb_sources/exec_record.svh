class cpu_exec_record_c extends uvm_object;
 // `uvm_object_utils(cpu_exec_record_c)
 
  instruction_t  instr;
  register_num_t rd;
  register_t     result;
  logic          write_op;
  register_t     waddr;
  register_t     wdata;
  register_t     next_pc;
    
  `uvm_object_utils_begin(cpu_exec_record_c)
    `uvm_field_int (instr,    UVM_ALL_ON | UVM_UNSIGNED)
    `uvm_field_int (rd,       UVM_ALL_ON | UVM_UNSIGNED)
    `uvm_field_int (result,   UVM_ALL_ON | UVM_UNSIGNED)
    `uvm_field_int (write_op, UVM_ALL_ON | UVM_UNSIGNED)
    `uvm_field_int (waddr,    UVM_ALL_ON | UVM_UNSIGNED)
    `uvm_field_int (wdata,    UVM_ALL_ON | UVM_UNSIGNED)
    `uvm_field_int (next_pc,  UVM_ALL_ON | UVM_UNSIGNED)
  `uvm_object_utils_end

  function new(string name="cpu_exec_record_c");
    super.new(name);
  endfunction

endclass
