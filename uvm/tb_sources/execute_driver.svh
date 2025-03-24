
class execute_driver_c extends uvm_driver#(int);
  `uvm_component_utils(execute_driver_c)

  function new(string name="execute_driver", uvm_component parent=null);
    super.new(name, parent);
  endfunction

  virtual interface cpu_if_i cpu_if;

  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);

    if (!uvm_config_db#(virtual interface cpu_if_i)::get(this, "", "cpu_if", cpu_if))
     `uvm_error(get_type_name, "Failed to get cpu interface");

  endfunction

  virtual task run_phase(uvm_phase phase);
    super.run_phase(phase);
 
    phase.raise_objection(this);

    @(posedge cpu_if.halted);

    phase.drop_objection(this);
  endtask
endclass : execute_driver_c 
