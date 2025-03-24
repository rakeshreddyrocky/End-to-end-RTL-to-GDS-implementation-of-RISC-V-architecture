
`include "env.sv"

class base_test;
  
  branch_env e;

  function new(virtual branch_if vif);
    e = new(vif);
  endfunction

  task run();
    e.run();
  endtask

endclass
