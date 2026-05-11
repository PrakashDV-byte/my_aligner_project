///////////////////////////////////////////////////////////////////////////////
// File:        cfs_algn_int_tests_3_3_2_1.sv
// Author:      Pranav
// Date:        2023-06-27
// Description: Test to hit the expression (irq_rx_fifo_full & ~pwdata[1]) 
//              in expression coverage of reg instance
///////////////////////////////////////////////////////////////////////////////
`ifndef CFS_ALGN_INT_TESTS_3_3_2_1_SV
`define CFS_ALGN_INT_TESTS_3_3_2_1_SV

class cfs_algn_int_tests_3_3_2_1 extends cfs_algn_test_base;

  `uvm_component_utils(cfs_algn_int_tests_3_3_2_1)

  function new(string name = "", uvm_component parent);
    super.new(name, parent);
  endfunction

  virtual task run_phase(uvm_phase phase);

    cfs_algn_virtual_sequence_reg_config cfg_seq;
    cfs_algn_virtual_sequence_rx_size1_offset0 rx_seq;
    cfs_md_sequence_tx_ready_block tx_block_seq;

    virtual cfs_algn_if vif;

    uvm_status_e status;
    uvm_reg_data_t irqen_val;
    uvm_reg_data_t status_val;

    phase.raise_objection(this, "TEST_START");

    vif = env.env_config.get_vif();
    #(100ns);

    // Step 0: Block md_tx_ready using tx_ready_block sequence
    fork
      begin
        tx_block_seq = cfs_md_sequence_tx_ready_block::type_id::create("tx_block_seq");
        tx_block_seq.start(env.md_tx_agent.sequencer);
      end
    join_none

    // Step 1: Apply basic register configuration
    cfg_seq = cfs_algn_virtual_sequence_reg_config::type_id::create("cfg_seq");
    cfg_seq.set_sequencer(env.virtual_sequencer);
    cfg_seq.start(env.virtual_sequencer);

    // Step 2: Explicitly write CTRL.SIZE=1 and OFFSET=0
    env.model.reg_block.CTRL.write(status, 32'h00000101, UVM_FRONTDOOR);

    // Step 3: Enable IRQEN for RX_FIFO_FULL and TX_FIFO_FULL
    env.model.reg_block.IRQEN.read(status, irqen_val, UVM_FRONTDOOR);
    //irqen_val[1] = 1'b1;  // RX_FIFO_FULL
   // irqen_val[3] = 1'b1;  // TX_FIFO_FULL
   env.model.reg_block.IRQEN.write(status, 32'h00000002, UVM_FRONTDOOR);
    #(50ns); 
   // env.model.reg_block.IRQEN.write(status, 32'h00000002, UVM_FRONTDOOR);
    `uvm_info("3_3_2", $sformatf("IRQEN configured: 0x%0h", irqen_val), UVM_MEDIUM)

    // Step 4: Send 19 RX packets (SIZE=1, OFFSET=0)
    for (int i = 0; i < 19; i++) begin
      rx_seq =
          cfs_algn_virtual_sequence_rx_size1_offset0::type_id::create($sformatf("rx_seq_%0d", i));
      rx_seq.set_sequencer(env.virtual_sequencer);
      void'(rx_seq.randomize());
      rx_seq.start(env.virtual_sequencer);
       if(i==17)
      begin
      #(10ns);
       env.model.reg_block.STATUS.RX_LVL.read(status, status_val, UVM_FRONTDOOR);
       end
    end
    
    env.model.reg_block.STATUS.RX_LVL.read(status, status_val, UVM_FRONTDOOR);
    
     env.model.reg_block.IRQ.write(status, 32'h00000000, UVM_FRONTDOOR);
     
      env.model.reg_block.IRQ.write(status, 32'h00000002, UVM_FRONTDOOR);
    

    `uvm_info("3_3_2", "Completed sending RX traffic under TX backpressure.", UVM_MEDIUM)
    
    #(50ns);
    
    //env.model.reg_block.IRQ.write(status, 32'h00000002, UVM_FRONTDOOR);//Added to hit irq_rx_fifo_full signal=0 in toggle coverage

    #(500ns);  // Let DUT settle
    phase.drop_objection(this, "TEST_DONE");

  endtask

endclass

`endif

