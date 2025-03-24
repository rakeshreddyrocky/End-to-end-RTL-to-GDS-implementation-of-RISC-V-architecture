
// memory model to capture transactions 
// and create expected value for reads
// from previously written address

class shadow_memory_c;
  parameter memory_size = 'h4000;
  typedef logic [3:0][7:0]  bytes_t;
  typedef logic [1:0][15:0] half_word_t;
  typedef logic [31:0]      word_t;
  typedef union packed {
    bytes_t bytes;
    half_word_t halfs;
    word_t word;
  } memory_t;
  memory_t memory [memory_size];

  /*
  function void new();
    int i;
    for (i=0;i<size;i++) memory[i] = 0;
  endfunction
  */
  // record all read transactions
  // shift and mask based on size
  function register_t read(input int address, size, input logic is_signed = 0);
    register_t data;
    logic [1:0] offset;
    case (size) 
      4 : begin
            address = address >> 2;
            data = memory[address].word;
            return data;
          end
      2 : begin 
            offset = (address & 2) ? 1 : 0;
            address = address >> 2;
            data = memory[address].halfs[offset];
            if (is_signed) data = signed'(data[15:0]);
            return data;
          end
      1 : begin
            offset = address & 3;
            address = address >> 2;
            data = memory[address].bytes[offset];
            if (is_signed) data = signed'(data[7:0]);
            return data;
          end
      default: $fatal("Verification engineer error: Invalid size in memory access!");
    endcase
  endfunction

  // return last value written to the spacific address
  // shift and mask based on size
  function void write(input int address, size, register_t data);
    logic [1:0] offset;        
    case (size) 
      4 : begin
            address = address >> 2;
            memory[address].word = data;
          end
      2 : begin 
            offset = (address & 2) ? 1 : 0;
            address = address >> 2;
            memory[address].halfs[offset] = data >> (offset * 16);
          end
      1 : begin
            offset = address & 3;
            address = address >> 2;
            memory[address].bytes[offset] = data >> (offset * 8);
          end
      default: $fatal("Verification engineer error: Invalid size in memory access!");
    endcase
  endfunction
endclass

function void mem_ops(
   input instruction_t instr,
   input register_t op1, op2,
   output register_t address, offset,
   output logic [2:0] size,
   output logic read_op, sign_ex);
 
   address = (op1 + op2) >> 2;
   offset  = (op1 + op2) & 32'h00000003;
   casez (instr)
     M_LW   : begin  size = 4;  read_op = 1; sign_ex = 0; end
     M_LH   : begin  size = 2;  read_op = 1; sign_ex = 1; end
     M_LHU  : begin  size = 2;  read_op = 1; sign_ex = 0; end
     M_LB   : begin  size = 1;  read_op = 1; sign_ex = 1; end
     M_LBU  : begin  size = 1;  read_op = 1; sign_ex = 0; end
     M_SW   : begin  size = 4;  read_op = 0; sign_ex = 0; end
     M_SH   : begin  size = 2;  read_op = 0; sign_ex = 0; end
     M_SB   : begin  size = 1;  read_op = 0; sign_ex = 0; end
     EBREAK : begin  size = 1;  read_op = 1; sign_ex = 1; end
     default: $error("Verification Engineer Error, bad input to mem_ops");
   endcase
endfunction

