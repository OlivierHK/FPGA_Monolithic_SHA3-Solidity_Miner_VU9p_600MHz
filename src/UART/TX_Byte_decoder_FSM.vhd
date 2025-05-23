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


entity TX_Byte_decoder_FSM is
    port(
        i_CLK_12M             : in std_logic;
        i_SYNCED_nRST_12M     : in std_logic;
    	----------------------
        o_byte_trig_TX        : out std_logic;
        o_byte_data_TX        : out std_logic_vector(7 downto 0);
        i_din_vld             : in std_logic;--
    	----------------------
        i_rd_data_TX          : in std_logic_vector(319 downto 0);--
		o_rd_en_TX            : out std_logic;--
        o_rd_addr_TX          : out std_logic_vector(  0 downto 0);
  
		i_trig_toggle_12M_TX  : in std_logic;

        i_info_ROM_trig       : in  std_logic;

        i_status_bus          : in  std_logic_vector(38 downto 0)
        --i_trig_toggle_12M_TX_ZZ      : in std_logic;
        --i_trig_toggle_12M_TX_ZZZ     : in std_logic
		----------------------
    );
end;



architecture TX_Byte_decoder_FSM_arch of TX_Byte_decoder_FSM is
    
    --TX FSM signals
    TYPE s_state_TX is (IDLE_TX, CMD_RD_MEM_TX, CMD_RD_MEM_TX_WAIT, RD_MEM_TX, START_TX, WAIT_START_TX, WAIT_BYTE_TX, END_MESSAGE_TX);
    signal   s_current_state_TX  : s_state_TX := IDLE_TX;
    signal   r_rd_data_TX_buff   : std_logic_vector (319 downto 0 );
    signal   r_rd_en_TX          : std_logic;
    signal   r_rd_addr_TX        : std_logic_vector (  0 downto 0 );

    signal   r_byte_index_TX     : std_logic_vector (  5 downto 0);--need go up to 40
    signal   r_byte_data_TX      : std_logic_vector (  7 downto 0);
    signal   r_byte_trig_TX      : std_logic;
    constant c_MESSAGE_SIZE_TX   : integer := 40;--RX Message is 40 bytes.

    signal r_trig_toggle_12M_TX_Z: std_logic;

    signal r_alarm_flag_latch     : std_logic_vector(4 downto 0);


