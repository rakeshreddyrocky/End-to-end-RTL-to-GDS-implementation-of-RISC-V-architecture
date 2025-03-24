
//`include "transaction_v2.sv"
import trans_v1::*;

class driver;
    virtual intf vif;
    mailbox gen2driv;
    transaction tx;
	
	function new (virtual intf vif, mailbox gen2driv);
    this.vif = vif;
    this.gen2driv = gen2driv;
  endfunction

task reset();
    wait(vif.rst);
    $display("[DRV] Reset started");
    vif.op1 <= 0;
    vif.op2 <= 0;
    vif.enable <= 0;
    vif.instr <= 0;
    wait(!vif.rst);
    $display ("[DRV] Reset ended");
  endtask
  
  
  task main();
  $display("[DRV] Driver started");

  repeat(10) begin
    $display("[DRV] Waiting for transaction...");
    gen2driv.get(tx);

    $display("[DRV] Received: instr=%s, op1=%0d, op2=%0d, enable=%0d", decode_instr(tx.instr), tx.op1, tx.op2, tx.enable);

  // Apply transaction to DUT

    vif.instr = tx.instr;
    vif.op1 = tx.op1;
    vif.op2 = tx.op2;
	
     @(posedge vif.clk);
    
	vif.enable = 1;

     @(posedge vif.clk);	// Enable signal set
    vif.enable = 0;
	  
    // Wait until instr_exec is set, then reset it before proceeding
    wait(vif.instr_exec);  // Wait until execution is complete
    @(posedge vif.clk);
    vif.instr_exec <= 0;  // Reset it before getting the next instruction

    $display("[DRV] Sent: instr=%s, op1=%0d, op2=%0d, enable=%0d", decode_instr(vif.instr), vif.op1, vif.op2, vif.enable);
  end
endtask 
endclass