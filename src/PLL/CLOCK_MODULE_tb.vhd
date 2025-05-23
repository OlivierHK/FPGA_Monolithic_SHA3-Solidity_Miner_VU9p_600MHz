library IEEE;
use IEEE.Std_logic_1164.all;
--use IEEE.Numeric_Std.all;
use IEEE.MATH_REAL.ALL;

entity CLOCK_MODULE_tb is
end;

architecture bench of CLOCK_MODULE_tb is

  component CLOCK_MODULE
      Port ( 
        i_nreset                  : in  STD_LOGIC;
        i_CLK_100M                : in  STD_LOGIC;
     
        i_shutdown_hash_CMD       : in  STD_LOGIC;
     
        i_HASH_FREQUENCY_TRIG     : in  STD_LOGIC;
        i_HASH_FREQUENCY_CMD      : in  STD_LOGIC_VECTOR( 7 downto 0);
     
        o_CLK_status              : out STD_LOGIC_VECTOR(31 downto 0);
     
        o_CLK_12M                 : out STD_LOGIC;
        o_CLK_HASH                : out STD_LOGIC;

        o_CLK_FSM_BUSY            : out STD_LOGIC;
             
        o_locked_CLKSYS_100M      : out STD_LOGIC;
        o_locked_CLK_12M          : out STD_LOGIC;
        o_locked_CLK_HASH_0       : out STD_LOGIC;
        o_locked_CLK_HASH_1       : out STD_LOGIC         
      );
  end component;

  component RST_SYNC
    Port (
        i_CLK_12M                 : in  std_logic;
        i_CLK_500M                : in  std_logic;
        
        i_ASYNC_nRST              : in  std_logic; --unsync

        i_locked_CLKSYS_100M      : in  std_logic; --unsync
        i_locked_CLK_12M          : in  std_logic; --unsync
        i_locked_CLK_HASH_0       : in  std_logic; --sync 12MHz
        i_locked_CLK_HASH_1       : in  std_logic; --sync 12MHz

        i_FSM_Busy                : in  std_logic; --sync 12MHz

        i_alarm_vector            : in   STD_LOGIC_VECTOR (7 downto 0);
        o_shutdown_hash_CMD       : out  STD_LOGIC;

        o_SYNCED_nRST_12M         : out std_logic; --sync 12MHz
        o_SYNCED_nRST_CLK_FSM_12M : out std_logic; --sync 12MHz


        o_SYNCED_nRST_500M        : out std_logic  --sync 12MHz
    );
  end component;


  constant clock_period         : time   := 10 ns;
  signal   stop_the_clock       : boolean;

  signal i_CLK_100M             : STD_LOGIC ;

  signal i_HASH_FREQUENCY_TRIG  : STD_LOGIC:= '0' ;
  signal i_HASH_FREQUENCY_CMD   : STD_LOGIC_VECTOR (7 downto 0) := (others => '0');
  
  signal i_alarm_vector         : STD_LOGIC_VECTOR (7 downto 0) := (others => '0');
  signal i_shutdown_hash_CMD    : STD_LOGIC;

  signal o_CLK_status           : STD_LOGIC_VECTOR (31 downto 0);

  signal o_CLK_FSM_BUSY         : STD_LOGIC;

  signal o_CLK_12M              : STD_LOGIC ;
  signal o_CLK_HASH             : STD_LOGIC ;
  signal o_locked_CLKSYS_100M   : STD_LOGIC ;
  signal o_locked_CLK_12M       : STD_LOGIC ;
  signal o_locked_CLK_HASH_0    : STD_LOGIC ;
  signal o_locked_CLK_HASH_1    : STD_LOGIC ;


  signal TB_phase_printout      : string(1 to 20) := "RESET..............."; 


  signal i_ASYNC_nRST              : STD_LOGIC ;

  signal o_SYNCED_nRST_12M         : STD_LOGIC ;
  signal o_SYNCED_nRST_CLK_FSM_12M : STD_LOGIC ;
  signal o_SYNCED_nRST_500M        : STD_LOGIC ;
          


