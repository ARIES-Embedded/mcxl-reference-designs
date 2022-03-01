## Generated SDC file "MCXL.out.sdc"

## Copyright (C) 2020  Intel Corporation. All rights reserved.
## Your use of Intel Corporation's design tools, logic functions 
## and other software and tools, and any partner logic 
## functions, and any output files from any of the foregoing 
## (including device programming or simulation files), and any 
## associated documentation or information are expressly subject 
## to the terms and conditions of the Intel Program License 
## Subscription Agreement, the Intel Quartus Prime License Agreement,
## the Intel FPGA IP License Agreement, or other applicable license
## agreement, including, without limitation, that your use is for
## the sole purpose of programming logic devices manufactured by
## Intel and sold by Intel or its authorized distributors.  Please
## refer to the applicable agreement for further details, at
## https://fpgasoftware.intel.com/eula.


## VENDOR  "Altera"
## PROGRAM "Quartus Prime"
## VERSION "Version 20.1.0 Build 711 06/05/2020 SJ Lite Edition"

## DATE    "Mon Jan 10 12:51:24 2022"

##
## DEVICE  "10CL055YU484I7G"
##


#**************************************************************
# Time Information
#**************************************************************

set_time_format -unit ns -decimal_places 3



#**************************************************************
# Create Clock
#**************************************************************

create_clock -name {altera_reserved_tck} -period 100.000 -waveform { 0.000 50.000 } [get_ports {altera_reserved_tck}]
create_clock -name {clk_25M} -period 40.000 -waveform { 0.000 20.000 } [get_ports {clk_25M}]

#**************************************************************
# Create Generated Clock
#**************************************************************


#**************************************************************
# Set Clock Latency
#**************************************************************



#**************************************************************
# Set Clock Uncertainty
#**************************************************************


#**************************************************************
# Set Clock Groups
#**************************************************************

set_clock_groups -asynchronous -group [get_clocks {altera_reserved_tck}] 
set_clock_groups -asynchronous -group [get_clocks {altera_reserved_tck}] 


#**************************************************************
# Set False Path
#**************************************************************
set_false_path -to [get_keepers {*altera_std_synchronizer:*|din_s1}]
set_false_path -from [get_registers {*|altera_tse_register_map_small:U_REG|command_config[9]}] -to [get_registers {*|altera_tse_mac_tx:U_TX|*}]
set_false_path -from [get_registers {*|altera_tse_register_map_small:U_REG|mac_0[*]}] -to [get_registers {*|altera_tse_mac_tx:U_TX|*}]
set_false_path -from [get_registers {*|altera_tse_register_map_small:U_REG|mac_1[*]}] -to [get_registers {*|altera_tse_mac_tx:U_TX|*}]
set_false_path -from [get_registers {*|altera_tse_register_map_small:U_REG|mac_0[*]}] -to [get_registers {*|altera_tse_mac_rx:U_RX|*}]
set_false_path -from [get_registers {*|altera_tse_register_map_small:U_REG|mac_1[*]}] -to [get_registers {*|altera_tse_mac_rx:U_RX|*}]
set_false_path -to [get_pins -nocase -compatibility_mode {*|altera_tse_reset_synchronizer:*|altera_tse_reset_synchronizer_chain*|clrn}]
set_false_path -to [get_pins -nocase -compatibility_mode {*|alt_rst_sync_uq1|altera_reset_synchronizer_int_chain*|clrn}]

#**************************************************************
# Set Multicycle Path
#**************************************************************


#**************************************************************
# Set Maximum Delay
#**************************************************************

