
class execute_agent_c extends uvm_agent;
  `uvm_component_utils(execute_agent_c)

  function new(string name="execute_agent", uvm_component parent=null);
    super.new(name, parent);
  endfunction

  riscv_monitor_c riscv_monitor;
  execute_driver_c execute_driver;

  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
  
    riscv_monitor = riscv_monitor_c::type_id::create("riscv_monitor", this);
    execute_driver = execute_driver_c::type_id::create("execute_driver", this);
  endfunction
endclass

