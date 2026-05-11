///////////////////////////////////////////////////////////////////////////////
// File:        cfs_algn_md_tests_3_2_2.sv
// Author:      Pranav
// Description: Test to verify interleaved legal and illegal RX packet handling
///////////////////////////////////////////////////////////////////////////////

`ifndef CFS_ALGN_MD_TESTS_3_2_2_SV
`define CFS_ALGN_MD_TESTS_3_2_2_SV

class cfs_algn_md_tests_3_2_2 extends cfs_algn_test_base;

  `uvm_component_utils(cfs_algn_md_tests_3_2_2)

  function new(string name = "", uvm_component parent = null);
    super.new(name, parent);
  endfunction

  virtual task run_phase(uvm_phase phase);

    cfs_md_sequence_slave_response_forever resp_seq;
    cfs_algn_virtual_sequence_reg_config cfg_seq;
    cfs_algn_virtual_sequence_rx_crt legal_seq;
    cfs_algn_virtual_sequence_rx_err illegal_seq;

    cfs_algn_vif vif;
    uvm_status_e       status;
    uvm_reg_data_t     ctrl_val;
    uvm_reg_data_t     reg_val;
    uvm_reg_field      cnt_drop_field;
    uvm_reg_data_t     cnt_drop_val;

    int legal_count   = 0;
    int illegal_count = 0;

    phase.raise_objection(this, "TEST_START");

    #(100ns);

    // Step 0: Start TX responder
    fork
      begin
        resp_seq = cfs_md_sequence_slave_response_forever::type_id::create("resp_seq");
        resp_seq.start(env.md_tx_agent.sequencer);
      end
    join_none

    // Step 1: Apply general register configuration
    cfg_seq = cfs_algn_virtual_sequence_reg_config::type_id::create("cfg_seq");
    cfg_seq.set_sequencer(env.virtual_sequencer);
    cfg_seq.start(env.virtual_sequencer);

    // Step 2: Set CTRL register manually (SIZE=4, OFFSET=0)
    env.model.reg_block.CTRL.write(status, 32'h00000004, UVM_FRONTDOOR);
    env.model.reg_block.CTRL.read(status, ctrl_val, UVM_FRONTDOOR);
    `uvm_info("3_2_2", $sformatf("CTRL register value: 0x%0h", ctrl_val), UVM_MEDIUM)

    // Step 3.1: Send 5 legal packets
    for (int i = 0; i < 5; i++) begin
      legal_seq = cfs_algn_virtual_sequence_rx_crt::type_id::create($sformatf("legal1_%0d", i));
      legal_seq.set_sequencer(env.virtual_sequencer);
      void'(legal_seq.randomize());
      legal_seq.start(env.virtual_sequencer);
      legal_count++;
    end

    #(100ns);

    // Step 3.2: Send 5 illegal packets
    for (int i = 0; i < 5; i++) begin
      illegal_seq = cfs_algn_virtual_sequence_rx_err::type_id::create($sformatf("illegal_%0d", i));
      illegal_seq.set_sequencer(env.virtual_sequencer);
      void'(illegal_seq.randomize());
      illegal_seq.start(env.virtual_sequencer);
      illegal_count++;
    end

    #(100ns);

    // Step 3.3: Send 5 more legal packets
    for (int i = 0; i < 5; i++) begin
      legal_seq = cfs_algn_virtual_sequence_rx_crt::type_id::create($sformatf("legal2_%0d", i));
      legal_seq.set_sequencer(env.virtual_sequencer);
      void'(legal_seq.randomize());
      legal_seq.start(env.virtual_sequencer);
      legal_count++;
    end

    #(500ns); // Let DUT process transactions

    // Step 4: Read and report CNT_DROP field from STATUS register
    env.model.reg_block.STATUS.read(status, reg_val, UVM_FRONTDOOR);
    cnt_drop_field = env.model.reg_block.STATUS.CNT_DROP;
    cnt_drop_val   = cnt_drop_field.get();

    `uvm_info("3_2_2", $sformatf("Total legal packets sent:   %0d", legal_count), UVM_MEDIUM)
    `uvm_info("3_2_2", $sformatf("Total illegal packets sent: %0d", illegal_count), UVM_MEDIUM)
    `uvm_info("3_2_2", $sformatf("CNT_DROP field value:       %0d", cnt_drop_val), UVM_MEDIUM)

    if (cnt_drop_val != illegal_count)
      `uvm_error("3_2_2", $sformatf("CNT_DROP mismatch! Expected %0d, got %0d",
                                     illegal_count, cnt_drop_val))

    #(200ns);

    phase.drop_objection(this, "TEST_DONE");
  endtask

endclass

`endif

