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
entity PIPELINE_BACKWARD_MODULE is
    Port (
        -- Hashing Clock.
        i_CLK                     : in    std_logic; 

        -- valid/Gticket backward Pipeline
        i_valid_out               : in   bit_bus_type;
        o_valid_out_delay         : out  std_logic;

        i_GoldenTicket_core       : in   bit_bus_type;
        o_GoldenTicket_core_delay : out  bit_bus_type;

        i_GoldenNonce_core        : in    header64_bus_type;
        o_GoldenNonce_core_delay  : out   header64_bus_type
    );
    
end entity;
-------------------------------------------------------------------------------------------------------




architecture ARCH of PIPELINE_BACKWARD_MODULE is

    
    signal r_valid_out_delay        : bit_delay_backward_type;
        attribute DONT_TOUCH    of r_valid_out_delay : signal is "true";
        attribute shreg_extract of r_valid_out_delay : signal is "no"  ;

    signal r_GoldenTicket_core_delay: bit_bus_delay_backward_type;
        attribute DONT_TOUCH    of r_GoldenTicket_core_delay: signal is "true";
        attribute shreg_extract of r_GoldenTicket_core_delay: signal is "no"; 

    signal r_GoldenNonce_core_delay: header_bus_delay_type;
        attribute DONT_TOUCH    of r_GoldenNonce_core_delay: signal is "true";
        attribute shreg_extract of r_GoldenNonce_core_delay: signal is "no"; 



    begin

    --pipeline backward ( Valid signal and Golden ticket signal)---------------------------------------------
    process(i_CLK)
    begin
        if(i_CLK'event and i_CLK = '1') then

            
            r_valid_out_delay(0)(0) <= i_valid_out(NB_CORE-1);--We arbitrary choose core max ID to carry the valid signal.
            
            for CORE_ID in 0 to (NB_CORE-1) loop
                r_GoldenTicket_core_delay(0)(CORE_ID)  <= i_GoldenTicket_core(CORE_ID);
                r_GoldenNonce_core_delay(0)(CORE_ID)   <= i_GoldenNonce_core(CORE_ID);
            end loop;   

            for DELAY_ID in 1 to DELAY_BACKWARD loop
                r_valid_out_delay(DELAY_ID)(0)        <=  r_valid_out_delay(DELAY_ID-1)(0);
                
                for CORE_ID in 0 to (NB_CORE-1) loop
                    r_GoldenTicket_core_delay(DELAY_ID)(CORE_ID) <= r_GoldenTicket_core_delay(DELAY_ID-1)(CORE_ID) ;
                    r_GoldenNonce_core_delay(DELAY_ID)(CORE_ID)  <= r_GoldenNonce_core_delay(DELAY_ID-1)(CORE_ID) ;
                end loop;

            end loop;    

        end if;
    end process;  
    
    o_valid_out_delay         <= r_valid_out_delay(DELAY_BACKWARD)(0);
    o_GoldenTicket_core_delay <= r_GoldenTicket_core_delay(DELAY_BACKWARD) ;
    o_GoldenNonce_core_delay  <= r_GoldenNonce_core_delay(DELAY_BACKWARD) ;

end architecture;