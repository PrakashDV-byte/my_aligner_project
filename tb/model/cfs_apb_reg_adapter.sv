///////////////////////////////////////////////////////////////////////////////
// File:        cfs_apb_reg_adapter.sv
// Author:      Cristian Florin Slav
// Date:        2024-07-09
// Description: Transaction adapter for the APB protocol
///////////////////////////////////////////////////////////////////////////////
`ifndef CFS_APB_REG_ADAPTER_SV
`define CFS_APB_REG_ADAPTER_SV 

class cfs_apb_reg_adapter extends uvm_reg_adapter;

  `uvm_object_utils(cfs_apb_reg_adapter)

  function new(string name = "");
    super.new(name);
  endfunction

  virtual function void bus2reg(uvm_sequence_item bus_item, ref uvm_reg_bus_op rw);
    cfs_apb_item_mon item_mon;
    cfs_apb_item_drv item_drv;

    if ($cast(item_mon, bus_item)) begin
      rw.kind   = item_mon.dir == CFS_APB_WRITE ? UVM_WRITE : UVM_READ;

      rw.addr   = item_mon.addr;
      rw.data   = item_mon.data;
      rw.status = item_mon.response == CFS_APB_OKAY ? UVM_IS_OK : UVM_NOT_OK;
    end else if ($cast(item_drv, bus_item)) begin
      rw.kind   = item_drv.dir == CFS_APB_WRITE ? UVM_WRITE : UVM_READ;

      rw.addr   = item_drv.addr;
      rw.data   = item_drv.data;
      rw.status = UVM_IS_OK;
    end else begin
      `uvm_fatal("ALGORITHM_ISSUE", $sformatf("Class not supported: %0s", bus_item.get_type_name()))
    end

  endfunction

  virtual function uvm_sequence_item reg2bus(const ref uvm_reg_bus_op rw);
    cfs_apb_item_drv item = cfs_apb_item_drv::type_id::create("item");

    void'(item.randomize() with {
      item.dir == (rw.kind == UVM_WRITE) ? CFS_APB_WRITE : CFS_APB_READ;
      item.data == rw.data;
      item.addr == rw.addr;
    });

    return item;
  endfunction

endclass

`endif
