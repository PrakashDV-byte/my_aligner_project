///////////////////////////////////////////////////////////////////////////////
// File:        cfs_algn_virtual_sequence_3_1_4.sv
// Author:      Pranav
// Date:        2025-06-27
// Description: Virtual sequence which configures CTRL register with size=4
//              and offset=0
///////////////////////////////////////////////////////////////////////////////
`ifndef CFS_ALGN_VIRTUAL_SEQUENCE_3_1_4_SV
`define CFS_ALGN_VIRTUAL_SEQUENCE_3_1_4_SV

class cfs_algn_virtual_sequence_3_1_4 extends cfs_algn_virtual_sequence_base;

  `uvm_object_utils(cfs_algn_virtual_sequence_3_1_4)

  function new(string name = "");
    super.new(name);
  endfunction

  virtual task body();
    uvm_reg registers[$];
    uvm_status_e status;
    uvm_reg_field fields[$];
    uvm_reg current_reg;
    uvm_reg_data_t val;

    `uvm_info(get_type_name(), "Setting CTRL.SIZE = 4 and CTRL.OFFSET = 0", UVM_MEDIUM)

    p_sequencer.model.reg_block.get_registers(registers);

    // Filter RW/WO registers
    for (int i = registers.size() - 1; i >= 0; i--) begin
      if (!(registers[i].get_rights() inside {"RW", "WO"})) registers.delete(i);
    end

    // Set CTRL.SIZE and CTRL.OFFSET specifically
    for (int i = 0; i < registers.size(); i++) begin
      current_reg = registers[i];
      if (current_reg.get_name() == "CTRL") begin
        current_reg.get_fields(fields);

        for (int j = 0; j < fields.size(); j++) begin
          if (fields[j].get_name() == "SIZE") fields[j].set(4);
          else if (fields[j].get_name() == "OFFSET") fields[j].set(0);
        end

        current_reg.update(status);
        current_reg.read(status, val);
        `uvm_info("3_1_4", $sformatf("CTRL configured, readback = 0x%0h", val), UVM_MEDIUM);
        break;  // exit after configuring CTRL
      end
    end
  endtask

endclass

`endif

