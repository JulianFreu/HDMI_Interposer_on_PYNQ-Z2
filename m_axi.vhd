entity m_axi is
    generic(

    )
    port(
       --Write request channel
        AWVALID         : out std_logic; -- Valid indicator
        AWREADY         : in std_logic; -- Ready indicator
        AWID            : out std_logic_vector(ID_W_WIDTH-1 downto 0); -- Transaction identifier for the write channels
        AWADDR          : out std_logic_vector(ADDR_WIDTH-1 downto 0); -- Transaction address
        AWREGION        : out std_logic_vector(3 downto 0); -- Region identifier
        AWLEN           : out std_logic_vector(7 downto 0); -- Transaction length
        AWSIZE          : out std_logic_vector(2 downto 0); -- Transaction size
        AWBURST         : out std_logic_vector(1 downto 0); -- Burst attribute
        AWLOCK          : out std_logic; -- Exclusive access indicator
        AWCACHE         : out std_logic_vector(3 downto 0); -- Memory attributes
        AWPROT          : out std_logic_vector(2 downto 0); -- Access attributes
        AWNSE           : out std_logic; -- Non-secure extension bit for RME
        AWQOS           : out std_logic_vector(3 downto 0); -- QoS identifier
        AWUSER          : out std_logic_vector(USER_REQ_WIDTH-1 downto 0); -- User-defined extension to a request
        AWDOMAIN        : out std_logic_vector(1 downto 0); -- Shareability domain of a request
        AWSNOOP         : out std_logic_vector(AWSNOOP_WIDTH-1 downto 0); -- Write request opcode
        AWSTASHNID      : out std_logic_vector(10 downto 0); -- Stash Node ID
        AWSTASHNIDEN    : out std_logic; -- Stash Node ID enable
        AWSTASHLPID     : out std_logic_vector(4 downto 0); -- Stash Logical Processor ID
        AWSTASHLPIDEN   : out std_logic; -- Stash Logical Processor ID enable
        AWTRACE         : out std_logic; -- Trace signal
        AWLOOP          : out std_logic_vector(LOOP_W_WIDTH-1 downto 0); -- Loopback signals on the write channels
        AWMMUVALID      : out std_logic; -- MMU signal qualifier
        AWMMUSECSID     : out std_logic_vector(SECSID_WIDTH-1 downto 0); -- Secure Stream ID
        AWMMUSID        : out std_logic_vector(SID_WIDTH-1 downto 0); -- StreamID
        AWMMUSSIDV      : out std_logic; -- SubstreamID valid
        AWMMUSSID       : out std_logic_vector(SSID_WIDTH-1 downto 0); -- SubstreamID
        AWMMUATST       : out std_logic; -- Address translated indicator
        AWMMUFLOW       : out std_logic_vector(1 downto 0); -- SMMU flow type
        AWPBHA          : out std_logic_vector(3 downto 0); -- Page-based Hardware Attributes
        AWNSAID         : out std_logic_vector(3 downto 0); -- Non-secure Access ID
        AWSUBSYSID      : out std_logic_vector(SUBSYSID_WIDTH-1 downto 0); -- Subsystem ID
        AWATOP          : out std_logic_vector(5 downto 0); -- Atomic transaction opcode
        AWMPAM          : out std_logic_vector(MPAM_WIDTH-1 downto 0); -- MPAM information with a request
        AWIDUNQ         : out std_logic; -- Unique ID indicator
        AWCMO           : out std_logic_vector(AWCMO_WIDTH-1 downto 0); -- CMO type
        AWTAGOP         : out std_logic_vector(1 downto 0); -- Memory Tag operation for write requests
        --Write data channel
        WVALID: out std_logic; -- Valid indicator
        WREADY : in std_logic; -- Ready indicator
        WDATA : out std_logic_vector(DATA_WIDTH-1 downto 0); -- Write data
        WSTRB : out std_logic_vector(DATA_WIDTH-1 downto 0); -- / : out std_logic_vector(7 downto 0); -- Write data strobes
        WLAST: out std_logic; -- Last write data
        WUSER : out std_logic_vector(USER_DATA_WIDTH-1 downto 0); -- User-defined extension to write data
        WPOISON : out std_logic_vector((DATA_WIDTH/64)-1 downto 0); -- Poison indicator
        WTRACE: out std_logic; -- Trace signal
        WTAG : out std_logic_vector(ceil(DATA_WIDTH/128)*4-1 downto 0); -- Memory Tag
        WTAGUPDATE : out std_logic_vector(ceil(DATA_WIDTH/128)-1 downto 0); -- Memory Tag update
            --Write response channel
        BVALID : in std_logic; -- Valid indicator
        BREADY: out std_logic; -- Ready indicator
        BID : in std_logic_vector(ID_W_WIDTH-1 downto 0); -- in Transaction identifier for the write channels
        BRESP : in std_logic_vector(BRESP_WIDTH-1 downto 0); -- in Write response
        BUSER : in std_logic_vector(USER_RESP_WIDTH-1 downto 0); -- in User-defined extension to a write response
        BTRACE : in std_logic; -- Trace signal
        BLOOP : in std_logic_vector(LOOP_W_WIDTH-1 downto 0); -- in Loopback signals on the write channels
        BBUSY : in std_logic_vector(1 downto 0); -- Busy indicator
        BIDUNQ : in std_logic; -- Unique ID indicator
        BCOMP : in std_logic; -- Completion response indicator
        BPERSIST : in std_logic; -- Persist response
        BTAGMATCH : in std_logic_vector(1 downto 0); -- Memory Tag Match response
        -- read request channel
        ARVALID     : out std_logic; -- valid indicator
        ARREADY     : in std_logic;      -- ready indicator
        ARID        : out std_logic_vector(ID_R_WIDTH-1 downto 0); --Transaction identifier for the read channels
        ARADDR      : out std_logic_vector(ADDR_WIDTH-1 downto 0);
        ARREGION : out std_logic_vector(3 downto 0); -- Region identifier
        ARLEN : out std_logic_vector(7 downto 0); -- Transaction length
        ARSIZE : out std_logic_vector(2 downto 0); -- Transaction size
        ARBURST : out std_logic_vector(1 downto 0); -- Burst attribute
        ARLOCK: out std_logic; -- Exclusive access indicator
        ARCACHE : out std_logic_vector(3 downto 0); -- Memory attributes
        ARPROT : out std_logic_vector(2 downto 0); -- Access attributes
        ARNSE: out std_logic; -- Non-secure extension bit for RME
        ARQOS : out std_logic_vector(3 downto 0); -- QoS identifier
        ARUSER : out std_logic_vector(USER_REQ_WIDTH-1 downto 0); -- User-defined extension to a request
        ARDOMAIN : out std_logic_vector(1 downto 0); -- Shareability domain of a request
        ARSNOOP : out  std_logic_vector(ARSNOOP_WIDTH-1 downto 0); -- Read request opcode
        ARTRACE: out std_logic; -- Trace signal
        ARLOOP : out  std_logic_vector(LOOP_R_WIDTH-1 downto 0); -- Loopback signals on the read channels
        ARMMUVALID: out std_logic; -- MMU signal qualifier
        ARMMUSECSID : out  std_logic_vector(SECSID_WIDTH-1 downto 0); -- Secure Stream ID
        ARMMUSID : out  std_logic_vector(SID_WIDTH-1 downto 0); -- StreamID
        ARMMUSSIDV: out std_logic; -- SubstreamID valid
        ARMMUSSID : out  std_logic_vector(SSID_WIDTH-1 downto 0); -- SubstreamID
        ARMMUATST: out std_logic; -- Address translated indicator
        ARMMUFLOW : out std_logic_vector(1 downto 0); -- SMMU flow type 
        ARPBHA : out std_logic_vector(3 downto 0); -- Page-based Hardware Attributes
        ARNSAID : out std_logic_vector(3 downto 0); -- Non-secure Access ID
        ARSUBSYSID  : out std_logic_vector(SUBSYSID_WIDTH-1 downto 0); -- Subsystem ID
        ARMPAM : out  std_logic_vector(MPAM_WIDTH-1 downto 0); -- MPAM information with a request
        ARCHUNKEN: out std_logic; -- Read data chunking enable
        ARIDUNQ: out std_logic; -- Unique ID indicator
        ARTAGOP : out std_logic_vector(1 downto 0); -- Memory Tag operation for read requests
        --read data channel
        RVALID : in std_logic; -- Valid indicator
        RREADY: out std_logic; -- Ready indicator
        RID : in  std_logic_vector(ID_R_WIDTH-1 downto 0); -- in Transaction identifier for the read channels
        RDATA : in  std_logic_vector(DATA_WIDTH-1 downto 0); -- in Read data
        RRESP : in  std_logic_vector(RRESP_WIDTH-1 downto 0); -- in Read response
        RLAST : in std_logic; -- Last read data 
        RUSER : in  std_logic_vector(USER_DATA_WIDTH + USER_RESP_WIDTH-1 downto 0); -- in User-defined extension to read data and response
        RPOISON : in  std_logic_vector(DATA_WIDTH / 64-1 downto 0); -- in Poison indicator
        RTRACE : in std_logic; -- Trace signal
        RLOOP : in  std_logic_vector(LOOP_R_WIDTH-1 downto 0); -- in Loopback signals on the read channels
        RBUSY : in std_logic_vector(1 downto 0); -- Busy indicator
        RIDUNQ : in std_logic; -- Unique ID indicator
        RCHUNKV : in std_logic; -- Read data chunking valid
        RCHUNKNUM : in  std_logic_vector(RCHUNKNUM_WIDTH-1 downto 0); -- in Read data chunk number
        RCHUNKSTRB : in  std_logic_vector(RCHUNKSTRB_WIDTH-1 downto 0); -- in Read data chunk strobe
        RTAG : in  std_logic_vector(ceil(DATA_WIDTH/128)*4-1 downto 0); -- in Memory Tag
        --snoop request channel
        ACVALID : in std_logic; -- Valid indicator
        ACREADY: out std_logic; -- Ready indicator
        ACADDR : in  std_logic_vector(ADDR_WIDTH-1 downto 0); -- in DVM message payload
        ACVMIDEXT : in std_logic_vector(3 downto 0); -- VMID extension for DVM messages
        ACTRACE : in std_logic; -- Trace signal
        --snoop response channel

        CRVALID: out std_logic; -- Valid indicator
        CRREADY : in std_logic; -- Ready indicator
        CRTRACE: out std_logic; -- Trace signal
        --clk and reset signals
        ACLK : in std_logic; -- External Global clock signal
        ARESETn  : in std_logic; --External Global reset signal
        --wakeup signals
        AWAKEUP: out std_logic; -- Wake-up signal associated with read and write channels
        ACWAKEUP : in std_logic; -- Wake-up signal associated with snoop channels
        --QoS accept signals
        VAWQOSACCEPT : in std_logic_vector(3 downto 0); -- QoS acceptance level for write requests
        VARQOSACCEPT : in std_logic_vector(3 downto 0); -- QoS acceptance level for read requests
        --Coherency Connection signals
        SYSCOREQ: out std_logic; -- Coherency connect request
        SYSCOACK : in std_logic; -- Coherency connect acknowledge
        --Interface control signals
        BROADCASTATOMIC  : in std_logic; -- Tie-off Control input for Atomic transactions
        BROADCASTSHAREABLE  : in std_logic; -- Tie-off Control input for Shareable transactions
        BROADCASTCACHEMAINT  : in std_logic; -- Tie-off Control input for cache maintenance operations
        BROADCASTCMOPOPA : in std_logic; -- Tie-off Control input for the CleanInvalidPoPA CMO
        BROADCASTPERSIST : in std_logic; -- Tie-off Control input for CleanSharedPersist and CleanSharedDeepPersist
    );
end m_axi;

architecture arch of m_axi is

begin

end architecture;
