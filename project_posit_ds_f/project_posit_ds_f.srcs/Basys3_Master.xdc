# Clock pin (100 MHz onboard clock)
set_property PACKAGE_PIN W5 [get_ports clk]
set_property IOSTANDARD LVCMOS33 [get_ports clk]
create_clock -add -name sys_clk_pin -period 10.00 -waveform {0 5} [get_ports clk]

# Reset button (BTNC - center button)
set_property PACKAGE_PIN U18 [get_ports reset]
set_property IOSTANDARD LVCMOS33 [get_ports reset]

# UART Receive (RxD) - Connected to one of the Pmod connectors
set_property PACKAGE_PIN A18 [get_ports RxD]  # Pmod Header J_C1 (Pin 1)
set_property IOSTANDARD LVCMOS33 [get_ports RxD]


set_property PACKAGE_PIN B18 [get_ports TxD]  
set_property IOSTANDARD LVCMOS33 [get_ports TxD]



