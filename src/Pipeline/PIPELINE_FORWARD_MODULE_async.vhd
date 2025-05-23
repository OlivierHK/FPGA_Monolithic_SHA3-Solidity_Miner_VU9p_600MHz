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

library work;
use     work.MyPackage.all;

-------------------------------------------------------------------------------------------------------
------------------------------------------TOP ENTITY---------------------------------------------------
-------------------------------------------------------------------------------------------------------
entity PIPELINE_FORWARD_MODULE is
    Port (
        -- Hashing Clock.
        i_CLK                     : in    std_logic; 

        -- header/enable forward Pipeline
        i_HASH_en                 : in   std_logic;
        o_HASH_en_delay           : out  bit_bus_type ;

        i_header_chunck           : in   std_logic_vector ( (BLOCK_HEADER_CHUNK_WIDTH-1) downto 0);
        o_header_chunck_delay     : out  header64_bus_type
    );
    
end entity;
-------------------------------------------------------------------------------------------------------




architecture ARCH of PIPELINE_FORWARD_MODULE is

    
    signal r_HASH_header_core_delay : header_bus_delay_type;
        attribute KEEP          of r_HASH_header_core_delay : signal is "true";
        attribute shreg_extract of r_HASH_header_core_delay : signal is "no"  ;

    signal r_HASH_en_delay          : bit_bus_delay_forward_type ;
        attribute KEEP          of r_HASH_en_delay  : signal is "true";
        attribute shreg_extract of r_HASH_en_delay  : signal is "no"  ;    



    begin

    --pipeline forward (chunked header, then nonce and Hash enable signal)
    process(i_CLK)
    begin
        if(i_CLK'event and i_CLK = '1') then

            for CORE_ID in 0 to (NB_CORE-1) loop
                
                --Pipeline bus filed with the full header chunk during fillinp up. truncated and filled up with core ID if during nonce sweeping.
                r_HASH_header_core_delay(0)(CORE_ID) <= i_header_chunck;
                
                --if (i_HASH_en = '1') then
                --    r_HASH_header_core_delay(0)(CORE_ID) <= i_header_chunck(63 downto NB_CORE_MAX_BIT_LENGTH) & (std_logic_vector(to_unsigned(CORE_ID,NB_CORE_MAX_BIT_LENGTH)));
                --end if;

                r_HASH_en_delay(0)(CORE_ID)          <= i_HASH_en;

                for DELAY_ID in 1 to DELAY_FORWARD loop
                    r_HASH_header_core_delay(DELAY_ID)(CORE_ID) <= r_HASH_header_core_delay(DELAY_ID-1)(CORE_ID) ;
                    r_HASH_en_delay(DELAY_ID)(CORE_ID)          <= r_HASH_en_delay(DELAY_ID-1)(CORE_ID);
                end loop;
            end loop;    
        end if;
    end process;

    o_HASH_en_delay       <= r_HASH_en_delay(DELAY_FORWARD)          ;
    o_header_chunck_delay <= r_HASH_header_core_delay(DELAY_FORWARD) ;   

end architecture;