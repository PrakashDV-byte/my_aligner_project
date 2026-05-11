`ifndef CFS_MD_AGENT_MASTER_SV
`define CFS_MD_AGENT_MASTER_SV 

class cfs_md_agent_master #(
    int unsigned DATA_WIDTH = 32
) extends cfs_md_agent #(DATA_WIDTH, cfs_md_item_drv_master);

  `uvm_component_param_utils(cfs_md_agent_master#(DATA_WIDTH))

  function new(string name = "", uvm_component parent);
    super.new(name, parent);

    cfs_md_agent_config#(DATA_WIDTH)::type_id::set_inst_override(
        cfs_md_agent_config_master#(DATA_WIDTH)::get_type(), "agent_config", this);
    cfs_md_driver#(DATA_WIDTH, cfs_md_item_drv_master)::type_id::set_inst_override(
        cfs_md_driver_master#(DATA_WIDTH)::get_type(), "driver", this);
    cfs_md_sequencer_base#(cfs_md_item_drv_master)::type_id::set_inst_override(
        cfs_md_sequencer_master#(DATA_WIDTH)::get_type(), "sequencer", this);
  endfunction

endclass

`endif  // CFS_MD_AGENT_MASTER_SV
