`ifndef CFS_MD_COVERAGE_SV
`define CFS_MD_COVERAGE_SV 



class cfs_md_coverage #(
    int unsigned DATA_WIDTH = 32
) extends uvm_ext_coverage #(
    .VIRTUAL_INTF(virtual cfs_md_if #(DATA_WIDTH)),
    .ITEM_MON(cfs_md_item_mon)
);

  typedef virtual cfs_md_if #(DATA_WIDTH) cfs_md_vif;

  //Pointer to agent configuration
  cfs_md_agent_config #(DATA_WIDTH) agent_config;

  //Wrapper over the coverage group covering the indices in the data signal
  //at which the bit of the data was 0
  uvm_ext_cover_index_wrapper #(DATA_WIDTH) wrap_cover_data_0;

  //Wrapper over the coverage group covering the indices in the data signal
  //at which the bit of the data was 1
  uvm_ext_cover_index_wrapper #(DATA_WIDTH) wrap_cover_data_1;

  `uvm_component_param_utils(cfs_md_coverage#(DATA_WIDTH))

  covergroup cover_item with function sample (cfs_md_item_mon item);
    option.per_instance = 1;

    offset: coverpoint item.offset {
      option.comment = "Offset of the MD access"; bins values[] = {[0 : (DATA_WIDTH / 8) - 1]};
    }

    size: coverpoint item.data.size() {
      option.comment = "Size of the MD access"; bins values[] = {[1 : (DATA_WIDTH / 8)]};
    }

    response: coverpoint item.response {option.comment = "Response of the MD access";}

    length: coverpoint item.length {
      option.comment = "Length of the MD access";
      bins length_eq_1 = {1};
      bins length_le_10[9] = {[2 : 10]};
      bins length_gt_10 = {[11 : $]};

      illegal_bins length_lt_1 = {0};
    }

    prev_item_delay: coverpoint item.prev_item_delay {
      option.comment = "Delay, in clock cycles, between two consecutive MD accesses";
      bins back2back = {0};
      bins delay_le_5[5] = {[1 : 5]};
      bins delay_gt_5 = {[6 : $]};
    }

    offset_x_size : cross offset, size{
      ignore_bins ignore_offset_plus_size_gt_data_width = offset_x_size with (offset + size > (DATA_WIDTH / 8));
    }

  endgroup

  covergroup cover_reset with function sample (bit valid);
    option.per_instance = 1;

    access_ongoing: coverpoint valid {option.comment = "An MD access was ongoing at reset";}
  endgroup

  function new(string name = "", uvm_component parent);
    super.new(name, parent);

    cover_item = new();
    cover_item.set_inst_name($sformatf("%s_%s", get_full_name(), "cover_item"));

    cover_reset = new();
    cover_reset.set_inst_name($sformatf("%s_%s", get_full_name(), "cover_reset"));
  endfunction

  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);

    wrap_cover_data_0 =
        uvm_ext_cover_index_wrapper#(DATA_WIDTH)::type_id::create("wrap_cover_data_0", this);
    wrap_cover_data_1 =
        uvm_ext_cover_index_wrapper#(DATA_WIDTH)::type_id::create("wrap_cover_data_1", this);
  endfunction

  virtual function void end_of_elaboration_phase(uvm_phase phase);
    super.end_of_elaboration_phase(phase);

    if ($cast(agent_config, super.agent_config) == 0) begin
      `uvm_fatal("ALGORITHM_ISSUE",
                 $sformatf("Could not cast %0s to %0s", super.agent_config.get_type_name(),
                           cfs_md_agent_config#(DATA_WIDTH)::type_id::type_name))
    end
  endfunction

  //Port associated with port_item port
  virtual function void write_item(cfs_md_item_mon item);
    cover_item.sample(item);

    foreach (item.data[byte_index]) begin
      for (int bit_index = 0; bit_index < 8; bit_index++) begin
        if (item.data[byte_index][bit_index]) begin
          wrap_cover_data_1.sample((item.offset * 8) + (byte_index * 8) + bit_index);
        end else begin
          wrap_cover_data_0.sample((item.offset * 8) + (byte_index * 8) + bit_index);
        end
      end
    end

  endfunction

  //Function to handle the reset
  virtual function void handle_reset(uvm_phase phase);
    cfs_md_vif vif = agent_config.get_vif();

    cover_reset.sample(vif.valid);
  endfunction

  //Function to print the coverage information.
  //This is only to be able to visualize some basic coverage information
  //in EDA Playground.
  //DON'T DO THIS IN A REAL PROJECT!!!
  virtual function string coverage2string();
    string result = {
      $sformatf("\n    cover_item:            %03.2f%%", cover_item.get_inst_coverage()),
      $sformatf("\n      offset:            %03.2f%%", cover_item.offset.get_inst_coverage()),
      $sformatf("\n      size:              %03.2f%%", cover_item.size.get_inst_coverage()),
      $sformatf("\n      response:          %03.2f%%", cover_item.response.get_inst_coverage()),
      $sformatf("\n      length:            %03.2f%%", cover_item.length.get_inst_coverage()),
      $sformatf(
          "\n      prev_item_delay:   %03.2f%%", cover_item.prev_item_delay.get_inst_coverage()
      ),
      $sformatf(
          "\n      offset_x_size:     %03.2f%%", cover_item.offset_x_size.get_inst_coverage()
      ),
      $sformatf("\n                                   "),
      $sformatf("\n    cover_reset:           %03.2f%%", cover_reset.get_inst_coverage()),
      $sformatf(
          "\n      access_ongoing:      %03.2f%%", cover_reset.access_ongoing.get_inst_coverage()
      ),
      super.coverage2string()
    };

    return result;
  endfunction

endclass

`endif  // CFS_MD_COVERAGE_SV
