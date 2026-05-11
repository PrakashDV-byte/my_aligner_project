class cfs_algn_virtual_sequence_split_cross_cover_directed
  extends cfs_algn_virtual_sequence_base;

  `uvm_object_utils(cfs_algn_virtual_sequence_split_cross_cover_directed)

  function new(string name = "cfs_algn_virtual_sequence_split_cross_cover_directed");
    super.new(name);
  endfunction


  //----------------------------------------------------------------
  // RAL helper – write CTRL register (frontdoor)
  //----------------------------------------------------------------
  task automatic write_ctrl(int unsigned size, int unsigned offset);
    uvm_status_e   status;
    uvm_reg_data_t data;

    data        = 0;
    data[2:0]   = size;   // SIZE  (bits [2:0])
    data[9:8]   = offset; // OFFSET(bits [9:8])

    p_sequencer.model.reg_block.CTRL.write(status, data, UVM_FRONTDOOR);

    `uvm_info(get_type_name(),
      $sformatf("CTRL written: SIZE=%0d  OFFSET=%0d  (0x%08x)", size, offset, data),
      UVM_LOW)
  endtask


  //----------------------------------------------------------------
  // Helper – send one RX packet (md_size / md_offset)
  //  (guarantees md_size ≤ 4 − md_offset for 4‑byte bus)
  //----------------------------------------------------------------
  task automatic send_rx_pkt(int unsigned md_size,
                             int unsigned md_offset,
                             string tag = "rx");
    cfs_algn_virtual_sequence_rx rx_seq;
    // Clamp to legal size if required
    if (md_size + md_offset > 4) begin
      `uvm_error(get_type_name(),
        $sformatf("Illegal MD packet (size=%0d offset=%0d) on 4‑byte bus",
                   md_size, md_offset))
      return;
    end

    rx_seq = cfs_algn_virtual_sequence_rx::type_id::create(
               {tag, "_size", md_size, "_off", md_offset});

    void'(rx_seq.seq.item.randomize() with {
      data.size() == md_size;
      offset      == md_offset;
      foreach (data[i]) data[i] inside {[0:255]};
    });

    rx_seq.start(p_sequencer);
    `uvm_info(get_type_name(),
      $sformatf("RX sent: SIZE=%0d  OFFSET=%0d", md_size, md_offset),
      UVM_LOW)

    #10ns;   // spacing
  endtask


  //----------------------------------------------------------------
  // Main body  –  Feasible directed cases
  //----------------------------------------------------------------
  virtual task body();

    //----------------------------------------------------------------
    // Start slave‑response‑forever in background
    //----------------------------------------------------------------
    fork
      cfs_md_sequence_slave_response_forever::type_id::
        create("slv_forever", p_sequencer.md_tx_sequencer)
        .start(p_sequencer.md_tx_sequencer);
    join_none


    // --------------------------------------------------------------
    //  1)  md_offset = 3
    // --------------------------------------------------------------
    write_ctrl(4, 0);
    send_rx_pkt(1, 3, "C1");

    // --------------------------------------------------------------
    //  2)  md_offset = 1
    // --------------------------------------------------------------
    write_ctrl(4, 0);
    send_rx_pkt(2, 1, "C2");

    // --------------------------------------------------------------
    //  3)  md_size = 1
    // --------------------------------------------------------------
    write_ctrl(4, 0);
    send_rx_pkt(1, 0, "C3");

    // --------------------------------------------------------------
    //  4)  ctrl_offset = 3  & num_bytes_needed = 3
    //      (CTRL.SIZE = 4, first packet 1 B @ offset 3  → need 3 B)
    // --------------------------------------------------------------
    write_ctrl(4, 3);
    send_rx_pkt(1, 3, "C4");   // leaves 3 bytes needed

    // --------------------------------------------------------------
    //  5)  ctrl_offset = 1  & num_bytes_needed = 3
    // --------------------------------------------------------------
    write_ctrl(4, 1);
    send_rx_pkt(1, 1, "C5");   // leaves 3 bytes needed

    // --------------------------------------------------------------
    //  6)  ctrl_offset = 2  & num_bytes_needed = 3
    // --------------------------------------------------------------
    write_ctrl(4, 2);
    send_rx_pkt(1, 2, "C6");   // leaves 3 bytes needed

    // --------------------------------------------------------------
    //  7)  ctrl_offset = 3  & num_bytes_needed = 2
    //      (CTRL.SIZE = 3, first packet 1 B @ off 3  → need 2 B)
    // --------------------------------------------------------------
    write_ctrl(3, 3);
    send_rx_pkt(1, 3, "C7");   // leaves 2 bytes needed

    // --------------------------------------------------------------
    //  8)  ctrl_offset = 1  & num_bytes_needed = 2
    //      (CTRL.SIZE = 3)
    // --------------------------------------------------------------
    write_ctrl(3, 1);
    send_rx_pkt(1, 1, "C8");   // leaves 2 bytes needed

    // --------------------------------------------------------------
    //  9)  ctrl_size = 4  & md_offset = 2
    // --------------------------------------------------------------
    write_ctrl(4, 0);
    send_rx_pkt(2, 2, "C9a");  // offset 2
    send_rx_pkt(2, 0, "C9b");  // filler to complete

    // --------------------------------------------------------------
    // Cases 10–18 that imply illegal size/offset > 4 or
    // num_bytes_needed > ctrl_size are not feasible on a 4‑byte bus
    // --------------------------------------------------------------
  endtask

endclass

