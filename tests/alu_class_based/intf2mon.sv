
import trans_v1::*;

class alu_mon;
  virtual intf vif;
  mailbox mon2scb;
  transaction tx ;
  
  function new(virtual intf vif, mailbox mon2scb);
    this.vif = vif;
    this.mon2scb = mon2scb;
  endfunction

  task main();
    repeat(100) begin
    tx = new();
      @(posedge vif.clk);
	  //$display("[mon] INF: Received instr=%0d, op1=%0d, op2=%0d, enable = %0d, instr_exec=%0d", decode_instr(tx.instr), tx.op1, tx.op2, tx.enable, tx.instr_exec);
	    tx.instr = vif.instr;
        tx.op1 = vif.op1;
        tx.op2 = vif.op2;
		tx.enable = vif.enable;
		tx.result = vif.result;
		tx.instr_exec = vif.instr_exec;
       
	   $display("[mon] Received instr=%s, op1=%0d, op2=%0d, enable = %0d, instr_exec = %0d", 
              decode_instr(tx.instr), tx.op1, tx.op2, tx.enable, tx.instr_exec);

	   mon2scb.put(tx);
		
    end
    $display("monitor finished");
  endtask
endclass