set_max_delay -from [get_registers {*|altera_tse_top_w_fifo:U_MAC|altera_tse_tx_min_ff:U_TXFF|dout_reg_sft*}] -to [get_registers {*|altera_tse_top_w_fifo:U_MAC|altera_tse_top_1geth:U_GETH|altera_tse_mac_tx:U_TX|*}] 7.000
set_max_delay -from [get_registers {*|altera_tse_top_w_fifo:U_MAC|altera_tse_tx_min_ff:U_TXFF|eop_sft*}] -to [get_registers {*|altera_tse_top_w_fifo:U_MAC|altera_tse_top_1geth:U_GETH|altera_tse_mac_tx:U_TX|*}] 7.000
set_max_delay -from [get_registers {*|altera_tse_top_w_fifo:U_MAC|altera_tse_tx_min_ff:U_TXFF|sop_reg*}] -to [get_registers {*|altera_tse_top_w_fifo:U_MAC|altera_tse_top_1geth:U_GETH|altera_tse_mac_tx:U_TX|*}] 7.000
set_max_delay -from [get_registers *] -to [get_registers {*altera_eth_tse_std_synchronizer:*|altera_std_synchronizer_nocut:*|din_s1}] 100.000
set_max_delay -from [get_registers {qsys_vex:u0|qsys_vex_eth_tse_0:eth_tse_0|altera_eth_tse_mac:i_tse_mac|altera_tse_top_w_fifo_10_100_1000:U_MAC_TOP|altera_tse_top_w_fifo:U_MAC|altera_tse_tx_min_ff:U_TXFF|altera_tse_a_fifo_opt_1246:TX_DATA|altera_tse_gray_cnt:U_RD|g_out[*]}] -to [get_registers {*altera_tse_a_fifo_opt_1246:TX_DATA|altera_eth_tse_std_synchronizer_bundle:U_SYNC_1|altera_eth_tse_std_synchronizer:*|altera_std_synchronizer_nocut:*|din_s1*}] 100.000
set_max_delay -from [get_registers {qsys_vex:u0|qsys_vex_eth_tse_0:eth_tse_0|altera_eth_tse_mac:i_tse_mac|altera_tse_top_w_fifo_10_100_1000:U_MAC_TOP|altera_tse_top_w_fifo:U_MAC|altera_tse_tx_min_ff:U_TXFF|altera_tse_a_fifo_opt_1246:TX_DATA|altera_tse_gray_cnt:U_WRT|g_out[*]}] -to [get_registers {*altera_tse_a_fifo_opt_1246:TX_DATA|altera_eth_tse_std_synchronizer_bundle:U_SYNC_3|altera_eth_tse_std_synchronizer:*|altera_std_synchronizer_nocut:*|din_s1*}] 100.000
set_max_delay -from [get_registers {qsys_vex:u0|qsys_vex_eth_tse_0:eth_tse_0|altera_eth_tse_mac:i_tse_mac|altera_tse_top_w_fifo_10_100_1000:U_MAC_TOP|altera_tse_top_w_fifo:U_MAC|altera_tse_rx_min_ff:U_RXFF|altera_tse_a_fifo_opt_1246:RX_DATA|altera_tse_gray_cnt:U_RD|g_out[*]}] -to [get_registers {*altera_tse_a_fifo_opt_1246:RX_DATA|altera_eth_tse_std_synchronizer_bundle:U_SYNC_1|altera_eth_tse_std_synchronizer:*|altera_std_synchronizer_nocut:*|din_s1*}] 100.000
set_max_delay -from [get_registers {qsys_vex:u0|qsys_vex_eth_tse_0:eth_tse_0|altera_eth_tse_mac:i_tse_mac|altera_tse_top_w_fifo_10_100_1000:U_MAC_TOP|altera_tse_top_w_fifo:U_MAC|altera_tse_rx_min_ff:U_RXFF|altera_tse_a_fifo_opt_1246:RX_DATA|altera_tse_gray_cnt:U_WRT|g_out[*]}] -to [get_registers {*altera_tse_a_fifo_opt_1246:RX_DATA|altera_eth_tse_std_synchronizer_bundle:U_SYNC_3|altera_eth_tse_std_synchronizer:*|altera_std_synchronizer_nocut:*|din_s1*}] 100.000
set_max_delay -from [get_registers {qsys_vex:u0|qsys_vex_eth_tse_0:eth_tse_0|altera_eth_tse_mac:i_tse_mac|altera_tse_top_w_fifo_10_100_1000:U_MAC_TOP|altera_tse_top_w_fifo:U_MAC|altera_tse_tx_min_ff:U_TXFF|altera_tse_a_fifo_13:TX_STATUS|altera_tse_gray_cnt:U_WRT|g_out[*]}] -to [get_registers {*altera_tse_a_fifo_13:TX_STATUS|altera_eth_tse_std_synchronizer_bundle:U_SYNC_2|altera_eth_tse_std_synchronizer:*|altera_std_synchronizer_nocut:*|din_s1*}] 100.000
set_max_delay -from [get_registers {qsys_vex:u0|qsys_vex_eth_tse_0:eth_tse_0|altera_eth_tse_mac:i_tse_mac|altera_tse_top_w_fifo_10_100_1000:U_MAC_TOP|altera_tse_top_w_fifo:U_MAC|altera_tse_rx_min_ff:U_RXFF|altera_tse_a_fifo_34:RX_STATUS|wr_g_ptr_reg[*]}] -to [get_registers {*altera_tse_a_fifo_34:RX_STATUS|altera_eth_tse_std_synchronizer_bundle:U_SYNC_WR_G_PTR|altera_eth_tse_std_synchronizer:*|altera_std_synchronizer_nocut:*|din_s1*}] 100.000


