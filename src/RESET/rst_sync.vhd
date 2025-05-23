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

entity RST_SYNC is
    Port (
        i_CLK_12M                 : in  std_logic;
        i_CLK_500M                : in  std_logic;
        
        i_ASYNC_nRST              : in  std_logic; --unsync

        i_locked_CLKSYS_100M      : in  std_logic; --unsync
        i_locked_CLK_12M          : in  std_logic; --unsync
        i_locked_CLK_HASH_0       : in  std_logic; --sync 12MHz
        i_locked_CLK_HASH_1       : in  std_logic; --sync 12MHz

        i_FSM_Busy                : in  std_logic; --sync 12MHz

        i_timeout_UART_trig       : in   STD_LOGIC;
        i_alarm_vector            : in   STD_LOGIC_VECTOR (7 downto 0);
        o_shutdown_hash_CMD       : out  STD_LOGIC;

        o_SYNCED_nRST_12M         : out std_logic; --sync 12MHz
        o_SYNCED_nRST_CLK_FSM_12M : out std_logic; --sync 12MHz

        o_SYNCED_nRST_500M        : out std_logic  --sync 12MHz
    );
end entity;

architecture RTL of RST_SYNC is
    
    attribute ASYNC_REG              : string   ;
     
    signal r_SYNC_nRSTZZZZ           : STD_LOGIC :='0';
    signal r_SYNC_nRSTZZZ            : STD_LOGIC :='0';
    signal r_SYNC_nRSTZZ             : STD_LOGIC :='0';
    signal r_SYNC_nRSTZ              : STD_LOGIC :='0';
    signal r_SYNC_nRST               : STD_LOGIC :='0';
    signal r_SYNCED_nRST_12M         : STD_LOGIC :='0';
    signal r_SYNCED_nRST_12MZ        : STD_LOGIC :='0';
    signal r_SYNCED_nRST_12MZZ       : STD_LOGIC :='0';
    -- --Sync the MMCM0              
    signal r_locked_CLK_100MZZ       : STD_LOGIC :='0';
    signal r_locked_CLK_100MZ        : STD_LOGIC :='0';
    signal r_locked_CLK_100M         : STD_LOGIC :='0';
    -- --Sync the MMCM1              
    signal r_locked_CLK_12MZZ        : STD_LOGIC :='0';
    signal r_locked_CLK_12MZ         : STD_LOGIC :='0';
    signal r_locked_CLK_12M          : STD_LOGIC :='0';

    --signal the sync to coreCLK
    signal r_SYNCED_nRST_500MZZZ     : STD_LOGIC :='0';
    signal r_SYNCED_nRST_500MZZ      : STD_LOGIC :='0';
    signal r_SYNCED_nRST_500MZ       : STD_LOGIC :='0';
    attribute ASYNC_REG of r_SYNCED_nRST_500MZ : signal is "TRUE";--the first reg receive the data as ASYNC.
    signal r_SYNCED_nRST_500M        : STD_LOGIC :='0';
    signal r_SYNCED_nRST_500M_reg    : STD_LOGIC :='0';
    signal r_SYNCED_nRST_500M_regZ   : STD_LOGIC :='0';
    signal r_SYNCED_nRST_500M_regZZ  : STD_LOGIC :='0';
    signal r_SYNCED_nRST_500M_regZZZ : STD_LOGIC :='0';

    signal r_FSM_BusyZ               : STD_LOGIC :='0';
    signal r_FSM_Busy                : STD_LOGIC :='0';

    signal cnt                       : STD_LOGIC_VECTOR (7 downto 0);


    attribute ASYNC_REG of r_SYNC_nRSTZZZZ : signal is "TRUE";--the first reg receive the data as ASYNC.


    --FSM State definition
    type TYPE_S_STATE is (S_WAKEUP_12M, S_WAKEUP_CLOCK_FSM_12M, S_WAKEUP_500M,
                          S_IDLE_RST,
                          S_WAIT_SHUTDOWM_FINISHED, S_WAIT_NRST_500M_PROPAGATION, S_RESET_ALL,
                          S_WAIT_SHUTDOWN_ALARM
                          );
    signal S_RESET_FSM : TYPE_S_STATE;

    
