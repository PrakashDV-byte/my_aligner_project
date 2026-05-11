# exclude_coverage.tcl

# Disable toggle coverage for prdata reserved bits
coverage exclude -type toggle -name "prdata[10]"
coverage exclude -type toggle -name "prdata[11]"
coverage exclude -type toggle -name "prdata[12]"
coverage exclude -type toggle -name "prdata[13]"
coverage exclude -type toggle -name "prdata[14]"
coverage exclude -type toggle -name "prdata[15]"

coverage exclude -type toggle -name "prdata[17]"
coverage exclude -type toggle -name "prdata[18]"

coverage exclude -type toggle -name "prdata[20]"
coverage exclude -type toggle -name "prdata[21]"
coverage exclude -type toggle -name "prdata[22]"
coverage exclude -type toggle -name "prdata[23]"
coverage exclude -type toggle -name "prdata[24]"
coverage exclude -type toggle -name "prdata[25]"
coverage exclude -type toggle -name "prdata[26]"
coverage exclude -type toggle -name "prdata[27]"
coverage exclude -type toggle -name "prdata[28]"
coverage exclude -type toggle -name "prdata[29]"
coverage exclude -type toggle -name "prdata[30]"
coverage exclude -type toggle -name "prdata[31]"

