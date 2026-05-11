///////////////////////////////////////////////////////////////////////////////
// File:        cfs_algn_apb_tests_3_1_5.sv
// Author:      Pranav
// Date:        2025-06-27
// Description: Test to verify that CTRL[7:3] (reserved) remain 0 after write
///////////////////////////////////////////////////////////////////////////////

`ifndef CFS_ALGN_APB_TESTS_3_1_5_SV
`define CFS_ALGN_APB_TESTS_3_1_5_SV

class cfs_algn_apb_tests_3_1_5 extends cfs_algn_test_base;

  `uvm_component_utils(cfs_algn_apb_tests_3_1_5)

  function new(string name = "", uvm_component parent);
    super.new(name, parent);
  endfunction

  virtual task run_phase(uvm_phase phase);
    cfs_md_sequence_slave_response_forever resp_seq;
    cfs_algn_virtual_sequence_reg_config reg_cfg_seq;
    cfs_algn_vif vif;
    uvm_status_e status;
    uvm_reg_data_t read_data_before, read_data_after, write_data;
    bit [4:0] reserved_bits_before, reserved_bits_after;

    phase.raise_objection(this, "TEST_START");

    #(100ns);

    // Step 0: Fork TX slave responder
    fork
      begin
        resp_seq = cfs_md_sequence_slave_response_forever::type_id::create("resp_seq");
        resp_seq.start(env.md_tx_agent.sequencer);
      end
    join_none

    // Step 1: Randomly configure registers
    reg_cfg_seq = cfs_algn_virtual_sequence_reg_config::type_id::create("reg_cfg_seq");
    reg_cfg_seq.set_sequencer(env.virtual_sequencer);
    reg_cfg_seq.start(env.virtual_sequencer);

    // Step 2: Wait before register access
    vif = env.env_config.get_vif();
    repeat (20) @(posedge vif.clk);

    // Step 3: Read CTRL register (before reserved write)
    env.model.reg_block.CTRL.read(status, read_data_before, UVM_FRONTDOOR);
    reserved_bits_before = read_data_before[7:3];
    `uvm_info("3_1_5", $sformatf("Initial CTRL[7:3] = %05b", reserved_bits_before), UVM_MEDIUM)

    // Step 4: Attempt to write 1s to reserved bits [7:3]
    write_data = read_data_before | 32'h0000_00F8;
    env.model.reg_block.CTRL.write(status, write_data, UVM_FRONTDOOR);
    `uvm_info("3_1_5", $sformatf("Tried writing 1s to CTRL[7:3], data = %08h", write_data),
              UVM_MEDIUM)

    #(100ns);

    // Step 5: Read CTRL register again
    env.model.reg_block.CTRL.read(status, read_data_after, UVM_FRONTDOOR);
    reserved_bits_after = read_data_after[7:3];
    `uvm_info("3_1_5", $sformatf("After write CTRL[7:3] = %05b", reserved_bits_after), UVM_MEDIUM)

    // Step 6: Validate reserved bits remain 0
    if (reserved_bits_after !== 5'b00000) begin
      `uvm_error("3_1_5", $sformatf(
                              "Reserved bits were incorrectly modified! Expected 00000, Got %05b",
                              reserved_bits_after))
    end else begin
      `uvm_info("3_1_5", "Reserved bits verified as Read-Only. Write had no effect.", UVM_LOW)
    end

    #(100ns);
    phase.drop_objection(this, "TEST_DONE");
  endtask

endclass

`endif