begin

  uut: CLOCK_MODULE port map ( i_nreset                 => o_SYNCED_nRST_CLK_FSM_12M,
                               i_CLK_100M               => i_CLK_100M,
                               i_shutdown_hash_CMD      => i_shutdown_hash_CMD,
                               i_HASH_FREQUENCY_TRIG    => i_HASH_FREQUENCY_TRIG,
                               i_HASH_FREQUENCY_CMD     => i_HASH_FREQUENCY_CMD,
                               o_CLK_status             => o_CLK_status,
                               o_CLK_12M                => o_CLK_12M,
                               o_CLK_HASH               => o_CLK_HASH,
                               o_CLK_FSM_BUSY           => o_CLK_FSM_BUSY,
                               o_locked_CLKSYS_100M     => o_locked_CLKSYS_100M,
                               o_locked_CLK_12M         => o_locked_CLK_12M,    
                               o_locked_CLK_HASH_0      => o_locked_CLK_HASH_0, 
                               o_locked_CLK_HASH_1      => o_locked_CLK_HASH_1 
                              );



  uut_rst: RST_SYNC port map( i_CLK_12M                 => o_CLK_12M,
                              i_CLK_500M                => o_CLK_HASH,
                              i_ASYNC_nRST              => i_ASYNC_nRST,
                              i_locked_CLKSYS_100M      => o_locked_CLKSYS_100M,
                              i_locked_CLK_12M          => o_locked_CLK_12M,
                              i_locked_CLK_HASH_0       => o_locked_CLK_HASH_0,
                              i_locked_CLK_HASH_1       => o_locked_CLK_HASH_1,
                              i_FSM_Busy                => o_CLK_FSM_BUSY,
                              o_shutdown_hash_CMD       => i_shutdown_hash_CMD,
                              i_alarm_vector            => i_alarm_vector,
                              o_SYNCED_nRST_12M         => o_SYNCED_nRST_12M,
                              o_SYNCED_nRST_CLK_FSM_12M => o_SYNCED_nRST_CLK_FSM_12M,
                              o_SYNCED_nRST_500M        => o_SYNCED_nRST_500M
                              );

  

  ------------------------------global reset----------------------------------
  i_ASYNC_nRST <= '0', '1' after 100 ns, '0' after 300 us,  '1' after 600 us;

  ---------------------------Board 100 MZh clock------------------------------
  stimulus: process
  begin
    stop_the_clock <= false;
    wait;
  end process;

  --100MHz Board Ref clock generation
  clocking: process
  begin
    while not stop_the_clock loop
      i_CLK_100M <= '0', '1' after clock_period / 2;
      wait for clock_period;
    end loop;
    wait;
  end process;

  --process to meaure Clock frequency
  Measure_CLK_HASH: process
  variable v_TIME       : time := 0 ps;
  variable v_Freq_Measured : real := 0.0 ;
  begin
    wait until rising_edge (o_CLK_HASH);
    v_TIME:= now;
    wait until rising_edge (o_CLK_HASH);
    v_TIME:= now - v_TIME;
    v_Freq_Measured:= 1000000.0/(real(v_TIME/1 ps));
  end process;  

-----------------------------------DRP State machine----------------------------
  DRP_access: process
  begin
    wait until rising_edge(o_CLK_12M);
    wait until i_ASYNC_nRST = '1';

    wait until o_locked_CLK_HASH_0='1';
    wait for 5 us;
        ---------------------------------------------------------------------------
        TB_phase_printout <= "Command Sweep up....";
        wait until rising_edge(o_CLK_12M);
        i_HASH_FREQUENCY_TRIG <= '1';
        i_HASH_FREQUENCY_CMD  <= X"0A";
        wait until rising_edge(o_CLK_12M);
        i_HASH_FREQUENCY_TRIG <= '0';
      
        wait for 700 us;

        TB_phase_printout <= "Command Sweep up....";
        wait until rising_edge(o_CLK_12M);
        i_HASH_FREQUENCY_TRIG <= '1';
        i_HASH_FREQUENCY_CMD  <= X"97";
        wait until rising_edge(o_CLK_12M);
        i_HASH_FREQUENCY_TRIG <= '0';

        wait for 3000 us ;

        TB_phase_printout <= "Command Sweep down..";
        wait until rising_edge(o_CLK_12M);
        i_HASH_FREQUENCY_TRIG <= '1';
        i_HASH_FREQUENCY_CMD  <= X"06";
        wait until rising_edge(o_CLK_12M);
        i_HASH_FREQUENCY_TRIG <= '0';


        wait for 3000 us;
        TB_phase_printout <= "Command Shutdown....";
        wait until rising_edge(o_CLK_12M);
        i_alarm_vector <= X"01";

        wait until rising_edge(o_CLK_12M);
        i_alarm_vector <= X"00";


        wait for 500 us;
        TB_phase_printout <= "Command Sweep up....";
        wait until rising_edge(o_CLK_12M);
        i_HASH_FREQUENCY_TRIG <= '1';
        i_HASH_FREQUENCY_CMD  <= X"12";
        wait until rising_edge(o_CLK_12M);
        i_HASH_FREQUENCY_TRIG <= '0';

        wait for 500 us;
        TB_phase_printout <= "Command Same........";
        wait until rising_edge(o_CLK_12M);
        i_HASH_FREQUENCY_TRIG <= '1';
        i_HASH_FREQUENCY_CMD  <= X"12";
        wait until rising_edge(o_CLK_12M);
        i_HASH_FREQUENCY_TRIG <= '0';


        wait until rising_edge(o_CLK_12M);

        wait until rising_edge(o_CLK_12M);

  wait;      
  end process;    


end;