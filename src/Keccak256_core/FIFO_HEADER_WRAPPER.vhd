--------------------------------------------------------------------------------
-- PROJECT: ALTO FPGA Miner. SHA3-Solidity Flavor on Virtex ULTRAScale XCVU9P
--------------------------------------------------------------------------------
-- AUTHORS: Olivier FAURIE <olivier.faurie.hk@gmail.com>
-- LICENSE: 
-- WEBSITE: https://github.com/olivierHK
--------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use IEEE.MATH_REAL.ALL;

Library UNISIM;
use UNISIM.vcomponents.all;

library work;
use work.MyPackage.all;


entity FIFO_HEADER_WRAPPER is
    port (
    	i_nrst_rd     : in  std_logic;                     --Low speed rd clock reset sync
    	i_nrst_wr     : in  std_logic;                     --High speed rd clock reset sync
    	-------------------------------write side-------------------------------
    	i_wr_clk      : in  std_logic;                     --low speed write clock
    	i_wr_en       : in  std_logic;                     --write eneable
    	i_din         : in  std_logic_vector(63 downto 0); --data in

    	o_full        : out std_logic;                     --write side - full flag
    	o_almost_full : out std_logic;                     --write side - almost full flag (full-1)
    	------------------------------------------------------------------------

    	--------------------------------read side-------------------------------
    	i_rd_clk      : in  std_logic;                     --High Speed read clock
        i_rd_en       : in  std_logic;                     --read enable
    	o_dout        : out std_logic_vector(63 downto 0); --dout

    	o_empty       : out std_logic;                     --read side - empty flag
    	o_almost_empty: out std_logic                      --read side - almost empty flag (empty+1)
    	-------------------------------------------------------------------------
    );
end FIFO_HEADER_WRAPPER;





