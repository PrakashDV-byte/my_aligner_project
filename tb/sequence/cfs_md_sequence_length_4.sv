`ifndef CFS_MD_SEQUENCE_LENGTH_4_SV
`define CFS_MD_SEQUENCE_LENGTH_4_SV

class cfs_md_sequence_length_4 extends cfs_md_sequence_base_slave;

  `uvm_object_utils(cfs_md_sequence_length_4)

  function new(string name = "");
    super.new(name);
  endfunction

  virtual task body();
    cfs_md_item_mon item_mon;
    p_sequencer.pending_items.get(item_mon);

    begin
      cfs_md_sequence_simple_slave seq;

      `uvm_do_with(seq,
                   {
       // seq.item.ready_at_end == 1;
        seq.item.length == 4;
      })

    end
  endtask

endclass

`endif  // CFS_MD_SEQUENCE_LENGTH_4_SV

