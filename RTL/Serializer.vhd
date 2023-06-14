library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity Serializer is
  port (
    i_clk : in STD_LOGIC;
    i_reset : in STD_LOGIC;
    i_parallel_load : in STD_LOGIC;
    i_data_in : in STD_LOGIC_VECTOR (7 downto 0);
    i_shift : in STD_LOGIC;
    o_data_out : out STD_LOGIC
  );
end Serializer;

architecture Behavioral of Serializer is
  signal r_internal_register : STD_LOGIC_VECTOR (7 downto 0);
begin
  process (i_clk, i_reset)
  begin
    if i_reset = '1' then
        r_internal_register <= (others => '0');
    elsif rising_edge(i_clk) then
      if i_parallel_load = '1' then
        r_internal_register <= i_data_in;
      elsif i_shift = '1' then
        r_internal_register <= '0' & r_internal_register(7 downto 1);
      end if;
    end if;
  end process;

  o_data_out <= r_internal_register(0);
end Behavioral;
