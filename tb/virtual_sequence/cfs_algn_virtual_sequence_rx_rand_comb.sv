///////////////////////////////////////////////////////////////////////////////
// File:        cfs_algn_virtual_sequence_rx_rand_comb.sv
// Author:      Keerthi Sree Somasi
// Date:        2025-07-15
// Description: RX virtual sequence that runs randomized combinations of 
//              (size, offset) pairs to test the aligner module. It randomly 
//              selects from a predefined list of valid combinations and 
//              sends RX items accordingly, enabling broader functional 
//              coverage across RX input cases.
///////////////////////////////////////////////////////////////////////////////
`ifndef CFS_ALGN_VIRTUAL_SEQUENCE_RX_RAND_COMB_SV
`define CFS_ALGN_VIRTUAL_SEQUENCE_RX_RAND_COMB_SV

class cfs_algn_virtual_sequence_rx_rand_comb extends cfs_algn_virtual_sequence_base;

  `uvm_object_utils(cfs_algn_virtual_sequence_rx_rand_comb)

  function new(string name = "");
    super.new(name);
  endfunction

  virtual task body();
    cfs_md_sequence_simple_master rx_sequence;

    // Define the list of (size, offset) combinations
    int sizes[] = '{1, 1, 1, 1, 1, 2, 2, 4, 1};
    int offsets[] = '{0, 3, 1, 2, 3, 0, 2, 0, 3};

    int unsigned rand_index;

    // Run the loop 20 times and pick random index
    for (int j = 0; j < 60; j++) begin
      assert (std::randomize(rand_index) with {rand_index < sizes.size();});

      `uvm_do_on_with(rx_sequence, p_sequencer.md_rx_sequencer,
                      {
          item.data.size() == sizes[rand_index];
          item.offset == offsets[rand_index];
        })
    end
  endtask

endclass

`endif
