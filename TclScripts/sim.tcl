# Create a new project
create_project pll_simulation ./pll_simulation -part xc7z020clg400-1 -force

# Set the target language to VHDL
set_property target_language VHDL [current_project]

# Add the .xci file to the project
add_files ../IP/pll_1/pll_1.xci

# Add the testbench file to the project
add_files ../Sim/pll_1_tb.vhd

# IP sources need to be synthesized before they can be used in a simulation.
# The 'generate_target' command synthesizes the IP.
generate_target {synthesis simulation} [get_files ../IP/pll_1/pll_1.xci]
# Wait for all the IPs to finish synthesizing.
catch {wait_on_run [get_runs synth_1]}

# Set the top module
set_property top pll_1_tb [current_fileset]

# Launch the simulation
launch_simulation
