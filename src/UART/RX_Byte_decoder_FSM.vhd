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


entity RX_Byte_decoder_FSM is
    port(
        i_CLK_12M             : in std_logic;
        i_SYNCED_nRST_12M     : in std_logic;
    	----------------------
        i_RX_valid            : in std_logic;
        i_data                : in std_logic_vector(7 downto 0);
    	----------------------
        o_wr_data_RX          : out std_logic_vector(767 downto 0);
		o_wr_en_RX            : out std_logic;
    
		o_trig_toggle_12M     : out std_logic;
		----------------------
		o_HASH_FREQUENCY_TRIG : out std_logic;
		o_HASH_FREQUENCY_CMD  : out std_logic_vector(7 downto 0);
		----------------------
		o_info_ROM_trig       : out std_logic
    );
end;



architecture RX_Byte_decoder_FSM_arch of RX_Byte_decoder_FSM is
    
    ----RX FSM signals
    TYPE s_state_RX is (IDLE_RX, START_RX, WAIT_BYTE_RX, WR_MEM_RX, END_MESSAGE_RX);
    signal   s_current_state_RX      : s_state_RX := IDLE_RX;
    signal   r_wr_data_RX            : std_logic_vector(767 downto 0);
    signal   r_wr_en_RX              : std_logic;
    signal   r_byte_index_RX         : std_logic_vector(6 downto 0);--need go up to 96
    signal   r_trig_toggle_12M       : std_logic;
    constant c_MESSAGE_SIZE_RX       : integer := 95;--RX Message is 96 bytes.

    signal   r_HASH_FREQUENCY_TRIG   :  std_logic;
    signal   r_HASH_FREQUENCY_CMD    :  std_logic_vector(7 downto 0);

    signal   r_info_ROM_trig  	     :  std_logic;

begin
 --Receive message FSM and write memory
    process(i_CLK_12M)
    begin
        if (i_CLK_12M'event and i_CLK_12M='1') then
            
            if(i_SYNCED_nRST_12M = '0')then
                s_current_state_RX <= IDLE_RX;

                r_wr_data_RX      <= (others => '0');
                r_wr_en_RX        <= '0';

                r_byte_index_RX   <= (others => '0');

                r_trig_toggle_12M <= '0';

                r_HASH_FREQUENCY_TRIG <= '0';
                r_HASH_FREQUENCY_CMD  <= (others => '0');

                r_info_ROM_trig  	  <= '0';

            else
                
                case s_current_state_RX is
                    
                    when IDLE_RX =>
                        s_current_state_RX <= IDLE_RX;
                        r_wr_data_RX       <= (others => '0');
                        r_wr_en_RX         <= '0';
                        r_byte_index_RX    <= (others => '0');

                        r_info_ROM_trig    <= '0';
                        
                        if(i_RX_valid = '1') then
                            r_wr_data_RX            <= r_wr_data_RX(759 downto 0) & i_data;
                            r_wr_en_RX              <= '0';
                            r_byte_index_RX         <= (others => '0') ;
                            s_current_state_RX      <= WR_MEM_RX;
                        end if;

                        r_HASH_FREQUENCY_TRIG <= '0';
                    

                    when WR_MEM_RX =>
                        r_wr_en_RX           <= '0';
                        s_current_state_RX   <= WAIT_BYTE_RX;        

                    when WAIT_BYTE_RX =>
                        r_wr_en_RX  <= '0';
                        
                        if(r_byte_index_RX = c_MESSAGE_SIZE_RX) then
                             s_current_state_RX <= END_MESSAGE_RX;
                        
                        elsif (i_RX_valid = '1') then
                            r_wr_data_RX        <= r_wr_data_RX(759 downto 0) & i_data;
                            r_wr_en_RX          <= '0';
                            r_byte_index_RX     <= r_byte_index_RX + 1 ;
                            s_current_state_RX  <= WR_MEM_RX;
                        end if;     

                    when END_MESSAGE_RX =>  
                        --address decoding
                        if(r_wr_data_RX(0) = '1') then--hitting message header trigger.   
                        	r_wr_en_RX         <= '1';
                        	r_trig_toggle_12M  <= not r_trig_toggle_12M;   
                        end if;

                        --address decoding
                        if(r_wr_data_RX(0) = '0') then--hitting readback info.
							r_info_ROM_trig  <= '1';
                        end if; 

                        --address decoding
                        if(r_wr_data_RX(1) = '1') then--hitting new Frequency command trigger.
                            r_HASH_FREQUENCY_TRIG <= '1';
                            r_HASH_FREQUENCY_CMD  <= r_wr_data_RX(39 downto 32);
                        end if;     

                        r_byte_index_RX    <= (others => '0');      
                        s_current_state_RX <= IDLE_RX;


                    when others =>
                        
                        s_current_state_RX    <= IDLE_RX;
                        r_wr_data_RX          <= (others => '0');
                        r_wr_en_RX            <= '0';
                        r_byte_index_RX       <= (others => '0');

                        r_HASH_FREQUENCY_TRIG <= '0';
                        r_HASH_FREQUENCY_CMD  <= (others => '0');
                        r_info_ROM_trig  	  <= '0';

                end case;
            end if;       
        end if;
    end process;




    o_wr_data_RX          <= r_wr_data_RX          ;
	o_wr_en_RX            <= r_wr_en_RX            ;
	o_trig_toggle_12M     <= r_trig_toggle_12M     ;
	--------------------------------------------
	o_HASH_FREQUENCY_TRIG <= r_HASH_FREQUENCY_TRIG ;
	o_HASH_FREQUENCY_CMD  <= r_HASH_FREQUENCY_CMD  ;

	o_info_ROM_trig       <= r_info_ROM_trig       ;


end;