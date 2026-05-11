///////////////////////////////////////////////////////////////////////////////
// File:        cfs_algn_int_tests_3_3_6.sv
// Author:      Pranav
// Date:        2023-06-27
// Description: Test to verify the design behaviour when multiple simultaneous
//              interrupts occur.
///////////////////////////////////////////////////////////////////////////////
`ifndef CFS_ALGN_INT_TESTS_3_3_6_SV
`define CFS_ALGN_INT_TESTS_3_3_6_SV

class cfs_algn_int_tests_3_3_6 extends cfs_algn_test_base;

  `uvm_component_utils(cfs_algn_int_tests_3_3_6)

  function new(string name = "", uvm_component parent);
    super.new(name, parent);
  endfunction

  virtual task run_phase(uvm_phase phase);

    cfs_algn_virtual_sequence_reg_config   cfg_seq;
    cfs_md_sequence_length_4               tx_block_seq;
    cfs_md_sequence_slave_response_forever tx_unblock_seq;
    cfs_md_sequence_fixed_delay            rx_delay_seq;

    virtual cfs_algn_if                    vif;
    uvm_status_e                           status;

    phase.raise_objection(this, "TEST_START");

    vif = env.env_config.get_vif();

    #(100ns);  // Now this comes AFTER all declarations
    // Step 0: Block TX side with a 4-byte transaction
    fork
      begin
        tx_block_seq = cfs_md_sequence_length_4::type_id::create("tx_block_seq");
        tx_block_seq.start(env.md_tx_agent.sequencer);
      end
    join_none

    // Step 1: Configure registers (CTRL.SIZE = 2, OFFSET = 0)
    cfg_seq = cfs_algn_virtual_sequence_reg_config::type_id::create("cfg_seq");
    cfg_seq.set_sequencer(env.virtual_sequencer);
    cfg_seq.start(env.virtual_sequencer);

    env.model.reg_block.CTRL.write(status, 32'h00000002, UVM_FRONTDOOR);
    `uvm_info("3_3_9", "Configured CTRL.SIZE = 2, OFFSET = 0", UVM_MEDIUM)

    // Step 2: Send 2 RX packets with pre/post delays = 1
    for (int i = 0; i < 4; i++) begin
      rx_delay_seq = cfs_md_sequence_fixed_delay::type_id::create($sformatf("rx_delay_seq_%0d", i));
      rx_delay_seq.start(env.md_rx_agent.sequencer);
    end

    `uvm_info("3_3_9", "2 RX packets sent with fixed delays", UVM_MEDIUM)

    // Step 3: Wait and then unblock TX ready


    fork
      begin
        tx_unblock_seq = cfs_md_sequence_slave_response_forever::type_id::create("tx_unblock_seq");
        tx_unblock_seq.start(env.md_tx_agent.sequencer);
      end
    join_none
    #(300ns);

    `uvm_info("3_3_9", "TX unblocked, ready to consume data", UVM_MEDIUM)

    #(500ns);

    phase.drop_objection(this, "TEST_DONE");

  endtask

endclass

`endif

