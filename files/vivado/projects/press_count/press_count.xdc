## Pins and clocks for press_count_top on the Arty A7, from Digilent's
## master XDC.
## clk is the board's 100 MHz oscillator.
set_property PACKAGE_PIN E3 [get_ports clk]
create_clock -name sys_clk_pin -period 10.00 [get_ports clk]
## The MMCM's output clock. Vivado works out its period from the MMCM's
## settings, 33.375 ns; this line only gives it a name.
create_generated_clock -name clk_b [get_pins mmcm/CLKOUT0]
## Every path from one clock to the other goes through a synchroniser,
## so Vivado must not time them, although the clocks are related (UG903).
set_clock_groups -asynchronous \
    -group [get_clocks sys_clk_pin] -group [get_clocks clk_b]
## btn is BTN0 and rst_btn is BTN1.
set_property PACKAGE_PIN D9 [get_ports btn]
set_property PACKAGE_PIN C9 [get_ports rst_btn]
## led[0] to led[3] are LD4 to LD7.
set_property PACKAGE_PIN H5 [get_ports {led[0]}]
set_property PACKAGE_PIN J5 [get_ports {led[1]}]
set_property PACKAGE_PIN T9 [get_ports {led[2]}]
set_property PACKAGE_PIN T10 [get_ports {led[3]}]
## Every pin uses 3.3 V signals.
set_property IOSTANDARD LVCMOS33 [get_ports {clk btn rst_btn led[*]}]
