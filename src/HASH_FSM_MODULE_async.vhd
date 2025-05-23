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


entity HASH_FSM_MODULE is
    Port (
        i_CLK_12M              : in  std_logic;      
        i_SYNCED_nRST_12M      : in std_logic ;
        i_SYNCED_nRST_500M     : in std_logic ;  
          
        o_rd_en_RX             : out std_logic;
        i_rd_data_RX           : in  std_logic_vector(767 downto 0);
        i_trig_toggle_RX       : in  std_logic;  
  
        o_wr_en_TX             : out std_logic;
        o_wr_data_TX           : out std_logic_vector(319 downto 0);
        o_trig_toggle_TX       : out std_logic;

        o_header_in_chunk      : out std_logic_vector ( (BLOCK_HEADER_CHUNK_WIDTH-1) downto 0);
        o_header_wr_en         : out std_logic ;
        o_HASH_gating          : out std_logic ;

        
        i_valid_out            : in std_logic;
        i_GoldenTicket_core    : in bit_bus_type;
        i_GoldenNonce_core     : in header64_bus_type

    );
end entity;



architecture arch of HASH_FSM_MODULE is

    --Hashing control FSM signals
    TYPE s_state_HASH is (IDLE_HASH, CMD_RD_MEM_RX, RD_MEM_RX, RD_MEM_RX_WAIT, PRE_SCAN_NONCE, SCAN_NONCE, --START_HASH, 
                            GET_GOLDEN_NONCE, PRE_WR_MEM_TX, WR_MEM_TX);
    
    -- --Simulation signals-----------------------------------------------                                                                                                                         
    TYPE ram_type is array (0 to 1) of std_logic_vector(767 downto 0);                                                                                                                --000000008f0cfd12000000000000000000000000
    signal RAM : ram_type :=( X"6b0d13638877fe9389f4d3287414b3d8189a1d04e6954168f0b467cd31773984363b5534fb8b5f615583c7329c9ca8ce6edaf6e6886c60378dc18856d5defa5c378a882365ed73a4e1f04262000000008f0cf000FFFFFFFF8000000000000000",
                              X"000000200b239efca9b8056bc74e4d1fc68ff592f237ca0dbc392d5b6603000000000000d28c22eb00cbf0777a8f99ddc9c8bc452fd53beecba5a7290cdb4a48f5e375def4dbb35fbbb60e1a617c9ab0CCCCCCCC00000000CCCCCCCCCCCCCCCC");
    ------------------------------------------------------------------


    signal   s_current_state_HASH       : s_state_HASH := IDLE_HASH;
    signal   r_rd_en_RX                 : std_logic;
      
    signal   r_wr_data_TX               : std_logic_vector ( 319 downto 0);
    signal   r_wr_en_TX                 : std_logic;

    signal   r_trig_toggle_RX_Z         : std_logic;

    signal   r_block_header_chunk_index : std_logic_vector (3 downto 0);
    signal   r_header_in_chunk       : std_logic_vector ( (BLOCK_HEADER_CHUNK_WIDTH-1) downto 0);
    signal   r_padded_block_header      : std_logic_vector ( 639 downto 0);--32 bits added for 0 padding and be a 62-Bits multipliers.

    signal   r_nonce                    : std_logic_vector ( 63  downto 0);
      
    signal   r_header_wr_en                  : std_logic ;
    signal   r_HASH_gating              : std_logic ;
      
    signal   r_golden_nonce             : std_logic_vector ( 63  downto 0);
    signal   r_golden_nonce_Z           : std_logic_vector ( 63  downto 0);
    signal   r_golden_nonce_REG         : std_logic_vector ( 63  downto 0);
    --signal   r_golden_nonce_REG_Z       : std_logic_vector ( 63  downto 0);
      
    signal   r_valid_outZ               : std_logic ;

    signal   r_trig_toggle_TX           : std_logic;



