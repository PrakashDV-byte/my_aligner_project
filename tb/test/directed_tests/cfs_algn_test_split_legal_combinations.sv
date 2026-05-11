class cfs_algn_test_split_legal_combinations extends cfs_algn_test_base;
  `uvm_component_utils(cfs_algn_test_split_legal_combinations)

  function new(string name = "cfs_algn_test_split_legal_combinations", uvm_component parent = null);
    super.new(name, parent);
  endfunction

  virtual task run_phase(uvm_phase phase);
    cfs_algn_virtual_sequence_split_legal_combinations seq;

    phase.raise_objection(this);

    #100ns;

    // Launch slave response sequence forever
    fork
      begin
        cfs_md_sequence_slave_response_forever slave_seq;
        slave_seq = cfs_md_sequence_slave_response_forever::type_id::create("slave_seq");
        slave_seq.start(env.md_tx_agent.sequencer);
      end
    join_none

    // Launch legal virtual sequence
    seq = cfs_algn_virtual_sequence_split_legal_combinations::type_id::create("seq");
    seq.start(env.virtual_sequencer);

    #100ns;
    phase.drop_objection(this);
  endtask
endclass

