# FPGA_Monolithic_SHA3-Solidity_Miner_VU9p_600MHz_14.4GHs
## Summary

This project is a Full VHDL and Optimized Monolithic Implementation of the Solidity-SHA3 algorithm used by several POW Crypto currency (0xBitcoin, BNBTC, Etica,...).

It is designed to run on a XCVU9P-flga2104-2-i, for my Home-Brew Alto Platform, but can easily be updated to other Virtex Ultrascale+ (up to XCVU13p) or other plaform (like BCU1525).

This project is implementing a Floorplanned 24 Solidity-SHA3 Cores, filling up the VU9P at 99% and closing timing at 600MHz. As Cores frequency can be glitched-free sweep-up and Down, the design can be overclocked up to ~700MHz, depending on your silicon luck. With excellent cooling system, a max of 16.5GHs/s Hashrate had been tested and validated.

This design is implementing complex Reset mechanism and Xilinx Sysmon monitoring, coupled to the novative "Ping-Pong" dual-MMCM core frequency Sweep-Up/Down to avoid any damage on the FPGA by sudden power Dump or Over-Temperature.


Communication with the computer hosting the miner software is done via simple UART protocol (kudos to Jakub Cabal for his SIMPLE UART FOR FPGA design): 
- An input UART frame contains the message header to be hashed, and miner configuration (Core frequency, Voltage/Temperature shutdown values,...).
- An output UART frame contains a winning Nonce (Golden Ticket), and status of the FPGA.

- An extra I2C interface has been added for the Arduino/PMIC present on the Atlo platform to check FPGA's Sysmon status.

- A PCIe interface can later be implemented to get rid of the UART interface and to reduce overall latency.


## System Diagram and Hierarchy

The Top module is self-descripting and is showing all the sub-functions of the design:

- `UART.vhd` is responsible to intercept UART packet and generate a Byte of it if valid.
- `RX_Byte_decoder_FSM.vhd` concatenate UART_Rx bytes into a full 767-bits header to be hashed and decode data for clock fequency change command, or information request, if needed.
- `TX_Byte_decoder_FSM.vhd` concatenate Golden nonce with Status/information (if requested), and sent it by Byte to the UART_TX module.
- `mem_Rx.vhd` and `mem_Tx.vhd` are wrapper of DP_RAM that stores the Header and the golden_nonce.
- `HASH_FSM.vhd` sequence the receival of a new Header, then send it to the cores by chunk of 8-bits and triggering the hashing start. it also sequence the receival of a golden_nonce found and trigger its sending back to the computer.
- `PIPELINE_MODULE.vhd` are D flip-flop pipeline (fixed at 4), to spread signals accross all the FPGA, to the cores. The placer will help to spread them heavenly. There is 2 sub-modules: Forward and Backward one.
- `SHA3_Solidity_core_x.vhd` are duplicated core module (x24 for VU9P), carrefully floorplanned, that will reconstruct the header, add a starting nonce, and CDC the whole to the high-frequency area where it will be hashed. Every fast clock cycle give a nonce++. if the digested Hash have sufficent leading "0", the nonce is recovered, CDC to the fixed slow-frequency clock area and send back to the HASH_FSM.vhd module via the PIPELINE_MODULE.vhd. sub-modules and complete descrition is found later.

- `clock_module.vhd` take control of generating all the clock of the design. it takes 100MHz from the on-board oscillator chip and generate out via MMCM a slow 12MHz fixed system clock, and a glitch-free variable 100MHz-800MHz high-speed clock for the hashing cores. Sub-Modules and complete descrition is found later.
- `RST_Sync.vhd` is taking care of generating all the FPGA's internal reset signals. it also have the ability to shutdown automatically the high-speed core clock and reset the FPGA if any protection or alarm is ttiggered. its complete descrition is found later.
- `UART_WATCHDOG.vhd` is a running counter checking UART_Rx signals. if no signal received after a programmed period (~2 minutes), it will trigger the fast core clock to shutdown to save energy.
- `system_management.vhd` is a wrapper to call the x3 Sysmon IP modules of the FPGA (1 per SLR). it can be read by the outside world via the I2C bus.
- `MyPackage.vhd` is a set of constants and variables than can be modified to tune the project or to fit other Hashing algorithms. Comments inside the file are self-explaining in case of modification.

