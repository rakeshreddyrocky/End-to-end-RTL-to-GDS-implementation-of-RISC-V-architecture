
class opcode_sequencer_c extends uvm_sequencer#(opcode_seq_item_c);
  `uvm_component_utils(opcode_sequencer_c)

  function new(string name="opcode_sequencer", uvm_component parent);
    super.new(name, parent);
  endfunction

endclass;
  
