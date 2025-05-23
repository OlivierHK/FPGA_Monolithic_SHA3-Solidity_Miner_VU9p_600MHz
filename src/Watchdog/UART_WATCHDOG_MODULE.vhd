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

Library UNISIM;
use     UNISIM.vcomponents.all;

library work;
use     work.MyPackage.all;

-------------------------------------------------------------------------------------------------------
------------------------------------------TOP ENTITY---------------------------------------------------
-------------------------------------------------------------------------------------------------------
entity UART_WATCHDOG_MODULE is
    Port (
        --CLOCK and nRESET
        i_CLK_12M           : in  std_logic; -- Sysclk 12 MHz.
        i_SYNCED_nRST_12M   : in  std_logic; -- sync nRST signal.
       
        -- UART new message received toggle signal.
        i_trig_toggle_12M   : in  std_logic;
       
        --output timeout signal. will trigger an FPGA shutdown.
        o_timeout_UART_trig : out std_Logic
    );
    
end entity;
-------------------------------------------------------------------------------------------------------



architecture ARCH of UART_WATCHDOG_MODULE is

    signal r_watchdog_cnt      : std_Logic_vector(32 downto 0);
    signal r_trig_toggle_12M_Z : std_logic;
    signal r_timeout_UART_trig : std_logic;

begin

    process(i_CLK_12M, i_SYNCED_nRST_12M) 
    begin
        if(i_CLK_12M'event AND i_CLK_12M = '1') then

            if(i_SYNCED_nRST_12M = '0') then
                r_watchdog_cnt      <= (others => '0');
                r_trig_toggle_12M_Z <= '0';
                r_timeout_UART_trig <= '0';

            else
                r_trig_toggle_12M_Z <= i_trig_toggle_12M;
                r_timeout_UART_trig <= '0';
                
                if(i_trig_toggle_12M /= r_trig_toggle_12M_Z) then
                    r_watchdog_cnt <= (others => '0');
                
                elsif(r_watchdog_cnt = C_WATCHDOG_TIMEOUT_TIME) then
                    r_timeout_UART_trig <= '1';
                    r_watchdog_cnt      <= (others => '0');
                
                else
                    r_watchdog_cnt <= r_watchdog_cnt + 1;
                
                end if; 
            end if;
        end if;
    end process;

    o_timeout_UART_trig <= r_timeout_UART_trig;                    

end architecture;