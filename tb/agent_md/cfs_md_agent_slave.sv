`ifndef CFS_MD_AGENT_SLAVE_SV
`define CFS_MD_AGENT_SLAVE_SV 

class cfs_md_agent_slave #(
    int unsigned DATA_WIDTH = 32
) extends cfs_md_agent #(DATA_WIDTH, cfs_md_item_drv_slave);

  `uvm_component_param_utils(cfs_md_agent_slave#(DATA_WIDTH))

  function new(string name = "", uvm_component parent);
    super.new(name, parent);

    cfs_md_agent_config#(DATA_WIDTH)::type_id::set_inst_override(
        cfs_md_agent_config_slave#(DATA_WIDTH)::get_type(), "agent_config", this);
    cfs_md_driver#(DATA_WIDTH, cfs_md_item_drv_slave)::type_id::set_inst_override(
        cfs_md_driver_slave#(DATA_WIDTH)::get_type(), "driver", this);
    cfs_md_sequencer_base#(cfs_md_item_drv_slave)::type_id::set_inst_override(
        cfs_md_sequencer_slave#(DATA_WIDTH)::get_type(), "sequencer", this);
  endfunction

  virtual function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);

    connect_port_from_mon_to_slave_seqr();
  endfunction

  //Function to connect port_from_mon_to_slave_seqr of the sequencer to the output_port of the monitor.
  //This allows future extensions of the agent to avoid using this mechanism to drive items on the bus.
  protected virtual function void connect_port_from_mon_to_slave_seqr();
    if (agent_config.get_active_passive() == UVM_ACTIVE) begin
      cfs_md_sequencer_slave #(DATA_WIDTH) sequencer;

      if ($cast(sequencer, super.sequencer) == 0) begin
        `uvm_fatal("ALGORITHM_ISSUE",
                   $sformatf("Could not cast %0s to %0s", super.sequencer.get_full_name(),
                             cfs_md_sequencer_slave#(DATA_WIDTH)::type_id::type_name))
      end

      monitor.output_port.connect(sequencer.port_from_mon);
    end
  endfunction

endclass

`endif  // CFS_MD_AGENT_SLAVE_SV
