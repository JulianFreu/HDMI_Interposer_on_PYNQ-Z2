library ieee;
use ieee.std_logic_1164.all;

entity m_axi_reader is
    generic (
        g_FIFO_WIDTH          : integer;
        g_ID_W_WIDTH          : integer; 
        g_ID_R_WIDTH          : integer; 
        g_ADDR_WIDTH          : integer;
        g_DATA_WIDTH          : integer;
        g_BRESP_WIDTH         : integer;
        g_RRESP_WIDTH         : integer;
        g_TRANSACTION_LENGTH  : std_logic_vector(7 downto 0); -- 16                                          
        g_TRANSACTION_SIZE    : std_logic_vector(2 downto 0); -- 4 bytes                                                            
        g_BURST_ATTRB         : std_logic_vector(1 downto 0); -- Burst attribute "0b01" incrementing burst                  
        g_LOCK_ATTRB          : std_logic;       -- Exclusive access indicator (not supported by Xiliinx, leave on 0, see ug1037
        g_CACHE_ATTRB         : std_logic_vector(3 downto 0);                                                                      
        g_PROT_ATTRB          : std_logic_vector(2 downto 0);                                                                                                 
        g_QOS_ATTRB           : std_logic_vector(3 downto 0);                                                                          
        g_STROBE_ATTRB        : std_logic_vector(3 downto 0)     -- for 32 bit data width
    );
    port (
        -- read request channel
        o_m_axi_ar_valid         : out std_logic; -- valid indicator
        i_m_axi_ar_ready         : in std_logic;      -- ready indicator
        o_m_axi_ar_id            : out std_logic_vector(g_ID_R_WIDTH-1 downto 0); --Transaction identifier for the read channels
        o_m_axi_ar_addr          : out std_logic_vector(g_ADDR_WIDTH-1 downto 0);
        o_m_axi_ar_len           : out std_logic_vector(7 downto 0)  := g_TRANSACTION_LENGTH; -- Transaction length 
        o_m_axi_ar_size          : out std_logic_vector(2 downto 0) := g_TRANSACTION_SIZE;-- Transaction size 
        o_m_axi_ar_burst         : out std_logic_vector(1 downto 0) := g_BURST_ATTRB; -- Burst attribute  
        o_m_axi_ar_lock          : out std_logic := g_LOCK_ATTRB; -- Exclusive access indicator (not supported by Xiliinx, leave on 0, see ug1037
        o_m_axi_ar_cache         : out std_logic_vector(3 downto 0) := g_CACHE_ATTRB; -- Memory attributes 0011 signifying a bufferable and modifiable transaction
        o_m_axi_ar_prot          : out std_logic_vector(2 downto 0) := g_PROT_ATTRB; -- Access attributes Protections bits should be constant at 000 signifying a constantly secure transaction type
        o_m_axi_ar_qos           : out std_logic_vector(3 downto 0) := g_QOS_ATTRB; -- QoS identifier Endpoint IP generally ignores the QoS bits
        --read data channel
        i_m_axi_r_valid          : in std_logic; -- Valid indicator
        o_m_axi_r_ready          : out std_logic; -- Ready indicator
        i_m_axi_r_id             : in  std_logic_vector(g_ID_R_WIDTH-1 downto 0); -- in Transaction identifier for the read channels
        i_m_axi_r_data           : in  std_logic_vector(g_DATA_WIDTH-1 downto 0); -- in Read data
        i_m_axi_r_resp           : in  std_logic_vector(g_RRESP_WIDTH-1 downto 0); -- in Read response
        i_m_axi_r_last           : in std_logic; -- Last read data 

        i_reset                  : in std_logic;
        i_aclk                   : in std_logic;
        i_trigger_transaction    : in std_logic;
        o_fifo_data              : out std_logic_vector(g_FIFO_WIDTH-1 downto 0);
       
        i_read_address           : in std_logic_vector(g_ADDR_WIDTH-1 downto 0);
        o_fifo_write             : out std_logic;
        o_last_read_response     : out std_logic_vector(g_BRESP_WIDTH-1 downto 0) -- probably only for debugging purposes connecto to LED? should be 0 when all ok
    );
    end m_axi_reader;

architecture arch of m_axi_reader is



begin

end architecture;