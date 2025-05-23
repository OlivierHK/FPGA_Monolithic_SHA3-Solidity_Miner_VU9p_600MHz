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
----------------------PLL Wrapper------------------------
---------------------------------------------------------
entity PLL is
    Port ( 
        CLK_12M  : out STD_LOGIC;
        CLK_500M : out STD_LOGIC;
        reset    : in  STD_LOGIC;
        locked   : out STD_LOGIC;
        clk_in1  : in  STD_LOGIC
    );
end entity;
----------------------------------------------------------


architecture PLL_ARCH of PLL is

   signal CLK_12M_PLL:  STD_LOGIC;
   signal CLK_500M_PLL: STD_LOGIC;
   begin

  -- MMCME4_ADV: Advanced Mixed Mode Clock Manager (MMCM)
   --             Virtex UltraScale+
   -- Xilinx HDL Language Template, version 2022.2

   MMCME4_ADV_inst : MMCME4_ADV
   generic map (
      BANDWIDTH => "OPTIMIZED",        -- Jitter programming
      CLKFBOUT_MULT_F => 15.0,          -- Multiply value for all CLKOUT
      CLKFBOUT_PHASE => 0.0,           -- Phase offset in degrees of CLKFB
      CLKFBOUT_USE_FINE_PS => "FALSE", -- Fine phase shift enable (TRUE/FALSE)
      CLKIN1_PERIOD => 10.0,            -- Input clock period in ns to ps resolution (i.e., 33.333 is 30 MHz).
      CLKIN2_PERIOD => 0.0,            -- Input clock period in ns to ps resolution (i.e., 33.333 is 30 MHz).
      CLKOUT0_DIVIDE_F => 125.0,         -- Divide amount for CLKOUT0
      CLKOUT0_DUTY_CYCLE => 0.5,       -- Duty cycle for CLKOUT0
      CLKOUT0_PHASE => 0.0,            -- Phase offset for CLKOUT0
      CLKOUT0_USE_FINE_PS => "FALSE",  -- Fine phase shift enable (TRUE/FALSE)
      CLKOUT1_DIVIDE => 3,             -- Divide amount for CLKOUT (1-128)
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
      COMPENSATION => "INTERNAL",          -- Clock input compensation
      DIVCLK_DIVIDE => 1,              -- Master division value
      IS_CLKFBIN_INVERTED => '0',      -- Optional inversion for CLKFBIN
      IS_CLKIN1_INVERTED => '0',       -- Optional inversion for CLKIN1
      IS_CLKIN2_INVERTED => '0',       -- Optional inversion for CLKIN2
      IS_CLKINSEL_INVERTED => '0',     -- Optional inversion for CLKINSEL
      IS_PSEN_INVERTED => '0',         -- Optional inversion for PSEN
      IS_PSINCDEC_INVERTED => '0',     -- Optional inversion for PSINCDEC
      IS_PWRDWN_INVERTED => '0',       -- Optional inversion for PWRDWN
      IS_RST_INVERTED => '0',          -- Optional inversion for RST
      REF_JITTER1 => 0.01,              -- Reference input jitter in UI (0.000-0.999).
      REF_JITTER2 => 0.01,              -- Reference input jitter in UI (0.000-0.999).
      SS_EN => "FALSE",                -- Enables spread spectrum
      SS_MODE => "CENTER_HIGH",        -- Spread spectrum frequency deviation and the spread type
      SS_MOD_PERIOD => 10000,          -- Spread spectrum modulation period (ns)
      STARTUP_WAIT => "FALSE"          -- Delays DONE until MMCM is locked
   )
   port map (
      CDDCDONE    => OPEN,       -- 1-bit output: Clock dynamic divide done
      CLKFBOUT    => OPEN,       -- 1-bit output: Feedback clock
      CLKFBOUTB   => OPEN,       -- 1-bit output: Inverted CLKFBOUT
      CLKFBSTOPPED=> OPEN,       -- 1-bit output: Feedback clock stopped
      CLKINSTOPPED=> OPEN,       -- 1-bit output: Input clock stopped
      CLKOUT0     => CLK_12M_PLL,-- 1-bit output: CLKOUT0
      CLKOUT0B    => OPEN,       -- 1-bit output: Inverted CLKOUT0
      CLKOUT1     => CLK_500M_PLL,-- 1-bit output: CLKOUT1
      CLKOUT1B    => OPEN,       -- 1-bit output: Inverted CLKOUT1
      CLKOUT2     => OPEN,       -- 1-bit output: CLKOUT2
      CLKOUT2B    => OPEN,       -- 1-bit output: Inverted CLKOUT2
      CLKOUT3     => OPEN,       -- 1-bit output: CLKOUT3
      CLKOUT3B    => OPEN,       -- 1-bit output: Inverted CLKOUT3
      CLKOUT4     => OPEN,       -- 1-bit output: CLKOUT4
      CLKOUT5     => OPEN,       -- 1-bit output: CLKOUT5
      CLKOUT6     => OPEN,       -- 1-bit output: CLKOUT6
      DO          => OPEN,       -- 16-bit output: DRP data output
      DRDY        => OPEN,       -- 1-bit output: DRP ready
      LOCKED      => locked,     -- 1-bit output: LOCK
      PSDONE      => OPEN,       -- 1-bit output: Phase shift done
      CDDCREQ     => '0',        -- 1-bit input: Request to dynamic divide clock
      CLKFBIN     => '0',        -- 1-bit input: Feedback clock
      CLKIN1      => clk_in1,    -- 1-bit input: Primary clock
      CLKIN2      => '0',        -- 1-bit input: Secondary clock
      CLKINSEL    => '1',        -- 1-bit input: Clock select, High=CLKIN1 Low=CLKIN2
      DADDR       => (others => '0'),-- 7-bit input: DRP address
      DCLK        => '0',        -- 1-bit input: DRP clock
      DEN         => '0',        -- 1-bit input: DRP enable
      DI          => (others => '0'),-- 16-bit input: DRP data input
      DWE         => '0',        -- 1-bit input: DRP write enable
      PSCLK       => '0',        -- 1-bit input: Phase shift clock
      PSEN        => '0',        -- 1-bit input: Phase shift enable
      PSINCDEC    => '0',        -- 1-bit input: Phase shift increment/decrement
      PWRDWN      => '0',        -- 1-bit input: Power-down
      RST         => reset       -- 1-bit input: Reset
   );



   -------------BUFG as MMCME don't comes with output clock buffer.---------------
   ---------------"create clock" constraint on the BUFG Input"--------------------
   BUFG_clk12M_inst : BUFG
   port map (      
      O => CLK_12M,    -- 1-bit output: Clock output.
      I => CLK_12M_PLL -- 1-bit input: Clock input.
   );
   --------------------------------------------------------------------------------
   BUFG_clk500M_inst : BUFG
   port map (      
      O => CLK_500M,    -- 1-bit output: Clock output.
      I => CLK_500M_PLL -- 1-bit input: Clock input.
   );
   --------------------------------------------------------------------------------



	
end architecture PLL_ARCH;