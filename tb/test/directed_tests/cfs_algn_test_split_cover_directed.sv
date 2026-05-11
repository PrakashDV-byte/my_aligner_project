class cfs_algn_test_split_cover_directed extends cfs_algn_test_base;
  `uvm_component_utils(cfs_algn_test_split_cover_directed)

  function new(string name = "cfs_algn_test_split_cover_directed", uvm_component parent = null);
    super.new(name, parent);
  endfunction

  virtual task run_phase(uvm_phase phase);
        cfs_md_sequence_slave_response_forever slave_seq;
    cfs_algn_virtual_sequence_split_cover_directed seq;
    phase.raise_objection(this);
    #100ns;

    // Fork slave response forever sequence
    fork
      begin
        slave_seq = cfs_md_sequence_slave_response_forever::type_id::create("slave_seq");
        slave_seq.start(env.md_tx_agent.sequencer);
      end
    join_none

    // Start the virtual sequence that hits all uncovered bins
    seq = cfs_algn_virtual_sequence_split_cover_directed::type_id::create("seq");
    seq.start(env.virtual_sequencer);

    #100ns;
    phase.drop_objection(this);
  endtask
endclass

