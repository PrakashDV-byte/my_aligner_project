///////////////////////////////////////////////////////////////////////////////
// File:        cfs_algn_int_tests_3_3_8.sv
// Author:      Pranav
// Date:        2023-06-27
// Description: Test to verify re triggering of IRQ bit
//           
///////////////////////////////////////////////////////////////////////////////
`ifndef CFS_ALGN_INT_TESTS_3_3_8_SV
`define CFS_ALGN_INT_TESTS_3_3_8_SV

class cfs_algn_int_tests_3_3_8 extends cfs_algn_test_base;

  `uvm_component_utils(cfs_algn_int_tests_3_3_8)

  function new(string name = "", uvm_component parent);
    super.new(name, parent);
  endfunction

  virtual task run_phase(uvm_phase phase);

    cfs_algn_virtual_sequence_reg_config   cfg_seq;
    cfs_algn_virtual_sequence_rx_err       rx_err_seq;
    cfs_md_sequence_slave_response_forever resp_seq;

    uvm_status_e                           status;
    uvm_reg_data_t irq_val, ctrl_val, irqen_val;
    virtual cfs_algn_if vif;

    phase.raise_objection(this, "TEST_START");

    vif = env.env_config.get_vif();
    #(100ns);

    // Step 0: Fork slave response forever before config
    fork
      begin
        resp_seq = cfs_md_sequence_slave_response_forever::type_id::create("resp_seq");
        resp_seq.start(env.md_tx_agent.sequencer);
      end
    join_none

    // Step 1: Apply register configuration
    cfg_seq = cfs_algn_virtual_sequence_reg_config::type_id::create("cfg_seq");
    cfg_seq.set_sequencer(env.virtual_sequencer);
    cfg_seq.start(env.virtual_sequencer);

    // Step 1.1: Manually set CTRL.SIZE = 1
    env.model.reg_block.CTRL.write(status, 32'h00000101, UVM_FRONTDOOR);

    // Step 1.2: Enable IRQEN.MAX_DROP bit [4]
    env.model.reg_block.IRQEN.read(status, irqen_val, UVM_FRONTDOOR);
    irqen_val = 32'h00000010;
    env.model.reg_block.IRQEN.write(status, irqen_val, UVM_FRONTDOOR);
    `uvm_info("3_3_8", $sformatf("IRQEN configured with MAX_DROP enabled: 0x%0h", irqen_val),
              UVM_MEDIUM)

    // Step 2: Send 255 illegal packets to reach CNT_DROP = 255
    for (int i = 0; i < 255; i++) begin
      rx_err_seq = cfs_algn_virtual_sequence_rx_err::type_id::create($sformatf("rx_err_1_%0d", i));
      rx_err_seq.set_sequencer(env.virtual_sequencer);
      void'(rx_err_seq.randomize());
      rx_err_seq.start(env.virtual_sequencer);
    end
    `uvm_info("3_3_8", "Sent 255 illegal packets to trigger IRQ.MAX_DROP", UVM_MEDIUM)

    // Step 3: Clear IRQ.MAX_DROP using APB write
    env.model.reg_block.IRQ.write(status, 32'h00000010, UVM_FRONTDOOR);  // Clear MAX_DROP bit [4]
    `uvm_info("3_3_8", "Cleared IRQ.MAX_DROP", UVM_MEDIUM)
    #(100ns);
    // Step 4: Clear CNT_DROP using CTRL.CLR = 1
    env.model.reg_block.CTRL.read(status, ctrl_val, UVM_FRONTDOOR);
    ctrl_val = 32'h00010101;  // Set CTRL.CLR (bit 16)
    env.model.reg_block.CTRL.write(status, ctrl_val, UVM_FRONTDOOR);
    `uvm_info("3_3_8", "Cleared CNT_DROP using CTRL.CLR", UVM_MEDIUM)

    // Step 5: Send another 255 illegal packets
    for (int i = 0; i < 255; i++) begin
      rx_err_seq = cfs_algn_virtual_sequence_rx_err::type_id::create($sformatf("rx_err_2_%0d", i));
      rx_err_seq.set_sequencer(env.virtual_sequencer);
      void'(rx_err_seq.randomize());
      rx_err_seq.start(env.virtual_sequencer);
    end
    `uvm_info("3_3_8", "Sent another 255 illegal packets post-clear", UVM_MEDIUM)

    // Step 6: Read IRQ to verify MAX_DROP is NOT re-triggered
    env.model.reg_block.IRQ.read(status, irq_val, UVM_FRONTDOOR);
    `uvm_info("3_3_8", $sformatf("IRQ = 0x%0h", irq_val), UVM_MEDIUM)

    if ((irq_val & 32'h10) != 0)
      `uvm_error("3_3_8", "IRQ.MAX_DROP was incorrectly reasserted after CNT_DROP was cleared")
    else `uvm_info("3_3_8", "PASS: IRQ.MAX_DROP not re-triggered as expected", UVM_LOW)

    #(200ns);
    phase.drop_objection(this, "TEST_DONE");

  endtask

endclass

`endif

