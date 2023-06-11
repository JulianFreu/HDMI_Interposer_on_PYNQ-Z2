create_clock -period 8.000 [get_ports {clk_in1}]
create_generated_clock -source [get_ports -no_traverse clk_in1] -edges {1 2 3} -edge_shift {0.000 4.000 8.000} [get_ports -no_traverse {clk_62_5MHz}]
create_generated_clock -source [get_ports -no_traverse clk_in1] -edges {1 2 3} -edge_shift {0.000 -3.200 -6.400} [get_ports -no_traverse {clk_625MHz}]
set_property -quiet IO_BUFFER_TYPE NONE [get_ports -quiet clk_in1]
set_property -quiet CLOCK_BUFFER_TYPE NONE [get_ports -quiet clk_in1]
set_property -quiet IS_IP_OOC_CELL TRUE [get_cells -of [get_ports -no_traverse -quiet clk_625MHz]]