architecture arch of FIFO_HEADER_WRAPPER is
	
	--COMPONENT fifo_generator_0 IS
  	--PORT (
    --	rst          : IN STD_LOGIC;
    --	wr_clk       : IN STD_LOGIC;
    --	rd_clk       : IN STD_LOGIC;
    --	din          : IN STD_LOGIC_VECTOR(63 DOWNTO 0);
    --	wr_en        : IN STD_LOGIC;
    --	rd_en        : IN STD_LOGIC;
    --	dout         : OUT STD_LOGIC_VECTOR(63 DOWNTO 0);
    --	full         : OUT STD_LOGIC;
    --	almost_full  : OUT STD_LOGIC;
    --	empty        : OUT STD_LOGIC;
    --	almost_empty : OUT STD_LOGIC
  	--);
	--END COMPONENT;

	signal r_dout         : std_logic_vector(63 downto 0) ;
	signal r_full         : std_logic                     ;
	signal r_almost_full  : std_logic                     ;
	signal r_empty        : std_logic                     ;
	signal r_almost_empty : std_logic                     ;


	begin

	--u_fifo: fifo_generator_0
  	--	PORT MAP(
	--    	rst          => i_nrst_rd      ,
	--    	wr_clk       => i_wr_clk       ,
	--    	rd_clk       => i_rd_clk       ,
	--    	din          => i_din          ,
	--    	wr_en        => i_wr_en        ,
	--    	rd_en        => i_rd_en        ,
	--    	dout         => r_dout         ,
	--    	full         => r_full         ,
	--    	almost_full  => r_almost_full  ,
	--    	empty        => r_empty        ,
	--    	almost_empty => r_almost_empty 
  	--	);

	o_dout          <= r_dout         ;
	o_full          <= r_full         ;
	o_almost_full   <= r_almost_full  ;
	o_empty         <= r_empty        ;
	o_almost_empty  <= r_almost_empty ;



	FIFO36E2_inst : FIFO36E2
	generic map (
	   CASCADE_ORDER => "NONE",            -- FIRST, LAST, MIDDLE, NONE, PARALLEL
	   CLOCK_DOMAINS => "INDEPENDENT",     -- COMMON, INDEPENDENT
	   EN_ECC_PIPE => "FALSE",             -- ECC pipeline register, (FALSE, TRUE)
	   EN_ECC_READ => "FALSE",             -- Enable ECC decoder, (FALSE, TRUE)
	   EN_ECC_WRITE => "FALSE",            -- Enable ECC encoder, (FALSE, TRUE)
	   FIRST_WORD_FALL_THROUGH => "FALSE", -- FALSE, TRUE
	   INIT => X"000000000000000000",      -- Initial values on output port
	   PROG_EMPTY_THRESH => 2,             -- Programmable Empty Threshold
	   PROG_FULL_THRESH => 256,            -- Programmable Full Threshold
	   -- Programmable Inversion Attributes: Specifies the use of the built-in programmable inversion
	   IS_RDCLK_INVERTED => '0',           -- Optional inversion for RDCLK
	   IS_RDEN_INVERTED => '0',            -- Optional inversion for RDEN
	   IS_RSTREG_INVERTED => '0',          -- Optional inversion for RSTREG
	   IS_RST_INVERTED => '1',             -- Optional inversion for RST
	   IS_WRCLK_INVERTED => '0',           -- Optional inversion for WRCLK
	   IS_WREN_INVERTED => '0',            -- Optional inversion for WREN
	   RDCOUNT_TYPE => "RAW_PNTR",         -- EXTENDED_DATACOUNT, RAW_PNTR, SIMPLE_DATACOUNT, SYNC_PNTR
	   READ_WIDTH => 72,                    -- 18-9
	   REGISTER_MODE => "REGISTERED",    -- DO_PIPELINED, REGISTERED, UNREGISTERED
	   RSTREG_PRIORITY => "RSTREG",        -- REGCE, RSTREG
	   SLEEP_ASYNC => "FALSE",             -- FALSE, TRUE
	   SRVAL => X"000000000000000000",     -- SET/reset value of the FIFO outputs
	   WRCOUNT_TYPE => "RAW_PNTR",         -- EXTENDED_DATACOUNT, RAW_PNTR, SIMPLE_DATACOUNT, SYNC_PNTR
	   WRITE_WIDTH => 72                    -- 18-9
	)
	port map (
	   -- Cascade Signals outputs: Multi-FIFO cascade signals
	   CASDOUT => OPEN,             -- 64-bit output: Data cascade output bus
	   CASDOUTP => OPEN,           -- 8-bit output: Parity data cascade output bus
	   CASNXTEMPTY => OPEN,     -- 1-bit output: Cascade next empty
	   CASPRVRDEN => OPEN,       -- 1-bit output: Cascade previous read enable
	   -- ECC Signals outputs: Error Correction Circuitry ports
	   DBITERR => OPEN,             -- 1-bit output: Double bit error status
	   ECCPARITY => OPEN,         -- 8-bit output: Generated error correction parity
	   SBITERR => OPEN,             -- 1-bit output: Single bit error status
	   -- Read Data outputs: Read output data
	   DOUT => r_dout,                   -- 64-bit output: FIFO data output bus
	   DOUTP => OPEN,                 -- 8-bit output: FIFO parity output bus.
	   -- Status outputs: Flags and other FIFO status outputs
	   EMPTY => r_empty,                 -- 1-bit output: Empty
	   FULL => r_full,                   -- 1-bit output: Full
	   PROGEMPTY => r_almost_empty,         -- 1-bit output: Programmable empty
	   PROGFULL => r_almost_full,           -- 1-bit output: Programmable full
	   RDCOUNT => OPEN,             -- 14-bit output: Read count
	   RDERR => OPEN,                 -- 1-bit output: Read error
	   RDRSTBUSY => OPEN,         -- 1-bit output: Reset busy (sync to RDCLK)
	   WRCOUNT => OPEN,             -- 14-bit output: Write count
	   WRERR => OPEN,                 -- 1-bit output: Write Error
	   WRRSTBUSY => OPEN,         -- 1-bit output: Reset busy (sync to WRCLK)
	   -- Cascade Signals inputs: Multi-FIFO cascade signals
	   CASDIN => (others => '0'),               -- 64-bit input: Data cascade input bus
	   CASDINP => (others => '0'),             -- 8-bit input: Parity data cascade input bus
	   CASDOMUX => '0',           -- 1-bit input: Cascade MUX select input
	   CASDOMUXEN => '1',       -- 1-bit input: Enable for cascade MUX select      --1 as specified in UG573 p.65
	   CASNXTRDEN => '0',       -- 1-bit input: Cascade next read enable
	   CASOREGIMUX => '0',     -- 1-bit input: Cascade output MUX select
	   CASOREGIMUXEN => '1', -- 1-bit input: Cascade output MUX select enable      --1 as specified in UG573 p.65
	   CASPRVEMPTY => '0',     -- 1-bit input: Cascade previous empty
	   -- ECC Signals inputs: Error Correction Circuitry ports
	   INJECTDBITERR => '0', -- 1-bit input: Inject a double-bit error
	   INJECTSBITERR => '0', -- 1-bit input: Inject a single bit error
	   -- Read Control Signals inputs: Read clock, enable and reset input signals
	   RDCLK => i_rd_clk,                 -- 1-bit input: Read clock
	   RDEN => i_rd_en,                   -- 1-bit input: Read enable
	   REGCE => '1',                 -- 1-bit input: Output register clock enable  --1 as specified in UG573 p.65
	   RSTREG => '0',               -- 1-bit input: Output register reset          --0 as specified in UG573 p.65
	   SLEEP => '0',                 -- 1-bit input: Sleep Mode
	   -- Write Control Signals inputs: Write clock and enable input signals
	   RST => i_nrst_wr,                     -- 1-bit input: Reset
	   WRCLK => i_wr_clk,                 -- 1-bit input: Write clock
	   WREN => i_wr_en,                   -- 1-bit input: Write enable
	   -- Write Data inputs: Write input data
	   DIN => i_din,                     -- 64-bit input: FIFO data input bus
	   DINP => (others =>  '0')                    -- 8-bit input: FIFO parity input bus
);









end architecture;