
// monitor for inputs to memory controller

class monitor_in_c;
  virtual mem_if_i  vif;
  mailbox#(stimulus_c) mon_in2scb;
  stimulus_c        inputs;

  logic             chatty = 0;

  function new(virtual mem_if_i i, mailbox#(stimulus_c) m);
    vif         = i;
    mon_in2scb  = m;
  endfunction

  task main;
    if (chatty) $display("monitor_in: started %t ", $time);
    forever begin

      @(posedge vif.clk);

      #1; // ensure signals settled

      if (vif.enable) begin

        inputs          = new();

        inputs.instr    = vif.instr;
        inputs.op1      = vif.op1;
        inputs.op2      = vif.op2;
        inputs.op3      = vif.op3;
        inputs.instr_id = vif.instr_id;

        if (verbose) $display("[MONITOR IN ] %5d instruction: %-25s op1: %x op2: %x op3: %x ",
                                 inputs.instr_id, decode_instr(inputs.instr), inputs.op1, inputs.op2, inputs.op3);
           
        mon_in2scb.put(inputs);

        if (chatty) begin
          $write("time: %t stimulus sent: %s ", 
                    $time, decode_instr(vif.instr));
        end

        if (inputs.instr == EBREAK) break;
      end
    end
  endtask
endclass

// monitor for output from memory controller
// captures read data from memory instance

class monitor_out_c;
  virtual mem_if_i     vif;
  mailbox#(results_c)  mon_out2scb;
  results_c            rx;
  register_t           write_data;

  logic                chatty = 0;

  function new(virtual mem_if_i i, mailbox#(results_c) m);
    vif           = i;
    mon_out2scb   = m;
  endfunction

  task main;
    if (chatty) $display("monitor_out: started");

    forever begin

      @(posedge vif.clk);

      #1; // ensure signals settle

      // capture memory reads
      if (vif.result_valid) begin

        rx           = new();

        rx.rw        = RX_READ;
        rx.result    = vif.result;
        rx.instr_id  = vif.instr_id;

        if (verbose) $display("[MONITOR OUT] %5d instruction: READ, value: %x ", rx.instr_id, rx.result);
           
        mon_out2scb.put(rx);

      end

      // capture memory writes
      if (vif.write_enable) begin

        // shift and mask data based on size, alignment of data
        case (vif.byte_enables) 
          4'b1111: write_data = (vif.write_data >>  0) & 32'hFFFFFFFF;
          4'b0011: write_data = (vif.write_data >>  0) & 32'h0000FFFF;
          4'b1100: write_data = (vif.write_data >> 16) & 32'h0000FFFF;
          4'b0001: write_data = (vif.write_data >>  0) & 32'h000000FF;
          4'b0010: write_data = (vif.write_data >>  8) & 32'h000000FF;
          4'b0100: write_data = (vif.write_data >> 16) & 32'h000000FF;
          4'b1000: write_data = (vif.write_data >> 24) & 32'h000000FF;
          default: $error("%t Invalid write byte enable pattern %x (%d) ", $time, vif.byte_enables, vif.write_enable);
        endcase

        rx           = new();

        rx.rw        = RX_WRITE;
        rx.result    = vif.write_data;
        rx.instr_id  = vif.instr_id;

        if (verbose) $display("[MONITOR OUT] %5d instruction: WRITE, value: %x ", rx.instr_id, rx.result);

        mon_out2scb.put(rx);
      end
    
      // send on break instruction with null data when received
      // signals end of test
      if (vif.instr == EBREAK) begin

        rx = new();

        rx.rw = RX_READ;
        rx.result = '0;

        if (verbose) $display("[MONITOR OUT] End of test marker received ");

        mon_out2scb.put(rx);

      end
    end
  endtask

endclass

