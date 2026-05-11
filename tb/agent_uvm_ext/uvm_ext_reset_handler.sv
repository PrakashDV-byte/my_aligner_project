///////////////////////////////////////////////////////////////////////////////
// File:        uvm_ext_reset_handler.sv
// Author:      Cristian Florin Slav
// Date:        2024-03-22
// Description: Reset handler class
///////////////////////////////////////////////////////////////////////////////
`ifndef UVM_EXT_RESET_HANDLER_SV
`define UVM_EXT_RESET_HANDLER_SV 

  interface class uvm_ext_reset_handler;

  //Function to handle the reset
  pure virtual
  function void handle_reset(uvm_phase phase)
  ;

  endclass

`endif

