Library UNISIM;
use UNISIM.vcomponents.all;

library ieee;
use ieee.std_logic_1164.all;
-- use ieee.numeric_std.all;
-- use ieee.math_real.all;

entity HDMI_Interposer is
    port (
        
    );
end HDMI_Interposer;

architecture behaviour of HDMI_Interposer is
    component TMDS_8b10b_encoder is 
        port (
            i_clk           : in std_logic;
            i_data_enable   : in std_logic;
            i_C0            : in std_logic;
            i_C1            : in std_logic;
            i_data          : in std_logic_vector(7 downto 0);
            o_data          : out std_logic_vector(9 downto 0)
        );
    end component;

    component TMDS_decoder is 
        port (
            i_data          : in std_logic_vector(9 downto 0);
            o_data          : out std_logic_vector(7 downto 0);
            o_data_enable   : out std_logic;
            o_C0            : out std_logic;
            o_C1            : out std_logic;
            i_clk           : in std_logic
        );
    end component;

    signal w_data_link  : std_logic_vector(9 downto 0);


begin

    generate_data_buffers : for i in 0 to 2 generate 
        rx_buf_i : IBUFDS 
        generic map (
            DIFF_TERM => FALSE,             -- Differential Termination 
            IBUF_LOW_PWR => TRUE,           -- Low power (TRUE) vs. performance (FALSE) setting for referenced I/O standards
            IOSTANDARD => "DEFAULT")
        port map (
            O => O,                 -- Buffer output
            I => hdmi_rx_d_p(i),      -- Diff_p buffer input (connect directly to top-level port)
            IB => hdmi_rx_d_n(i)      -- Diff_n buffer input (connect directly to top-level port)
        );
        
        tx_buf_i : OBUFDS
        generic map (
            IOSTANDARD => "DEFAULT",        -- Specify the output I/O standard
            SLEW => "SLOW")                 -- Specify the output slew rate
        port map (
            O => hdmi_tx_d_p(i),      -- Diff_p output (connect directly to top-level port)
            OB => hdmi_tx_d_n(i),     -- Diff_n output (connect directly to top-level port)
            I => I                  -- Buffer input 
        );
    end generate;

    hdmi_clk_in : IBUFDS 
        generic map (
            DIFF_TERM => FALSE,             -- Differential Termination 
            IBUF_LOW_PWR => TRUE,           -- Low power (TRUE) vs. performance (FALSE) setting for referenced I/O standards
            IOSTANDARD => "DEFAULT")
        port map (
            O => O,                 -- Buffer output
            I => hdmi_rx_clk_p,      -- Diff_p buffer input (connect directly to top-level port)
            IB => hdmi_rx_clk_n      -- Diff_n buffer input (connect directly to top-level port)
        );

    hdmi_clk_out : IBUFDS 
        generic map (
            DIFF_TERM => FALSE,             -- Differential Termination 
            IBUF_LOW_PWR => TRUE,           -- Low power (TRUE) vs. performance (FALSE) setting for referenced I/O standards
            IOSTANDARD => "DEFAULT")
        port map (
            O => O,                 -- Buffer output
            I => hdmi_tx_clk_p,      -- Diff_p buffer input (connect directly to top-level port)
            IB => hdmi_tx_clk_n      -- Diff_n buffer input (connect directly to top-level port)
        );
    generate_decoder : for i in 0 to 2 generate

    end generate;
    
    generate_encoder : for i in 0 to 2 generate

    end generate;

end architecture;
    
