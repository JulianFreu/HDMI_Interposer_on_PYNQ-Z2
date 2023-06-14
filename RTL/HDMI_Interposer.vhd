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
        --hdmi_rx_d_p : in std_ulogic_vector(2 downto 0);
        --hdmi_rx_d_n : in std_ulogic_vector(2 downto 0);
        hdmi_tx_d_p : out std_ulogic_vector(2 downto 0);
        hdmi_tx_d_n : out std_ulogic_vector(2 downto 0);
        --hdmi_rx_clk_p : in std_ulogic;
        --hdmi_rx_clk_n : in std_ulogic;
        hdmi_tx_clk_p : out std_ulogic;
        hdmi_tx_clk_n : out std_ulogic
        
        --hdmi_tx_hpdn : in std_logic;
        --hdmi_tx_cec     : inout std_logic;
        
        --hdmi_rx_cec : inout std_logic;
        --hdmi_rx_hpd     : out std_logic
        
      --  hdmi_rx_sda : inout std_logic;
      --  hdmi_tx_sda : inout std_logic;
        
      --  hdmi_rx_scl : in std_logic;
      --  hdmi_tx_scl : out std_logic
    );
end HDMI_Interposer;

architecture behaviour of HDMI_Interposer is

    component pll_1
        port
         (-- Clock in ports
          -- Clock out ports
          clk_400MHz          : out    std_logic;
          clk_40MHz          : out    std_logic;
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

    --component TMDS_decoder is 
    --    port (
    --        i_data          : in std_logic_vector(9 downto 0);
    --        o_data          : out std_logic_vector(7 downto 0);
    --        o_data_enable   : out std_logic;
    --        o_C0            : out std_logic;
    --        o_C1            : out std_logic;
    --        i_clk           : in std_logic
    --    );
    --end component;

    --signal w_data_link  : std_logic_vector(9 downto 0);
    signal w_hdmi_tx    : std_ulogic_vector(2 downto 0);
    signal r_encoded_byte_r : std_logic_vector(9 downto 0);
    signal r_encoded_byte_g : std_logic_vector(9 downto 0);
    signal r_encoded_byte_b : std_logic_vector(9 downto 0);
    --signal w_hdmi_rx    : std_ulogic_vector(2 downto 0);
    signal w_hdmi_tx_clk : std_ulogic;
    --signal w_hdmi_rx_clk : std_ulogic;
    --signal w_hpd    : std_logic;
    --signal w_cec    : std_logic;
   -- signal w_hdmi_scl : std_logic;
    --signal w_hdmi_rx_sda : std_logic;
   -- signal w_hdmi_tx_sda : std_logic;
 
     signal r_counter_x : integer range 0 to 1055 := 0;
     signal r_counter_y : integer range 0 to 627 := 0;
     signal w_reset : std_logic;
     signal w_clk_40MHz : std_logic;
     signal w_clk_400MHz : std_logic;
     signal w_locked : std_logic;
     signal w_sysclk : std_logic;
 
    signal w_hsync : std_logic;
    signal w_vsync : std_logic;
    signal w_DrawArea : std_logic;
    
    signal w_data_red : std_logic_vector(7 downto 0);
    signal w_data_green : std_logic_vector(7 downto 0);
    signal w_data_blue : std_logic_vector(7 downto 0);
    
    signal r_shift_counter : integer range 0 to 9 := 0;
    
    signal w_red : std_logic;
    signal w_green : std_logic;
    signal w_blue : std_logic;

    signal load_red : std_logic := '0';
    signal w_shift_red : std_logic_vector(9 downto 0) := "1111111111";
    signal load_green : std_logic := '0';
    signal w_shift_green : std_logic_vector(9 downto 0) := "1111111111";
    signal load_blue : std_logic := '0';
    signal w_shift_blue : std_logic_vector(9 downto 0) := "1111111111";

begin
    clocks: pll_1
    port map ( 
    -- Clock out ports  
        clk_400MHz => w_clk_400MHz,
        clk_40MHz => w_clk_40MHz,
    -- Status and control signals                
        reset => w_reset,
        locked => w_locked,
        -- Clock in ports
        clk_in1 => w_sysclk
    );
    
    
    counters : process(w_clk_40MHz)
    begin
        if rising_edge(w_clk_40MHz) then
            if(w_reset = '1') then
                r_counter_x <= 0;
                r_counter_y <= 0;
            else
                if (r_counter_x = 1055) then 
                    r_counter_x <= 0;
                else
                    r_counter_x <= r_counter_x+1;
                end if;
                if (r_counter_x = 1055) then
                    if (r_counter_y = 627) then
                        r_counter_y <= 0;
                    else
                        r_counter_y <= r_counter_y+1;
                    end if;
                end if;
            end if;
        end if;
    end process;


    update_sync : process(w_clk_40MHz)
    begin
        if rising_edge(w_clk_40MHz) then
            if((r_counter_x >= 840) and (r_counter_x < 968)) then
                w_hsync <= '1';
            else 
                w_hsync <= '0';
            end if;
            if((r_counter_y >= 601) and (r_counter_y < 605)) then
                w_vsync <= '1';
            else 
                w_vsync <= '0';
            end if;
            if((r_counter_x < 800) and (r_counter_y < 600)) then
                w_DrawArea <= '1';
            else 
                w_DrawArea <= '0';
            end if;
        end if;
    end process;
    



    
    generate_data_buffers : for i in 0 to 2 generate 
      --  rx_buf_i : IBUFDS 
      --  generic map (
      --      DIFF_TERM => FALSE,             -- Differential Termination 
      --      IBUF_LOW_PWR => TRUE,           -- Low power (TRUE) vs. performance (FALSE) setting for referenced I/O standards
      --      IOSTANDARD => "DEFAULT")
      --  port map (
      --      O => w_hdmi_rx(i),                 -- Buffer output
      --      I => hdmi_rx_d_p(i),      -- Diff_p buffer input (connect directly to top-level port)
      --      IB => hdmi_rx_d_n(i)      -- Diff_n buffer input (connect directly to top-level port)
      --  );
        
    tx_buf_i : OBUFDS
        generic map (
            IOSTANDARD => "DEFAULT",        -- Specify the output I/O standard
            SLEW => "SLOW")                 -- Specify the output slew rate
        port map (
            O => hdmi_tx_d_p(i),      -- Diff_p output (connect directly to top-level port)
            OB => hdmi_tx_d_n(i),     -- Diff_n output (connect directly to top-level port)
            I => w_hdmi_tx(i)                  -- Buffer input 
        );
    end generate;

    --hdmi_clk_in : IBUFDS 
    --    generic map (
    --        DIFF_TERM => FALSE,             -- Differential Termination 
    --        IBUF_LOW_PWR => TRUE,           -- Low power (TRUE) vs. performance (FALSE) setting for referenced I/O standards
    --        IOSTANDARD => "DEFAULT")
    --    port map (
    --        O => w_hdmi_rx_clk,                 -- Buffer output
    --        I => hdmi_rx_clk_p,      -- Diff_p buffer input (connect directly to top-level port)
    --        IB => hdmi_rx_clk_n      -- Diff_n buffer input (connect directly to top-level port)
    --    );

    hdmi_clk_out : OBUFDS 
        generic map (
            IOSTANDARD => "DEFAULT", -- Specify the output I/O standard
            SLEW => "SLOW")          -- Specify the output slew rate
        port map (
            O => hdmi_tx_clk_p,     -- Diff_p output (connect directly to top-level port)
            OB => hdmi_tx_clk_n,   -- Diff_n output (connect directly to top-level port)
            I => w_clk_40MHz      -- Buffer input 
        );

    --end generate;
    
    encode_red : TMDS_8b10b_encoder 
        port map (
            i_clk           => w_clk_40MHz,
            i_data_enable   => w_DrawArea,
            i_C0            => '0',
            i_C1            => '0',
            i_data          => w_data_red,
            o_data          => r_encoded_byte_r
        );
    encode_green : TMDS_8b10b_encoder 
        port map (
            i_clk           => w_clk_40MHz,
            i_data_enable   => w_DrawArea,
            i_C0            => '0',
            i_C1            => '0',
            i_data          => w_data_green,
            o_data          => r_encoded_byte_g
        );
    encode_blue : TMDS_8b10b_encoder 
        port map (
            i_clk           => w_clk_40MHz,
            i_data_enable   => w_DrawArea,
            i_C0            => w_vsync,
            i_C1            => w_hsync,
            i_data          => w_data_blue,
            o_data          => r_encoded_byte_b 
        );
    

    shift_counter : process(w_clk_400MHz)
    begin
        if rising_edge(w_clk_400MHz) then
            if(w_reset = '1') then
                r_shift_counter <= 0;
            elsif (r_shift_counter = 9) then
                r_shift_counter <= 0;
            else
                r_shift_counter <= r_shift_counter+1;
            end if;
        end if;
    end process;

    w_hdmi_tx(0) <= r_encoded_byte_r(r_shift_counter);
    w_hdmi_tx(1) <= r_encoded_byte_g(r_shift_counter);
    w_hdmi_tx(2) <= r_encoded_byte_b(r_shift_counter);

    w_sysclk <= sysclk;
    w_reset <= reset;
    
    led4_r <= not w_locked;
    led4_g <= w_locked;
    
    led5_b <= w_reset;

    w_data_red <= "11110000";
    w_data_green <= "01000000";
    w_data_blue <= "11110000";
    
end architecture;
    
