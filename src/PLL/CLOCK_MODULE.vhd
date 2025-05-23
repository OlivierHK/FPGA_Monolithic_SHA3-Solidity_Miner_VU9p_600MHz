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


---------------------------------------------------------
----------------------Clock Module-----------------------
---------------------------------------------------------
entity CLOCK_MODULE is
    Port ( 
        i_nreset             : in  STD_LOGIC;
        i_CLK_100M           : in  STD_LOGIC;

        i_shutdown_hash_CMD  : in  STD_LOGIC;

        i_HASH_FREQUENCY_TRIG: in  STD_LOGIC;
        i_HASH_FREQUENCY_CMD : in  STD_LOGIC_VECTOR( 7 downto 0);

        o_CLK_status         : out STD_LOGIC_VECTOR(31 downto 0);

        o_CLK_12M            : out STD_LOGIC;
        o_CLK_HASH           : out STD_LOGIC;

        o_CLK_FSM_BUSY	     : out STD_LOGIC;
          
        o_locked_CLKSYS_100M : out STD_LOGIC;
        o_locked_CLK_12M     : out STD_LOGIC;
        o_locked_CLK_HASH_0  : out STD_LOGIC;
        o_locked_CLK_HASH_1  : out STD_LOGIC

    );
end entity;
----------------------------------------------------------


---------------------------------------------------------
----------------------Clock Module-----------------------
---------------------------------------------------------
architecture CLOCK_MODULE_arch of CLOCK_MODULE is

	---------------------------------------------------------
	-------------------Clock Hash FSM------------------------
	---------------------------------------------------------	
	component CLOCK_HASH_FSM_MODULE is
	    Port ( 
	        -----------------------System port------------------------
	        i_nreset              : in  STD_LOGIC;

	        i_shutdown_hash_CMD  : in  STD_LOGIC;

	        i_HASH_FREQUENCY_TRIG: in STD_LOGIC;
	        i_HASH_FREQUENCY_CMD : in STD_LOGIC_VECTOR (7 downto 0);

	        i_CLK_12M            : in STD_LOGIC;
	        
	        o_HASH_CLK_status    : out STD_LOGIC_VECTOR (15 downto 0);  

	        o_BUFGMUX_SEL        : out STD_LOGIC;

	        o_CLK_FSM_BUSY       : out STD_LOGIC;
	        -----------------------DRP Port---------------------------
	        i_locked_MMCM2_0     : in STD_LOGIC;
	        i_locked_MMCM2_1     : in STD_LOGIC;

	        o_nreset_MMCMC2_0    : out STD_LOGIC;
	        o_nreset_MMCMC2_1    : out STD_LOGIC;

	        o_DEN_DRP_0          : out STD_LOGIC;
	        o_DEN_DRP_1          : out STD_LOGIC;

	        o_DWE_DRP_0          : out STD_LOGIC;
	        o_DWE_DRP_1          : out STD_LOGIC;

	        o_DADDR_DRP          : out STD_LOGIC_VECTOR(6 DOWNTO 0);
	                       
	        o_DI_DRP             : out STD_LOGIC_VECTOR(15 DOWNTO 0); 

	        i_DO_DRP_0           : in  STD_LOGIC_VECTOR(15 DOWNTO 0);
	        i_DO_DRP_1           : in  STD_LOGIC_VECTOR(15 DOWNTO 0);

	        i_DRDY_DRP_0         : in  STD_LOGIC;
	        i_DRDY_DRP_1         : in  STD_LOGIC
	    );
	end component;
    ------------------------------------------------------------------



	---------------------------------------------------------
	------------------- MMCME Wrapper------------------------
	---------------------------------------------------------
	component MMCME_WRAPPER is
    generic (
      g_BANDWIDTH    : string  := "OPTIMIZED";-- Jitter programming. OPTIMIZED for normal MMCM, LOW for cleaning Jitter.
      g_CLKIN_PERIOD : real    := 10.0; -- period in ns of the input clock. 100MHz (10ps) by default.
      g_CLKOUT_MULT  : real    := 10.0;
      g_DIVCLK_DIVIDE: integer := 1;
      g_CLKOUT0_DIV  : real    := 10.0; -- Fout= Fin*(Mult/Div)
      g_CLKOUT1_DIV  : integer := 10  ; -- Output 100MHz Clock by default.
      g_USE_BUFIN    : boolean := True;
      g_USE_BUFOUT_0 : boolean := True;
      g_USE_BUFOUT_1 : boolean := True;
      g_USE_BUFfb    : boolean := True
    );

   Port ( 
      i_nreset    : in  STD_LOGIC;
      i_clk_in1   : in  STD_LOGIC;   
      o_CLK_out0  : out STD_LOGIC;
      o_CLK_out1  : out STD_LOGIC;   
      o_locked    : out STD_LOGIC;
      --------------------------
      i_DCLK_DRP  : in  STD_LOGIC;
      i_DEN_DRP   : in  STD_LOGIC;
      i_DWE_DRP   : in  STD_LOGIC;
      i_DADDR_DRP : in  STD_LOGIC_VECTOR(6 DOWNTO 0);
            
      i_DI_DRP    : in  STD_LOGIC_VECTOR(15 DOWNTO 0);   
      o_DO_DRP    : out STD_LOGIC_VECTOR(15 DOWNTO 0);
      o_DRDY_DRP  : out STD_LOGIC
    );
	end component;
	---------------------------------------------------------

	--------------------------MMCM0--------------------------
	signal r_CLK_100M        : STD_LOGIC;
	signal r_locked_MMCME0   : STD_LOGIC;
	--signal r_CLKSYS_100M     : STD_LOGIC;
    -------------------------MMCM1---------------------------
	signal r_nreset_MMCMC1   : STD_LOGIC;
  
	signal r_locked_MMCME1   : STD_LOGIC;
	signal r_CLK_12M         : STD_LOGIC;	
	signal r_CLK_120M        : STD_LOGIC;	
    ---------------------------MMCM2_x-----------------------
	signal r_nreset_FSM      : STD_LOGIC;

	signal r_nreset_MMCMC2_0 : STD_LOGIC;
	signal r_nreset_MMCMC2_1 : STD_LOGIC;

	signal r_locked_MMCME2_0 : STD_LOGIC;
	signal r_locked_MMCME2_1 : STD_LOGIC;
	signal r_CLK_HASH_0      : STD_LOGIC;
	signal r_CLK_HASH_1      : STD_LOGIC;
	signal r_BUFGMUX_SEL     : STD_LOGIC;
	------------------------DRP PORT-------------------------

    signal r_DEN_DRP_0       : STD_LOGIC;
    signal r_DEN_DRP_1       : STD_LOGIC;
    signal r_DWE_DRP_0       : STD_LOGIC;
    signal r_DWE_DRP_1       : STD_LOGIC;
    signal r_DADDR_DRP       : STD_LOGIC_VECTOR(6  DOWNTO 0);
    signal r_DI_DRP          : STD_LOGIC_VECTOR(15 DOWNTO 0);
    signal r_DO_DRP_0        : STD_LOGIC_VECTOR(15 DOWNTO 0);
    signal r_DO_DRP_1        : STD_LOGIC_VECTOR(15 DOWNTO 0);
    signal r_DRDY_DRP_0      : STD_LOGIC;
    signal r_DRDY_DRP_1      : STD_LOGIC;
  
    signal r_CLK_FSM_BUSY    : STD_LOGIC;

    signal r_CLK_HASH_MUX    : STD_LOGIC;

    signal r_HASH_CLK_status : STD_LOGIC_VECTOR(15 DOWNTO 0);

