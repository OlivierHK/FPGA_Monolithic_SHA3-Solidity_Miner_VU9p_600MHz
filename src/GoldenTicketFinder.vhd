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

library work;
use work.MyPackage.all;



entity GoldenTicketFinder is
port(
		reset               : in std_logic ;                      -- Reset signal (active high).
		clk                 : in std_logic ;                      -- clock signal
		---------------------
		en                  : in std_logic ;                      -- enable signal(active high).
		gate                : in std_logic ;                      -- gating signal to halt hashing (active high).
		Htarg               : in std_logic_vector(63  downto 0) ; --
		hash_in_core        : in hash256_bus_type;
		--hash_in_core0       : in std_logic_vector(255 downto 0) ; -- hash32 in.
        --hash_in_core1       : in std_logic_vector(255 downto 0) ; -- hash32 in.
        --hash_in_core2       : in std_logic_vector(255 downto 0) ; -- hash32 in.
        --hash_in_core3       : in std_logic_vector(255 downto 0) ; -- hash32 in.
        --hash_in_core4       : in std_logic_vector(255 downto 0) ; -- hash32 in.
        --hash_in_core5       : in std_logic_vector(255 downto 0) ; -- hash32 in.
        --hash_in_core6       : in std_logic_vector(255 downto 0) ; -- hash32 in.
        --hash_in_core7       : in std_logic_vector(255 downto 0) ; -- hash32 in.
        valid_core          : in bit_bus_type;
        --valid_core0         : in std_logic ;                     -- valid signal(active high).
        --valid_core1         : in std_logic ;                     -- valid signal(active high).
        --valid_core2         : in std_logic ;                     -- valid signal(active high).
        --valid_core3         : in std_logic ;                     -- valid signal(active high).
        --valid_core4         : in std_logic ;                     -- valid signal(active high).
        --valid_core5         : in std_logic ;                     -- valid signal(active high).
        --valid_core6         : in std_logic ;                     -- valid signal(active high).
        --valid_core7         : in std_logic ;                     -- valid signal(active high).
        ----------------------
        valid_out           : out std_logic ;
        
        GoldenTicket_core   : out bit_bus_type;
        --GoldenTicket_core0  : out std_logic ;
        --GoldenTicket_core1  : out std_logic ;
        --GoldenTicket_core2  : out std_logic ;
        --GoldenTicket_core3  : out std_logic ;
        --GoldenTicket_core4  : out std_logic ;
        --GoldenTicket_core5  : out std_logic ;
        --GoldenTicket_core6  : out std_logic ;
        --GoldenTicket_core7  : out std_logic ;
        hash_out_core       : out hash256_bus_type;
        --hash_out_core0      : out std_logic_vector(255 downto 0) ;-- hash32 out.
        --hash_out_core1      : out std_logic_vector(255 downto 0) ;-- hash32 out.
        --hash_out_core2      : out std_logic_vector(255 downto 0) ;-- hash32 out.
        --hash_out_core3      : out std_logic_vector(255 downto 0) ;-- hash32 out.
        --hash_out_core4      : out std_logic_vector(255 downto 0) ;-- hash32 out.
        --hash_out_core5      : out std_logic_vector(255 downto 0) ;-- hash32 out.
        --hash_out_core6      : out std_logic_vector(255 downto 0) ;-- hash32 out.
        --hash_out_core7      : out std_logic_vector(255 downto 0) ;-- hash32 out.
		----------------------
		DEBUG_port_in       : in  std_logic_vector(31 downto 0) ; --
		DEBUG_port_out      : out std_logic_vector(31 downto 0)   -- DEBUG port
	);
end GoldenTicketFinder;


