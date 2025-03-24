
class execute_env_c extends uvm_env;
  `uvm_component_utils(execute_env_c);

  riscv_scoreboard_c   riscv_scoreboard;
  riscv_tracer_c       riscv_tracer;
  riscv_coverage_c     riscv_coverage;
  execute_agent_c      execute_agent;

  function new(string name="env_execute_test", uvm_component parent=null);
    super.new(name, parent);
  endfunction

  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);

    riscv_scoreboard   = riscv_scoreboard_c::type_id::create("riscv_scoreboard", this);
    riscv_tracer       = riscv_tracer_c::type_id::create("riscv_tracer", this);
    riscv_coverage     = riscv_coverage_c::type_id::create("risv_coverage", this);
    execute_agent      = execute_agent_c::type_id::create("execute_agent", this);

  endfunction

  virtual function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);

    // connect cpu monitor with tracer and scoreboard
    execute_agent.riscv_monitor.cpu_exec_port.connect(riscv_scoreboard.rtl_exec_port);
    execute_agent.riscv_monitor.cpu_exec_port.connect(riscv_tracer.rtl_trace_port);

  endfunction

endclass
