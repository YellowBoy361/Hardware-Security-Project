## Nexys4DDR Constraints File for 4-bit Adder with UART

## Clock signal (100 MHz)
set_property -dict { PACKAGE_PIN E3    IOSTANDARD LVCMOS33 } [get_ports { i_Clock }];
create_clock -add -name sys_clk_pin -period 10.00 -waveform {0 5} [get_ports {i_Clock}];

## Reset Button (BTNC - Center button)
set_property -dict { PACKAGE_PIN N17   IOSTANDARD LVCMOS33 } [get_ports { i_Reset }];

## USB-UART Interface
set_property -dict { PACKAGE_PIN D4   IOSTANDARD LVCMOS33 } [get_ports { o_Tx_Serial }];
set_property -dict { PACKAGE_PIN C4   IOSTANDARD LVCMOS33 } [get_ports { i_Rx_Serial }];

# LEDs for debugging
set_property -dict { PACKAGE_PIN H17   IOSTANDARD LVCMOS33 } [get_ports { Current_State[0] }];
set_property -dict { PACKAGE_PIN K15   IOSTANDARD LVCMOS33 } [get_ports { Current_State[1] }];
set_property -dict { PACKAGE_PIN J13   IOSTANDARD LVCMOS33 } [get_ports { Current_State[2] }];
#set_property -dict { PACKAGE_PIN N14   IOSTANDARD LVCMOS33 } [get_ports { Current_State[3] }];


## Configuration options
set_property CONFIG_VOLTAGE 3.3 [current_design]
set_property CFGBVS VCCO [current_design]

## Timing constraints
set_property CLOCK_DEDICATED_ROUTE FALSE [get_nets i_Reset_IBUF]