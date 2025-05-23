library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use IEEE.MATH_REAL.ALL;

entity Keccak256_core_tb is
end;

architecture bench of Keccak256_core_tb is

  component Keccak256_core
  port(
  		reset         : in std_logic ;
  		clk           : in std_logic ;
  		en            : in std_logic ;
  		gate          : in std_logic ;
  		header_in     : in std_logic_vector(639 downto 0) ;
  		valid         : out std_logic ;
  		hash_out      : out std_logic_vector(255 downto 0) ;
  		DEBUG_port_in : in  std_logic_vector(32 downto 0) ;
  		DEBUG_port_out: out std_logic_vector(32 downto 0)
  	);
  end component;

  signal reset: std_logic;
  signal clk: std_logic;
  signal en: std_logic;
  signal gate: std_logic;
  signal header_in: std_logic_vector(639 downto 0);
  signal valid: std_logic;
  signal hash_out: std_logic_vector(255 downto 0);
  signal DEBUG_port_in: std_logic_vector(32 downto 0);
  signal DEBUG_port_out: std_logic_vector(32 downto 0) ;

  constant clock_period: time := 2 ns;
  signal   stop_the_clock: boolean;

  signal cnt_nonce: std_logic_vector(31 downto 0) ;
  constant NONCE_START: std_logic_vector(31 downto 0) := X"FF0EFFF0";
  constant NONCE_MAX: std_logic_vector(31 downto 0) := X"FF0F0000";

begin

  uut: Keccak256_core port map ( reset          => reset,
                                 clk            => clk,
                                 en             => en,
                                 gate           => gate,
                                 header_in      => header_in,
                                 valid          => valid,
                                 hash_out       => hash_out,
                                 DEBUG_port_in  => DEBUG_port_in,
                                 DEBUG_port_out => DEBUG_port_out );

  reset<= '1', '0' after 100 ns;
  
  process(clk, reset)
  begin
    if(reset = '1') then
      header_in <= (others=> '0');
      en   <= '0';
      gate <= '0';
      cnt_nonce <= NONCE_START;

    elsif(clk'event AND clk='1')then
      if(cnt_nonce = NONCE_START) then
        header_in <= X"200000028fa7db028bf3310f2c703bec66214b1d5b0ee0b477943a38adef21f9e20499bb15081eb5e881a59e61fcfc844664d2ed83fae2aef381af42b8549d4105c75f8c5eaee6b21b00e4bf00000000" + NONCE_START;
        en   <= '1';
        gate <= '1';
        cnt_nonce <= cnt_nonce + X"00000001";
      elsif (cnt_nonce = NONCE_MAX+1) then
        --header_in <= (others=> '0');
        en   <= '0';
        gate <= '1';
      else
        cnt_nonce <= cnt_nonce + X"00000001";
        header_in <= header_in+1;
        en   <= '1';
        gate <= '1'; 
      end if;     
    end if;
  end process;
  

  stimulus: process
  begin
    stop_the_clock <= false;
    wait;
  end process;

  clocking: process
  begin
    while not stop_the_clock loop
      clk <= '0', '1' after clock_period / 2;
      wait for clock_period;
    end loop;
    wait;
  end process;


end bench;
