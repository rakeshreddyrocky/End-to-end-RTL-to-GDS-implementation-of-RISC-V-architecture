
// drives stimuli into interface 
// receives stimli from geenrator mailbox

class  driver_c;
  virtual mem_if_i      vif;
  mailbox#(stimulus_c)  gen2drv;
  int                   pause = 5; // delay between instructions sent to DUT

  logic                 chatty  = 0;

  function new(virtual mem_if_i i, mailbox#(stimulus_c) m);
    if (chatty) $display("driver: in constructor for driver");

    gen2drv          = m;
    vif              = i;
  endfunction

  task reset;
    if (chatty) $display("driver: in reset");

    // deassert/initialize all signals
    vif.op1          = '0;
    vif.op2          = '0;
    vif.op3          = '0;
    vif.instr        = NO_OP;
    vif.enable       = 0;
    vif.byte_enables = 0;

    // wait for reset 
    wait(vif.rst);
    wait(!vif.rst);

    if (chatty) $display("driver: reset completed");
  endtask

  task main;
    if (chatty) $display("driver: started");

    @(posedge vif.clk); // sync to rising edge of clock
    forever begin

      stimulus_c inputs = new();

      // get inputs from generator
      gen2drv.get(inputs);

      // drive inputs
      vif.instr       = inputs.instr;
      vif.op1         = inputs.op1;
      vif.op2         = inputs.op2;
      vif.op3         = inputs.op3;
      vif.instr_id    = inputs.instr_id;

      // toggle enable
      vif.enable = 1;
      @(posedge vif.clk);
      vif.enable = 0;

      if (verbose) $display("[DRIVER     ] %5d instruction: %-25s op1: %x op2: %x op3: %x", 
                              inputs.instr_id, decode_instr(inputs.instr), inputs.op1, inputs.op2, inputs.op3);

      // wait a bit
      repeat (pause) @(posedge vif.clk);

      if (inputs.instr == EBREAK) break;
    end

    if (chatty) $display("driver: finished");
  endtask : main

endclass


