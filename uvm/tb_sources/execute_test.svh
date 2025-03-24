
class execute_test_c extends uvm_test;
  `uvm_component_utils(execute_test_c)

  execute_env_c     execute_env;
  virtual interface config_data_i cd_vif;

  function new(string name = "execute_test",uvm_component parent=null);
    super.new(name, parent);
    `uvm_info(get_type_name(), "In the constructor", UVM_DEBUG);
  endfunction : new

  virtual function void build_phase(uvm_phase phase);
    `uvm_info(get_type_name(), "In the build phase", UVM_DEBUG);
    super.build_phase(phase);

    execute_env = execute_env_c::type_id::create("execute_env", this);

    if (!uvm_config_db#(virtual interface config_data_i)::get(null, "*", "config_data_if", cd_vif))
     `uvm_error(get_type_name, "Failed to get config_data interface");

  endfunction

  virtual function void end_of_elaboration_phase(uvm_phase phase);
    super.end_of_elaboration_phase(phase);

    uvm_top.print_topology();
  endfunction

  function void set_instr(int address, instruction_t instr,
       input virtual interface cpu_state_i cs_vif);
    string message;

    message = $sformatf("Load instruction: %x: %x : %-25s ", address, instr, decode_instr(instr));
    `uvm_info(get_type_name(), message, UVM_MEDIUM);

    cs_vif.code_memory[address] = instr;
    // top.u_cpu_design.u_code_memory.memory[address] = instr;

  endfunction


  // there is no stimulus for this test, except for a 
  // a program loaded into code memory do this at the 
  // start of simulation

  function void start_of_simulation_phase(uvm_phase phase);
    virtual interface cpu_state_i cs_vif;
    int program_size;

    super.start_of_simulation_phase(phase);
    `uvm_info(get_type_name(), "In the start_of_simulation phase", UVM_DEBUG);

    program_size = load_program();
    cd_vif.program_size = program_size;
  endfunction

  virtual function int load_program();
    `uvm_warning(get_type_name(), "No program loaded");
    return 0;
  endfunction

endclass