begin


    --generation of the Reset for 12MHz modules. and SYNC all signals to 12MHz
    process (i_CLK_12M, i_locked_CLK_12M)
    begin
        if(i_locked_CLK_12M ='0') then
            --synchronize outside Board nRST signal with 12MHz.
            r_SYNC_nRSTZZZZ     <= '0';
            r_SYNC_nRSTZZZ      <= '0';
            r_SYNC_nRSTZZ       <= '0';
            r_SYNC_nRSTZ        <= '0';
            r_SYNC_nRST         <= '0';

            -- --Sync the MMCM0 signal to 12MHz.
            r_locked_CLK_100MZZ <= '0';
            r_locked_CLK_100MZ  <= '0';
            r_locked_CLK_100M   <= '0';      

            -- --Sync the MMCM1 signal to 12MHz.
            r_locked_CLK_12MZZ  <= '0';
            r_locked_CLK_12MZ   <= '0';
            r_locked_CLK_12M    <= '0';

        elsif(rising_edge(i_CLK_12M)) then           
            --synchronize outside Board nRST signal with 12MHz.
            r_SYNC_nRSTZZZZ     <= i_ASYNC_nRST;
            r_SYNC_nRSTZZZ      <= r_SYNC_nRSTZZZZ;
            r_SYNC_nRSTZZ       <= r_SYNC_nRSTZZZ;
            r_SYNC_nRSTZ        <= r_SYNC_nRSTZZ;
            r_SYNC_nRST         <= r_SYNC_nRSTZ AND r_SYNC_nRSTZZ AND r_SYNC_nRSTZZZ AND r_SYNC_nRSTZZZZ;

            -- --Sync the MMCM0 signal to 12MHz.
            r_locked_CLK_100MZZ <= i_locked_CLKSYS_100M;
            r_locked_CLK_100MZ  <= r_locked_CLK_100MZZ ;
            r_locked_CLK_100M   <= r_locked_CLK_100MZ  ;        

            -- --Sync the MMCM1 signal to 12MHz.
            r_locked_CLK_12MZZ  <= i_locked_CLK_12M  ;
            r_locked_CLK_12MZ   <= r_locked_CLK_12MZZ;
            r_locked_CLK_12M    <= r_locked_CLK_12MZ ;

        end if;    
    end process;    


    --process (i_CLK_500M, i_locked_CLK_12M )
    --begin
    --    if(i_locked_CLK_12M ='0') then
    --        r_SYNCED_nRST_500MZ   <= '0';
    --        r_SYNCED_nRST_500MZZ  <= '0';
    --        r_SYNCED_nRST_500MZZZ <= '0';
    --        r_SYNCED_nRST_500M_reg<= '0';
    --
    --    elsif (rising_edge(i_CLK_500M)) then
    --        r_SYNCED_nRST_500MZ   <= r_SYNCED_nRST_500M   ;
    --        r_SYNCED_nRST_500MZZ  <= r_SYNCED_nRST_500MZ  ;
    --        r_SYNCED_nRST_500MZZZ <= r_SYNCED_nRST_500MZZ ;
    --        r_SYNCED_nRST_500M_reg<= r_SYNCED_nRST_500MZZZ AND r_SYNCED_nRST_500MZZ ;
    --
    --    end if;
    --end process;

    ----multiple pipelines of the reset signal for meeting up timing accross the chip
    --process(i_CLK_500M)
    --begin
    --    if(rising_edge(i_CLK_500M)) then
    --        r_SYNCED_nRST_500M_regZ   <= r_SYNCED_nRST_500M_reg   ; --
    --        r_SYNCED_nRST_500M_regZZ  <= r_SYNCED_nRST_500M_regZ  ; --
    --        r_SYNCED_nRST_500M_regZZZ <= r_SYNCED_nRST_500M_regZZ ; --Let Vivado duplicate those registers and spread them all around the Chip.
    --        o_SYNCED_nRST_500M        <= r_SYNCED_nRST_500M_regZZZ; --
    --    end if;
    --end process;    


    --multiple pipelines of the reset signal for meeting up timing accross the chip
    process(i_CLK_12M)
    begin
        if(rising_edge(i_CLK_12M)) then
            r_SYNCED_nRST_12MZ  <= r_SYNCED_nRST_12M  ; --
            r_SYNCED_nRST_12MZZ <= r_SYNCED_nRST_12MZ ; --
            o_SYNCED_nRST_12M   <= r_SYNCED_nRST_12MZZ; --can be replicated by vivado tool.; --Let Vivado duplicate those registers and spread them all around the Chip.
        
            r_SYNCED_nRST_500MZ  <= r_SYNCED_nRST_500M;
            r_SYNCED_nRST_500MZZ <= r_SYNCED_nRST_500MZ;
            o_SYNCED_nRST_500M   <= r_SYNCED_nRST_500MZZ;

        end if;
    end process;  



    r_FSM_BusyZ <= i_FSM_Busy;

    --async reset FSM, for proper init when power ON.
    process(i_CLK_12M, i_locked_CLK_12M)
    begin

    if(i_locked_CLK_12M ='0') then
        
        r_SYNCED_nRST_12M         <= '0';

        o_SYNCED_nRST_CLK_FSM_12M <= '0';
        o_shutdown_hash_CMD       <= '0';

        r_SYNCED_nRST_500M        <= '0';

        r_FSM_Busy                <= '0';

        cnt                       <= (others => '0');

        S_RESET_FSM               <= S_WAKEUP_12M;


    elsif(rising_edge(i_CLK_12M)) then

        r_FSM_Busy        <= r_FSM_BusyZ;

        case S_RESET_FSM is
            -- --waking up all the module with Sysclock 12MHz clock. exept Clock FSM
            when S_WAKEUP_12M =>
                
                if(r_locked_CLK_12M = '1' and r_locked_CLK_100M = '1' AND r_SYNC_nRST = '1') then
                    r_SYNCED_nRST_12M <= '1';
                    S_RESET_FSM       <= S_WAKEUP_CLOCK_FSM_12M;
                end if;


            --waking up Core Clock FSM
            when S_WAKEUP_CLOCK_FSM_12M =>  

                --delay 1 clock cycle waking up of CLK FSM
                o_SYNCED_nRST_CLK_FSM_12M <= '1'; 

                if(i_locked_CLK_HASH_0 = '1') then--MMCM0 is output first after a reset.
                    S_RESET_FSM <= S_WAKEUP_500M;
                end if;
              
            --waking up CoreCLock Modules.
            when S_WAKEUP_500M =>

                r_SYNCED_nRST_500M <= '1';
                S_RESET_FSM        <=S_IDLE_RST;


            --IDLE state. Waiting for a reset signal or alarm signal
            when S_IDLE_RST =>

                if(r_SYNC_nRST = '0') then
                    o_shutdown_hash_CMD <= '1';
                    S_RESET_FSM         <= S_WAIT_SHUTDOWM_FINISHED;
                end if;

                if(i_alarm_vector /= X"00") then
                    o_shutdown_hash_CMD <= '1';
                    S_RESET_FSM         <= S_WAIT_SHUTDOWN_ALARM;
                end if;

                if(i_timeout_UART_trig = '1') then
                    o_shutdown_hash_CMD <= '1';
                    S_RESET_FSM         <= S_WAIT_SHUTDOWN_ALARM;
                end if;


            --waiting for clock FSM shutdown to finish.
            when S_WAIT_SHUTDOWM_FINISHED =>

                if (r_FSM_BusyZ='0' and r_FSM_Busy='1') then--edge detector. 
                    cnt                <= (others => '0');
                    r_SYNCED_nRST_500M <= '0'  ;
                    S_RESET_FSM        <= S_WAIT_NRST_500M_PROPAGATION;
                end if;   

            --waiting some time, so the nRST_500M can propagate around trhe chip
            when S_WAIT_NRST_500M_PROPAGATION =>

                cnt <= cnt+1;
                if (cnt = X"FF") then
                    S_RESET_FSM <= S_RESET_ALL;
                end if;     


            --put the whole FPGA under reset and wait outside reset to be de-asserted.
            when S_RESET_ALL =>
              
                o_shutdown_hash_CMD       <= '0';
                o_SYNCED_nRST_CLK_FSM_12M <= '0';  
                r_SYNCED_nRST_12M         <= '0';

                r_SYNCED_nRST_500M        <= '0';

                if(r_SYNC_nRST = '1') then  
                    S_RESET_FSM <= S_WAKEUP_12M;
                end if;  


            --waiting for clock FSM shutdown to finish.
            when S_WAIT_SHUTDOWN_ALARM =>

                if (r_FSM_BusyZ='0' and r_FSM_Busy='1') then--edge detector. 
                    o_shutdown_hash_CMD <= '0';
                    S_RESET_FSM         <= S_IDLE_RST;
                end if; 


            --others    
            when others =>

                r_SYNCED_nRST_12M         <= '0';
        
                o_SYNCED_nRST_CLK_FSM_12M <= '0';
                o_shutdown_hash_CMD       <= '0';
        
                r_SYNCED_nRST_500M        <= '0';
        
                r_FSM_Busy                <= '0';

                cnt                       <= (others => '0');
        
                S_RESET_FSM               <= S_WAKEUP_12M;

        end case;
    end if;
    end process;

end architecture;