library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;


entity DVI_Transmitter is
    port (
        i_pix_clk           : in std_logic;     -- 40 MHz
        i_bit_clk           : in std_logic;     -- 400 MHz
        i_pix_clk_shifted   : in std_logic;     -- 40MHz with 10% duty cycle, shifted -18 degrees
        i_reset             : in std_logic;
        o_red               : out std_logic;
        o_green             : out std_logic;
        o_blue              : out std_logic      
        --AXI DMA Interface  
    );
end entity;

architecture rtl of DVI_Transmitter is

    component Frame_Ctrl is
        port(
            i_pix_clk           : in std_logic;
            i_reset             : in std_logic;
            i_transmit_frame    : in std_logic;
            i_frame_ready       : in std_logic;
            o_DrawArea          : out std_logic;
            o_vsync             : out std_logic;
            o_hsync             : out std_logic;
            o_enable_serializer : out std_logic
            -- AXI DMA interface
        );
        end component;

    component Frame_Grabber is
        port(
            o_data_red      : out std_logic_vector(7 downto 0);
            o_data_green    : out std_logic_vector(7 downto 0);
            o_data_blue     : out std_logic_vector(7 downto 0);
            i_frame_ready   : in std_logic
            -- AXI DMA interface
        );
        end component;

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
            i_clk : in std_logic;
            i_reset : in std_logic;
            i_parallel_load : in std_logic;
            i_data_in : in std_logic_vector (9 downto 0);
            i_shift : in std_logic;
            o_data_out : out std_logic
        );
        end component;


    signal w_data_red       : std_logic_vector(7 downto 0);
    signal w_data_green     : std_logic_vector(7 downto 0);
    signal w_data_blue      : std_logic_vector(7 downto 0);
    signal r_encoded_byte_r : std_logic_vector(9 downto 0);
    signal r_encoded_byte_g : std_logic_vector(9 downto 0);
    signal r_encoded_byte_b : std_logic_vector(9 downto 0);

    signal w_output_enable : std_logic;

    signal w_hsync      : std_logic;
    signal w_vsync      : std_logic;
    signal w_DrawArea   : std_logic;

begin

    Transmit_Ctrl : Frame_Ctrl
        port map(
            i_pix_clk               => i_pix_clk,
            i_reset                 => i_reset,
            i_transmit_frame        => '1',
            i_frame_ready           => '1',
            o_DrawArea              => w_DrawArea,
            o_vsync                 => w_vsync,
            o_hsync                 => w_hsync,
            o_enable_serializer     => w_output_enable
            -- AXI DMA interface    
        );

    Frame_grab : Frame_Grabber
        port map(
            o_data_red => w_data_red,      
            o_data_green => w_data_green,    
            o_data_blue => w_data_blue,     
            i_frame_ready => '1'
            -- AXI DMA interface
        );

    --#####################
    --#### red channel ####
    --#####################
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
        port map(
            i_clk           => i_bit_clk,
            i_reset         => i_reset,
            i_parallel_load => i_pix_clk_shifted, -- 40MHz with 10% duty cycle, shifted -18 degrees
            i_data_in       => r_encoded_byte_r,
            i_shift         => w_output_enable,
            o_data_out      => o_red
        );
    
    --#######################
    --#### green channel ####
    --#######################
    encode_green : TMDS_8b10b_encoder 
        port map (
            i_clk           => i_pix_clk,
            i_data_enable   => w_DrawArea,
            i_C0            => '0',
            i_C1            => '0',
            i_data          => w_data_green,
            o_data          => r_encoded_byte_g
        );
    serialize_green : Serializer
        port map(
            i_clk           => i_bit_clk,
            i_reset         => i_reset,
            i_parallel_load => i_pix_clk_shifted, -- 40MHz with 10% duty cycle, shifted -18 degrees
            i_data_in       => r_encoded_byte_g,
            i_shift         => w_output_enable,
            o_data_out      => o_green
        );

    --######################
    --#### blue channel ####
    --######################
    encode_blue : TMDS_8b10b_encoder 
        port map (
            i_clk           => i_pix_clk,
            i_data_enable   => w_DrawArea,
            i_C0            => w_hsync,
            i_C1            => w_vsync,
            i_data          => w_data_blue,
            o_data          => r_encoded_byte_b
        );
    serialize_blue : Serializer
        port map(
            i_clk           => i_bit_clk,
            i_reset         => i_reset,
            i_parallel_load => i_pix_clk_shifted, -- 40MHz with 10% duty cycle, shifted -18 degrees
            i_data_in       => r_encoded_byte_b,
            i_shift         => w_output_enable,
            o_data_out      => o_blue
        );

end architecture;
