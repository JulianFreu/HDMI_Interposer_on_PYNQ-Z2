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
        CONFIG.CLKOUT1_DRIVES {BUFG} \
        CONFIG.CLKOUT1_JITTER {139.033} \
        CONFIG.CLKOUT1_PHASE_ERROR {87.180} \
        CONFIG.CLKOUT1_REQUESTED_OUT_FREQ {40} \
        CONFIG.CLKOUT2_DRIVES {BUFG} \
        CONFIG.CLKOUT2_JITTER {90.074} \
        CONFIG.CLKOUT2_PHASE_ERROR {87.180} \
        CONFIG.CLKOUT2_REQUESTED_OUT_FREQ {400} \
        CONFIG.CLKOUT2_USED {true} \
        CONFIG.CLKOUT3_DRIVES {BUFG} \
        CONFIG.CLKOUT4_DRIVES {BUFG} \
        CONFIG.CLKOUT5_DRIVES {BUFG} \
        CONFIG.CLKOUT6_DRIVES {BUFG} \
        CONFIG.CLKOUT7_DRIVES {BUFG} \
        CONFIG.CLK_OUT1_PORT {clk_40MHz} \
        CONFIG.CLK_OUT2_PORT {clk_400MHz} \
        CONFIG.Component_Name {pll_1} \
        CONFIG.MMCM_BANDWIDTH {OPTIMIZED} \
        CONFIG.MMCM_CLKFBOUT_MULT_F {12} \
        CONFIG.MMCM_CLKOUT0_DIVIDE_F {30} \
        CONFIG.MMCM_CLKOUT1_DIVIDE {3} \
        CONFIG.MMCM_COMPENSATION {ZHOLD} \
        CONFIG.MMCM_DIVCLK_DIVIDE {1} \
        CONFIG.NUM_OUT_CLKS {2} \
        CONFIG.PRIMITIVE {PLL} \
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
synth_design -top HDMI_Interposer -part xc7z020clg400-1 -rtl
start_gui
