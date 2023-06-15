library ieee;
use ieee.std_logic_1164.all;

entity Frame_Ctrl is
port(
    i_pix_clk           : in std_logic;
    i_reset             : in std_logic;
    i_transmit_frame    : in std_logic;
    i_frame_ready       : in std_logic;
    o_DrawArea         : out std_logic;
    o_vsync             : out std_logic;
    o_hsync             : out std_logic;
    o_enable_serializer : out std_logic
    -- AXI DMA interface
);
end Frame_Ctrl;

architecture arch of Frame_Ctrl is
    signal r_counter_x  : integer range 0 to 1055 := 0;
    signal r_counter_y  : integer range 0 to 627 := 0;
    signal w_hsync      : std_logic;
    signal w_vsync      : std_logic;
    signal w_DrawArea   : std_logic;
begin

    counters : process(i_pix_clk)
    begin
        if rising_edge(i_pix_clk) then
            if(i_reset = '1') then
                r_counter_x <= 0;
                r_counter_y <= 0;
            else
                if (r_counter_x = 1055) then 
                    r_counter_x <= 0;
                else
                    r_counter_x <= r_counter_x+1;
                end if;
                if (r_counter_x = 1055) then
                    if (r_counter_y = 627) then
                        r_counter_y <= 0;
                    else
                        r_counter_y <= r_counter_y+1;
                    end if;
                end if;
            end if;
        end if;
    end process;

    update_sync : process(i_pix_clk)
    begin
        if rising_edge(i_pix_clk) then
            if(i_reset = '1') then
                w_hsync <= '0';
                w_vsync <= '0';
                w_DrawArea <= '0';
            else                  
                if((r_counter_x >= 840) and (r_counter_x < 968)) then
                    w_hsync <= '1';
                else 
                    w_hsync <= '0';
                end if;
                if((r_counter_y >= 601) and (r_counter_y < 605)) then
                    w_vsync <= '1';
                else 
                    w_vsync <= '0';
                end if;
                if((r_counter_x < 800) and (r_counter_y < 600)) then
                    w_DrawArea <= '1';
                else 
                    w_DrawArea <= '0';
                end if;
            end if;
        end if;
    end process;

    o_hsync <= w_hsync;   
    o_vsync <= w_vsync;     
    o_DrawArea <= w_DrawArea; 
    o_enable_serializer <= '1';

end architecture;