#**************************************************************
# Set Minimum Delay
#**************************************************************

set_min_delay -from [get_registers *] -to [get_registers {*altera_eth_tse_std_synchronizer:*|altera_std_synchronizer_nocut:*|din_s1}] -100.000
set_min_delay -from [get_registers {qsys_vex:u0|qsys_vex_eth_tse_0:eth_tse_0|altera_eth_tse_mac:i_tse_mac|altera_tse_top_w_fifo_10_100_1000:U_MAC_TOP|altera_tse_top_w_fifo:U_MAC|altera_tse_tx_min_ff:U_TXFF|altera_tse_a_fifo_opt_1246:TX_DATA|altera_tse_gray_cnt:U_RD|g_out[*]}] -to [get_registers {*altera_tse_a_fifo_opt_1246:TX_DATA|altera_eth_tse_std_synchronizer_bundle:U_SYNC_1|altera_eth_tse_std_synchronizer:*|altera_std_synchronizer_nocut:*|din_s1*}] -100.000
set_min_delay -from [get_registers {qsys_vex:u0|qsys_vex_eth_tse_0:eth_tse_0|altera_eth_tse_mac:i_tse_mac|altera_tse_top_w_fifo_10_100_1000:U_MAC_TOP|altera_tse_top_w_fifo:U_MAC|altera_tse_tx_min_ff:U_TXFF|altera_tse_a_fifo_opt_1246:TX_DATA|altera_tse_gray_cnt:U_WRT|g_out[*]}] -to [get_registers {*altera_tse_a_fifo_opt_1246:TX_DATA|altera_eth_tse_std_synchronizer_bundle:U_SYNC_3|altera_eth_tse_std_synchronizer:*|altera_std_synchronizer_nocut:*|din_s1*}] -100.000
set_min_delay -from [get_registers {qsys_vex:u0|qsys_vex_eth_tse_0:eth_tse_0|altera_eth_tse_mac:i_tse_mac|altera_tse_top_w_fifo_10_100_1000:U_MAC_TOP|altera_tse_top_w_fifo:U_MAC|altera_tse_rx_min_ff:U_RXFF|altera_tse_a_fifo_opt_1246:RX_DATA|altera_tse_gray_cnt:U_RD|g_out[*]}] -to [get_registers {*altera_tse_a_fifo_opt_1246:RX_DATA|altera_eth_tse_std_synchronizer_bundle:U_SYNC_1|altera_eth_tse_std_synchronizer:*|altera_std_synchronizer_nocut:*|din_s1*}] -100.000
set_min_delay -from [get_registers {qsys_vex:u0|qsys_vex_eth_tse_0:eth_tse_0|altera_eth_tse_mac:i_tse_mac|altera_tse_top_w_fifo_10_100_1000:U_MAC_TOP|altera_tse_top_w_fifo:U_MAC|altera_tse_rx_min_ff:U_RXFF|altera_tse_a_fifo_opt_1246:RX_DATA|altera_tse_gray_cnt:U_WRT|g_out[*]}] -to [get_registers {*altera_tse_a_fifo_opt_1246:RX_DATA|altera_eth_tse_std_synchronizer_bundle:U_SYNC_3|altera_eth_tse_std_synchronizer:*|altera_std_synchronizer_nocut:*|din_s1*}] -100.000
set_min_delay -from [get_registers {qsys_vex:u0|qsys_vex_eth_tse_0:eth_tse_0|altera_eth_tse_mac:i_tse_mac|altera_tse_top_w_fifo_10_100_1000:U_MAC_TOP|altera_tse_top_w_fifo:U_MAC|altera_tse_tx_min_ff:U_TXFF|altera_tse_a_fifo_13:TX_STATUS|altera_tse_gray_cnt:U_WRT|g_out[*]}] -to [get_registers {*altera_tse_a_fifo_13:TX_STATUS|altera_eth_tse_std_synchronizer_bundle:U_SYNC_2|altera_eth_tse_std_synchronizer:*|altera_std_synchronizer_nocut:*|din_s1*}] -100.000
set_min_delay -from [get_registers {qsys_vex:u0|qsys_vex_eth_tse_0:eth_tse_0|altera_eth_tse_mac:i_tse_mac|altera_tse_top_w_fifo_10_100_1000:U_MAC_TOP|altera_tse_top_w_fifo:U_MAC|altera_tse_rx_min_ff:U_RXFF|altera_tse_a_fifo_34:RX_STATUS|wr_g_ptr_reg[*]}] -to [get_registers {*altera_tse_a_fifo_34:RX_STATUS|altera_eth_tse_std_synchronizer_bundle:U_SYNC_WR_G_PTR|altera_eth_tse_std_synchronizer:*|altera_std_synchronizer_nocut:*|din_s1*}] -100.000


