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


package MyPackage is

	constant SIMULATION               : boolean                        := false;--true if simulation. false otherwise.
	constant SIMULATION_XOR5          : boolean                        := false;--true if simulation XOR5. false otherwise.

	constant NB_CORE_MAX              : integer                        := 64;--FIXED. ArbitraryFixed maximum number of core (V13p cannot get more than 64 cores)
	constant NB_CORE_MAX_BIT_LENGTH   : integer                        := 6 ;--FIXED. NB_CORE_MAX bit'lengh to know how many bit the nonce should be shifted. (64 cores, so 0~63. With d'63 = b'111_111, bit'length = 6).
	constant NONCE_MAX                : std_logic_vector(63 downto 0)  := X"FFFFFFFFFFFFFFFF";--FIXED. nonce max is define on 64-bit.
	
	constant NB_CORE                  : integer range 0 to NB_CORE_MAX := 24;--User defined number of core.


	attribute DONT_TOUCH              : string;
	attribute KEEP                    : string;
	attribute shreg_extract           : string;
	
	constant DELAY_FORWARD            : integer                        := 3;--User defined pipeline delay from Hash FSM to Hash core (for full header in)
	constant DELAY_BACKWARD           : integer                        := 3;--User defined pipeline delay from Hash core to Hash FSM(for Hash back)


    
	------------------------VARIABLE type for hte header Shift register----------------------
	constant BLOCK_HEADER_CHUNK_SIZE  : integer        				   := ((671+1)+32)/64;--number of elements to be sent on the Shift Register bus. include padding. Here is 11 elements
	constant BLOCK_HEADER_CHUNK_WIDTH : integer        				   := 64;--Size in bit of the chunk. Fixed to 64, now. as Nonce is 64-bits.

	-----------------------------------------------------------------------------------------


    ---------------------------FIXED TYPE for bus definition---------------------------------
	TYPE header64_bus_type is array (0 to NB_CORE-1) of std_logic_vector( (BLOCK_HEADER_CHUNK_WIDTH-1) downto 0);

	TYPE hash256_bus_type   is array (0 to NB_CORE-1) of std_logic_vector( 255                     downto 0);

	TYPE bit_bus_type       is array (0 to NB_CORE-1) of std_logic;


	--parametrable pipeline types
	TYPE header_bus_delay_type is array (0 to DELAY_FORWARD)  of header64_bus_type;

	TYPE hash_bus_delay_type   is array (0 to DELAY_BACKWARD) of hash256_bus_type;

	TYPE bit_bus_delay_forward_type     is array (0 to DELAY_FORWARD)  of bit_bus_type;
	TYPE bit_bus_delay_backward_type    is array (0 to DELAY_BACKWARD) of bit_bus_type;
	TYPE bit_delay_backward_type        is array (0 to DELAY_BACKWARD) of std_logic_vector(0 downto 0);
	-----------------------------------------------------------------------------------------


	---------MMCME number of memory cell to write (FIXED VALUE). it is 12 for XCVU9P)------
	constant C_ELEMENT_TO_RD : STD_LOGIC_VECTOR(3 downto 0) := X"B";
	---------------------------------------------------------------------------------------


	---------------------Clock FSM Timeout value. to be updated is frequency change, or timeout time to be changed.-------------------   
	constant FSM_CLOCK_FREQ : integer := 12 ;  --Frequency in MHz of the FSM clock. 12MHz as default.
	constant TIMEOUT_TIME   : integer := 1000; --timeout time in micro-second. Default is 1ms (=1,000us).
	--convert and set timer in std_logic_vector. TIMOUT_cnt= FSM_CLOCK_FREQ * TIMEOUT_TIME.
	constant C_TIMEOUT_LOAD : std_logic_vector(19 downto 0) :=  std_logic_vector(to_unsigned((FSM_CLOCK_FREQ * TIMEOUT_TIME), 20));
	----------------------------------------------------------------------------------------------------------------------------------


    ---------------------Clock FSM Cooldown value. to be updated is frequency change, or cooldown time to be changed.-------------   
	--constant FSM_CLOCK_FREQ : integer := 12 ;  --Frequency in MHz of the FSM clock. 12MHz as default.
	constant COOLDOWN_TIME   : integer := 150; --timeout time in micro-second. Default is 150us.
	--convert and set timer in std_logic_vector. TIMOUT_cnt= FSM_CLOCK_FREQ * TIMEOUT_TIME.
	constant C_COOLDOWN_LOAD : std_logic_vector(19 downto 0) :=  std_logic_vector(to_unsigned((FSM_CLOCK_FREQ * COOLDOWN_TIME), 20));
	----------------------------------------------------------------------------------------------------------------------------------


	----------------WATCHDOG TIMEOUT MODULE CONSTANTE VALUE. to be update if timeout time to be change, or Sysclk updated-------------
	--WatchDog Timeout constant. X"562CE65C" is 2 minutes @ 12MHz.
	constant C_WATCHDOG_TIMEOUT_TIME: std_logic_vector(31 downto 0) := X"562CE65C";
	----------------------------------------------------------------------------------------------------------------------------------


end MyPackage;	
