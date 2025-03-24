`include "generator.sv"
`include "driver_v2.sv"
`include "intf2mon.sv"
`include "scb.sv"

import trans_v1::*;

class environment;
  generator gen;
  driver driv;
  alu_mon mon;
 alu_scb scb;
  
  mailbox gen2driv;
  mailbox mon2scb;
  

  virtual intf vif;
  
  function new(virtual intf vif);
    this.vif = vif;
    gen2driv = new();
	mon2scb = new();
    //mon_in2scb = new();
    //mon_out2scb = new();
    
    gen = new(gen2driv);
    driv = new(vif, gen2driv);
    mon = new(vif, mon2scb);
   scb = new(mon2scb);
  endfunction
  
  task test();
  $display("ENV: Starting testbench");
    fork
      gen.main();      // Start transaction generation
      driv.main();     // Apply transactions to DUT
      mon.main();   // Capture input transactions
     scb.main();      // Compare expected vs actual results
    join_any // Run all tasks concurrently
  endtask
  
  task pre_test();
    driv.reset(); // Ensure proper DUT reset
  endtask
  
  task run();
    pre_test();
    test();
    wait(gen.ended.triggered); // Ensure the generator has completed its task
    #500; // Extra time to process final transactions
    $display("Test completed successfully.");
    $finish;
  endtask
endclass