architecture arch of GoldenTicketFinder is

	
	TYPE Htarg64b_bus_type is array (0 to NB_CORE-1) of std_logic_vector(63 downto 0);
	signal HtargMask: Htarg64b_bus_type;
	--signal HtargMask0: std_logic_vector(63 downto 0);
	--signal HtargMask1: std_logic_vector(63 downto 0);
	--signal HtargMask2: std_logic_vector(63 downto 0);
	--signal HtargMask3: std_logic_vector(63 downto 0);
	--signal HtargMask4: std_logic_vector(63 downto 0);
	--signal HtargMask5: std_logic_vector(63 downto 0);
	--signal HtargMask6: std_logic_vector(63 downto 0);
	--signal HtargMask7: std_logic_vector(63 downto 0);

	signal Htarg_core: Htarg64b_bus_type;
	signal Htarg_coreZ: Htarg64b_bus_type;
	signal Htarg_coreZZ: Htarg64b_bus_type;
	signal Htarg_coreZZZ: Htarg64b_bus_type;
	--signal Htarg0: std_logic_vector(63 downto 0);
	--signal Htarg1: std_logic_vector(63 downto 0);
	--signal Htarg2: std_logic_vector(63 downto 0);
	--signal Htarg3: std_logic_vector(63 downto 0);
	--signal Htarg4: std_logic_vector(63 downto 0);
	--signal Htarg5: std_logic_vector(63 downto 0);
	--signal Htarg6: std_logic_vector(63 downto 0);
	--signal Htarg7: std_logic_vector(63 downto 0);

	signal hash_in_core_Z: hash256_bus_type;
	--signal hash_in_core0_Z: std_logic_vector(255 downto 0) ;
	--signal hash_in_core1_Z: std_logic_vector(255 downto 0) ;
	--signal hash_in_core2_Z: std_logic_vector(255 downto 0) ;
	--signal hash_in_core3_Z: std_logic_vector(255 downto 0) ;
	--signal hash_in_core4_Z: std_logic_vector(255 downto 0) ;
	--signal hash_in_core5_Z: std_logic_vector(255 downto 0) ;
	--signal hash_in_core6_Z: std_logic_vector(255 downto 0) ;
	--signal hash_in_core7_Z: std_logic_vector(255 downto 0) ;

	
	signal valid_core_Z   : bit_bus_type ;
	--signal valid_core0_Z  : std_logic ;                     -- valid signal(active high).
    --signal valid_core1_Z  : std_logic ;                     -- valid signal(active high).
    --signal valid_core2_Z  : std_logic ;                     -- valid signal(active high).
    --signal valid_core3_Z  : std_logic ;                     -- valid signal(active high).
    --signal valid_core4_Z  : std_logic ;                     -- valid signal(active high).
    --signal valid_core5_Z  : std_logic ;                     -- valid signal(active high).
    --signal valid_core6_Z  : std_logic ;                     -- valid signal(active high).
    --signal valid_core7_Z  : std_logic ;                     -- valid signal(active high).


