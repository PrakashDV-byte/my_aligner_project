class cfs_algn_test_ctrl4_off0_two_pkts extends cfs_algn_test_base;

  `uvm_component_utils(cfs_algn_test_ctrl4_off0_two_pkts)

  function new(string name = "cfs_algn_test_ctrl4_off0_two_pkts", uvm_component parent = null);
    super.new(name, parent);
  endfunction

  virtual task run_phase(uvm_phase phase);
        cfs_md_sequence_slave_response_forever slave_seq ; 
    cfs_algn_virtual_sequence_ctrl4_off0_two_pkts seq;
    super.run_phase(phase);

    // Declare the sequence

    // Start background slave response sequence

    // Run our actual test sequence
    phase.raise_objection(this);
    #100;

    fork
      begin
        slave_seq = 
            cfs_md_sequence_slave_response_forever::type_id::create(
            "slave_seq"
        );
        slave_seq.start(env.md_tx_agent.sequencer);
      end
    join_none
    seq = cfs_algn_virtual_sequence_ctrl4_off0_two_pkts::type_id::create("seq");
    seq.start(env.virtual_sequencer);
    #100;
    phase.drop_objection(this);
  endtask

endclass
