library ieee;
use ieee.std_logic_1164.all;

entity pll_1_tb is
end pll_1_tb;

architecture sim of pll_1_tb is
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


  -- assuming an 125MHz input clock
  constant clk_period : time := 8 ns;
  signal clk : std_logic := '0';
  signal rst : std_logic := '1';
  signal clk_40MHz, clk_400MHz, clk_40MHz_shifted, locked : std_logic;
begin
  -- clock generation process
  clk_process: process
  begin
    wait for clk_period / 2;
    clk <= not clk;
  end process;

  -- reset release process
  rst_process: process
  begin
    wait for clk_period * 10;
    rst <= '0';
    wait until pll.locked = '1';
  end process;

  -- instantiate pll
  pll: pll_1
    port map (
      clk_in1 => clk,
      reset => rst,
      clk_40MHz => clk_40MHz, 
      clk_400MHz => clk_400MHz,
      clk_40MHz_shifted  => clk_40MHz_shifted,
      locked => locked
    );
end sim;
