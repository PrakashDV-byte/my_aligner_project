`ifndef CFS_APB_AGENT_SV
`define CFS_APB_AGENT_SV


class cfs_apb_agent extends uvm_ext_agent#(.VIRTUAL_INTF(cfs_apb_vif), .ITEM_MON(cfs_apb_item_mon), .ITEM_DRV(cfs_apb_item_drv));

  `uvm_component_utils(cfs_apb_agent)

  function new(string name = "", uvm_component parent);
  super.new(name, parent);

  // Corrected overrides using proper uvm_object_wrapper type
  uvm_ext_agent_config#(.VIRTUAL_INTF(cfs_apb_vif))::type_id::
    set_inst_override(cfs_apb_agent_config::get_type(), "agent_config", this);

  uvm_ext_monitor#(.VIRTUAL_INTF(cfs_apb_vif), .ITEM_MON(cfs_apb_item_mon))::type_id::
    set_inst_override(cfs_apb_monitor::get_type(), "monitor", this);

  uvm_ext_coverage#(.VIRTUAL_INTF(cfs_apb_vif), .ITEM_MON(cfs_apb_item_mon))::type_id::
    set_inst_override(cfs_apb_coverage::get_type(), "coverage", this);

  uvm_ext_driver#(.VIRTUAL_INTF(cfs_apb_vif), .ITEM_DRV(cfs_apb_item_drv))::type_id::
    set_inst_override(cfs_apb_driver::get_type(), "driver", this);
endfunction


endclass

`endif // CFS_APB_AGENT_SV
