///////////////////////////////////////////////////////////////////////////////
// File:        cfs_algn_err_tests_3_4_5.sv
// Author:      Pranav
// Date:        2023-06-27
// Description: Test to verify the design behaviour when CTRL register is 
//              configured with illegal values
///////////////////////////////////////////////////////////////////////////////
`ifndef CFS_ALGN_ERR_TESTS_3_4_5_SV
`define CFS_ALGN_ERR_TESTS_3_4_5_SV

class cfs_algn_err_tests_3_4_5 extends cfs_algn_test_base;

  `uvm_component_utils(cfs_algn_err_tests_3_4_5)

  function new(string name = "", uvm_component parent = null);
    super.new(name, parent);
  endfunction

  virtual task run_phase(uvm_phase phase);
    cfs_algn_virtual_sequence_reg_config cfg_seq;
    cfs_md_sequence_slave_response_forever resp_seq;

    uvm_status_e status;
    uvm_reg_data_t ctrl_val, irq_val;
    virtual cfs_algn_if vif;

    phase.raise_objection(this, "TEST_START");

    vif = env.env_config.get_vif();
    #(100ns);

    // Step 0: Fork slave responder
    fork
      begin
        resp_seq = cfs_md_sequence_slave_response_forever::type_id::create("resp_seq");
        resp_seq.start(env.md_tx_agent.sequencer);
      end
    join_none

    // Step 1: Basic register configuration
  /*  cfg_seq = cfs_algn_virtual_sequence_reg_config::type_id::create("cfg_seq");
    cfg_seq.set_sequencer(env.virtual_sequencer);
    cfg_seq.start(env.virtual_sequencer);*/

    // Step 2: Write illegal CTRL values (SIZE=3, OFFSET=1)
    ctrl_val = 32'h00000203;
    env.model.reg_block.CTRL.write(status, ctrl_val, UVM_FRONTDOOR);
    //#(50ns);
   ctrl_val = 32'h00000103;
    env.model.reg_block.CTRL.write(status, ctrl_val, UVM_FRONTDOOR);
    #(50ns);
   /*  ctrl_val = 32'h00000100;
    env.model.reg_block.CTRL.write(status, ctrl_val, UVM_FRONTDOOR);
    // Step 3: Wait and check DUT response
    #(200ns);*/


    phase.drop_objection(this, "TEST_DONE");
  endtask

endclass

`endif

