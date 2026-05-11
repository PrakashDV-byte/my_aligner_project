///////////////////////////////////////////////////////////////////////////////
// File:        cfs_algn_virtual_sequence_rx_size2_offset2.sv
// Author:      Pranav
// Date:        2025-06-27
// Description: Virtual sequence which configures size field of a rx item as 2 
//              and offset as 2
///////////////////////////////////////////////////////////////////////////////
`ifndef CFS_ALGN_VIRTUAL_SEQUENCE_RX_SIZE2_OFFSET2_SV
`define CFS_ALGN_VIRTUAL_SEQUENCE_RX_SIZE2_OFFSET2_SV

class cfs_algn_virtual_sequence_rx_size2_offset2 extends cfs_algn_virtual_sequence_rx;

  // Aligner data width for validation
  local int unsigned algn_data_width;

  // Constraints to force size = 1 and offset = 0
  constraint fixed_size_offset {
    seq.item.data.size() == 2;
    seq.item.offset == 2;
    // Optional legality constraint (safety)
    (seq.item.data.size() + seq.item.offset) <= (algn_data_width / 8);
  }

  `uvm_object_utils(cfs_algn_virtual_sequence_rx_size2_offset2)

  function new(string name = "");
    super.new(name);
  endfunction

  function void pre_randomize();
    super.pre_randomize();
    algn_data_width = p_sequencer.model.env_config.get_algn_data_width();
  endfunction

endclass

`endif

