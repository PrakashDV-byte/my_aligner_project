`ifndef CFS_MD_SEQUENCE_SIMPLE_SLAVE_SV
`define CFS_MD_SEQUENCE_SIMPLE_SLAVE_SV 

class cfs_md_sequence_simple_slave extends cfs_md_sequence_base_slave;

  //Item to drive
  rand cfs_md_item_drv_slave item;

  `uvm_object_utils(cfs_md_sequence_simple_slave)

  function new(string name = "");
    super.new(name);

    item = cfs_md_item_drv_slave::type_id::create("item");
  endfunction

  virtual task body();
    `uvm_send(item)
  endtask

endclass

`endif  // CFS_MD_SEQUENCE_SIMPLE_SLAVE_SV
