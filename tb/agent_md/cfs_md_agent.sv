`ifndef CFS_MD_AGENT_SV
`define CFS_MD_AGENT_SV

class cfs_md_agent#(int unsigned DATA_WIDTH = 32, type ITEM_DRV = cfs_md_item_drv) extends uvm_ext_agent#(.VIRTUAL_INTF(virtual cfs_md_if#(DATA_WIDTH)), .ITEM_MON(cfs_md_item_mon), .ITEM_DRV(ITEM_DRV));
    
                                 typedef virtual cfs_md_if#(DATA_WIDTH) cfs_md_vif;

  `uvm_component_param_utils(cfs_md_agent#(DATA_WIDTH, ITEM_DRV))

  function new(string name = "", uvm_component parent);
    super.new(name, parent);

    uvm_ext_agent_config#(.VIRTUAL_INTF(cfs_md_vif))::type_id::set_inst_override(cfs_md_agent_config#(DATA_WIDTH)::get_type(), "agent_config", this);
    uvm_ext_monitor#(.VIRTUAL_INTF(cfs_md_vif), .ITEM_MON(cfs_md_item_mon))::type_id::set_inst_override(cfs_md_monitor#(DATA_WIDTH)::get_type(), "monitor", this);
    uvm_ext_coverage#(.VIRTUAL_INTF(cfs_md_vif), .ITEM_MON(cfs_md_item_mon))::type_id::set_inst_override(cfs_md_coverage#(DATA_WIDTH)::get_type(), "coverage", this);
    uvm_ext_driver#(.VIRTUAL_INTF(cfs_md_vif), .ITEM_DRV(ITEM_DRV))::type_id::set_inst_override(cfs_md_driver#(DATA_WIDTH, ITEM_DRV)::get_type(), "driver", this);
    uvm_ext_sequencer#(.ITEM_DRV(ITEM_DRV))::type_id::set_inst_override(cfs_md_sequencer_base#(ITEM_DRV)::get_type(), "sequencer", this);
  endfunction

endclass

`endif // CFS_MD_AGENT_SV
