
// drives stimuli into interface 
// receives stimli from generator mailbox

class  driver_c;
  virtual decoder_if_i  vif;
  mailbox#(stimulus_c)  gen2drv;
  int                   pause = 5; // delay between instructions sent to DUT

  logic                 chatty  = 0;

  function new(virtual decoder_if_i i, mailbox#(stimulus_c) m);
    if (chatty) $display("driver: in constructor for driver");

    gen2drv          = m;
    vif              = i;
  endfunction

  task reset;
    if (chatty) $display("driver: in reset");

    // deassert/initialize all signals
    vif.instr        = NO_OP;
    vif.enable       = 0;
    foreach(vif.register_bank[i]) vif.register_bank[i] = '0;

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
      foreach(vif.register_bank[i]) vif.register_bank[i] = inputs.register_bank[i];
      vif.instr_id    = inputs.instr_id;

      // toggle enable
      vif.enable = 1;
      @(posedge vif.clk);
      vif.enable = 0;

      if (verbose) $display("[DRIVER     ] %5d instruction: %-25s registers[1]: %x registers[2]: %x registers[3]: %x",
                              inputs.instr_id, decode_instr(inputs.instr), inputs.register_bank[1],
                              inputs.register_bank[2], inputs.register_bank[3]);

      // wait a bit
      repeat (pause) @(posedge vif.clk);
    end

    if (chatty) $display("driver: finished");
  endtask : main

endclass


