library ieee;
use ieee.std_logic_1164.all;

entity TMDS_decoder is
    port (
        i_data          : in std_logic_vector(9 downto 0);
        o_data          : out std_logic_vector(7 downto 0);
        o_data_enable   : out std_logic;
        o_C0            : out std_logic;
        o_C1            : out std_logic;
        i_clk           : in std_logic
    );
end entity;

architecture rtl of TMDS_decoder is

    signal w_data : std_logic_vector(7 downto 0);

begin

    data_enable : process(i_data)
    begin
        --if(rising_edge(i_clk)) then            
            if(i_data = "1101010100") then
                o_C0 <= '0';
                o_C1 <= '0';
                o_data_enable <= '0';
            elsif(i_data = "0010101011") then
                o_C0 <= '1';
                o_C1 <= '0';
                o_data_enable <= '0';
            elsif(i_data = "0101010100") then
                o_C0 <= '0';
                o_C1 <= '1';
                o_data_enable <= '0';
            elsif(i_data = "1010101011") then
                o_C0 <= '1';
                o_C1 <= '1';
                o_data_enable <= '0';
            else
                o_C0 <= '0';
                o_C1 <= '0';
                o_data_enable <= '1';
            end if;
    end process;

    bit9 : process(i_data)
    begin
        if(i_data(9) = '1') then
            w_data <= not i_data(7 downto 0);
        else 
            w_data <= i_data(7 downto 0);
        end if;
    end process;

    bit8 : process(i_clk)
    begin
        if rising_edge(i_clk) then 
            if (i_data(8) = '1') then 
                o_data(0) <= w_data(0);
                o_data(1) <= w_data(1) xor w_data(0);
                o_data(2) <= w_data(2) xor w_data(1);
                o_data(3) <= w_data(3) xor w_data(2);
                o_data(4) <= w_data(4) xor w_data(3);
                o_data(5) <= w_data(5) xor w_data(4);
                o_data(6) <= w_data(6) xor w_data(5);
                o_data(7) <= w_data(7) xor w_data(6);
            else
                o_data(0) <= w_data(0);
                o_data(1) <= w_data(1) xnor w_data(0);
                o_data(2) <= w_data(2) xnor w_data(1);
                o_data(3) <= w_data(3) xnor w_data(2);
                o_data(4) <= w_data(4) xnor w_data(3);
                o_data(5) <= w_data(5) xnor w_data(4);
                o_data(6) <= w_data(6) xnor w_data(5);
                o_data(7) <= w_data(7) xnor w_data(6);
            end if;
        end if;
    end process;
end architecture;
