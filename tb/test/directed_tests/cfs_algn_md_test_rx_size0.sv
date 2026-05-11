///////////////////////////////////////////////////////////////////////////////
// File:        cfs_algn_md_test_rx_size0.sv
// Author:      Pranav
// Date:        2025-07-15
// Description: Test to send a single RX packet with size = 0
///////////////////////////////////////////////////////////////////////////////

`ifndef CFS_ALGN_MD_TEST_RX_SIZE0_SV
`define CFS_ALGN_MD_TEST_RX_SIZE0_SV

class cfs_algn_md_test_rx_size0 extends cfs_algn_test_base;

  `uvm_component_utils(cfs_algn_md_test_rx_size0)

  function new(string name = "", uvm_component parent = null);
    super.new(name, parent);
  endfunction

  virtual task run_phase(uvm_phase phase);

    cfs_md_sequence_slave_response_forever resp_seq;
    cfs_algn_virtual_sequence_reg_config cfg_seq;
    cfs_algn_virtual_sequence_rx_size0 rx_seq;

    uvm_status_e status;
    uvm_reg_data_t ctrl_val;

    phase.raise_objection(this, "TEST_START");

    #(100ns);

    // Step 0: Fork TX slave responder
    fork
      begin
        resp_seq = cfs_md_sequence_slave_response_forever::type_id::create("resp_seq");
        resp_seq.start(env.md_tx_agent.sequencer);
      end
    join_none

    // Step 1: Register configuration
    cfg_seq = cfs_algn_virtual_sequence_reg_config::type_id::create("cfg_seq");
    cfg_seq.set_sequencer(env.virtual_sequencer);
    cfg_seq.start(env.virtual_sequencer);

    // Step 2: Set CTRL to some valid non-zero value, e.g., size = 2, offset = 0
    env.model.reg_block.CTRL.write(status, 32'h00000002, UVM_FRONTDOOR);
    env.model.reg_block.CTRL.read(status, ctrl_val, UVM_FRONTDOOR);

    `uvm_info("rx_size0", $sformatf("CTRL register value: 0x%0h", ctrl_val), UVM_MEDIUM)

    // Step 3: Send RX packet with size = 0
    rx_seq = cfs_algn_virtual_sequence_rx_size0::type_id::create("rx_seq");
    rx_seq.set_sequencer(env.virtual_sequencer);
    void'(rx_seq.randomize());
    rx_seq.start(env.virtual_sequencer);

    #(200ns);

    phase.drop_objection(this, "TEST_DONE");

  endtask
endclass

`endif

