--------------------------------------------------------------------------------
-- PROJECT: ALTO FPGA Miner. SHA3-Solidity Flavor on Virtex ULTRAScale XCVU9P
--------------------------------------------------------------------------------
-- AUTHORS: Olivier FAURIE <olivier.faurie.hk@gmail.com>
-- LICENSE: 
-- WEBSITE: https://github.com/olivierHK
--------------------------------------------------------------------------------

library IEEE;
use     IEEE.STD_LOGIC_1164.ALL;
use     IEEE.NUMERIC_STD.ALL;
use     IEEE.STD_LOGIC_ARITH.ALL;
use     IEEE.STD_LOGIC_UNSIGNED.ALL;
use     IEEE.MATH_REAL.ALL;

Library UNISIM;
use     UNISIM.vcomponents.all;

library work;
use     work.MyPackage.all;

-------------------------------------------------------------------------------------------------------
------------------------------------------TOP ENTITY---------------------------------------------------
-------------------------------------------------------------------------------------------------------
entity Alto_top is
    Port (
        --CLOCK and nRESET
        i_CLK_100M   : in    std_logic; -- system clock 100 MHz from Card.
        i_RST_N      : in    std_logic; -- active low reset from Card.
       
        -- UART INTERFACE
        o_UART_TXD   : out   std_logic;
        i_UART_RXD   : in    std_logic;

        -- Sysmon I2C INTERFACE
        io_i2c_sclk  : inout STD_LOGIC;
        io_i2c_sda   : inout STD_LOGIC;
       
        --DEBUG/LED INTERFACE
        o_DEBUG_PORT : out   std_Logic_vector(7 downto 0)
    );
    
end entity;
-------------------------------------------------------------------------------------------------------



