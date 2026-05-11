
class cfs_algn_virtual_sequence_ctrl4_off0_two_pkts
  extends cfs_algn_virtual_sequence_base;

  `uvm_object_utils(cfs_algn_virtual_sequence_ctrl4_off0_two_pkts)

  function new(string name = "cfs_algn_virtual_sequence_ctrl4_off0_two_pkts");
    super.new(name);
  endfunction

  virtual task body();

    uvm_status_e status;
    uvm_reg_data_t data;

    cfs_algn_virtual_sequence_rx rx_seq2;
    cfs_algn_virtual_sequence_rx rx_seq1;
    //----------------------------------------------------------
    // 1. Write CTRL register: ctrl_size = 4, ctrl_offset = 0
    //----------------------------------------------------------
    data = 0;
    data[2:0] = 4;  // SIZE  (bits [2:0])
    data[9:8] = 0;  // OFFSET(bits [9:8])
    p_sequencer.model.reg_block.CTRL.write(status, data, UVM_FRONTDOOR);

    `uvm_info(get_type_name(), $sformatf("CTRL configured: SIZE=4 OFFSET=0 (0x%0h)", data), UVM_LOW)

    //----------------------------------------------------------
    // 2. Send RX packet: md_size = 2, md_offset = 2
    //----------------------------------------------------------
    rx_seq1 = cfs_algn_virtual_sequence_rx::type_id::create("rx_seq_1");

    void'(rx_seq1.seq.item.randomize() with {
      data.size() == 2;
      offset == 2;
    });

    rx_seq1.start(p_sequencer);
    `uvm_info(get_type_name(), "Sent RX Packet 1 (size=2, offset=2)", UVM_LOW)

    //----------------------------------------------------------
    // 3. Send RX packet: md_size = 4, md_offset = 0
    //----------------------------------------------------------
    rx_seq2 = cfs_algn_virtual_sequence_rx::type_id::create("rx_seq_2");

    void'(rx_seq2.seq.item.randomize() with {
      data.size() == 4;
      offset == 0;
    });

    rx_seq2.start(p_sequencer);
    `uvm_info(get_type_name(), "Sent RX Packet 2 (size=4, offset=0)", UVM_LOW)

    #100ns; // spacing

  endtask

endclass
