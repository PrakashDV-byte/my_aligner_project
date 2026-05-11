class cfs_algn_virtual_sequence_split_legal_combinations extends cfs_algn_virtual_sequence_base;

  `uvm_object_utils(cfs_algn_virtual_sequence_split_legal_combinations)

  function new(string name = "");
    super.new(name);
  endfunction

  virtual task body();
    int ctrl_offset_vals[] = '{0, 1, 2, 3};
    int ctrl_size_vals[]   = '{1, 2, 3, 4};
    int md_offset_vals[]   = '{0, 1, 2, 3};
    int md_size_vals[]     = '{1, 2, 3, 4};

            cfs_md_sequence_simple_master rx_seq;
    uvm_status_e status;
    uvm_reg_data_t ctrl_val;

    foreach (ctrl_offset_vals[i]) begin
      foreach (ctrl_size_vals[j]) begin
        // Skip illegal combinations for ctrl_offset + ctrl_size
        if ((i == 0 && ctrl_size_vals[j] inside {3})    ||
            (i == 1 && ctrl_size_vals[j] inside {2,3,4}) ||
            (i == 2 && ctrl_size_vals[j] inside {3,4})   ||
            (i == 3 && ctrl_size_vals[j] inside {2,3,4})) begin
          continue;
        end

        // Set the control register (CTRL)
        ctrl_val = 0;
        ctrl_val[2:0] = ctrl_size_vals[j];     // SIZE
        ctrl_val[9:8] = ctrl_offset_vals[i];   // OFFSET

        p_sequencer.model.reg_block.CTRL.write(status, ctrl_val);

        foreach (md_offset_vals[k]) begin
          foreach (md_size_vals[l]) begin
            // Skip illegal combinations for md_offset + md_size
            if ((k == 0 && md_size_vals[l] inside {3})    ||
                (k == 1 && md_size_vals[l] inside {2,3,4}) ||
                (k == 2 && md_size_vals[l] inside {3,4})   ||
                (k == 3 && md_size_vals[l] inside {2,3,4})) begin
              continue;
            end

            rx_seq = cfs_md_sequence_simple_master::type_id::create(
              $sformatf("rx_seq_c%0d_s%0d_mo%0d_ms%0d", i, ctrl_size_vals[j], k, md_size_vals[l])
            );

            rx_seq.item.offset = md_offset_vals[k];
            rx_seq.item.data.delete();

            repeat (md_size_vals[l])
              rx_seq.item.data.push_back($urandom_range(0, 255));

            `uvm_info(get_type_name(),
              $sformatf("RX: ctrl_offset=%0d ctrl_size=%0d md_offset=%0d md_size=%0d",
              ctrl_offset_vals[i], ctrl_size_vals[j], md_offset_vals[k], md_size_vals[l]), UVM_LOW)

            rx_seq.start(p_sequencer.md_rx_sequencer);
            #100ns;
          end
        end
      end
    end
  endtask
endclass
//
