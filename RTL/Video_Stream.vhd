Library UNISIM;
use UNISIM.vcomponents.all;

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
-- use ieee.math_real.all;

entity Video_Stream is
    port (
        sysclk : in std_logic;
        reset  : in std_logic := '1';
        led4_g : out std_logic;
        led4_r : out std_logic;
        led5_b : out std_logic;

        hdmi_tx_d_p : out std_ulogic_vector(2 downto 0);
        hdmi_tx_d_n : out std_ulogic_vector(2 downto 0);

        hdmi_tx_clk_p : out std_ulogic;
        hdmi_tx_clk_n : out std_ulogic
    );
end Video_Stream;

architecture behaviour of Video_Stream is

    component pll_1
        port
         (-- Clock in ports
          -- Clock out ports
          clk_400MHz            : out    std_logic;
          clk_40MHz             : out    std_logic;
          clk_40MHz_shifted     : out std_logic;
          -- Status and control signals
          reset             : in     std_logic;
          locked            : out    std_logic;
          clk_in1           : in     std_logic
         );
        end component;

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

    component Serializer is
        port (
            i_clk : in std_logic;
            i_reset : in std_logic;
            i_parallel_load : in std_logic;
            i_data_in : in std_logic_vector (9 downto 0);
            i_shift : in std_logic;
            o_data_out : out std_logic
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

    component Deserializer is
        port (
            i_bit_clk : in std_logic;
            i_reset : in std_logic;
            o_data_out : out std_logic_vector (9 downto 0);
            i_data_in : in std_logic
        );
        end component;

    component package_pixel is
        port (
            i_pix_clk : in std_logic;
            i_reset : in std_logic;
            i_hsync : in std_logic;
            i_red     : in std_logic_vector(7 downto 0);
            i_green : in std_logic_vector(7 downto 0);
            i_blue : in std_logic_vector(7 downto 0);
            o_data_out : out std_logic_vector (24 downto 0)
        );
        end component;

    component depackage_pixel is
        port (
            o_pix_clk : out std_logic;
            o_reset : out std_logic;
            o_hsync : out std_logic;
            o_red     : out std_logic_vector(7 downto 0);
            o_green : out std_logic_vector(7 downto 0);
            o_blue : out std_logic_vector(7 downto 0);
            i_data_in : in std_logic_vector (24 downto 0)
        );
        end component;
    signal w_hdmi_tx        : std_ulogic_vector(2 downto 0);
    signal w_hdmi_tx_clk    : std_ulogic;
 
    signal w_reset              : std_logic;
    signal w_pix_clk            : std_logic;
    signal w_pix_clk_shifted    : std_logic;
    signal w_bit_clk            : std_logic;
    signal w_locked             : std_logic;
    signal w_sysclk             : std_logic;

    signal w_red    : std_logic;
    signal w_green  : std_logic;
    signal w_blue   : std_logic;

begin
    clocks: pll_1
        port map ( 
        -- Clock out ports  
            clk_400MHz          => w_bit_clk,
            clk_40MHz           => w_pix_clk,
            clk_40MHz_shifted   => w_pix_clk_shifted,
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
            I => w_pix_clk      -- Buffer input 
        );

    DVI_Tx : DVI_Transmitter
        port map (
            i_pix_clk           => w_pix_clk,   
            i_bit_clk           => w_bit_clk,
            i_pix_clk_shifted   => w_pix_clk_shifted,
            i_reset             => w_reset,
            o_red               => w_red,
            o_green             => w_green,
            o_blue              => w_blue
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
    
