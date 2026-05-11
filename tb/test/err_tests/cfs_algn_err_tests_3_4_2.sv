///////////////////////////////////////////////////////////////////////////////
// File:        cfs_algn_err_tests_3_4_2.sv
// Author:      Pranav
// Date:        2023-06-27
// Description: Test to verify design behaviour when write to read only register
//              is attempted.
///////////////////////////////////////////////////////////////////////////////
`ifndef CFS_ALGN_ERR_TESTS_3_4_2_SV
`define CFS_ALGN_ERR_TESTS_3_4_2_SV

class cfs_algn_err_tests_3_4_2 extends cfs_algn_test_base;

  `uvm_component_utils(cfs_algn_err_tests_3_4_2)

  function new(string name = "", uvm_component parent = null);
    super.new(name, parent);
  endfunction

  virtual task run_phase(uvm_phase phase);

    cfs_algn_virtual_sequence_reg_config cfg_seq;
    uvm_status_e status;
    uvm_reg_data_t dummy_data = 32'hFFFF_FFFF;

    phase.raise_objection(this, "TEST_START");

    #(100ns);

    // Step 1: Apply basic config (optional)
    cfg_seq = cfs_algn_virtual_sequence_reg_config::type_id::create("cfg_seq");
    cfg_seq.set_sequencer(env.virtual_sequencer);
    cfg_seq.start(env.virtual_sequencer);

    // Step 2: Attempt to write to read-only STATUS register
    `uvm_info("3_4_2", "Attempting illegal APB write to STATUS register", UVM_MEDIUM)
    env.model.reg_block.STATUS.write(status, dummy_data, UVM_FRONTDOOR);

    if (status != UVM_NOT_OK)
      `uvm_info("3_4_2", "PASS: Write to STATUS register blocked as expected", UVM_LOW)
    else `uvm_error("3_4_2", "FAIL: STATUS register write was not rejected by the DUT")

    #(100ns);
    phase.drop_objection(this, "TEST_DONE");

  endtask

endclass

`endif

