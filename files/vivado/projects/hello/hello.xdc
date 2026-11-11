## Pins for hello on the Arty A7, from Digilent's master XDC.
## clk is the board's 100 MHz oscillator.
set_property PACKAGE_PIN E3 [get_ports clk]
create_clock -name sys_clk_pin -period 10.00 [get_ports clk]
## rst is BTN1.
set_property PACKAGE_PIN C9 [get_ports rst]
## btn is BTN0.
set_property PACKAGE_PIN D9 [get_ports btn]
## tx is the USB-UART line to the PC (uart_rxd_out).
set_property PACKAGE_PIN D10 [get_ports tx]
## Every pin uses 3.3 V signals.
set_property IOSTANDARD LVCMOS33 [get_ports {clk rst btn tx}]
