//`include "transaction_v2.sv"
import trans_v1::*;
import opcodes::*;

class generator;
  transaction tx;
  mailbox gen2driv;
  event ended;
  int tx_count = 100; // Number of transactions to send
  
  function new(mailbox gen2driv);
    this.gen2driv = gen2driv;
  endfunction
  
  task main();
    $display("Generator started");
    repeat(tx_count) begin
      tx = new();
      assert (tx.randomize()); // Generate random transaction
      $display("GEN: Sending instr=%s, op1=%0d, op2=%0d", decode_instr(tx.instr), tx.op1, tx.op2);   
	  gen2driv.put(tx); // Send transaction to driver
    end
   ->ended; // Signal that generator is done
    $display("Generator completed");
  endtask
endclass
