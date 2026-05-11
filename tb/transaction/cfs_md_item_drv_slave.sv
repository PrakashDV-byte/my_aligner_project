`ifndef CFS_MD_ITEM_DRV_SLAVE_SV
`define CFS_MD_ITEM_DRV_SLAVE_SV



class cfs_md_item_drv_slave extends cfs_md_item_drv;

  //Length, in clock cycles, of the item - this controls after how many cycles the "ready" signal will be high.
  //A value of 0 means that the MD item will be one clock cycle long.
  rand int unsigned length;

  //Response
  rand cfs_md_response response;

  //Value of 'ready' signal at the end of the MD item
  rand bit ready_at_end;

  constraint length_default {soft length <= 5;}

  `uvm_object_utils(cfs_md_item_drv_slave)

  function new(string name = "");
    super.new(name);
  endfunction

  virtual function string convert2string();
    return $sformatf("length: %0d, response: %0s, ready_at_end: %0d", length, response.name(),
                     ready_at_end);
  endfunction

endclass

`endif  // CFS_MD_ITEM_DRV_SLAVE_SV
