///////////////////////////////////////////////////////////////////////////////
// File:        cfs_algn_virtual_sequence_3_1_3.sv
// Author:      Pranav
// Date:        2025-06-27
// Description: Virtual sequence which configures IRQEN register to enable
//              all the 5 interrupts
///////////////////////////////////////////////////////////////////////////////
`ifndef CFS_ALGN_VIRTUAL_SEQUENCE_3_1_3_SV
`define CFS_ALGN_VIRTUAL_SEQUENCE_3_1_3_SV

class cfs_algn_virtual_sequence_3_1_3 extends cfs_algn_virtual_sequence_base;

  `uvm_object_utils(cfs_algn_virtual_sequence_3_1_3)

  function new(string name = "");
    super.new(name);
  endfunction

  virtual task body();
    uvm_reg registers[$];
    uvm_status_e status;

    // Fetch all registers
    p_sequencer.model.reg_block.get_registers(registers);

    // Filter out read-only registers
    for (int reg_idx = registers.size() - 1; reg_idx >= 0; reg_idx--) begin
      if (!(registers[reg_idx].get_rights() inside {"RW", "WO"})) begin
        registers.delete(reg_idx);
      end
    end

    // Randomize order of register writes
    registers.shuffle();

    foreach (registers[reg_idx]) begin
      uvm_reg current_reg = registers[reg_idx];
      uvm_reg_data_t read_val;

      if (current_reg.get_name() == "IRQEN") begin
        // Set only first 5 fields to 1
        uvm_reg_field fields[$];
        current_reg.get_fields(fields);

        foreach (fields[i]) begin
          if (i < 5) begin
            fields[i].set(1);
          end
        end

        current_reg.update(status);
        current_reg.read(status, read_val);
        `uvm_info("IRQEN_CHECK", $sformatf("Read back IRQEN = 0x%0h", read_val), UVM_MEDIUM);
      end else begin
        void'(current_reg.randomize());
        current_reg.update(status);
      end
    end
  endtask

endclass

`endif
