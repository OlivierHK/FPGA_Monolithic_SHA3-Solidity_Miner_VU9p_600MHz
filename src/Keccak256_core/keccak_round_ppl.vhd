--------------------------------------------------------------------------------
-- PROJECT: ALTO FPGA Miner. SHA3-Solidity Flavor on Virtex ULTRAScale XCVU9P
--------------------------------------------------------------------------------
-- AUTHORS: Olivier FAURIE <olivier.faurie.hk@gmail.com>
-- LICENSE: 
-- WEBSITE: https://github.com/olivierHK
--------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use work.sha3_pkg.all;
use work.keccak_pkg.all;

library work;
use work.MyPackage.all;

Library UNISIM;
use UNISIM.vcomponents.all;
	
entity keccak_round_ppl is
port (	  
	clk	  : in  std_logic;
	------------------------------------------
	en    : in  std_logic;
	gate  : in  std_logic;
    rin   : in  std_logic_vector(KECCAK_STATE-1 downto 0);
    rc	  : in  std_logic_vector(63 downto 0);
    -------------------------------------------
	valid : out std_logic;
    rout  : out std_logic_vector(KECCAK_STATE-1 downto 0));
end keccak_round_ppl;

architecture mrogawski_round of keccak_round_ppl is 	
	type single_lane_type is array (0 to 4) of std_logic_vector(63 downto 0);
	type five_lanes_type  is array (0 to 4) of single_lane_type;
	
	signal aa : five_lanes_type; 
	signal bb : five_lanes_type;
	signal cc : five_lanes_type;	
	signal dd : five_lanes_type;	
	signal ee : five_lanes_type;	
	
	signal Ca, Ce, Ci, Co, Cu: std_logic_vector(63 downto 0); 
	signal Da, De, Di, Do, Du: std_logic_vector(63 downto 0); 
	signal rc_reg : std_logic_vector(63 downto 0);
	signal rout_reg : std_logic_vector(KECCAK_STATE-1 downto 0);
	signal enZ      : std_logic;

