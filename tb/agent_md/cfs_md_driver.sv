`ifndef CFS_MD_DRIVER_SV
`define CFS_MD_DRIVER_SV 

class cfs_md_driver #(
    int unsigned DATA_WIDTH = 32,
    type ITEM_DRV = cfs_md_item_drv
) extends uvm_ext_driver #(
    .VIRTUAL_INTF(virtual cfs_md_if #(DATA_WIDTH)),
    .ITEM_DRV(ITEM_DRV)
);

  //Pointer to agent configuration
  cfs_md_agent_config #(DATA_WIDTH) agent_config;

  `uvm_component_param_utils(cfs_md_driver#(DATA_WIDTH, ITEM_DRV))

  function new(string name = "", uvm_component parent);
    super.new(name, parent);
  endfunction

  virtual function void end_of_elaboration_phase(uvm_phase phase);
    super.end_of_elaboration_phase(phase);

    if ($cast(agent_config, super.agent_config) == 0) begin
      `uvm_fatal("ALGORITHM_ISSUE",
                 $sformatf("Could not cast %0s to %0s", super.agent_config.get_type_name(),
                           cfs_md_agent_config#(DATA_WIDTH)::type_id::type_name))
    end
  endfunction

endclass

`endif  // CFS_MD_DRIVER_SV
