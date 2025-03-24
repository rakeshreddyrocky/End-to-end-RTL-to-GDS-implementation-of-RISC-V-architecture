

class code_exec_env_c extends uvm_env;
  `uvm_component_utils(code_exec_env_c)

  code_exec_agent_c  code_exec_agent;
  riscv_scoreboard_c riscv_scoreboard;

  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction

  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);

    code_exec_agent = code_exec_agent_c::type_id::create("code_exec_agent", this);
    riscv_scoreboard = riscv_scoreboard_c::type_id::create("riscv_scoreboard", this);
  endfunction

  virtual function connect_phase(string name, umv_component parent);

    code_exec_agent.xxxx.xxxx.port(riscv_scoreboard.ex_port);
  endfunction

endclass
