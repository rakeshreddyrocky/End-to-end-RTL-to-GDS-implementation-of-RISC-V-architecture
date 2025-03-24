`include "generator.sv"
`include "driver.sv"
`include "monitor.sv"
`include "scoreboard.sv"
class branch_env;
    branch_gen gen;
    branch_drv drv;
    branch_mon mon;
    branch_scb scb;

    mailbox gen2drv;
    mailbox mon2scb;

    virtual branch_if vif;

    function new(virtual branch_if vif);
        this.vif = vif;
        gen2drv = new();
        mon2scb = new();
        gen = new(gen2drv);
        drv = new(vif, gen2drv);
        mon = new(vif, mon2scb);
        scb = new(mon2scb);
    endfunction

    task run();
        $display("ENV: Starting testbench");
        fork
            gen.run();
            drv.run();
            mon.run();
            scb.run();
        join_any
    endtask

    task report();
        scb.report();
    endtask
endclass