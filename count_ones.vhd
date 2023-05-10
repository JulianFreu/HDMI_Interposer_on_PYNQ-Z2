library ieee;
use ieee.std_logic_1164.all;    

    entity count_ones is 
        generic (
            g_VECTOR_LENGTH : integer := 8
        );
        port (
            i_data          : in std_logic_vector(g_VECTOR_LENGTH-1 downto 0);
            o_num_of_ones   : out integer range 0 to g_VECTOR_LENGTH
        );
    end entity;


architecture rtl of count_ones is

begin
-- counts how many 1s are in the input byte
count_ones : process(i_data)
    variable count : integer range 0 to 8 := 0;
    begin
        for i in 0 to g_VECTOR_LENGTH-1 loop
            if (i_data(i) = '1') then
                count := count + 1;
            end if;
        end loop;
	o_num_of_ones <= count;
    end process;
end architecture;
