///////////////////////////////////////////////////////////////////////////////
// File:        cfs_algn_test_size_offset_cross_reset_rand.sv
// Author:      Keerthi Sree Somasi
// Date:        2025-07-15
// Description: UVM test that performs randomized testing of the Aligner module
//              across different size-offset CTRL register configurations,
//              injecting resets both before and mid-stream to validate DUT
//              behavior under repeated resets and stress conditions.
//              It uses:
//                - random CTRL register programming,
//                - a continuous slave response sequence,
//                - randomized RX sequences from predefined combinations,
//              to increase functional coverage of alignment and reset behavior.
///////////////////////////////////////////////////////////////////////////////
`ifndef CFS_ALGN_TEST_SIZE_OFFSET_CROSS_RESET_RAND_SV
`define CFS_ALGN_TEST_SIZE_OFFSET_CROSS_RESET_RAND_SV

class cfs_algn_test_size_offset_cross_reset_rand extends cfs_algn_test_base;

  `uvm_component_utils(cfs_algn_test_size_offset_cross_reset_rand)

  function new(string name = "", uvm_component parent = null);
    super.new(name, parent);
  endfunction

  virtual cfs_apb_if vif_apb;
  virtual cfs_algn_if vif_algn;
  uvm_status_e status;
  process resp_proc;
  int trials = 100;
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);

    if (!uvm_config_db#(virtual cfs_apb_if)::get(
            null, "uvm_test_top.env.apb_agent", "vif", vif_apb
        )) begin
      `uvm_fatal("NO_VIF", "Unable to get APB vif")
    end
    if (!uvm_config_db#(virtual cfs_algn_if)::get(null, "uvm_test_top.env", "vif", vif_algn)) begin
      `uvm_fatal("NO_ALGN_VIF", "Unable to get ALGN vif")
    end
  endfunction

  virtual task run_phase(uvm_phase phase);
    cfs_md_sequence_slave_response_forever resp_seq;
    cfs_algn_virtual_sequence_rx_rand_comb rx_comb_seq;
    cfs_algn_virtual_sequence_reg_config reg_cfg;
    int idx;
    int ctrl_val;
    int ctrl_val_list[] = '{
        32'h00000001,  // size=1, offset=0
        32'h00000101,  // size=1, offset=1
        32'h00000201,  // size=1, offset=2
        32'h00000301,  // size=1, offset=3
        32'h00000002,  // size=2, offset=0
        32'h00000202,  // size=2, offset=2
        32'h00000004  // size=4, offset=0
    };

    phase.raise_objection(this, "Start randomized size-offset cross test with reset");

    #(10ns);

    // Start slave responder
    fork
      resp_proc = process::self();
      begin
        resp_seq = cfs_md_sequence_slave_response_forever::type_id::create("resp_seq");
        resp_seq.start(env.md_tx_agent.sequencer);
      end
    join_none

    // Initial register configuration
    reg_cfg = cfs_algn_virtual_sequence_reg_config::type_id::create("reg_cfg");
    void'(reg_cfg.randomize());
    reg_cfg.set_sequencer(env.virtual_sequencer);
    reg_cfg.start(env.virtual_sequencer);

    repeat (trials) begin
      idx = $urandom_range(0, ctrl_val_list.size() - 1);
      ctrl_val = ctrl_val_list[idx];

      // Reset before programming
      repeat (2) @(posedge vif_algn.clk);
      vif_apb.preset_n <= 0;
      repeat (2) @(posedge vif_algn.clk);

      // Kill responder
      resp_proc.kill();

      repeat (2) @(posedge vif_algn.clk);
      vif_apb.preset_n <= 1;

      // Restart responder
      fork
        resp_seq = cfs_md_sequence_slave_response_forever::type_id::create("resp_seq_post_reset");
        resp_seq.start(env.md_tx_agent.sequencer);
      join_none

      // Program CTRL Register
      @(posedge vif_algn.clk);
      env.model.reg_block.CTRL.write(status, ctrl_val, UVM_FRONTDOOR);

      // Run RX combination sequence
      rx_comb_seq = cfs_algn_virtual_sequence_rx_rand_comb::type_id::create("rx_comb_seq");
      rx_comb_seq.set_sequencer(env.virtual_sequencer);
      rx_comb_seq.start(env.virtual_sequencer);

      #(100ns);

      // Optional second reset mid-test
      repeat (2) @(posedge vif_algn.clk);
      vif_apb.preset_n <= 0;
      repeat (2) @(posedge vif_algn.clk);
      resp_proc.kill();
      repeat (2) @(posedge vif_algn.clk);
      vif_apb.preset_n <= 1;
    end

    #(100ns);
    phase.drop_objection(this, "End randomized size-offset cross test with reset");
  endtask

endclass

`endif




