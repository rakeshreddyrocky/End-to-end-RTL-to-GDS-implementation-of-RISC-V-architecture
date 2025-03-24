
import iss_pkg::*;

class iss_c extends uvm_object;
  `uvm_object_utils(iss_c)

  virtual interface cpu_state_i   cpu_state_if;
  virtual interface config_data_i config_data_if;

  function new(string name="iss");
    super.new(name);

    if (!uvm_config_db#(virtual interface cpu_state_i)::get(null, "*", "cpu_state_if", cpu_state_if)) 
     `uvm_error("ISS", "Failed to get cpu_state_if interface");

    if (!uvm_config_db#(virtual interface config_data_i)::get(null, "*", "config_data_if", config_data_if)) 
     `uvm_error("ISS", "Failed to get config_object interface");

  endfunction

  function void load_program();
    int i;
    for (i=0; i<config_data_if.program_size; i++) begin
     iss_set_instruction(i, cpu_state_if.code_memory[i]);
    end
  endfunction

  function void set_instruction(int addr, instruction_t instr);
    iss_set_instruction(addr, instr);
  endfunction

  function void set_register(int addr, register_t value);
    iss_set_register(addr, value);
  endfunction

  function int get_register(int addr);
    return iss_get_register(addr);
  endfunction

  function void set_pc(register_t value);
    iss_set_pc(value);
  endfunction

  function void reset();
    iss_reset();
  endfunction

  function void step();
    iss_step();
  endfunction

  function void enable_trace();
    iss_enable_trace();
  endfunction

  function void disable_trace();
    iss_disable_trace();
  endfunction

  function void run_iss();
    iss_enable_trace();
    iss_run();
  endfunction

  function void set_read_value(int value);
    iss_set_read_value(value);
  endfunction

  function void enable_data_bypass();
    iss_enable_data_bypass();
  endfunction

  function void disable_data_bypass();
    iss_disable_data_bypass();
  endfunction

  function void get_exec_rec(ref cpu_exec_record_c exec_rec);
    exec_rec.instr = iss_get_instruction(iss_get_pc());

    iss_step();
    exec_rec.next_pc = ((iss_get_pc()) << 2);
    exec_rec.rd = iss_get_rd();
    exec_rec.result = iss_get_register(exec_rec.rd);
    exec_rec.write_op = iss_get_write_op();
    exec_rec.wdata = iss_get_wdata();
    exec_rec.waddr = iss_get_waddr();
  endfunction

  function void check_state(int size);
    int i;
    int errors = 0;
    string message;

    for (i=1; i<32; i++) begin
      if (iss_get_register(i) != cpu_state_if.register_bank[i]) begin
        message = $sformatf("Register error: hdl register[%0d] = %x iss register[%0d] = %x ",
                             i, cpu_state_if.register_bank[i], i, iss_get_register(i));
        `uvm_error(get_type_name(), message);
        errors++;
      end
    end

    for (i=0; i<size; i++) begin
      if (!$isunknown(cpu_state_if.data_memory[i])) begin
        if (iss_get_memory_word(i<<2) != cpu_state_if.data_memory[i]) begin 
          message = $sformatf("Memory error: hdl data_memory[%0d] = %x iss memory[%0d] = %x ",
                               i, cpu_state_if.data_memory[i], i, iss_get_memory_word(i<<2));
          `uvm_error(get_type_name(), message);
          errors++;
        end
      end
    end
    if (errors)   `uvm_error(get_type_name(), "Reference ISS comparison failed!");
    if (errors==0) `uvm_info(get_type_name(), "Reference ISS comparison passed!", UVM_HIGH);
  endfunction
endclass
