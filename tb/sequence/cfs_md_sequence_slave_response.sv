`ifndef CFS_MD_SEQUENCE_SLAVE_RESPONSE_SV
`define CFS_MD_SEQUENCE_SLAVE_RESPONSE_SV 



class cfs_md_sequence_slave_response extends cfs_md_sequence_base_slave;

  `uvm_object_utils(cfs_md_sequence_slave_response)

  function new(string name = "");
    super.new(name);
  endfunction

  virtual task body();
    cfs_md_item_mon item_mon;

    p_sequencer.pending_items.get(item_mon);

    begin
      cfs_md_sequence_simple_slave seq;

      `uvm_do_with(
      seq,
      {
      //item_mon.data[0] == 'h85 -> seq.item.response == CFS_MD_ERR;
                   //item_mon.data[0] != 'h85 -> seq.item.response == CFS_MD_OKAY;
                   })
    end
  endtask

endclass

`endif  // CFS_MD_SEQUENCE_SLAVE_RESPONSE_SV
