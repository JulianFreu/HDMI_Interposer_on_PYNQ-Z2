library ieee;
use ieee.std_logic_1164.all;

entity Frame_Buffer_Ctrl is
    generic (
        --fifo
        g_FIFO_DEPTH                : integer := 50;   
        g_FIFO_WIDTH                : integer := 24;
        g_ALMOST_FULL_THRESHOLD     : integer := 35;
        g_ALMOST_EMPTY_THRESHOLD    : integer := 15;

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
        i_fifo_wr_en    : in std_logic;
        o_data_red      : out std_logic_vector(7 downto 0);
        o_data_green    : out std_logic_vector(7 downto 0);
        o_data_blue     : out std_logic_vector(7 downto 0);
        i_data_red      : in std_logic_vector(7 downto 0);
        i_data_green    : in std_logic_vector(7 downto 0);
        i_data_blue     : in std_logic_vector(7 downto 0);
        i_frame_ready   : in std_logic;
        -- AXI interface

        --write request channel
        o_m_axi_aw_valid        : out std_logic; -- Valid indicator 
        i_m_axi_aw_ready        : in std_logic; -- Ready indicator
        o_m_axi_aw_id           : out std_logic_vector(g_ID_W_WIDTH-1 downto 0) := (others => '0'); -- Transaction identifier for the write channels
        o_m_axi_aw_addr         : out std_logic_vector(g_ADDR_WIDTH-1 downto 0); -- Transaction address
        o_m_axi_aw_len          : out std_logic_vector(7 downto 0) := g_TRANSACTION_LENGTH; -- Transaction length
        o_m_axi_aw_size         : out std_logic_vector(2 downto 0) := g_TRANSACTION_SIZE; -- Transaction size
        o_m_axi_aw_burst        : out std_logic_vector(1 downto 0) := g_BURST_ATTRB; -- Burst attribute
        o_m_axi_aw_lock         : out std_logic := g_LOCK_ATTRB; -- Exclusive access indicator (not supported by Xiliinx, leave on 0, see ug1037
        o_m_axi_aw_cache        : out std_logic_vector(3 downto 0) := g_CACHE_ATTRB; -- Memory attributes 0011 signifying a bufferable and modifiable transaction
        o_m_axi_aw_prot         : out std_logic_vector(2 downto 0) := g_PROT_ATTRB; -- Access attributes Protections bits should be constant at 000 signifying a constantly secure transaction type
        o_m_axi_aw_qos          : out std_logic_vector(3 downto 0) := g_QOS_ATTRB; -- QoS identifier Endpoint IP generally ignores the QoS bits
        --write data channel
        o_m_axi_w_valid         : out std_logic; -- Valid indicator
        i_m_axi_w_ready         : in std_logic; -- Ready indicator
        o_m_axi_w_data          : out std_logic_vector(g_DATA_WIDTH-1 downto 0); -- Write data
        o_m_axi_w_strb          : out std_logic_vector((g_DATA_WIDTH/8)-1 downto 0) := g_STROBE_ATTRB; -- The WSTRB signal carries write strobes that specify which byte lanes of the write data channel contain valid information
        o_m_axi_w_last          : out std_logic; -- Last write data
        --write response channel
        i_m_axi_b_valid         : in std_logic; -- Valid indicator
        o_m_axi_b_ready         : out std_logic; -- Ready indicator
        i_m_axi_b_id            : in std_logic_vector(g_ID_W_WIDTH-1 downto 0); -- Transaction identifier for the write channels
        i_m_axi_b_resp          : in std_logic_vector(g_BRESP_WIDTH-1 downto 0); -- Write response
        -- read request channel
        o_m_axi_ar_valid        : out std_logic; -- valid indicator
        i_m_axi_ar_ready        : in std_logic;      -- ready indicator
        o_m_axi_ar_id           : out std_logic_vector(g_ID_R_WIDTH-1 downto 0); --Transaction identifier for the read channels
        o_m_axi_ar_addr         : out std_logic_vector(g_ADDR_WIDTH-1 downto 0);
        o_m_axi_ar_len          : out std_logic_vector(7 downto 0)  := g_TRANSACTION_LENGTH; -- Transaction length 
        o_m_axi_ar_size         : out std_logic_vector(2 downto 0) := g_TRANSACTION_SIZE;-- Transaction size 
        o_m_axi_ar_burst        : out std_logic_vector(1 downto 0) := g_BURST_ATTRB; -- Burst attribute  
        o_m_axi_ar_lock         : out std_logic := g_LOCK_ATTRB; -- Exclusive access indicator (not supported by Xiliinx, leave on 0, see ug1037
        o_m_axi_ar_cache        : out std_logic_vector(3 downto 0) := g_CACHE_ATTRB; -- Memory attributes 0011 signifying a bufferable and modifiable transaction
        o_m_axi_ar_prot         : out std_logic_vector(2 downto 0) := g_PROT_ATTRB; -- Access attributes Protections bits should be constant at 000 signifying a constantly secure transaction type
        o_m_axi_ar_qos          : out std_logic_vector(3 downto 0) := g_QOS_ATTRB; -- QoS identifier Endpoint IP generally ignores the QoS bits
        --read data channel
        i_m_axi_r_valid         : in std_logic; -- Valid indicator
        o_m_axi_r_ready         : out std_logic; -- Ready indicator
        i_m_axi_r_id            : in  std_logic_vector(g_ID_R_WIDTH-1 downto 0); -- in Transaction identifier for the read channels
        i_m_axi_r_data          : in  std_logic_vector(g_DATA_WIDTH-1 downto 0); -- in Read data
        i_m_axi_r_resp          : in  std_logic_vector(g_RRESP_WIDTH-1 downto 0); -- in Read response
        i_m_axi_r_last          : in std_logic; -- Last read data 
        
        i_reset                 : in std_logic;   
        i_clk                   : in std_logic;
        i_write_address          : in std_logic_vector(g_ADDR_WIDTH-1 downto 0);
        o_last_write_response    : out std_logic_vector(g_BRESP_WIDTH-1 downto 0); -- probably only for debugging purposes connecto to LED? should be 0 when all ok 
        
        i_read_address           : in std_logic_vector(g_ADDR_WIDTH-1 downto 0);
        o_last_read_response     : out std_logic_vector(g_BRESP_WIDTH-1 downto 0) -- probably only for debugging purposes connecto to LED? should be 0 when all ok
    );
end Frame_Buffer_Ctrl;

architecture arch of Frame_Buffer_Ctrl is

    component m_axi is
        generic(
            g_FIFO_WIDTH          : integer                         := g_FIFO_WIDTH;
            g_ID_W_WIDTH          : integer                         := g_ID_W_WIDTH; 
            g_ID_R_WIDTH          : integer                         := g_ID_R_WIDTH; 
            g_ADDR_WIDTH          : integer                         := g_ADDR_WIDTH;
            g_DATA_WIDTH          : integer                         := g_DATA_WIDTH;
            g_BRESP_WIDTH         : integer                         := g_BRESP_WIDTH;
            g_RRESP_WIDTH         : integer                         := g_RRESP_WIDTH;
            g_TRANSACTION_LENGTH  : std_logic_vector(7 downto 0)    := g_TRANSACTION_LENGTH; -- 16                                          
            g_TRANSACTION_SIZE    : std_logic_vector(2 downto 0)    := g_TRANSACTION_SIZE; -- 4 bytes                                                            
            g_BURST_ATTRB         : std_logic_vector(1 downto 0)    := g_BURST_ATTRB; -- Burst attribute "0b01" incrementing burst                  
            g_LOCK_ATTRB          : std_logic                       := g_LOCK_ATTRB;       -- Exclusive access indicator (not supported by Xiliinx, leave on 0, see ug1037
            g_CACHE_ATTRB         : std_logic_vector(3 downto 0)    := g_CACHE_ATTRB;                                                                      
            g_PROT_ATTRB          : std_logic_vector(2 downto 0)    := g_PROT_ATTRB;                                                                                                 
            g_QOS_ATTRB           : std_logic_vector(3 downto 0)    := g_QOS_ATTRB;                                                                          
            g_STROBE_ATTRB        : std_logic_vector(3 downto 0) := g_STROBE_ATTRB                                                                            
        );
        port(
            --write request channel
            o_m_axi_aw_valid         : out std_logic; -- Valid indicator 
            i_m_axi_aw_ready         : in std_logic; -- Ready indicator
            o_m_axi_aw_id            : out std_logic_vector(g_ID_W_WIDTH-1 downto 0) := (others => '0'); -- Transaction identifier for the write channels
            o_m_axi_aw_addr          : out std_logic_vector(g_ADDR_WIDTH-1 downto 0); -- Transaction address
            o_m_axi_aw_len           : out std_logic_vector(7 downto 0) := g_TRANSACTION_LENGTH; -- Transaction length
            o_m_axi_aw_size          : out std_logic_vector(2 downto 0) := g_TRANSACTION_SIZE; -- Transaction size
            o_m_axi_aw_burst         : out std_logic_vector(1 downto 0) := g_BURST_ATTRB; -- Burst attribute
            o_m_axi_aw_lock          : out std_logic := g_LOCK_ATTRB; -- Exclusive access indicator (not supported by Xiliinx, leave on 0, see ug1037
            o_m_axi_aw_cache         : out std_logic_vector(3 downto 0) := g_CACHE_ATTRB; -- Memory attributes 0011 signifying a bufferable and modifiable transaction
            o_m_axi_aw_prot          : out std_logic_vector(2 downto 0) := g_PROT_ATTRB; -- Access attributes Protections bits should be constant at 000 signifying a constantly secure transaction type
            o_m_axi_aw_qos           : out std_logic_vector(3 downto 0) := g_QOS_ATTRB; -- QoS identifier Endpoint IP generally ignores the QoS bits
            --write data channel
            o_m_axi_w_valid          : out std_logic; -- Valid indicator
            i_m_axi_w_ready          : in std_logic; -- Ready indicator
            o_m_axi_w_data           : out std_logic_vector(g_DATA_WIDTH-1 downto 0); -- Write data
            o_m_axi_w_strb           : out std_logic_vector((g_DATA_WIDTH/8)-1 downto 0) := g_STROBE_ATTRB; -- The WSTRB signal carries write strobes that specify which byte lanes of the write data channel contain valid information
            o_m_axi_w_last           : out std_logic; -- Last write data
            --write response channel
            i_m_axi_b_valid          : in std_logic; -- Valid indicator
            o_m_axi_b_ready          : out std_logic; -- Ready indicator
            i_m_axi_b_id             : in std_logic_vector(g_ID_W_WIDTH-1 downto 0); -- Transaction identifier for the write channels
            i_m_axi_b_resp           : in std_logic_vector(g_BRESP_WIDTH-1 downto 0); -- Write response
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
            
            i_fifo_data              : in std_logic_vector(g_FIFO_WIDTH-1 downto 0);
            i_write_address          : in std_logic_vector(g_ADDR_WIDTH-1 downto 0);
            o_fifo_read              : out std_logic;
            o_last_write_response    : out std_logic_vector(g_BRESP_WIDTH-1 downto 0); -- probably only for debugging purposes connecto to LED? should be 0 when all ok

            o_fifo_data              : out std_logic_vector(g_FIFO_WIDTH-1 downto 0);
            i_read_address           : in std_logic_vector(g_ADDR_WIDTH-1 downto 0);
            o_fifo_write             : out std_logic;
            o_last_read_response     : out std_logic_vector(g_BRESP_WIDTH-1 downto 0) -- probably only for debugging purposes connecto to LED? should be 0 when all ok
        );
    end component;

    component fifo is
        generic(
            g_FIFO_DEPTH                : integer := g_FIFO_DEPTH;    
            g_FIFO_WIDTH                : integer := g_FIFO_WIDTH;            
            g_ALMOST_FULL_THRESHOLD     : integer := g_ALMOST_FULL_THRESHOLD;    
            g_ALMOST_EMPTY_THRESHOLD    : integer := g_ALMOST_EMPTY_THRESHOLD
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

    signal w_m_axi_w_valid : std_logic;
    signal w_fifo2axi_data_out : std_logic_vector(g_FIFO_WIDTH-1 downto 0);
    signal w_axi2fifo_data_out : std_logic_vector(g_FIFO_WIDTH-1 downto 0);
    signal w_fifo2frame_data_out : std_logic_vector(g_FIFO_WIDTH-1 downto 0);
    signal w_frame2fifo_data_in : std_logic_vector(g_FIFO_WIDTH-1 downto 0);
    signal w_trigger_write_transaction : std_logic;
    signal w_trigger_read_transaction : std_logic;
    signal w_fifo_almost_empty : std_logic;
    signal w_fifo_almost_full : std_logic;
    signal w_fifo_read_en   : std_logic;
    signal w_fifo_write_en  : std_logic;

begin

    frame_in_fifo : fifo
        port map (
            i_clk           => i_clk,
            i_reset         => i_reset,
            i_wr_en         => i_fifo_wr_en, --later this needs to be 1 when inside DrawArea and if the beginning of a frame was detected
            i_data_in       => w_frame2fifo_data_in,
            i_rd_en         => w_fifo_read_en,
            o_data_out      => w_fifo2axi_data_out,
            o_full          => open, -- maybe use for debugging, route to led?
            o_empty         => open,-- maybe use for debugging, route to led?
            o_almost_full   => open, -- maybe use for debugging, route to led?
            o_almost_empty  => w_fifo_almost_empty       
        );

    w_frame2fifo_data_in(7 downto 0) <= i_data_red;
    w_frame2fifo_data_in(15 downto 8) <= i_data_green;
    w_frame2fifo_data_in(23 downto 16) <= i_data_blue;

    frame_out_fifo : fifo
        port map (
            i_clk           => i_clk,
            i_reset         => i_reset,
            i_wr_en         => i_fifo_wr_en, --later this needs to be 1 when inside DrawArea and if the beginning of a frame was detected
            i_data_in       => i_m_axi_r_data(g_FIFO_WIDTH-1 downto 0), 
            i_rd_en         => w_fifo_read_en,
            o_data_out      => w_fifo2frame_data_out,
            o_full          => open, -- maybe use for debugging, route to led?
            o_empty         => open,-- maybe use for debugging, route to led?
            o_almost_full   => w_fifo_almost_full, -- maybe use for debugging, route to led?
            o_almost_empty  => open       
        );

    o_data_red <= w_fifo2frame_data_out(7 downto 0);
    o_data_green <= w_fifo2frame_data_out(15 downto 8);
    o_data_blue <= w_fifo2frame_data_out(23 downto 16);

    axi_master : m_axi
        port map(
            --write request channel
            o_m_axi_aw_valid            =>  o_m_axi_aw_valid,
            i_m_axi_aw_ready            =>  i_m_axi_aw_ready,
            o_m_axi_aw_id               =>  o_m_axi_aw_id,   
            o_m_axi_aw_addr             =>  o_m_axi_aw_addr, 
            o_m_axi_aw_len              =>  o_m_axi_aw_len,  
            o_m_axi_aw_size             =>  o_m_axi_aw_size, 
            o_m_axi_aw_burst            =>  o_m_axi_aw_burst,
            o_m_axi_aw_lock             =>  o_m_axi_aw_lock, 
            o_m_axi_aw_cache            =>  o_m_axi_aw_cache,
            o_m_axi_aw_prot             =>  o_m_axi_aw_prot, 
            o_m_axi_aw_qos              =>  o_m_axi_aw_qos, 
            --write data channel           
            o_m_axi_w_valid             =>  o_m_axi_w_valid, 
            i_m_axi_w_ready             =>  i_m_axi_w_ready, 
            o_m_axi_w_data              =>  o_m_axi_w_data, 
            o_m_axi_w_strb              =>  o_m_axi_w_strb,  
            o_m_axi_w_last              =>  o_m_axi_w_last,  
            --write response channel   
            i_m_axi_b_valid             =>  i_m_axi_b_valid, 
            o_m_axi_b_ready             =>  o_m_axi_b_ready,
            i_m_axi_b_id                =>  i_m_axi_b_id,    
            i_m_axi_b_resp              =>  i_m_axi_b_resp,  
            -- read request channel          
            o_m_axi_ar_valid            =>  o_m_axi_ar_valid,
            i_m_axi_ar_ready            =>  i_m_axi_ar_ready,
            o_m_axi_ar_id               =>  o_m_axi_ar_id,   
            o_m_axi_ar_addr             =>  o_m_axi_ar_addr, 
            o_m_axi_ar_len              =>  o_m_axi_ar_len,  
            o_m_axi_ar_size             =>  o_m_axi_ar_size,
            o_m_axi_ar_burst            =>  o_m_axi_ar_burst,
            o_m_axi_ar_lock             =>  o_m_axi_ar_lock, 
            o_m_axi_ar_cache            =>  o_m_axi_ar_cache,
            o_m_axi_ar_prot             =>  o_m_axi_ar_prot, 
            o_m_axi_ar_qos              =>  o_m_axi_ar_qos,
            --read data channel             
            i_m_axi_r_valid             =>  i_m_axi_r_valid, 
            o_m_axi_r_ready             =>  o_m_axi_r_ready, 
            i_m_axi_r_id                =>  i_m_axi_r_id,    
            i_m_axi_r_data              =>  i_m_axi_r_data,  
            i_m_axi_r_resp              =>  i_m_axi_r_resp,  
            i_m_axi_r_last              =>  i_m_axi_r_last,  
                            
            i_reset                     =>  i_reset,
            i_aclk                      =>  i_clk,

            i_trigger_transaction       =>  w_trigger_write_transaction,
            i_fifo_data                 =>  w_fifo2axi_data_out,
            i_write_address             =>  i_write_address,
            o_fifo_read                 =>  w_fifo_read_en,
            o_last_write_response       =>  o_last_write_response,
            
            o_fifo_data                 => w_axi2fifo_data_out,
            i_read_address              => i_read_address,
            o_fifo_write                => w_fifo_write_en,
            o_last_read_response        => o_last_read_response
        );

    w_trigger_write_transaction <= not w_fifo_almost_empty;
    o_data_red <= "11110000";
    o_data_green <= "01000000";
    o_data_blue <= "11110000";
end architecture;