library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity fifo is
    generic(
        g_FIFO_DEPTH            : integer;  
        g_FIFO_WIDTH            : integer;
        g_ALMOST_FULL_THRESHOLD   : integer;  
        g_ALMOST_EMPTY_THRESHOLD  : integer
    );
    port(
        i_wr_clk       : in  std_logic;
        i_rd_clk       : in  std_logic;
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
end fifo;

architecture Behavioral of fifo is
    type memory is array (0 to g_FIFO_DEPTH-1) of std_logic_vector(g_FIFO_WIDTH-1 downto 0);
    signal r_mem : memory;
    attribute ram_style : string;
    attribute ram_style of r_mem : signal is "block";
    signal r_wr_ptr, r_rd_ptr : integer range 0 to g_FIFO_DEPTH - 1;
    signal r_count: integer range 0 to g_FIFO_DEPTH := 0;
begin
    -- Write process
    process(i_wr_clk)
    begin
        if rising_edge(i_wr_clk) then
            if i_reset = '1' then
                r_wr_ptr <= 0;
                r_count <= 0;
            else
                if (i_wr_en = '1' and r_count < g_FIFO_DEPTH) then
                    r_mem(r_wr_ptr) <= i_data_in;
                    if r_wr_ptr = g_FIFO_DEPTH-1 then
                        r_wr_ptr <= 0;
                    else
                        r_wr_ptr <= r_wr_ptr + 1;
                    end if;
                    r_count <= r_count + 1;
                end if;
            end if;
        end if;
    end process;

    -- Read process
    process(i_rd_clk)
    begin
        if rising_edge(i_rd_clk) then
            if i_reset = '1' then
                r_rd_ptr <= 0;
            else
                if (i_rd_en = '1' and r_count > 0) then
                    o_data_out <= r_mem(r_rd_ptr);
                    if r_rd_ptr = g_FIFO_DEPTH-1 then 
                        r_rd_ptr <= 0;
                    else
                        r_rd_ptr <= r_rd_ptr + 1;
                    end if;
                    r_count <= r_count - 1;
                end if;
            end if;
        end if;
    end process;

    o_full         <= '1' when r_count = g_FIFO_DEPTH else '0';
    o_empty        <= '1' when r_count = 0 else '0';
    o_almost_full  <= '1' when r_count >= g_ALMOST_FULL_THRESHOLD else '0';
    o_almost_empty <= '1' when r_count <= g_ALMOST_EMPTY_THRESHOLD else '0';

end Behavioral;
