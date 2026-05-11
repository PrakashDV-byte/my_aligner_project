`ifndef CFS_ALGN_CLOCK_RESET_DURING_APB_ACCESS_SV
`define CFS_ALGN_CLOCK_RESET_DURING_APB_ACCESS_SV

class cfs_algn_clock_reset_during_apb_access extends cfs_algn_test_base;

  `uvm_component_utils(cfs_algn_clock_reset_during_apb_access)

  function new(string name = "", uvm_component parent = null);
    super.new(name, parent);
  endfunction

  virtual task run_phase(uvm_phase phase);

    cfs_algn_virtual_sequence_reg_config cfg_seq;
    cfs_md_sequence_slave_response_forever tx_resp_seq;
    cfs_algn_virtual_sequence_rx_size1_offset0 rx_seq;
    cfs_apb_sequence_rw apb_seq;

    virtual cfs_apb_if apb_vif;
    virtual cfs_algn_if algn_vif;
    uvm_status_e status;

    phase.raise_objection(this, "RESET_DURING_APB");

    // Get interface handles
    if (!uvm_config_db#(virtual cfs_apb_if)::get(null, "uvm_test_top.env.apb_agent", "vif", apb_vif)) begin
      `uvm_fatal("RESET_TEST", "Failed to get APB interface")
    end

    if (!uvm_config_db#(virtual cfs_algn_if)::get(null, "uvm_test_top.env", "vif", algn_vif)) begin
      `uvm_fatal("RESET_TEST", "Failed to get Aligner interface")
    end

    #(100ns);

    // Step 0: Start responder to drain TX FIFO
    fork
      begin
        tx_resp_seq = cfs_md_sequence_slave_response_forever::type_id::create("tx_resp_seq");
        tx_resp_seq.start(env.md_tx_agent.sequencer);
      end
    join_none

    // Step 1: Register config via virtual sequence
    cfg_seq = cfs_algn_virtual_sequence_reg_config::type_id::create("cfg_seq");
    cfg_seq.set_sequencer(env.virtual_sequencer);
    cfg_seq.start(env.virtual_sequencer);

    // Step 2: Launch APB sequence and trigger reset during it
    
    fork
      begin : apb_txn
        apb_seq = cfs_apb_sequence_rw::type_id::create("apb_seq");
        apb_seq.set_sequencer(env.apb_agent.sequencer);
        apb_seq.start(env.apb_agent.sequencer);
        //  env.model.reg_block.CTRL.write(status, 32'h00000001, UVM_FRONTDOOR);
      end

      begin : mid_reset
        // Wait for APB transaction to be active
        @(posedge apb_vif.psel);
        #(5ns);
        `uvm_info("RESET_TEST", "psel=1 detected; triggering reset...", UVM_MEDIUM)

        // Assert reset during APB access
        apb_vif.preset_n = 0;
        #(200ns);
        apb_vif.preset_n = 1;

        `uvm_info("RESET_TEST", "Reset deasserted", UVM_MEDIUM)
      end
    join
      env.model.reg_block.CTRL.write(status, 32'h00000004, UVM_FRONTDOOR);

    // Step 3: Wait for recovery and send legal RX traffic
    repeat (5) @(posedge algn_vif.clk);
    #(100ns);

    for (int i = 0; i < 4; i++) begin
      rx_seq = cfs_algn_virtual_sequence_rx_size1_offset0::type_id::create($sformatf("rx_post_%0d", i));
      rx_seq.set_sequencer(env.virtual_sequencer);
      void'(rx_seq.randomize());
      rx_seq.start(env.virtual_sequencer);
    end

    #(300ns);
    phase.drop_objection(this, "RESET_DURING_APB");

  endtask

endclass

`endif

