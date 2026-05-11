`ifndef CFS_MD_SEQUENCER_SLAVE_SV
`define CFS_MD_SEQUENCER_SLAVE_SV 

class cfs_md_sequencer_slave #(
    int unsigned DATA_WIDTH = 32
) extends cfs_md_sequencer_base_slave;

  `uvm_component_param_utils(cfs_md_sequencer_slave#(DATA_WIDTH))

  function new(string name = "", uvm_component parent);
    super.new(name, parent);
  endfunction

  virtual function int unsigned get_data_width();
    return DATA_WIDTH;
  endfunction

endclass

`endif  // CFS_MD_SEQUENCER_SLAVE_SV
