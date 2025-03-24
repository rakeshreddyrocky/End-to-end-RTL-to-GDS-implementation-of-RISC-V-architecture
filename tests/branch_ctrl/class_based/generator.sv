import pkg::*;

class branch_gen;

	transaction txn;
	mailbox  gen2drv;

	function new(mailbox gen2drv);
		this.gen2drv =gen2drv;
	endfunction
	
	task run();
		repeat(100) 
		begin
		  txn = new(); 
		if (!txn.randomize()) begin
         $error("randomization failed");
       end
       else begin
	   //txn.display();
       $display("[ GENERATOR]:  after randomization txn.instr=%0d,txn.op1=%0d,txn.op2=%0d,txn.op3=%0d", txn.instr,txn.op1,txn.op2,txn.op3);
       end 
		gen2drv.put(txn);
		  
		end
	endtask
	
endclass

