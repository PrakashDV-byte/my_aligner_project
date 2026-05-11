`ifndef CFS_APB_MONITOR_SV
`define CFS_APB_MONITOR_SV

class cfs_apb_monitor extends uvm_ext_monitor #(
    .VIRTUAL_INTF(cfs_apb_vif),
    .ITEM_MON(cfs_apb_item_mon)
);

  cfs_apb_agent_config agent_config;

  `uvm_component_utils(cfs_apb_monitor)

  function new(string name = "", uvm_component parent);
    super.new(name, parent);
  endfunction

  virtual function void end_of_elaboration_phase(uvm_phase phase);
    super.end_of_elaboration_phase(phase);

    if ($cast(agent_config, super.agent_config) == 0) begin
      `uvm_fatal("ALGORITHM_ISSUE", $sformatf("Could not cast %0s to %0s",
                                              super.agent_config.get_type_name(),
                                              "cfs_apb_agent_config"))
    end
  endfunction

  protected virtual task collect_transaction();
    cfs_apb_vif vif = agent_config.get_vif();
    cfs_apb_item_mon item = cfs_apb_item_mon::type_id::create("item");

    while (vif.psel !== 1) begin
      @(posedge vif.pclk);
      item.prev_item_delay++;
    end

    item.addr   = vif.paddr;
    item.dir    = cfs_apb_dir'(vif.pwrite);
    item.length = 1;

    if (item.dir == CFS_APB_WRITE) begin
      item.data = vif.pwdata;
    end

    @(posedge vif.pclk);
    item.length++;

    while (vif.pready !== 1) begin
      @(posedge vif.pclk);
      item.length++;

      if (agent_config.get_has_checks()) begin
        if (item.length >= agent_config.get_stuck_threshold()) begin
          `uvm_error("PROTOCOL_ERROR",
                     $sformatf("The APB transfer reached the stuck threshold value of %0d",
                               item.length))
        end
      end
    end

    item.response = cfs_apb_response'(vif.pslverr);

    if (item.dir == CFS_APB_READ) begin
      item.data = vif.prdata;
    end

    output_port.write(item);

    `uvm_info("ITEM_END", $sformatf("Monitored item:: %0s", item.convert2string()), UVM_LOW)

    @(posedge vif.pclk);
  endtask

endclass

`endif  // CFS_APB_MONITOR_SV