- The Debug_port can be assigned to any signal (slower or ASYNC is better, for timing/routing concern), and will drive the outside LEDs of the mezannine card. In this design, it has been assigned as:
  ```
  o_DEBUG_PORT(7) <= r_header_wr_en                             ;
  o_DEBUG_PORT(6) <= i_UART_RXD                                 ;
  o_DEBUG_PORT(5) <= r_SYNCED_nRST_12M                          ;
  o_DEBUG_PORT(4) <= r_SYNCED_nRST_500M_SYNC_12MZ               ;               

  if(r_timeout_UART_trig = '1') then 
      o_DEBUG_PORT(3) <= '1'                                    ; --latch timeout watchdog LED
  elsif (i_UART_RXD= '0') then    
      o_DEBUG_PORT(3) <= '0'                                    ; --clear timeout watchdog LED
  end if;
                
  o_DEBUG_PORT(2) <= r_CLK_status( 19) AND r_CLK_status(17)    ; --MMCM2_1 AND MMCM2_0 locked
  o_DEBUG_PORT(1) <= r_CLK_status(  3)                         ; --MMCM1 locked
  o_DEBUG_PORT(0) <= r_alarm_vector(0) or r_alarm_vector(1) or
                     r_alarm_vector(2) or r_alarm_vector(3) or
                     r_alarm_vector(4) or r_alarm_vector(5)    ;
  ```

