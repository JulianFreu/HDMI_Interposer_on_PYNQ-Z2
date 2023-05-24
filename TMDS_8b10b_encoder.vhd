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

    signal w_disparity      : integer range -8 to 8 := 0;
    signal r_dc_bias      : integer range -16 to 16 := 0;
    signal w_qm        : std_logic_vector(8 downto 0);
    signal w_qm_inv     :   std_logic_vector(8 downto 0);
    signal w_qout        : std_logic_vector(9 downto 0);
    signal w_ones_i_data       : integer range 0 to 8 := 0;
    signal w_ones_qm       : integer range 0 to 8 := 0;


begin

    count_ones_i_data : count_ones
        generic map (
            g_VECTOR_LENGTH => 8
        )
        port map ( 
            i_data => i_data,
            o_num_of_ones => w_ones_i_data
        );

    count_ones_qm : count_ones
        generic map (
            g_VECTOR_LENGTH => 8
        )
        port map ( 
            i_data => w_qm(7 downto 0),
            o_num_of_ones => w_ones_qm
        );

w_qm_inv <= w_qm(8) & not w_qm(7 downto 0);

encode : process(i_data, w_qm, w_ones_i_data)
begin
        if (w_ones_i_data > 4 or (w_ones_i_data = 4 and i_data(0) = '0')) then                               -- when there are 4 or more 1s, the bits get xnor'ed
            w_qm(0) <= i_data(0);    
            w_qm(1) <= w_qm(0) xnor i_data(1);
            w_qm(2) <= w_qm(1) xnor i_data(2);
            w_qm(3) <= w_qm(2) xnor i_data(3);
            w_qm(4) <= w_qm(3) xnor i_data(4);
            w_qm(5) <= w_qm(4) xnor i_data(5);
            w_qm(6) <= w_qm(5) xnor i_data(6);
            w_qm(7) <= w_qm(6) xnor i_data(7);
            w_qm(8) <= '0';                             -- indicates that the data bits have been xnor'ed
        else                                                -- when there are less then 4 1s, the bits get xor'ed
            w_qm(0) <= i_data(0);    
            w_qm(1) <= w_qm(0) xor i_data(1);
            w_qm(2) <= w_qm(1) xor i_data(2);
            w_qm(3) <= w_qm(2) xor i_data(3);
            w_qm(4) <= w_qm(3) xor i_data(4);
            w_qm(5) <= w_qm(4) xor i_data(5);
            w_qm(6) <= w_qm(5) xor i_data(6);
            w_qm(7) <= w_qm(6) xor i_data(7); 
            w_qm(8) <= '1';                               -- indicates that the data bits have been xor'ed
        end if;
end process;

decide_output : process(w_qm, w_qm_inv, r_dc_bias, w_ones_qm, i_C0, i_C1)
begin
    if (i_data_enable = '0') then    
        w_disparity <= 0;
        if(i_C0 = '0' and i_C1 = '0') then
            w_qout <= "1101010100";
        elsif(i_C0 = '1' and i_C1 = '0') then
            w_qout <= "0010101011";
        elsif(i_C0 = '0' and i_C1 = '1') then 
            w_qout <= "0101010100";
        elsif(i_C0 = '1' and i_C1 = '1') then
            w_qout <= "1010101011";
        end if;
    elsif (r_dc_bias = 0 or w_ones_qm = 4) then
        if (w_qm(8) = '1') then
            w_qout <= '0' &  w_qm;
            w_disparity <= (r_dc_bias + (8 - 2*w_ones_qm));
        else
            w_qout <= '1' & w_qm_inv;
            w_disparity <=  (r_dc_bias + w_ones_qm - (8 - w_ones_qm));
        end if;        
    elsif ((r_dc_bias > 0 and w_ones_qm > 4) or (r_dc_bias < 0 and w_ones_qm < 4)) then
        w_qout <= '1' & w_qm_inv;
        if(w_qm(8) = '1') then
            w_disparity <= r_dc_bias +2 + (8 - 2*w_ones_qm);
        else
            w_disparity <= r_dc_bias + (8 - 2*w_ones_qm);
        end if;
    else
        w_qout <= '0' & w_qm;
        if(w_qm(8) = '1') then
            w_disparity <= r_dc_bias + w_ones_qm -(8-w_ones_qm);
        else
            w_disparity <= r_dc_bias -2 + (w_ones_qm -(8-w_ones_qm));
        end if;
    end if;
end process;

    ff : process(i_clk)
    begin
        if (rising_edge(i_clk)) then
            o_data <= w_qout;
            r_dc_bias <= w_disparity;
        end if;
    end process;
end architecture;
    