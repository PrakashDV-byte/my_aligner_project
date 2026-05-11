`ifndef CFS_APB_SEQUENCE_RW_SV
`define CFS_APB_SEQUENCE_RW_SV



class cfs_apb_sequence_rw extends cfs_apb_sequence_base;

  rand cfs_apb_addr addr;

  rand cfs_apb_data wr_data;

  `uvm_object_utils(cfs_apb_sequence_rw)

  function new(string name = "");
    super.new(name);
  endfunction

  virtual task body();
    cfs_apb_item_drv item;

    `uvm_do_with(item,
                 {
      dir  == CFS_APB_READ;
      addr == local::addr;
    });

    `uvm_do_with(item,
                 {
      dir  == CFS_APB_WRITE;
      addr == local::addr;
      data == wr_data;
    });

  endtask

endclass

`endif  // CFS_APB_SEQUENCE_RW_SV