// oracle for expected results 
function results_c oracle(
    input instruction_t instr,
    input register_t op1, op2, op3);
  
  register_t address, data;
  logic [2:0] size, offset;
  logic read_op, write_op, sign_ex;
  static shadow_memory_c memory = new();
  static results_c ret = new();

  mem_ops(instr, op1, op2, address, offset, size, read_op, sign_ex);

  address = op1 + op2;
  if (read_op) data = memory.read(address, size, sign_ex);
  else begin 
    data = (size==4) ? op3 : 
           (size==2) ? ((op3 & 32'h0000FFFF) << (offset * 8)) :
           (size==1) ? ((op3 & 32'h000000FF) << (offset * 8)) : 0;
    memory.write(address, size, data);
  end

  ret.result = data;
  ret.rw = (read_op) ? RX_READ : RX_WRITE;
  return ret;
endfunction  


// scoreboard class

class scoreboard_c;
  mailbox#(stimulus_c) mon_in2scb;
  mailbox#(results_c)  mon_out2scb;
  stimulus_c   stim;
  results_c    resp;
  results_c    expected_result;
  int          errors;
  int          instruction_count;
  logic        done;

  logic        chatty = 0;
  logic        very_chatty = 0;

  function new(mailbox#(stimulus_c) i, mailbox#(results_c) o); 
    mon_in2scb         = i;
    mon_out2scb        = o;
    stim               = new;
    resp               = new;
    errors             = 0;
    instruction_count  = 0;
    done               = 0;
  endfunction

  task get_stim(ref stimulus_c stim);
    mon_in2scb.get(stim);
    if (verbose) begin
      $display("[SCOREBOARD ] %5d instruction: %-25s op1: %x op2: %x op3: %x", 
                   stim.instr_id, decode_instr(stim.instr), stim.op1, stim.op2, stim.op3);
    end
  endtask;

  task get_resp(ref results_c resp);
    mon_out2scb.get(resp);
    if (verbose) begin
      $display("[SCOREBOARD ] %5d %s response: %x ", 
                  stim.instr_id, (resp.rw == RX_READ) ? "Read" : "Write", resp.result);
    end
  endtask;

  task main(mem_test_t mem_test=0);
    forever begin
    
      // get stim and responses
      fork
        // mon_in2scb.get(stim);
        // mon_out2scb.get(resp);
        get_stim(stim);
        get_resp(resp);
      join

      if (stim.instr == EBREAK) begin
        done = 1;
        report_results(mem_test);
        $display("end of test reached ");
        break;
      end

      // compute expected results 
      expected_result = oracle(stim.instr, stim.op1, stim.op2, stim.op3);

      // record errors
      if ((expected_result.rw     != resp.rw) ||
          (expected_result.result != resp.result)) begin
        errors++;
        $display("Error: %-28s op1=%x op2=%x op3=%x result=%x exp_result=%x rw=%0d ex_rw=%0d ", 
                    decode_instr(stim.instr), stim.op1, stim.op2, stim.op3, resp.result, expected_result.result, resp.rw, expected_result.rw);
      end else if (chatty) begin // if chatty, record all trsnactions
        $display("Success: %-28s op1=%x op2=%x result=%x ", 
                    decode_instr(stim.instr), stim.op1, stim.op2, resp.result);
      end
   
      if (verbose) begin 
        if ((expected_result.rw     != resp.rw) ||
            (expected_result.result != resp.result)) 
            $display("[SCOREBOARD ] %5d - failure - instruction: %-25s expected=%x actual=%x ", 
                       stim.instr_id, decode_instr(stim.instr), expected_result.result, resp.result); 
        else 
            $display("[SCOREBOARD ] %5d - success - instruction: %-25s expected=%x actual=%x ", 
                       stim.instr_id, decode_instr(stim.instr), expected_result.result, resp.result); 
      end
      instruction_count++;
    end
  endtask

  task report_results(mem_test_t mem_test);
    $display("==================================================");
    $display("||                                              ||");
    $display("|| Mem_Ctrl Object Oriented Test Case Complete  ||");
    $display("|| Test Name: %-20s              ||", mem_test.name);
    $display("||                                              ||");
    $display("|| Tests Run: %7d                           ||", instruction_count);
    $display("|| Errors:    %7d                           ||", errors);  
    $display("||                                              ||");
    $display("||  >>> Test %-6s! <<<                        ||", (errors==0) ? "Passed" : "Failed"); 
    $display("||                                              ||");
    $display("==================================================");
  endtask

endclass

