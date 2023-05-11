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
            g_VECTOR_LENGTH : integer
        );
        port (
            i_data          : in std_logic_vector(g_VECTOR_LENGTH-1 downto 0);
            o_num_of_ones   : out integer range 0 to g_VECTOR_LENGTH
        );
    end component;

    signal r_cnt_disparity      : integer range -8 to 8 := 0;
    signal w_int_data_9b        : std_logic_vector(8 downto 0);
    signal w_int_data_10b        : std_logic_vector(9 downto 0);
    signal w_ones_i_data       : integer range 0 to 8 := 0;
    signal w_ones_int_data       : integer range 0 to 9 := 0;

begin

    count_ones_8b : count_ones
        generic map (
            g_VECTOR_LENGTH => 8
        )
        port map ( 
            i_data => i_data,
            o_num_of_ones => w_ones_i_data
        );

    count_ones_9b : count_ones
        generic map (
            g_VECTOR_LENGTH => 9
        )
        port map ( 
            i_data => w_int_data_9b,
            o_num_of_ones => w_ones_int_data
        );


o_data <= w_int_data_10b;

encode : process(i_data)
    signal w_temp : std_logic_vector(7 downto 0);
begin
    if (w_ones_i_data >= 4) then                               -- when there are 4 or more 1s, the bits get xnor'ed
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
    if (r_cnt_disparity = 0 or w_ones_int_data = 4) then
        w_int_data_10b(9) <= not w_int_data_9b(8);
        w_int_data_10b(8) <= w_int_data_9b(8);
        if (w_int_data_9b(8) = '1') then
            w_int_data_10b(7 downto 0) <= w_int_data_9b(7 downto 0);
        else
            w_int_data_10b(7 downto 0) <= not w_int_data_9b(7 downto 0);
        end if;        
    elsif ((r_cnt_disparity > 0 and w_ones_int_data > 8 - w_ones_int_data) or (r_cnt_disparity < 0 and (8-w_ones_int_data > w_ones_int_data))) then
        w_int_data_10b <= '1' & w_int_data_9b(8) & not w_int_data_9b(7 downto 0);
    else
        w_int_data_10b <= '0' & w_int_data_9b(8 downto 0);
    end if;
end process;

set_output : process(i_clk)

begin
    if (rising_edge(i_clk)) then
        if (i_data_enable = '0') then
            r_cnt_disparity <= 0;
            w_int_data_10b <=   "0010101011" when (i_C0 = '0' and i_C1 = '0') else
                                "1101010100" when (i_C0 = '1' and i_C1 = '0') else
                                "0010101010" when (i_C0 = '0' and i_C1 = '1') else
                                "1101010101" when (i_C0 = '1' and i_C1 = '1') else
                                (others => '0');
        elsif (r_cnt_disparity = 0 or w_ones_int_data = 4) then
            r_cnt_disparity <=  (r_cnt_disparity + w_ones_int_data - (8 - w_ones_int_data)) when w_int_data_9b(8) = '0' else
                                (r_cnt_disparity + (8 - 2*w_ones_int_data)) when w_int_data_9b(8) = '1' else
                                0;
        else
            if w_int_data_10b(9) = '1' and w_int_data_10b(8) = '1' then
                r_cnt_disparity <= r_cnt_disparity +2 + (8 - 2*w_ones_int_data);
            elsif w_int_data_10b(9) = '1' and w_int_data_10b(8) = '0' then
                r_cnt_disparity <= r_cnt_disparity + (8 - 2*w_ones_int_data);
            elsif w_int_data_10b(9) = '0' and w_int_data_10b(8) = '1' then
                r_cnt_disparity <= r_cnt_disparity + w_ones_int_data -(8-w_ones_int_data);
            else 
                r_cnt_disparity <= r_cnt_disparity -2 + (w_ones_int_data -(8-w_ones_int_data));
            end if;
        end if;
    end if;
end process;

end architecture;
