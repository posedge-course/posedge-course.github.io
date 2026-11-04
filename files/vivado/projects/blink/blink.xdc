## Pins for blink on the Arty A7, from Digilent's master XDC.
## clk is the board's 100 MHz oscillator.
set_property PACKAGE_PIN E3 [get_ports clk]
create_clock -name sys_clk_pin -period 10.00 [get_ports clk]
## rst is button BTN0.
set_property PACKAGE_PIN D9 [get_ports rst]
## run is switch SW0.
set_property PACKAGE_PIN A8 [get_ports run]
## led is LED LD4.
set_property PACKAGE_PIN H5 [get_ports led]
## All four pins use 3.3 V signals.
set_property IOSTANDARD LVCMOS33 [get_ports {clk rst run led}]
