# STEP#1: define the output directory area.
#
set outputDir ../Outputs
file mkdir $outputDir

# Check IP
if { [file isdirectory ../"IP"] } {
    # if the IP files exist, we already generated the IP, so we can just
    # read the ip definition (.xci)
    read_ip ../IP/sfix_19_16_to_float32.xci
} else {
    # IP folder does not exist. Create IP folder
    file mkdir ../IP

    # create_ip requires that a project is open in memory. Create project
    # but don't do anything with it
    create_project -in_memory

    # paste commands from Journal file to recreate IP
    create_ip -name clk_wiz -vendor xilinx.com -library ip \
        -version 6.0 -module_name pll_1 \
        -dir ../IP

    set_property -dict [list \
        CONFIG.CLKIN1_JITTER_PS {80.0} \
        CONFIG.CLKOUT1_DRIVES {BUFG} \
        CONFIG.CLKOUT1_JITTER {138.255} \
        CONFIG.CLKOUT1_PHASE_ERROR {222.305} \
        CONFIG.CLKOUT1_REQUESTED_OUT_FREQ {600} \
        CONFIG.CLKOUT2_DRIVES {BUFG} \
        CONFIG.CLKOUT2_JITTER {191.470} \
        CONFIG.CLKOUT2_PHASE_ERROR {222.305} \
        CONFIG.CLKOUT2_REQUESTED_OUT_FREQ {60} \
        CONFIG.CLKOUT2_USED {true} \
        CONFIG.CLKOUT3_DRIVES {BUFG} \
        CONFIG.CLKOUT4_DRIVES {BUFG} \
        CONFIG.CLKOUT5_DRIVES {BUFG} \
        CONFIG.CLKOUT6_DRIVES {BUFG} \
        CONFIG.CLKOUT7_DRIVES {BUFG} \
        CONFIG.CLK_IN1_BOARD_INTERFACE {Custom} \
        CONFIG.CLK_OUT1_PORT {clk_600MHz} \
        CONFIG.CLK_OUT2_PORT {clk_60MHz} \
        CONFIG.MMCM_BANDWIDTH {OPTIMIZED} \
        CONFIG.MMCM_CLKFBOUT_MULT_F {48} \
        CONFIG.MMCM_CLKIN1_PERIOD {8.000} \
        CONFIG.MMCM_CLKIN2_PERIOD {10.000} \
        CONFIG.MMCM_CLKOUT0_DIVIDE_F {2} \
        CONFIG.MMCM_CLKOUT1_DIVIDE {20} \
        CONFIG.MMCM_COMPENSATION {ZHOLD} \
        CONFIG.MMCM_DIVCLK_DIVIDE {5} \
        CONFIG.NUM_OUT_CLKS {2} \
        CONFIG.PRIMITIVE {PLL} \
        CONFIG.PRIM_IN_FREQ {125.000} \
    ] [get_ips pll_1]

    generate_target all [get_ips]

    # Synthesize all the IP
    synth_ip [get_ips]
}

#
# STEP#2: setup design sources and constraints
#
read_vhdl ../RTL/HDMI_Interposer.vhd
read_vhdl ../RTL/count_ones.vhd
read_vhdl ../RTL/TMDS_8b10b_encoder.vhd
read_vhdl ../RTL/TMDS_decoder.vhd
read_xdc ../Constraints/PYNQ_Z2_v1.xdc

#
# STEP#3: run synthesis, write design checkpoint, report timing, 
# and utilization estimates
#
synth_design -top HDMI_Interposer -part xc7z020clg400-1
write_checkpoint -force $outputDir/post_synth.dcp
report_timing_summary -file $outputDir/post_synth_timing_summary.rpt
report_utilization -file $outputDir/post_synth_util.rpt
#
# Run custom script to report critical timing paths
# reportCriticalPaths $outputDir/post_synth_critpath_report.csv #this is a custom command
#
# STEP#4: run logic optimization, placement and physical logic optimization, 
# write design checkpoint, report utilization and timing estimates
#
opt_design
# reportCriticalPaths $outputDir/post_opt_critpath_report.csv #this is a custom command
place_design
report_clock_utilization -file $outputDir/clock_util.rpt
#
# Optionally run optimization if there are timing violations after placement
if {[get_property SLACK [get_timing_paths -max_paths 1 -nworst 1 -setup]] < 0} {
    puts "Found setup timing violations => running physical optimization"
    phys_opt_design
}
write_checkpoint -force $outputDir/post_place.dcp
report_utilization -file $outputDir/post_place_util.rpt
report_timing_summary -file $outputDir/post_place_timing_summary.rpt
#
# STEP#5: run the router, write the post-route design checkpoint, report the routing
# status, report timing, power, and DRC, and finally save the Verilog netlist.
#
route_design
write_checkpoint -force $outputDir/post_route.dcp
report_route_status -file $outputDir/post_route_status.rpt
report_timing_summary -file $outputDir/post_route_timing_summary.rpt
report_power -file $outputDir/post_route_power.rpt
report_drc -file $outputDir/post_imp_drc.rpt
# write_verilog -force $outputDir/cpu_impl_netlist.v -mode timesim -sdf_anno true
#
# STEP#6: generate a bitstream
# 
write_bitstream -force $outputDir/cpu.bit
