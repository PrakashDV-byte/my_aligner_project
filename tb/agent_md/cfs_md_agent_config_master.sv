`ifndef CFS_MD_AGENT_CONFIG_MASTER_SV
`define CFS_MD_AGENT_CONFIG_MASTER_SV 

class cfs_md_agent_config_master #(
    int unsigned DATA_WIDTH = 32
) extends cfs_md_agent_config #(DATA_WIDTH);

  `uvm_component_param_utils(cfs_md_agent_config_master#(DATA_WIDTH))

  function new(string name = "", uvm_component parent);
    super.new(name, parent);
  endfunction

endclass

`endif  // CFS_MD_AGENT_CONFIG_MASTER_SV
