library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity Serializer_tb is
end Serializer_tb;

architecture Behavioral of Serializer_tb is

    component Serializer is
        port (
            i_clk : in STD_LOGIC;
            i_reset : in STD_LOGIC;
            i_parallel_load : in STD_LOGIC;
            i_data_in : in STD_LOGIC_VECTOR (7 downto 0);
            i_shift : in STD_LOGIC;
            o_data_out : out STD_LOGIC
        );
        end component;

    signal i_clk : std_logic := '0';
    signal i_reset : std_logic := '1';
    signal i_parallel_load : std_logic := '0';
    signal i_data_in : std_logic_vector(7 downto 0) := (others => '0');
    signal i_shift : std_logic := '0';
    signal o_data_out : std_logic;
    constant clk_period : time := 2.5 ns;
begin
    i_clk <= not i_clk after clk_period / 2;

    UUT: Serializer
        port map (
            i_clk => i_clk,
            i_reset => i_reset,
            i_parallel_load => i_parallel_load,
            i_data_in => i_data_in,
            i_shift => i_shift,
            o_data_out => o_data_out
        );

  stim_proc: process
  begin
    -- hold i_reset state for 100 ns.
    wait for 10 ns;  
    i_reset <= '0'; 
    -- wait for 10 clock periods
    wait for clk_period * 10;
    -- load parallel data
    i_parallel_load <= '1';
    i_data_in <= "10101010";
    -- wait for 1 clock period
    wait for clk_period;
    -- stop loading and start shifting
    i_parallel_load <= '0';
    i_shift <= '1';
    -- wait for 8 clock periods to completely i_shift out i_data_in
    wait for clk_period * 8;
    -- load new data
    i_parallel_load <= '1';
    i_data_in <= "11001100";
    -- wait for 1 clock period
    wait for clk_period;
    -- stop loading and start shifting
    i_parallel_load <= '0';
    -- wait for 8 clock periods to completely i_shift out i_data_in
    wait for clk_period * 8;
    -- stop the test
    wait;
  end process;

end Behavioral;
