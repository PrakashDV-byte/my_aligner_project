class cfs_algn_virtual_sequence_split_cover_directed extends cfs_algn_virtual_sequence_base;

  `uvm_object_utils(cfs_algn_virtual_sequence_split_cover_directed)

  function new(string name = "");
    super.new(name);
  endfunction

  virtual task body();
    uvm_status_e status;
    uvm_reg_data_t ctrl_val;

      cfs_md_sequence_simple_master rx_seq;
    // List of tuples (ctrl_offset, ctrl_size, md_offset, md_size)
    int test_vectors[][] = '{
      '{0, 3, 1, 3},   // covers ctrl_size=3, md_offset=1, md_size=3
      '{0, 1, 1, 2},   // covers ctrl_size=1, md_offset=1, md_size=2
      '{1, 2, 2, 2},   // covers ctrl_offset=1, ctrl_size=2, md_offset=2, md_size=2
      '{3, 1, 0, 3},   // covers ctrl_offset=3, md_size=3
      '{1, 1, 2, 2},   // ctrl_offset=1, size=1, md_offset=2
      '{2, 1, 0, 3},   // ctrl_offset=2, size=1, md_size=3
      '{2, 1, 0, 2},   // ctrl_offset=2, md_size=2
      '{3, 1, 0, 2}    // ctrl_offset=3, md_size=2
    };

    foreach (test_vectors[i]) begin
      int ctrl_offset = test_vectors[i][0];
      int ctrl_size   = test_vectors[i][1];
      int md_offset   = test_vectors[i][2];
      int md_size     = test_vectors[i][3];

      // Only apply legal combinations
      if ((ctrl_offset + ctrl_size) > 4 || (md_offset + md_size) > 4)
        continue;

      ctrl_val = 0;
      ctrl_val[2:0] = ctrl_size;        // SIZE in bits [2:0]
      ctrl_val[9:8] = ctrl_offset;      // OFFSET in bits [9:8]

      p_sequencer.model.reg_block.CTRL.write(status, ctrl_val);

      rx_seq = cfs_md_sequence_simple_master::type_id::create($sformatf("rx_seq_%0d", i));

      rx_seq.item.offset = md_offset;
      rx_seq.item.data.delete();
      repeat (md_size) rx_seq.item.data.push_back($urandom_range(0, 255));

      `uvm_info(get_type_name(), $sformatf("[Directed Split Cover] ctrl_offset=%0d, ctrl_size=%0d, md_offset=%0d, md_size=%0d", ctrl_offset, ctrl_size, md_offset, md_size), UVM_LOW)

      rx_seq.start(p_sequencer.md_rx_sequencer);
      #10ns;
    end
  endtask

endclass

