///////////////////////////////////////////////////////////////////////////////
// File:        cfs_algn_int_tests_3_3_5.sv
// Author:      Pranav
// Date:        2023-06-27
// Description: Test to verify the triggering of TX FIFO EMPTY interrupt
///////////////////////////////////////////////////////////////////////////////
`ifndef CFS_ALGN_INT_TESTS_3_3_5_SV
`define CFS_ALGN_INT_TESTS_3_3_5_SV

class cfs_algn_int_tests_3_3_5 extends cfs_algn_test_base;

  `uvm_component_utils(cfs_algn_int_tests_3_3_5)

  function new(string name = "", uvm_component parent);
    super.new(name, parent);
  endfunction

  virtual task run_phase(uvm_phase phase);

    cfs_md_sequence_slave_response_forever resp_seq;
    cfs_algn_virtual_sequence_reg_config cfg_seq;
    cfs_algn_virtual_sequence_rx_size1_offset0 rx_seq;

    cfs_algn_vif vif;
    uvm_status_e status;
    uvm_reg_data_t status_reg, irqen_val;


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

    // Step 1: Apply basic register config
    cfg_seq = cfs_algn_virtual_sequence_reg_config::type_id::create("cfg_seq");
    cfg_seq.set_sequencer(env.virtual_sequencer);
    cfg_seq.start(env.virtual_sequencer);

    // Step 2: Configure CTRL.SIZE = 4 and OFFSET = 0
    env.model.reg_block.CTRL.write(status, 32'h00000004, UVM_FRONTDOOR);
    `uvm_info("3_3_5", "Configured CTRL.SIZE = 4, OFFSET = 0", UVM_MEDIUM)

    env.model.reg_block.IRQEN.read(status, irqen_val, UVM_FRONTDOOR);
    irqen_val[2] = 1'b1;  // RX_FIFO_FULL
    env.model.reg_block.IRQEN.write(status, irqen_val, UVM_FRONTDOOR);
    `uvm_info("3_3_3", $sformatf("IRQEN configured: 0x%0h", irqen_val), UVM_MEDIUM)

    // Step 3: Send 8 RX packets with SIZE = 1, OFFSET = 0
    for (int i = 0; i < 8; i++) begin
      rx_seq =
          cfs_algn_virtual_sequence_rx_size1_offset0::type_id::create($sformatf("rx_seq_%0d", i));
      rx_seq.set_sequencer(env.virtual_sequencer);
      void'(rx_seq.randomize());
      rx_seq.start(env.virtual_sequencer);
    end

    // Step 4: Wait and read FIFO level from STATUS
    #(200ns);
    env.model.reg_block.STATUS.read(status, status_reg, UVM_FRONTDOOR);
    env.model.reg_block.IRQ.write(status, 32'h00000004, UVM_FRONTDOOR);//Added to hit pwdata[2]=1 in expression coverage(irq_tx_fifo_empty & ~pwdata[2]) 
    // rx_lvl_int = int'((status_reg >> 8) & 4'hF);  // Extract RX_LVL from bits [11:8]
    
    

    //`uvm_info("3_3_5", $sformatf("RX_LVL = %0d (from STATUS: 0x%0h)", rx_lvl_int, status_reg), UVM_MEDIUM)

    phase.drop_objection(this, "TEST_DONE");

  endtask

endclass

`endif