begin

	----------------------------------------------------------
	-------------- IBUF: Master Input Buffer------------------
	----------------------------------------------------------
	IBUF_inst : IBUF 										--
	--generic map (											--
	--	CCIO_EN => "TRUE" 									--
	--)														--
	port map (												--
		O       => r_CLK_100M, -- 1-bit output: Buff output --
		I       => i_CLK_100M  -- 1-bit input: Buff input 	--
	);														--
	----------------------------------------------------------
	----------------------------------------------------------
	
	

	----------------------------------------------------------
	--- MMCME0. 100MHz as input, 100MHz as output ------------
	----------------------------------------------------------
	--u_MMCME0_CLKIN_DEJITTERING : MMCME_WRAPPER
	--generic map(
	--	g_BANDWIDTH    => "LOW", -- LOW for cleaning input jitter (UG572 p38)
	--	g_CLKIN_PERIOD => 10.0 , --real.    
 	--	g_CLKOUT_MULT  => 10.0 , --real.  
 	--	g_DIVCLK_DIVIDE=> 1    , --integer  
	--	g_CLKOUT0_DIV  => 10.0 , --real.    
 	--	g_CLKOUT1_DIV  => 10   , --integer. 
	--	g_USE_BUFIN    => False, --boolean.
	--	g_USE_BUFOUT   => True , --boolean. 
	--	g_USE_BUFfb    => False  --boolean.
	--)
	--port map(
	--	------------clock-------------
	--	i_nreset    => '1'            ,
	--	i_clk_in1   => r_CLK_100M     ,
	--	o_CLK_out0  => r_CLKSYS_100M  ,
	--	o_CLK_out1  => OPEN           ,
	--	o_locked    => r_locked_MMCME0,
	--	------------DRP Port----------
	--	i_DCLK_DRP  => '0'            ,
	--	i_DEN_DRP   => '0'            ,
	--	i_DWE_DRP   => '0'            ,
	--	i_DADDR_DRP => (others =>'0') ,
 --
	--	i_DI_DRP    => (others =>'0') ,
	--	o_DO_DRP    => OPEN           ,
	--	o_DRDY_DRP  => OPEN           
--
	--);
	r_locked_MMCME0 <= '1';	
	----------------------------------------------------------
	----------------------------------------------------------

	r_nreset_MMCMC1 <= r_locked_MMCME0;
	----------------------------------------------------------
	--- MMCME1. 100MHz as input, 12MHz as output -------------
	----------------------------------------------------------
	u_MMCME1_CLK_12M : MMCME_WRAPPER
	generic map(
		g_BANDWIDTH    => "LOW" , -- LOW for cleaning input jitter (UG572 p38)- 
		g_CLKIN_PERIOD => 10.0  , --real.    
 		g_CLKOUT_MULT  => 12.0  , --real.  
 		g_DIVCLK_DIVIDE=> 1     , --integer  
		g_CLKOUT0_DIV  => 100.0 , --real.    
 		g_CLKOUT1_DIV  => 10    , --integer. 
		g_USE_BUFIN    => False , --boolean.
      	g_USE_BUFOUT_0 => True  ,
      	g_USE_BUFOUT_1 => True  , 
		g_USE_BUFfb    => False   --boolean. 
	)
	port map(
		------------clock-------------
		i_nreset    => r_nreset_MMCMC1,
		i_clk_in1   => r_CLK_100M     ,
		o_CLK_out0  => r_CLK_12M      ,
		o_CLK_out1  => r_CLK_120M     ,
		o_locked    => r_locked_MMCME1,
		------------DRP Port----------
		i_DCLK_DRP  => '0'            ,
		i_DEN_DRP   => '0'            ,
		i_DWE_DRP   => '0'            ,
		i_DADDR_DRP => (others =>'0') ,
 
		i_DI_DRP    => (others =>'0') ,
		o_DO_DRP    => OPEN           ,
		o_DRDY_DRP  => OPEN    

	);

	r_nreset_FSM <= i_nreset      ;
	o_CLK_12M    <= r_CLK_12M ;
	----------------------------------------------------------
	----------------------------------------------------------


	u_CLOCK_HASH_FSM_MODULE: CLOCK_HASH_FSM_MODULE
	    Port map( 
	        -----------------------System port------------------------
	        i_nreset              => r_nreset_FSM,

	        i_shutdown_hash_CMD  => i_shutdown_hash_CMD,

	        i_HASH_FREQUENCY_TRIG=> i_HASH_FREQUENCY_TRIG,
	        i_HASH_FREQUENCY_CMD => i_HASH_FREQUENCY_CMD,

	        i_CLK_12M            => r_CLK_12M,

	        o_HASH_CLK_status    => r_HASH_CLK_status,

	        o_BUFGMUX_SEL        => r_BUFGMUX_SEL,

	        o_CLK_FSM_BUSY       => r_CLK_FSM_BUSY,          
	        -----------------------DRP Port---------------------------
	        i_locked_MMCM2_0     => r_locked_MMCME2_0,
	        i_locked_MMCM2_1     => r_locked_MMCME2_1,

	        o_nreset_MMCMC2_0     => r_nreset_MMCMC2_0,
	        o_nreset_MMCMC2_1     => r_nreset_MMCMC2_1,

	        o_DEN_DRP_0          => r_DEN_DRP_0,
	        o_DEN_DRP_1          => r_DEN_DRP_1,

	        o_DWE_DRP_0          => r_DWE_DRP_0,
	        o_DWE_DRP_1          => r_DWE_DRP_1,

	        o_DADDR_DRP          => r_DADDR_DRP,
	                       
	        o_DI_DRP             => r_DI_DRP  ,

	        i_DO_DRP_0           => r_DO_DRP_0,
	        i_DO_DRP_1           => r_DO_DRP_1,

	        i_DRDY_DRP_0         => r_DRDY_DRP_0,
	        i_DRDY_DRP_1         => r_DRDY_DRP_1
	    );
	------------------------------------------------------------------



	----------------------------------------------------------
	--- MMCME2_0. 120MHz as input, 100-800MHz as output -------------
	----------------------------------------------------------
	u_MMCME2_0_CLK_HASH : MMCME_WRAPPER
	generic map(
		g_BANDWIDTH    => "HIGH", -- HIGH for lowering output jitter (UG572 p38)
		g_CLKIN_PERIOD => 8.333333 , --real.    
 		g_CLKOUT_MULT  => 60.0 , --real.  
 		g_DIVCLK_DIVIDE=> 6    , --integer  
		g_CLKOUT0_DIV  => 12.0 , --real.    
 		g_CLKOUT1_DIV  => 1    , --integer. 
		g_USE_BUFIN    => False , --boolean.
      	g_USE_BUFOUT_0 => True  ,
      	g_USE_BUFOUT_1 => False  ,
		g_USE_BUFfb    => False  --boolean. 
	)
	port map(
		------------clock-------------
		i_nreset    => r_nreset_MMCMC2_0,
		i_clk_in1   => r_CLK_120M       ,
		o_CLK_out0  => r_CLK_HASH_0     ,
		o_CLK_out1  => OPEN             ,
		o_locked    => r_locked_MMCME2_0,
		------------DRP Port----------
		i_DCLK_DRP  => r_CLK_12M ,
		i_DEN_DRP   => r_DEN_DRP_0   ,
		i_DWE_DRP   => r_DWE_DRP_0   ,
		i_DADDR_DRP => r_DADDR_DRP   ,
 
		i_DI_DRP    => r_DI_DRP      ,
		o_DO_DRP    => r_DO_DRP_0    ,
		o_DRDY_DRP  => r_DRDY_DRP_0 

	);
    --------------------------------------------------------------------------------


	----------------------------------------------------------
	--- MMCME2_1. 120MHz as input, 100-800MHz as output -------------
	----------------------------------------------------------
	u_MMCME2_1_CLK_HASH : MMCME_WRAPPER
	generic map(
		g_BANDWIDTH    => "HIGH", -- HIGH for lowering output jitter (UG572 p38)
		g_CLKIN_PERIOD => 8.333333, --real.    
 		g_CLKOUT_MULT  => 60.0 , --real.  
 		g_DIVCLK_DIVIDE=> 6    , --integer  
		g_CLKOUT0_DIV  => 12.0 , --real.    
 		g_CLKOUT1_DIV  => 1    , --integer. 
		g_USE_BUFIN    => False , --boolean.
      	g_USE_BUFOUT_0 => True  ,
      	g_USE_BUFOUT_1 => False , 
		g_USE_BUFfb    => False  --boolean. 
	)
	port map(
		------------clock-------------
		i_nreset    => r_nreset_MMCMC2_1,
		i_clk_in1   => r_CLK_120M       ,
		o_CLK_out0  => r_CLK_HASH_1     ,
		o_CLK_out1  => OPEN             ,
		o_locked    => r_locked_MMCME2_1,
		------------DRP Port----------
		i_DCLK_DRP  => r_CLK_12M    ,
		i_DEN_DRP   => r_DEN_DRP_1      ,
		i_DWE_DRP   => r_DWE_DRP_1      ,
		i_DADDR_DRP => r_DADDR_DRP      ,
    
		i_DI_DRP    => r_DI_DRP         ,
		o_DO_DRP    => r_DO_DRP_1       ,
		o_DRDY_DRP  => r_DRDY_DRP_1    

	);


	o_CLK_HASH  <= r_CLK_HASH_MUX     ;
	------------------------------------------------------------
	------------------------------------------------------------


    ------------------------------------------------------------
    ------------------------------------------------------------
    --BUFGMUX_1: General Clock Mux Buffer with Output State 1--- 
    ------------------------------------------------------------
    BUFGMUX_1_inst : BUFGMUX_1                                --
    generic map (                                             --
       CLK_SEL_TYPE => "SYNC"  -- ASYNC, SYNC                --
    )                                                         --
    port map (												  --
       O  => r_CLK_HASH_MUX, -- 1-bit output: Clock output    --
       I0 => r_CLK_HASH_0  , -- 1-bit input: Clock input (S=0)--
       I1 => r_CLK_HASH_1  , -- 1-bit input: Clock input (S=1)--
       S  => r_BUFGMUX_SEL   -- 1-bit input: Clock select     --
    );														  --
    ------------------------------------------------------------
    ------------------------------------------------------------

    o_CLK_FSM_BUSY             <= r_CLK_FSM_BUSY;

	o_locked_CLKSYS_100M       <= r_locked_MMCME0;
	o_locked_CLK_12M           <= r_locked_MMCME1;
    o_locked_CLK_HASH_0        <= r_locked_MMCME2_0;
	o_locked_CLK_HASH_1        <= r_locked_MMCME2_1;


	--Clocking module Status register
	o_CLK_status(31 downto 16) <= r_HASH_CLK_status;
	o_CLK_status(15 downto  4) <= (others => '0');

	o_CLK_status(3)            <= r_locked_MMCME1;
	o_CLK_status(2)            <= r_nreset_MMCMC1;
	o_CLK_status(1)            <= r_locked_MMCME0;
	o_CLK_status(0)            <= '0'; --MMCM0 is always running

end architecture CLOCK_MODULE_arch;