//////////////////////////////////////////////////////////////////////////////

// File:        cfs_algn_apb_tests_3_1_4.sv

// Author:      Pranav

// Date:        2025-06-23

// Description: To verify whether values of TX_LVL and RX_LVL at any point between ongoing

//              transactions are correct or any corruption has taken place

///////////////////////////////////////////////////////////////////////////////

`ifndef CFS_ALGN_APB_TESTS_3_1_4_SV

`define CFS_ALGN_APB_TESTS_3_1_4_SV

class cfs_algn_apb_tests_3_1_4 extends cfs_algn_test_base;

  `uvm_component_utils(cfs_algn_apb_tests_3_1_4)

  function new(string name = "", uvm_component parent);

    super.new(name, parent);

  endfunction

  virtual task run_phase(uvm_phase phase);

    cfs_md_sequence_slave_response_forever resp_seq;

    cfs_algn_virtual_sequence_reg_config cfg_seq;

    cfs_algn_virtual_sequence_rx_crt rx_seq;


    cfs_algn_vif vif;

    uvm_reg_data_t reg_val;

    uvm_status_e status;

    // uvm_reg_field irq_fields[$];

    phase.raise_objection(this, "TEST_START");

    #(100ns);

    // Fork forever slave responder

    fork

      begin

        cfs_md_sequence_tx_ready_block tx_block_seq = cfs_md_sequence_tx_ready_block::type_id::create(

            "tx_block_seq"

        );

        tx_block_seq.start(env.md_tx_agent.sequencer);

      end

    join_none

    cfg_seq = cfs_algn_virtual_sequence_reg_config::type_id::create("cfg_seq");

    cfg_seq.set_sequencer(env.virtual_sequencer);

    cfg_seq.start(env.virtual_sequencer);

    vif = env.env_config.get_vif();

    repeat (50) @(posedge vif.clk);

    env.model.reg_block.CTRL.write(status, 32'h00000004, UVM_FRONTDOOR);

    env.model.reg_block.CTRL.read(status, reg_val, UVM_FRONTDOOR);

    // env.model.reg_block.CTRL.SIZE.write(status, 4, UVM_FRONTDOOR);

    // env.model.reg_block.CTRL.OFFSET.write(status, 0, UVM_FRONTDOOR);

    // // Step 3: Send 20 legal RX packets

    for (int i = 0; i < 1; i++) begin

      rx_seq = cfs_algn_virtual_sequence_rx_crt::type_id::create($sformatf("rx_seq_%0d", i));

      rx_seq.set_sequencer(env.virtual_sequencer);

      void'(rx_seq.randomize());

      rx_seq.start(env.virtual_sequencer);

    end

    #(100ns);


    for (int i = 0; i < 8; i++) begin

      rx_seq = cfs_algn_virtual_sequence_rx_crt::type_id::create($sformatf("rx_seq_%0d", i));

      rx_seq.set_sequencer(env.virtual_sequencer);

      void'(rx_seq.randomize());

      rx_seq.start(env.virtual_sequencer);

    end

    #(200ns);

    phase.drop_objection(this, "TEST_DONE");

  endtask

endclass

`endif

