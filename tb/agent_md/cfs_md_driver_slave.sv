`ifndef CFS_MD_DRIVER_SLAVE_SV
`define CFS_MD_DRIVER_SLAVE_SV 


class cfs_md_driver_slave #(
    int unsigned DATA_WIDTH = 32
) extends cfs_md_driver #(
    .DATA_WIDTH(DATA_WIDTH),
    .ITEM_DRV  (cfs_md_item_drv_slave)
);

  //Pointer to the agent configuration component
  cfs_md_agent_config_slave #(DATA_WIDTH) agent_config;

  typedef virtual cfs_md_if #(DATA_WIDTH) cfs_md_vif;

  `uvm_component_param_utils(cfs_md_driver_slave#(DATA_WIDTH))

  function new(string name = "", uvm_component parent);
    super.new(name, parent);
  endfunction

  virtual function void end_of_elaboration_phase(uvm_phase phase);
    super.end_of_elaboration_phase(phase);

    if (super.agent_config == null) begin
      `uvm_fatal("ALGORITHM_ISSUE",
                 $sformatf("At this point the pointer to agent_config from %0s should not be null",
                           get_full_name()))
    end

    if ($cast(agent_config, super.agent_config) == 0) begin
      `uvm_fatal("ALGORITHM_ISSUE",
                 $sformatf("Could not cast %0s to %0s", super.agent_config.get_full_name(),
                           cfs_md_agent_config_slave#(DATA_WIDTH)::type_id::type_name))
    end

  endfunction

  //Task which drives one single item on the bus
  protected virtual task drive_transaction(cfs_md_item_drv_slave item);

    cfs_md_vif vif = agent_config.get_vif();

    `uvm_info("ITEM_START", $sformatf("Driving \"%0s\": %0s", item.get_full_name(),
                                      item.convert2string()), UVM_LOW)

    if (vif.valid !== 1) begin
      `uvm_error(
          "ALGORITHM_ISSUE",
          $sformatf(
              "Trying to drive a slave item when there is no item started by the master - item: %0s",
              item.convert2string()))
    end

    vif.ready <= 0;

    for (int i = 0; i < item.length; i++) begin
      @(posedge vif.clk);
    end

    vif.ready <= 1;
    vif.err   <= bit'(item.response);

    @(posedge vif.clk);

    vif.ready <= item.ready_at_end;
    vif.err   <= 0;
  endtask

  //Function to handle the reset
  virtual function void handle_reset(uvm_phase phase);
    cfs_md_vif vif = agent_config.get_vif();

    super.handle_reset(phase);

    vif.ready <= agent_config.get_ready_at_reset();
    vif.err   <= 0;

  endfunction

endclass

`endif  // CFS_MD_DRIVER_SLAVE_SV
