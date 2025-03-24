import pkg::*;
class branch_drv;
    virtual branch_if vif;
    mailbox gen2drv;
    transaction txn;
	
    function new(virtual branch_if vif, mailbox gen2drv);
        this.vif = vif;
        this.gen2drv = gen2drv;
    endfunction

    task run();
    forever begin
        gen2drv.get(txn);
        @(posedge vif.clk); // Wait for clock edge before driving values
        
        vif.instr  = txn.instr;
        vif.op1    = txn.op1;
        vif.op2    = txn.op2;
        vif.op3    = txn.op3;
        vif.enable = 1; // Assert enable signal

        @(posedge vif.clk); // Hold enable for one clock cycle
        vif.enable = 0;  // Deassert enable after a cycle to allow the DUT to process the next transaction
		$display("[DRIVER] Sent: instr=%0d, op1=%0d, op2=%0d, op3=%0d, enable=%0b", vif.instr, vif.op1, vif.op2, vif.op3, vif.enable);
    end
endtask

endclass
