library ieee;
use ieee.std_logic_1164.all;

entity DVI_Transmitter_tb is
end DVI_Transmit_tb;

architecture test of DVI_Transmit_tb is

    component DVI_Transmitter is
    port {


    };
    end component;

    constant pixel_clk_period : time := 25 ns; -- pixel clock is 40MHz

begin

    clk : process is
    begin
        i_clk <= '0';
        wait for pixel_clk_period/2;  
        i_clk <= '1';
        wait for pixel_clk_period/2;
    end process;

    tb : process is
    begin

    end process;
end architecture;