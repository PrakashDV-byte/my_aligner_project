///////////////////////////////////////////////////////////////////////////////
// File:        uvm_ext_agent_config.sv
// Author:      Cristian Florin Slav
// Date:        2024-03-18
// Description: Agent configuration class
///////////////////////////////////////////////////////////////////////////////
`ifndef UVM_EXT_AGENT_CONFIG_SV
`define UVM_EXT_AGENT_CONFIG_SV 

class uvm_ext_agent_config #(
    type VIRTUAL_INTF = int
) extends uvm_component;

  //Virtual interface
  protected VIRTUAL_INTF vif;

  //Active/Passive control
  protected uvm_active_passive_enum active_passive;

  //Switch to enable coverage
  protected bit has_coverage;

  //Switch to enable checks
  protected bit has_checks;

  `uvm_component_param_utils(uvm_ext_agent_config#(VIRTUAL_INTF))

  function new(string name = "", uvm_component parent);
    super.new(name, parent);

    active_passive = UVM_ACTIVE;
    has_coverage   = 1;
    has_checks     = 1;
  endfunction

  //Getter for the virtual interface
  virtual function VIRTUAL_INTF get_vif();
    return vif;
  endfunction

  //Setter for the APB virtual interface
  virtual function void set_vif(VIRTUAL_INTF value);
    if (vif == null) begin
      vif = value;
    end else begin
      `uvm_fatal("ALGORITHM_ISSUE", "Trying to set the virtual interface more than once")
    end
  endfunction

  //Getter for the Active/Passive control
  virtual function uvm_active_passive_enum get_active_passive();
    return active_passive;
  endfunction

  //Setter for the Active/Passive control
  virtual function void set_active_passive(uvm_active_passive_enum value);
    active_passive = value;
  endfunction

  //Getter for the has_coverage control field
  virtual function bit get_has_coverage();
    return has_coverage;
  endfunction

  //Setter for the has_coverage control field
  virtual function void set_has_coverage(bit value);
    has_coverage = value;
  endfunction

  //Getter for the has_checks control field
  virtual function bit get_has_checks();
    return has_checks;
  endfunction

  //Setter for the has_checks control field
  virtual function void set_has_checks(bit value);
    has_checks = value;
  endfunction

  virtual function void start_of_simulation_phase(uvm_phase phase);
    super.start_of_simulation_phase(phase);

    if (get_vif() == null) begin
      `uvm_fatal("ALGORITHM_ISSUE",
                 "The APB virtual interface is not configured at \"Start of simulation\" phase")
    end else begin
      `uvm_info("CONFIG",
                "The APB virtual interface is configured at \"Start of simulation\" phase",
                UVM_FULL)
    end
  endfunction

  //Task for waiting the reset to start
  virtual task wait_reset_start();
    `uvm_fatal("ALGORITHM_ISSUE", "One must implement wait_reset_start() task")
  endtask

  //Task for waiting the reset to be finished
  virtual task wait_reset_end();
    `uvm_fatal("ALGORITHM_ISSUE", "One must implement wait_reset_end() task")
  endtask

endclass

`endif

