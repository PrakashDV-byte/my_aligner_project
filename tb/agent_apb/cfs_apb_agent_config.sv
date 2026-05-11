`ifndef CFS_APB_AGENT_CONFIG_SV
`define CFS_APB_AGENT_CONFIG_SV



class cfs_apb_agent_config extends uvm_ext_agent_config #(
    .VIRTUAL_INTF(cfs_apb_vif)
);

  local int unsigned stuck_threshold;

  `uvm_component_utils(cfs_apb_agent_config)

  function new(string name = "", uvm_component parent);
    super.new(name, parent);
    stuck_threshold = 1000;
  endfunction

  virtual function void set_vif(cfs_apb_vif value);
    super.set_vif(value);
    set_has_checks(get_has_checks());
  endfunction

  virtual function void set_has_checks(bit value);
    super.set_has_checks(value);

    if (vif != null) begin
      vif.has_checks = has_checks;
    end
  endfunction

  virtual function int unsigned get_stuck_threshold();
    return stuck_threshold;
  endfunction

  virtual function void set_stuck_threshold(int unsigned value);
    if (value <= 2) begin
      `uvm_error(
          "ALGORITHM_ISSUE",
          $sformatf(
              "Tried to set stuck_threshold to value %d but the minimum length of an APB transfer is 2",
              value))
    end
    stuck_threshold = value;
  endfunction

  virtual task run_phase(uvm_phase phase);
    forever begin
      @(vif.has_checks);

      if (vif.has_checks != get_has_checks()) begin
        `uvm_error(
            "ALGORITHM_ISSUE",
            $sformatf(
                "Can not change \"has_checks\" from APB interface directly - use %0s.set_has_checks()",
                get_full_name()))
      end
    end
  endtask

  virtual task wait_reset_start();
    if (vif.preset_n !== 0) begin
      @(negedge vif.preset_n);
    end
  endtask

  virtual task wait_reset_end();
    while (vif.preset_n == 0) begin
      @(posedge vif.pclk);
    end
  endtask

endclass

`endif  // CFS_APB_AGENT_CONFIG_SV
