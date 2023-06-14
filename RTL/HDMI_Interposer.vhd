Library UNISIM;
use UNISIM.vcomponents.all;

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
-- use ieee.math_real.all;

entity HDMI_Interposer is
    port (
        sysclk : in std_logic;
        reset  : in std_logic;
        led4_g : out std_logic;
        led4_r : out std_logic;
        led5_b : out std_logic;

        hdmi_tx_d_p : out std_ulogic_vector(2 downto 0);
        hdmi_tx_d_n : out std_ulogic_vector(2 downto 0);

        hdmi_tx_clk_p : out std_ulogic;
        hdmi_tx_clk_n : out std_ulogic
    );
end HDMI_Interposer;

architecture behaviour of HDMI_Interposer is

    component pll_1
        port
         (-- Clock in ports
          -- Clock out ports
          clk_400MHz         : out    std_logic;
          clk_40MHz          : out    std_logic;
          -- Status and control signals
          reset             : in     std_logic;
          locked            : out    std_logic;
          clk_in1           : in     std_logic
         );
    end component;
 
    component DVI_Transmitter is
        port (
            i_pix_clk   : in std_logic;     -- 40 MHz
            i_bit_clk   : in std_logic;     -- 400 MHz
            i_reset     : in std_logic;
            o_red       : out std_logic;
            o_green     : out std_logic;
            o_blue      : out std_logic        
        );
    end component;

    signal w_hdmi_tx    : std_ulogic_vector(2 downto 0);
    signal w_hdmi_tx_clk : std_ulogic;
 
    signal w_reset : std_logic;
    signal w_pix_clk : std_logic;
    signal w_bit_clk : std_logic;
    signal w_locked : std_logic;
    signal w_sysclk : std_logic;

    signal w_red    : std_logic;
    signal w_green  : std_logic;
    signal w_blue   : std_logic;

begin
    clocks: pll_1
    port map ( 
    -- Clock out ports  
        clk_400MHz => w_bit_clk,
        clk_40MHz => w_pix_clk,
    -- Status and control signals                
        reset => w_reset,
        locked => w_locked,
        -- Clock in ports
        clk_in1 => w_sysclk
    );
    
    generate_data_buffers : for i in 0 to 2 generate 
        tx_buf : OBUFDS
            generic map (
                IOSTANDARD => "DEFAULT",        -- Specify the output I/O standard
                SLEW => "SLOW")                 -- Specify the output slew rate
            port map (
                O => hdmi_tx_d_p(i),      -- Diff_p output (connect directly to top-level port)
                OB => hdmi_tx_d_n(i),     -- Diff_n output (connect directly to top-level port)
                I => w_hdmi_tx(i)                  -- Buffer input 
            );
    end generate;

    hdmi_clk_out : OBUFDS 
        generic map (
            IOSTANDARD => "DEFAULT", -- Specify the output I/O standard
            SLEW => "SLOW")          -- Specify the output slew rate
        port map (
            O => hdmi_tx_clk_p,     -- Diff_p output (connect directly to top-level port)
            OB => hdmi_tx_clk_n,   -- Diff_n output (connect directly to top-level port)
            I => w_clk_40MHz      -- Buffer input 
        );

    w_hdmi_tx(0) <= w_red;
    w_hdmi_tx(1) <= w_green;
    w_hdmi_tx(2) <= w_blue;

    w_sysclk <= sysclk;
    w_reset <= reset;
    
    led4_r <= not w_locked;
    led4_g <= w_locked;
    
    led5_b <= w_reset;
    
end architecture;
    