architecture ARCH of Alto_top is



    -------------------------------------------------------------------------------------------------------
    ------------------------------------------UART ENTITY--------------------------------------------------
    -------------------------------------------------------------------------------------------------------
    component UART
        Generic (
            CLK_FREQ      : integer := 12e6  ; -- system clock frequency in Hz. input 12MHz from PLL.
            BAUD_RATE     : integer := 115200; -- baud rate value
            PARITY_BIT    : string  := "none"; -- type of parity: "none", "even", "odd", "mark", "space"
            USE_DEBOUNCER : boolean := True    -- enable/disable debouncer
        );
        Port (
            -- CLOCK AND RESET
            CLK           : in  std_logic; -- system clock
            RST           : in  std_logic; -- high active synchronous reset
            -- UART INTERFACE
            UART_TXD      : out std_logic; -- serial transmit r_UART_data
            UART_RXD      : in  std_logic; -- serial receive r_UART_data
            -- USER r_UART_data TX INTERFACE
            DIN           : in  std_logic_vector(7 downto 0); -- input r_UART_data to be transmitted over UART
            DIN_VLD       : in  std_logic; -- when r_din_vld = 1, input r_UART_data (DIN) are valid
            DIN_RDY       : out std_logic; -- when DIN_RDY = 1, transmitter is ready and valid input r_UART_data will be accepted for transmiting
            -- USER r_UART_data RX INTERFACE
            DOUT          : out std_logic_vector(7 downto 0); -- output r_UART_data received via UART
            DOUT_VLD      : out std_logic; -- when DOUT_VLD = 1, output r_UART_data (DOUT) are valid (is assert only for one clock cycle)
            FRAME_ERROR   : out std_logic  -- when FRAME_ERROR = 1, stop bit was in valid (is assert only for one clock cycle)
        );
    end component UART;
    -----------------------------------------------------------------------------------------------------


    -------------------------------------------------------------------------------------------------------
    -----------------------------------RX_Byte_decoder_FSM-------------------------------------------------
    -------------------------------------------------------------------------------------------------------
    component RX_Byte_decoder_FSM
        port(
            i_CLK_12M             : in std_logic;
            i_SYNCED_nRST_12M     : in std_logic;
            ----------------------
            i_RX_valid            : in std_logic;
            i_data                : in std_logic_vector (  7 downto 0);
            ----------------------
            o_wr_data_RX          : out std_logic_vector(767 downto 0);
            o_wr_en_RX            : out std_logic;
        
            o_trig_toggle_12M     : out std_logic;
            ----------------------
            o_HASH_FREQUENCY_TRIG : out std_logic;
            o_HASH_FREQUENCY_CMD  : out std_logic_vector(  7 downto 0);
            ----------------------
            o_info_ROM_trig       : out std_logic
        );
    end component RX_Byte_decoder_FSM;
    -----------------------------------------------------------------------------------------------------

   
    -------------------------------------------------------------------------------------------------------
    -----------------------------------TX_Byte_decoder_FSM-------------------------------------------------
    -------------------------------------------------------------------------------------------------------
    component TX_Byte_decoder_FSM
        port(
            i_CLK_12M             : in  std_logic ;
            i_SYNCED_nRST_12M     : in  std_logic ;
            ----------------------
            o_byte_trig_TX        : out std_logic ;
            o_byte_data_TX        : out std_logic_vector(  7 downto 0);
            i_din_vld             : in  std_logic ;
            ----------------------
            i_rd_data_TX          : in  std_logic_vector(319 downto 0);
            o_rd_en_TX            : out std_logic ;
            o_rd_addr_TX          : out std_logic_vector(  0 downto 0);

      
            i_trig_toggle_12M_TX  : in  std_logic ;

            i_info_ROM_trig       : in  std_logic ;

            i_status_bus          : in  std_logic_vector(38 downto 0)
            --i_trig_toggle_12M_TX_ZZ      : in std_logic;
            --i_trig_toggle_12M_TX_ZZZ     : in std_logic
            ----------------------
        );
    end component TX_Byte_decoder_FSM;
    -----------------------------------------------------------------------------------------------------
    
     
    ---------------------------------------------------------
    ----------------------Clock Module-----------------------
    ---------------------------------------------------------
    component CLOCK_MODULE is
        Port ( 
            i_nreset             : in  STD_LOGIC;
            i_CLK_100M           : in  STD_LOGIC;

            i_shutdown_hash_CMD  : in  STD_LOGIC;

            i_HASH_FREQUENCY_TRIG: in  STD_LOGIC;
            i_HASH_FREQUENCY_CMD : in  STD_LOGIC_VECTOR( 7 downto 0);

            o_CLK_status         : out STD_LOGIC_VECTOR(31 downto 0);

            o_CLK_12M            : out STD_LOGIC;
            o_CLK_HASH           : out STD_LOGIC;

            o_CLK_FSM_BUSY       : out STD_LOGIC;
              
            o_locked_CLKSYS_100M : out STD_LOGIC;
            o_locked_CLK_12M     : out STD_LOGIC;
            o_locked_CLK_HASH_0  : out STD_LOGIC;
            o_locked_CLK_HASH_1  : out STD_LOGIC

        );
    end component CLOCK_MODULE;
    ----------------------------------------------------------


    ------------------------------------------Reset Module---------------------------------------------------
    component RST_SYNC is
        Port (
            i_CLK_12M                 : in  std_logic;
            i_CLK_500M                : in  std_logic;
            
            i_ASYNC_nRST              : in  std_logic; --unsync

            i_locked_CLKSYS_100M      : in  std_logic; --unsync
            i_locked_CLK_12M          : in  std_logic; --unsync
            i_locked_CLK_HASH_0       : in  std_logic; --sync 12MHz
            i_locked_CLK_HASH_1       : in  std_logic; --sync 12MHz

            i_FSM_Busy                : in  std_logic; --sync 12MHz

            i_timeout_UART_trig       : in   STD_LOGIC;
            i_alarm_vector            : in   STD_LOGIC_VECTOR (7 downto 0);
            o_shutdown_hash_CMD       : out  STD_LOGIC;

            o_SYNCED_nRST_12M         : out std_logic; --sync 12MHz
            o_SYNCED_nRST_CLK_FSM_12M : out std_logic; --sync 12MHz

            o_SYNCED_nRST_500M        : out std_logic  --sync 12MHz
        );
    end component RST_SYNC;
    ----------------------------------------------//---------------------------------------------------------


    ----------------------------------UART_WATCHDOG_MODULE---------------------------------------------------
    component UART_WATCHDOG_MODULE is
        Port (
            --CLOCK and nRESET
            i_CLK_12M           : in  std_logic; -- Sysclk 12 MHz.
            i_SYNCED_nRST_12M   : in  std_logic; -- sync nRST signal.
           
            -- UART new message received toggle signal.
            i_trig_toggle_12M   : in  std_logic;
           
            --output timeout signal. will trigger an FPGA clock shutdown.
            o_timeout_UART_trig : out std_Logic
        );
        
    end component UART_WATCHDOG_MODULE;
    -------------------------------------------------------------------------------------------------------




    ------------------------------------------DP Async RAM---------------------------------------------------
    component mem_rx is
        Port ( 
            clka : in STD_LOGIC;
            ena  : in STD_LOGIC;
            wea  : in STD_LOGIC_VECTOR ( 0 to 0 );
            addra: in STD_LOGIC_VECTOR ( 0 to 0 );
            dina : in STD_LOGIC_VECTOR ( 767 downto 0 );
            clkb : in STD_LOGIC;
            enb  : in STD_LOGIC;
            addrb: in STD_LOGIC_VECTOR  ( 0 to 0 );
            doutb: out STD_LOGIC_VECTOR ( 767 downto 0 )
        );
    end component mem_rx;

    component mem_tx is
        Port ( 
            clka  : in STD_LOGIC;
            ena   : in STD_LOGIC;
            wea   : in STD_LOGIC_VECTOR ( 0 to 0 );
            addra : in STD_LOGIC_VECTOR ( 0 to 0 );
            dina  : in STD_LOGIC_VECTOR ( 319 downto 0 );
            clkb  : in STD_LOGIC;
            enb   : in STD_LOGIC;
            addrb : in STD_LOGIC_VECTOR ( 0 to 0 );
            doutb : out STD_LOGIC_VECTOR( 319 downto 0 )
        );
    end component mem_tx;
    ------------------------------------------------//-------------------------------------------------------

    
    ------------------------------------------HASH FSM MODULE---------------------------------------------------
    component HASH_FSM_MODULE is
        Port (
            i_CLK_12M              : in  std_logic;      
            i_SYNCED_nRST_12M      : in  std_logic;  
            i_SYNCED_nRST_500M     : in std_logic ;
              
            o_rd_en_RX             : out std_logic;
            i_rd_data_RX           : in  std_logic_vector(767 downto 0);
            i_trig_toggle_RX       : in  std_logic;  
      
            o_wr_en_TX             : out std_logic;
            o_wr_data_TX           : out std_logic_vector(319 downto 0);
            o_trig_toggle_TX       : out std_logic;

            o_header_in_chunk      : out std_logic_vector ( (BLOCK_HEADER_CHUNK_WIDTH-1) downto 0);
            o_header_wr_en         : out std_logic;
            o_HASH_gating          : out std_logic;
            
            i_valid_out            : in std_logic ;
            i_GoldenTicket_core    : in bit_bus_type;
            i_GoldenNonce_core     : in header64_bus_type

        );
    end component HASH_FSM_MODULE;
    ------------------------------------------------//-------------------------------------------------------


    -- ----------------------------------SHA3-Solidity Module---------------------------------------------------
    component SHA3_Solidity_core
        generic(
             CORE_ID            : integer := 0      
        ); 
        port(
            i_SYNCED_nRST_12M   : in std_logic ;                      -- Reset signal (active high).
            i_SYNCED_nRST_500M  : in std_logic ;                      -- Reset signal (active high).
            i_CLK_12M           : in std_logic ;                      -- clock signal
            i_CLK_500M          : in std_logic ;                      -- clock signal
            ---------------------
            i_header_wr_en      : in std_logic ;                      -- enable signal(active high).
            i_gate              : in std_logic ;                      -- gating signal to halt hashing (active high).
            i_header_in_chunk   : in std_logic_vector( (BLOCK_HEADER_CHUNK_WIDTH-1) downto 0) ; -- heading in.
            ----------------------
            o_valid             : out std_logic;                     -- valid signal(active high).
            o_Golden_Ticket     : out std_logic;
            o_Golden_Nonce      : out std_logic_vector(63 downto 0) ;-- golden nonce out.
            ----------------------
            ----------------------
            DEBUG_port_in       : in  std_logic_vector(31 downto 0) ; --
            DEBUG_port_out      : out std_logic_vector(31 downto 0)   -- DEBUG port
        );
    end component SHA3_Solidity_core;
    -----------------------------------------------//---------------------------------------------------------


