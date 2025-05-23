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

use work.MyPackage.all;


entity SHA3_Solidity_core is
generic(
      	CORE_ID             : integer := 0      
	);   

port(
		i_SYNCED_nRST_12M   : in std_logic ;                      -- Reset signal (active high).
	    i_SYNCED_nRST_500M  : in std_logic ;                      -- Reset signal (active high).
        i_CLK_12M           : in std_logic ;                      -- clock signal
        i_CLK_500M          : in std_logic ;                      -- clock signal

		---------------------
		i_header_wr_en      : in std_logic ;                      -- wr enable signal(active high).
		i_gate              : in std_logic ;                      -- ignored, for SHA3 and variant.
		i_header_in_chunk   : in std_logic_vector( (BLOCK_HEADER_CHUNK_WIDTH-1) downto 0) ; -- heading in.
		----------------------
		o_valid             : out std_logic ;                     -- valid signal(active high).
		o_Golden_Ticket     : out std_logic ;
		o_Golden_Nonce      : out std_logic_vector(63 downto 0) ;-- golden nonce out.
		----------------------
		----------------------
		DEBUG_port_in  		: in  std_logic_vector(31 downto 0) ; --
		DEBUG_port_out 		: out std_logic_vector(31 downto 0)   -- DEBUG port
	);
end SHA3_Solidity_core;