As a top diagram:
![system_diagram](https://github.com/user-attachments/assets/0b91418f-5d8f-4593-be16-571b43f89fda)


## Project Pinout

The Project only consist of a few IO pins, all on +1.8V LVCMOS standard:

- An input 100MHz LVCMOS18 clock from external Oscillator IC.
- An input LVCMOS18 Active-Low Reset pin controlled by the Arduino.
- An LVCMOS18 UART Tx/Rx interface pair.
- An LVCMOS18 I2C interface (SDA/SCL) for Arduino to communicate with the FPGA's Sysmon module.
- An output LVCMOS18 Bye array for debugging (driving LEDs outside).

```
set_property PACKAGE_PIN BC10 [get_ports i_CLK_100M]
set_property IOSTANDARD LVCMOS18 [get_ports i_CLK_100M]

set_property PACKAGE_PIN BF11 [get_ports i_RST_N]
set_property IOSTANDARD LVCMOS18 [get_ports i_RST_N]

set_property PACKAGE_PIN BF10 [get_ports i_UART_RXD]
set_property IOSTANDARD LVCMOS18 [get_ports i_UART_RXD]

set_property PACKAGE_PIN BE10 [get_ports o_UART_TXD]
set_property IOSTANDARD LVCMOS18 [get_ports o_UART_TXD]

set_property PACKAGE_PIN BC35 [get_ports {o_DEBUG_PORT[7]}]
set_property PACKAGE_PIN BC36 [get_ports {o_DEBUG_PORT[6]}]
set_property PACKAGE_PIN BA36 [get_ports {o_DEBUG_PORT[5]}]
set_property PACKAGE_PIN BA37 [get_ports {o_DEBUG_PORT[4]}]
set_property PACKAGE_PIN BF34 [get_ports {o_DEBUG_PORT[3]}]
set_property PACKAGE_PIN BF35 [get_ports {o_DEBUG_PORT[2]}]
set_property PACKAGE_PIN BF36 [get_ports {o_DEBUG_PORT[1]}]
set_property PACKAGE_PIN BF27 [get_ports {o_DEBUG_PORT[0]}]

set_property IOSTANDARD LVCMOS18 [get_ports {o_DEBUG_PORT[*]}]


set_property PACKAGE_PIN AP18 [get_ports io_i2c_sclk]
set_property IOSTANDARD LVCMOS18 [get_ports io_i2c_sclk]

set_property PACKAGE_PIN AP17 [get_ports io_i2c_sda]
set_property IOSTANDARD LVCMOS18 [get_ports io_i2c_sda]
```

## Simulate the design

Several simple testbenches had been scattered to test different part of the design.
They are ModelSim compatible. Remember to compile the Xilinx Simulation IP libraries and import them in ModelSim to simulate the design.

in order to speed-up simulation time, put `constant SIMULATION: boolean:= true;`, and `constant SIMULATION_XOR5: boolean:= true;` in `MyPackage.vhd`.

- `Keccak256_core_tb.vhd` to simulate Solidity-SHA3 single hashing core.
- `PIPELINE_TOP_MODULE_tb.vhd` to simulate the forward/backward parametrable accross-the-chip data spreading pipelines.
- `CLOCK_MODULE_tb.vhd` to simulate the "Ping-Pong" dual-MMCM on-the-fly reconfiguration for core frequency smooth Sweep-up and Sweep-Down.
- `alto_top_tb.vhd` to simulate the whole design. Very time/ressource consumming as a whole UART frame input/output is generated if simulation mode is OFF.  


## Build the .bit file

The project and Scripts been targeted for Virtex Ultrascale+ VU9p (XCVU9P-flga2104-2-i).
Best to build under Linux (faster) and with Vivado 2023.1

1. run `Create_Project.Tcl` under Vivado Tcl mode.
2. open vivado and load project with the generated .xpr, and "Run Synthesys".
3. Once Synthesis completed, open the Design by selecting "open Synthesised Design".
4. Once Synthesised project opened, select "Tools/Run Tcl Sript" and open *Place_and_Opt.Tcl*.
5. Wait...(up to 24Hours, depending on your configuration).
6. Generated .bit file can be found in the root folder of the project.

## design Summary

### Design utilisation report:
```
SLR CLB Logic and Dedicated Block Utilization
---------------------------------------------

+----------------------------+--------+--------+--------+--------+--------+--------+
|          Site Type         |  SLR0  |  SLR1  |  SLR2  | SLR0 % | SLR1 % | SLR2 % |
+----------------------------+--------+--------+--------+--------+--------+--------+
| CLB                        |  48933 |  49117 |  48803 |  99.34 |  99.71 |  99.07 |
|   CLBL                     |  24518 |  24537 |  24497 |  99.67 |  99.74 |  99.58 |
|   CLBM                     |  24415 |  24580 |  24306 |  99.01 |  99.68 |  98.56 |
| CLB LUTs                   | 385162 | 387437 | 384855 |  97.74 |  98.31 |  97.66 |
|   LUT as Logic             | 385162 | 387437 | 384855 |  97.74 |  98.31 |  97.66 |
|     using O5 output only   |     43 |     67 |     43 |   0.01 |   0.02 |   0.01 |
|     using O6 output only   | 129815 | 131670 | 129443 |  32.94 |  33.41 |  32.85 |
|     using O5 and O6        | 255304 | 255700 | 255369 |  64.78 |  64.89 |  64.80 |
|   LUT as Memory            |      0 |      0 |      0 |   0.00 |   0.00 |   0.00 |
|     LUT as Distributed RAM |      0 |      0 |      0 |   0.00 |   0.00 |   0.00 |
|     LUT as Shift Register  |      0 |      0 |      0 |   0.00 |   0.00 |   0.00 |
| CLB Registers              | 595188 | 599939 | 592961 |  75.52 |  76.12 |  75.23 |
| CARRY8                     |    192 |    204 |    192 |   0.39 |   0.41 |   0.39 |
| F7 Muxes                   |      0 |      0 |      0 |   0.00 |   0.00 |   0.00 |
| F8 Muxes                   |      0 |      0 |      0 |   0.00 |   0.00 |   0.00 |
| F9 Muxes                   |      0 |      0 |      0 |   0.00 |   0.00 |   0.00 |
| Block RAM Tile             |      8 |   25.5 |      8 |   1.11 |   3.54 |   1.11 |
|   RAMB36/FIFO              |      8 |     25 |      8 |   1.11 |   3.47 |   1.11 |
|   RAMB18                   |      0 |      1 |      0 |   0.00 |   0.07 |   0.00 |
| URAM                       |      0 |      0 |      0 |   0.00 |   0.00 |   0.00 |
| DSPs                       |      0 |      0 |      0 |   0.00 |   0.00 |   0.00 |
| Unique Control Sets        |    154 |    237 |    135 |   0.16 |   0.24 |   0.14 |
+----------------------------+--------+--------+--------+--------+--------+--------+
* Note: Available Control Sets based on CLB Registers / 8
```

### Timing summary:
```
------------------------------------------------------------------------------------------------
| Design Timing Summary
| ---------------------
------------------------------------------------------------------------------------------------

    WNS(ns)      TNS(ns)  TNS Failing Endpoints  TNS Total Endpoints      WHS(ns)      THS(ns)  THS Failing Endpoints  THS Total Endpoints     WPWS(ns)     TPWS(ns)  TPWS Failing Endpoints  TPWS Total Endpoints  
    -------      -------  ---------------------  -------------------      -------      -------  ---------------------  -------------------     --------     --------  ----------------------  --------------------  
      0.001        0.000                      0              1836592        0.009        0.000                      0              1836544        0.291        0.000                       0               1788187  


All user specified timing constraints are met.


------------------------------------------------------------------------------------------------
| Clock Summary
| -------------
------------------------------------------------------------------------------------------------

Clock               Waveform(ns)         Period(ns)      Frequency(MHz)
-----               ------------         ----------      --------------
i_CLK_100M          {0.000 5.000}        10.000          100.000         
  CLK_MMCME_1_125M  {0.000 4.167}        8.333           120.000         
    CLK_MMCME_2_0   {0.000 5.000}        10.000          100.000         
      clk_500M_0    {0.000 0.833}        1.667           600.000         
    CLK_MMCME_2_1   {0.000 5.000}        10.000          100.000         
      clk_500M_1    {0.000 0.833}        1.667           600.000         
  CLK_MMCME_1_12M   {0.000 41.667}       83.333          12.000
```

### Post Place And Route Floorplan:

![PandR_floorplanning](https://github.com/user-attachments/assets/bdbfb172-5b4b-48a8-bd91-fc06302763dd)