begin 
	InRowGen: 
	for i in 0 to 4 generate
		InColGen: 
		for j in 0 to 4 generate
			aa(i)(j) <= rin(KECCAK_STATE-(5*i+j)*64-1 downto KECCAK_STATE-(5*i+j)*64-64);
		end generate;
	end generate;
 	
	--Theta 5 bit XOR for simulation only.
	SIMULATION_Label: if (SIMULATION_XOR5 = true) generate
		Ca <= aa(0)(0) xor aa(1)(0) xor aa(2)(0) xor aa(3)(0) xor aa(4)(0); 
		Ce <= aa(0)(1) xor aa(1)(1) xor aa(2)(1) xor aa(3)(1) xor aa(4)(1); 
		Ci <= aa(0)(2) xor aa(1)(2) xor aa(2)(2) xor aa(3)(2) xor aa(4)(2); 
		Co <= aa(0)(3) xor aa(1)(3) xor aa(2)(3) xor aa(3)(3) xor aa(4)(3); 
		Cu <= aa(0)(4) xor aa(1)(4) xor aa(2)(4) xor aa(3)(4) xor aa(4)(4); 
	end generate SIMULATION_Label;	

	--Theta 5 bit XOR for Synth/Implementation .
	No_SIMULATION_XOR5_Label: if (SIMULATION_XOR5 = false) generate 
		--Call LUT5 primitve to force LUT5 usage. will do Ca <= aa(0)(0) xor aa(1)(0) xor aa(2)(0) xor aa(3)(0) xor aa(4)(0);
		LUT5_XOR_64bits: for i in 0 to 63 generate
			LUT5_Ca_inst : LUT5
				generic map (INIT => X"96696996")
				port map    ( O => Ca(i), I0 => aa(0)(0)(i), I1 => aa(1)(0)(i), I2 => aa(2)(0)(i), I3 => aa(3)(0)(i), I4 => aa(4)(0)(i) );

		--Call LUT5 primitve to force LUT5 usage. will do Ce <= aa(0)(1) xor aa(1)(1) xor aa(2)(1) xor aa(3)(1) xor aa(4)(1);
			LUT5_Ce_inst : LUT5
				generic map (INIT => X"96696996")
				port map    ( O => Ce(i), I0 => aa(0)(1)(i), I1 => aa(1)(1)(i), I2 => aa(2)(1)(i), I3 => aa(3)(1)(i), I4 => aa(4)(1)(i) );	

		--Call LUT5 primitve to force LUT5 usage. will do Ci <= aa(0)(2) xor aa(1)(2) xor aa(2)(2) xor aa(3)(2) xor aa(4)(2);
			LUT5_Ci_inst : LUT5
				generic map (INIT => X"96696996")
				port map    ( O => Ci(i), I0 => aa(0)(2)(i), I1 => aa(1)(2)(i), I2 => aa(2)(2)(i), I3 => aa(3)(2)(i), I4 => aa(4)(2)(i) );

		--Call LUT5 primitve to force LUT5 usage. will do Co <= aa(0)(3) xor aa(1)(3) xor aa(2)(3) xor aa(3)(3) xor aa(4)(3);
			LUT5_Co_inst : LUT5
				generic map (INIT => X"96696996")
				port map    ( O => Co(i), I0 => aa(0)(3)(i), I1 => aa(1)(3)(i), I2 => aa(2)(3)(i), I3 => aa(3)(3)(i), I4 => aa(4)(3)(i) );

		--Call LUT5 primitve to force LUT5 usage. will do Cu <= aa(0)(4) xor aa(1)(4) xor aa(2)(4) xor aa(3)(4) xor aa(4)(4);
			LUT5_Cu_inst : LUT5
				generic map (INIT => X"96696996")
				port map    ( O => Cu(i), I0 => aa(0)(4)(i), I1 => aa(1)(4)(i), I2 => aa(2)(4)(i), I3 => aa(3)(4)(i), I4 => aa(4)(4)(i) );
		end generate;
	end generate No_SIMULATION_XOR5_Label;





	Da <= Cu xor rolx(Ce, 1); 
	De <= Ca xor rolx(Ci, 1); 
	Di <= Ce xor rolx(Co, 1); 
	Do <= Ci xor rolx(Cu, 1); 
	Du <= Co xor rolx(Ca, 1); 
	
	bb(0)(0) <= aa(0)(0) xor Da;	cc(0)(0) <= bb(0)(0); 
	bb(0)(1) <= aa(1)(1) xor De; 	cc(0)(1) <= rolx(bb(0)(1), 44); 
	bb(0)(2) <= aa(2)(2) xor Di; 	cc(0)(2) <= rolx(bb(0)(2), 43); 
	bb(0)(3) <= aa(3)(3) xor Do; 	cc(0)(3) <= rolx(bb(0)(3), 21); 	
	bb(0)(4) <= aa(4)(4) xor Du; 	cc(0)(4) <= rolx(bb(0)(4), 14); 	
	
	bb(1)(0) <= aa(0)(3) xor Do; 	cc(1)(0) <= rolx(bb(1)(0), 28); 
	bb(1)(1) <= aa(1)(4) xor Du; 	cc(1)(1) <= rolx(bb(1)(1), 20); 
	bb(1)(2) <= aa(2)(0) xor Da; 	cc(1)(2) <= rolx(bb(1)(2), 3); 	
	bb(1)(3) <= aa(3)(1) xor De; 	cc(1)(3) <= rolx(bb(1)(3), 45); 
	bb(1)(4) <= aa(4)(2) xor Di;	cc(1)(4) <= rolx(bb(1)(4), 61);  
	
	bb(2)(0) <= aa(0)(1) xor De; 	cc(2)(0) <= rolx(bb(2)(0), 1); 
	bb(2)(1) <= aa(1)(2) xor Di; 	cc(2)(1) <= rolx(bb(2)(1), 6); 
	bb(2)(2) <= aa(2)(3) xor Do; 	cc(2)(2) <= rolx(bb(2)(2), 25); 	
	bb(2)(3) <= aa(3)(4) xor Du; 	cc(2)(3) <= rolx(bb(2)(3), 8); 	
	bb(2)(4) <= aa(4)(0) xor Da; 	cc(2)(4) <= rolx(bb(2)(4), 18); 	
	
	bb(3)(0) <= aa(0)(4) xor Du; 	cc(3)(0) <= rolx(bb(3)(0), 27); 
	bb(3)(1) <= aa(1)(0) xor Da; 	cc(3)(1) <= rolx(bb(3)(1), 36); 
	bb(3)(2) <= aa(2)(1) xor De; 	cc(3)(2) <= rolx(bb(3)(2), 10); 
	bb(3)(3) <= aa(3)(2) xor Di; 	cc(3)(3) <= rolx(bb(3)(3), 15); 
	bb(3)(4) <= aa(4)(3) xor Do;	cc(3)(4) <= rolx(bb(3)(4), 56); 
	
	bb(4)(0) <= aa(0)(2) xor Di; 	cc(4)(0) <= rolx(bb(4)(0), 62); 
	bb(4)(1) <= aa(1)(3) xor Do; 	cc(4)(1) <= rolx(bb(4)(1), 55); 
	bb(4)(2) <= aa(2)(4) xor Du; 	cc(4)(2) <= rolx(bb(4)(2), 39); 	
	bb(4)(3) <= aa(3)(0) xor Da; 	cc(4)(3) <= rolx(bb(4)(3), 41); 	
	bb(4)(4) <= aa(4)(1) xor De; 	cc(4)(4) <= rolx(bb(4)(4), 2); 		   
		   
	InterReg: process( clk )
	begin
		if rising_edge( clk ) then
			--if(gate = '1') then	
				dd     <= cc;
				rc_reg <= rc;
				enZ    <= en;
			--end if;	
		end if;
	end process;
	
	ee(0)(0) <=(dd(0)(0) xor ((not dd(0)(1)) and dd(0)(2))) xor rc_reg; 	
	ee(0)(1) <= dd(0)(1) xor ((not dd(0)(2)) and dd(0)(3)); 	
	ee(0)(2) <= dd(0)(2) xor ((not dd(0)(3)) and dd(0)(4)); 
	ee(0)(3) <= dd(0)(3) xor ((not dd(0)(4)) and dd(0)(0)); 	
	ee(0)(4) <= dd(0)(4) xor ((not dd(0)(0)) and dd(0)(1)); 
	        
	ee(1)(0) <= dd(1)(0) xor ((not dd(1)(1)) and dd(1)(2)); 		
	ee(1)(1) <= dd(1)(1) xor ((not dd(1)(2)) and dd(1)(3));	
	ee(1)(2) <= dd(1)(2) xor ((not dd(1)(3)) and dd(1)(4)); 
	ee(1)(3) <= dd(1)(3) xor ((not dd(1)(4)) and dd(1)(0)); 
	ee(1)(4) <= dd(1)(4) xor ((not dd(1)(0)) and dd(1)(1));
	        
	ee(2)(0) <= dd(2)(0) xor ((not dd(2)(1)) and dd(2)(2)); 
	ee(2)(1) <= dd(2)(1) xor ((not dd(2)(2)) and dd(2)(3)); 
	ee(2)(2) <= dd(2)(2) xor ((not dd(2)(3)) and dd(2)(4)); 
	ee(2)(3) <= dd(2)(3) xor ((not dd(2)(4)) and dd(2)(0)); 
	ee(2)(4) <= dd(2)(4) xor ((not dd(2)(0)) and dd(2)(1)); 	
	        
	ee(3)(0) <= dd(3)(0) xor ((not dd(3)(1)) and dd(3)(2)); 	
	ee(3)(1) <= dd(3)(1) xor ((not dd(3)(2)) and dd(3)(3)); 
	ee(3)(2) <= dd(3)(2) xor ((not dd(3)(3)) and dd(3)(4)); 
	ee(3)(3) <= dd(3)(3) xor ((not dd(3)(4)) and dd(3)(0)); 
	ee(3)(4) <= dd(3)(4) xor ((not dd(3)(0)) and dd(3)(1)); 
	        
	ee(4)(0) <= dd(4)(0) xor ((not dd(4)(1)) and dd(4)(2)); 
	ee(4)(1) <= dd(4)(1) xor ((not dd(4)(2)) and dd(4)(3)); 
	ee(4)(2) <= dd(4)(2) xor ((not dd(4)(3)) and dd(4)(4)); 
	ee(4)(3) <= dd(4)(3) xor ((not dd(4)(4)) and dd(4)(0)); 
	ee(4)(4) <= dd(4)(4) xor ((not dd(4)(0)) and dd(4)(1));    
	
	OutRowGen: 
	for i in 0 to 4 generate
		OutColGen: 
		for j in 0 to 4 generate
			rout_reg(KECCAK_STATE-(5*i+j)*64-1 downto KECCAK_STATE-(5*i+j)*64-64) <= ee(i)(j);
		end generate;
	end generate;

	process(clk)
	begin
		if rising_edge( clk ) then
			--if(gate = '1') then	
				rout   <= rout_reg;
				valid  <= enZ;
			--end if;	
		end if;
	end process;

end;	   