begin

	process(clk)
	begin
		if(clk'event and clk='1') then
			if (reset = '1') then
				Htarg_core    <= (others =>(others => '1'));
				Htarg_coreZ   <= (others =>(others => '1'));
				--Htarg_coreZZ  <= (others =>(others => '1'));
				--Htarg_coreZZZ <= (others =>(others => '1'));
				--Htarg0<=(others => '1');
				--Htarg1<=(others => '1');
				--Htarg2<=(others => '1');
				--Htarg3<=(others => '1');
				--Htarg4<=(others => '1');
				--Htarg5<=(others => '1');
				--Htarg6<=(others => '1');
				--Htarg7<=(others => '1');

				HtargMask <= (others =>(others => '1'));
				--HtargMask0<=(others => '1');
				--HtargMask1<=(others => '1');
				--HtargMask2<=(others => '1');
				--HtargMask3<=(others => '1');
				--HtargMask4<=(others => '1');
				--HtargMask5<=(others => '1');
				--HtargMask6<=(others => '1');
				--HtargMask7<=(others => '1');

				valid_core_Z  <= (others => '0');
				--valid_core0_Z  <= '0';
 				--valid_core1_Z  <= '0';
 				--valid_core2_Z  <= '0';
 				--valid_core3_Z  <= '0';
 				--valid_core4_Z  <= '0';
 				--valid_core5_Z  <= '0';
 				--valid_core6_Z  <= '0';
 				--valid_core7_Z  <= '0';

				valid_out <= '0';

				GoldenTicket_core   <= (others => '0');
				--GoldenTicket_core0  <= '0';
				--GoldenTicket_core1  <= '0';
				--GoldenTicket_core2  <= '0';
				--GoldenTicket_core3  <= '0';
				--GoldenTicket_core4  <= '0';
				--GoldenTicket_core5  <= '0';
				--GoldenTicket_core6  <= '0';
				--GoldenTicket_core7  <= '0';

				hash_in_core_Z <= (others =>(others => '1'));
				--hash_in_core0_Z <= (others => '1');
				--hash_in_core1_Z <= (others => '1');
				--hash_in_core2_Z <= (others => '1');
				--hash_in_core3_Z <= (others => '1');
				--hash_in_core4_Z <= (others => '1');
				--hash_in_core5_Z <= (others => '1');
				--hash_in_core6_Z <= (others => '1');
				--hash_in_core7_Z <= (others => '1');

				hash_out_core   <= (others =>(others => '1'));
				--hash_out_core0  <= (others => '1');
				--hash_out_core1  <= (others => '1');
				--hash_out_core2  <= (others => '1');
				--hash_out_core3  <= (others => '1');
				--hash_out_core4  <= (others => '1');
				--hash_out_core5  <= (others => '1');
				--hash_out_core6  <= (others => '1');
				--hash_out_core7  <= (others => '1');

			else
				
				for CORE_ID in 0 to (NB_CORE-1) loop
					
					Htarg_core(CORE_ID)     <= Htarg;
					--Htarg_core(CORE_ID)      <= Htarg_coreZ(CORE_ID);
					HtargMask(CORE_ID)       <= ( Htarg_core(CORE_ID) ) AND hash_in_core(CORE_ID)(255 downto 192);
					valid_core_Z(CORE_ID)    <= valid_core(CORE_ID);
					hash_in_core_Z(CORE_ID)  <= hash_in_core(CORE_ID);
					hash_out_core(CORE_ID)   <= hash_in_core_Z(CORE_ID);


					if(valid_core_Z(CORE_ID) = '1') then
						if ( HtargMask(CORE_ID) = X"00000000_00000000") then
							GoldenTicket_core(CORE_ID) <= '1';
						else
							GoldenTicket_core(CORE_ID) <= '0';	
						end if;	
					else
						GoldenTicket_core(CORE_ID) <= '0';		
					end if;

				end loop;
				

				--Htarg0          <=  HTarg;
				--Htarg1          <=  HTarg;
				--Htarg2          <=  HTarg;
				--Htarg3          <=  HTarg;
				--Htarg4          <=  HTarg;
				--Htarg5          <=  HTarg;
				--Htarg6          <=  HTarg;
				--Htarg7          <=  HTarg;

				--HtargMask0<=( Htarg0) AND hash_in_core0(255 downto 192);
				--HtargMask1<=( Htarg1) AND hash_in_core1(255 downto 192);
				--HtargMask2<=( Htarg2) AND hash_in_core2(255 downto 192);
				--HtargMask3<=( Htarg3) AND hash_in_core3(255 downto 192);
				--HtargMask4<=( Htarg4) AND hash_in_core4(255 downto 192);
				--HtargMask5<=( Htarg5) AND hash_in_core5(255 downto 192);
				--HtargMask6<=( Htarg6) AND hash_in_core6(255 downto 192);
				--HtargMask7<=( Htarg7) AND hash_in_core7(255 downto 192);

				--valid_core0_Z  <= valid_core0;
 				--valid_core1_Z  <= valid_core1;
 				--valid_core2_Z  <= valid_core2;
 				--valid_core3_Z  <= valid_core3;
 				--valid_core4_Z  <= valid_core4;
 				--valid_core5_Z  <= valid_core5;
 				--valid_core6_Z  <= valid_core6;
 				--valid_core7_Z  <= valid_core7;				

				valid_out      <= valid_core_Z(0) ;

				--hash_in_core0_Z <= hash_in_core0;
				--hash_in_core1_Z <= hash_in_core1;
				--hash_in_core2_Z <= hash_in_core2;
				--hash_in_core3_Z <= hash_in_core3;
				--hash_in_core4_Z <= hash_in_core4;
				--hash_in_core5_Z <= hash_in_core5;
				--hash_in_core6_Z <= hash_in_core6;
				--hash_in_core7_Z <= hash_in_core7;

				--hash_out_core0  <= hash_in_core0_Z;
				--hash_out_core1  <= hash_in_core1_Z;
				--hash_out_core2  <= hash_in_core2_Z;
				--hash_out_core3  <= hash_in_core3_Z;
				--hash_out_core4  <= hash_in_core4_Z;
				--hash_out_core5  <= hash_in_core5_Z;
				--hash_out_core6  <= hash_in_core6_Z;
				--hash_out_core7  <= hash_in_core7_Z;
				
				--if(valid_core0_Z='1') then
				--	if ( HtargMask0=X"00000000_00000000") then
				--		GoldenTicket_core0 <= '1';
				--	else
				--		GoldenTicket_core0 <= '0';	
				--	end if;	
				--else
				--	GoldenTicket_core0 <= '0';		
				--end if;
--
				--if(valid_core1_Z='1') then
				--	if (HtargMask1=X"00000000_00000000") then
				--		GoldenTicket_core1 <= '1';
				--	else
				--		GoldenTicket_core1 <= '0';	
				--	end if;	
				--else
				--	GoldenTicket_core1 <= '0';		
				--end if;
--
				--if(valid_core2_Z='1') then
				--	if (HtargMask2=X"00000000_00000000") then
				--		GoldenTicket_core2 <= '1';
				--	else
				--		GoldenTicket_core2 <= '0';	
				--	end if;	
				--else
				--	GoldenTicket_core2 <= '0';		
				--end if;
--
				--if(valid_core3_Z='1') then
				--	if (HtargMask3=X"00000000_00000000") then
				--		GoldenTicket_core3 <= '1';
				--	else
				--		GoldenTicket_core3 <= '0';	
				--	end if;
				--else
				--	GoldenTicket_core3 <= '0';		
				--end if;
--
				--if(valid_core4_Z='1' ) then
				--	if ( HtargMask4=X"00000000_00000000") then
				--		GoldenTicket_core4 <= '1';
				--	else
				--		GoldenTicket_core4 <= '0';	
				--	end if;	
				--else
				--	GoldenTicket_core4 <= '0';		
				--end if;
--
				--if(valid_core5_Z='1' ) then
				--	if ( HtargMask5=X"00000000_00000000") then
				--		GoldenTicket_core5 <= '1';
				--	else
				--		GoldenTicket_core5 <= '0';	
				--	end if;	
				--else
				--	GoldenTicket_core5 <= '0';		
				--end if;
--
				--if(valid_core6_Z='1' ) then
				--	if ( HtargMask6=X"00000000_00000000") then
				--		GoldenTicket_core6 <= '1';
				--	else
				--		GoldenTicket_core6 <= '0';	
				--	end if;	
				--else
				--	GoldenTicket_core6 <= '0';		
				--end if;
--
				--if(valid_core7_Z='1' ) then
				--	if ( HtargMask7=X"00000000_00000000") then
				--		GoldenTicket_core7 <= '1';
				--	else
				--		GoldenTicket_core7 <= '0';	
				--	end if;	
				--else
				--	GoldenTicket_core7 <= '0';		
				--end if;

			end if;	 
		end if;
	end process;	

end architecture;