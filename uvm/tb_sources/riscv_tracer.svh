
`uvm_analysis_imp_decl(_rtl_trace_port)

class riscv_tracer_c extends uvm_scoreboard;
  virtual interface cpu_state_i   cs_vif;
  cpu_exec_record_c rtl_exec;

  UVM_FILE uvm_report_file;

  uvm_analysis_imp_rtl_trace_port#(cpu_exec_record_c, riscv_tracer_c) rtl_trace_port;

  `uvm_component_utils(riscv_tracer_c)

  function new(string name, uvm_component parent);
    super.new(name, parent);

    rtl_trace_port = new("rtl_trace_port", this);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);

    rtl_exec = cpu_exec_record_c::type_id::create("rtl_exec");

    //=======================//
    // set report file here  //
    //=======================//
    uvm_report_file = $fopen("uvm_processor_trace_file.txt", "w");

    $fwrite(uvm_report_file, "Log file for Processor Execution Trace \n");

    set_report_default_file(uvm_report_file);
    // set_report_severity_action(UVM_INFO, UVM_LOG);
    set_report_severity_id_action(UVM_INFO, "riscv_tracer_c", UVM_LOG);

  endfunction

  virtual function void write_rtl_trace_port( // how is this not named "read"???
    cpu_exec_record_c exec_rec);

    string decode_message, state_change_message;

    decode_message = $sformatf(" %s ", decode_instr(exec_rec.instr));
    state_change_message = "";

    if (exec_rec.rd != 0)   state_change_message = $sformatf("set: x%0d = %x ", exec_rec.rd, exec_rec.result);
    if (exec_rec.write_op)  state_change_message = $sformatf("set: @%x = %x ", exec_rec.waddr, exec_rec.wdata);

    `uvm_info(get_type_name(), $sformatf("%-25s   %s", decode_message, state_change_message), UVM_MEDIUM);

  endfunction

endclass


