`ifndef CFS_ALGN_CLOCK_RESET_TESTS_3_5_2_SV
`define CFS_ALGN_CLOCK_RESET_TESTS_3_5_2_SV

/*import "DPI-C" context function int uvm_hdl_force(string path, logic val);
import "DPI-C" context function int uvm_hdl_release(string path);*/

class cfs_algn_clock_reset_tests_3_5_2 extends cfs_algn_test_base;

  `uvm_component_utils(cfs_algn_clock_reset_tests_3_5_2)

  function new(string name = "", uvm_component parent);
    super.new(name, parent);
  endfunction

  virtual task run_phase(uvm_phase phase);
    cfs_algn_virtual_sequence_reg_config cfg_seq;
    cfs_algn_virtual_sequence_rx_size1_offset0 rx_seq;
    cfs_md_sequence_slave_response_forever slave_resp_seq;

    uvm_status_e status;
    virtual cfs_algn_if algn_vif;
    int clk_ctrl;
    logic clk_val;
    uvm_reg_data_t ctrl_val, status_val, irq_val, irqen_val;

    phase.raise_objection(this, "CLOCK_TEST");

    // Get VIF handle
    if (!uvm_config_db#(virtual cfs_algn_if)::get(null, "uvm_test_top.env", "vif", algn_vif)) begin
      `uvm_fatal("CLOCK_TEST", "Failed to get aligner VIF from config DB")
    end

    #(100ns);

    // Start TX slave responder
    fork
      slave_resp_seq = cfs_md_sequence_slave_response_forever::type_id::create("slave_resp_seq");
      slave_resp_seq.start(env.md_tx_agent.sequencer);
    join_none

    // Step 1: Basic register config
    cfg_seq = cfs_algn_virtual_sequence_reg_config::type_id::create("cfg_seq");
    cfg_seq.set_sequencer(env.virtual_sequencer);
    cfg_seq.start(env.virtual_sequencer);

    env.model.reg_block.CTRL.write(status, 32'h00000001, UVM_FRONTDOOR);  // SIZE=1 OFFSET=0

    // Step 2: Send a few packets before freezing
    for (int i = 0; i < 15; i++) begin
      rx_seq = cfs_algn_virtual_sequence_rx_size1_offset0::type_id::create(
          $sformatf("rx_seq_before_%0d", i));
      rx_seq.set_sequencer(env.virtual_sequencer);
      void'(rx_seq.randomize());
      rx_seq.start(env.virtual_sequencer);
    end
    #(15ns);

    env.model.reg_block.CTRL.read(status, ctrl_val, UVM_FRONTDOOR);
    env.model.reg_block.STATUS.read(status, status_val, UVM_FRONTDOOR);
    env.model.reg_block.IRQEN.read(status, irqen_val, UVM_FRONTDOOR);
    env.model.reg_block.IRQ.read(status, irq_val, UVM_FRONTDOOR);


    `uvm_info("CLOCK_TEST", "Forcing clock LOW to simulate clock freeze", UVM_MEDIUM)
    clk_val  = 1'b0;

    // Path depends on your hierarchy — adjust if needed
    clk_ctrl = uvm_hdl_force("testbench.clk", clk_val);
    if (!clk_ctrl) `uvm_fatal("CLOCK_TEST", "Failed to force testbench.clk")

    #(300ns);  // Freeze duration

    `uvm_info("CLOCK_TEST", "Releasing clock to resume toggling", UVM_MEDIUM)
    clk_ctrl = uvm_hdl_release("testbench.clk");

    env.model.reg_block.CTRL.read(status, ctrl_val, UVM_FRONTDOOR);
    env.model.reg_block.STATUS.read(status, status_val, UVM_FRONTDOOR);
    env.model.reg_block.IRQEN.read(status, irqen_val, UVM_FRONTDOOR);
    env.model.reg_block.IRQ.read(status, irq_val, UVM_FRONTDOOR);
    #(100ns);

    if (!clk_ctrl) `uvm_fatal("CLOCK_TEST", "Failed to release testbench.clk")

    // Step 3: Send a few more packets after clock resumes
    repeat (5) @(posedge algn_vif.clk);

    for (int i = 0; i < 5; i++) begin
      rx_seq = cfs_algn_virtual_sequence_rx_size1_offset0::type_id::create(
          $sformatf("rx_seq_after_%0d", i));
      rx_seq.set_sequencer(env.virtual_sequencer);
      void'(rx_seq.randomize());
      rx_seq.start(env.virtual_sequencer);
    end

    #(300ns);
    phase.drop_objection(this, "CLOCK_TEST");
  endtask

endclass

`endif

