`ifndef CFS_MD_AGENT_CONFIG_SV
`define CFS_MD_AGENT_CONFIG_SV 

class cfs_md_agent_config #(
    int unsigned DATA_WIDTH = 32
) extends uvm_ext_agent_config #(
    .VIRTUAL_INTF(virtual cfs_md_if #(DATA_WIDTH))
);

  typedef virtual cfs_md_if #(DATA_WIDTH) cfs_md_vif;

  //Delay used when detecting start of an MD transaction in the monitor
  local time sample_delay_start_tr;

  //Number of clock cycles after which an MD transfer is considered
  //stuck and an error is triggered
  local int unsigned stuck_threshold;

  `uvm_component_param_utils(cfs_md_agent_config#(DATA_WIDTH))

  function new(string name = "", uvm_component parent);
    super.new(name, parent);

    sample_delay_start_tr = 1ns;
    stuck_threshold       = 1000;
  endfunction

  //Setter for the MD virtual interface
  virtual function void set_vif(cfs_md_vif value);
    super.set_vif(value);
    set_has_checks(get_has_checks());
  endfunction

  //Setter for the has_checks control field
  virtual function void set_has_checks(bit value);
    super.set_has_checks(value);

    if (vif != null) begin
      vif.has_checks = has_checks;
    end
  endfunction

  //Setter for sample_delay_start_tr_detection
  virtual function void set_sample_delay_start_tr(time value);
    sample_delay_start_tr = value;
  endfunction

  //Getter for sample_delay_start_tr_detection
  virtual function time get_sample_delay_start_tr();
    return sample_delay_start_tr;
  endfunction

  //Getter for the stuck threshold
  virtual function int unsigned get_stuck_threshold();
    return stuck_threshold;
  endfunction

  //Setter for stuck threshold
  virtual function void set_stuck_threshold(int unsigned value);
    stuck_threshold = value;
  endfunction

  virtual task run_phase(uvm_phase phase);
    forever begin
      @(vif.has_checks);

      if (vif.has_checks != get_has_checks()) begin
        `uvm_error(
            "ALGORITHM_ISSUE",
            $sformatf(
                "Can not change \"has_checks\" from MD interface directly - use %0s.set_has_checks()",
                get_full_name()))
      end
    end
  endtask

  //Task for waiting the reset to start
  virtual task wait_reset_start();
    if (vif.reset_n !== 0) begin
      @(negedge vif.reset_n);
    end
  endtask

  //Task for waiting the reset to be finished
  virtual task wait_reset_end();
    while (vif.reset_n == 0) begin
      @(posedge vif.clk);
    end
  endtask
endclass

`endif  // CFS_MD_AGENT_CONFIG_SV