-------------------------------------------------------------------------------------------------------
------------------------------------------TOP ENTITY---------------------------------------------------
-------------------------------------------------------------------------------------------------------
    component PIPELINE_TOP_MODULE is
        Port (
            -- Hashing Clock.
            i_CLK                     : in   std_logic; 

            -- header/enable forward Pipeline
            i_HASH_en                 : in   std_logic;
            o_HASH_en_delay           : out  bit_bus_type ;

            i_header_chunck           : in   std_logic_vector ( (BLOCK_HEADER_CHUNK_WIDTH-1) downto 0);
            o_header_chunck_delay     : out  header64_bus_type;

            -- valid/Gticket backward Pipeline
            i_valid_out               : in   bit_bus_type;
            o_valid_out_delay         : out  std_logic;

            i_GoldenTicket_core       : in   bit_bus_type;
            o_GoldenTicket_core_delay : out  bit_bus_type;

            i_GoldenNonce_core        : in    header64_bus_type;
            o_GoldenNonce_core_delay  : out   header64_bus_type
        );
    end component PIPELINE_TOP_MODULE;
-------------------------------------------------------------------------------------------------------





    ----------------------------------Xilinx SysMon module (SLR1 ,2 ,4)---------------------------------------
    component system_management_wiz_0
       port
       (
        sysmon_slave_sel       : in    std_logic_vector (1 downto 0);  
        daddr_in               : in    STD_LOGIC_VECTOR (7 downto 0);     -- Address bus for the dynamic reconfiguration port
        den_in                 : in    STD_LOGIC;                         -- Enable Signal for the dynamic reconfiguration port
        di_in                  : in    STD_LOGIC_VECTOR (15 downto 0);    -- Input data bus for the dynamic reconfiguration port
        dwe_in                 : in    STD_LOGIC;                         -- Write Enable for the dynamic reconfiguration port
        do_out                 : out   STD_LOGIC_VECTOR (15 downto 0);    -- Output data bus for dynamic reconfiguration port
        drdy_out               : out   STD_LOGIC;                         -- Data ready signal for the dynamic reconfiguration port
        dclk_in                : in    STD_LOGIC;                         -- Clock input for the dynamic reconfiguration port
        reset_in               : in    STD_LOGIC;                         -- Reset signal for the System Monitor control logic
        --vp                     : in    STD_LOGIC;
        --vn                     : in    STD_LOGIC;
        busy_out               : out   STD_LOGIC;                        -- ADC Busy signal
        channel_out            : out   STD_LOGIC_VECTOR (5 downto 0);    -- Channel Selection Outputs
        eoc_out                : out   STD_LOGIC;                        -- End of Conversion Signal
        eos_out                : out   STD_LOGIC;                        -- End of Sequence Signal
        ot_out                 : out   STD_LOGIC;                        -- Over-Temperature alarm output
        user_supply0_alarm_out : out   STD_LOGIC;
        vccaux_alarm_out       : out   STD_LOGIC;                        -- VCCAUX-sensor alarm output
        vccint_alarm_out       : out   STD_LOGIC;                        -- VCCINT-sensor alarm output
        vbram_alarm_out        : out   STD_LOGIC;                        -- VCCINT-sensor alarm output
        i2c_sclk               : inout STD_LOGIC;         
        i2c_sda                : inout STD_LOGIC;         
        alarm_out              : out   STD_LOGIC
    );
    end component system_management_wiz_0;
    -----------------------------------------------//---------------------------------------------------------

    attribute ASYNC_REG : string;

    signal r_RST                       : std_logic ;
    signal r_SYNCED_RST_12M            : std_logic ;
      
    --UART Signals  
    signal r_RX_valid                  : std_logic ;
    signal r_din_vld                   : std_logic ;
  
    --PLL Signals  
    signal r_clk_12M                   : STD_LOGIC ;
    signal r_clk_500M                  : STD_LOGIC ;
    signal r_locked_CLKSYS_100M        : STD_LOGIC ;
    signal r_locked_CLK_12M            : STD_LOGIC ;
    signal r_locked_CLK_HASH_0         : STD_LOGIC ;
    signal r_locked_CLK_HASH_1         : STD_LOGIC ;
    signal r_CLK_FSM_BUSY              : STD_LOGIC ;
      
    signal r_alarm_vector              : STD_LOGIC_VECTOR (5 downto 0);
    signal r_shutdown_hash_CMD         : STD_LOGIC ;
    signal r_timeout_UART_trig         : STD_LOGIC ;
  
    signal r_SYNCED_nRST_12M           : STD_LOGIC ;
    signal r_SYNCED_nRST_CLK_FSM_12M   : STD_LOGIC ;
    signal r_SYNCED_nRST_500M          : STD_LOGIC ;

    signal r_SYNCED_nRST_500M_SYNC_12M : STD_LOGIC ; 
    signal r_SYNCED_nRST_500M_SYNC_12MZ: STD_LOGIC ; 

    signal r_CLK_status                : STD_LOGIC_vector( 31 downto 0) ;
  
    --RX FSM signals  
    signal r_data                      : std_logic_vector(  7 downto 0);
    ---------------------        
    signal r_wr_data_RX                : std_logic_vector(767 downto 0);
    signal r_wr_en_RX                  : std_logic;
      
    signal r_HASH_FREQUENCY_TRIG       : std_logic;
    signal r_HASH_FREQUENCY_CMD        : std_logic_vector(  7 downto 0);
  
    signal r_info_ROM_trig             : std_logic;
    --      
    signal r_rd_en_RX                  : std_logic;
    signal r_rd_data_RX                : std_logic_vector(767 downto 0);

    --TX FSM signals
    signal r_rd_en_TX                  : std_logic;
    signal r_rd_addr_TX                : std_logic_vector (  0 downto 0);
    signal r_byte_data_TX              : std_logic_vector (  7 downto 0);
    signal r_byte_trig_TX              : std_logic;
    signal r_rd_data_TX                : std_logic_vector (319 downto 0);
    --      
    signal r_wr_en_TX                  : std_logic;
    signal r_wr_data_TX                : std_logic_vector (319 downto 0);
   
    --Hashing control FSM signals   
    signal r_header_in_chunk        : std_logic_vector ( (BLOCK_HEADER_CHUNK_WIDTH-1) downto 0);
         
    signal r_header_wr_en_delay           : bit_bus_type ;
    signal r_header_wr_en                   : std_logic ;
    
    
    signal   r_header_in_chunk_delay : header64_bus_type;


    signal r_valid_out              : std_logic;

    signal r_valid_out_temp         : bit_bus_type;

    signal r_GoldenTicket_core      : bit_bus_type;
    signal r_GoldenTicket_core_temp : bit_bus_type;

    signal r_GoldenNonce_core_temp  : header64_bus_type;
    signal r_GoldenNonce_core       : header64_bus_type;



    --RX/TX toggle pipeline signals
    signal r_trig_toggle_12M        : std_logic;
    signal r_trig_toggle_12M_Z      : std_logic;
    signal r_trig_toggle_12M_ZZ     : std_logic; 
    --
    signal r_trig_toggle_12M_TX     : std_logic;
    signal r_trig_toggle_12M_TX_Z   : std_logic;
    signal r_trig_toggle_12M_TX_ZZ  : std_logic;

    begin
        ---------------------------------------------------------
        -----------------------UART Module-----------------------
        ---------------------------------------------------------
        u_uart: UART
        generic map (
            CLK_FREQ      =>  12e6  , -- system clock frequency in Hz. input 12MHz from PLL.
            BAUD_RATE     =>  115200, -- baud rate value
            PARITY_BIT    =>  "none", -- type of parity: "none", "even", "odd", "mark", "space"
            USE_DEBOUNCER =>  True
        )
        port map (
            CLK           => r_clk_12M       ,
            RST           => r_SYNCED_RST_12M,
            -- UART INTERFACE
            UART_TXD      => o_UART_TXD      ,
            UART_RXD      => i_UART_RXD      ,
            -- USER r_UART_data RX INTERFACE
            DOUT          => r_data          ,     ------------
            DOUT_VLD      => r_RX_valid      ,     ---------------------
            FRAME_ERROR   => open,                           --       --
            -- USER r_UART_data TX INTERFACE                 --       --
            DIN           => r_byte_data_TX  ,     ------------       --
            DIN_VLD       => r_byte_trig_TX  ,     ---------------------   can loop-back byte if want to test UART.
            DIN_RDY       => r_din_vld
        );

        r_SYNCED_RST_12M <= not r_SYNCED_nRST_12M;
        r_RST            <= not (i_RST_N);
        ----------


        ---------------------------------------------------------
        ----------------------Clock Module-----------------------
        ---------------------------------------------------------
        uut_CLOCK_MODULE: CLOCK_MODULE port map(
            i_nreset              => r_SYNCED_nRST_CLK_FSM_12M,
            i_CLK_100M            => i_CLK_100M,
            i_shutdown_hash_CMD   => r_shutdown_hash_CMD,
            i_HASH_FREQUENCY_TRIG => r_HASH_FREQUENCY_TRIG,  
            i_HASH_FREQUENCY_CMD  => r_HASH_FREQUENCY_CMD,
            o_CLK_status          => r_CLK_status,        
            o_CLK_12M             => r_clk_12M,
            o_CLK_HASH            => r_clk_500M,
            o_CLK_FSM_BUSY        => r_CLK_FSM_BUSY,
                
            o_locked_CLKSYS_100M  => r_locked_CLKSYS_100M,
            o_locked_CLK_12M      => r_locked_CLK_12M,
            o_locked_CLK_HASH_0   => r_locked_CLK_HASH_0,
            o_locked_CLK_HASH_1   => r_locked_CLK_HASH_1
        );
        --------------------------------------------------------


        ------------------------------------------------------------
        u_rst_sync: RST_SYNC
        port map(
            i_CLK_12M                  => r_clk_12M                 ,
            i_CLK_500M                 => r_clk_500M                ,
  
            i_ASYNC_nRST               => i_RST_N                   ,
  
            i_locked_CLKSYS_100M       => r_locked_CLKSYS_100M      ,
            i_locked_CLK_12M           => r_locked_CLK_12M          ,
            i_locked_CLK_HASH_0        => r_locked_CLK_HASH_0       ,
            i_locked_CLK_HASH_1        => r_locked_CLK_HASH_1       ,
  
            i_FSM_Busy                 => r_CLK_FSM_BUSY            ,
  
            i_timeout_UART_trig        => r_timeout_UART_trig       ,
            i_alarm_vector(7 downto 6) => (others => '0')           ,--undefined yet
            i_alarm_vector(5 downto 0) => (others => '0')           ,--r_alarm_vector(5 downto 0), --ignore alarm at the moment
            o_shutdown_hash_CMD        => r_shutdown_hash_CMD       ,
                 
            o_SYNCED_nRST_12M          => r_SYNCED_nRST_12M         ,
            o_SYNCED_nRST_CLK_FSM_12M  => r_SYNCED_nRST_CLK_FSM_12M ,
            o_SYNCED_nRST_500M         => r_SYNCED_nRST_500M
        );
        ------------------------------------------------------------


        ----------------------------------UART_WATCHDOG_MODULE--------------------------------------------------
        u_UART_WATCHDOG_MODULE: UART_WATCHDOG_MODULE
            Port map(
                --CLOCK and nRESET
                i_CLK_12M           => r_clk_12M, -- Sysclk 12 MHz.
                i_SYNCED_nRST_12M   => r_SYNCED_nRST_12M, -- sync nRST signal.
               
                -- UART new message received toggle signal.
                i_trig_toggle_12M   => r_trig_toggle_12M,
               
                --output timeout signal. will trigger an FPGA clock shutdown.
                o_timeout_UART_trig => r_timeout_UART_trig
            );
        -------------------------------------------------------------------------------------------------------



        -----------------------------------
        u_mem_rx: mem_rx
        Port map( 
            clka    =>  r_clk_12M    ,--: in STD_LOGIC;
            ena     =>  r_wr_en_RX   ,--: in STD_LOGIC;
            wea(0)  =>  r_wr_en_RX   ,--: in STD_LOGIC_VECTOR ( 0 downto 0 );
            addra   =>  (others=>'0'),--: in STD_LOGIC_VECTOR ( 0 to 0 );
            dina    =>  r_wr_data_RX ,--: in STD_LOGIC_VECTOR ( 767 downto 0 );
            clkb    =>  r_clk_12M   ,--: in STD_LOGIC;
            enb     =>  r_rd_en_RX   ,--: in STD_LOGIC;
            addrb   =>  (others=>'0'),--: in STD_LOGIC_VECTOR ( 0 to 0 );
            doutb   =>  r_rd_data_RX    --: out STD_LOGIC_VECTOR ( 767 downto 0 )
        );

        u_mem_tx: mem_tx
        Port map( 
            clka    =>  r_clk_12M    ,--: in STD_LOGIC;
            ena     =>  r_wr_en_TX   ,--: in STD_LOGIC;
            wea(0)  =>  r_wr_en_TX   ,--: in STD_LOGIC_VECTOR ( 0 downto 0 );
            addra   =>  (others=>'0'),--: in STD_LOGIC_VECTOR ( 0 to 0 );
            dina    =>  r_wr_data_TX ,--: in STD_LOGIC_VECTOR ( 319 downto 0 );
            clkb    =>  r_clk_12M    ,--: in STD_LOGIC;
            enb     =>  r_rd_en_TX   ,--: in STD_LOGIC;
            addrb   =>  r_rd_addr_TX ,--: in STD_LOGIC_VECTOR ( 0 to 0 );
            doutb   =>  r_rd_data_TX  --: out STD_LOGIC_VECTOR ( 319 downto 0 )
        );


    ---------------------------DEBUG PORT---------------------------------
    process(r_clk_12M)
    begin
        if (r_clk_12M'event and r_clk_12M='1')then
                o_DEBUG_PORT(7)              <= r_header_wr_en                   ;
                o_DEBUG_PORT(6)              <= i_UART_RXD                  ;
                o_DEBUG_PORT(5)              <= r_SYNCED_nRST_12M           ;
                
                r_SYNCED_nRST_500M_SYNC_12M  <= r_SYNCED_nRST_500M          ;--
                r_SYNCED_nRST_500M_SYNC_12MZ <= r_SYNCED_nRST_500M_SYNC_12M ;--some pipeline
                o_DEBUG_PORT(4)              <= r_SYNCED_nRST_500M_SYNC_12MZ;
                
                if(r_timeout_UART_trig = '1') then 
                    o_DEBUG_PORT(3) <= '1'  ;--latch timeout watchdog LED
                elsif (i_UART_RXD= '0') then    
                    o_DEBUG_PORT(3) <= '0'  ;--clear timeout watchdog LED
                end if;
                
                o_DEBUG_PORT(2) <= r_CLK_status( 19) AND r_CLK_status(17)  ;--MMCM2_1 AND MMCM2_0 locked
                o_DEBUG_PORT(1) <= r_CLK_status(  3)  ;--MMCM1 locked
                o_DEBUG_PORT(0) <= r_alarm_vector(0) or
                                   r_alarm_vector(1) or
                                   r_alarm_vector(2) or
                                   r_alarm_vector(3) or
                                   r_alarm_vector(4) or
                                   r_alarm_vector(5)  ;
        end if;
    end process;  
    -----------------------------------------------------------------------  


    --Receive message FSM and write memory
    u_RX_Byte_decoder_FSM: RX_Byte_decoder_FSM
        port map(
            i_CLK_12M                => r_clk_12M             ,
            i_SYNCED_nRST_12M        => r_SYNCED_nRST_12M     ,
            ------------------------  ---------------------   
            i_RX_valid               => r_RX_valid            ,
            i_data                   => r_data                ,
            ------------------------  ---------------------    
            o_wr_data_RX             => r_wr_data_RX          ,
            o_wr_en_RX               => r_wr_en_RX            ,
            ------------------------  ---------------------
            o_trig_toggle_12M        => r_trig_toggle_12M     ,
            ------------------------  ---------------------    
            o_HASH_FREQUENCY_TRIG    => r_HASH_FREQUENCY_TRIG ,
            o_HASH_FREQUENCY_CMD     => r_HASH_FREQUENCY_CMD  ,
            o_info_ROM_trig          => r_info_ROM_trig
    );

    --read memory and Transmit message FSM
    u_TX_Byte_decoder_FSM: TX_Byte_decoder_FSM
        port map(
            i_CLK_12M                => r_clk_12M              ,
            i_SYNCED_nRST_12M        => r_SYNCED_nRST_12M      ,
            ------------------------  ---------------------  
            o_byte_trig_TX           => r_byte_trig_TX         ,
            o_byte_data_TX           => r_byte_data_TX         ,
            i_din_vld                => r_din_vld              ,
            ------------------------  ---------------------  
            i_rd_data_TX             => r_rd_data_TX           ,
            o_rd_en_TX               => r_rd_en_TX             ,
            o_rd_addr_TX             => r_rd_addr_TX           ,
            ------------------------  ---------------------                                               
            i_trig_toggle_12M_TX     => r_trig_toggle_12M_TX_ZZ,
            ------------------------  --------------------- 
            i_info_ROM_trig          => r_info_ROM_trig        ,
            ------------------------  --------------------- 
            i_status_bus(38 downto 7)=> r_CLK_status           ,
            i_status_bus(6  downto 2)=> r_alarm_vector(4 downto 0) ,
            i_status_bus(1)          => r_header_wr_en             ,
            i_status_bus(0)          => r_SYNCED_nRST_500M_SYNC_12MZ 
        );

    --TX/RX toggle pipeline.---------------------------
    process(r_clk_12M) 
    begin
        if (r_clk_12M'event and r_clk_12M='1') then
            if(r_SYNCED_nRST_12M='0') then
                r_trig_toggle_12M_Z     <='0' ;
                r_trig_toggle_12M_ZZ    <='0' ;
                --
                r_trig_toggle_12M_TX_Z  <= '0';
                r_trig_toggle_12M_TX_ZZ <= '0';
            else
                --delay toggle(RX) to let the Memory reading port to be valid.
                r_trig_toggle_12M_Z     <= r_trig_toggle_12M       ;
                r_trig_toggle_12M_ZZ    <= r_trig_toggle_12M_Z     ;
                
                --delay toggle(TX) to let the Memory reading port to be valid.  
                r_trig_toggle_12M_TX_Z  <= r_trig_toggle_12M_TX    ;  
                r_trig_toggle_12M_TX_ZZ <= r_trig_toggle_12M_TX_Z  ; 
            end if;    
        end if;
    end process;
    

    ------------------------------------------HASH FSM MODULE---------------------------------------------------
    u_HASH_FSM_MODULE: HASH_FSM_MODULE
    Port map(
        i_CLK_12M             => r_clk_12M            ,--: in  std_logic;      
        i_SYNCED_nRST_12M     => r_SYNCED_nRST_12M    ,--: in std_logic;  
        i_SYNCED_nRST_500M    => r_SYNCED_nRST_500M   ,--for sim only.

        o_rd_en_RX            => r_rd_en_RX           ,--: out std_logic;
        i_rd_data_RX          => r_rd_data_RX         ,--: in  std_logic_vector(767 downto 0);
        i_trig_toggle_RX      => r_trig_toggle_12M_ZZ ,--: in  std_logic;  
                                                      
        o_wr_en_TX            => r_wr_en_TX           ,--: out std_logic;
        o_wr_data_TX          => r_wr_data_TX         ,--: out std_logic_vector(319 downto 0);
        o_trig_toggle_TX      => r_trig_toggle_12M_TX ,--: out std_logic;
                                                      
        o_header_in_chunk     => r_header_in_chunk    ,--: out std_logic_vector ( (BLOCK_HEADER_CHUNK_WIDTH-1) downto 0);
        o_header_wr_en        => r_header_wr_en       ,--: out std_logic ;
        o_HASH_gating         => open                 ,--: out std_logic ;
                                                      
                                                      
        i_valid_out           => r_valid_out          ,--: in std_logic;
        i_GoldenTicket_core   => r_GoldenTicket_core  ,--: in bit_bus_type
        i_GoldenNonce_core    => r_GoldenNonce_core

    );
    ------------------------------------------------//-------------------------------------------------------


    
    GEN_SOLIDITY_CORE: for I in 0 to (NB_CORE-1) generate
        SHA3_Solidity_coreX_arch: SHA3_Solidity_core
        generic map(
            CORE_ID             => I
        )
        Port map(
            i_SYNCED_nRST_12M   => r_SYNCED_nRST_12M              ,  -- Reset signal (active low).
            i_SYNCED_nRST_500M  => r_SYNCED_nRST_500M             ,  -- Reset signal (active low).
            i_CLK_12M           => r_clk_12M                      ,  -- clock signal
            i_CLK_500M          => r_clk_500M                     ,  -- clock signal
            --------------------
            i_header_wr_en      =>  r_header_wr_en_delay(I)       ,  -- enable signal(active high).
            i_gate              =>  '0'                           ,  -- gating signal to halt hashing (active high).
            i_header_in_chunk   =>  r_header_in_chunk_delay(I)          ,  -- heading in.
            ---------------------
            o_valid             =>  r_valid_out_temp(I)           ,  -- valid signal(active high).
            o_Golden_Ticket     =>  r_GoldenTicket_core_temp(I)   ,
            o_Golden_Nonce      =>  r_GoldenNonce_core_temp(I)    ,-- golden nonce out.
            ---------------------
            ---------------------
            DEBUG_port_in       => (others => '0')                ,  --
            DEBUG_port_out      => open                              -- DEBUG port. Not in use at the moment.
        );
    end generate GEN_SOLIDITY_CORE;


    -----------------------------------------Pipeline top module (Forward and backward)---------------------------------
    u_PIPELINE_TOP_MODULE: PIPELINE_TOP_MODULE 
        port map ( 
            -- Hashing Clock.
            i_CLK                    => r_clk_12M , 

            -- header/enable forward Pipeline
            i_HASH_en                 => r_header_wr_en,
            o_HASH_en_delay           => r_header_wr_en_delay,

            i_header_chunck           => r_header_in_chunk,
            o_header_chunck_delay     => r_header_in_chunk_delay,

            -- valid/Gticket backward Pipeline
            i_valid_out               => r_valid_out_temp,
            o_valid_out_delay         => r_valid_out,

            i_GoldenTicket_core       => r_GoldenTicket_core_temp,
            o_GoldenTicket_core_delay => r_GoldenTicket_core,

            i_GoldenNonce_core        => r_GoldenNonce_core_temp,
            o_GoldenNonce_core_delay  => r_GoldenNonce_core
    );
    -------------------------------------------------------------------------------------------------------------------


    u_system_management_wiz_0: system_management_wiz_0
       port map(
        sysmon_slave_sel       => "00"              , 
        daddr_in               => (others => '0')   , -- Address bus for the dynamic reconfiguration port
        den_in                 => '0'               , -- Enable Signal for the dynamic reconfiguration port
        di_in                  => (others => '0')   , -- Input data bus for the dynamic reconfiguration port
        dwe_in                 => '0'               , -- Write Enable for the dynamic reconfiguration port
        do_out                 => OPEN              , -- Output data bus for dynamic reconfiguration port
        drdy_out               => OPEN              , -- Data ready signal for the dynamic reconfiguration port
        dclk_in                => r_clk_12M         , -- Clock input for the dynamic reconfiguration port
        reset_in               => r_SYNCED_RST_12M  , -- Reset signal for the System Monitor control logic
        --vp                     => '0'               ,
        --vn                     => '0'               ,
        busy_out               => OPEN              , -- ADC Busy signal
        channel_out            => OPEN              , -- Channel Selection Outputs
        eoc_out                => OPEN              , -- End of Conversion Signal
        eos_out                => OPEN              , -- End of Sequence Signal
        ot_out                 => r_alarm_vector(0) , -- Over-Temperature alarm output
        user_supply0_alarm_out => r_alarm_vector(1) ,
        vccaux_alarm_out       => r_alarm_vector(2) , -- VCCAUX-sensor alarm output
        vccint_alarm_out       => r_alarm_vector(3) , -- VCCINT-sensor alarm output
        vbram_alarm_out        => r_alarm_vector(4) ,
        i2c_sclk               => io_i2c_sclk       ,
        i2c_sda                => io_i2c_sda        ,
        alarm_out              => r_alarm_vector(5) 
    );


end architecture;