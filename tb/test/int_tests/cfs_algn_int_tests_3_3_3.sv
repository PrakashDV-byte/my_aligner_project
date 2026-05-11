///////////////////////////////////////////////////////////////////////////////
// File:        cfs_algn_int_tests_3_3_3.sv
// Author:      Pranav
// Date:        2023-06-27
// Description: Test to verify the triggering of RX FIFO EMPTY interrupt
///////////////////////////////////////////////////////////////////////////////
`ifndef CFS_ALGN_INT_TESTS_3_3_3_SV
`define CFS_ALGN_INT_TESTS_3_3_3_SV

class cfs_algn_int_tests_3_3_3 extends cfs_algn_test_base;

  `uvm_component_utils(cfs_algn_int_tests_3_3_3)

  function new(string name = "", uvm_component parent);
    super.new(name, parent);
  endfunction

  virtual task run_phase(uvm_phase phase);

    cfs_md_sequence_tx_ready_block tx_block_seq;
    cfs_algn_virtual_sequence_reg_config cfg_seq;
    cfs_algn_virtual_sequence_rx_size1_offset0 rx_seq;

    cfs_algn_vif vif;
    uvm_status_e status;
    uvm_reg_data_t rx_lvl, tx_lvl;
    uvm_reg_data_t irqen_val;


    phase.raise_objection(this, "TEST_START");

    vif = env.env_config.get_vif();
    #(100ns);

    // Step 0: Block TX ready using ready block sequence
    fork
      begin
        tx_block_seq = cfs_md_sequence_tx_ready_block::type_id::create("tx_block_seq");
        tx_block_seq.start(env.md_tx_agent.sequencer);
      end
    join_none

    // Step 1: Basic register config
    cfg_seq = cfs_algn_virtual_sequence_reg_config::type_id::create("cfg_seq");
    cfg_seq.set_sequencer(env.virtual_sequencer);
    cfg_seq.start(env.virtual_sequencer);

    // Step 2: Manually configure CTRL.SIZE = 4, OFFSET = 0
    env.model.reg_block.CTRL.write(status, 32'h00000004, UVM_FRONTDOOR);
    `uvm_info("3_3_3", "Configured CTRL.SIZE = 4, OFFSET = 0", UVM_MEDIUM)
    env.model.reg_block.IRQEN.read(status, irqen_val, UVM_FRONTDOOR);
    irqen_val[0] = 1'b1;  // RX_FIFO_FULL
    env.model.reg_block.IRQEN.write(status, irqen_val, UVM_FRONTDOOR);
    `uvm_info("3_3_3", $sformatf("IRQEN configured: 0x%0h", irqen_val), UVM_MEDIUM)

    // Step 3: Send 2 RX packets with SIZE = 1, OFFSET = 0
    for (int i = 0; i < 8; i++) begin
      rx_seq =
          cfs_algn_virtual_sequence_rx_size1_offset0::type_id::create($sformatf("rx_seq_%0d", i));
      rx_seq.set_sequencer(env.virtual_sequencer);
      void'(rx_seq.randomize());
      rx_seq.start(env.virtual_sequencer);
    end

    // Step 4: Wait and then read FIFO levels
    #(200ns);

    env.model.reg_block.STATUS.read(status, rx_lvl, UVM_FRONTDOOR);
    env.model.reg_block.IRQ.write(status, 32'h00000001, UVM_FRONTDOOR);//Added to hit pwdata[0]=1 in expression coverage(irq_rx_fifo_empty & ~pwdata[0]) 


    //`uvm_info("3_3_3", $sformatf("RX_LVL = %0b", rx_lvl), UVM_MEDIUM)

    phase.drop_objection(this, "TEST_DONE");

  endtask

endclass

`endif

