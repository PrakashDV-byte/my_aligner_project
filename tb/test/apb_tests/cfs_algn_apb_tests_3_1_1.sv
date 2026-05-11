///////////////////////////////////////////////////////////////////////////////
// File:        cfs_algn_apb_tests_3_1_1.sv
// Author:      Pranav
// Date:        2025-06-27
// Description: Test to validate IRQEN.MAX_DROP and CNT_DROP CLR functionality
///////////////////////////////////////////////////////////////////////////////

`ifndef CFS_ALGN_APB_TESTS_3_1_1_SV
`define CFS_ALGN_APB_TESTS_3_1_1_SV

class cfs_algn_apb_tests_3_1_1 extends cfs_algn_test_base;

  `uvm_component_utils(cfs_algn_apb_tests_3_1_1)

  function new(string name = "", uvm_component parent);
    super.new(name, parent);
  endfunction

  virtual task run_phase(uvm_phase phase);
    cfs_md_sequence_slave_response_forever resp_seq;
    cfs_algn_virtual_sequence_3_1_1 cfg_seq;
    cfs_algn_virtual_sequence_rx_err rx_err_seq1;
    cfs_algn_virtual_sequence_rx_err rx_err_seq2;
    cfs_algn_vif vif;
    uvm_status_e status;

    phase.raise_objection(this, "TEST_START");

    #(100ns);

    // Fork slave responder sequence
    fork
      begin
        resp_seq = cfs_md_sequence_slave_response_forever::type_id::create("resp_seq");
        resp_seq.start(env.md_tx_agent.sequencer);
      end
    join_none

    // Step 1: Configure IRQEN for MAX_DROP
    cfg_seq = cfs_algn_virtual_sequence_3_1_1::type_id::create("cfg_seq");
    cfg_seq.set_sequencer(env.virtual_sequencer);
    cfg_seq.start(env.virtual_sequencer);

    // Step 2: Wait before sending traffic
    vif = env.env_config.get_vif();
    repeat (50) @(posedge vif.clk);

    // Step 3: Send 10 illegal RX packets
    for (int i = 0; i < 255; i++) begin
      rx_err_seq1 =
          cfs_algn_virtual_sequence_rx_err::type_id::create($sformatf("rx_err_seq1_%0d", i));
      rx_err_seq1.set_sequencer(env.virtual_sequencer);
      void'(rx_err_seq1.randomize());
      rx_err_seq1.start(env.virtual_sequencer);
    end

    #(100ns);

    // Step 4: Write 0 to CLR (no effect expected)
    env.model.reg_block.CTRL.CLR.write(status, 0, UVM_FRONTDOOR);

    #(200ns);

    env.model.reg_block.CTRL.CLR.write(status, 1, UVM_FRONTDOOR);
    

    // Step 5: Send 10 more illegal RX packets
    for (int i = 0; i < 10; i++) begin
      rx_err_seq2 =
          cfs_algn_virtual_sequence_rx_err::type_id::create($sformatf("rx_err_seq2_%0d", i));
      rx_err_seq2.set_sequencer(env.virtual_sequencer);
      void'(rx_err_seq2.randomize());
      rx_err_seq2.start(env.virtual_sequencer);
    end

    #(200ns);

    // Step 6: Write 1 to CLR to reset CNT_DROP
    env.model.reg_block.CTRL.CLR.write(status, 1, UVM_FRONTDOOR);

    #(200ns);

    phase.drop_objection(this, "TEST_DONE");
  endtask

endclass

`endif

