///////////////////////////////////////////////////////////////////////////////
// File:        cfs_algn_reg_pkg.sv
// Author:      Cristian Florin Slav
// Date:        2024-05-27
// Description: Package containing the register definitions for the registers
//              in the Aligner module.
///////////////////////////////////////////////////////////////////////////////
`ifndef CFS_ALGN_REG_PKG_SV
`define CFS_ALGN_REG_PKG_SV 

package cfs_algn_reg_pkg;
  import uvm_pkg::*;

  `include "cfs_algn_reg_ctrl.sv"
  `include "cfs_algn_reg_status.sv"
  `include "cfs_algn_reg_irqen.sv"
  `include "cfs_algn_reg_irq.sv"
  `include "cfs_algn_reg_block.sv"

endpackage

`endif
