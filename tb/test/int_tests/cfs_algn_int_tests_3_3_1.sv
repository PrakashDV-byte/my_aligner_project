///////////////////////////////////////////////////////////////////////////////
// File:        cfs_algn_int_tests_3_3_1.sv
// Author:      Pranav
// Date:        2023-06-27
// Description: Test to verify triggering of MAX DROP interrupt
//              
///////////////////////////////////////////////////////////////////////////////
`ifndef CFS_ALGN_INT_TESTS_3_3_1_SV
`define CFS_ALGN_INT_TESTS_3_3_1_SV

class cfs_algn_int_tests_3_3_1 extends cfs_algn_test_base;

  `uvm_component_utils(cfs_algn_int_tests_3_3_1)

  function new(string name = "", uvm_component parent);
    super.new(name, parent);
  endfunction

  virtual task run_phase(uvm_phase phase);

    cfs_algn_virtual_sequence_reg_config cfg_seq;
    cfs_algn_virtual_sequence_rx_err     rx_err_seq;

    virtual cfs_algn_if                  vif;

    uvm_status_e                         status;
    uvm_reg_data_t                       irqen_val;
    uvm_reg_data_t                       irq_val;
    uvm_reg_data_t                       cnt_drop_val;

    phase.raise_objection(this, "TEST_START");

    vif = env.env_config.get_vif();
    #(100ns);

    // Step 1: Basic Register Config
    cfg_seq = cfs_algn_virtual_sequence_reg_config::type_id::create("cfg_seq");
    cfg_seq.set_sequencer(env.virtual_sequencer);
    cfg_seq.start(env.virtual_sequencer);

    // Step 2: Enable IRQEN.CNT_DROP (bit 4)
    env.model.reg_block.IRQEN.read(status, irqen_val, UVM_FRONTDOOR);
    irqen_val[4] = 1'b0;
    env.model.reg_block.IRQEN.write(status, irqen_val, UVM_FRONTDOOR);
    `uvm_info("3_3_1", $sformatf("IRQEN updated: 0x%0h", irqen_val), UVM_MEDIUM)

    // Step 3: Send 255 illegal RX packets
    for (int i = 0; i < 255; i++) begin
      rx_err_seq =
          cfs_algn_virtual_sequence_rx_err::type_id::create($sformatf("rx_err_seq_%0d", i));
      rx_err_seq.set_sequencer(env.virtual_sequencer);
      void'(rx_err_seq.randomize());
      rx_err_seq.start(env.virtual_sequencer);
    end

    `uvm_info("3_3_1", "Sent 255 illegal RX packets. Expecting CNT_DROP interrupt.", UVM_MEDIUM)

    // Step 4: Wait & check if IRQ.CNT_DROP is triggered
    #(100ns);
    env.model.reg_block.IRQ.read(status, irq_val, UVM_FRONTDOOR);
    // `uvm_info("3_3_1", $sformatf("IRQ reg: 0x%0h", irq_val), UVM_MEDIUM)

    // Step 5: Read CNT_DROP field from STATUS register
    env.model.reg_block.STATUS.read(status, cnt_drop_val, UVM_FRONTDOOR);
    //   `uvm_info("3_3_1", $sformatf("CNT_DROP after 255 illegal packets: %0d", cnt_drop_val[7:0]), UVM_MEDIUM)

    #(200ns);
    phase.drop_objection(this, "TEST_DONE");

  endtask

endclass

`endif

