library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;


entity DVI_Transmitter is
    port (
        i_pix_clk   : in std_logic;     -- 40 MHz
        i_bit_clk   : in std_logic;     -- 400 MHz
        i_reset     : in std_logic;
        o_red       : out std_logic;
        o_green     : out std_logic;
        o_blue      : out std_logic        
    );
end entity;

architecture rtl of DVI_Transmitter is

    component TMDS_8b10b_encoder is 
        port (
            i_clk           : in std_logic;
            i_data_enable   : in std_logic;
            i_C0            : in std_logic;
            i_C1            : in std_logic;
            i_data          : in std_logic_vector(7 downto 0);
            o_data          : out std_logic_vector(9 downto 0)
        );
        end component;

    component Serializer is
        port (
            i_clk : in STD_LOGIC;
            i_reset : in STD_LOGIC;
            i_parallel_load : in STD_LOGIC;
            i_data_in : in STD_LOGIC_VECTOR (7 downto 0);
            i_shift : in STD_LOGIC;
            o_data_out : out STD_LOGIC
        );
        end component;


    signal w_data_red       : std_logic_vector(7 downto 0);
    signal w_data_green     : std_logic_vector(7 downto 0);
    signal w_data_blue      : std_logic_vector(7 downto 0);
    signal r_encoded_byte_r : std_logic_vector(9 downto 0);
    signal r_encoded_byte_g : std_logic_vector(9 downto 0);
    signal r_encoded_byte_b : std_logic_vector(9 downto 0);

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

    
    -- red channel
    encode_red : TMDS_8b10b_encoder 
    port map (
        i_clk           => i_pix_clk,
        i_data_enable   => w_DrawArea,
        i_C0            => '0',
        i_C1            => '0',
        i_data          => w_data_red,
        o_data          => r_encoded_byte_r
    );
    serialize_red : Serializer
    port map{
        i_clk           => i_bit_clk,
        i_reset         => i_reset,
        i_parallel_load => -- how to decide when to load
        i_data_in       => r_encoded_byte_r,
        i_shift         => '1';
        o_data_out      => o_red
    };
    
    w_data_red <= "11110000";
    w_data_green <= "01000000";
    w_data_blue <= "11110000";
end architecture;