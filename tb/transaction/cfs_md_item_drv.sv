`ifndef CFS_MD_ITEM_DRV_SV
`define CFS_MD_ITEM_DRV_SV

class cfs_md_item_drv extends cfs_md_item_base;

  `uvm_object_utils(cfs_md_item_drv)

  function new(string name = "");
    super.new(name);
  endfunction

endclass

`endif  // CFS_MD_ITEM_DRV_SV
