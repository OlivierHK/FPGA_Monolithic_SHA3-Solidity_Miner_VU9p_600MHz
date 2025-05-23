library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use IEEE.MATH_REAL.ALL;

entity alto_top_tb is
end;

architecture bench of alto_top_tb is

  component alto_top
      Port (
          i_CLK_100M   : in  std_logic;
          i_RST_N      : in  std_logic;
          o_UART_TXD   : out std_logic;
          i_UART_RXD   : in  std_logic;
                  -- Sysmon I2C INTERFACE
          io_i2c_sclk  : inout STD_LOGIC;
          io_i2c_sda   : inout STD_LOGIC;
          o_DEBUG_PORT : out std_Logic_vector(7 downto 0)
      );
  end component;

  signal CLK_100M: std_logic;
  signal RST_N: std_logic;
  signal UART_TXD: std_logic;
  signal rx_uart: std_logic :='1';
  signal DEBUG_PORT: std_Logic_vector(7 downto 0) ;

  signal rio_i2c_sclk: std_logic :='H';
  signal rio_i2c_sda: std_logic :='H';

  constant clock_period: time := 10 ns;
  signal   stop_the_clock: boolean;

  constant uart_period : time := 8680.56 ns;


  --signal data_value  : std_logic_vector(7 downto 0) := "00000000";                 																																      8f0cfd12 is goldnonce  8C is 800MHz, 3 is Freq trig and header.
  																																																				                                                                                                      --000000008f0cfd12000000000000000000000000												  
  signal data_value  : std_logic_vector(767 downto 0) :=X"6b0d13638877fe9389f4d3287414b3d8189a1d04e6954168f0b467cd31773984363b5534fb8b5f615583c7329c9ca8ce6edaf6e6886c60378dc18856d5defa5c378a882365ed73a4e1f04262000000008f0cf000FFFFFFFF8000008C00000000";--return info data
  signal data_value2 : std_logic_vector(767 downto 0) :=X"6b0d13638877fe9389f4d3287414b3d8189a1d04e6954168f0b467cd31773984363b5534fb8b5f615583c7329c9ca8ce6edaf6e6886c60378dc18856d5defa5c378a882365ed73a4e1f04262000000008f0cf000FFFFFFFF8000008C00000003";--send header.
 

begin

  uut: alto_top port map ( i_CLK_100M   => CLK_100M,
                           i_RST_N      => RST_N,
                           o_UART_TXD   => UART_TXD,
                           i_UART_RXD   => rx_uart,
                           -- Sysmon I2C INTERFACE
          				   io_i2c_sclk  => rio_i2c_sclk,
          				   io_i2c_sda   => rio_i2c_sda,
                           o_DEBUG_PORT => DEBUG_PORT );

  --RST_N<= '0', '1' after 20000 ns, '0' after 50000 ns, '1' after 70000 ns;
  RST_N<= '0', '1' after 20000 ns;

  stimulus: process
  begin
    stop_the_clock <= false;
    wait;
  end process;

  clocking: process
  begin
    while not stop_the_clock loop
      CLK_100M <= '0', '1' after clock_period / 2;
      wait for clock_period;
    end loop;
    wait;
  end process;


  test_rx_uart : process
  variable n: integer := (data_value'LENGTH)-8;
  begin

    wait until RST_N = '1';

    wait for 20 us;

    rx_uart <= '1';
    
    
    wait until rising_edge(CLK_100M);

    --send read back command FGPA Info data
    for j in 0 to 95 loop
      rx_uart <= '0'; -- start bit
      wait for uart_period;

      for i in n to ( (n+8) -1) loop
        rx_uart <= data_value(i); -- data bits
        wait for uart_period;
      end loop;

      n:= n-8;
      rx_uart <= '1'; -- stop bit
      wait for uart_period;
      --data_value <= data_value + '1';
    end loop;


    wait for 8 us;
    n:= (data_value'LENGTH)-8;
    
    --send new header to FPGA
    for j in 0 to 95 loop
      rx_uart <= '0'; -- start bit
      wait for uart_period;

      for i in n to ( (n+8) -1) loop
        rx_uart <= data_value2(i); -- data bits
        wait for uart_period;
      end loop;

      n:= n-8;
      rx_uart <= '1'; -- stop bit
      wait for uart_period;
      --data_value <= data_value + '1';
    end loop;

    wait;

  end process;

end;