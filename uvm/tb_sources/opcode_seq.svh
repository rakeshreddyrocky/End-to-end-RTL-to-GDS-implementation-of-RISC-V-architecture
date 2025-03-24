
class opcode_seq_c extends uvm_sequence#(opcode_seq_item_c);
  `uvm_object_utils(opcode_seq_c);

  opcode_seq_item_c opcode_stim;

  function new(string name="opcode_seq_c");
    super.new(name);
  endfunction

  task body;
    opcode_stim = opcode_seq_item_c::type_id::create("opcode_stim");
    
    start_item(opcode_stim);
    if (!opcode_stim.randomize())
      `uvm_error(get_type_name(), "Randomize failed");
    finish_item(opcode_stim);

  endtask
endclass
