
class opcode_agent_c extends uvm_agent;
  `uvm_component_utils(opcode_agent_c);

  function new(string name="opcode_agent_c", uvm_component parent);
    super.new(name, parent);
    
  endfunction

  opcode_driver_c    opcode_driver;
  //opcode_monitor_c   opcode_monitor;
  riscv_monitor_c    riscv_monitor;
  opcode_sequencer_c opcode_sequencer;

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);

    opcode_driver    = opcode_driver_c::type_id::create("opcode_driver", this);
    //opcode_monitor   = opcode_monitor_c::type_id::create("opcode_monitor", this);
    riscv_monitor    = riscv_monitor_c::type_id::create("riscv_monitor", this);
    opcode_sequencer = opcode_sequencer_c::type_id::create("opcode_sequencer", this);
  endfunction

  virtual function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);

    // connect default ports
    opcode_driver.seq_item_port.connect(opcode_sequencer.seq_item_export);
  endfunction

endclass
