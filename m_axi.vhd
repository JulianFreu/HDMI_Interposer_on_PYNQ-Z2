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
        --Write request channel
        AWREADY         : in std_logic; -- Ready indicator
        AWID            : out std_logic_vector(ID_W_WIDTH-1 downto 0) := (others => '0'); -- Transaction identifier for the write channels
        AWADDR          : out std_logic_vector(ADDR_WIDTH-1 downto 0); -- Transaction address
        AWLEN           : out std_logic_vector(7 downto 0) := "00001000"; -- Transaction length 8
        AWSIZE          : out std_logic_vector(2 downto 0) := "010"; -- Transaction size "0b010" -> 4 bytes
        AWBURST         : out std_logic_vector(1 downto 0) := "01"; -- Burst attribute "0b01" incrementing burst
        AWLOCK          : out std_logic := '0'; -- Exclusive access indicator (not supported by Xiliinx, leave on 0, see ug1037
        AWCACHE         : out std_logic_vector(3 downto 0) := "0011"; -- Memory attributes 0011 signifying a bufferable and modifiable transaction
        AWPROT          : out std_logic_vector(2 downto 0) := "000"; -- Access attributes Protections bits should be constant at 000 signifying a constantly secure transaction type
        AWQOS           : out std_logic_vector(3 downto 0) := "0000"; -- QoS identifier Endpoint IP generally ignores the QoS bits
        --Write data channel
        WVALID          : out std_logic; -- Valid indicator
        WREADY          : in std_logic; -- Ready indicator
        WDATA           : out std_logic_vector(DATA_WIDTH-1 downto 0); -- Write data
        WSTRB           : out std_logic_vector((DATA_WIDTH/8)-1 downto 0); -- The WSTRB signal carries write strobes that specify which byte lanes of the write data channel contain valid information
        WLAST           : out std_logic; -- Last write data
        --Write response channel
        BVALID          : in std_logic; -- Valid indicator
        BREADY          : out std_logic; -- Ready indicator
        BID             : in std_logic_vector(ID_W_WIDTH-1 downto 0); -- Transaction identifier for the write channels
        BRESP           : in std_logic_vector(BRESP_WIDTH-1 downto 0); -- Write response
        -- read request channel
        ARVALID         : out std_logic; -- valid indicator
        ARREADY         : in std_logic;      -- ready indicator
        ARID            : out std_logic_vector(ID_R_WIDTH-1 downto 0); --Transaction identifier for the read channels
        ARADDR          : out std_logic_vector(ADDR_WIDTH-1 downto 0);
        ARLEN           : out std_logic_vector(7 downto 0)  := "00001000"; -- Transaction length
        ARSIZE          : out std_logic_vector(2 downto 0) := "010";-- Transaction size "0b010" -> 4 bytes
        ARBURST         : out std_logic_vector(1 downto 0) := "01"; -- Burst attribute  "0b01" incrementing burst
        ARLOCK          : out std_logic:= '0'; -- Exclusive access indicator (not supported by Xiliinx, leave on 0, see ug1037
        ARCACHE         : out std_logic_vector(3 downto 0) := "0011"; -- Memory attributes 0011 signifying a bufferable and modifiable transaction
        ARPROT          : out std_logic_vector(2 downto 0) := "000"; -- Access attributes Protections bits should be constant at 000 signifying a constantly secure transaction type
        ARQOS           : out std_logic_vector(3 downto 0) := "0000"; -- QoS identifier Endpoint IP generally ignores the QoS bits
        --read data channel
        RVALID          : in std_logic; -- Valid indicator
        RREADY          : out std_logic; -- Ready indicator
        RID             : in  std_logic_vector(ID_R_WIDTH-1 downto 0); -- in Transaction identifier for the read channels
        RDATA           : in  std_logic_vector(DATA_WIDTH-1 downto 0); -- in Read data
        RRESP           : in  std_logic_vector(RRESP_WIDTH-1 downto 0); -- in Read response
        RLAST           : in std_logic -- Last read data 
    );
end m_axi;

architecture arch of m_axi is

begin

end architecture;
