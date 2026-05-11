///////////////////////////////////////////////////////////////////////////////
// File:        cfs_algn_md_tests_3_2_1.sv
// Author:      Pranav
// Date:        2025-06-23
// Description: Verify the design behavior by sending 7 different data
//              patterns
///////////////////////////////////////////////////////////////////////////////
`ifndef CFS_ALGN_MD_TESTS_3_2_1_SV
`define CFS_ALGN_MD_TESTS_3_2_1_SV

class cfs_algn_md_tests_3_2_1 extends cfs_algn_test_base;

  `uvm_component_utils(cfs_algn_md_tests_3_2_1)

  function new(string name = "", uvm_component parent);
    super.new(name, parent);
  endfunction

  virtual task run_phase(uvm_phase phase);
    cfs_md_sequence_slave_response_forever resp_seq;
    cfs_algn_virtual_sequence_reg_config cfg_seq;
    cfs_algn_virtual_sequence_rx_crt rx_seq1;
    cfs_algn_virtual_sequence_rx_crt1 rx_seq2;
    cfs_algn_virtual_sequence_rx_crt2 rx_seq3;
    cfs_algn_vif vif;

    uvm_reg_data_t reg_val;
    uvm_status_e status;

    phase.raise_objection(this, "TEST_START");

    #(100ns);

    // Fork forever slave responder
    fork
      begin
        resp_seq = cfs_md_sequence_slave_response_forever::type_id::create("resp_seq");
        resp_seq.start(env.md_tx_agent.sequencer);
      end
    join_none

    cfg_seq = cfs_algn_virtual_sequence_reg_config::type_id::create("cfg_seq");
    cfg_seq.set_sequencer(env.virtual_sequencer);
    cfg_seq.start(env.virtual_sequencer);

    vif = env.env_config.get_vif();
    repeat (50) @(posedge vif.clk);

    $display(
        "\n ********** 1/7 POSSIBLE VALUES OF CTRL.OFFSET AND CTRL.SIZE ***********************");
    env.model.reg_block.CTRL.write(status, 32'h00000001, UVM_FRONTDOOR);
    //env.model.reg_block.CTRL.read(status, reg_val, UVM_FRONTDOOR);
    #(50ns);

    rx_seq1 = cfs_algn_virtual_sequence_rx_crt::type_id::create("rx_seq1");
    rx_seq1.set_sequencer(env.virtual_sequencer);
    void'(rx_seq1.randomize());
    rx_seq1.start(env.virtual_sequencer);
    #(50ns);

    rx_seq2 = cfs_algn_virtual_sequence_rx_crt1::type_id::create("rx_seq2");
    rx_seq2.set_sequencer(env.virtual_sequencer);
    void'(rx_seq2.randomize());
    rx_seq2.start(env.virtual_sequencer);
    #(50ns);

    rx_seq3 = cfs_algn_virtual_sequence_rx_crt2::type_id::create("rx_seq3");
    rx_seq3.set_sequencer(env.virtual_sequencer);
    void'(rx_seq3.randomize());
    rx_seq3.start(env.virtual_sequencer);

    #(100ns);

    $display(
        "\n ********** 2/7 POSSIBLE VALUES OF CTRL.OFFSET AND CTRL.SIZE ***********************");
    env.model.reg_block.CTRL.write(status, 32'h00000101, UVM_FRONTDOOR);
    //env.model.reg_block.CTRL.read(status, reg_val, UVM_FRONTDOOR);
    #(50ns);
    rx_seq1 = cfs_algn_virtual_sequence_rx_crt::type_id::create("rx_seq1");
    rx_seq1.set_sequencer(env.virtual_sequencer);
    void'(rx_seq1.randomize());
    rx_seq1.start(env.virtual_sequencer);
    #(50ns);

    rx_seq2 = cfs_algn_virtual_sequence_rx_crt1::type_id::create("rx_seq2");
    rx_seq2.set_sequencer(env.virtual_sequencer);
    void'(rx_seq2.randomize());
    rx_seq2.start(env.virtual_sequencer);
    #(50ns);

    rx_seq3 = cfs_algn_virtual_sequence_rx_crt2::type_id::create("rx_seq3");
    rx_seq3.set_sequencer(env.virtual_sequencer);
    void'(rx_seq3.randomize());
    rx_seq3.start(env.virtual_sequencer);

    #(100ns);

    $display(
        "\n *********** 3/7 POSSIBLE VALUES OF CTRL.OFFSET AND CTRL.SIZE ************************");
    env.model.reg_block.CTRL.write(status, 32'h00000201, UVM_FRONTDOOR);
    //env.model.reg_block.CTRL.read(status, reg_val, UVM_FRONTDOOR);
    #(50ns);
    rx_seq1 = cfs_algn_virtual_sequence_rx_crt::type_id::create("rx_seq1");
    rx_seq1.set_sequencer(env.virtual_sequencer);
    void'(rx_seq1.randomize());
    rx_seq1.start(env.virtual_sequencer);
    #(50ns);

    rx_seq2 = cfs_algn_virtual_sequence_rx_crt1::type_id::create("rx_seq2");
    rx_seq2.set_sequencer(env.virtual_sequencer);
    void'(rx_seq2.randomize());
    rx_seq2.start(env.virtual_sequencer);
    #(50ns);

    rx_seq3 = cfs_algn_virtual_sequence_rx_crt2::type_id::create("rx_seq3");
    rx_seq3.set_sequencer(env.virtual_sequencer);
    void'(rx_seq3.randomize());
    rx_seq3.start(env.virtual_sequencer);

    #(100ns);

    $display(
        "\n *********** 4/7 POSSIBLE VALUES OF CTRL.OFFSET AND CTRL.SIZE *************************");
    env.model.reg_block.CTRL.write(status, 32'h00000301, UVM_FRONTDOOR);
    //env.model.reg_block.CTRL.read(status, reg_val, UVM_FRONTDOOR);
    #(50ns);
    rx_seq1 = cfs_algn_virtual_sequence_rx_crt::type_id::create("rx_seq1");
    rx_seq1.set_sequencer(env.virtual_sequencer);
    void'(rx_seq1.randomize());
    rx_seq1.start(env.virtual_sequencer);
    #(50ns);

    rx_seq2 = cfs_algn_virtual_sequence_rx_crt1::type_id::create("rx_seq2");
    rx_seq2.set_sequencer(env.virtual_sequencer);
    void'(rx_seq2.randomize());
    rx_seq2.start(env.virtual_sequencer);
    #(50ns);

    rx_seq3 = cfs_algn_virtual_sequence_rx_crt2::type_id::create("rx_seq3");
    rx_seq3.set_sequencer(env.virtual_sequencer);
    void'(rx_seq3.randomize());
    rx_seq3.start(env.virtual_sequencer);

    #(100ns);

    $display(
        "\n *********** 5/7 POSSIBLE VALUES OF CTRL.OFFSET AND CTRL.SIZE **************************");
    env.model.reg_block.CTRL.write(status, 32'h00000002, UVM_FRONTDOOR);
    //env.model.reg_block.CTRL.read(status, reg_val, UVM_FRONTDOOR);
    #(50ns);
    rx_seq1 = cfs_algn_virtual_sequence_rx_crt::type_id::create("rx_seq1");
    rx_seq1.set_sequencer(env.virtual_sequencer);
    void'(rx_seq1.randomize());
    rx_seq1.start(env.virtual_sequencer);
    #(50ns);

    rx_seq2 = cfs_algn_virtual_sequence_rx_crt1::type_id::create("rx_seq2");
    rx_seq2.set_sequencer(env.virtual_sequencer);
    void'(rx_seq2.randomize());
    rx_seq2.start(env.virtual_sequencer);
    #(50ns);

    rx_seq2 = cfs_algn_virtual_sequence_rx_crt1::type_id::create("rx_seq2");
    rx_seq2.set_sequencer(env.virtual_sequencer);
    void'(rx_seq2.randomize());
    rx_seq2.start(env.virtual_sequencer);
    #(50ns);

    rx_seq3 = cfs_algn_virtual_sequence_rx_crt2::type_id::create("rx_seq3");
    rx_seq3.set_sequencer(env.virtual_sequencer);
    void'(rx_seq3.randomize());
    rx_seq3.start(env.virtual_sequencer);

    #(100ns);

    $display(
        "\n *********** 6/7 POSSIBLE VALUES OF CTRL.OFFSET AND CTRL.SIZE **************************");
    env.model.reg_block.CTRL.write(status, 32'h00000202, UVM_FRONTDOOR);
    //env.model.reg_block.CTRL.read(status, reg_val, UVM_FRONTDOOR);
    #(50ns);
    rx_seq1 = cfs_algn_virtual_sequence_rx_crt::type_id::create("rx_seq1");
    rx_seq1.set_sequencer(env.virtual_sequencer);
    void'(rx_seq1.randomize());
    rx_seq1.start(env.virtual_sequencer);
    #(50ns);

    rx_seq2 = cfs_algn_virtual_sequence_rx_crt1::type_id::create("rx_seq2");
    rx_seq2.set_sequencer(env.virtual_sequencer);
    void'(rx_seq2.randomize());
    rx_seq2.start(env.virtual_sequencer);
    #(50ns);

    rx_seq2 = cfs_algn_virtual_sequence_rx_crt1::type_id::create("rx_seq2");
    rx_seq2.set_sequencer(env.virtual_sequencer);
    void'(rx_seq2.randomize());
    rx_seq2.start(env.virtual_sequencer);
    #(50ns);

    rx_seq3 = cfs_algn_virtual_sequence_rx_crt2::type_id::create("rx_seq3");
    rx_seq3.set_sequencer(env.virtual_sequencer);
    void'(rx_seq3.randomize());
    rx_seq3.start(env.virtual_sequencer);

    #(100ns);

    $display(
        "\n *********** 7/7 POSSIBLE VALUES OF CTRL.OFFSET AND CTRL.SIZE ***************************");
    env.model.reg_block.CTRL.write(status, 32'h00000004, UVM_FRONTDOOR);
    //env.model.reg_block.CTRL.read(status, reg_val, UVM_FRONTDOOR);
    #(50ns);
    rx_seq1 = cfs_algn_virtual_sequence_rx_crt::type_id::create("rx_seq1");
    rx_seq1.set_sequencer(env.virtual_sequencer);
    void'(rx_seq1.randomize());
    rx_seq1.start(env.virtual_sequencer);
    #(50ns);

    rx_seq2 = cfs_algn_virtual_sequence_rx_crt1::type_id::create("rx_seq2");
    rx_seq2.set_sequencer(env.virtual_sequencer);
    void'(rx_seq2.randomize());
    rx_seq2.start(env.virtual_sequencer);
    #(50ns);

    rx_seq2 = cfs_algn_virtual_sequence_rx_crt1::type_id::create("rx_seq2");
    rx_seq2.set_sequencer(env.virtual_sequencer);
    void'(rx_seq2.randomize());
    rx_seq2.start(env.virtual_sequencer);
    #(50ns);

    rx_seq3 = cfs_algn_virtual_sequence_rx_crt2::type_id::create("rx_seq3");
    rx_seq3.set_sequencer(env.virtual_sequencer);
    void'(rx_seq3.randomize());
    rx_seq3.start(env.virtual_sequencer);

    #(100ns);

    phase.drop_objection(this, "TEST_DONE");
  endtask

endclass

`endif
