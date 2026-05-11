`ifndef CFS_ALGN_NUM_BYTES_SV
`define CFS_ALGN_NUM_BYTES_SV

class cfs_algn_num_bytes extends cfs_algn_test_base;

  `uvm_component_utils(cfs_algn_num_bytes)

  function new(string name = "", uvm_component parent = null);
    super.new(name, parent);
  endfunction



virtual cfs_apb_if apb_vif;
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);

    // Get APB interface from config DB
    if (!uvm_config_db#(virtual cfs_apb_if)::get(this, "env.apb_agent", "vif", apb_vif)) begin
      `uvm_fatal("NO_APB_VIF", "Couldn't get apb_if from config DB");
    end
  endfunction

  virtual task run_phase(uvm_phase phase);

    cfs_md_sequence_slave_response_forever resp_seq;

    cfs_algn_virtual_sequence_reg_config cfg_seq;

   cfs_algn_virtual_sequence_rx_size1_offset0 rx_non_err_seq;

    cfs_algn_virtual_sequence_rx_crt rx_non_err_seq1;

    // cfs_md_sequence_tx_ready_block tx_block_seq;

    cfs_algn_vif vif;
 //   virtual cfs_apb_if apb_vif;

    uvm_reg_data_t control_val;
    uvm_reg_data_t status_val;
    uvm_reg_data_t irqen_val;

    uvm_status_e status;

    phase.raise_objection(this, "TEST_START");

    #(100ns);

    // Step 0: Fork TX ready blocker

    fork

      begin

        resp_seq = cfs_md_sequence_slave_response_forever::type_id::create("resp_seq");

        resp_seq.start(env.md_tx_agent.sequencer);

      end

    join_none

    // Step 1: Register config
    cfg_seq = cfs_algn_virtual_sequence_reg_config::type_id::create("cfg_seq");

    cfg_seq.set_sequencer(env.virtual_sequencer);

    cfg_seq.start(env.virtual_sequencer);


    env.model.reg_block.IRQEN.read(status, irqen_val, UVM_FRONTDOOR);
    irqen_val = 32'h00000000;  // enabling all interupts
    env.model.reg_block.IRQEN.write(status, irqen_val, UVM_FRONTDOOR);
    `uvm_info("1FIFO_LVLS", $sformatf("IRQEN disabled: 0x%0h", irqen_val),
              UVM_MEDIUM)  //ensure irqen value=1f


    // Step 2: Manual CTRL config with size 4 offset 0

    env.model.reg_block.CTRL.write(status, 32'h00000002, UVM_FRONTDOOR);
    env.model.reg_block.CTRL.read(status, control_val, UVM_FRONTDOOR);

  //  `uvm_info("3_2_4", $sformatf("CTRL register value: 0x%0h", control_val), UVM_MEDIUM)

    // Step 3: Wait post reset
    vif = env.env_config.get_vif();

    repeat (50) @(posedge vif.clk);

    // Step 4: Send 8 legal RX packets with SIZE=1 and OFFSET=0, delay 5 clks, read STATUS at each negedge

    for (int i = 0; i < 1 ; i++) begin
      rx_non_err_seq = cfs_algn_virtual_sequence_rx_size1_offset0::type_id::create($sformatf("rx_size1_%0d", i));
      rx_non_err_seq.set_sequencer(env.virtual_sequencer);
      void'(rx_non_err_seq.randomize());
      rx_non_err_seq.start(env.virtual_sequencer);
    end
    
    #(100ns);
    for (int i = 0; i < 1 ; i++) begin
      rx_non_err_seq1 = cfs_algn_virtual_sequence_rx_crt::type_id::create($sformatf("rx_size1_%0d", i));
      rx_non_err_seq1.set_sequencer(env.virtual_sequencer);
      void'(rx_non_err_seq1.randomize());
      rx_non_err_seq1.start(env.virtual_sequencer);
    end
     #(100ns);
        env.model.reg_block.CTRL.write(status, 32'h00000004, UVM_FRONTDOOR);
        
     for (int i = 0; i < 1 ; i++) begin
      rx_non_err_seq1 = cfs_algn_virtual_sequence_rx_crt::type_id::create($sformatf("rx_size1_%0d", i));
      rx_non_err_seq1.set_sequencer(env.virtual_sequencer);
      void'(rx_non_err_seq1.randomize());
      rx_non_err_seq1.start(env.virtual_sequencer);
    end
  
   
        


    #(500ns);
    phase.drop_objection(this, "TEST_DONE");

  endtask

endclass

`endif  // CFS_ALGN_MD_TESTS_SEND_4_RX_SIZE1_OFFSET0_SV

