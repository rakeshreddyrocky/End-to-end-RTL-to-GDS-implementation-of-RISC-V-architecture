import opcodes::*;

import trans_v1::*;


class alu_scb;
    mailbox mon2scb;
    transaction tx;
    int error_count = 0; // Error counter
	register_t expected_result;

   // Declare covergroup instance
    covergroup alu_cg;

        // Cover instruction execution
        coverpoint tx.instr {
            bins arith_ops[] = {M_ADD, M_ADDI, M_SUB};
            bins logic_ops[] = {M_AND, M_ANDI, M_OR, M_ORI, M_XOR, M_XORI};
            bins shift_ops[] = {M_SLL, M_SLLI, M_SRL, M_SRLI, M_SRA, M_SRAI};
            bins compare_ops[] = {M_STL, M_STLI, M_STLU, M_STLUI};
        }

        // Cover operand values
        coverpoint tx.op1 {
            bins zero = {0};
            bins positive = {[1:10]};
            bins negative = {[-10:-1]};
        }
        
        coverpoint tx.op2 {
            bins zero = {0};
            bins positive = {[1:10]};
            bins negative = {[-10:-1]};
        }

        // Cover ALU output
        coverpoint tx.result {
            bins zero = {0};
            bins positive = {[1:100]};
            bins negative = {[-100:-1]};
        }

        // Cross coverage to ensure all combinations are tested
        cross tx.instr, tx.op1, tx.op2, tx.result;

    endgroup // End of covergroup


   function new(mailbox mon2scb);
        this.mon2scb = mon2scb;
    endfunction

    task main();
        repeat(100) begin
            mon2scb.get(tx);  // Get transaction from monitor
			
			 wait(tx.instr_exec);  // Wait until instr_exec is asserted
    @(posedge vif.clk);  // Ensure the value has settled
            
            $display("SCB: Received tx - instr=%0d, op1=%0d, op2=%0d, enable=%0d, result=%0d",
                     decode_instr(tx.instr), tx.op1, tx.op2, tx.enable, tx.result);

            // Check for valid enable signal
            if (tx.enable === 1'bx) begin
                error_count++;
                $error("SCB: Enable signal is X!");
                continue;
            end

            // Compute expected ALU result using Golden Model inside the scoreboard
            expected_result = golden_alu(tx.op1, tx.op2, tx.instr);

            // Compare DUT result with expected result
            if (tx.result !== expected_result) begin
                error_count++;
                $error("SCB: Mismatch! instr=%0d, op1=%0d, op2=%0d, Expected Result=%0d, DUT Output=%0d",
                       decode_instr(tx.instr), tx.op1, tx.op2, expected_result, tx.result);
            end else begin
                $display("SCB: Match! instr=%0d, op1=%0d, op2=%0d, Result=%0d ",
                         decode_instr(tx.instr), tx.op1, tx.op2, tx.result);
            end
        end
    endtask

    // **Golden Model inside Scoreboard**
    function automatic register_t golden_alu(bit[31:0] op1, bit[31:0] op2, instruction_t instr);
        case (instr)
            M_ADD, M_ADDI  : return op1 + op2;
            M_SUB          : return op1 - op2;
            M_AND, M_ANDI  : return op1 & op2;
            M_OR, M_ORI    : return op1 | op2;
            M_XOR, M_XORI  : return op1 ^ op2;
            M_SLL, M_SLLI  : return op1 << (op2 & 5'h1F);
            M_SRL, M_SRLI  : return op1 >> (op2 & 5'h1F);
            M_SRA, M_SRAI  : return $signed(op1) >>> (op2 & 5'h1F);
            M_STL, M_STLI  : return ($signed(op1) < $signed(op2)) ? 1 : 0;
            M_STLU, M_STLUI: return ($unsigned(op1) < $unsigned(op2)) ? 1 : 0;
            default        : return 0; // Default case for unsupported operations
        endcase
    endfunction

    function void report();
        $display("SCB: Test completed with %0d errors", error_count);
    endfunction
endclass
