library ieee;
use ieee.std_logic_1164.all;

entity m_axi_tb is
end m_axi_tb;

architecture testbench_arch of m_axi_tb is
  constant g_FIFO_DEPTH                : integer := 50;   
  constant g_FIFO_WIDTH                : integer := 24;
  constant g_ALMOST_FULL_THRESHOLD     : integer := 35;
  constant g_ALMOST_EMPTY_THRESHOLD    : integer := 15;

  --axi
  constant g_ID_W_WIDTH : integer := 6;
  constant g_ID_R_WIDTH : integer := 6;
  constant g_ADDR_WIDTH : integer := 32;
  constant g_DATA_WIDTH : integer := 32;
  constant g_BRESP_WIDTH : integer := 2;
  constant g_RRESP_WIDTH : integer := 2;
  constant g_TRANSACTION_LENGTH : std_logic_vector(7 downto 0) := "00001111"; -- 16                                        
  constant g_TRANSACTION_SIZE : std_logic_vector(2 downto 0) := "010"; -- 4 bytes                                          
  constant g_BURST_ATTRB   : std_logic_vector(1 downto 0) := "01"; -- Burst attribute "0b01" incrementing burst            
  constant g_LOCK_ATTRB : std_logic := '0'; -- Exclusive access indicator (not supported by Xiliinx, leave on 0, see ug1037
  constant g_CACHE_ATTRB : std_logic_vector(3 downto 0) := "0011";                                                         
  constant g_PROT_ATTRB : std_logic_vector(2 downto 0) := "000";                                                           
  constant g_QOS_ATTRB : std_logic_vector(3 downto 0) := "0000";                                                           
  constant g_STROBE_ATTRB : std_logic_vector(3 downto 0) := "0111";                          

  -- Signals
  signal i_reset                 : std_logic;
  signal i_aclk                  : std_logic;
  signal i_trigger_transaction   : std_logic := '0';
  signal i_fifo_data             : std_logic_vector(g_FIFO_WIDTH-1 downto 0);
  signal o_fifo_data             : std_logic_vector(g_FIFO_WIDTH-1 downto 0);
  signal i_write_address         : std_logic_vector(g_ADDR_WIDTH-1 downto 0);
  signal o_fifo_read             : std_logic;
  signal o_last_write_response   : std_logic_vector(g_BRESP_WIDTH-1 downto 0);
  signal i_read_address          : std_logic_vector(g_ADDR_WIDTH-1 downto 0);
  signal o_fifo_write            : std_logic;
  signal o_last_read_response    : std_logic_vector(g_BRESP_WIDTH-1 downto 0);

  -- Component instantiation
  component m_axi is
    generic(
        --fifo         
        g_FIFO_WIDTH                : integer := 24;      
        --axi
        g_ID_W_WIDTH : integer := 6;
        g_ID_R_WIDTH : integer := 6;
        g_ADDR_WIDTH : integer := 32;
        g_DATA_WIDTH : integer := 32;
        g_BRESP_WIDTH : integer := 2;
        g_RRESP_WIDTH : integer := 2;
        g_TRANSACTION_LENGTH : std_logic_vector(7 downto 0) := "00001111"; -- 16                                        
        g_TRANSACTION_SIZE : std_logic_vector(2 downto 0) := "010"; -- 4 bytes                                          
        g_BURST_ATTRB   : std_logic_vector(1 downto 0) := "01"; -- Burst attribute "0b01" incrementing burst            
        g_LOCK_ATTRB : std_logic := '0'; -- Exclusive access indicator (not supported by Xiliinx, leave on 0, see ug1037
        g_CACHE_ATTRB : std_logic_vector(3 downto 0) := "0011";                                                         
        g_PROT_ATTRB : std_logic_vector(2 downto 0) := "000";                                                           
        g_QOS_ATTRB : std_logic_vector(3 downto 0) := "0000";                                                           
        g_STROBE_ATTRB : std_logic_vector(3 downto 0) := "0111"                             
    );
    port(
      o_m_axi_aw_valid         : out std_logic;
      i_m_axi_aw_ready         : in std_logic;
      o_m_axi_aw_id            : out std_logic_vector(g_ID_W_WIDTH-1 downto 0);
      o_m_axi_aw_addr          : out std_logic_vector(g_ADDR_WIDTH-1 downto 0);
      o_m_axi_aw_len           : out std_logic_vector(7 downto 0);
      o_m_axi_aw_size          : out std_logic_vector(2 downto 0);
      o_m_axi_aw_burst         : out std_logic_vector(1 downto 0);
      o_m_axi_aw_lock          : out std_logic;
      o_m_axi_aw_cache         : out std_logic_vector(3 downto 0);
      o_m_axi_aw_prot          : out std_logic_vector(2 downto 0);
      o_m_axi_aw_qos           : out std_logic_vector(3 downto 0);
      o_m_axi_w_valid          : out std_logic;
      i_m_axi_w_ready          : in std_logic;
      o_m_axi_w_data           : out std_logic_vector(g_DATA_WIDTH-1 downto 0);
      o_m_axi_w_strb           : out std_logic_vector(3 downto 0);
      o_m_axi_w_last           : out std_logic;
      i_m_axi_b_valid          : in std_logic;
      o_m_axi_b_ready          : out std_logic;
      i_m_axi_b_id             : in std_logic_vector(g_ID_W_WIDTH-1 downto 0);
      i_m_axi_b_resp           : in std_logic_vector(g_BRESP_WIDTH-1 downto 0);
      o_m_axi_ar_valid         : out std_logic;
      i_m_axi_ar_ready         : in std_logic;
      o_m_axi_ar_id            : out std_logic_vector(g_ID_R_WIDTH-1 downto 0);
      o_m_axi_ar_addr          : out std_logic_vector(g_ADDR_WIDTH-1 downto 0);
      o_m_axi_ar_len           : out std_logic_vector(7 downto 0);
      o_m_axi_ar_size          : out std_logic_vector(2 downto 0);
      o_m_axi_ar_burst         : out std_logic_vector(1 downto 0);
      o_m_axi_ar_lock          : out std_logic;
      o_m_axi_ar_cache         : out std_logic_vector(3 downto 0);
      o_m_axi_ar_prot          : out std_logic_vector(2 downto 0);
      o_m_axi_ar_qos           : out std_logic_vector(3 downto 0);
      i_m_axi_r_valid          : in std_logic;
      o_m_axi_r_ready          : out std_logic;
      i_m_axi_r_id             : in std_logic_vector(g_ID_R_WIDTH-1 downto 0);
      i_m_axi_r_data           : in std_logic_vector(g_DATA_WIDTH-1 downto 0);
      i_m_axi_r_resp           : in std_logic_vector(g_RRESP_WIDTH-1 downto 0);
      i_m_axi_r_last           : in std_logic;
      i_reset                  : in std_logic;
      i_aclk                   : in std_logic;
      i_trigger_transaction    : in std_logic;
      i_fifo_data              : in std_logic_vector(g_FIFO_WIDTH-1 downto 0) := "001101011110001100000011";
      o_fifo_data              : out std_logic_vector(g_FIFO_WIDTH-1 downto 0);
      i_write_address          : in std_logic_vector(g_ADDR_WIDTH-1 downto 0);
      o_fifo_read              : out std_logic;
      o_last_write_response    : out std_logic_vector(g_BRESP_WIDTH-1 downto 0);
      i_read_address           : in std_logic_vector(g_ADDR_WIDTH-1 downto 0);
      o_fifo_write             : out std_logic;
      o_last_read_response     : out std_logic_vector(g_BRESP_WIDTH-1 downto 0)
    );
  end component;

signal tb_m_axi_aw_valid     : std_logic;
signal tb_m_axi_aw_id        : std_logic_vector(g_ID_W_WIDTH-1 downto 0);
signal tb_m_axi_aw_addr      : std_logic_vector(g_ADDR_WIDTH-1 downto 0);
signal tb_m_axi_aw_len       : std_logic_vector(7 downto 0);
signal tb_m_axi_aw_size      : std_logic_vector(2 downto 0);
signal tb_m_axi_aw_burst     : std_logic_vector(1 downto 0);
signal tb_m_axi_aw_cache     : std_logic_vector(3 downto 0);
signal tb_m_axi_aw_prot      : std_logic_vector(2 downto 0);
signal tb_m_axi_aw_qos       : std_logic_vector(3 downto 0);
signal tb_m_axi_w_data       : std_logic_vector(g_DATA_WIDTH-1 downto 0);
signal tb_m_axi_w_strb       : std_logic_vector(3 downto 0);
signal tb_m_axi_w_last       : std_logic;
signal tb_m_axi_b_ready      : std_logic;
signal tb_m_axi_ar_valid     : std_logic;
signal tb_m_axi_ar_id        : std_logic_vector(g_ID_R_WIDTH-1 downto 0);
signal tb_m_axi_ar_addr      : std_logic_vector(g_ADDR_WIDTH-1 downto 0);
signal tb_m_axi_ar_len       : std_logic_vector(7 downto 0);
signal tb_m_axi_ar_size      : std_logic_vector(2 downto 0);
signal tb_m_axi_ar_burst     : std_logic_vector(1 downto 0);
signal tb_m_axi_ar_cache     : std_logic_vector(3 downto 0);
signal tb_m_axi_ar_prot      : std_logic_vector(2 downto 0);
signal tb_m_axi_ar_qos       : std_logic_vector(3 downto 0);
signal tb_m_axi_r_ready      : std_logic;
signal tb_m_axi_ar_lock: std_logic;
signal tb_m_axi_aw_lock: std_logic;
signal tb_m_axi_w_valid: std_logic;

begin
  -- Instantiate the m_axi DUT
  uut : m_axi
    generic map (
      g_FIFO_WIDTH          => g_FIFO_WIDTH,
      g_ID_W_WIDTH          => g_ID_W_WIDTH,
      g_ID_R_WIDTH          => g_ID_R_WIDTH,
      g_ADDR_WIDTH          => g_ADDR_WIDTH,
      g_DATA_WIDTH          => g_DATA_WIDTH,
      g_BRESP_WIDTH         => g_BRESP_WIDTH,
      g_RRESP_WIDTH         => g_RRESP_WIDTH,
      g_TRANSACTION_LENGTH  => g_TRANSACTION_LENGTH,
      g_TRANSACTION_SIZE    => g_TRANSACTION_SIZE,
      g_BURST_ATTRB         => g_BURST_ATTRB,
      g_LOCK_ATTRB          => g_LOCK_ATTRB,
      g_CACHE_ATTRB         => g_CACHE_ATTRB,
      g_PROT_ATTRB          => g_PROT_ATTRB,
      g_QOS_ATTRB           => g_QOS_ATTRB,
      g_STROBE_ATTRB        => g_STROBE_ATTRB
    )
  port map (
    o_m_axi_aw_valid         => tb_m_axi_aw_valid,
    i_m_axi_aw_ready         => '0',
    o_m_axi_aw_id            => tb_m_axi_aw_id,
    o_m_axi_aw_addr          => tb_m_axi_aw_addr,
    o_m_axi_aw_len           => tb_m_axi_aw_len,
    o_m_axi_aw_size          => tb_m_axi_aw_size,
    o_m_axi_aw_burst         => tb_m_axi_aw_burst,
    o_m_axi_aw_lock          => tb_m_axi_aw_lock,
    o_m_axi_aw_cache         => tb_m_axi_aw_cache,
    o_m_axi_aw_prot          => tb_m_axi_aw_prot,
    o_m_axi_aw_qos           => tb_m_axi_aw_qos,
    o_m_axi_w_valid          => tb_m_axi_w_valid,
    i_m_axi_w_ready          => '0',
    o_m_axi_w_data           => tb_m_axi_w_data,
    o_m_axi_w_strb           => tb_m_axi_w_strb,
    o_m_axi_w_last           => tb_m_axi_w_last,
    i_m_axi_b_valid          => '0',
    o_m_axi_b_ready          => tb_m_axi_b_ready,
    i_m_axi_b_id             => (others => '0'),
    i_m_axi_b_resp           => (others => '0'),
    o_m_axi_ar_valid         => tb_m_axi_ar_valid,
    i_m_axi_ar_ready         => '0',
    o_m_axi_ar_id            => tb_m_axi_ar_id,
    o_m_axi_ar_addr          => tb_m_axi_ar_addr,
    o_m_axi_ar_len           => tb_m_axi_ar_len,
    o_m_axi_ar_size          => tb_m_axi_ar_size,
    o_m_axi_ar_burst         => tb_m_axi_ar_burst,
    o_m_axi_ar_lock          => tb_m_axi_ar_lock,
    o_m_axi_ar_cache         => tb_m_axi_ar_cache,
    o_m_axi_ar_prot          => tb_m_axi_ar_prot,
    o_m_axi_ar_qos           => tb_m_axi_ar_qos,
    i_m_axi_r_valid          => '0',
    o_m_axi_r_ready          => tb_m_axi_r_ready,
    i_m_axi_r_id             => (others => '0'),
    i_m_axi_r_data           => (others => '0'),
    i_m_axi_r_resp           => (others => '0'),
    i_m_axi_r_last           => '0',
    i_reset                  => i_reset,
    i_aclk                   => i_aclk,
    i_trigger_transaction    => i_trigger_transaction,
    i_fifo_data              => i_fifo_data,
    o_fifo_data              => o_fifo_data,
    i_write_address          => i_write_address,
    o_fifo_read              => o_fifo_read,
    o_last_write_response    => o_last_write_response,
    i_read_address           => i_read_address,
    o_fifo_write             => o_fifo_write,
    o_last_read_response     => o_last_read_response
  );

      -- Clock process
  process
  begin
    while now < 1000 ns loop
      i_aclk <= '0';
      wait for 12.5 ns;
      i_aclk <= '1';
      wait for 12.5 ns;
    end loop;
    wait;
  end process;

  -- Stimulus process
  process
  begin
    -- Initialize signals
    i_reset                 <= '1';
    i_trigger_transaction   <= '0';
    i_fifo_data             <= (others => '0');
    i_write_address         <= (others => '0');
    i_read_address          <= (others => '0');

    -- Release reset
    wait for 10 ns;
    i_reset <= '0';

    -- Trigger transactions
    wait for 50 ns;
    i_trigger_transaction <= '1';

    -- Wait for transactions to complete
    wait for 100 ns;

    -- End simulation
    wait;
  end process;
end testbench_arch;
