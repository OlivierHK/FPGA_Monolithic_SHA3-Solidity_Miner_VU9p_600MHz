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


entity mem_rx is
Port ( 
    clka : in  STD_LOGIC;
    ena  : in  STD_LOGIC;
    wea  : in  STD_LOGIC_VECTOR ( 0 to 0 );
    addra: in  STD_LOGIC_VECTOR ( 0 to 0 );
    dina : in  STD_LOGIC_VECTOR ( 767 downto 0 );
    clkb : in  STD_LOGIC;
    enb  : in  STD_LOGIC;
    addrb: in  STD_LOGIC_VECTOR  ( 0 to 0 );
    doutb: out STD_LOGIC_VECTOR (767 downto 0 )
);
end entity;

architecture syn of mem_rx is
  
  type ram_type is array (0 to 1) of std_logic_vector(767 downto 0);
  
  --shared variable RAM : ram_type;
  signal RAM : ram_type;
  attribute ram_style : string;
  attribute ram_style of RAM : signal is "block";

  signal do : STD_LOGIC_VECTOR (767 downto 0 );
  
  begin
  
  process(clka)--write port
    begin
    if clka'event and clka = '1' then
      if ena = '1' then
        if wea(0) = '1' then
          RAM(conv_integer('0'&addra)) <= dina;
          --RAM(conv_integer(addra)) := dina;
        end if;
      end if;
    end if;
  end process;
  
  process(clkb)--read port
    begin 
   
  if clkb'event and clkb = '1' then	
			if enb = '1' then
				do <= RAM(conv_integer('0'&addrb));
			end if;
		end if;
	end process;


  process(clkb)--read port, output register
    begin 
  if clkb'event and clkb = '1' then 
      if enb = '1' then
        doutb <= do;
      end if;
    end if;
  end process;



end syn; 