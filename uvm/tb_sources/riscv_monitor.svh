
class riscv_monitor_c extends uvm_monitor;
  `uvm_component_utils(riscv_monitor_c)

  function new(string name = "riscv_monitor",uvm_component parent=null);
    super.new(name, parent);
    `uvm_info(get_type_name(), "In the contructor", UVM_DEBUG);
  endfunction : new

  virtual interface cpu_trace_i tr_vif;

  uvm_analysis_port #(cpu_exec_record_c) cpu_exec_port;
  
  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);

    cpu_exec_port = new("cpu_exec_port", this);

    if (!uvm_config_db#(virtual interface cpu_trace_i)::get(this, "", "cpu_trace_if", tr_vif))
      `uvm_error(get_type_name(), "Get CPU trace interface failed");
    
  endfunction

  virtual task run_phase(uvm_phase phase);

    cpu_exec_record_c ex_rec;
    string message;

    ex_rec = cpu_exec_record_c::type_id::create("ex_rec");

    super.run_phase(phase);

    forever @(posedge tr_vif.clk) begin

      logic [31:0] byte_address;
      logic [31:0] write_data;

      if (tr_vif.execute) begin
        ex_rec.instr = tr_vif.instr;
      end

      if (tr_vif.write_back) begin

        case (tr_vif.byte_enable)
          2  :  byte_address = 1 + (tr_vif.address << 2);
          4, 
          12 :  byte_address = 2 + (tr_vif.address << 2);
          8  :  byte_address = 3 + (tr_vif.address << 2);
          default: byte_address = (tr_vif.address << 2);
        endcase

        case (tr_vif.byte_enable)
          2  :  write_data = tr_vif.write_data >> 8;
          4, 
          12 :  write_data = tr_vif.write_data >> 16;
          8  :  write_data = tr_vif.write_data >> 24;
          default: write_data = tr_vif.write_data;
        endcase

        ex_rec.rd = tr_vif.rd;
        if (tr_vif.rd == 0) ex_rec.result = 0; 
        else ex_rec.result = tr_vif.result;
        ex_rec.next_pc = tr_vif.pc;

        if (is_s_type(tr_vif.instr)) begin
           ex_rec.write_op = 1;
           ex_rec.waddr = byte_address;
           ex_rec.wdata = write_data;
        end else begin
           ex_rec.write_op = 0;
           ex_rec.waddr = '0;
           ex_rec.wdata = '0;
        end
        cpu_exec_port.write(ex_rec);

      end

    end
  endtask

endclass : riscv_monitor_c

