///////////////////////////////////////////////////////////////////////////////
// File:        cfs_algn_err_tests_3_4_3.sv
// Author:      Pranav
// Date:        2023-06-27
// Description: Test which attempts read to write only location
//              
///////////////////////////////////////////////////////////////////////////////
`ifndef CFS_ALGN_ERR_TESTS_3_4_3_SV
`define CFS_ALGN_ERR_TESTS_3_4_3_SV

class cfs_algn_err_tests_3_4_3 extends cfs_algn_test_base;

  `uvm_component_utils(cfs_algn_err_tests_3_4_3)

  function new(string name = "", uvm_component parent = null);
    super.new(name, parent);
  endfunction

  virtual task run_phase(uvm_phase phase);

    cfs_algn_virtual_sequence_reg_config cfg_seq;
    uvm_status_e status;
    uvm_reg_data_t ctrl_val;

    phase.raise_objection(this, "TEST_START");

    #(100ns);

    // Step 1: Apply base config
    cfg_seq = cfs_algn_virtual_sequence_reg_config::type_id::create("cfg_seq");
    cfg_seq.set_sequencer(env.virtual_sequencer);
    cfg_seq.start(env.virtual_sequencer);

    // Step 2: Attempt to read from write-only CTRL.CLR field
    `uvm_info("3_4_3", "Attempting to read write-only CTRL.CLR bit", UVM_MEDIUM)

    env.model.reg_block.CTRL.read(status, ctrl_val, UVM_FRONTDOOR);

    if (status != UVM_NOT_OK)
      `uvm_info("3_4_3", $sformatf(
                "PASS: Read attempt from write-only CTRL.CLR was handled: CTRL=0x%0h", ctrl_val),
                UVM_LOW)
    else `uvm_error("3_4_3", "FAIL: Read from write-only CTRL.CLR was not blocked")

    #(100ns);
    phase.drop_objection(this, "TEST_DONE");

  endtask

endclass

`endif

