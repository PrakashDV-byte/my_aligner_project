///////////////////////////////////////////////////////////////////////////////
// File:        cfs_algn_virtual_sequence_3_1_5.sv
// Author:      Pranav
// Date:        2025-06-27
// Description: Virtual sequence to verify reserved RO bits in CTRL register
///////////////////////////////////////////////////////////////////////////////

`ifndef CFS_ALGN_VIRTUAL_SEQUENCE_3_1_5_SV
`define CFS_ALGN_VIRTUAL_SEQUENCE_3_1_5_SV

class cfs_algn_virtual_sequence_3_1_5 extends cfs_algn_virtual_sequence_base;

  `uvm_object_utils(cfs_algn_virtual_sequence_3_1_5)

  function new(string name = "");
    super.new(name);
  endfunction

  virtual task body();
    uvm_status_e status;
    uvm_reg_data_t pre_write_data, post_write_data, write_data;
    bit [4:0] pre_bits, post_bits;

    // Step 1: Read CTRL register
    `uvm_info(get_type_name(), "Reading CTRL before reserved bit write", UVM_MEDIUM)
    p_sequencer.model.reg_block.CTRL.read(status, pre_write_data, UVM_FRONTDOOR);

    // Step 2: Attempt to write 1s into reserved bits [7:3]
    write_data = pre_write_data | 32'h0000_00F8;  // bits 7:3 = 11111
    `uvm_info(get_type_name(), $sformatf("Attempting to write reserved bits as 1s: %0h",
                                         write_data), UVM_MEDIUM)
    p_sequencer.model.reg_block.CTRL.write(status, write_data, UVM_FRONTDOOR);

    // Step 3: Read CTRL register again
    p_sequencer.model.reg_block.CTRL.read(status, post_write_data, UVM_FRONTDOOR);

    // Step 4: Extract bits 7:3 and verify they remain 0
    pre_bits  = pre_write_data[7:3];
    post_bits = post_write_data[7:3];

    if (post_bits !== 5'b00000) begin
      `uvm_error(get_type_name(), $sformatf("RO Reserved bits changed! Expected 0, got %0b",
                                            post_bits))
    end else begin
      `uvm_info(get_type_name(), "RO Reserved bits verified correctly as unchanged (0)", UVM_LOW)
    end
  endtask

endclass

`endif

