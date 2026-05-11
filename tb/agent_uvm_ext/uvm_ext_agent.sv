///////////////////////////////////////////////////////////////////////////////
// File:        uvm_ext_agent.sv
// Author:      Cristian Florin Slav
// Date:        2024-04-14
// Description: Generic agent class
///////////////////////////////////////////////////////////////////////////////
`ifndef UVM_EXT_AGENT_SV
`define UVM_EXT_AGENT_SV 

class uvm_ext_agent #(
    type VIRTUAL_INTF = int,
    type ITEM_MON = uvm_sequence_item,
    type ITEM_DRV = uvm_sequence_item
) extends uvm_agent implements uvm_ext_reset_handler;

  //Agent configuration handler
  uvm_ext_agent_config #(VIRTUAL_INTF) agent_config;

  //Monitor handler
  uvm_ext_monitor #(VIRTUAL_INTF, ITEM_MON) monitor;

  //Coverage handler
  uvm_ext_coverage #(VIRTUAL_INTF, ITEM_MON) coverage;

  //Driver handler
  uvm_ext_driver #(VIRTUAL_INTF, ITEM_DRV) driver;

  //Sequencer handler
  uvm_ext_sequencer #(ITEM_DRV) sequencer;

  `uvm_component_param_utils(uvm_ext_agent#(VIRTUAL_INTF, ITEM_MON, ITEM_DRV))

  function new(string name = "", uvm_component parent);
    super.new(name, parent);
  endfunction

  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);

    if (!uvm_config_db#(uvm_ext_agent_config#(VIRTUAL_INTF))::get(
            this, "", "agent_config", agent_config
        )) begin
      agent_config = uvm_ext_agent_config#(VIRTUAL_INTF)::type_id::create("agent_config", this);
    end

    monitor = uvm_ext_monitor#(VIRTUAL_INTF, ITEM_MON)::type_id::create("monitor", this);

    if (agent_config.get_has_coverage()) begin
      coverage = uvm_ext_coverage#(VIRTUAL_INTF, ITEM_MON)::type_id::create("coverage", this);
    end

    if (agent_config.get_active_passive() == UVM_ACTIVE) begin
      driver    = uvm_ext_driver#(VIRTUAL_INTF, ITEM_DRV)::type_id::create("driver", this);
      sequencer = uvm_ext_sequencer#(ITEM_DRV)::type_id::create("sequencer", this);
    end
  endfunction

  virtual function void connect_phase(uvm_phase phase);
    VIRTUAL_INTF vif;
    string       vif_name = "vif";

    super.connect_phase(phase);

    if (!uvm_config_db#(VIRTUAL_INTF)::get(this, "", vif_name, vif)) begin
      `uvm_fatal("NO_VIF",
                 $sformatf(
                     "Could not get from the database the virtual interface using name \"%0s\"",
                     vif_name))
    end else begin
      agent_config.set_vif(vif);
    end

    monitor.agent_config = agent_config;

    if (agent_config.get_has_coverage()) begin
      coverage.agent_config = agent_config;

      monitor.output_port.connect(coverage.port_item);
    end

    if (agent_config.get_active_passive() == UVM_ACTIVE) begin
      driver.seq_item_port.connect(sequencer.seq_item_export);

      driver.agent_config = agent_config;
    end
  endfunction

  //Task for waiting the reset to start
  protected virtual task wait_reset_start();
    agent_config.wait_reset_start();
  endtask

  //Task for waiting the reset to be finished
  protected virtual task wait_reset_end();
    agent_config.wait_reset_end();
  endtask

  //Function to handle the reset
  virtual function void handle_reset(uvm_phase phase);
    uvm_component children[$];

    get_children(children);

    foreach (children[idx]) begin
      uvm_ext_reset_handler reset_handler;

      if ($cast(reset_handler, children[idx])) begin
        reset_handler.handle_reset(phase);
      end
    end
  endfunction

  virtual task run_phase(uvm_phase phase);
    forever begin
      wait_reset_start();
      handle_reset(phase);
      wait_reset_end();
    end
  endtask

endclass

`endif

