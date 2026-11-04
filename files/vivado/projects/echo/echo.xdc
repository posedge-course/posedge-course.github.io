## Pins for echo on the Arty A7, from Digilent's master XDC.
## clk is the board's 100 MHz oscillator.
set_property PACKAGE_PIN E3 [get_ports clk]
create_clock -name sys_clk_pin -period 10.00 [get_ports clk]
## btn is BTN1, the reset; sw is SW0, hold.
set_property PACKAGE_PIN C9 [get_ports btn]
set_property PACKAGE_PIN A8 [get_ports sw]
## rx is the USB-UART line from the computer (uart_txd_in); tx is the
## line to the computer (uart_rxd_out).
set_property PACKAGE_PIN A9 [get_ports rx]
set_property PACKAGE_PIN D10 [get_ports tx]
## count[0] to count[2] are LD4 to LD6; lost is LD7.
set_property PACKAGE_PIN H5 [get_ports {count[0]}]
set_property PACKAGE_PIN J5 [get_ports {count[1]}]
set_property PACKAGE_PIN T9 [get_ports {count[2]}]
set_property PACKAGE_PIN T10 [get_ports lost]
## Every pin uses 3.3 V signals.
set_property IOSTANDARD LVCMOS33 [get_ports {clk btn sw rx tx lost}]
set_property IOSTANDARD LVCMOS33 [get_ports {count[*]}]
