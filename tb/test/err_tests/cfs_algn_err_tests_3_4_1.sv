///////////////////////////////////////////////////////////////////////////////
// File:        cfs_algn_err_tests_3_4_1.sv
// Author:      Pranav
// Date:        2023-06-27
// Description: Test to verify design behaviour on sending one illegal packet.
//              
///////////////////////////////////////////////////////////////////////////////
`ifndef CFS_ALGN_ERR_TESTS_3_4_1_SV
`define CFS_ALGN_ERR_TESTS_3_4_1_SV

class cfs_algn_err_tests_3_4_1 extends cfs_algn_test_base;

  `uvm_component_utils(cfs_algn_err_tests_3_4_1)

  function new(string name = "", uvm_component parent = null);
    super.new(name, parent);
  endfunction

  virtual task run_phase(uvm_phase phase);

    cfs_algn_virtual_sequence_reg_config cfg_seq;
    cfs_algn_virtual_sequence_rx_err rx_err_seq;

    uvm_status_e status;
    uvm_reg_data_t irq_val, cnt_drop_val;

    virtual cfs_algn_if vif;

    phase.raise_objection(this, "TEST_START");

    vif = env.env_config.get_vif();
    #(100ns);

    // Step 1: Basic Register Configuration
    cfg_seq = cfs_algn_virtual_sequence_reg_config::type_id::create("cfg_seq");
    cfg_seq.set_sequencer(env.virtual_sequencer);
    cfg_seq.start(env.virtual_sequencer);

    // Step 2: Send one illegal RX packet
    rx_err_seq = cfs_algn_virtual_sequence_rx_err::type_id::create("rx_err_seq");
    rx_err_seq.set_sequencer(env.virtual_sequencer);
    void'(rx_err_seq.randomize());
    rx_err_seq.start(env.virtual_sequencer);
    `uvm_info("3_4_1", "Sent one illegal RX packet", UVM_MEDIUM)

    // Step 3: Wait and read STATUS and IRQ registers
    #(100ns);
    env.model.reg_block.IRQ.read(status, irq_val, UVM_FRONTDOOR);
    env.model.reg_block.STATUS.read(status, cnt_drop_val, UVM_FRONTDOOR);


    phase.drop_objection(this, "TEST_DONE");

  endtask

endclass

`endif

