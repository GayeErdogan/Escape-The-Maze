set_property PACKAGE_PIN W5 [get_ports clk]
set_property IOSTANDARD LVCMOS33 [get_ports clk]
create_clock -period 10.00 -name sys_clk_pin [get_ports clk]

# Seven-Segment Display (Anode ve Segmentler)
set_property PACKAGE_PIN U2 [get_ports anode[0]]
set_property IOSTANDARD LVCMOS33 [get_ports anode[0]]
set_property PACKAGE_PIN U4 [get_ports anode[1]]
set_property IOSTANDARD LVCMOS33 [get_ports anode[1]]
set_property PACKAGE_PIN V4 [get_ports anode[2]]
set_property IOSTANDARD LVCMOS33 [get_ports anode[2]]
set_property PACKAGE_PIN W4 [get_ports anode[3]]
set_property IOSTANDARD LVCMOS33 [get_ports anode[3]]

set_property PACKAGE_PIN W7 [get_ports seg[0]]
set_property IOSTANDARD LVCMOS33 [get_ports seg[0]]
set_property PACKAGE_PIN W6 [get_ports seg[1]]
set_property IOSTANDARD LVCMOS33 [get_ports seg[1]]
set_property PACKAGE_PIN U8 [get_ports seg[2]]
set_property IOSTANDARD LVCMOS33 [get_ports seg[2]]
set_property PACKAGE_PIN V8 [get_ports seg[3]]
set_property IOSTANDARD LVCMOS33 [get_ports seg[3]]
set_property PACKAGE_PIN U5 [get_ports seg[4]]
set_property IOSTANDARD LVCMOS33 [get_ports seg[4]]
set_property PACKAGE_PIN V5 [get_ports seg[5]]
set_property IOSTANDARD LVCMOS33 [get_ports seg[5]]
set_property PACKAGE_PIN U7 [get_ports seg[6]]
set_property IOSTANDARD LVCMOS33 [get_ports seg[6]]

# LED'ler
set_property PACKAGE_PIN U16 [get_ports led[0]]
set_property IOSTANDARD LVCMOS33 [get_ports led[0]]
set_property PACKAGE_PIN E19 [get_ports led[1]]
set_property IOSTANDARD LVCMOS33 [get_ports led[1]]
set_property PACKAGE_PIN U19 [get_ports led[2]]
set_property IOSTANDARD LVCMOS33 [get_ports led[2]]
set_property PACKAGE_PIN V19 [get_ports led[3]]
set_property IOSTANDARD LVCMOS33 [get_ports led[3]]
set_property PACKAGE_PIN W18 [get_ports led[4]]
set_property IOSTANDARD LVCMOS33 [get_ports led[4]]
set_property PACKAGE_PIN U15 [get_ports led[5]]
set_property IOSTANDARD LVCMOS33 [get_ports led[5]]
set_property PACKAGE_PIN U14 [get_ports led[6]]
set_property IOSTANDARD LVCMOS33 [get_ports led[6]]
set_property PACKAGE_PIN V14 [get_ports led[7]]
set_property IOSTANDARD LVCMOS33 [get_ports led[7]]

# Switch'ler
set_property PACKAGE_PIN V17 [get_ports switches[0]]
set_property IOSTANDARD LVCMOS33 [get_ports switches[0]]
set_property PACKAGE_PIN V16 [get_ports switches[1]]
set_property IOSTANDARD LVCMOS33 [get_ports switches[1]]
set_property PACKAGE_PIN W16 [get_ports switches[2]]
set_property IOSTANDARD LVCMOS33 [get_ports switches[2]]
set_property PACKAGE_PIN W17 [get_ports switches[3]]
set_property IOSTANDARD LVCMOS33 [get_ports switches[3]]
set_property PACKAGE_PIN R2 [get_ports switches[4]]
set_property IOSTANDARD LVCMOS33 [get_ports switches[4]]
set_property PACKAGE_PIN T1 [get_ports switches[5]]
set_property IOSTANDARD LVCMOS33 [get_ports switches[5]]


# UART RX

set_property -dict { PACKAGE_PIN B18   IOSTANDARD LVCMOS33 } [get_ports uart_rx]


# Mode Select
set_property PACKAGE_PIN T18 [get_ports mode_select]
set_property IOSTANDARD LVCMOS33 [get_ports mode_select]

# VGA Çıkışları
set_property PACKAGE_PIN P19 [get_ports hsync]
set_property IOSTANDARD LVCMOS33 [get_ports hsync]
set_property PACKAGE_PIN R19 [get_ports vsync]
set_property IOSTANDARD LVCMOS33 [get_ports vsync]

# Blue signals (B[3:0])
set_property PACKAGE_PIN N18 [get_ports {b[0]}]
set_property IOSTANDARD LVCMOS33 [get_ports {b[0]}]
set_property PACKAGE_PIN L18 [get_ports {b[1]}]
set_property IOSTANDARD LVCMOS33 [get_ports {b[1]}]
set_property PACKAGE_PIN K18 [get_ports {b[2]}]
set_property IOSTANDARD LVCMOS33 [get_ports {b[2]}]
set_property PACKAGE_PIN J18 [get_ports {b[3]}]
set_property IOSTANDARD LVCMOS33 [get_ports {b[3]}]

# Green signals (G[3:0])
set_property PACKAGE_PIN J17 [get_ports {g[0]}]
set_property IOSTANDARD LVCMOS33 [get_ports {g[0]}]
set_property PACKAGE_PIN H17 [get_ports {g[1]}]
set_property IOSTANDARD LVCMOS33 [get_ports {g[1]}]
set_property PACKAGE_PIN G17 [get_ports {g[2]}]
set_property IOSTANDARD LVCMOS33 [get_ports {g[2]}]
set_property PACKAGE_PIN D17 [get_ports {g[3]}]
set_property IOSTANDARD LVCMOS33 [get_ports {g[3]}]

# Red signals (R[3:0])
set_property PACKAGE_PIN G19 [get_ports {r[0]}]
set_property IOSTANDARD LVCMOS33 [get_ports {r[0]}]
set_property PACKAGE_PIN H19 [get_ports {r[1]}]
set_property IOSTANDARD LVCMOS33 [get_ports {r[1]}]
set_property PACKAGE_PIN J19 [get_ports {r[2]}]
set_property IOSTANDARD LVCMOS33 [get_ports {r[2]}]
set_property PACKAGE_PIN N19 [get_ports {r[3]}]
set_property IOSTANDARD LVCMOS33 [get_ports {r[3]}]
