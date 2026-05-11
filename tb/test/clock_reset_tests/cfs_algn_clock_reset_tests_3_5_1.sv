`ifndef CFS_ALGN_CLOCK_RESET_TESTS_3_5_1_SV
`define CFS_ALGN_CLOCK_RESET_TESTS_3_5_1_SV

class cfs_algn_clock_reset_tests_3_5_1 extends cfs_algn_test_base;

  `uvm_component_utils(cfs_algn_clock_reset_tests_3_5_1)

  function new(string name = "", uvm_component parent);
    super.new(name, parent);
  endfunction

  virtual task run_phase(uvm_phase phase);

    cfs_algn_virtual_sequence_reg_config cfg_seq;
    cfs_algn_virtual_sequence_rx_size1_offset0 rx_seq;
    cfs_md_sequence_tx_ready_block tx_block_seq;
    cfs_md_sequence_slave_response_forever tx_seq;
    uvm_reg_data_t ctrl_val, status_val, irq_val, irqen_val;

    virtual cfs_apb_if apb_vif;
    virtual cfs_algn_if algn_vif;

    uvm_status_e status;
    phase.raise_objection(this, "RESET_TEST");

    // Get APB interface handle from config_db
    if (!uvm_config_db#(virtual cfs_apb_if)::get(
            null, "uvm_test_top.env.apb_agent", "vif", apb_vif
        )) begin
      `uvm_fatal("RESET_TEST", "Failed to get APB interface from config DB")
    end

    if (!uvm_config_db#(virtual cfs_algn_if)::get(null, "uvm_test_top.env", "vif", algn_vif)) begin
      `uvm_fatal("RESET_TEST", "Failed to get aligner VIF from config DB")
    end

    #(100ns);

    // Step 0: Start slave responder to drain TX
    fork
      begin
        tx_block_seq = cfs_md_sequence_tx_ready_block::type_id::create("tx_block_seq");
        tx_block_seq.start(env.md_tx_agent.sequencer);
      end
    join_none

    // Step 1: Register configuration
    cfg_seq = cfs_algn_virtual_sequence_reg_config::type_id::create("cfg_seq");
    cfg_seq.set_sequencer(env.virtual_sequencer);
    cfg_seq.start(env.virtual_sequencer);
    env.model.reg_block.CTRL.write(status, 32'h00000001, UVM_FRONTDOOR);
    `uvm_info("3_3_9", "Configured CTRL.SIZE = 2, OFFSET = 0", UVM_MEDIUM)

    // Step 2: Send a few legal packets
    for (int i = 0; i < 12; i++) begin
      rx_seq = cfs_algn_virtual_sequence_rx_size1_offset0::type_id::create(
          $sformatf("rx_before_reset_%0d", i));
      rx_seq.set_sequencer(env.virtual_sequencer);
      void'(rx_seq.randomize());
      rx_seq.start(env.virtual_sequencer);
    end

    `uvm_info("RESET_TEST", "Mid-transaction reset is about to be applied...", UVM_MEDIUM)

    env.model.reg_block.CTRL.read(status, ctrl_val, UVM_FRONTDOOR);
    env.model.reg_block.STATUS.read(status, status_val, UVM_FRONTDOOR);
    env.model.reg_block.IRQEN.read(status, irqen_val, UVM_FRONTDOOR);
    env.model.reg_block.IRQ.read(status, irq_val, UVM_FRONTDOOR);

    // Step 3: Assert and deassert reset via APB interface
    apb_vif.preset_n = 0;
    #(400ns);
    apb_vif.preset_n = 1;
    `uvm_info("RESET_TEST", "Reset deasserted. Post-reset recovery starting...", UVM_MEDIUM)

    // Step 4: Wait for a few cycles and then send packets again
    repeat (5) @(posedge algn_vif.clk);
    env.model.reg_block.CTRL.read(status, ctrl_val, UVM_FRONTDOOR);
    env.model.reg_block.STATUS.read(status, status_val, UVM_FRONTDOOR);
    env.model.reg_block.IRQEN.read(status, irqen_val, UVM_FRONTDOOR);
    env.model.reg_block.IRQ.read(status, irq_val, UVM_FRONTDOOR);
    #(100ns);
    fork
      begin

        tx_seq = cfs_md_sequence_slave_response_forever::type_id::create("tx_seq");
        tx_seq.start(env.md_tx_agent.sequencer);
      end
    join_none

    for (int i = 0; i < 10; i++) begin
      rx_seq = cfs_algn_virtual_sequence_rx_size1_offset0::type_id::create(
          $sformatf("rx_after_reset_%0d", i));
      rx_seq.set_sequencer(env.virtual_sequencer);
      void'(rx_seq.randomize());
      rx_seq.start(env.virtual_sequencer);
    end

    #(300ns);
    phase.drop_objection(this, "RESET_TEST");

  endtask

endclass

`endif

