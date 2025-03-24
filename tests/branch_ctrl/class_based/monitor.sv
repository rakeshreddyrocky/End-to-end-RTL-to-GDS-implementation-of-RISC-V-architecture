import pkg::*;

class branch_mon;
    virtual branch_if vif;
    mailbox mon2scb;
    transaction txn;

    // Constructor
    function new(virtual branch_if vif, mailbox mon2scb);
        this.vif = vif;
        this.mon2scb = mon2scb;
    endfunction

    task run();
        forever begin
            txn = new();
            @(posedge vif.clk);
			#1;
			 $display("[Interface] : received vif.instr=%0d, vif.op1=%0d, vif.op2=%0d, vif.op3=%0d,vif.pc_out=%0d,vif.ret_addr=%0d",vif.instr, vif.op1, vif.op2, vif.op3,vif.pc_out,vif.ret_addr);
                txn.instr = vif.instr;
                txn.op1 = vif.op1;
                txn.op2 = vif.op2;
                txn.op3 = vif.op3;
                txn.enable = vif.enable;
				#10;
				txn.pc_out = vif.pc_out;     
                txn.ret_addr = vif.ret_addr; 
                mon2scb.put(txn);
                $display("[Monitor]: received txn.instr=%0d, txn.op1=%0d, txn.op2=%0d, txn.op3=%0d,pc_out=%0d,ret_addr=%0d",txn.instr, txn.op1, txn.op2, txn.op3,txn.pc_out,txn.ret_addr);
        end
    endtask
endclass
