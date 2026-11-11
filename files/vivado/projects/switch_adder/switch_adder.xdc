## Pins for switch_adder on the Arty A7, from Digilent's master XDC.
## a[0] to a[3] are switches SW0 to SW3.
set_property PACKAGE_PIN A8 [get_ports {a[0]}]
set_property PACKAGE_PIN C11 [get_ports {a[1]}]
set_property PACKAGE_PIN C10 [get_ports {a[2]}]
set_property PACKAGE_PIN A10 [get_ports {a[3]}]
## b[0] to b[3] are buttons BTN0 to BTN3.
set_property PACKAGE_PIN D9 [get_ports {b[0]}]
set_property PACKAGE_PIN C9 [get_ports {b[1]}]
set_property PACKAGE_PIN B9 [get_ports {b[2]}]
set_property PACKAGE_PIN B8 [get_ports {b[3]}]
## low[0] to low[3] are LEDs LD4 to LD7.
set_property PACKAGE_PIN H5 [get_ports {low[0]}]
set_property PACKAGE_PIN J5 [get_ports {low[1]}]
set_property PACKAGE_PIN T9 [get_ports {low[2]}]
set_property PACKAGE_PIN T10 [get_ports {low[3]}]
## carry is the green of RGB LED LD0.
set_property PACKAGE_PIN F6 [get_ports carry]
## big is the blue of RGB LED LD1.
set_property PACKAGE_PIN G4 [get_ports big]
## All fourteen pins use 3.3 V signals.
set_property IOSTANDARD LVCMOS33 [get_ports {a[*] b[*] low[*] carry big}]
