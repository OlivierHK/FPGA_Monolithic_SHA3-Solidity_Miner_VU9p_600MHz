# FPGA_Monolithic_SHA3-Solidity_Miner_VU9p_600MHz_14.4GHs
## Introduction

This project is a Full VHDL and Optimized Monolithic Implementation of the Solidity-SHA3 algorithm used by several POW Crypto currency (0xBitcoin, BNBTC, Etica,...).

It is designed to run on a XCVU9P-flga2104-2-i, for my Home-Brew Alto Platform, but can easily be updated to other Virtex Ultrascale+ (up to XCVU13p) or other plaform (like BCU1525).

This project is implementing 24 Solidity-SHA3 Cores, filling up the VU9P at 98,22% and closing timing at 600MHz. As Cores frequency can be glitched-free sweep-up and Down, the design can be overclocked up to ~700MHz, depending on your silicon luck. With excellent cooling system, a max of 16.5GHs/s Hashrate had been tested and validated.

This design is implementing complex Reset mechanism and Xilinx Sysmon monitoring, coupled to the novative "Ping-Pong" dual-MMCM core frequency Sweep-Up/Down to avoid any damage on the FPGA by sudden power Dump or Over-Temperature.


Communication with the computer hosting the miner software is done via simple UART protocol (kudos to Jakub Cabal for his SIMPLE UART FOR FPGA design): 
- An input UART frame contains the message header to be hashed, and miner configuration (Core frequency, Voltage/Temperature shutdown values,...).
- An output UART frame contains a winning Nonce (Golden Ticket), and status of the FPGA.

- An extra I2C interface has been added for the Arduino/PMIC present on the Atlo platform to check FPGA's Sysmon status.

- A PCIe interface can later be implemented to get rid of the UART interface and to reduce overall latency.




## Simulate the design

Several simple testbenches had been scattered to test different part of the design.
They are ModelSim compatible. Remember to compile the Xilinx Simulation IP libraries and import them in ModelSim to simulate the design.

in order to speed-up simulation time, put `constant SIMULATION: boolean:= true;` in `MyPackage.vhd`.

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
### Design utilisation report
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
### Timing summary
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
