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
--------------------MMCME Wrapper------------------------
---------------------------------------------------------
entity MMCME_WRAPPER is
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
end entity;
----------------------------------------------------------


architecture MMCME_WRAPPER_arch of MMCME_WRAPPER is

   signal r_clk_in1       : STD_LOGIC;

   signal r_CLKFBOUTi     : STD_LOGIC;
   signal r_CLKFBOUTo     : STD_LOGIC;

   signal r_CLK_out0_MMCME: STD_LOGIC;
   signal r_CLK_out1_MMCME: STD_LOGIC;
   begin

  -- MMCME4_ADV: Advanced Mixed Mode Clock Manager (MMCM)
   --             Virtex UltraScale+
   -- Xilinx HDL Language Template, version 2022.2

   MMCME4_ADV_inst : MMCME4_ADV
   generic map (
      BANDWIDTH => g_BANDWIDTH,        -- Jitter programming
      CLKFBOUT_MULT_F => g_CLKOUT_MULT,  -- Multiply value for all CLKOUT
      CLKFBOUT_PHASE => 0.0,           -- Phase offset in degrees of CLKFB
      CLKFBOUT_USE_FINE_PS => "FALSE", -- Fine phase shift enable (TRUE/FALSE)
      CLKIN1_PERIOD => g_CLKIN_PERIOD,   -- Input clock period in ns to ps resolution (i.e., 33.333 is 30 MHz).
      CLKIN2_PERIOD => 0.0,            -- Input clock period in ns to ps resolution (i.e., 33.333 is 30 MHz).
      CLKOUT0_DIVIDE_F => g_CLKOUT0_DIV, -- Divide amount for CLKOUT0
      CLKOUT0_DUTY_CYCLE => 0.5,       -- Duty cycle for CLKOUT0
      CLKOUT0_PHASE => 0.0,            -- Phase offset for CLKOUT0
      CLKOUT0_USE_FINE_PS => "FALSE",  -- Fine phase shift enable (TRUE/FALSE)
      CLKOUT1_DIVIDE => g_CLKOUT1_DIV,   -- Divide amount for CLKOUT (1-128)
      CLKOUT1_DUTY_CYCLE => 0.5,       -- Duty cycle for CLKOUT outputs (0.001-0.999).
      CLKOUT1_PHASE => 0.0,            -- Phase offset for CLKOUT outputs (-360.000-360.000).
      CLKOUT1_USE_FINE_PS => "FALSE",  -- Fine phase shift enable (TRUE/FALSE)
      CLKOUT2_DIVIDE => 1,             -- Divide amount for CLKOUT (1-128)
      CLKOUT2_DUTY_CYCLE => 0.5,       -- Duty cycle for CLKOUT outputs (0.001-0.999).
      CLKOUT2_PHASE => 0.0,            -- Phase offset for CLKOUT outputs (-360.000-360.000).
      CLKOUT2_USE_FINE_PS => "FALSE",  -- Fine phase shift enable (TRUE/FALSE)
      CLKOUT3_DIVIDE => 1,             -- Divide amount for CLKOUT (1-128)
      CLKOUT3_DUTY_CYCLE => 0.5,       -- Duty cycle for CLKOUT outputs (0.001-0.999).
      CLKOUT3_PHASE => 0.0,            -- Phase offset for CLKOUT outputs (-360.000-360.000).
      CLKOUT3_USE_FINE_PS => "FALSE",  -- Fine phase shift enable (TRUE/FALSE)
      CLKOUT4_CASCADE => "FALSE",      -- Divide amount for CLKOUT (1-128)
      CLKOUT4_DIVIDE => 1,             -- Divide amount for CLKOUT (1-128)
      CLKOUT4_DUTY_CYCLE => 0.5,       -- Duty cycle for CLKOUT outputs (0.001-0.999).
      CLKOUT4_PHASE => 0.0,            -- Phase offset for CLKOUT outputs (-360.000-360.000).
      CLKOUT4_USE_FINE_PS => "FALSE",  -- Fine phase shift enable (TRUE/FALSE)
      CLKOUT5_DIVIDE => 1,             -- Divide amount for CLKOUT (1-128)
      CLKOUT5_DUTY_CYCLE => 0.5,       -- Duty cycle for CLKOUT outputs (0.001-0.999).
      CLKOUT5_PHASE => 0.0,            -- Phase offset for CLKOUT outputs (-360.000-360.000).
      CLKOUT5_USE_FINE_PS => "FALSE",  -- Fine phase shift enable (TRUE/FALSE)
      CLKOUT6_DIVIDE => 1,             -- Divide amount for CLKOUT (1-128)
      CLKOUT6_DUTY_CYCLE => 0.5,       -- Duty cycle for CLKOUT outputs (0.001-0.999).
      CLKOUT6_PHASE => 0.0,            -- Phase offset for CLKOUT outputs (-360.000-360.000).
      CLKOUT6_USE_FINE_PS => "FALSE",  -- Fine phase shift enable (TRUE/FALSE)
      COMPENSATION => "ZHOLD",      -- Clock input compensation
      DIVCLK_DIVIDE => g_DIVCLK_DIVIDE,              -- Master division value
      IS_CLKFBIN_INVERTED => '0',      -- Optional inversion for CLKFBIN
      IS_CLKIN1_INVERTED => '0',       -- Optional inversion for CLKIN1
      IS_CLKIN2_INVERTED => '0',       -- Optional inversion for CLKIN2
      IS_CLKINSEL_INVERTED => '0',     -- Optional inversion for CLKINSEL
      IS_PSEN_INVERTED => '0',         -- Optional inversion for PSEN
      IS_PSINCDEC_INVERTED => '0',     -- Optional inversion for PSINCDEC
      IS_PWRDWN_INVERTED => '0',       -- Optional inversion for PWRDWN
      IS_RST_INVERTED => '1',          -- Optional inversion for RST
      REF_JITTER1 => 0.01,              -- Reference input jitter in UI (0.000-0.999).
      REF_JITTER2 => 0.01,              -- Reference input jitter in UI (0.000-0.999).
      SS_EN => "FALSE",                -- Enables spread spectrum
      SS_MODE => "CENTER_HIGH",        -- Spread spectrum frequency deviation and the spread type
      SS_MOD_PERIOD => 10000,          -- Spread spectrum modulation period (ns)
      STARTUP_WAIT => "FALSE"          -- Delays DONE until MMCM is locked
   )
   port map (
      CDDCDONE    => OPEN,       -- 1-bit output: Clock dynamic divide done
      CLKFBOUT    => r_CLKFBOUTo,-- 1-bit output: Feedback clock
      CLKFBOUTB   => OPEN,       -- 1-bit output: Inverted CLKFBOUT
      CLKFBSTOPPED=> OPEN,       -- 1-bit output: Feedback clock stopped
      CLKINSTOPPED=> OPEN,       -- 1-bit output: Input clock stopped
      CLKOUT0     => r_CLK_out0_MMCME,-- 1-bit output: CLKOUT0
      CLKOUT0B    => OPEN,       -- 1-bit output: Inverted CLKOUT0
      CLKOUT1     => r_CLK_out1_MMCME,-- 1-bit output: CLKOUT1
      CLKOUT1B    => OPEN,       -- 1-bit output: Inverted CLKOUT1
      CLKOUT2     => OPEN,       -- 1-bit output: CLKOUT2
      CLKOUT2B    => OPEN,       -- 1-bit output: Inverted CLKOUT2
      CLKOUT3     => OPEN,       -- 1-bit output: CLKOUT3
      CLKOUT3B    => OPEN,       -- 1-bit output: Inverted CLKOUT3
      CLKOUT4     => OPEN,       -- 1-bit output: CLKOUT4
      CLKOUT5     => OPEN,       -- 1-bit output: CLKOUT5
      CLKOUT6     => OPEN,       -- 1-bit output: CLKOUT6
      DO          => o_DO_DRP,       -- 16-bit output: DRP data output
      DRDY        => o_DRDY_DRP,       -- 1-bit output: DRP ready
      LOCKED      => o_locked,   -- 1-bit output: LOCK
      PSDONE      => OPEN,       -- 1-bit output: Phase shift done
      CDDCREQ     => '0',        -- 1-bit input: Request to dynamic divide clock
      CLKFBIN     => r_CLKFBOUTi,-- 1-bit input: Feedback clock
      CLKIN1      => r_clk_in1,    -- 1-bit input: Primary clock
      CLKIN2      => '0',        -- 1-bit input: Secondary clock
      CLKINSEL    => '1',        -- 1-bit input: Clock select, High=CLKIN1 Low=CLKIN2
      DADDR       => i_DADDR_DRP,-- 7-bit input: DRP address
      DCLK        => i_DCLK_DRP,        -- 1-bit input: DRP clock
      DEN         => i_DEN_DRP,        -- 1-bit input: DRP enable
      DI          => i_DI_DRP,-- 16-bit input: DRP data input
      DWE         => i_DWE_DRP,        -- 1-bit input: DRP write enable
      PSCLK       => '0',        -- 1-bit input: Phase shift clock
      PSEN        => '0',        -- 1-bit input: Phase shift enable
      PSINCDEC    => '0',        -- 1-bit input: Phase shift increment/decrement
      PWRDWN      => '0',        -- 1-bit input: Power-down
      RST         => i_nreset    -- 1-bit input: Reset
   );



   --------------------------------Clock Feedback BUFG-----------------------------
   -- --create a BUFG on feedback clock if requested.
   generate_BUFfb: if (g_USE_BUFfb = True) generate
   BUFG_CLK_fb_inst : BUFG
   port map (      
      O => r_CLKFBOUTi,-- 1-bit output: Clock output.
      I => r_CLKFBOUTo -- 1-bit input: Clock input.
   );
   end generate; 

   -- do not create a BUFG on input clock if requested.-------------------------------
   generate_noBUFfb: if (g_USE_BUFfb = False) generate
      r_CLKFBOUTi <= r_CLKFBOUTo;      
   end generate; 
   --------------------------------------------------------------------------------



   ----------------------------------------------------------------------------------
   -----------------------------BUFG section if needed-------------------------------
   ----------------------------------------------------------------------------------

   -- --create a BUFG on input clock if requested.
   generate_BUFIN: if (g_USE_BUFIN = True) generate
      --------------BUFG as MMCME don't comes with input clock buffer.---------------
      BUFG_clkin_inst : BUFG
      port map (      
         O => r_clk_in1,-- 1-bit output: Clock output.
         I => i_clk_in1 -- 1-bit input: Clock input.
      );
      --------------------------------------------------------------------------------
   end generate;   

   -- do not create a BUFG on input clock if requested.-------------------------------
   generate_noBUFIN: if (g_USE_BUFIN = False) generate
      r_clk_in1 <= i_clk_in1;      
   end generate; 
   -----------------------------------------------------------------------------------




   ----create a BUFG on output clock if requested.
   generate_BUFOUT_0: if (g_USE_BUFOUT_0 = True) generate
      -------------BUFG as MMCME don't comes with output clock buffer.---------------
      -----------"create_generate_clock" constraint on the BUFG Input"---------------
      BUFG_clkout0_inst : BUFG
      port map (      
         O => o_CLK_out0,      -- 1-bit output: Clock output.
         I => r_CLK_out0_MMCME -- 1-bit input: Clock input.
      );
      --------------------------------------------------------------------------------
   end generate;

   --Do not crete a BUFG on output clock if requested----------------------------------
   generate_noBUFOUT_0: if (g_USE_BUFOUT_0 = False) generate
      o_CLK_out0 <= r_CLK_out0_MMCME;
   end generate;





   ----create a BUFG on output clock if requested.
   generate_BUFOUT_1: if (g_USE_BUFOUT_1 = True) generate
      -------------BUFG as MMCME don't comes with output clock buffer.---------------
      -----------"create_generate_clock" constraint on the BUFG Input"---------------
      BUFG_clkout1_inst : BUFG
      port map (      
         O => o_CLK_out1,      -- 1-bit output: Clock output.
         I => r_CLK_out1_MMCME -- 1-bit input: Clock input.
      );
      --------------------------------------------------------------------------------
   end generate;   
   
  --Do not crete a BUFG on output clock if requested----------------------------------
   generate_noBUFOUT_1: if (g_USE_BUFOUT_1 = False) generate
      o_CLK_out1 <= r_CLK_out1_MMCME;  
   end generate;
   -----------------------------------------------------------------------------------
   -----------------------------------------------------------------------------------
   -----------------------------------------------------------------------------------

	
end architecture MMCME_WRAPPER_arch;