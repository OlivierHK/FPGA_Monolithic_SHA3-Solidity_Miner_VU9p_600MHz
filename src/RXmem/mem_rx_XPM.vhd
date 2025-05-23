library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use IEEE.MATH_REAL.ALL;

Library xpm;
use xpm.vcomponents.all;

Library UNISIM;
use UNISIM.vcomponents.all;

library work;
use work.MyPackage.all;


------------------------------------------------------
-------------------mem_rx Wrapper---------------------
----------------Simple Dual Port RAM------------------
entity mem_rx is
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
end entity;


architecture mem_rx_arch of mem_rx is

begin


  -- xpm_memory_sdpram: Simple Dual Port RAM
   -- Xilinx Parameterized Macro, version 2022.2

   xpm_memory_sdpram_inst : xpm_memory_sdpram
   generic map (
      ADDR_WIDTH_A => 1,               -- DECIMAL
      ADDR_WIDTH_B => 1,               -- DECIMAL
      AUTO_SLEEP_TIME => 0,            -- DECIMAL
      BYTE_WRITE_WIDTH_A => 768,         -- DECIMAL
      CASCADE_HEIGHT => 0,             -- DECIMAL
      CLOCKING_MODE => "independent_clock", -- String
      ECC_MODE => "no_ecc",            -- String
      MEMORY_INIT_FILE => "none",      -- String
      MEMORY_INIT_PARAM => "0",        -- String
      MEMORY_OPTIMIZATION => "true",   -- String
      MEMORY_PRIMITIVE => "auto",      -- String
      MEMORY_SIZE => 1536,             -- DECIMAL
      MESSAGE_CONTROL => 0,            -- DECIMAL
      READ_DATA_WIDTH_B => 768,         -- DECIMAL
      READ_LATENCY_B => 1,             -- DECIMAL
      READ_RESET_VALUE_B => "0",       -- String
      RST_MODE_A => "SYNC",            -- String
      RST_MODE_B => "SYNC",            -- String
      SIM_ASSERT_CHK => 0,             -- DECIMAL; 0=disable simulation messages, 1=enable simulation messages
      USE_EMBEDDED_CONSTRAINT => 0,    -- DECIMAL
      USE_MEM_INIT => 1,               -- DECIMAL
      USE_MEM_INIT_MMI => 0,           -- DECIMAL
      WAKEUP_TIME => "disable_sleep",  -- String
      WRITE_DATA_WIDTH_A => 768,       -- DECIMAL
      WRITE_MODE_B => "write_first",   -- String
      WRITE_PROTECT => 1               -- DECIMAL
   )
   port map (
      dbiterrb => OPEN,             -- 1-bit output: Status signal to indicate double bit error occurrence
                                        -- on the data output of port B.

      doutb => doutb,                   -- READ_DATA_WIDTH_B-bit output: Data output for port B read operations.
      sbiterrb => OPEN,             -- 1-bit output: Status signal to indicate single bit error occurrence
                                        -- on the data output of port B.

      addra => addra,                   -- ADDR_WIDTH_A-bit input: Address for port A write operations.
      addrb => addrb,                   -- ADDR_WIDTH_B-bit input: Address for port B read operations.
      clka => clka,                     -- 1-bit input: Clock signal for port A. Also clocks port B when
                                        -- parameter CLOCKING_MODE is "common_clock".

      clkb => clkb,                     -- 1-bit input: Clock signal for port B when parameter CLOCKING_MODE is
                                        -- "independent_clock". Unused when parameter CLOCKING_MODE is
                                        -- "common_clock".

      dina => dina,                     -- WRITE_DATA_WIDTH_A-bit input: Data input for port A write operations.
      ena => ena,                       -- 1-bit input: Memory enable signal for port A. Must be high on clock
                                        -- cycles when write operations are initiated. Pipelined internally.

      enb => enb,                       -- 1-bit input: Memory enable signal for port B. Must be high on clock
                                        -- cycles when read operations are initiated. Pipelined internally.

      injectdbiterra => '0',            -- 1-bit input: Controls double bit error injection on input data when
                                        -- ECC enabled (Error injection capability is not available in
                                        -- "decode_only" mode).

      injectsbiterra => '0',            -- 1-bit input: Controls single bit error injection on input data when
                                        -- ECC enabled (Error injection capability is not available in
                                        -- "decode_only" mode).

      regceb => '1',                     -- 1-bit input: Clock Enable for the last register stage on the output
                                        -- data path.

      rstb => '0',                     -- 1-bit input: Reset signal for the final port B output register
                                        -- stage. Synchronously resets output port doutb to the value specified
                                        -- by parameter READ_RESET_VALUE_B.

      sleep => '0',                   -- 1-bit input: sleep signal to enable the dynamic power saving feature.
      wea => wea                        -- WRITE_DATA_WIDTH_A/BYTE_WRITE_WIDTH_A-bit input: Write enable vector
                                        -- for port A input data port dina. 1 bit wide when word-wide writes
                                        -- are used. In byte-wide write configurations, each bit controls the
                                        -- writing one byte of dina to address addra. For example, to
                                        -- synchronously write only bits [15-8] of dina when WRITE_DATA_WIDTH_A
                                        -- is 32, wea would be 4'b0010.

   );
    
end architecture mem_rx_arch;