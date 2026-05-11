onerror {resume}
quietly WaveActivateNextPane {} 0

# Add all signals from testbench
add wave -recursive /testbench/*

# Optionally group by interface
add wave -group APB_IF /testbench/apb_if/*
add wave -group MD_RX_IF /testbench/md_rx_if/*
add wave -group MD_TX_IF /testbench/md_tx_if/*
add wave -group ALGN_IF /testbench/algn_if/*
add wave -group DUT /testbench/dut/*

TreeUpdate [SetDefaultTree]
update
