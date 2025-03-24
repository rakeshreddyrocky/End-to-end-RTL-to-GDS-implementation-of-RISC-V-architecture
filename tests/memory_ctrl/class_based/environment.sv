

class environment_c;
  generator_c      gen;
  driver_c         drv;
  monitor_in_c     mon_in;
  monitor_out_c    mon_out;
  scoreboard_c     scb;

  mailbox#(stimulus_c)  gen2drv;
  mailbox#(stimulus_c)  mon_in2scb;
  mailbox#(results_c)   mon_out2scb;

  virtual mem_if_i vif;
  int              num_tests;
  mem_test_t       mem_test;

  logic chatty = 0;

  function new(virtual mem_if_i m, 
               int              n = 100,
               mem_test_t       mem_test = 0);

    if (chatty) $display("environment: starting, running %d tests ", n);
    num_tests     = n;
    this.mem_test = mem_test;

    // make new mailboxes

    gen2drv       = new();
    mon_in2scb    = new();
    mon_out2scb   = new();

    // connect virtual interface
    vif          = m;

    // make new classes for agent and scoreboard
    drv          = new(vif, gen2drv);
    gen          = new(gen2drv, num_tests);
    mon_in       = new(vif, mon_in2scb);
    mon_out      = new(vif, mon_out2scb);
    scb          = new(mon_in2scb, mon_out2scb);

  endfunction

  task pre_test;
    drv.reset();
  endtask

  task test;

    if (chatty) $display("starting test ");

    fork
      gen.main(mem_test);
      mon_in.main();   // forever thread
      mon_out.main();  // forever thread
      drv.main();      // forever thread
      scb.main(mem_test);
    join_any

    wait (scb.done);   // when "EBREAK instruction reached 
                       // scoreboard, test is done

    if (chatty) $display("test done ");

  endtask

  task post_test;
    // perform any clean-up here
  endtask

  task run;
    pre_test();
    test();
    post_test();
    $finish;
  endtask

endclass

