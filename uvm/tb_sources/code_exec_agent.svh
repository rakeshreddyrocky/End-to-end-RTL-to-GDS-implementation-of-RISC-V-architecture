
class code_exec_agent_c extends uvm_agent;
  `uvm_component_utils(code_exec_agent_c)

  string program_name;
  program_loader_c program_loader;

  function new(string name="code_exec_agent", uvm_component parent=null);
    super.new(name, parent);
  endfunction

  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
  
    program_loader = new();
    monitor

