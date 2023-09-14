# part: xc7k160tffg676-2

# General configuration
set_property CFGBVS VCCO                               [current_design]
set_property CONFIG_VOLTAGE 3.3                        [current_design]
set_property BITSTREAM.GENERAL.COMPRESS true           [current_design]
set_property BITSTREAM.CONFIG.UNUSEDPIN Pullup         [current_design]

# 50 MHz system clock
set_property -dict {LOC G17  IOSTANDARD LVCMOS33} [get_ports clk_50mhz]
create_clock -period 20 -name clk_50mhz [get_ports clk_50mhz]

# SFP+ Interfaces
#set_property -dict {LOC R4   } [get_ports sfp_1_rx_p] 
#set_property -dict {LOC R3   } [get_ports sfp_1_rx_n] 
#set_property -dict {LOC P2   } [get_ports sfp_1_tx_p] 
#set_property -dict {LOC P1   } [get_ports sfp_1_tx_n] 

set_property -dict {LOC J4   } [get_ports sfp_1_rx_p] 
set_property -dict {LOC J3   } [get_ports sfp_1_rx_n] 
set_property -dict {LOC H2   } [get_ports sfp_1_tx_p] 
set_property -dict {LOC H1   } [get_ports sfp_1_tx_n] 

# 156.25 MHz MGT reference clock
set_property -dict {LOC H6   } [get_ports sfp_mgt_refclk_p] ;# MGTREFCLK0P_115
set_property -dict {LOC H5   } [get_ports sfp_mgt_refclk_n] ;# MGTREFCLK0N_115

#set_property -dict {LOC L18  IOSTANDARD LVCMOS33 PULLUP true} [get_ports sfp_1_los]
#set_property -dict {LOC J10  IOSTANDARD LVCMOS33 SLEW SLOW DRIVE 12} [get_ports sfp_1_tx_disable]

set_property -dict {LOC J11  IOSTANDARD LVCMOS33 PULLUP true} [get_ports sfp_1_los]
set_property -dict {LOC J13  IOSTANDARD LVCMOS33 SLEW SLOW DRIVE 12} [get_ports sfp_1_tx_disable]

set_false_path -from [get_ports {get_ports sfp_1_los}]
set_input_delay 0 [get_ports {get_ports sfp_1_los}]
set_false_path -to [get_ports {get_ports sfp_1_tx_disable}]
set_output_delay 0 [get_ports {get_ports sfp_1_tx_disable}]

