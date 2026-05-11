///////////////////////////////////////////////////////////////////////////////
// File:        cfs_algn_reg_irq.sv
// Author:      Cristian Florin Slav
// Date:        2024-05-27
// Description: Definition of the Interrupt Requests register
///////////////////////////////////////////////////////////////////////////////
`ifndef CFS_ALGN_REG_IRQ_SV
`define CFS_ALGN_REG_IRQ_SV 

class cfs_algn_reg_irq extends uvm_reg;

  rand uvm_reg_field RX_FIFO_EMPTY;

  rand uvm_reg_field RX_FIFO_FULL;

  rand uvm_reg_field TX_FIFO_EMPTY;

  rand uvm_reg_field TX_FIFO_FULL;

  rand uvm_reg_field MAX_DROP;

  `uvm_object_utils(cfs_algn_reg_irq)

  function new(string name = "");
    super.new(.name(name), .n_bits(32), .has_coverage(UVM_NO_COVERAGE));
  endfunction

  virtual function void build();
    RX_FIFO_EMPTY = uvm_reg_field::type_id::create(.name("RX_FIFO_EMPTY"), .parent(null), .contxt(
                                                   get_full_name()));
    RX_FIFO_FULL = uvm_reg_field::type_id::create(.name("RX_FIFO_FULL"), .parent(null), .contxt(
                                                  get_full_name()));
    TX_FIFO_EMPTY = uvm_reg_field::type_id::create(.name("TX_FIFO_EMPTY"), .parent(null), .contxt(
                                                   get_full_name()));
    TX_FIFO_FULL = uvm_reg_field::type_id::create(.name("TX_FIFO_FULL"), .parent(null), .contxt(
                                                  get_full_name()));
    MAX_DROP =
        uvm_reg_field::type_id::create(.name("MAX_DROP"), .parent(null), .contxt(get_full_name()));

    RX_FIFO_EMPTY.configure(.parent(this), .size(1), .lsb_pos(0), .access("W1C"), .volatile(0),
                            .reset(1'b0), .has_reset(1), .is_rand(1), .individually_accessible(0));

    RX_FIFO_FULL.configure(.parent(this), .size(1), .lsb_pos(1), .access("W1C"), .volatile(0),
                           .reset(1'b0), .has_reset(1), .is_rand(1), .individually_accessible(0));

    TX_FIFO_EMPTY.configure(.parent(this), .size(1), .lsb_pos(2), .access("W1C"), .volatile(0),
                            .reset(1'b0), .has_reset(1), .is_rand(1), .individually_accessible(0));

    TX_FIFO_FULL.configure(.parent(this), .size(1), .lsb_pos(3), .access("W1C"), .volatile(0),
                           .reset(1'b0), .has_reset(1), .is_rand(1), .individually_accessible(0));

    MAX_DROP.configure(.parent(this), .size(1), .lsb_pos(4), .access("W1C"), .volatile(0),
                       .reset(1'b0), .has_reset(1), .is_rand(1), .individually_accessible(0));
    RX_FIFO_EMPTY.value.rand_mode(1);
    RX_FIFO_FULL.value.rand_mode(1);
    TX_FIFO_EMPTY.value.rand_mode(1);
    TX_FIFO_FULL.value.rand_mode(1);
    MAX_DROP.value.rand_mode(1);
  endfunction
endclass

`endif

