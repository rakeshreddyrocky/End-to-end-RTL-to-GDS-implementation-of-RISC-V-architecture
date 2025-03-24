
`uvm_analysis_imp_decl(_rtl_exec_port)

class riscv_scoreboard_c extends uvm_scoreboard;
  cpu_exec_record_c rtl_exec, iss_exec;
  iss_c  iss;
  int errors;
  virtual interface config_data_i config_data_if;

  uvm_analysis_imp_rtl_exec_port#(cpu_exec_record_c, riscv_scoreboard_c) rtl_exec_port;

  `uvm_component_utils(riscv_scoreboard_c)

  function new(string name="riscv_scoreboard", uvm_component parent=null);
    super.new(name, parent);

    rtl_exec_port = new("rtl_exec_port", this);
    errors = 0;
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    `uvm_info(get_type_name(), "In scoreboard build phase", UVM_INFO);

    iss      = iss_c::type_id::create("iss");
    rtl_exec = cpu_exec_record_c::type_id::create("rtl_exec");
    iss_exec = cpu_exec_record_c::type_id::create("iss_exec");
    
    uvm_config_db#(iss_c)::set(null, "", "iss", iss);

    if (!uvm_config_db#(virtual interface config_data_i)::get(null, "*", "config_data_if", config_data_if))
      `uvm_error(get_type_name(), "Unable to get config_data interface");

  endfunction

  virtual task pre_reset_phase(uvm_phase phase);
    int i;
    super.pre_reset_phase(phase);
  
    // set up reference ISS
 
    `uvm_info("SCB", "Loading program into ISS memory from design code_memory", UVM_MEDIUM);

    iss.load_program(); 
    iss.reset();
    // iss.enable_trace();

  endtask

  virtual function void write_rtl_exec_port( // how is this not named "read"???
    cpu_exec_record_c exec_rec);
    string message;

    message = $sformatf("Instruction executed: %s ", decode_instr(exec_rec.instr));

    `uvm_info("port reader", message, UVM_HIGH);

    if (config_data_if.program_name=="opcode_test") begin
      iss.set_pc(0);
      iss.set_instruction(0, exec_rec.instr);
    end
    iss.get_exec_rec(iss_exec);
    if (config_data_if.program_name=="opcode_test") begin
      iss_exec.next_pc = 0;
    end
    `uvm_info(get_type_name(), $sformatf("hdl result:   %x iss result:    %x ", exec_rec.result, iss_exec.result), UVM_DEBUG);
    `uvm_info(get_type_name(), $sformatf("hdl rd:       x%0d      iss rd:      x%0d ", exec_rec.rd, iss_exec.rd), UVM_DEBUG);
    `uvm_info(get_type_name(), $sformatf("hdl instr:    %x iss instr:     %x ", exec_rec.instr, iss_exec.instr), UVM_DEBUG);
    `uvm_info(get_type_name(), $sformatf("hdl next pc:  %x iss next_pc:   %x ", exec_rec.next_pc, iss_exec.next_pc), UVM_DEBUG);
    `uvm_info(get_type_name(), $sformatf("hdl write_op: %0d       iss write_op: %0d ", exec_rec.write_op, iss_exec.write_op), UVM_DEBUG);
    `uvm_info(get_type_name(), $sformatf("hdl waddr:    %x iss waddr:     %x ", exec_rec.waddr, iss_exec.waddr), UVM_DEBUG);
    `uvm_info(get_type_name(), $sformatf("hdl wdata:    %x iss wdata:     %x ", exec_rec.wdata, iss_exec.wdata), UVM_DEBUG);
    if (!exec_rec.compare(iss_exec)) begin
      `uvm_error(get_type_name(), "ISS and RTL have diverged");
      errors++;
    end

  endfunction

  virtual function void report_phase(uvm_phase phase);
    super.report_phase(phase);

    // check result word
    if (config_data_if.program_name=="execute_test") begin
      if (iss.get_register(10) != 'h600D600D) errors ++;
    end

    `uvm_info(get_type_name(), "=======================================================", UVM_LOW);
    `uvm_info(get_type_name(), "||                                                   ||", UVM_LOW);
    `uvm_info(get_type_name(), "||                                                   ||", UVM_LOW);
    if (errors == 0) begin
      `uvm_info(get_type_name(), "|| UVM Program execution test passed!                ||", UVM_LOW);
    end else begin
      `uvm_info(get_type_name(), $sformatf("|| UVM Program execution test failed! %3d errors     ||", errors), UVM_LOW);
    end
    `uvm_info(get_type_name(), "||                                                   ||", UVM_LOW);
    `uvm_info(get_type_name(), "||                                                   ||", UVM_LOW);
    `uvm_info(get_type_name(), "=======================================================", UVM_LOW);
  endfunction
endclass


