
class opcode_driver_c extends uvm_driver#(opcode_seq_item_c);
  `uvm_component_utils(opcode_driver_c)

  function new(string name="opcode_driver_c", uvm_component parent);
    super.new(name, parent);
  endfunction

  virtual interface cpu_if_i    ci_vif;
  virtual interface cpu_state_i cs_vif;
  iss_c                         iss;

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    `uvm_info(get_type_name(), "Starting driver build phase", UVM_INFO);

    if (!uvm_config_db#(virtual interface cpu_if_i)::get(null, "*", "cpu_if", ci_vif)) 
      `uvm_error(get_type_name(), "Unable to get cpu_if interface");

    if (!uvm_config_db#(virtual interface cpu_state_i)::get(null, "*", "cpu_state_if", cs_vif)) 
      `uvm_error(get_type_name(), "Unable to get cpu_state interface");

  endfunction

  function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);

    if (!uvm_config_db#(iss_c)::get(null, "*", "iss", iss))
      `uvm_error(get_type_name(), "Unable to get iss handle");

  endfunction

  task drive_item(input opcode_seq_item_c item);
    `uvm_info(get_type_name(), $sformatf("driver opcode: %s ", decode_instr(item.instr)), UVM_HIGH);

    ci_vif.instr     = item.instr;
    ci_vif.read_data = item.read_data;

    foreach (item.register_bank[i]) begin
      cs_vif.register_bank[i] = item.register_bank[i];
      iss.set_register(i, item.register_bank[i]);
    end

    // cs_vif.pc = 0;
    iss.set_pc(0);
    iss.set_instruction(iss_get_pc(), item.instr);
    iss.set_read_value(item.read_data);

    @(posedge ci_vif.instruction_enable);
  
  endtask

  virtual task run_phase(uvm_phase phase);
    opcode_seq_item_c item;

    super.run_phase(phase);

    @(posedge ci_vif.rst);

    forever begin
      item = opcode_seq_item_c::type_id::create("item");
      seq_item_port.get_next_item(item);
      drive_item(item);
      seq_item_port.item_done();
    end

  endtask
endclass