architecture arch of SHA3_Solidity_core is

	attribute ASYNC_REG : string                                     ;

	signal r_header_in_chunk        : std_logic_vector ((BLOCK_HEADER_CHUNK_WIDTH-1) downto 0);
	signal r_header_wr_en           : std_logic ; 
        
	signal r_header_in_12M          : std_logic_vector (671 downto 0);
	        
	signal r_header_in_500M         : std_logic_vector (671 downto 0);  
	attribute ASYNC_REG of r_header_in_500M : signal is "TRUE"  ;--the first reg receive the data as ASYNC
	signal r_header_in              : std_logic_vector (671 downto 0);

	signal r_golden_nonce_init_12M  : std_logic_vector (63  downto 0);
	signal r_golden_nonce_init_500M : std_logic_vector (63  downto 0);
	attribute ASYNC_REG of r_golden_nonce_init_500M : signal is "TRUE"  ;--the first reg receive the data as ASYNC
	

	component keccak_round_ppl
	port (	  
		clk	  : in std_logic;
		------------------------------------------
		en    : in std_logic;
		gate  : in std_logic;
	    rin   : in std_logic_vector(1599 downto 0);
	    rc	  : in std_logic_vector(63 downto 0);
	    -------------------------------------------
	    valid : out std_logic;
	    rout  : out std_logic_vector(1599 downto 0));
	end component;


    --component FIFO_HEADER_WRAPPER is
    --port (
    --	i_nrst_rd     : in  std_logic;                     --Low speed rd clock reset sync
    --	i_nrst_wr     : in  std_logic;                     --High speed rd clock reset sync
    --	-------------------------------write side-------------------------------
    --	i_wr_clk      : in  std_logic;                     --low speed write clock
    --	i_wr_en       : in  std_logic;                     --write eneable
    --	i_din         : in  std_logic_vector(63 downto 0); --data in
    --
    --	o_full        : out std_logic;                     --write side - full flag
    --	o_almost_full : out std_logic;                     --write side - almost full flag (full-1)
    --	------------------------------------------------------------------------
    --
    --	--------------------------------read side-------------------------------
    --	i_rd_clk      : in  std_logic;                     --High Speed read clock
    --    i_rd_en       : in  std_logic;                     --read enable
    --	o_dout        : out std_logic_vector(63 downto 0); --dout
    --
    --	o_empty       : out std_logic;                     --read side - empty flag
    --	o_almost_empty: out std_logic                      --read side - almost empty flag (empty+1)
    --	-------------------------------------------------------------------------
    --);
    --end component;

    
    signal r_SYNCED_nRST_500M     : std_logic :='0'              ;
    signal r_nRST_500M_local      : std_logic :='0'              ;
    attribute ASYNC_REG of r_nRST_500M_local : signal is "TRUE"  ;--the first reg receive the data as ASYNC
	signal r_nRST_500M_localZ     : std_logic :='0'              ;
    signal r_nRST_500M_localZZ    : std_logic :='0'              ;
    signal r_nRST_500M_localZZZ   : std_logic :='0'              ;

    signal r_new_job_toggle_12M   : std_logic :='0'              ;
	signal r_new_job_toggle_12MZ  : std_logic :='0'              ;
	signal r_new_job_toggle_12MZZ : std_logic :='0'              ;
   
	signal r_new_job_toggle_500M  : std_logic :='0'              ;
	attribute ASYNC_REG of r_new_job_toggle_500M : signal is "TRUE";--the first reg receive the data as ASYNC
	signal r_new_job_toggle_500MZ : std_logic :='0'              ;
	signal r_new_job_toggle_500MZZ: std_logic :='0'              ;

	
	

    --write FIFO header
    signal r_full                : std_logic                    ;
    signal r_almost_full         : std_logic                    ;
    --read FIFO  header                              
    signal r_new_job_trig        : std_logic                    ;
    signal r_rd_en               : std_logic                    ;
    --signal r_rd_enZ            : std_logic                    ;
    --signal r_rd_enZZ           : std_logic                    ;
    signal r_header_out_chunk    : std_logic_vector(63 downto 0);
    signal r_empty               : std_logic                    ;
    signal r_almost_empty        : std_logic                    ;

    signal r_header_out_chunkZ   : std_logic_vector(63 downto 0);
    signal r_emptyZ              : std_logic                    ;
    signal r_almost_emptyZ       : std_logic                    ;


    
    signal hash_outZ             : std_logic_vector(255 downto 223);
   
    signal r_HASH_en             : std_logic               :='0';
    signal r_nonce_temp          : std_logic_vector(63 downto 0);
    signal r_nonce               : std_logic_vector(63 downto 0);
    signal r_golden_nonce        : std_logic_vector(63 downto 0);
    signal r_golden_nonceZ       : std_logic_vector(63 downto 0);
    signal r_golden_nonceZZ      : std_logic_vector(63 downto 0);
    signal r_golden_nonce_reg    : std_logic_vector(63 downto 0);
    signal r_valid               : std_logic                    ;
    signal r_validZ              : std_logic                    ;
    signal r_validZZ             : std_logic                    ;

    signal r_Golden_Ticket        : std_logic                ;
    signal r_Golden_Ticket_toggle : std_logic           :='0';
    signal r_Golden_Ticket_toggle_12M     : std_logic                    ;
    attribute ASYNC_REG of r_Golden_Ticket_toggle_12M : signal is "TRUE";--the first reg receive the data as ASYNC


	signal r_Golden_Ticket_toggle_12MZ    : std_logic                    ;
	signal r_Golden_Ticket_toggle_12MZZ   : std_logic                    ;
	signal r_Golden_Ticket_toggle_12MZZZ  : std_logic                    ;

	signal r_Golden_nonce_12M             : std_logic_vector(63 downto 0) ;
	attribute ASYNC_REG of r_Golden_nonce_12M : signal is "TRUE";--the first reg receive the data as ASYNC                   
	--signal r_Golden_nonce_12MZ          : std_logic_vector(63 downto 0);                    
	signal r_Golden_Ticket_12M            : std_logic                    ;

    --Hearder re-built FSM signals
    TYPE   s_state_HEADER_builder is (s_WAIT_NEW_HEADER, s_BUILD_HEADER);
 	signal s_current_state_HEADER_builder : s_state_HEADER_builder := s_WAIT_NEW_HEADER;
    -- 
    -- --Hashing control FSM signals
    TYPE   s_state_HASH_control is (s_WAIT_NEW_HEADER, s_NEW_HEADER_TRIG, s_SCAN_NONCE);
 	signal s_current_state_HASH_control : s_state_HASH_control := s_WAIT_NEW_HEADER;


	TYPE enable_ppl is array (0 to 24) of std_logic;
	signal en_ppl : enable_ppl;

	TYPE state_total is array (0 to 25) of std_logic_vector(1599 downto 0);
	signal state : state_total;

	TYPE rc_total is array (0 to 31) of std_logic_vector(63 downto 0);
	constant rc : rc_total :=(
	x"0000000000000001", x"0000000000008082", x"800000000000808A", x"8000000080008000",
	x"000000000000808B", x"0000000080000001", x"8000000080008081", x"8000000000008009",
	x"000000000000008A", x"0000000000000088", x"0000000080008009", x"000000008000000A",
	x"000000008000808B", x"800000000000008B", x"8000000000008089", x"8000000000008003",
	x"8000000000008002", x"8000000000000080", x"000000000000800A", x"800000008000000A",
	x"8000000080008081", x"8000000000008080", x"0000000080000001", x"8000000080008008",
	x"0000000000000000", x"0000000000000000", x"0000000000000000", x"0000000000000000",
	x"0000000000000000", x"0000000000000000", x"0000000000000000", x"0000000000000000");


	signal hash_out : std_logic_vector(255 downto 0) ;-- hash32 out.


	begin


	---------------------CDC of nRST_500M from 12M to 500M--------------------------
	process(i_CLK_12M)
		begin
		if(i_CLK_12M'event and i_CLK_12M='1')then
			r_SYNCED_nRST_500M    <= i_SYNCED_nRST_500M ;--sync reset to 500M
		end if;
	end process;

	process(i_CLK_500M)
		begin
		if(i_CLK_500M'event and i_CLK_500M='1')then
			r_nRST_500M_local    <= r_SYNCED_nRST_500M ;--
			r_nRST_500M_localZ   <= r_nRST_500M_local  ;--sync reset to 500M
			r_nRST_500M_localZZ  <= r_nRST_500M_localZ ;--
			r_nRST_500M_localZZZ <= r_nRST_500M_localZZ;--
		end if;
	end process;	
	--------------------------------------------------------------------------------

     ---------------------De-serialize header in 12M domain-------------------------
	process(i_CLK_12M)
		begin
		if(i_CLK_12M'event and i_CLK_12M='1')then
			if (i_SYNCED_nRST_12M= '0') then
				
				r_header_in_chunk      <= (others => '0');

				s_current_state_HEADER_builder <= s_WAIT_NEW_HEADER;
				
				r_header_in_12M        <= (others => '0');
				r_header_wr_en         <= '0';
				r_new_job_toggle_12M   <= '0';
				r_new_job_toggle_12MZ  <= '0';
				r_new_job_toggle_12MZZ <= '0';
				r_golden_nonce_init_12M     <= (others => '0');

				
			else

				r_header_in_chunk      <= i_header_in_chunk;
				r_header_wr_en         <= i_header_wr_en;

				r_new_job_toggle_12MZ  <= r_new_job_toggle_12M ;
				r_new_job_toggle_12MZZ <= r_new_job_toggle_12MZ;

			
				case s_current_state_HEADER_builder is
	               

	                when s_WAIT_NEW_HEADER =>
	                	
	                	if (r_header_wr_en = '1') then --a "new header" is coming.
	                		r_header_in_12M        <= r_header_in_12M( (r_header_in_12M'high - BLOCK_HEADER_CHUNK_WIDTH )  downto 0) & r_header_in_chunk; 
							s_current_state_HEADER_builder <= s_BUILD_HEADER;
						end if;	


					when s_BUILD_HEADER =>						

						r_header_in_12M <= r_header_in_12M( (r_header_in_12M'high - BLOCK_HEADER_CHUNK_WIDTH )  downto 0) & r_header_in_chunk; 						

						if (r_header_wr_en = '0') then --when the FIFO is finish to read, save nonce and start the scan.									
							r_new_job_toggle_12M           <= not r_new_job_toggle_12M;
							r_golden_nonce_init_12M             <= r_header_in_chunk       ;
							s_current_state_HEADER_builder <= s_WAIT_NEW_HEADER       ;
						end if;

	                when others =>

	                	r_header_in_chunk            <= (others => '0');

	                	s_current_state_HEADER_builder <= s_WAIT_NEW_HEADER;
						r_header_in_12M                <= (others => '0');
						r_header_wr_en                 <= '0';
						r_new_job_toggle_12M           <= '0';
						r_new_job_toggle_12MZ          <= '0';
						r_new_job_toggle_12MZZ         <= '0';
						r_golden_nonce_init_12M             <= (others => '0');       
	            end case;        	
			end if;
		end if;
	end process;	
	----------------------------------------------------------------------------------
	

	---------------------New job Toggle creation and CDC----------------------------
	process(i_CLK_500M)
		begin
		if(i_CLK_500M'event and i_CLK_500M='1')then
			if (r_nRST_500M_localZZZ= '0') then
				r_new_job_toggle_500M   <= '0';
				r_new_job_toggle_500MZ  <= '0';
				r_new_job_toggle_500MZZ <= '0';

				r_new_job_trig          <= '0';

				--r_header_in_500M        <= (others => '0');
				--r_golden_nonce_init_500M     <= (others => '0');
			else	

				r_new_job_toggle_500M   <= r_new_job_toggle_12MZZ;--CDC happening here. Need ASYN_REG here. 
				r_new_job_toggle_500MZ  <= r_new_job_toggle_500M ;
				r_new_job_toggle_500MZZ <= r_new_job_toggle_500MZ;

				r_new_job_trig          <= '0';
				if (r_new_job_toggle_500MZZ /= r_new_job_toggle_500MZ) then --Toggle detection.
					r_new_job_trig <= '1';
				end if;

				r_header_in_500M         <= r_header_in_12M   ; --CDC happening here. Need ASYN_REG, Bus skew, set_max_delay.
				r_golden_nonce_init_500M <= r_golden_nonce_init_12M; --CDC happening here. Need ASYN_REG, Bus skew, set_max_delay.

			end if;	
		end if;
	end process;
	----------------------------------------------------------------------------------


    ---------------------De-serialize header and set nonce----------------------------
	process(i_CLK_500M)
		begin
		if(i_CLK_500M'event and i_CLK_500M='1')then
			
			--if (r_nRST_500M_localZZZ= '0') then
	        --    s_current_state_HASH_control <= s_WAIT_NEW_HEADER;
			--	r_header_in                    <= (others => '0');
			--	r_HASH_en                      <= '0'            ;
			--	r_nonce                        <= (others => '0');
			--else
			
				case s_current_state_HASH_control is
	               

	                when s_WAIT_NEW_HEADER =>
	                	
	                	if (r_new_job_trig = '1') then --a "new job ready" trigger the reading of the FIFO.
							s_current_state_HASH_control <= s_SCAN_NONCE;
							r_header_in                  <= r_header_in_500M(r_header_in'high downto BLOCK_HEADER_CHUNK_WIDTH ) &
									                        (r_header_in_500M(63 downto NB_CORE_MAX_BIT_LENGTH)) & std_logic_vector(to_unsigned(CORE_ID,NB_CORE_MAX_BIT_LENGTH)); 
							r_nonce                      <= (r_header_in_500M(63 downto NB_CORE_MAX_BIT_LENGTH)) & std_logic_vector(to_unsigned(CORE_ID,NB_CORE_MAX_BIT_LENGTH));
                 
							r_HASH_en                    <= '1';
						end if;	


					when s_SCAN_NONCE =>

						if (r_nRST_500M_localZZZ = '0') then --local reset.		
							s_current_state_HASH_control <= s_WAIT_NEW_HEADER;
							r_HASH_en                    <= '0';
						end if;

						--r_HASH_en                <= '1';
						r_header_in(63 downto 0) <= (r_nonce(63 downto NB_CORE_MAX_BIT_LENGTH)) & std_logic_vector(to_unsigned(CORE_ID,NB_CORE_MAX_BIT_LENGTH));

						--nonce accumulator. is pipelined to shorten the carry line (is implemented using CARRY8).------------------------------------------------
						r_nonce(31 downto 0)     <= (r_nonce(31 downto NB_CORE_MAX_BIT_LENGTH) + 1) & std_logic_vector(to_unsigned(CORE_ID,NB_CORE_MAX_BIT_LENGTH));
						if (r_nonce(31 downto NB_CORE_MAX_BIT_LENGTH) = (X"FFFFFF" & "11")) then
							r_nonce(63 downto 32)<= r_nonce(63 downto 32)+1;
						end if;
						------------------------------------------------------------------------------------------------------------------------------------------

						--infinite loop until new job received ready to read received.
						if (r_new_job_trig = '1') then --a "new job ready" trigger.
							s_current_state_HASH_control <= s_NEW_HEADER_TRIG;
							r_HASH_en                    <= '0';
						end if;	


					when s_NEW_HEADER_TRIG =>
							
						s_current_state_HASH_control <= s_SCAN_NONCE;
						r_HASH_en                    <= '1';
						r_header_in                  <= r_header_in_500M(r_header_in'high downto BLOCK_HEADER_CHUNK_WIDTH ) &
								                       (r_header_in_500M(63 downto NB_CORE_MAX_BIT_LENGTH)) & std_logic_vector(to_unsigned(CORE_ID,NB_CORE_MAX_BIT_LENGTH)); 
						r_nonce                      <=(r_header_in_500M(63 downto NB_CORE_MAX_BIT_LENGTH)) & std_logic_vector(to_unsigned(CORE_ID,NB_CORE_MAX_BIT_LENGTH));


	                when others =>

	                	s_current_state_HASH_control <= s_WAIT_NEW_HEADER;

						r_header_in                  <= (others => '0');
						r_HASH_en                    <= '0'            ;
						r_nonce                      <= (others => '0');	            
	            end case;        	
			--end if;
		end if;
	end process;	
	----------------------------------------------------------------------------------


	en_ppl(0) <= r_HASH_en;

	keccak256_function: for i in 0 to 23 generate
		keccakF: keccak_round_ppl port map(
			clk	  => i_CLK_500M        ,
			en    => en_ppl(i)         ,
			gate  => i_gate            ,
			rin   => state (i)         ,
			rc	  => rc(i)             ,
			valid => en_ppl(i+1)       ,
			rout  => state (i+1)
		);
	end generate;




	to_LE: for i in 0 to 9 generate
		state(0)( (64*16)+(64*i)-1 downto (64*15)+(64*i) ) <= r_header_in(  7+(64*i)+32 downto  0+(64*i)+32 ) 
														    & r_header_in( 15+(64*i)+32 downto  8+(64*i)+32 ) 
														    & r_header_in( 23+(64*i)+32 downto 16+(64*i)+32 )
														    & r_header_in( 31+(64*i)+32 downto 24+(64*i)+32 )
														    & r_header_in( 39+(64*i)+32 downto 32+(64*i)+32 ) 
															& r_header_in( 47+(64*i)+32 downto 40+(64*i)+32 ) 
															& r_header_in( 55+(64*i)+32 downto 48+(64*i)+32 )
															& r_header_in( 63+(64*i)+32 downto 56+(64*i)+32 );
	end generate;	

	state(0)(959 downto 896) <=   X"00000001"
								& r_header_in(  7+(64*0) downto  0+(64*0) ) 
								& r_header_in( 15+(64*0) downto  8+(64*0) ) 
								& r_header_in( 23+(64*0) downto 16+(64*0) )
								& r_header_in( 31+(64*0) downto 24+(64*0) );


	--state(0)(959 downto 0) <=     X"00000000" & X"00000001" --end of message
	--& X"00000000" & X"00000000" & X"00000000" & X"00000000" & X"00000000" & X"00000000" & X"00000000" & X"00000000" 
	--& X"00000000" & X"00000000" & X"80000000"               --end of the rate 'r'
	--& X"00000000" & X"00000000" & X"00000000" & X"00000000" & X"00000000" & X"00000000" & X"00000000" & X"00000000" 
	--& X"00000000" & X"00000000" & X"00000000" & X"00000000" & X"00000000" & X"00000000" & X"00000000" & X"00000000" 
	--& X"00000000";                                          --end of the capacity 'c'

	state(0)(895 downto 0) <=
	  X"00000000" & X"00000000" & X"00000000" & X"00000000" & X"00000000" & X"00000000" & X"00000000" & X"00000000" 
	& X"00000000" & X"00000000" & X"80000000"               --end of the rate 'r'
	& X"00000000" & X"00000000" & X"00000000" & X"00000000" & X"00000000" & X"00000000" & X"00000000" & X"00000000" 
	& X"00000000" & X"00000000" & X"00000000" & X"00000000"	& X"00000000" & X"00000000" & X"00000000" & X"00000000" 
	& X"00000000";                                          --end of the capacity 'c'
	



	to_BE: for i in 0 to 3 generate
		hash_out( (64*(i+1)-1) downto (64*i) ) <= state(24) (  1351+(64*i) downto 1344+(64*i) ) 
											    & state(24) (  1359+(64*i) downto 1352+(64*i) ) 
											    & state(24) (  1367+(64*i) downto 1360+(64*i) )
											    & state(24) (  1375+(64*i) downto 1368+(64*i) )
											    & state(24) (  1383+(64*i) downto 1376+(64*i) ) 
								                & state(24) (  1391+(64*i) downto 1384+(64*i) ) 
								                & state(24) (  1399+(64*i) downto 1392+(64*i) )
								                & state(24) (  1407+(64*i) downto 1400+(64*i) );
	end generate;



	---------------------------------------Golden nonce finder-----------------------------------
	process(i_CLK_500M)
		begin
		if(i_CLK_500M'event and i_CLK_500M='1')then --create toggle signal from pulse
			

			--some pipeline
			r_valid           <= en_ppl(24);
			r_validZ          <= r_valid;
			r_validZZ         <= r_validZ;

			hash_outZ         <= hash_out(255 downto 223);
			
			--load new start nonce and increment golden nonce once first Hash out valid.
			if (r_validZ = '1' and r_validZZ = '0') then 				
				r_golden_nonceZZ  <= r_golden_nonce_init_500M;
			else				
				r_golden_nonceZZ  <= (r_golden_nonceZZ(63 downto NB_CORE_MAX_BIT_LENGTH) + 1) & std_logic_vector(to_unsigned(CORE_ID,NB_CORE_MAX_BIT_LENGTH));
			end if;	

			--Looking for golden ticket and trigger event. Non state changing event.
			--                       hash_out(255 downto 223) = X"00000000" & '0')   -- optimized comparator tree
			r_Golden_Ticket <= not( (hash_outZ(255)) or (hash_outZ(254)) or (hash_outZ(253)) or (hash_outZ(252)) or (hash_outZ(251)) or (hash_outZ(250)) ) and
				               not( (hash_outZ(249)) or (hash_outZ(248)) or (hash_outZ(247)) or (hash_outZ(246)) or (hash_outZ(245)) or (hash_outZ(244)) ) and
				               not( (hash_outZ(243)) or (hash_outZ(242)) or (hash_outZ(241)) or (hash_outZ(240)) or (hash_outZ(239)) or (hash_outZ(238)) ) and
				               not( (hash_outZ(237)) or (hash_outZ(236)) or (hash_outZ(235)) or (hash_outZ(234)) or (hash_outZ(233)) or (hash_outZ(232)) ) and
				               not( (hash_outZ(231)) or (hash_outZ(230)) or (hash_outZ(229)) or (hash_outZ(228)) or (hash_outZ(227)) or (hash_outZ(226)) ) and
				               not( (hash_outZ(225)) or (hash_outZ(224)) or (hash_outZ(223))                                                                )     ;
			
			if (r_Golden_Ticket = '1') then  					                                    

				r_golden_nonce_reg <= r_golden_nonceZZ; --latching the golden nonce to be sent back
			end if;		

		end if;
	end process;


	-------------------------------------------------------------CDC to SYSCLK-----------------------
	process(i_CLK_500M)
		begin
		if(i_CLK_500M'event and i_CLK_500M='1')then --create toggle signal from pulse
			if (r_nRST_500M_localZZZ = '0') then
				r_Golden_Ticket_toggle <= '0';									
			else	
				if(r_Golden_Ticket = '1') then				
					r_Golden_Ticket_toggle <= not (r_Golden_Ticket_toggle);
				end if;
			end if;	
		end if;
	end process;

	process(i_CLK_12M)
		begin
		if(i_CLK_12M'event and i_CLK_12M='1')then
			if (i_SYNCED_nRST_12M = '0') then
				r_Golden_Ticket_toggle_12M     <= '0';
				r_Golden_Ticket_toggle_12MZ    <= '0';
				r_Golden_Ticket_toggle_12MZZ   <= '0';
				r_Golden_Ticket_toggle_12MZZZ  <= '0';

				--r_Golden_nonce_12M           <= (others => '0');
				--r_Golden_nonce_12MZ          <= (others => '0');
				r_Golden_Ticket_12M            <= '0';

			else	
				r_Golden_Ticket_toggle_12M   <= r_Golden_Ticket_toggle;--CDC happening here.
				r_Golden_Ticket_toggle_12MZ  <= r_Golden_Ticket_toggle_12M;
				r_Golden_Ticket_toggle_12MZZ <= r_Golden_Ticket_toggle_12MZ;
				r_Golden_Ticket_toggle_12MZZZ<= r_Golden_Ticket_toggle_12MZZ;

				r_Golden_Ticket_12M <= '0';

				if(r_Golden_Ticket_toggle_12MZZZ /= r_Golden_Ticket_toggle_12MZZ) then --toggle detectec
					r_Golden_nonce_12M  <= r_golden_nonce_reg;--need a set_bus_scew constraint here.
					r_Golden_Ticket_12M <= '1'; --generate a pulse.
				end if;

			end if;	
		end if;
	end process;
	
	o_Golden_Ticket  <= r_Golden_Ticket_12M when (r_SYNCED_nRST_500M = '1') else '0';
	o_Golden_Nonce   <= r_Golden_nonce_12M ;
	
	--return 0 if no simulation. if simulation, emulate o_Golden_Ticket.
	o_valid <= r_Golden_Ticket_12M when (SIMULATION = true and r_SYNCED_nRST_500M = '1') else '0';

	---------------------------------------------------------------------------------------------------

end architecture;