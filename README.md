# FPGA_Monolithic_SHA3-Solidity_Miner_VU9p_600MHz_14.4GHs
## Introduction

This project is a Full VHDL and Optimized Monolithic Implementation of the Solidity-SHA3 algorithm used by several POW Crypto currency (0xBitcoin, BNBTC, Etica,...).

It is designed to run on a XCVU9P-flga2104-2-i, for my Home-Brew Alto Platform, but can easily be updated to other Virtex Ultrascale+ (up to XCVU13p) or other plaform (like BCU1525).

This project is implementing 24 Solidity-SHA3 Cores, filling up the VU9P at 98,22% and closing timing at 600MHz. As Cores frequency can be glitched-free sweep-up and Down, the design can be overclocked up to ~700MHz, depending on your silicon luck. With excellent cooling system, a max of 16.5GHs/s Hashrate had been tested and validated.

This design is implementing complex Reset mechanism and Xilinx Sysmon monitoring, coupled to the novative "Ping-Pong" dual-MMCME core frequency Sweep-Up/Down to avoid any damage on the FPGA by sudden power Dump or Over-Temperature.


Communication with the computer hosting the miner software is done via simple UART protocol (kudos to Jakub Cabal for his SIMPLE UART FOR FPGA design). 
An input UART frame contains the message header to be hashed, and miner configuration (Core frequency, Voltage/Temperature shutdown values,...).
An output UART frame contains a winning Nonce (Golden Ticket), and status of the FPGA.

An extra I2C interface has been added for the Arduino/PMIC present on the Atlo platform to check FPGA's Sysmon status.

A PCIe interface can later be implemented to get rid of the UART interface and to reduce overall latency.




## Simulate the design

Several simple testbenches had been scattered to test different part of the design.
They are ModelSim compatible. Remember to compile the Xilinx Simulation IP libraries and import them in ModelSim to simulate the design.

in order to speed-up simulation time, put `constant SIMULATION: boolean:= true;` in MyPackage.vhd.

- *Keccak256_core_tb.vhd* to simulate Solidity-SHA3 single hashing core.
- *PIPELINE_TOP_MODULE_tb.vhd* to simulate the forward/backward parametrable accross-the-chip data spreading pipelines.
- *CLOCK_MODULE_tb.vhd* to simulate the "Ping-Pong" dual-MMCME on-the-fly reconfiguration for core frequency smooth Sweep-up and Sweep-Down.
- *alto_top_tb.vhd* to simulate the whole design. Very time/ressource consumming as a whole UART frame input/output is generated if simulation mode is OFF.  


## Build the .bit file

The project and Scripts been targeted for Virtex Ultrascale+ VU9p (XCVU9P-flga2104-2-i).
Best to build under Linux (faster) and with Vivado 2023.1

1- Open Vivado GUI and run *Setup_Project.Tcl*.
2- Once project Loaded, select "Run Synthesys" under the Vivado GUI.
3- Once Synthesis completed, open the Design by selecting "open Synthesised Design".
4- Once Synthesised project opened, select "Tools/Run Tcl Sript" and open *Place_and_Opt.Tcl*.
5- Wait...(up to 24Hours, depending on your configuration).
6- .bit file can be found in the root folder of the project.
