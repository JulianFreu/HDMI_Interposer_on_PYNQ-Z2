library ieee;
use ieee.std_logic_1164.all;

entity count_ones_tb is
end count_ones_tb;

architecture tb of count_ones_tb is
component count_ones is
    generic (
        g_VECTOR_LENGTH : integer
    );
    port ( 
        i_data          : in std_logic_vector(g_VECTOR_LENGTH-1 downto 0);
        o_num_of_ones   : out integer range 0 to g_VECTOR_LENGTH
    );
end component;

signal output_8b_dut    : integer range 0 to 8;
signal output_11b_dut   : integer range 0 to 11;

signal input_8b_dut     : std_logic_vector(7 downto 0);
signal input_11b_dut    : std_logic_vector(10 downto 0);

begin

dut1 : count_ones
    generic map (
        g_VECTOR_LENGTH => 8
    )
    port map (
        i_data => input_8b_dut,
        o_num_of_ones => output_8b_dut
    );

dut2 : count_ones
    generic map (
        g_VECTOR_LENGTH => 11
    )
    port map (
        i_data => input_11b_dut,
        o_num_of_ones => output_11b_dut
    );
process
begin
	wait for 10 ns;

	input_8b_dut <= "01000101";
	input_11b_dut <= "01000101111";

	wait for 10 ns;

	input_8b_dut <= "11111111";
	input_11b_dut <= "11111111111";

	wait for 10 ns;

	input_8b_dut <= "00000000";
	input_11b_dut <= "00000000000";

	wait;

end process;

end tb;
