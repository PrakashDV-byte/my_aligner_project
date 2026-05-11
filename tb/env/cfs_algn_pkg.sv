///////////////////////////////////////////////////////////////////////////////
// File:        cfs_algn_pkg.sv
// Author:      Cristian Florin Slav
// Date:        2023-06-27
// Description: Environment package.
///////////////////////////////////////////////////////////////////////////////
`ifndef CFS_ALGN_PKG_SV
`define CFS_ALGN_PKG_SV 

`include "uvm_macros.svh"

`include "../agent_uvm_ext/uvm_ext_pkg.sv"
`include "../agent_apb/cfs_apb_pkg.sv"
`include "../agent_md/cfs_md_pkg.sv"
`include "../model/cfs_algn_reg_pkg.sv"
`include "../model/cfs_algn_if.sv"
package cfs_algn_pkg;
  import uvm_pkg::*;
  import uvm_ext_pkg::*;
  import cfs_apb_pkg::*;
  import cfs_md_pkg::*;
  import cfs_algn_reg_pkg::*;

  `include "../model/cfs_algn_types.sv"
  `include "cfs_algn_env_config.sv"
  `include "../model/cfs_algn_clr_cnt_drop.sv"
  `include "../coverage/cfs_algn_split_info.sv"
  `include "../model/cfs_algn_model.sv"
  `include "../coverage/cfs_algn_coverage.sv"
  `include "../model/cfs_algn_reg_access_status_info.sv"
  `include "../model/cfs_algn_reg_predictor.sv"
  `include "../model/cfs_apb_reg_adapter.sv"
  `include "../scoreboard/cfs_algn_scoreboard.sv"
  `include "../virtual_sequence/cfs_algn_virtual_sequencer.sv"
  `include "cfs_algn_env.sv"

  `include "../model/cfs_algn_seq_reg_config.sv"
  `include "../virtual_sequence/cfs_algn_virtual_sequence_base.sv"
  `include "../virtual_sequence/cfs_algn_virtual_sequence_slow_pace.sv"
  `include "../virtual_sequence/cfs_algn_virtual_sequence_reg_access_random.sv"
  `include "../virtual_sequence/cfs_algn_virtual_sequence_reg_access_unmapped.sv"
  `include "../virtual_sequence/cfs_algn_virtual_sequence_reg_config.sv"
  `include "../virtual_sequence/cfs_algn_virtual_sequence_reg_status.sv"
  `include "../virtual_sequence/cfs_algn_virtual_sequence_rx.sv"
  `include "../virtual_sequence/cfs_algn_virtual_sequence_rx_err.sv"
  `include "../virtual_sequence/cfs_algn_virtual_sequence_rx_crt.sv"
  `include "../virtual_sequence/cfs_algn_virtual_sequence_rx_crt1.sv"
  `include "../virtual_sequence/cfs_algn_virtual_sequence_rx_crt2.sv"
  `include "../virtual_sequence/cfs_algn_virtual_sequence_rx_size1_offset0.sv"
  `include "../virtual_sequence/cfs_algn_virtual_sequence_rx_size1_offset3.sv"
  `include "../virtual_sequence/cfs_algn_virtual_sequence_rx_size2_offset2.sv"
  `include "../virtual_sequence/cfs_algn_virtual_sequence_rx_size2_offset0.sv"
    `include "../virtual_sequence/cfs_algn_virtual_sequence_rx_size0.sv"
  `include "../virtual_sequence/cfs_algn_virtual_sequence_split_cover_directed.sv"
  `include "../virtual_sequence/cfs_algn_virtual_sequence_ctrl4_off0_two_pkts.sv"
  `include "../virtual_sequence/cfs_algn_virtual_sequence_split_cross_cover_directed.sv"
  `include "../virtual_sequence/cfs_algn_virtual_sequence_split_legal_combinations.sv"
    `include "../virtual_sequence/cfs_algn_virtual_sequence_rx_rand_comb.sv"
  

  `include "../virtual_sequence/custom_sequence/cfs_algn_virtual_sequence_3_1_1.sv"
  `include "../virtual_sequence/custom_sequence/cfs_algn_virtual_sequence_3_1_5.sv"
  `include "../virtual_sequence/custom_sequence/cfs_algn_virtual_sequence_3_1_3.sv"
  `include "../virtual_sequence/custom_sequence/cfs_algn_virtual_sequence_3_1_4.sv"
endpackage

`endif
