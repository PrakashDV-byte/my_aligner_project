`ifndef CFS_MD_SEQUENCE_FIXED_DELAY_SV
`define CFS_MD_SEQUENCE_FIXED_DELAY_SV

class cfs_md_sequence_fixed_delay extends cfs_md_sequence_base_master;

  `uvm_object_utils(cfs_md_sequence_fixed_delay)

  function new(string name = "");
    super.new(name);
  endfunction

  virtual task body();
    cfs_md_item_drv_master item;

    `uvm_do_with(item,
                 {
      item.data.size() == 1;
      item.offset == 0;
      item.pre_drive_delay == 1;
      item.post_drive_delay == 1;
    })
  endtask

endclass

`endif

