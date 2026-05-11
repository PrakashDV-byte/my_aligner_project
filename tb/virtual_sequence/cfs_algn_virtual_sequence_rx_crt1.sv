///////////////////////////////////////////////////////////////////////////////
// File:        cfs_algn_virtual_sequence_rx_crt1.sv
// Author:      Pranav
// Date:        2025-02-12
// Description: Virtual sequence which sends only one MD RX transaction and
//              constraints the MD transaction to always be not illegal.
///////////////////////////////////////////////////////////////////////////////

`ifndef CFS_ALGN_VIRTUAL_SEQUENCE_RX_CRT1_SV
`define CFS_ALGN_VIRTUAL_SEQUENCE_RX_CRT1_SV

class cfs_algn_virtual_sequence_rx_crt1 extends cfs_algn_virtual_sequence_rx;

  //Aligner data width
  local int unsigned algn_data_width;

  constraint legal_rx_hard {
    (((algn_data_width / 8) + seq.item.offset) % seq.item.data.size() == 0) &&
    ((seq.item.data.size() + seq.item.offset) <= (algn_data_width / 8)) &&
    (seq.item.data.size() == 1);
  }

  `uvm_object_utils(cfs_algn_virtual_sequence_rx_crt1)

  function new(string name = "");
    super.new(name);
  endfunction

  function void pre_randomize();
    super.pre_randomize();

    algn_data_width = p_sequencer.model.env_config.get_algn_data_width();
  endfunction

endclass

`endif
