library ieee;
use ieee.std_logic_1164.all;

entity Frame_Grabber is
port(
    o_data_red      : out std_logic_vector(7 downto 0);
    o_data_green    : out std_logic_vector(7 downto 0);
    o_data_blue     : out std_logic_vector(7 downto 0);
    i_frame_ready   : in std_logic
    -- AXI DMA interface
);
end Frame_Grabber;

architecture arch of Frame_Grabber is

begin
    o_data_red <= "11110000";
    o_data_green <= "01000000";
    o_data_blue <= "11110000";
end architecture;