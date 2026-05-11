///////////////////////////////////////////////////////////////////////////////
// File:        uvm_ext_sequencer.sv
// Author:      Cristian Florin Slav
// Date:        2024-04-03
// Description: Generic sequencer class
///////////////////////////////////////////////////////////////////////////////
`ifndef UVM_EXT_SEQUENCER_SV
`define UVM_EXT_SEQUENCER_SV 

class uvm_ext_sequencer #(
    type ITEM_DRV = uvm_sequence_item
) extends uvm_sequencer #(
    .REQ(ITEM_DRV)
) implements uvm_ext_reset_handler;

  `uvm_component_param_utils(uvm_ext_sequencer#(ITEM_DRV))

  function new(string name = "", uvm_component parent);
    super.new(name, parent);
  endfunction

  virtual function void handle_reset(uvm_phase phase);
    int objections_count;
    stop_sequences();

    objections_count = uvm_test_done.get_objection_count(this);

    if (objections_count > 0) begin
      uvm_test_done.drop_objection(
          this, $sformatf("Dropping %0d objections at reset", objections_count), objections_count);
    end

    start_phase_sequence(phase);
  endfunction

endclass

`endif
