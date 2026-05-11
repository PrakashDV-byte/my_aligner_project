`ifndef CFS_MD_DRIVER_MASTER_SV
`define CFS_MD_DRIVER_MASTER_SV 

class cfs_md_driver_master #(
    int unsigned DATA_WIDTH = 32
) extends cfs_md_driver #(
    .DATA_WIDTH(DATA_WIDTH),
    .ITEM_DRV  (cfs_md_item_drv_master)
);

  typedef virtual cfs_md_if #(DATA_WIDTH) cfs_md_vif;

  `uvm_component_param_utils(cfs_md_driver_master#(DATA_WIDTH))

  function new(string name = "", uvm_component parent);
    super.new(name, parent);
  endfunction

  //Task which drives one single item on the bus
  protected virtual task drive_transaction(cfs_md_item_drv_master item);

    cfs_md_vif   vif = agent_config.get_vif();

    int unsigned data_width_in_bytes = DATA_WIDTH / 8;

    `uvm_info("ITEM_START", $sformatf("Driving \"%0s\": %0s", item.get_full_name(),
                                      item.convert2string()), UVM_LOW)

    if (item.offset + item.data.size() > data_width_in_bytes) begin
      `uvm_fatal(
          "ALGORITHM_ISSUE",
          $sformatf(
              "Trying to drive an item with offset %0d and %0d bytes but the width of the data bus, in bytes, is %0d",
              item.offset, item.data.size(), data_width_in_bytes))
    end

    for (int i = 0; i < item.pre_drive_delay; i++) begin
      @(posedge vif.clk);
    end

    vif.valid <= 1;

    begin
      bit [DATA_WIDTH-1:0] data = 0;

      foreach (item.data[idx]) begin
        bit [DATA_WIDTH-1:0] temp = item.data[idx] << ((item.offset + idx) * 8);

        data = data | temp;
      end

      vif.data <= data;
    end

    vif.offset <= item.offset;
    vif.size   <= item.data.size();

    @(posedge vif.clk);

    while (vif.ready !== 1) begin
      @(posedge vif.clk);
    end

    vif.valid  <= 0;
    vif.data   <= 0;
    vif.offset <= 0;
    vif.size   <= 0;

    for (int i = 0; i < item.post_drive_delay; i++) begin
      @(posedge vif.clk);
    end
  endtask

  //Function to handle the reset
  virtual function void handle_reset(uvm_phase phase);
    cfs_md_vif vif = agent_config.get_vif();

    super.handle_reset(phase);

    vif.valid  <= 0;
    vif.data   <= 0;
    vif.offset <= 0;
    vif.size   <= 0;

  endfunction

endclass

`endif  // CFS_MD_DRIVER_MASTER_SV
