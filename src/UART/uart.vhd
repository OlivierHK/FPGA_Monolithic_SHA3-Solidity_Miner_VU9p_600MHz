--------------------------------------------------------------------------------
-- PROJECT: SIMPLE UART FOR FPGA
--------------------------------------------------------------------------------
-- AUTHORS: Jakub Cabal <jakubcabal@gmail.com>
-- LICENSE: The MIT License (MIT), please read LICENSE file
-- WEBSITE: https://github.com/jakubcabal/uart-for-fpga
--------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use IEEE.MATH_REAL.ALL;

-- SIMPLE UART FOR FPGA
-- ====================
-- UART FOR FPGA REQUIRES: 1 START BIT, 8 DATA BITS, 1 STOP BIT!!!
-- OTHER PARAMETERS CAN BE SET USING GENERICS.

-- DESCRIPTION OF RELEASED VERSIONS:
-- =================================
-- Version 1.0 - released on 27 May 2016
    -- Initial release.
-- Version 1.1 - released on 20 December 2018
    -- Added better debouncer.
    -- Added simulation script and Quartus project file.
    -- Removed unnecessary resets.
    -- Signal BUSY replaced by DIN_RDY.
    -- Many other optimizations and changes.
-- Version 1.2 - released on 23 December 2019
    -- Added double FF for safe CDC.
    -- Fixed fake received transaction after FPGA boot without reset.
    -- Added more precisely clock dividers, dividing with rounding.
    -- UART loopback example is for CYC1000 board now.

entity UART is
    Generic (
        CLK_FREQ      : integer := 50e6;   -- system clock frequency in Hz
        BAUD_RATE     : integer := 115200; -- baud rate value
        PARITY_BIT    : string  := "none"; -- type of parity: "none", "even", "odd", "mark", "space"
        USE_DEBOUNCER : boolean := True    -- enable/disable debouncer
    );
    Port (
        -- CLOCK AND RESET
        CLK         : in  std_logic; -- system clock
        RST         : in  std_logic; -- high active synchronous reset
        -- UART INTERFACE
        UART_TXD    : out std_logic; -- serial transmit data
        UART_RXD    : in  std_logic; -- serial receive data
        -- USER DATA INPUT INTERFACE
        DIN         : in  std_logic_vector(7 downto 0); -- input data to be transmitted over UART
        DIN_VLD     : in  std_logic; -- when DIN_VLD = 1, input data (DIN) are valid
        DIN_RDY     : out std_logic; -- when DIN_RDY = 1, transmitter is ready and valid input data will be accepted for transmiting
        -- USER DATA OUTPUT INTERFACE
        DOUT        : out std_logic_vector(7 downto 0); -- output data received via UART
        DOUT_VLD    : out std_logic; -- when DOUT_VLD = 1, output data (DOUT) are valid (is assert only for one clock cycle)
        FRAME_ERROR : out std_logic  -- when FRAME_ERROR = 1, stop bit was invalid (is assert only for one clock cycle)
    );
end entity;

architecture RTL of UART is

    attribute ASYNC_REG       : string   ;
    constant OS_CLK_DIV_VAL   : integer := integer(real(CLK_FREQ)/real(16*BAUD_RATE));
    constant UART_CLK_DIV_VAL : integer := integer(real(CLK_FREQ)/real(OS_CLK_DIV_VAL*BAUD_RATE));

    signal os_clk_en            : std_logic;
    signal uart_rxd_meta_n      : std_logic;
    attribute ASYNC_REG of uart_rxd_meta_n : signal is "TRUE";
    signal uart_rxd_synced_n    : std_logic;
    signal uart_rxd_debounced_n : std_logic;
    signal uart_rxd_debounced   : std_logic;


component UART_CLK_DIV is
    Generic (
        DIV_MAX_VAL  : integer := 16;
        DIV_MARK_POS : integer := 1
    );
    Port (
        CLK      : in  std_logic; -- system clock
        RST      : in  std_logic; -- high active synchronous reset
        -- USER INTERFACE
        CLEAR    : in  std_logic; -- clock divider counter clear
        ENABLE   : in  std_logic; -- clock divider counter enable
        DIV_MARK : out std_logic  -- output divider mark (divided clock enable)
    );
end component UART_CLK_DIV;

component UART_DEBOUNCER is
    Generic (
        -- latency of debouncer in clock cycles, minimum value is 2,
        -- value also corresponds to the number of bits compared
        LATENCY : natural := 4
    );
    Port (
        CLK     : in  std_logic; -- system clock
        DEB_IN  : in  std_logic; -- input of signal from outside FPGA
        DEB_OUT : out std_logic  -- output of debounced (filtered) signal
    );
end component UART_DEBOUNCER;

