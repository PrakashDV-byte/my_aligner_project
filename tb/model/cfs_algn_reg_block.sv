//////////////////////////////////////////////////////////////////////////////
// File:        cfs_algn_reg_block.sv
// Author:      Cristian Florin Slav
// Date:        2024-06-19
// Description: Register block
///////////////////////////////////////////////////////////////////////////////
`ifndef CFS_ALGN_REG_BLOCK_SV
`define CFS_ALGN_REG_BLOCK_SV 

class cfs_algn_reg_block extends uvm_reg_block;

  rand cfs_algn_reg_ctrl   CTRL;

  rand cfs_algn_reg_status STATUS;

  rand cfs_algn_reg_irqen  IRQEN;

  rand cfs_algn_reg_irq    IRQ;


  `uvm_object_utils(cfs_algn_reg_block)

  function new(string name = "");
    super.new(name, UVM_NO_COVERAGE);
  endfunction

  virtual function void build();
    default_map = create_map(
        .name("apb_map"),
        .base_addr('h0000),
        .n_bytes(4),
        .endian(UVM_LITTLE_ENDIAN),
        .byte_addressing(1)
    );

    default_map.set_check_on_read(1);

    CTRL =
        cfs_algn_reg_ctrl::type_id::create(.name("CTRL"), .parent(null), .contxt(get_full_name()));
    STATUS = cfs_algn_reg_status::type_id::create(.name("STATUS"), .parent(null), .contxt(
                                                  get_full_name()));
    IRQEN = cfs_algn_reg_irqen::type_id::create(.name("IRQEN"), .parent(null), .contxt(
                                                get_full_name()));
    IRQ = cfs_algn_reg_irq::type_id::create(.name("IRQ"), .parent(null), .contxt(get_full_name()));

    CTRL.configure(.blk_parent(this));
    STATUS.configure(.blk_parent(this));
    IRQEN.configure(.blk_parent(this));
    IRQ.configure(.blk_parent(this));

    CTRL.build();
    STATUS.build();
    IRQEN.build();
    IRQ.build();

    default_map.add_reg(.rg(CTRL), .offset('h0000), .rights("RW"));
    default_map.add_reg(.rg(STATUS), .offset('h000C), .rights("RO"));   //changed the address to `h000C from `h0008
    default_map.add_reg(.rg(IRQEN), .offset('h00F0), .rights("RW"));
    default_map.add_reg(.rg(IRQ), .offset('h00F4), .rights("RW"));

  endfunction

endclass

`endif
