## Pins for reg_en_planted on the Arty A7, from Digilent's master XDC.
## clk is the board's 100 MHz oscillator.
set_property PACKAGE_PIN E3 [get_ports clk]
create_clock -name sys_clk_pin -period 10.00 [get_ports clk]
## rst is button BTN0, and load is button BTN1.
set_property PACKAGE_PIN D9 [get_ports rst]
set_property PACKAGE_PIN C9 [get_ports load]
## d[0] to d[3] are switches SW0 to SW3.
set_property PACKAGE_PIN A8 [get_ports {d[0]}]
set_property PACKAGE_PIN C11 [get_ports {d[1]}]
set_property PACKAGE_PIN C10 [get_ports {d[2]}]
set_property PACKAGE_PIN A10 [get_ports {d[3]}]
## q[0] to q[3] are LEDs LD4 to LD7.
set_property PACKAGE_PIN H5 [get_ports {q[0]}]
set_property PACKAGE_PIN J5 [get_ports {q[1]}]
set_property PACKAGE_PIN T9 [get_ports {q[2]}]
set_property PACKAGE_PIN T10 [get_ports {q[3]}]
## All eleven pins use 3.3 V signals.
set_property IOSTANDARD LVCMOS33 [get_ports {clk rst load d[*] q[*]}]
