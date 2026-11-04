## Pins for harness on the Arty A7, from Digilent's master XDC.
## clk is the board's 100 MHz oscillator.
set_property PACKAGE_PIN E3 [get_ports clk]
create_clock -name sys_clk_pin -period 10.00 [get_ports clk]
## btn is BTN1, the reset.
set_property PACKAGE_PIN C9 [get_ports btn]
## rx is the USB-UART line from the computer (uart_txd_in); tx is the
## line to the computer (uart_rxd_out).
set_property PACKAGE_PIN A9 [get_ports rx]
set_property PACKAGE_PIN D10 [get_ports tx]
## led is LD4.
set_property PACKAGE_PIN H5 [get_ports led]
## Every pin uses 3.3 V signals.
set_property IOSTANDARD LVCMOS33 [get_ports {clk btn rx tx led}]
