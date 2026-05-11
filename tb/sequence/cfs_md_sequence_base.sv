`ifndef CFS_MD_SEQUENCE_BASE_SV
`define CFS_MD_SEQUENCE_BASE_SV 

class cfs_md_sequence_base #(
    type ITEM_DRV = cfs_md_item_drv
) extends uvm_sequence #(
    .REQ(ITEM_DRV)
);

  `uvm_object_param_utils(cfs_md_sequence_base#(ITEM_DRV))

  function new(string name = "");
    super.new(name);
  endfunction

endclass

`endif  // CFS_MD_SEQUENCE_BASE_SV
