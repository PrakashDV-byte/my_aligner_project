`ifndef CFS_APB_COVERAGE_SV
`define CFS_APB_COVERAGE_SV



class cfs_apb_coverage extends uvm_ext_coverage #(
    .VIRTUAL_INTF(cfs_apb_vif),
    .ITEM_MON(cfs_apb_item_mon)
);

  cfs_apb_agent_config agent_config;

  uvm_ext_cover_index_wrapper #(`CFS_APB_MAX_ADDR_WIDTH) wrap_cover_addr_0;

  uvm_ext_cover_index_wrapper #(`CFS_APB_MAX_ADDR_WIDTH) wrap_cover_addr_1;

  uvm_ext_cover_index_wrapper #(`CFS_APB_MAX_DATA_WIDTH) wrap_cover_wr_data_0;

  uvm_ext_cover_index_wrapper #(`CFS_APB_MAX_DATA_WIDTH) wrap_cover_wr_data_1;

  uvm_ext_cover_index_wrapper #(`CFS_APB_MAX_DATA_WIDTH) wrap_cover_rd_data_0;

  uvm_ext_cover_index_wrapper #(`CFS_APB_MAX_DATA_WIDTH) wrap_cover_rd_data_1;

  `uvm_component_utils(cfs_apb_coverage)

  covergroup cover_item with function sample (cfs_apb_item_mon item);
    option.per_instance = 1;

    direction: coverpoint item.dir {option.comment = "Direction of the APB access";}

    response: coverpoint item.response {option.comment = "Response of the APB access";}

    length: coverpoint item.length {
      option.comment = "Length of the APB access";
      bins length_eq_2 = {2};
      bins length_le_10[8] = {[3 : 10]};
      bins length_gt_10 = {[11 : $]};

      illegal_bins length_lt_2 = {[$ : 1]};
      ignore_bins all_others = {[0:2], [4:$]};
    }

    prev_item_delay: coverpoint item.prev_item_delay {
      option.comment = "Delay, in clock cycles, between two consecutive APB accesses";
      bins back2back = {0};
      bins delay_le_5[5] = {[1 : 5]};
      bins delay_gt_5 = {[6 : $]};
    }

    response_x_direction : cross response, direction;

    trans_direction: coverpoint item.dir {
      option.comment = "Transitions of APB direction";
      bins direction_trans[] = (CFS_APB_READ, CFS_APB_WRITE => CFS_APB_READ, CFS_APB_WRITE);
    }

  endgroup

  covergroup cover_reset with function sample (bit psel);
    option.per_instance = 1;

    access_ongoing: coverpoint psel {option.comment = "An APB access was ongoing at reset";}
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

    wrap_cover_addr_0 = uvm_ext_cover_index_wrapper#(`CFS_APB_MAX_ADDR_WIDTH)::type_id::create(
        "wrap_cover_addr_0", this);
    wrap_cover_addr_1 = uvm_ext_cover_index_wrapper#(`CFS_APB_MAX_ADDR_WIDTH)::type_id::create(
        "wrap_cover_addr_1", this);
    wrap_cover_wr_data_0 = uvm_ext_cover_index_wrapper#(`CFS_APB_MAX_DATA_WIDTH)::type_id::create(
        "wrap_cover_wr_data_0", this);
    wrap_cover_wr_data_1 = uvm_ext_cover_index_wrapper#(`CFS_APB_MAX_DATA_WIDTH)::type_id::create(
        "wrap_cover_wr_data_1", this);
    wrap_cover_rd_data_0 = uvm_ext_cover_index_wrapper#(`CFS_APB_MAX_DATA_WIDTH)::type_id::create(
        "wrap_cover_rd_data_0", this);
    wrap_cover_rd_data_1 = uvm_ext_cover_index_wrapper#(`CFS_APB_MAX_DATA_WIDTH)::type_id::create(
        "wrap_cover_rd_data_1", this);
  endfunction

  virtual function void end_of_elaboration_phase(uvm_phase phase);
    super.end_of_elaboration_phase(phase);

    if ($cast(agent_config, super.agent_config) == 0) begin
      `uvm_fatal("ALGORITHM_ISSUE", $sformatf("Could not cast %0s to %0s",
                                              super.agent_config.get_type_name(),
                                              "cfs_apb_agent_config"))
    end
  endfunction

  virtual function void write_item(cfs_apb_item_mon item);
    cover_item.sample(item);

    for (int i = 0; i < `CFS_APB_MAX_ADDR_WIDTH; i++) begin
      if (item.addr[i]) begin
        wrap_cover_addr_1.sample(i);
      end else begin
        wrap_cover_addr_0.sample(i);
      end
    end

    for (int i = 0; i < `CFS_APB_MAX_DATA_WIDTH; i++) begin
      case (item.dir)
        CFS_APB_WRITE: begin
          if (item.data[i]) begin
            wrap_cover_wr_data_1.sample(i);
          end else begin
            wrap_cover_wr_data_0.sample(i);
          end
        end
        CFS_APB_READ: begin
          if (item.data[i]) begin
            wrap_cover_rd_data_1.sample(i);
          end else begin
            wrap_cover_rd_data_0.sample(i);
          end
        end
        default: begin
          `uvm_error("ALGORITHM_ISSUE", $sformatf(
                     "Current version of the code does not support item.dir: %0s", item.dir.name()))
        end
      endcase
    end
  endfunction

  virtual function void handle_reset(uvm_phase phase);
    cfs_apb_vif vif = agent_config.get_vif();

    cover_reset.sample(vif.psel);
  endfunction

  virtual function string coverage2string();
    string result = {
      $sformatf("\n    cover_item:            %03.2f%%", cover_item.get_inst_coverage()),
      $sformatf("\n      direction:           %03.2f%%", cover_item.direction.get_inst_coverage()),
      $sformatf(
          "\n      trans_direction:     %03.2f%%", cover_item.trans_direction.get_inst_coverage()
      ),
      $sformatf("\n      response:            %03.2f%%", cover_item.response.get_inst_coverage()),
      $sformatf(
          "\n      response_x_direction: %03.2f%%",
          cover_item.response_x_direction.get_inst_coverage()
      ),
      $sformatf("\n      length:              %03.2f%%", cover_item.length.get_inst_coverage()),
      $sformatf(
          "\n      prev_item_delay:     %03.2f%%", cover_item.prev_item_delay.get_inst_coverage()
      ),
      $sformatf("\n                                  "),
      $sformatf("\n    cover_reset:          %03.2f%%", cover_reset.get_inst_coverage()),
      $sformatf(
          "\n      access_ongoing:      %03.2f%%", cover_reset.access_ongoing.get_inst_coverage()
      ),
      super.coverage2string()
    };
    return result;
  endfunction

endclass

`endif  // CFS_APB_COVERAGE_SV
