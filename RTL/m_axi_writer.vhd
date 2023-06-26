library ieee;
use ieee.std_logic_1164.all;

entity m_axi_writer is
    generic(
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
        o_m_axi_w_strb           : out std_logic_vector(3 downto 0) := g_STROBE_ATTRB; -- The WSTRB signal carries write strobes that specify which byte lanes of the write data channel contain valid information
        o_m_axi_w_last           : out std_logic; -- Last write data
        --write response channel
        i_m_axi_b_valid          : in std_logic; -- Valid indicator
        o_m_axi_b_ready          : out std_logic; -- Ready indicator
        i_m_axi_b_id             : in std_logic_vector(g_ID_W_WIDTH-1 downto 0); -- Transaction identifier for the write channels
        i_m_axi_b_resp           : in std_logic_vector(g_BRESP_WIDTH-1 downto 0); -- Write response

        i_reset                  : in std_logic;
        i_aclk                   : in std_logic;
        i_trigger_transaction    : in std_logic;
        i_fifo_data              : in std_logic_vector(g_FIFO_WIDTH-1 downto 0);

        i_write_address          : in std_logic_vector(g_ADDR_WIDTH-1 downto 0);
        o_fifo_read              : out std_logic;
        o_last_write_response    : out std_logic_vector(g_BRESP_WIDTH-1 downto 0) -- probably only for debugging purposes connecto to LED? should be 0 when all ok
    );
    end m_axi_writer;

architecture arch of m_axi_writer is
    type fsm_states is (s_wait_for_next_transaction, s_write_request, s_write_data, s_check_response);
    signal state : fsm_states := s_wait_for_next_transaction;
    signal next_state : fsm_states;
    signal r_sent_bytes : integer range 0 to 15 := 0;
    signal r_last_write_response : std_logic_vector(g_BRESP_WIDTH-1 downto 0);
    signal r_m_axi_b_ready : std_logic;  
    signal r_m_axi_w_valid : std_logic;
    signal r_m_axi_aw_valid : std_logic;
    signal r_m_axi_aw_addr  : std_logic_vector(g_ADDR_WIDTH-1 downto 0);
    
begin
    state_switching : process(i_aclk, i_reset) is
    begin
        if rising_edge(i_aclk) then
            if (i_reset = '1') then 
                state <= s_wait_for_next_transaction;
                --next_state <= s_wait_for_next_transaction;
            else
                state <= next_state;
            end if;
        end if;
    end process;

    write_fsm : process(i_aclk) is
    begin
        if rising_edge(i_aclk) then
            case state is 
                when s_wait_for_next_transaction =>
                    o_fifo_read <= '0';
                    r_m_axi_aw_valid <= '0';
                    r_m_axi_aw_addr <= (others => '0');
                    o_m_axi_w_last <= '0';
                    o_m_axi_w_valid <= '0';
                    o_m_axi_w_data <= (others => '0');
                    r_m_axi_b_ready <= '0';
                    if i_trigger_transaction = '1' then
                        r_m_axi_aw_valid <= '1';
                        r_m_axi_aw_addr <= i_write_address;
                        next_state <= s_write_request;
                    end if;

                when s_write_request =>
                    if r_m_axi_aw_valid = '1' and i_m_axi_aw_ready = '1' then
                        next_state <= s_write_data;
                        r_m_axi_aw_valid <= '0';
                        r_sent_bytes <= 0;
                        r_m_axi_w_valid <= '1';
                    end if;

                when s_write_data =>
                    if r_sent_bytes = 15 then
                        o_m_axi_w_last <= '1';
                        if r_m_axi_w_valid = '1' and i_m_axi_w_ready = '1' then
                            o_fifo_read <= '1';
                            next_state <= s_check_response;
                            r_m_axi_b_ready <= '1';
                        else 
                            o_fifo_read <= '0';
                        end if;
                    else 
                        o_m_axi_w_last <= '0';
                        if r_m_axi_w_valid = '1' and i_m_axi_w_ready = '1' then
                            r_sent_bytes <= r_sent_bytes +1;
                            o_fifo_read <= '1';
                        else
                            o_fifo_read <= '0';
                        end if;
                    end if;
                            
                when s_check_response =>
                    if i_m_axi_b_valid = '1' and r_m_axi_b_ready = '1' then
                        o_last_write_response <= i_m_axi_b_resp;
                        if i_trigger_transaction = '1' then
                            next_state <= s_write_request;
                        else 
                            next_state <= s_wait_for_next_transaction;
                        end if;
                    end if;     
            end case;
        end if;
    end process;

    o_m_axi_b_ready <= r_m_axi_b_ready;
    o_m_axi_w_valid <= r_m_axi_w_valid; 
    o_m_axi_aw_valid <= r_m_axi_aw_valid;
    o_m_axi_w_data <= "00000000" &  i_fifo_data;
    o_m_axi_aw_addr <= r_m_axi_aw_addr;
end architecture;