#**************************************************************
# Set Input Transition
#**************************************************************



#**************************************************************
# Set Net Delay
#**************************************************************

set_net_delay -max 6.000 -from [get_pins -compatibility_mode {*|q}] -to [get_registers {*altera_eth_tse_std_synchronizer:*|altera_std_synchronizer_nocut:*|din_s1}]
set_net_delay -max 6.000 -from [get_pins -compatibility_mode {*altera_tse_a_fifo_opt_1246:TX_DATA|altera_tse_gray_cnt:U_RD|g_out[*]|q}] -to [get_registers {*altera_tse_a_fifo_opt_1246:TX_DATA|altera_eth_tse_std_synchronizer_bundle:U_SYNC_1|altera_eth_tse_std_synchronizer:*|altera_std_synchronizer_nocut:*|din_s1*}]
set_net_delay -max 6.000 -from [get_pins -compatibility_mode {*altera_tse_a_fifo_opt_1246:TX_DATA|altera_tse_gray_cnt:U_WRT|g_out[*]|q}] -to [get_registers {*altera_tse_a_fifo_opt_1246:TX_DATA|altera_eth_tse_std_synchronizer_bundle:U_SYNC_3|altera_eth_tse_std_synchronizer:*|altera_std_synchronizer_nocut:*|din_s1*}]
set_net_delay -max 6.000 -from [get_pins -compatibility_mode {*altera_tse_a_fifo_opt_1246:RX_DATA|altera_tse_gray_cnt:U_RD|g_out[*]|q}] -to [get_registers {*altera_tse_a_fifo_opt_1246:RX_DATA|altera_eth_tse_std_synchronizer_bundle:U_SYNC_1|altera_eth_tse_std_synchronizer:*|altera_std_synchronizer_nocut:*|din_s1*}]
set_net_delay -max 6.000 -from [get_pins -compatibility_mode {*altera_tse_a_fifo_opt_1246:RX_DATA|altera_tse_gray_cnt:U_WRT|g_out[*]|q}] -to [get_registers {*altera_tse_a_fifo_opt_1246:RX_DATA|altera_eth_tse_std_synchronizer_bundle:U_SYNC_3|altera_eth_tse_std_synchronizer:*|altera_std_synchronizer_nocut:*|din_s1*}]
set_net_delay -max 6.000 -from [get_pins -compatibility_mode {*altera_tse_a_fifo_13:TX_STATUS|altera_tse_gray_cnt:U_WRT|g_out[*]|q}] -to [get_registers {*altera_tse_a_fifo_13:TX_STATUS|altera_eth_tse_std_synchronizer_bundle:U_SYNC_2|altera_eth_tse_std_synchronizer:*|altera_std_synchronizer_nocut:*|din_s1*}]
set_net_delay -max 6.000 -from [get_pins -compatibility_mode {*altera_tse_a_fifo_34:RX_STATUS|wr_g_ptr_reg[*]|q}] -to [get_registers {*altera_tse_a_fifo_34:RX_STATUS|altera_eth_tse_std_synchronizer_bundle:U_SYNC_WR_G_PTR|altera_eth_tse_std_synchronizer:*|altera_std_synchronizer_nocut:*|din_s1*}]


#**************************************************************
# Set Max Skew
#**************************************************************

