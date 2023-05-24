library ieee;
use ieee.std_logic_1164.all;

entity TMDS_decoder_tb is
end entity;

architecture rtl of TMDS_decoder_tb is

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
        port(
            i_data          : in std_logic_vector(9 downto 0);
            o_data          : out std_logic_vector(7 downto 0);
            o_data_enable   : out std_logic;
            o_C0            : out std_logic;
            o_C1            : out std_logic;
            i_clk           : in std_logic
        );
    end component;

    signal i_clk           :  std_logic := '0';
    signal i_data_enable   :  std_logic := '0';
    signal i_C0            :  std_logic := '0';
    signal i_C1            :  std_logic := '0';
    signal i_data          :  std_logic_vector(7 downto 0) := "00000000";
    signal o_data          :  std_logic_vector(9 downto 0);
    
    constant clk_period     : time := 20 ns;

    signal w_data_link : std_logic_vector(9 downto 0);
    signal o_data_decoded : std_logic_vector (7 downto 0);
    signal o_C0 : std_logic;
    signal o_C1 : std_logic;
    signal o_data_enable : std_logic;

begin

encode : TMDS_8b10b_encoder
    port map (
        i_data  => i_data,
        o_data  => w_data_link,
        i_data_enable => i_data_enable,
        i_C0 => i_C0,
        i_C1 => i_C1,
        i_clk => i_clk
    );
    
decode : TMDS_decoder
    port map (
        i_data          => w_data_link,       
        o_data          => o_data_decoded,        
        o_data_enable   => o_data_enable,
        o_C0            => o_C0,             
        o_C1            => o_C1,   
        i_clk           => i_clk       
    );

    clk : process
    begin
        i_clk <= '0';
        wait for clk_period/2;  --for 0.5 ns signal is '0'.
        i_clk <= '1';
        wait for clk_period/2;  --for next 0.5 ns signal is '1'.
    end process;

    tb : process
    begin
        assert false report "Simulation has started";
--      #####################
--      ## Data Enable Off ##
--      #####################       
        wait for 10 ns;
        i_data_enable   <=  '0';
        i_C0            <=  '0';
        i_C1            <=  '0';
        i_data          <=  "00000000";
       
        wait for 10 ns;
        
        assert o_data = "0010101011" report "FAILURE: Output should be 0010101011";

        i_data_enable   <=  '0';
        i_C0            <=  '1';
        i_C1            <=  '0';
        i_data          <=  "00000000";

        wait for 20 ns;

        assert o_data = "1101010100" report "FAILURE: Output should be 1101010100";
        
        i_data_enable   <=  '0';
        i_C0            <=  '0';
        i_C1            <=  '1';
        i_data          <=  "00000000";

        wait for 20 ns;

        assert o_data = "0010101010" report "FAILURE: Output should be 0010101010";

        i_data_enable   <=  '0';
        i_C0            <=  '1';
        i_C1            <=  '1';
        i_data          <=  "00000000";

        wait for 20 ns;

        assert o_data = "1101010101" report "FAILURE: Output should be 1101010101";

--      #####################
--      ## Data Enable On  ##
--      ##################### 

        i_data_enable   <=  '1';
        i_data          <=  "00000000";

        wait for 20 ns;

        assert o_data = "0000000010" report "FAILURE: Output should be 0000000010";

        i_data          <=  "00000001";

        wait for 20 ns;

        assert o_data = "1101010101" report "FAILURE: Output should be 1101010101";

        i_data          <=  "00000011";

        wait for 20 ns;

        assert o_data = "1101010101" report "FAILURE: Output should be 1101010101";

        i_data          <=  "00000111";

        wait for 20 ns;

        assert o_data = "1101010101" report "FAILURE: Output should be 1101010101";

        i_data          <=  "11110000";

        wait for 20 ns;

        assert o_data = "1101010101" report "FAILURE: Output should be 1101010101";

        i_data          <=  "11111000";

        wait for 20 ns;

        assert o_data = "1101010101" report "FAILURE: Output should be 1101010101";

        i_data          <=  "11111100";

        wait for 20 ns;

        assert o_data = "1101010101" report "FAILURE: Output should be 1101010101";

        i_data          <=  "11111110";

        wait for 20 ns;

        assert o_data = "1101010101" report "FAILURE: Output should be 1101010101";

        i_data          <=  "11111111";

        wait for 20 ns;

        assert o_data = "1101010101" report "FAILURE: Output should be 1101010101";


        
        assert false report "Simulation finished";
        wait;
    end process;
    
end architecture;