component UART_RX is
    Generic (
        CLK_DIV_VAL : integer := 16;
        PARITY_BIT  : string  := "none" -- type of parity: "none", "even", "odd", "mark", "space"
    );
    Port (
        CLK          : in  std_logic; -- system clock
        RST          : in  std_logic; -- high active synchronous reset
        -- UART INTERFACE
        UART_CLK_EN  : in  std_logic; -- oversampling (16x) UART clock enable
        UART_RXD     : in  std_logic; -- serial receive data
        -- USER DATA OUTPUT INTERFACE
        DOUT         : out std_logic_vector(7 downto 0); -- output data received via UART
        DOUT_VLD     : out std_logic; -- when DOUT_VLD = 1, output data (DOUT) are valid without errors (is assert only for one clock cycle)
        FRAME_ERROR  : out std_logic; -- when FRAME_ERROR = 1, stop bit was invalid (is assert only for one clock cycle)
        PARITY_ERROR : out std_logic  -- when PARITY_ERROR = 1, parity bit was invalid (is assert only for one clock cycle)
    );
end component UART_RX;

component UART_TX is
    Generic (
        CLK_DIV_VAL : integer := 16;
        PARITY_BIT  : string  := "none" -- type of parity: "none", "even", "odd", "mark", "space"
    );
    Port (
        CLK         : in  std_logic; -- system clock
        RST         : in  std_logic; -- high active synchronous reset
        -- UART INTERFACE
        UART_CLK_EN : in  std_logic; -- oversampling (16x) UART clock enable
        UART_TXD    : out std_logic; -- serial transmit data
        -- USER DATA INPUT INTERFACE
        DIN         : in  std_logic_vector(7 downto 0); -- input data to be transmitted over UART
        DIN_VLD     : in  std_logic; -- when DIN_VLD = 1, input data (DIN) are valid
        DIN_RDY     : out std_logic  -- when DIN_RDY = 1, transmitter is ready and valid input data will be accepted for transmiting
    );
end component UART_TX;


begin

    -- -------------------------------------------------------------------------
    --  UART OVERSAMPLING (~16X) CLOCK DIVIDER AND CLOCK ENABLE FLAG
    -- -------------------------------------------------------------------------

    os_clk_divider_i : UART_CLK_DIV
    generic map(
        DIV_MAX_VAL  => OS_CLK_DIV_VAL,
        DIV_MARK_POS => OS_CLK_DIV_VAL-1
    )
    port map (
        CLK      => CLK,
        RST      => RST,
        CLEAR    => RST,
        ENABLE   => '1',
        DIV_MARK => os_clk_en
    );

    -- -------------------------------------------------------------------------
    --  UART RXD CROSS DOMAIN CROSSING
    -- -------------------------------------------------------------------------
    
    uart_rxd_cdc_reg_p : process (CLK)
    begin
        if (rising_edge(CLK)) then
            uart_rxd_meta_n   <= not UART_RXD;
            uart_rxd_synced_n <= uart_rxd_meta_n;
        end if;
    end process;

    -- -------------------------------------------------------------------------
    --  UART RXD DEBAUNCER
    -- -------------------------------------------------------------------------

    use_debouncer_g : if (USE_DEBOUNCER = True) generate
        debouncer_i : UART_DEBOUNCER
        generic map(
            LATENCY => 4
        )
        port map (
            CLK     => CLK,
            DEB_IN  => uart_rxd_synced_n,
            DEB_OUT => uart_rxd_debounced_n
        );
    end generate;

    not_use_debouncer_g : if (USE_DEBOUNCER = False) generate
        uart_rxd_debounced_n <= uart_rxd_synced_n;
    end generate;

    uart_rxd_debounced <= not uart_rxd_debounced_n;

    -- -------------------------------------------------------------------------
    --  UART RECEIVER
    -- -------------------------------------------------------------------------

    uart_rx_i: UART_RX
    generic map (
        CLK_DIV_VAL => UART_CLK_DIV_VAL,
        PARITY_BIT  => PARITY_BIT
    )
    port map (
        CLK          => CLK,
        RST          => RST,
        -- UART INTERFACE
        UART_CLK_EN  => os_clk_en,
        UART_RXD     => uart_rxd_debounced,
        -- USER DATA OUTPUT INTERFACE
        DOUT         => DOUT,
        DOUT_VLD     => DOUT_VLD,
        FRAME_ERROR  => FRAME_ERROR,
        PARITY_ERROR => open
    );

    -- -------------------------------------------------------------------------
    --  UART TRANSMITTER
    -- -------------------------------------------------------------------------

    uart_tx_i: UART_TX
    generic map (
        CLK_DIV_VAL => UART_CLK_DIV_VAL,
        PARITY_BIT  => PARITY_BIT
    )
    port map (
        CLK         => CLK,
        RST         => RST,
        -- UART INTERFACE
        UART_CLK_EN => os_clk_en,
        UART_TXD    => UART_TXD,
        -- USER DATA INPUT INTERFACE
        DIN         => DIN,
        DIN_VLD     => DIN_VLD,
        DIN_RDY     => DIN_RDY
    );

end architecture;
