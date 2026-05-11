///////////////////////////////////////////////////////////////////////////////
// File:        cfs_apb_pkg.sv
// Author:      Cristian Florin Slav
// Date:        2023-07-05
// Description: APB Agent package.
///////////////////////////////////////////////////////////////////////////////
`ifndef CFS_APB_PKG_SV
`define CFS_APB_PKG_SV 

`include "uvm_macros.svh"

`include "../interface/cfs_apb_if.sv"
`include "../agent_uvm_ext/uvm_ext_pkg.sv"
package cfs_apb_pkg;
  import uvm_pkg::*;
  import uvm_ext_pkg::*;
  `include "cfs_apb_types.sv"  //
  `include "../transaction/cfs_apb_item_base.sv"
  `include "../transaction/cfs_apb_item_drv.sv"
  `include "../transaction/cfs_apb_item_mon.sv"
  `include "cfs_apb_agent_config.sv"  //
  `include "cfs_apb_monitor.sv"  //
  `include "../coverage/cfs_apb_coverage.sv"
  `include "cfs_apb_driver.sv"  //

  `include "cfs_apb_agent.sv"  //
  `include "../sequence/cfs_apb_sequence_base.sv"
  `include "../sequence/cfs_apb_sequence_simple.sv"
  `include "../sequence/cfs_apb_sequence_rw.sv"
  `include "../sequence/cfs_apb_sequence_random.sv"
endpackage

`endif

