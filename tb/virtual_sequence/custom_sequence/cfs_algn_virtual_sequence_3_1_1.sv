///////////////////////////////////////////////////////////////////////////////
// File:        cfs_algn_virtual_sequence_3_1_1.sv
// Author:      Pranav
// Date:        2025-06-27
// Description: Virtual sequence which configures IRQEN register to enable
//              MAX_DROP interrupt by writing 0x10.
///////////////////////////////////////////////////////////////////////////////

`ifndef CFS_ALGN_VIRTUAL_SEQUENCE_3_1_1_SV
`define CFS_ALGN_VIRTUAL_SEQUENCE_3_1_1_SV

class cfs_algn_virtual_sequence_3_1_1 extends cfs_algn_virtual_sequence_base;

  `uvm_object_utils(cfs_algn_virtual_sequence_3_1_1)

  function new(string name = "");
    super.new(name);
  endfunction

  virtual task body();
    uvm_reg registers[$];
    uvm_status_e status;

    `uvm_info(get_type_name(), "Configuring IRQEN register to enable MAX_DROP", UVM_MEDIUM)

    // Get all registers
    p_sequencer.model.reg_block.get_registers(registers);

    // Iterate and find IRQEN, then write full value
    foreach (registers[i]) begin
      if (registers[i].get_name() == "IRQEN") begin
        registers[i].write(status, 32'h0000_0010);  // Set MAX_DROP = 1
        break;
      end
    end
  endtask

endclass

`endif

