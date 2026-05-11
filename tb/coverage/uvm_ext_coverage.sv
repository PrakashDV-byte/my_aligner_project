///////////////////////////////////////////////////////////////////////////////
// File:        uvm_ext_coverage.sv
// Author:      Cristian Florin Slav
// Date:        2024-03-26
// Description: Generic coverage class
///////////////////////////////////////////////////////////////////////////////
`ifndef UVM_EXT_COVERAGE_SV
`define UVM_EXT_COVERAGE_SV 

`uvm_analysis_imp_decl(_item)

virtual class uvm_ext_cover_index_wrapper_base extends uvm_component;

  function new(string name = "", uvm_component parent);
    super.new(name, parent);
  endfunction

  //Function used to sample the information
  pure virtual function void sample (int unsigned value);

  //Function to print the coverage information.
  //This is only to be able to visualize some basic coverage information
  //in EDA Playground.
  //DON'T DO THIS IN A REAL PROJECT!!!
  pure virtual function string coverage2string();
endclass

//Wrapper over the covergroup which covers indices.
//The MAX_VALUE parameter is used to determine the maximum value to sample
class uvm_ext_cover_index_wrapper #(
    int unsigned MAX_VALUE_PLUS_1 = 16
) extends uvm_ext_cover_index_wrapper_base;

  `uvm_component_param_utils(uvm_ext_cover_index_wrapper#(MAX_VALUE_PLUS_1))

  covergroup cover_index with function sample (int unsigned value);
    option.per_instance = 1;

    index: coverpoint value {
      option.comment = "Index"; bins values[MAX_VALUE_PLUS_1] = {[0 : MAX_VALUE_PLUS_1 - 1]};
    }

  endgroup

  function new(string name = "", uvm_component parent);
    super.new(name, parent);

    cover_index = new();
    cover_index.set_inst_name($sformatf("%s_%s", get_full_name(), "cover_index"));
  endfunction

  //Function to print the coverage information.
  //This is only to be able to visualize some basic coverage information
  //in EDA Playground.
  //DON'T DO THIS IN A REAL PROJECT!!!
  virtual function string coverage2string();
    return {
      $sformatf("\n   cover_index:              %03.2f%%", cover_index.get_inst_coverage()),
      $sformatf("\n      index:                 %03.2f%%", cover_index.index.get_inst_coverage())
    };
  endfunction

  //Function used to sample the information
  virtual function void sample (int unsigned value);
    cover_index.sample(value);
  endfunction

endclass

class uvm_ext_coverage #(
    type VIRTUAL_INTF = int,
    type ITEM_MON = uvm_sequence_item
) extends uvm_component implements uvm_ext_reset_handler;

  //Pointer to agent configuration
  uvm_ext_agent_config #(VIRTUAL_INTF) agent_config;

  //Port for receiving the collected item
  uvm_analysis_imp_item #(ITEM_MON, uvm_ext_coverage #(VIRTUAL_INTF, ITEM_MON)) port_item;

  `uvm_component_param_utils(uvm_ext_coverage#(VIRTUAL_INTF, ITEM_MON))

  function new(string name = "", uvm_component parent);
    super.new(name, parent);

    port_item = new("port_item", this);
  endfunction

  //Port associated with port_item port
  virtual function void write_item(ITEM_MON item);

  endfunction

  //Function to handle the reset
  virtual function void handle_reset(uvm_phase phase);

  endfunction

  //Function to print the coverage information.
  //This is only to be able to visualize some basic coverage information
  //in EDA Playground.
  //DON'T DO THIS IN A REAL PROJECT!!!
  virtual function string coverage2string();
    string result = "";

    uvm_component children[$];

    get_children(children);

    foreach (children[idx]) begin
      uvm_ext_cover_index_wrapper_base wrapper;

      if ($cast(wrapper, children[idx])) begin
        result = $sformatf("%s\n\nChild component: %0s%0s", result, wrapper.get_name(),
                           wrapper.coverage2string());
      end
    end

    return result;
  endfunction

  virtual function void report_phase(uvm_phase phase);
    super.report_phase(phase);

    //IMPORTANT: DON'T DO THIS IN A REAL PROJECT!!!
    `uvm_info("COVERAGE", $sformatf("Coverage: %0s", coverage2string()), UVM_DEBUG)
  endfunction

endclass
`endif

