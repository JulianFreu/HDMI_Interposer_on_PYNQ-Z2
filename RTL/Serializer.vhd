library ieee;
use ieee.std_logic_1164.all;

entity Serializer is
  port (
    i_clk : in std_logic;
    i_reset : in std_logic;
    i_parallel_load : in std_logic;
    i_data_in : in std_logic_vector (9 downto 0);
    i_shift : in std_logic;
    o_data_out : out std_logic
  );
end Serializer;

architecture Behavioral of Serializer is
  signal r_internal_register : std_logic_vector (9 downto 0);
begin
  process (i_clk, i_reset)
  begin
    if i_reset = '1' then
        r_internal_register <= (others => '0');
    elsif rising_edge(i_clk) then
      if i_parallel_load = '1' then
        r_internal_register <= i_data_in;
      elsif i_shift = '1' then
        r_internal_register <= '0' & r_internal_register(9 downto 1);
      end if;
    end if;
  end process;

  o_data_out <= r_internal_register(0);
end Behavioral;
