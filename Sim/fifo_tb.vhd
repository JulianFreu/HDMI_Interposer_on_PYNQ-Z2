library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity fifo_tb is
end fifo_tb;

architecture Behavioral of fifo_tb is

    component fifo is
        generic(
            g_FIFO_DEPTH            : integer;  
            g_FIFO_WIDTH            : integer;
            ALMOST_FULL_THRESHOLD   : integer;  
            ALMOST_EMPTY_THRESHOLD  : integer
        );
        port(
            i_clk          : in  std_logic;
            i_reset        : in  std_logic;
            i_wr_en        : in  std_logic;
            i_data_in      : in  std_logic_vector(g_FIFO_WIDTH-1 downto 0);
            i_rd_en        : in  std_logic;
            o_data_out     : out std_logic_vector(g_FIFO_WIDTH-1 downto 0);
    
            o_full         : out std_logic;
            o_empty        : out std_logic;
            o_almost_full  : out std_logic;
            o_almost_empty : out std_logic
        );
    end component;

    constant g_FIFO_DEPTH            : integer := 50;  
    constant g_FIFO_WIDTH            : integer := 24;
    constant ALMOST_FULL_THRESHOLD   : integer := 45;  
    constant ALMOST_EMPTY_THRESHOLD  : integer := 15;

    signal i_clk     : std_logic := '0';
    signal i_reset   : std_logic := '1';
    signal i_wr_en   : std_logic := '0';
    signal i_data_in : std_logic_vector(g_FIFO_WIDTH-1 downto 0);
    signal i_rd_en   : std_logic := '0';
    signal o_data_out: std_logic_vector(g_FIFO_WIDTH-1 downto 0);

    signal o_full    : std_logic;
    signal o_empty   : std_logic;
    signal o_almost_full : std_logic;
    signal o_almost_empty: std_logic;

begin

    DUT: fifo
    generic map(
        g_FIFO_DEPTH            => g_FIFO_DEPTH,
        g_FIFO_WIDTH            => g_FIFO_WIDTH,
        ALMOST_FULL_THRESHOLD   => ALMOST_FULL_THRESHOLD,
        ALMOST_EMPTY_THRESHOLD  => ALMOST_EMPTY_THRESHOLD
    )
    port map(
        i_clk          => i_clk,
        i_reset        => i_reset,
        i_wr_en        => i_wr_en,
        i_data_in      => i_data_in,
        i_rd_en        => i_rd_en,
        o_data_out     => o_data_out,
        o_full         => o_full,
        o_empty        => o_empty,
        o_almost_full  => o_almost_full,
        o_almost_empty => o_almost_empty
    );

    -- Clock process

    i_clk <= not i_clk after 12.5 ns;
    i_reset <= '0' after 25 ns;

    -- Test process
    test_proc: process
    begin
        wait for 50 ns;
        i_wr_en <= '1';     
        for i in 0 to g_FIFO_DEPTH-1 loop
            i_data_in <= std_logic_vector(to_unsigned(i, g_FIFO_WIDTH));
            wait for 25 ns;
        end loop;
        i_wr_en <= '0';
        i_rd_en <= '1';
        for i in 0 to g_FIFO_DEPTH-10 loop
            wait for 25 ns;
        end loop;
        i_wr_en <= '1';
        for i in 0 to g_FIFO_DEPTH-1 loop
            i_data_in <= std_logic_vector(to_unsigned(i, g_FIFO_WIDTH));
            wait for 25 ns;
        end loop;
        wait;
    end process test_proc;

end Behavioral;
