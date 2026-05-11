///////////////////////////////////////////////////////////////////////////////
// File:        cfs_md_pkg.sv
// Author:      Cristian Florin Slav
// Date:        2023-12-02
// Description: MD Agent package.
///////////////////////////////////////////////////////////////////////////////
`ifndef CFS_MD_PKG_SV
`define CFS_MD_PKG_SV 

`include "uvm_macros.svh"

`include "../interface/cfs_md_if.sv"

`include "../agent_uvm_ext/uvm_ext_pkg.sv"

package cfs_md_pkg;

  import uvm_pkg::*;
  import uvm_ext_pkg::*;
  `include "cfs_md_types.sv"  //


  `include "../transaction/cfs_md_item_base.sv"
  `include "../transaction/cfs_md_item_drv.sv"
  `include "../transaction/cfs_md_item_drv_master.sv"
  `include "../transaction/cfs_md_item_drv_slave.sv"
  `include "../transaction/cfs_md_item_mon.sv"

  `include "cfs_md_agent_config.sv"  //
  `include "cfs_md_agent_config_slave.sv"  //
  `include "cfs_md_agent_config_master.sv"  //
  `include "cfs_md_monitor.sv"  //
  `include "../coverage/cfs_md_coverage.sv"
  `include "cfs_md_sequencer_base.sv"  //
  `include "cfs_md_sequencer_base_master.sv"  //
  `include "cfs_md_sequencer_master.sv"  //
  `include "cfs_md_sequencer_base_slave.sv"  //
  `include "cfs_md_sequencer_slave.sv"  //
  `include "cfs_md_driver.sv"  //
  `include "cfs_md_driver_master.sv"  //
  `include "cfs_md_driver_slave.sv"  //
  `include "cfs_md_agent.sv"  //
  `include "cfs_md_agent_slave.sv"  //
  `include "cfs_md_agent_master.sv"  //

  `include "../sequence/cfs_md_sequence_base.sv"
  `include "../sequence/cfs_md_sequence_base_slave.sv"
  `include "../sequence/cfs_md_sequence_base_master.sv"
  `include "../sequence/cfs_md_sequence_simple_master.sv"
  `include "../sequence/cfs_md_sequence_simple_slave.sv"
  `include "../sequence/cfs_md_sequence_slave_response.sv"
  `include "../sequence/cfs_md_sequence_slave_response_forever.sv"
  `include "../sequence/cfs_md_sequence_length_4.sv"
  `include "../sequence/cfs_md_sequence_fixed_delay.sv"
  `include "../sequence/cfs_md_sequence_tx_ready_block.sv"
  `include "../sequence/cfs_md_sequence_length_directed_7.sv"
  `include "../sequence/cfs_md_sequence_length_directed_8.sv"
  `include "../sequence/cfs_md_sequence_length_directed_9.sv"
  `include "../sequence/cfs_md_sequence_length_directed_10.sv"
endpackage

`endif
