coverage exclude -scope /testbench/dut -togglenode {prdata[20]} {prdata[21]} {prdata[22]} {prdata[23]} {prdata[24]} {prdata[25]} {prdata[26]} {prdata[27]} {prdata[28]} {prdata[29]}
coverage exclude -scope /testbench/dut -togglenode {prdata[30]} {prdata[31]}
coverage exclude -scope /testbench/dut -togglenode {prdata[12]} {prdata[13]} {prdata[14]} {prdata[15]}
coverage exclude -scope /testbench/dut/core -togglenode {prdata[20]} {prdata[21]} {prdata[22]} {prdata[23]} {prdata[24]} {prdata[25]} {prdata[26]} {prdata[27]} {prdata[28]} {prdata[29]}
coverage exclude -scope /testbench/dut/core -togglenode {prdata[30]} {prdata[31]}
coverage exclude -scope /testbench/dut/core -togglenode {prdata[12]} {prdata[13]} {prdata[14]} {prdata[15]}
coverage exclude -scope /testbench/dut/core/regs -togglenode {addr_aligned[0]} {addr_aligned[1]} {prdata[20]} {prdata[21]} {prdata[22]} {prdata[23]} {prdata[24]} {prdata[25]} {prdata[26]} {prdata[27]}
coverage exclude -scope /testbench/dut/core/regs -togglenode {prdata[28]} {prdata[29]} {prdata[30]} {prdata[31]}
coverage exclude -scope /testbench/dut/core/regs -togglenode {prdata[12]} {prdata[13]} {prdata[14]} {prdata[15]}

coverage exclude -scope /testbench/dut/core/regs -togglenode {status_rd_val[20]} {status_rd_val[21]} {status_rd_val[22]} {status_rd_val[23]} {status_rd_val[24]} {status_rd_val[25]} {status_rd_val[26]} {status_rd_val[27]} {status_rd_val[28]} {status_rd_val[29]} {status_rd_val[30]} {status_rd_val[31]}

coverage exclude -scope /testbench/dut/core/regs -togglenode {status_rd_val[12]} {status_rd_val[13]} {status_rd_val[14]} {status_rd_val[15]}
coverage exclude -scope /testbench/dut/core/regs -togglenode {ctrl_rd_val[20]} {ctrl_rd_val[21]} {ctrl_rd_val[22]} {ctrl_rd_val[23]} {ctrl_rd_val[24]} {ctrl_rd_val[25]} {ctrl_rd_val[26]} {ctrl_rd_val[27]} {ctrl_rd_val[28]} {ctrl_rd_val[29]} {ctrl_rd_val[30]} {ctrl_rd_val[31]}

coverage exclude -scope /testbench/dut/core/regs -togglenode {ctrl_rd_val[10]} {ctrl_rd_val[11]} {ctrl_rd_val[12]} {ctrl_rd_val[13]} {ctrl_rd_val[14]} {ctrl_rd_val[15]} {ctrl_rd_val[16]} {ctrl_rd_val[17]} {ctrl_rd_val[18]} {ctrl_rd_val[19]}
coverage exclude -scope /testbench/dut/core/regs -togglenode {ctrl_rd_val[3]} {ctrl_rd_val[4]} {ctrl_rd_val[5]} {ctrl_rd_val[6]} {ctrl_rd_val[7]}

coverage exclude -scope /testbench/dut/core/regs -togglenode {irq_rd_val[20]} {irq_rd_val[21]} {irq_rd_val[22]} {irq_rd_val[23]} {irq_rd_val[24]} {irq_rd_val[25]} {irq_rd_val[26]} {irq_rd_val[27]} {irq_rd_val[28]} {irq_rd_val[29]} {irq_rd_val[30]} {irq_rd_val[31]}
coverage exclude -scope /testbench/dut/core/regs -togglenode {irq_rd_val[10]} {irq_rd_val[11]} {irq_rd_val[12]} {irq_rd_val[13]} {irq_rd_val[14]} {irq_rd_val[15]} {irq_rd_val[16]} {irq_rd_val[17]} {irq_rd_val[18]} {irq_rd_val[19]}
coverage exclude -scope /testbench/dut/core/regs -togglenode {irq_rd_val[8]} {irq_rd_val[9]} {irq_rd_val[5]} {irq_rd_val[6]} {irq_rd_val[7]}

coverage exclude -scope /testbench/dut/core/regs -togglenode {irqen_rd_val[20]} {irqen_rd_val[21]} {irqen_rd_val[22]} {irqen_rd_val[23]} {irqen_rd_val[24]} {irqen_rd_val[25]} {irqen_rd_val[26]} {irqen_rd_val[27]} {irqen_rd_val[28]} {irqen_rd_val[29]} {irqen_rd_val[30]} {irqen_rd_val[31]}
coverage exclude -scope /testbench/dut/core/regs -togglenode {irqen_rd_val[10]} {irqen_rd_val[11]} {irqen_rd_val[12]} {irqen_rd_val[13]} {irqen_rd_val[14]} {irqen_rd_val[15]} {irqen_rd_val[16]} {irqen_rd_val[17]} {irqen_rd_val[18]} {irqen_rd_val[19]}
coverage exclude -scope /testbench/dut/core/regs -togglenode {irqen_rd_val[8]} {irqen_rd_val[9]} {irqen_rd_val[5]} {irqen_rd_val[6]} {irqen_rd_val[7]}

# Waive line 128 in tx_fifo
coverage exclude \
  -scope /testbench/dut/core/tx_fifo \
  -srcfile "../../rtl/cfs_synch_fifo.v" \
  -linerange 132 \
  -code c \
  -comment "Waiving uncovered condition at line 128 (tx_fifo)"
 
# Waive line 154 in tx_fifo
coverage exclude \
  -scope /testbench/dut/core/tx_fifo \
  -srcfile "../../rtl/cfs_synch_fifo.v" \
  -linerange 156 \
  -code c \
  -comment "Waiving uncovered condition at line 154 (tx_fifo)"
 
# Waive line 128 in rx_fifo
coverage exclude \
  -scope /testbench/dut/core/rx_fifo \
  -srcfile "../../rtl/cfs_synch_fifo.v" \
  -linerange 132 \
  -code c \
  -comment "Waiving uncovered condition at line 128 (rx_fifo)"
 
# Waive line 128 in rx_fifo
coverage exclude \
  -scope /testbench/dut/core/rx_ctrl \
  -srcfile "../../rtl/cfs_rx_ctrl.v" \
  -linerange 76 \
  -code c \
  -comment "Waiving uncovered condition at line 128 (rx_fifo)"
  
# Exclude toggle coverage for aligned_bytes_processed[2] in ctrl
coverage exclude \
  -scope /testbench/dut/core/ctrl \
  -togglenode {aligned_bytes_processed[2]} \
  -comment "Excluding toggle coverage for aligned_bytes_processed[2] in ctrl"
