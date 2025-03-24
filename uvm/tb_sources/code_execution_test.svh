
class code_execution_test extends uvm_test;
  `uvm_component_utils(code_execuiton_test)

  function new(string name = "code_execution_test",uvm_component parent=null);
    super.new(name, parent);
    `uvm_info("FIB", "In the contructor", UVM_HIGH);
  endfunction : new

  int program_size;
  int data_size = 'h10000;

  function void set_instr(int address, instruction_t instr,
       input virtual interface code_memory_i cm_vif); 
    string message;

    message = $sformatf("Load instruction: %x: %x : %-25s ", address, instr, decode_instr(instr)); 
    `uvm_info("LOAD", message, UVM_INFO);

    cm_vif.set(address, instr);
    // top.u_cpu_design.u_code_memory.memory[address] = instr;

  endfunction

  pure virtual function int load_program(
     input virtual interface code_memory_i cm_vif);
    
  endfunction

  function automatic string print_write(input int address, data, logic [3:0] byte_enable);
    string message;
    case (byte_enable)
      'hf: message = $sformatf(" write @%x = %x ",  address<<2, data);
      'hc: message = $sformatf(" write @%x = %4x ", address<<2, (data >> 16));
      'h3: message = $sformatf(" write @%x = %4x ", address<<2, (data & 'hFFFF));
      'h8: message = $sformatf(" write @%x = %2x ", address<<2, (data >> 24) & 'hFF);
      'h4: message = $sformatf(" write @%x = %2x ", address<<2, (data >> 16) & 'hFF);
      'h2: message = $sformatf(" write @%x = %2x ", address<<2, (data >>  8) & 'hFF);
      'h1: message = $sformatf(" write @%x = %2x ", address<<2, (data >>  0) & 'hFF);
      default: message = $sformatf(" *** illegal write operation ");
    endcase
    return message;
  endfunction

  task cpu_trace;
    virtual interface cpu_trace_i tr_vif;
    string message;

    uvm_config_db#(virtual interface cpu_trace_i)::get(null, "*", "cpu_trace_if", tr_vif);

    forever @(posedge tr_vif.clk) begin
      if (tr_vif.execute) begin
        message = $sformatf("%x: %x : %-25s ", 
            tr_vif.pc, tr_vif.instr, 
            decode_instr(tr_vif.instr)); 
        `uvm_info("CPU_TRACE", message, UVM_INFO);
      end
      if (tr_vif.write_back) begin
        if (tr_vif.rd != 0) begin
          message = $sformatf("x%0d = %x ", 
             tr_vif.rd,
             tr_vif.result);
          `uvm_info("CPU_STATE_CHANGE", message, UVM_INFO);
        end
        if (is_s_type(tr_vif.instr)) begin
          message = print_write(
             tr_vif.address,
             tr_vif.write_data,
             tr_vif.byte_enable);
          `uvm_info("CPU_STATE_CHANGE", message, UVM_INFO)
        end
      end
    end
  endtask

  task configure_phase(uvm_phase phase);
    int i;

    super.configure_phase(phase);
    `uvm_info("FIB", "In the config phase", UVM_INFO);     

  endtask : configure_phase

  function void start_of_simulation_phase(uvm_phase phase);
    virtual interface code_memory_i cm_vif;

    // super.configure_phase(phase); Why? Why? Why????

    `uvm_info("FIB", "In the end_of_simulation_phase", UVM_INFO);

    uvm_config_db#(virtual interface code_memory_i)::get(null, "*", "code_memory_if", cm_vif);

    program_size = load_program(cm_vif);
    // fork cpu_trace;
    // join_none;
  endfunction
  
  function void end_of_elaboration_phase(uvm_phase phase); // (uvm_phase phase);
    super.end_of_elaboration_phase(phase); 
 kdjflslkdjflksdjf
    `uvm_info("FIB", "In the end_of_elaboration_phase", UVM_INFO);
  endfunction

  task reset_phase(uvm_phase phase);
    super.configure_phase(phase);

    `uvm_info("FIB", "In the reset_phase ", UVM_INFO);

  endtask

  task run_phase(uvm_phase phase);
    virtual interface cpu_if_i cpu_if;

    super.configure_phase(phase);

    `uvm_info("FIB", "In the run phase", UVM_INFO);     

    // get cpu interface
    uvm_config_db#(virtual interface cpu_if_i)::get(null, "*", "cpu_if", cpu_if);
    
    phase.raise_objection(this);

    @(posedge cpu_if.halted);

    phase.drop_objection(this);
  endtask

  function void extract_phase(uvm_phase phase);
    virtual interface code_memory_i code_memory_if;
    iss_c iss = new();

    super.configure_phase(phase);

    uvm_config_db#(virtual interface code_memory_i)::get(null, "*", "code_memory_if", code_memory_if);
    `uvm_info("FIB", "In the extract phase", UVM_INFO);

    iss.load_program(program_size);
    iss.run();
    iss.check_state(data_size);

  endfunction

endclass 

