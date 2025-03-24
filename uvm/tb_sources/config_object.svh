
class config_object_c extends uvm_object;

  // properties of the configuration
  
  string program_name;
  string program_filename;
  int    program_size;

  `uvm_object_utils_begin(config_object_c)
    `uvm_field_string (program_name,        UVM_ALL_ON)
    `uvm_field_string (program_filename,    UVM_ALL_ON)
    `uvm_field_int    (program_size,        UVM_ALL_ON | UVM_UNSIGNED)
  `uvm_object_utils_end

  function new(string name="config_object");
    super.new(name);
  endfunction

endclass
