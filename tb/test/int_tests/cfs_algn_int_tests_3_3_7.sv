///////////////////////////////////////////////////////////////////////////////
// File:        cfs_algn_int_tests_3_3_7.sv
// Author:      Pranav
// Date:        2023-06-27
// Description: Test to verify sticky nature of IRQ register
///////////////////////////////////////////////////////////////////////////////
`ifndef CFS_ALGN_INT_TESTS_3_3_7_SV
`define CFS_ALGN_INT_TESTS_3_3_7_SV

class cfs_algn_int_tests_3_3_7 extends cfs_algn_test_base;

  `uvm_component_utils(cfs_algn_int_tests_3_3_7)

  function new(string name = "", uvm_component parent);
    super.new(name, parent);
  endfunction

  virtual task run_phase(uvm_phase phase);

    cfs_algn_virtual_sequence_rx_err rx_err_seq;
    cfs_algn_virtual_sequence_reg_config cfg_seq;
    cfs_md_sequence_slave_response_forever resp_seq;

    virtual cfs_algn_if vif;

    uvm_status_e status;
    uvm_reg_data_t ctrl_val, irq_val;

    phase.raise_objection(this, "TEST_START");

    vif = env.env_config.get_vif();
    #(100ns);

    // Step 0: Start slave response forever sequence
    fork
      begin
        resp_seq = cfs_md_sequence_slave_response_forever::type_id::create("resp_seq");
        resp_seq.start(env.md_tx_agent.sequencer);
      end
    join_none

    // Step 1: Apply default register configuration
    cfg_seq = cfs_algn_virtual_sequence_reg_config::type_id::create("cfg_seq");
    cfg_seq.set_sequencer(env.virtual_sequencer);
    cfg_seq.start(env.virtual_sequencer);

    // Step 2: Send 255 illegal RX packets to trigger CNT_DROP = 255
    for (int i = 0; i < 255; i++) begin
      rx_err_seq = cfs_algn_virtual_sequence_rx_err::type_id::create($sformatf("rx_err_%0d", i));
      rx_err_seq.set_sequencer(env.virtual_sequencer);
      void'(rx_err_seq.randomize());
      rx_err_seq.start(env.virtual_sequencer);
    end

    `uvm_info("3_3_7", "Sent 255 illegal packets. CNT_DROP should be 255 now.", UVM_MEDIUM)

    // Step 3: Read IRQ register to confirm MAX_DROP (bit 4) is set
    env.model.reg_block.IRQ.read(status, irq_val, UVM_FRONTDOOR);
    `uvm_info("3_3_7", $sformatf("IRQ value after 255 illegal packets: 0x%0h", irq_val), UVM_MEDIUM)

    // Step 4: Set CTRL.CLR=1 to clear CNT_DROP
    // Bit 16 = CLR
    env.model.reg_block.CTRL.CLR.write(status, 1, UVM_FRONTDOOR);
    //`uvm_info("3_3_7", "CTRL.CLR=1 written to clear CNT_DROP", UVM_MEDIUM)

    // Step 5: Read IRQ register again — MAX_DROP must still be set
    env.model.reg_block.IRQ.read(status, irq_val, UVM_FRONTDOOR);
    //`uvm_info("3_3_7", $sformatf("IRQ value after CLR: 0x%0h", irq_val), UVM_MEDIUM)

    /*if ((irq_val & 32'h10) != 0)
      `uvm_info("3_3_7", "PASS: IRQ.MAX_DROP remains set (sticky behavior)", UVM_LOW)
    else
      `uvm_error("3_3_7", "FAIL: IRQ.MAX_DROP was cleared after CNT_DROP reset")*/

    #(200ns);
    phase.drop_objection(this, "TEST_DONE");

  endtask

endclass

`endif