set_max_skew -from [get_registers {qsys_vex:u0|qsys_vex_eth_tse_0:eth_tse_0|altera_eth_tse_mac:i_tse_mac|altera_tse_top_w_fifo_10_100_1000:U_MAC_TOP|altera_tse_top_w_fifo:U_MAC|altera_tse_tx_min_ff:U_TXFF|altera_tse_a_fifo_opt_1246:TX_DATA|altera_tse_gray_cnt:U_RD|g_out[*]}] -to [get_registers {*altera_tse_a_fifo_opt_1246:TX_DATA|altera_eth_tse_std_synchronizer_bundle:U_SYNC_1|altera_eth_tse_std_synchronizer:*|altera_std_synchronizer_nocut:*|din_s1*}] 7.500 
set_max_skew -from [get_registers {qsys_vex:u0|qsys_vex_eth_tse_0:eth_tse_0|altera_eth_tse_mac:i_tse_mac|altera_tse_top_w_fifo_10_100_1000:U_MAC_TOP|altera_tse_top_w_fifo:U_MAC|altera_tse_tx_min_ff:U_TXFF|altera_tse_a_fifo_opt_1246:TX_DATA|altera_tse_gray_cnt:U_WRT|g_out[*]}] -to [get_registers {*altera_tse_a_fifo_opt_1246:TX_DATA|altera_eth_tse_std_synchronizer_bundle:U_SYNC_3|altera_eth_tse_std_synchronizer:*|altera_std_synchronizer_nocut:*|din_s1*}] 7.500 
set_max_skew -from [get_registers {qsys_vex:u0|qsys_vex_eth_tse_0:eth_tse_0|altera_eth_tse_mac:i_tse_mac|altera_tse_top_w_fifo_10_100_1000:U_MAC_TOP|altera_tse_top_w_fifo:U_MAC|altera_tse_rx_min_ff:U_RXFF|altera_tse_a_fifo_opt_1246:RX_DATA|altera_tse_gray_cnt:U_RD|g_out[*]}] -to [get_registers {*altera_tse_a_fifo_opt_1246:RX_DATA|altera_eth_tse_std_synchronizer_bundle:U_SYNC_1|altera_eth_tse_std_synchronizer:*|altera_std_synchronizer_nocut:*|din_s1*}] 7.500 
set_max_skew -from [get_registers {qsys_vex:u0|qsys_vex_eth_tse_0:eth_tse_0|altera_eth_tse_mac:i_tse_mac|altera_tse_top_w_fifo_10_100_1000:U_MAC_TOP|altera_tse_top_w_fifo:U_MAC|altera_tse_rx_min_ff:U_RXFF|altera_tse_a_fifo_opt_1246:RX_DATA|altera_tse_gray_cnt:U_WRT|g_out[*]}] -to [get_registers {*altera_tse_a_fifo_opt_1246:RX_DATA|altera_eth_tse_std_synchronizer_bundle:U_SYNC_3|altera_eth_tse_std_synchronizer:*|altera_std_synchronizer_nocut:*|din_s1*}] 7.500 
set_max_skew -from [get_registers {qsys_vex:u0|qsys_vex_eth_tse_0:eth_tse_0|altera_eth_tse_mac:i_tse_mac|altera_tse_top_w_fifo_10_100_1000:U_MAC_TOP|altera_tse_top_w_fifo:U_MAC|altera_tse_tx_min_ff:U_TXFF|altera_tse_a_fifo_13:TX_STATUS|altera_tse_gray_cnt:U_WRT|g_out[*]}] -to [get_registers {*altera_tse_a_fifo_13:TX_STATUS|altera_eth_tse_std_synchronizer_bundle:U_SYNC_2|altera_eth_tse_std_synchronizer:*|altera_std_synchronizer_nocut:*|din_s1*}] 7.500 
set_max_skew -from [get_registers {qsys_vex:u0|qsys_vex_eth_tse_0:eth_tse_0|altera_eth_tse_mac:i_tse_mac|altera_tse_top_w_fifo_10_100_1000:U_MAC_TOP|altera_tse_top_w_fifo:U_MAC|altera_tse_rx_min_ff:U_RXFF|altera_tse_a_fifo_34:RX_STATUS|wr_g_ptr_reg[*]}] -to [get_registers {*altera_tse_a_fifo_34:RX_STATUS|altera_eth_tse_std_synchronizer_bundle:U_SYNC_WR_G_PTR|altera_eth_tse_std_synchronizer:*|altera_std_synchronizer_nocut:*|din_s1*}] 7.500 


#**************************************************************
# Set Disable Timing
#**************************************************************

set_disable_timing -from * -to * [get_cells -hierarchical {AMGP4450_0}]
set_disable_timing -from * -to * [get_cells -hierarchical {TPOO7242_0}]
set_disable_timing -from * -to * [get_cells -hierarchical {TPOO7242_1}]
set_disable_timing -from * -to * [get_cells -hierarchical {TPOO7242_2}]
set_disable_timing -from * -to * [get_cells -hierarchical {TPOO7242_3}]
set_disable_timing -from * -to * [get_cells -hierarchical {TPOO7242_4}]
set_disable_timing -from * -to * [get_cells -hierarchical {TPOO7242_5}]
set_disable_timing -from * -to * [get_cells -hierarchical {TPOO7242_6}]
set_disable_timing -from * -to * [get_cells -hierarchical {TPOO7242_7}]
set_disable_timing -from * -to * [get_cells -hierarchical {ZNXJ5711_0}]