begin
 --Send message FSM.
    process(i_CLK_12M)
    begin
        if (i_CLK_12M'event and i_CLK_12M='1') then
            if(i_SYNCED_nRST_12M = '0')then
                s_current_state_TX     <= IDLE_TX;
                r_rd_data_TX_buff      <= (others => '0');
                r_rd_en_TX             <= '0';
                r_rd_addr_TX           <= (others => '0');
                r_byte_index_TX        <= (others => '0');
                r_byte_data_TX         <= (others => '0');
                r_byte_trig_TX         <= '0';

                r_trig_toggle_12M_TX_Z <= '0';

                r_alarm_flag_latch       <= (others => '0');
            else
                r_trig_toggle_12M_TX_Z <= i_trig_toggle_12M_TX;

                --latching alarm flag
                if   (i_status_bus(6) ='1')then
                    r_alarm_flag_latch(4)<='1';
                elsif(i_status_bus(5) ='1') then
                    r_alarm_flag_latch(3)<='1';
                elsif(i_status_bus(4) ='1') then
                    r_alarm_flag_latch(2)<='1';
                elsif(i_status_bus(3) ='1') then
                    r_alarm_flag_latch(1)<='1';
                elsif(i_status_bus(2) ='1') then
                    r_alarm_flag_latch(0)<='1';
                end if; 




                case s_current_state_TX is
                    when IDLE_TX =>
                        s_current_state_TX <= IDLE_TX;
                        r_rd_data_TX_buff  <= (others => '0');
                        r_rd_en_TX         <= '0';
                        r_byte_index_TX    <= (others => '0');
                        r_byte_data_TX     <= (others => '0');
                        r_byte_trig_TX     <= '0';
                        
                        if(r_trig_toggle_12M_TX_Z /= i_trig_toggle_12M_TX) then
                            r_rd_en_TX           <= '1';
                            r_rd_addr_TX         <= (others => '0');
                            s_current_state_TX   <= CMD_RD_MEM_TX;
                        end if;

                        if (i_info_ROM_trig ='1') then
                            r_rd_en_TX           <= '1';
                            r_rd_addr_TX         <= (others => '1');
                            s_current_state_TX   <= CMD_RD_MEM_TX;
                        end if;
                    
                    when CMD_RD_MEM_TX =>
                        r_rd_en_TX           <= '1';
                        s_current_state_TX   <= CMD_RD_MEM_TX_WAIT;

                    when CMD_RD_MEM_TX_WAIT =>
                        r_rd_en_TX           <= '0';
                        s_current_state_TX   <= RD_MEM_TX;
                    
                    when RD_MEM_TX =>
                        --r_rd_en_TX       <= '0';
                        if r_rd_addr_TX(0) = '0' then
                            r_rd_data_TX_buff(319 downto 288)  <= i_status_bus(38  downto 7);--clock status
                            r_rd_data_TX_buff(287 downto 283)  <= r_alarm_flag_latch;        --alarm latch
                            r_rd_data_TX_buff(282 downto 281)  <= i_status_bus(1   downto 0);--Hash enable and 500MHZ reset.

                            r_rd_data_TX_buff(280 downto   0)  <= i_rd_data_TX(280 downto 0);--nonce

                            r_alarm_flag_latch <= (others => '0');--reset alarm latch as will be sent.

                        else
                            r_rd_data_TX_buff  <= i_rd_data_TX;
                        end if;    
                        s_current_state_TX <= START_TX;

                    when START_TX =>
                        r_byte_trig_TX     <= '1';
                        r_byte_data_TX     <= r_rd_data_TX_buff(319 downto 312);
                        r_rd_data_TX_buff  <= r_rd_data_TX_buff(311 downto 0) & X"00";
                        r_byte_index_TX    <= r_byte_index_TX + 1;
                        s_current_state_TX <= WAIT_START_TX;        

                    when WAIT_START_TX =>
                        r_byte_trig_TX     <= '0';
                        s_current_state_TX <= WAIT_BYTE_TX;

                    when WAIT_BYTE_TX =>
                        r_byte_trig_TX    <= '0';
                        if (i_din_vld = '1') then

                            if(r_byte_index_TX = c_MESSAGE_SIZE_TX) then
                                s_current_state_TX <= END_MESSAGE_TX;
                            else
                                s_current_state_TX <= START_TX; 
                            end if;               
                        end if;     

                    when END_MESSAGE_TX =>  
                        s_current_state_TX     <= IDLE_TX;
                        r_rd_data_TX_buff      <= (others => '0');
                        r_rd_en_TX             <= '0';
                        r_byte_index_TX        <= (others => '0');
                        r_byte_data_TX         <= (others => '0');
                        r_byte_trig_TX         <= '0';   

                    when others =>
                        s_current_state_TX     <= IDLE_TX;
                        r_rd_data_TX_buff      <= (others => '0');
                        r_rd_en_TX             <= '0';
                        r_rd_addr_TX           <= (others => '0');
                        r_byte_index_TX        <= (others => '0');
                        r_byte_data_TX         <= (others => '0');
                        r_byte_trig_TX         <= '0';  

                        r_trig_toggle_12M_TX_Z <= '0';

                        r_alarm_flag_latch       <= (others => '0');
                end case;   
            end if;    
        end if;
    end process; 


    o_byte_trig_TX <= r_byte_trig_TX  ;
    o_byte_data_TX <= r_byte_data_TX  ;
    o_rd_en_TX     <= r_rd_en_TX      ;
    o_rd_addr_TX   <= r_rd_addr_TX    ;


end;