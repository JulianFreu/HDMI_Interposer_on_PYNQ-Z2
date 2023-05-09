library ieee;
use ieee.std_logic_1164.all;
-- use ieee.numeric_std.all;
-- use ieee.math_real.all;

entity TMDS_8b10b_encoder is
    port (
        i_clk           : in std_logic;
        i_data_enable   : in std_logic;
        i_C0            : in std_logic;
        i_C1            : in std_logic;
        i_data          : in std_logic_vector(7 downto 0);
        o_data          : out std_logic_vector(9 downto 0)
    );
end TMDS_8b10b_encoder;

architecture rtl of TMDS_8b10b_encoder is
    component count_ones is 
        generic (
            g_VECTOR_LENGTH := 8
        );
        port (
            i_data          : std_logic_vector(g_VECTOR_LENGTH-1 downto 0);
            o_num_of_ones   : std_logic;
        );


    signal r_cnt_disparity      : integer range -8 to 8 := 0;
    signal w_int_data_9b           : std_logic_vector(8 downto 0);
    signal w_ones               : integer range 0 to 8 := 0;
    signal w_zeroes             : integer range 0 to 8 := 0;

begin

-- counts how many 1s are in the input byte
count_ones : process(i_data)
signal count : integer range 0 to 8 := 0;
begin
    for i in 0 to 7 : loop
        if (i_data(i) = '1') then
            count := count+1;
        end if;
    end loop;
    w_ones := count;
end process;

encode : process(i_data)
    signal w_temp : std_logic_vector(7 downto 0);
begin
    if (w_ones >= 4) then                               -- when there are 4 or more 1s, the bits get xnor'ed
        for i in 0 to 6 loop
            w_temp(i) <= i_data(i) xnor i_data(i+1);
        end loop;
        w_temp(7) <= '0';                               -- indicates that the data bits have been xnor'ed
    else                                                -- when there are less then 4 1s, the bits get xor'ed
        for i in 0 to 6 loop
            w_temp(i) <= i_data(i) xor i_data(i+1);
        end loop;
        w_temp(7) <= '1';                               -- indicates that the data bits have been xor'ed
    end if;
    w_int_data_9b <= w_temp & i_data(0);                -- first data bit remains unchanged
end process;

invert : process(w_int_data_9b)
begin
    if (r_cnt_disparity = 0 or w_ones = 4) then
        o_data(9) <= not w_int_data_9b(8);
        o_data(8) <= w_int_data_9b(8);
        if (w_int_data_9b(8) = '1') then
            o_data(7 downto 0) <= not w_int_data_9b(7 downto 0);
        else
            o_data(7 downto 0) <= w_int_data_9b(7 downto 0);
        end if;        
    elsif disparity worsens
        invert
        set bit 10 to 1
    else
        dont invert
        set bit 10 to 0 
end process;

process(i_clk)

begin

end process;

end architecture;