begin
-------HASHING FSM---------------------------------
    utt_Hashing_FSM: process(i_CLK_12M)
    begin        
        if (i_CLK_12M'event AND i_CLK_12M='1') then
            if(i_SYNCED_nRST_12M='0')then
                s_current_state_HASH       <=  IDLE_HASH        ;--: s_state_HASH := IDLE_HASH;
                r_rd_en_RX                 <=  '0'              ;--: std_logic;
                r_wr_data_TX               <=  (others => '0')  ;--: std_logic_vector ( 319 downto 0);
                r_wr_en_TX                 <=  '0'              ;--: std_logic;
               
                r_trig_toggle_RX_Z         <=  '0';
                
                r_block_header_chunk_index <=  (others => '0')  ;
                r_header_in_chunk          <=  (others => '0')  ;
                r_padded_block_header      <=  (others => '0')  ; 

                r_nonce                    <=  (others => '0')  ;--: std_logic_vector ( 63  downto 0);
                r_header_wr_en                  <=  '0'              ;--: std_logic ;
                r_HASH_gating              <=  '0'              ;
                
                r_golden_nonce             <=  (others => '0')  ;
                r_golden_nonce_Z           <=  (others => '0')  ;
                r_golden_nonce_REG         <=  (others => '0')  ;

                r_trig_toggle_TX           <=  '0'              ;--: std_logic;
                r_valid_outZ               <=  '1'              ;--1 to trigger the FSM on simulation.
            else

                --refrech the header and r_nonce when a new message is received or first message is recaived.
                r_rd_en_RX         <= '1' ;
                r_valid_outZ       <= i_valid_out;     
                r_trig_toggle_RX_Z <= i_trig_toggle_RX;         
                
                case s_current_state_HASH is
                    when IDLE_HASH =>
                        s_current_state_HASH       <=  IDLE_HASH        ;

                        r_wr_data_TX               <=  (others => '0')  ;
                        r_wr_en_TX                 <=  '0'              ;
                        
                        r_block_header_chunk_index <=  (others => '0')  ;
                        r_header_in_chunk          <=  (others => '0')  ;
                        r_padded_block_header      <=  (others => '0')  ; 

                        r_nonce                    <=  (others => '0')  ;

                        r_header_wr_en             <=  '0'              ;
                        r_HASH_gating              <=  '0'              ;

                        r_golden_nonce             <=  (others => '0')  ;
                        r_golden_nonce_Z           <=  (others => '0')  ;
                        r_golden_nonce_REG         <=  (others => '0')  ;         

                        --------------------------------------------------------
                        if (SIMULATION = false) then
                            if( r_trig_toggle_RX_Z /= i_trig_toggle_RX) then--
                                s_current_state_HASH  <=  RD_MEM_RX   ;
                                --r_rd_en_RX          <=  '1'              ;
                                r_wr_data_TX          <=  (others => '0')  ;
                                r_wr_en_TX            <=  '0'              ;
                                r_header_wr_en        <=  '0'              ;
                            end if;
                        end if;
                        --------------------------------------------------------
                        if (SIMULATION = true) then 
                            if (i_SYNCED_nRST_500M='1') then
                                s_current_state_HASH  <=  RD_MEM_RX        ;
                                --r_rd_en_RX          <=  '1'              ;
                                r_wr_data_TX          <=  (others => '0')  ;
                                r_wr_en_TX            <=  '0'              ;
                                r_header_wr_en        <=  '0'              ;
                            end if;
                        end if;    
                        --------------------------------------------------------

                    when CMD_RD_MEM_RX => 
                        s_current_state_HASH  <=  RD_MEM_RX_WAIT   ;
                        --r_rd_en_RX          <=  '1'              ;
                        r_wr_data_TX          <=  (others => '0')  ;
                        r_wr_en_TX            <=  '0'              ;
                        r_header_wr_en        <=  '0'              ;
                        r_HASH_gating         <=  '0'              ;

                    when RD_MEM_RX_WAIT => 
                        s_current_state_HASH  <=  RD_MEM_RX        ;
                        --r_rd_en_RX          <=  '1'              ;
                        r_wr_data_TX          <=  (others => '0')  ;
                        r_wr_en_TX            <=  '0'              ;
                        r_header_wr_en             <=  '0'              ;
                        r_HASH_gating         <=  '0'              ;

                    when RD_MEM_RX =>    
                        s_current_state_HASH  <=  PRE_SCAN_NONCE   ;
                        --r_rd_en_RX          <=  '0'              ;
                        r_wr_data_TX          <=  (others => '0')  ;
                        r_wr_en_TX            <=  '0'              ;
                       -- ----------------------------------------------------
                        -----------------------------------------------------Simulation case-----------------------------------------------------------------------------
                        if (SIMULATION = true) then 
                            r_padded_block_header                                <=  X"00000000" & RAM(0)(767 downto 160);
                            r_nonce                                              <=  RAM(0)(159 downto 96);
                            --r_nonce((NB_CORE_MAX_BIT_LENGTH-1) downto 0)       <=  std_logic_vector(to_unsigned(NB_CORE_MAX,NB_CORE_MAX_BIT_LENGTH));
                            r_nonce((NB_CORE_MAX_BIT_LENGTH-1) downto 0)         <=  (others => '0');
                            r_golden_nonce                                       <=  RAM(0)(159 downto 96);
                            --r_golden_nonce((NB_CORE_MAX_BIT_LENGTH-1) downto 0)<=  std_logic_vector(to_unsigned(NB_CORE_MAX,NB_CORE_MAX_BIT_LENGTH));
                            r_golden_nonce((NB_CORE_MAX_BIT_LENGTH-1) downto 0)  <=  (others => '0');
                            r_golden_nonce_Z                                     <=  RAM(0)(159 downto 96);
                            --r_golden_nonce_Z((NB_CORE_MAX_BIT_LENGTH-1) downto 0)<=  std_logic_vector(to_unsigned(NB_CORE_MAX,NB_CORE_MAX_BIT_LENGTH));
                            r_golden_nonce_Z((NB_CORE_MAX_BIT_LENGTH-1) downto 0)<=  (others => '0');

                        end if;     
                        --------------------------------------------------------Synthesys case-----------------------------------------------------------------------------
                        if (SIMULATION = false) then   
                            r_padded_block_header                                <=  X"00000000" & i_rd_data_RX (767 downto 160);
                            r_nonce                                              <=  i_rd_data_RX (159 downto 96 );
                            --r_nonce((NB_CORE_MAX_BIT_LENGTH-1) downto 0)       <=  std_logic_vector(to_unsigned(NB_CORE_MAX,NB_CORE_MAX_BIT_LENGTH));
                            r_nonce((NB_CORE_MAX_BIT_LENGTH-1) downto 0)         <=  (others => '0');
                            r_golden_nonce                                       <=  i_rd_data_RX(159 downto 96);
                            --r_golden_nonce((NB_CORE_MAX_BIT_LENGTH-1) downto 0)<=  std_logic_vector(to_unsigned(NB_CORE_MAX,NB_CORE_MAX_BIT_LENGTH));
                            r_golden_nonce((NB_CORE_MAX_BIT_LENGTH-1) downto 0)  <=  (others => '0');
                            r_golden_nonce_Z                                     <=  i_rd_data_RX(159 downto 96);
                            --r_golden_nonce_Z((NB_CORE_MAX_BIT_LENGTH-1) downto 0)<=  std_logic_vector(to_unsigned(NB_CORE_MAX,NB_CORE_MAX_BIT_LENGTH));
                            r_golden_nonce_Z((NB_CORE_MAX_BIT_LENGTH-1) downto 0)<=  (others => '0');
 
                        end if;            
                        --------------------------------------------------------------------------------------------------------------------------------------------------   

                        r_header_wr_en        <=  '0'              ;
                        r_HASH_gating         <=  '0'              ;
                    

                    when PRE_SCAN_NONCE => 

                        --parametrable bus Shift register for sending the block header to the different Hash core.
                        r_block_header_chunk_index <= r_block_header_chunk_index+1;
                        r_header_in_chunk          <= r_padded_block_header(r_padded_block_header'high downto (r_padded_block_header'high - BLOCK_HEADER_CHUNK_WIDTH+1 ) );
                        r_padded_block_header      <= r_padded_block_header( (r_padded_block_header'high - BLOCK_HEADER_CHUNK_WIDTH) downto 0) & ( std_logic_vector(to_unsigned(0,BLOCK_HEADER_CHUNK_WIDTH)) );
                        
                        r_header_wr_en             <=  '1'         ;
                        r_HASH_gating              <=  '0'         ;

                        if r_block_header_chunk_index =  std_logic_vector(to_unsigned((BLOCK_HEADER_CHUNK_SIZE-1), 4) ) then
                            r_header_in_chunk       <= r_nonce;

                            r_header_wr_en             <=  '1'            ;
                            r_HASH_gating              <=  '1'            ;
                            r_block_header_chunk_index <=  (others => '0');

                            s_current_state_HASH       <=  SCAN_NONCE     ;

                        end if; 


                    when SCAN_NONCE =>
                        
                        s_current_state_HASH <= SCAN_NONCE;
                        r_header_wr_en  <= '0';
                        ----------------------------------------------------------
                        if (SIMULATION = true) then 
                            if (r_valid_outZ='1' AND i_valid_out='0') then
                                s_current_state_HASH <= RD_MEM_RX;
                            end if;
                        end if;    
                        ----------------------------------------------------------
                        if (SIMULATION = false) then   
                           if( i_trig_toggle_RX /= r_trig_toggle_RX_Z) then
                                s_current_state_HASH <= RD_MEM_RX;
                            end if;
                        end if;  
                        ----------------------------------------------------------
                        --r_header_in_chunk(63 downto NB_CORE_MAX_BIT_LENGTH) <= r_nonce(63 downto NB_CORE_MAX_BIT_LENGTH) + 1; --nonceZ++
                        
                        --r_nonce(63 downto NB_CORE_MAX_BIT_LENGTH) <= r_nonce(63 downto NB_CORE_MAX_BIT_LENGTH) + 1; --nonce++
                        
                        for I in 0 to (NB_CORE-1) loop
                            if( i_GoldenTicket_core(I) = '1') then
                                s_current_state_HASH  <= GET_GOLDEN_NONCE;
                                r_golden_nonce_Z      <= i_GoldenNonce_core(I);
                                --r_golden_nonce_Z( (NB_CORE_MAX_BIT_LENGTH-1) downto 0 ) <= std_logic_vector(to_unsigned(I, NB_CORE_MAX_BIT_LENGTH));
                                r_header_wr_en        <= '0';
                                r_HASH_gating         <= '0';
                            end if;    
                        end loop;
                       
                        --for I in 0 to (NB_CORE-2) loop -- -2 because last core is win be default.
                        --    if(i_GoldenTicket_core(I) = '1') then
                        --        r_golden_nonce_Z( (NB_CORE_MAX_BIT_LENGTH-1) downto 0 )  <= std_logic_vector(to_unsigned(I, NB_CORE_MAX_BIT_LENGTH));
                        --    end if;
                        --end loop;

                        --if (i_valid_out = '1') then
                        --    r_golden_nonce  (63 downto NB_CORE_MAX_BIT_LENGTH) <= r_golden_nonce(63 downto NB_CORE_MAX_BIT_LENGTH) + 1;
                        --    r_golden_nonce_Z(63 downto NB_CORE_MAX_BIT_LENGTH) <= r_golden_nonce(63 downto NB_CORE_MAX_BIT_LENGTH);
                        --end if;   

                         r_wr_en_TX <= '0'; 


                    when GET_GOLDEN_NONCE =>
                        
                        s_current_state_HASH <= PRE_WR_MEM_TX;
                        r_golden_nonce_REG   <= r_golden_nonce_Z;

                                        
                    when PRE_WR_MEM_TX =>
                        
                        s_current_state_HASH <= WR_MEM_TX; 
                        --Give the data to the memory one clock cycle earlier then WE for high speed.
                        r_wr_data_TX         <= X"00000000_00000000_00000000_00000000_00000000_00000000_00000000_00000000" &
                                                r_golden_nonce_REG;                      


                    when WR_MEM_TX  =>
                        if (SIMULATION = false) then
                            s_current_state_HASH  <=  SCAN_NONCE    ;
                        end if;    
                        if (SIMULATION = true) then
                            s_current_state_HASH  <=  IDLE_HASH    ;
                        end if; 
                        
                        r_HASH_gating         <= '1';

                        r_wr_en_TX            <= '1';

                        r_trig_toggle_TX      <=  not r_trig_toggle_TX;

                    
                    when others =>

                        s_current_state_HASH       <=  IDLE_HASH        ;
                        r_rd_en_RX                 <=  '0'              ;
                        r_wr_data_TX               <=  (others => '0')  ;
                        r_wr_en_TX                 <=  '0'              ;
                        r_block_header_chunk_index <=  (others => '0')  ;
                        r_header_in_chunk          <=  (others => '0')  ;
                        r_padded_block_header      <=  (others => '0')  ; 
                        r_nonce                    <=  (others => '0')  ;
                        r_header_wr_en                  <=  '0'              ;
                        r_HASH_gating              <=  '0'              ;
                        r_golden_nonce             <=  (others => '0')  ;
                        r_golden_nonce_Z           <=  (others => '0')  ;
                        r_golden_nonce_REG         <=  (others => '0')  ;

                        r_trig_toggle_TX           <=  '0'              ;
                end case; 
            end if;       
        end if;
    end process;

    o_rd_en_RX             <= r_rd_en_RX          ;
    o_wr_en_TX             <= r_wr_en_TX          ;
    o_wr_data_TX           <= r_wr_data_TX        ;
    o_trig_toggle_TX       <= r_trig_toggle_TX    ;
    o_header_in_chunk      <= r_header_in_chunk;
    o_header_wr_en         <= r_header_wr_en           ;
    o_HASH_gating          <= r_HASH_gating       ;

end architecture;