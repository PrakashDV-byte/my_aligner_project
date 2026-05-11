///////////////////////////////////////////////////////////////////////////////
// File:        cfs_algn_md_tests_3_2_4.sv
// Author:      Pranav
// Date:        2023-06-27
// Description: Test to verify the data storing capability of central controller
//              
///////////////////////////////////////////////////////////////////////////////

`ifndef CFS_ALGN_MD_TESTS_3_2_4_SV
`define CFS_ALGN_MD_TESTS_3_2_4_SV

class cfs_algn_md_tests_3_2_4 extends cfs_algn_test_base;

  `uvm_component_utils(cfs_algn_md_tests_3_2_4)

  function new(string name = "", uvm_component parent = null);
    super.new(name, parent);
  endfunction

  virtual task run_phase(uvm_phase phase);

    cfs_md_sequence_slave_response_forever resp_seq;
    cfs_algn_virtual_sequence_reg_config cfg_seq;
    cfs_algn_virtual_sequence_rx_size1_offset0 rx_seq;
    cfs_md_sequence_tx_ready_block tx_block_seq;

    cfs_algn_vif vif;
    uvm_reg_data_t ctrl_val;
    uvm_reg_data_t rx_lvl, tx_lvl;
    uvm_status_e status;

    phase.raise_objection(this, "TEST_START");

    #(100ns);

    // Step 0: Fork TX ready blocker
    fork
      begin
        tx_block_seq = cfs_md_sequence_tx_ready_block::type_id::create("tx_block_seq");
        tx_block_seq.start(env.md_tx_agent.sequencer);
      end
    join_none

    // Step 1: Register config
    cfg_seq = cfs_algn_virtual_sequence_reg_config::type_id::create("cfg_seq");
    cfg_seq.set_sequencer(env.virtual_sequencer);
    cfg_seq.start(env.virtual_sequencer);

    // Step 2: Manual CTRL config
    env.model.reg_block.CTRL.write(status, 32'h00000004, UVM_FRONTDOOR);
    env.model.reg_block.CTRL.read(status, ctrl_val, UVM_FRONTDOOR);
    `uvm_info("3_2_4", $sformatf("CTRL register value: 0x%0h", ctrl_val), UVM_MEDIUM)

    // Step 3: Wait post reset
    vif = env.env_config.get_vif();
    repeat (50) @(posedge vif.clk);

    // Step 4: Send 8 RX packets with SIZE=1 and OFFSET=0, delay 5 clks, read STATUS at each negedge
    for (int i = 0; i < 8; i++) begin
      rx_seq = cfs_algn_virtual_sequence_rx_size1_offset0::type_id::create($sformatf("rx_size1_%0d", i));
      rx_seq.set_sequencer(env.virtual_sequencer);
      void'(rx_seq.randomize());
      rx_seq.start(env.virtual_sequencer);

      repeat (5) @(posedge vif.clk);

      // Sample RX_LVL + TX_LVL at negedge
      @(negedge vif.clk);
      env.model.reg_block.STATUS.RX_LVL.read(status, rx_lvl, UVM_FRONTDOOR);
      env.model.reg_block.STATUS.TX_LVL.read(status, tx_lvl, UVM_FRONTDOOR);

      `uvm_info("3_2_4", $sformatf("RX_LVL = %0d, TX_LVL = %0d", rx_lvl, tx_lvl), UVM_MEDIUM)
    end

    #(200ns);

    phase.drop_objection(this, "TEST_DONE");
  endtask

endclass

`endif

