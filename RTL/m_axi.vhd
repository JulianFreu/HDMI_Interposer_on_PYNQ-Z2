library ieee;
use ieee.std_logic_1164.all;

entity m_axi is
    generic(
        ID_W_WIDTH : integer := 6;
        ID_R_WIDTH : integer := 6;
        ADDR_WIDTH : integer := 32;
        DATA_WIDTH : integer := 32;
        BRESP_WIDTH : integer := 2;
        RRESP_WIDTH : integer := 2
    );
    port(
        --write request channel
        o_m_axi_aw_valid         : out std_logic; -- Valid indicator 
        i_m_axi_aw_ready         : in std_logic; -- Ready indicator
        o_m_axi_aw_id            : out std_logic_vector(ID_W_WIDTH-1 downto 0) := (others => '0'); -- Transaction identifier for the write channels
        o_m_axi_aw_addr          : out std_logic_vector(ADDR_WIDTH-1 downto 0); -- Transaction address
        o_m_axi_aw_len           : out std_logic_vector(7 downto 0) := "00001111"; -- Transaction length 16
        o_m_axi_aw_size          : out std_logic_vector(2 downto 0) := "010"; -- Transaction size "0b010" -> 4 bytes
        o_m_axi_aw_burst         : out std_logic_vector(1 downto 0) := "01"; -- Burst attribute "0b01" incrementing burst
        o_m_axi_aw_lock          : out std_logic := '0'; -- Exclusive access indicator (not supported by Xiliinx, leave on 0, see ug1037
        o_m_axi_aw_cache         : out std_logic_vector(3 downto 0) := "0011"; -- Memory attributes 0011 signifying a bufferable and modifiable transaction
        o_m_axi_aw_prot          : out std_logic_vector(2 downto 0) := "000"; -- Access attributes Protections bits should be constant at 000 signifying a constantly secure transaction type
        o_m_axi_aw_qos           : out std_logic_vector(3 downto 0) := "0000"; -- QoS identifier Endpoint IP generally ignores the QoS bits
        --write data channel
        o_m_axi_w_valid          : out std_logic; -- Valid indicator
        i_m_axi_w_ready          : in std_logic; -- Ready indicator
        o_m_axi_w_data           : out std_logic_vector(DATA_WIDTH-1 downto 0); -- Write data
        o_m_axi_w_strb           : out std_logic_vector((DATA_WIDTH/8)-1 downto 0) := "0111"; -- The WSTRB signal carries write strobes that specify which byte lanes of the write data channel contain valid information
        o_m_axi_w_last           : out std_logic; -- Last write data
        --write response channel
        i_m_axi_b_valid          : in std_logic; -- Valid indicator
        o_m_axi_b_ready          : out std_logic; -- Ready indicator
        i_m_axi_b_id             : in std_logic_vector(ID_W_WIDTH-1 downto 0); -- Transaction identifier for the write channels
        i_m_axi_b_resp           : in std_logic_vector(BRESP_WIDTH-1 downto 0); -- Write response
        -- read request channel
        o_m_axi_ar_valid         : out std_logic; -- valid indicator
        i_m_axi_ar_ready         : in std_logic;      -- ready indicator
        o_m_axi_ar_id            : out std_logic_vector(ID_R_WIDTH-1 downto 0); --Transaction identifier for the read channels
        o_m_axi_ar_addr          : out std_logic_vector(ADDR_WIDTH-1 downto 0);
        o_m_axi_ar_len           : out std_logic_vector(7 downto 0)  := "00001111"; -- Transaction length 16
        o_m_axi_ar_size          : out std_logic_vector(2 downto 0) := "010";-- Transaction size "0b010" -> 4 bytes
        o_m_axi_ar_burst         : out std_logic_vector(1 downto 0) := "01"; -- Burst attribute  "0b01" incrementing burst
        o_m_axi_ar_lock          : out std_logic := '0'; -- Exclusive access indicator (not supported by Xiliinx, leave on 0, see ug1037
        o_m_axi_ar_cache         : out std_logic_vector(3 downto 0) := "0011"; -- Memory attributes 0011 signifying a bufferable and modifiable transaction
        o_m_axi_ar_prot          : out std_logic_vector(2 downto 0) := "000"; -- Access attributes Protections bits should be constant at 000 signifying a constantly secure transaction type
        o_m_axi_ar_qos           : out std_logic_vector(3 downto 0) := "0000"; -- QoS identifier Endpoint IP generally ignores the QoS bits
        --read data channel
        i_m_axi_r_valid          : in std_logic; -- Valid indicator
        o_m_axi_r_ready          : out std_logic; -- Ready indicator
        i_m_axi_r_id             : in  std_logic_vector(ID_R_WIDTH-1 downto 0); -- in Transaction identifier for the read channels
        i_m_axi_r_data           : in  std_logic_vector(DATA_WIDTH-1 downto 0); -- in Read data
        i_m_axi_r_resp           : in  std_logic_vector(RRESP_WIDTH-1 downto 0); -- in Read response
        i_m_axi_r_last           : in std_logic; -- Last read data 


        i_reset                  : in std_logic;
        i_aclk                   : in std_logic;
        i_trigger_transaction    : in std_logic;
        i_fifo_data              : in std_logic_vector(23 downto 0);
        i_write_address          : in std_logic_vector(ADDR_WIDTH-1 downto 0);
        o_fifo_read              : out std_logic;
        o_last_write_response    : out std_logic_vector(BRESP_WIDTH-1 downto 0) -- probably only for debugging purposes connecto to LED? should be 0 when all ok
    );
end m_axi;

architecture arch of m_axi is

type fsm_states is (s_wait_for_next_transaction, s_write_request, s_write_data, s_check_response);
signal state : fsm_states;
signal next_state : fsm_states;
signal r_sent_bytes : integer range 0 to 15;
signal r_last_write_response : std_logic_vector(BRESP_WIDTH-1 downto 0);

begin
    state_switching : process(i_aclk, i_reset) is
    begin
        if rising_edge(i_aclk) then
            if (i_reset = '1') then 
                state <= s_wait_for_next_transaction;
                next_state <= s_wait_for_next_transaction;
            else
                state <= next_state;
            end if;
        end if;
    end process;

    fsm : process is

    begin
        if rising_edge(i_aclk) then
            case state is 
                when s_wait_for_next_transaction =>
                    o_fifo_read <= '0';
                    o_m_axi_aw_valid <= '0';
                    o_m_axi_aw_addr <= (others => '0');
                    o_m_axi_w_last <= '0';
                    o_m_axi_w_valid <= '0';
                    o_m_axi_w_data <= (others => '0');
                    o_m_axi_b_ready <= '0';
                    if i_trigger_transaction = '1' then
                        o_m_axi_aw_valid <= '1';
                        next_state <= s_write_request;
                    end if;

                when s_write_request =>
                    if o_m_axi_aw_valid = '1' and i_m_axi_aw_ready = '1' then
                        next_state <= s_write_data;
                        o_m_axi_aw_valid <= '0';
                        r_sent_bytes <= 0;
                        o_m_axi_w_valid <= '1';
                    end if;

                when s_write_data =>
                    if r_sent_bytes = 15 then
                        o_m_axi_w_last <= '1';
                        if o_m_axi_w_valid = '1' and i_m_axi_w_ready = '1' then
                            o_fifo_read <= '1';
                            next_state <= s_check_response;
                            o_m_axi_b_ready <= '1';
                        else 
                            o_fifo_read <= '0';
                        end if;
                    else 
                        o_m_axi_w_last <= '0';
                        if o_m_axi_w_valid = '1' and i_m_axi_w_ready = '1' then
                            r_sent_bytes <= r_sent_bytes +1;
                            o_fifo_read <= '1';
                        else
                            o_fifo_read <= '0';
                        end if;
                    end if;
                          
                when s_check_response =>
                    if i_m_axi_b_valid = '1' and o_m_axi_b_ready = '1' then
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

    o_m_axi_w_data <= i_fifo_data;
    o_m_axi_aw_addr <= i_write_address;
end architecture;
