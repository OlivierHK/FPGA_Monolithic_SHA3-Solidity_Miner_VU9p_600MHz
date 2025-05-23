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



entity CLOCK_HASH_FSM_MODULE is
    Port ( 
            -----------------------System port------------------------
            i_nreset             : in  STD_LOGIC;

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
end entity;
------------------------------------------------------------------


architecture CLOCK_HASH_FSM_MODULE_arch of CLOCK_HASH_FSM_MODULE is

    attribute ASYNC_REG              : string   ;
    --MMCM Locked re-clocking signals.
    signal r_locked_MMCM2_0_Z     : STD_LOGIC;
    attribute ASYNC_REG of r_locked_MMCM2_0_Z : signal is "TRUE";
    signal r_locked_MMCM2_1_Z     : STD_LOGIC;
    attribute ASYNC_REG of r_locked_MMCM2_1_Z : signal is "TRUE";
    signal r_locked_MMCM2_0_ZZ    : STD_LOGIC;
    signal r_locked_MMCM2_1_ZZ    : STD_LOGIC;
    signal r_locked_MMCM2_0_ZZZ   : STD_LOGIC;
    signal r_locked_MMCM2_1_ZZZ   : STD_LOGIC;
    signal r_locked_MMCM2_0_ZZZZ  : STD_LOGIC;
    signal r_locked_MMCM2_1_ZZZZ  : STD_LOGIC;

    signal r_locked_MMCM2_0       : STD_LOGIC;
    signal r_locked_MMCM2_1       : STD_LOGIC;

    signal r_nreset_MMCMC2_0      : STD_LOGIC;
    signal r_nreset_MMCMC2_1      : STD_LOGIC;

    --ROM Signals
    signal r_ROM_en   : STD_LOGIC;
    signal r_ROM_addr : STD_LOGIC_VECTOR(11 downto 0);
    signal r_ROM_data : STD_LOGIC_VECTOR(23 downto 0);

    --FSM State definition
    type TYPE_S_STATE is (S_STARTUP, S_WAIT_FIRST_LOCK, S_IDLE, S_GET_NEXT_CMD, 
                          S_RD_ROM_DATA, S_WAIT_ROM_DATA, S_GET_ROM_DATA,
                          S_WR_DRP_MMCM, S_WAIT_DRP_MMCM_RDY,
                          S_SET_MMCM, S_WAIT_MMCM_LOCK,
                          S_COOLDOWN_TIME
                          );
    signal S_FMS_HASH_CLOCKING : TYPE_S_STATE;


    --signals to handle new command request
    signal r_HASH_FREQUENCY_TRIGZ    : STD_LOGIC;
    signal r_new_CMD_latch           : STD_LOGIC;
    signal r_HASH_FREQUENCY_CMD      : STD_LOGIC_VECTOR(7 downto 0);-- the COMMAND final input cammand register.
    signal r_last_CMD_latch          : STD_LOGIC_VECTOR(7 downto 0);-- the last COMMAND successfully set. used for Timeout.
    signal r_now_CMD                 : STD_LOGIC_VECTOR(7 downto 0);-- the COMMAND now in used.
    signal r_final_CMD               : STD_LOGIC_VECTOR(7 downto 0);--the requested COMMAND value.

    --signals to handle shutdown request
    signal r_shutdown_hash_CMDZ      : STD_LOGIC;
    signal r_shutdown_hash_CMD_latch : STD_LOGIC;

    --signals to handle ROM reading sequence
    signal r_ROM_index_temp_cnt      : STD_LOGIC_VECTOR(3 downto 0);

    --timer for cooldown time.
    signal r_cooldown_cnt            : STD_LOGIC_VECTOR(19 downto 0);
     
    --timout counter time;     
    signal r_timeout_cnt             : STD_LOGIC_VECTOR(19 downto 0);
    signal r_Timeout_Flag            : STD_LOGIC;

    --MMCM Multiplexer selector signal
    signal r_BUFGMUX_SEL             : STD_LOGIC;

    --FSM Busy signal
    signal r_FSM_busy                : STD_LOGIC;



    ----------------------------------------------------------
    -------------- ROM for DRP values and addresses-----------
    ----------------------------------------------------------
    component ROM_DRP_CLK_MODULE is                         --
        Port (                                              --
        i_ROM_clk  : in  std_logic;                         --
        i_ROM_en   : in  std_logic;                         --
        i_ROM_addr : in  std_logic_vector(11 downto 0);     --
        o_ROM_data : out std_logic_vector(23 downto 0)      --
        );                                                  --
    end component;                                          --
    ----------------------------------------------------------
    ----------------------------------------------------------

--------------------------------------------------------------
    begin

    ----------------------------------------------------------
    -------------- ROM for DRP values and addresses-----------
    ----------------------------------------------------------
    ROM_DRP: ROM_DRP_CLK_MODULE                             --   
    Port map(                                               --   
        i_ROM_clk  => i_CLK_12M  ,                          --       
        i_ROM_en   => r_ROM_en   ,                          --       
        i_ROM_addr => r_ROM_addr ,                          --       
        o_ROM_data => r_ROM_data                            --       
    );                                                      --                                     
    ----------------------------------------------------------
    ----------------------------------------------------------


    --re-clocking Locked signals in FSM Clock speed--------------------------
    Process (i_nreset, i_CLK_12M)
    begin
        if(i_CLK_12M'event AND i_CLK_12M='1') then
            if(i_nreset = '0') then
                r_locked_MMCM2_0_Z    <= '0';
                r_locked_MMCM2_1_Z    <= '0';
                r_locked_MMCM2_0_ZZ   <= '0';
                r_locked_MMCM2_1_ZZ   <= '0';
                r_locked_MMCM2_0_ZZ   <= '0';
                r_locked_MMCM2_1_ZZZ  <= '0';
                r_locked_MMCM2_0_ZZZZ <= '0';
                r_locked_MMCM2_1_ZZZZ <= '0';

                r_locked_MMCM2_0      <= '0';
                r_locked_MMCM2_0      <= '0';

            else
                -----------------------------------------------------------------
                r_locked_MMCM2_0_Z    <= i_locked_MMCM2_0;
                r_locked_MMCM2_0_ZZ   <= r_locked_MMCM2_0_Z;
                r_locked_MMCM2_0_ZZZ  <= r_locked_MMCM2_0_ZZ;
                r_locked_MMCM2_0_ZZZZ <= r_locked_MMCM2_0_ZZZ;

                r_locked_MMCM2_0      <= r_locked_MMCM2_0_ZZZZ AND r_locked_MMCM2_0_ZZZ AND r_locked_MMCM2_0_ZZ;

                -----------------------------------------------------------------
                r_locked_MMCM2_1_Z    <= i_locked_MMCM2_1;
                r_locked_MMCM2_1_ZZ   <= r_locked_MMCM2_1_Z;
                r_locked_MMCM2_1_ZZZ  <= r_locked_MMCM2_1_ZZ;
                r_locked_MMCM2_1_ZZZZ <= r_locked_MMCM2_1_ZZZ;

                r_locked_MMCM2_1      <= r_locked_MMCM2_1_ZZZZ AND r_locked_MMCM2_1_ZZZ AND r_locked_MMCM2_1_ZZ;
            end if;    
        end if; 
    end process;    
    -------------------------------------------------------------------------   


    --FSM BODY------------------------------------------------
    process(i_nreset, i_CLK_12M)
    begin
        
        if (i_CLK_12M'event AND i_CLK_12M='1') then
            if (i_nreset = '0') then
            
                r_ROM_en               <= '0';
                r_ROM_addr             <= (others => '0');

                r_HASH_FREQUENCY_TRIGZ <= '0'; 
                r_new_CMD_latch        <= '0';
                r_HASH_FREQUENCY_CMD   <= X"00"; --default is 0 (100MHZ) 0x3C is 400MHz
                r_last_CMD_latch       <= X"00"; --default is 0 (100MHZ)
                r_now_CMD              <= X"00"; --default is 0 (100MHZ)
                r_final_CMD            <= X"00"; --default is 0 (100MHZ)

                r_shutdown_hash_CMDZ        <= '0';
                r_shutdown_hash_CMD_latch   <= '0';

                r_ROM_index_temp_cnt <= (others => '0');

                r_BUFGMUX_SEL        <= '0';
       
                r_nreset_MMCMC2_0    <= '0';
                r_nreset_MMCMC2_1    <= '0';
       
                o_DEN_DRP_0          <= '0';
                o_DEN_DRP_1          <= '0';
       
                o_DWE_DRP_0          <= '0';
                o_DWE_DRP_1          <= '0';
       
                o_DADDR_DRP          <= (others => '0');                    
                o_DI_DRP             <= (others => '0');

                r_cooldown_cnt       <= C_COOLDOWN_LOAD;

                r_timeout_cnt        <= C_TIMEOUT_LOAD;
                r_Timeout_Flag       <= '0';

                r_FSM_busy           <= '0';


                S_FMS_HASH_CLOCKING  <= S_STARTUP;


            else
                ----------------------------------------------------------------------------------------------
                --latching at any time new command request and value
                r_HASH_FREQUENCY_TRIGZ <= i_HASH_FREQUENCY_TRIG;       
                if(i_HASH_FREQUENCY_TRIG = '1' AND r_HASH_FREQUENCY_TRIGZ = '0') then --rising edge detector
                    r_new_CMD_latch      <='1';                   --
                    r_HASH_FREQUENCY_CMD <= i_HASH_FREQUENCY_CMD; -- Latching event and data.
                end if;
                ----------------------------------------------------------------------------------------------
                --latching at any time shutdown command
                r_shutdown_hash_CMDZ <= i_shutdown_hash_CMD;       
                if(i_shutdown_hash_CMD = '1' AND r_shutdown_hash_CMDZ = '0') then --rising edge detector
                    r_shutdown_hash_CMD_latch <= '1'; -- Latching event and data.
                end if;
                ---------------------------------------------------------------------------------------------
                
                case S_FMS_HASH_CLOCKING is
                    
                    when S_STARTUP=>
         
                        r_nreset_MMCMC2_0   <= '1';-- as startup, running the HASHING clock at it's default setting.
                        S_FMS_HASH_CLOCKING <= S_WAIT_FIRST_LOCK;


                    when S_WAIT_FIRST_LOCK =>
                        
                        if(i_locked_MMCM2_0 = '1') then --May reclock it on 12MHz
                            S_FMS_HASH_CLOCKING <= S_IDLE;
                        end if;         


                    when S_IDLE=>
                        ----------------------------------------------------
                        -- Do nothing and wait for new COMMAND or SHUTDOWN--
                        ----------------------------------------------------   

                        --Shutdown request have highest priority
                        if(r_shutdown_hash_CMD_latch = '1') then
                            r_FSM_busy                <= '1';
                            r_shutdown_hash_CMD_latch <= '0';             -- De-assert the shutdown request
                            r_final_CMD               <= (others => '0'); --triggering a shutdown is requested a 100MHz frequency.
                            --r_now_CMD                 <= r_final_CMD;-- update actual CMD in use
                            S_FMS_HASH_CLOCKING       <= S_GET_NEXT_CMD;
                         
                        --new Command requested
                        elsif(r_new_CMD_latch = '1') then
                            r_FSM_busy          <= '1';
                            r_new_CMD_latch     <= '0'; -- De-assert the command request
                            r_final_CMD         <= r_HASH_FREQUENCY_CMD;
                            --r_now_CMD           <= r_final_CMD;-- update actual CMD in use
                            S_FMS_HASH_CLOCKING <= S_GET_NEXT_CMD;
                        end if;


                    when S_GET_NEXT_CMD=>

                        r_Timeout_Flag <= '0';

                        if(r_final_CMD>r_now_CMD) then                       
                            r_now_CMD           <= r_now_CMD + '1';-- increase the command by one is final command higher than now command.
                            r_ROM_index_temp_cnt<= (others => '0');--reset ROM index counter
                            if(r_BUFGMUX_SEL= '0') then
                                r_nreset_MMCMC2_1 <= '0'; --put the MMCM2_1 in reset state if MMCM2_0 now in use.
                            else
                                r_nreset_MMCMC2_0 <= '0'; --put the MMCM2_0 in reset state if MMCM2_1 now in use.
                            end if;    
                            S_FMS_HASH_CLOCKING <= S_RD_ROM_DATA;
                        end if;

                        if(r_final_CMD<r_now_CMD) then
                            r_now_CMD           <= r_now_CMD - '1';-- decrease the command by one is final command lower than now command.
                            r_ROM_index_temp_cnt<= (others => '0');--reset ROM index counter
                            if(r_BUFGMUX_SEL= '0') then
                                r_nreset_MMCMC2_1 <= '0'; --put the MMCM2_1 in reset state if MMCM2_0 now in use.
                            else
                                r_nreset_MMCMC2_0 <= '0'; --put the MMCM2_0 in reset state if MMCM2_1 now in use.
                            end if;  
                            S_FMS_HASH_CLOCKING <= S_RD_ROM_DATA;
                        end if;

                        if(r_final_CMD=r_now_CMD) then
                            r_FSM_busy          <= '0';
                            S_FMS_HASH_CLOCKING <= S_IDLE;-- command have same value as the command now in use, nothing to do, return to idle.
                        end if;


                    when S_RD_ROM_DATA=>
                        
                        r_timeout_cnt       <= C_TIMEOUT_LOAD;--reload the timer.

                        r_ROM_en            <= '1';
                        r_ROM_addr          <= r_now_CMD & r_ROM_index_temp_cnt;
                        S_FMS_HASH_CLOCKING <= S_WAIT_ROM_DATA;


                    when S_WAIT_ROM_DATA=>
                        
                        r_ROM_en            <= '0';
                        S_FMS_HASH_CLOCKING <= S_GET_ROM_DATA;
                    

                    when S_GET_ROM_DATA =>

                        r_ROM_en              <= '0';
                        r_ROM_index_temp_cnt  <= r_ROM_index_temp_cnt + 1; --increase index counter.
                        o_DADDR_DRP           <= r_ROM_data (22 downto 16);-- Load the DRP address port
                        o_DI_DRP              <= r_ROM_data (15 downto 0); -- Load the DRP data port
                        S_FMS_HASH_CLOCKING   <= S_WR_DRP_MMCM;


                    when S_WR_DRP_MMCM =>   

                        if(r_BUFGMUX_SEL = '0') then
                            o_DEN_DRP_1 <= '1';--write MMCM2_1 DRP if MMCM2_0 now in use.
                            o_DWE_DRP_1 <= '1';
                        else
                            o_DEN_DRP_0 <= '1';--write MMCM2_0 DRP if MMCM2_1 now in use.
                            o_DWE_DRP_0 <= '1';
                        end if;        
                        S_FMS_HASH_CLOCKING <= S_WAIT_DRP_MMCM_RDY;


                    when S_WAIT_DRP_MMCM_RDY =>    
                        
                        o_DEN_DRP_0 <= '0';
                        o_DEN_DRP_1 <= '0';
                        o_DWE_DRP_0 <= '0';
                        o_DWE_DRP_1 <= '0';
                        
                        --wait MMCM2_1 DRP ready if MMCM2_0 now in use or wait MMCM2_0 DRP ready if MMCM2_1 now in use
                        if( (r_BUFGMUX_SEL='0' AND i_DRDY_DRP_1 = '1') OR (r_BUFGMUX_SEL='1' AND i_DRDY_DRP_0 = '1') )then --May need to re-clock to 12 MHz
                            r_timeout_cnt  <= C_TIMEOUT_LOAD;--reload the timer.
                            if (C_ELEMENT_TO_RD = r_ROM_index_temp_cnt) then
                                S_FMS_HASH_CLOCKING  <= S_SET_MMCM;
                            else
                                S_FMS_HASH_CLOCKING  <= S_RD_ROM_DATA;
                            end if;    
                        end if;   

                        --Timeout case. Return to idle, set timeout flag and load the now_command with last good one now in use. and 
                        if (r_timeout_cnt = X"00000") then
                            r_timeout_cnt       <= C_TIMEOUT_LOAD;--reload the timer.
                            r_now_CMD           <= r_last_CMD_latch;
                            r_Timeout_Flag      <= '1';
                            r_FSM_busy          <= '0';
                            S_FMS_HASH_CLOCKING <= S_IDLE;
                        else 
                            r_timeout_cnt       <= r_timeout_cnt - 1 ;   
                        end if;


                    when S_SET_MMCM =>    
                        
                        r_timeout_cnt  <= C_TIMEOUT_LOAD;--reload the timer.
                        if(r_BUFGMUX_SEL='0') then
                            r_nreset_MMCMC2_1 <= '1';--set MMCM2_1 if MMCM2_0 now in use.
                        else
                            r_nreset_MMCMC2_0 <= '1';--set MMCM2_0 if MMCM2_1 now in use.
                        end if;
                            
                        S_FMS_HASH_CLOCKING  <= S_WAIT_MMCM_LOCK;


                    when S_WAIT_MMCM_LOCK =>  

                        if(r_BUFGMUX_SEL='0' AND r_locked_MMCM2_1 = '1') then 
                            r_BUFGMUX_SEL        <= '1';--switch output to MMCM2_1 once MMCM2_1 locked.
                            r_last_CMD_latch     <= r_now_CMD; --latching last working command
                            S_FMS_HASH_CLOCKING  <= S_COOLDOWN_TIME;
                        end if;

                        if(r_BUFGMUX_SEL='1' AND r_locked_MMCM2_0 = '1') then 
                            r_BUFGMUX_SEL        <= '0';--switch output to MMCM2_0 once MMCM0 locked.
                            r_last_CMD_latch     <= r_now_CMD; --latching last working command
                            S_FMS_HASH_CLOCKING  <= S_COOLDOWN_TIME;
                        end if;


                        --Timeout case. Return to idle, set timeout flag and load the now_command with last good one now in use. and 
                        if (r_timeout_cnt = X"00000") then
                            r_timeout_cnt       <= C_TIMEOUT_LOAD;--reload the timer.
                            r_now_CMD           <= r_last_CMD_latch;
                            r_Timeout_Flag      <= '1';
                            r_FSM_busy          <= '0';
                            S_FMS_HASH_CLOCKING <= S_IDLE;
                        else
                            r_timeout_cnt       <= r_timeout_cnt - 1 ;    
                        end if;


                    when S_COOLDOWN_TIME =>
                        
                        r_timeout_cnt <= C_TIMEOUT_LOAD;--reload the timer.
                        if(SIMULATION = true) then
                            if(r_cooldown_cnt = (C_COOLDOWN_LOAD-10) ) then--short cooldown time of 1.0.us for simulation. 
                                S_FMS_HASH_CLOCKING  <= S_GET_NEXT_CMD;
                                r_cooldown_cnt       <=  C_COOLDOWN_LOAD;
                            else
                                r_cooldown_cnt       <= r_cooldown_cnt - '1';    
                            end if;
                        
                        else--Cooldown time is set at 150us (12MHz*2048) in hardware
                            if(r_cooldown_cnt = X"00000" ) then   
                                S_FMS_HASH_CLOCKING  <= S_GET_NEXT_CMD;
                                r_cooldown_cnt       <= C_COOLDOWN_LOAD;
                            else
                                r_cooldown_cnt       <= r_cooldown_cnt - '1'; 
                            end if;                    
                        End if;    

                    when others =>

                        r_ROM_en                    <= '0';
                        r_ROM_addr                  <= (others => '0');
         
                        r_HASH_FREQUENCY_TRIGZ      <= '0'; 
                        r_new_CMD_latch             <= '0';
                        r_HASH_FREQUENCY_CMD        <= (others => '0')    ; --default is 0 (100MHZ) 0x3C is 400MHz
                        r_last_CMD_latch            <= r_last_CMD_latch   ; --default is 0 (100MHZ)
                        r_now_CMD                   <= r_now_CMD          ; --default is 0 (100MHZ)
                        r_final_CMD                 <= r_final_CMD        ; --default is 0 (100MHZ)

                        r_shutdown_hash_CMDZ        <= '0';
                        r_shutdown_hash_CMD_latch   <= '0';

                        r_ROM_index_temp_cnt        <= (others => '0');
      
                        r_BUFGMUX_SEL               <= r_BUFGMUX_SEL;
                 
                        r_nreset_MMCMC2_0            <= '1';
                        r_nreset_MMCMC2_1            <= '1';
                 
                        o_DEN_DRP_0                 <= '0';
                        o_DEN_DRP_1                 <= '0';
                 
                        o_DWE_DRP_0                 <= '0';
                        o_DWE_DRP_1                 <= '0';
                 
                        o_DADDR_DRP                 <= (others => '0');                    
                        o_DI_DRP                    <= (others => '0');             
                 
                        r_cooldown_cnt              <= C_COOLDOWN_LOAD;
      
                        r_timeout_cnt               <= C_TIMEOUT_LOAD;
                        r_Timeout_Flag              <= '0';

                        r_FSM_busy                  <= '0';
      
                        S_FMS_HASH_CLOCKING         <= S_IDLE;

                end case;    
            end if;
        end if;
    end process; 


    --Assigning output ports signals
    o_CLK_FSM_BUSY    <= r_FSM_busy;

    o_BUFGMUX_SEL     <= r_BUFGMUX_SEL;

    o_nreset_MMCMC2_0 <= r_nreset_MMCMC2_0;
    o_nreset_MMCMC2_1 <= r_nreset_MMCMC2_1;   

    --Status register feedback
    o_HASH_CLK_status(15)          <= '0';--reserved
    o_HASH_CLK_status(14)          <= r_BUFGMUX_SEL;
    o_HASH_CLK_status(13)          <= r_Timeout_Flag;
    o_HASH_CLK_status(12)          <= r_FSM_busy;
    o_HASH_CLK_status(11 downto 4) <= r_now_CMD;
    o_HASH_CLK_status(3)           <= r_locked_MMCM2_1;
    o_HASH_CLK_status(2)           <= r_nreset_MMCMC2_1;
    o_HASH_CLK_status(1)           <= r_locked_MMCM2_0;
    o_HASH_CLK_status(0)           <= r_nreset_MMCMC2_0;


    
end architecture CLOCK_HASH_FSM_MODULE_arch;