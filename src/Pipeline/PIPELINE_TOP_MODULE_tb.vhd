library IEEE;
use     IEEE.STD_LOGIC_1164.ALL;
use     IEEE.NUMERIC_STD.ALL;
use     IEEE.STD_LOGIC_ARITH.ALL;
use     IEEE.STD_LOGIC_UNSIGNED.ALL;
use     IEEE.MATH_REAL.ALL;

library work;
use     work.MyPackage.all;

entity PIPELINE_TOP_MODULE_tb is
end;

architecture bench of PIPELINE_TOP_MODULE_tb is

  component PIPELINE_TOP_MODULE
      Port (
          i_CLK_500M                : in    std_logic;
          i_HASH_en                 : in   std_logic;
          o_HASH_en_delay           : out  bit_bus_type ;
          i_header_chunck           : in   std_logic_vector ( (BLOCK_HEADER_CHUNK_WIDTH-1) downto 0);
          o_header_chunck_delay     : out  header64_bus_type;
          i_valid_out               : in   bit_bus_type;
          o_valid_out_delay         : out  std_logic;
          i_GoldenTicket_core       : in   bit_bus_type;
          o_GoldenTicket_core_delay : out  bit_bus_type
      );
  end component;

  signal i_CLK_500M                : std_logic;
  signal i_HASH_en                 : std_logic:='0';
  signal o_HASH_en_delay           : bit_bus_type;
  signal i_header_chunck           : std_logic_vector ( (BLOCK_HEADER_CHUNK_WIDTH-1) downto 0):=X"0000000000000001";
  signal o_header_chunck_delay     : header64_bus_type;
  signal i_valid_out               : bit_bus_type:="00000000000000000000001";
  signal o_valid_out_delay         : std_logic;
  signal i_GoldenTicket_core       : bit_bus_type:="00000000000000000000001";
  signal o_GoldenTicket_core_delay : bit_bus_type ;

  constant clock_period: time := 2 ns;
  signal   stop_the_clock: boolean;

begin

  uut: PIPELINE_TOP_MODULE 
    port map ( 
      i_CLK_500M                => i_CLK_500M,
      i_HASH_en                 => i_HASH_en,
      o_HASH_en_delay           => o_HASH_en_delay,
      i_header_chunck           => i_header_chunck,
      o_header_chunck_delay     => o_header_chunck_delay,
      i_valid_out               => i_valid_out,
      o_valid_out_delay         => o_valid_out_delay,
      i_GoldenTicket_core       => i_GoldenTicket_core,
      o_GoldenTicket_core_delay => o_GoldenTicket_core_delay 
    );

  
  stimulus: process
  begin
    stop_the_clock <= false;
    wait;
  end process;

  clocking: process
  begin
    while not stop_the_clock loop
      i_CLK_500M <= '0', '1' after clock_period / 2;
      wait for clock_period;
    end loop;
    wait;
  end process;



process(i_CLK_500M)
  begin
    if(i_CLK_500M='1' and i_CLK_500M'event) then
       i_HASH_en                  <= not (i_HASH_en);

       i_header_chunck            <= i_header_chunck + 1 ;

       --i_valid_out                <= i_valid_out( (NB_CORE-2) downto 0) & '0';

       i_GoldenTicket_core        <= i_GoldenTicket_core;
    end if;   
end process;       



end;