-- file: system_management_wiz_0.vhd
-- (c) Copyright 2013 - 2013 Xilinx, Inc. All rights reserved.
-- 
-- This file contains confidential and proprietary information
-- of Xilinx, Inc. and is protected under U.S. and
-- international copyright and other intellectual property
-- laws.
-- 
-- DISCLAIMER
-- This disclaimer is not a license and does not grant any
-- rights to the materials distributed herewith. Except as
-- otherwise provided in a valid license issued to you by
-- Xilinx, and to the maximum extent permitted by applicable
-- law: (1) THESE MATERIALS ARE MADE AVAILABLE "AS IS" AND
-- WITH ALL FAULTS, AND XILINX HEREBY DISCLAIMS ALL WARRANTIES
-- AND CONDITIONS, EXPRESS, IMPLIED, OR STATUTORY, INCLUDING
-- BUT NOT LIMITED TO WARRANTIES OF MERCHANTABILITY, NON-
-- INFRINGEMENT, OR FITNESS FOR ANY PARTICULAR PURPOSE; and
-- (2) Xilinx shall not be liable (whether in contract or tort,
-- including negligence, or under any other theory of
-- liability) for any loss or damage of any kind or nature
-- related to, arising under or in connection with these
-- materials, including for any direct, or any indirect,
-- special, incidental, or consequential loss or damage
-- (including loss of data, profits, goodwill, or any type of
-- loss or damage suffered as a result of any action brought
-- by a third party) even if such damage or loss was
-- reasonably foreseeable or Xilinx had been advised of the
-- possibility of the same.
-- 
-- CRITICAL APPLICATIONS
-- Xilinx products are not designed or intended to be fail-
-- safe, or for use in any application requiring fail-safe
-- performance, such as life-support or safety devices or
-- systems, Class III medical devices, nuclear facilities,
-- applications related to the deployment of airbags, or any
-- other applications that could lead to death, personal
-- injury, or severe property or environmental damage
-- (individually and collectively, "Critical
-- Applications"). Customer assumes the sole risk and
-- liability of any use of Xilinx products in Critical
-- Applications, subject only to applicable laws and
-- regulations governing limitations on product liability.
-- 
-- THIS COPYRIGHT NOTICE AND DISCLAIMER MUST BE RETAINED AS
-- PART OF THIS FILE AT ALL TIMES.

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
Library UNISIM;
use UNISIM.VCOMPONENTS.ALL;

entity system_management_wiz_0_sysmon is
   port
   (
    sysmon_slave_sel : in  std_logic_vector (1 downto 0);  
    daddr_in        : in  STD_LOGIC_VECTOR (7 downto 0);     -- Address bus for the dynamic reconfiguration port
    den_in          : in  STD_LOGIC;                         -- Enable Signal for the dynamic reconfiguration port
    di_in           : in  STD_LOGIC_VECTOR (15 downto 0);    -- Input data bus for the dynamic reconfiguration port
    dwe_in          : in  STD_LOGIC;                         -- Write Enable for the dynamic reconfiguration port
    do_out          : out  STD_LOGIC_VECTOR (15 downto 0);   -- Output data bus for dynamic reconfiguration port
    drdy_out        : out  STD_LOGIC;                        -- Data ready signal for the dynamic reconfiguration port
    dclk_in         : in  STD_LOGIC;                         -- Clock input for the dynamic reconfiguration port
    reset_in        : in  STD_LOGIC;                         -- Reset signal for the System Monitor control logic
    vp              : in  STD_LOGIC;
    vn              : in  STD_LOGIC;
    busy_out        : out  STD_LOGIC;                        -- ADC Busy signal
    channel_out     : out  STD_LOGIC_VECTOR (5 downto 0);    -- Channel Selection Outputs
    eoc_out         : out  STD_LOGIC;                        -- End of Conversion Signal
    eos_out         : out  STD_LOGIC;                        -- End of Sequence Signal
    ot_out          : out  STD_LOGIC;                        -- Over-Temperature alarm output
    user_supply0_alarm_out : out  STD_LOGIC;
    vccaux_alarm_out : out  STD_LOGIC;                        -- VCCAUX-sensor alarm output
    vccint_alarm_out : out  STD_LOGIC;                        -- VCCINT-sensor alarm output
    vbram_alarm_out : out  STD_LOGIC;                        -- VCCINT-sensor alarm output
    i2c_sclk            : inout STD_LOGIC;         
    i2c_sda             : inout STD_LOGIC;         
    alarm_out       : out STD_LOGIC
);
end system_management_wiz_0_sysmon;

architecture xilinx of system_management_wiz_0_sysmon is


  signal FLOAT_USER_TEMP_ALARM : std_logic;
  signal FLOAT_MUXADDR : std_logic_vector (4 downto 0);
  signal aux_channel_p : std_logic_vector (15 downto 0);
  signal aux_channel_n : std_logic_vector (15 downto 0);
  signal alm_int : std_logic_vector (15 downto 0);
signal i2c_sda_master : std_logic;
signal i2c_sclk_master : std_logic;
signal i2c_sda_slave0 : std_logic;
signal i2c_sclk_slave0 : std_logic;
signal i2c_sda_slave1 : std_logic;
signal i2c_sclk_slave1 : std_logic;
signal i2c_sda_slave2 : std_logic;
signal i2c_sclk_slave2 : std_logic;
signal i2c_sclk_int   : std_logic;
signal i2c_sda_int    : std_logic;
signal i2c_sda_ts   : std_logic;
signal i2c_sclk_ts  : std_logic;
signal i2c_sclk_int_master   : std_logic;
signal i2c_sda_int_master    : std_logic;
signal i2c_sda_ts_master   : std_logic;
signal i2c_sclk_ts_master  : std_logic;
signal smbalert_slave0  : std_logic;
signal smbalert_slave1  : std_logic;
signal smbalert_slave2  : std_logic;
signal smbalert_master  : std_logic;
signal vp_ssit_slave0 : std_logic;
signal vn_ssit_slave0 : std_logic;
signal vp_ssit_slave1 : std_logic;
signal vn_ssit_slave1 : std_logic;
signal vp_ssit_slave2 : std_logic;
signal vn_ssit_slave2 : std_logic;
signal alm_int_ssit_slave2 : std_logic_vector(15 downto 0);
signal alm_int_ssit_slave1 : std_logic_vector(15 downto 0);
signal alm_int_ssit_slave0 : std_logic_vector(15 downto 0);
signal i2c_sclk_int_slave0   : std_logic;
signal i2c_sda_int_slave0    : std_logic;
signal i2c_sda_ts_slave0   : std_logic;
signal i2c_sclk_ts_slave0  : std_logic;
signal i2c_sclk_int_slave1   : std_logic;
signal i2c_sda_int_slave1    : std_logic;
signal i2c_sda_ts_slave1   : std_logic;
signal i2c_sclk_ts_slave1  : std_logic;
signal i2c_sclk_int_slave2   : std_logic;
signal i2c_sda_int_slave2    : std_logic;
signal i2c_sda_ts_slave2   : std_logic;
signal i2c_sclk_ts_slave2  : std_logic;
signal dummy_aux_channel_n : std_logic_vector(15 downto 0);
signal dummy_aux_channel_p : std_logic_vector(15 downto 0);
signal do_out_ssit_master : std_logic_vector(15 downto 0);
signal do_out_ssit_slave0 : std_logic_vector(15 downto 0);
signal di_ssit_master : std_logic_vector(15 downto 0);
signal di_ssit_slave0 : std_logic_vector(15 downto 0);
signal daddr_ssit_master : std_logic_vector(7 downto 0);
signal daddr_ssit_slave0 : std_logic_vector(7 downto 0);
signal den_in_ssit_master : std_logic;
signal den_in_ssit_slave0 : std_logic;
signal dwe_ssit_master : std_logic;
signal dwe_ssit_slave0 : std_logic;
signal drdy_out_ssit_master : std_logic;
signal drdy_out_ssit_slave0 : std_logic;
signal eoc_out_ssit_master : std_logic;
signal eoc_out_ssit_slave0 : std_logic;
signal eos_out_ssit_master : std_logic;
signal eos_out_ssit_slave0 : std_logic;
signal busy_out_ssit_master : std_logic;
signal busy_out_ssit_slave0 : std_logic;
signal channel_out_ssit_master : std_logic_vector(5 downto 0);
signal channel_out_ssit_slave0 : std_logic_vector(5 downto 0);
signal ot_out_ssit_master : std_logic;
signal ot_out_ssit_slave0 : std_logic;
signal jtaglocked_out_ssit_master : std_logic;
signal jtaglocked_out_ssit_slave0 : std_logic;
signal jtagbusy_out_ssit_master : std_logic;
signal jtagbusy_out_ssit_slave0 : std_logic;
signal jtagmodified_out_ssit_master : std_logic;
signal jtagmodified_out_ssit_slave0 : std_logic;
signal muxaddr_out_ssit_master : std_logic_vector(4 downto 0);
signal muxaddr_out_ssit_slave0 : std_logic_vector(4 downto 0);
signal di_ssit_slave1 : std_logic_vector(15 downto 0);
signal daddr_ssit_slave1 : std_logic_vector(7 downto 0);
signal den_in_ssit_slave1 : std_logic;
signal dwe_ssit_slave1 : std_logic;
signal do_out_ssit_slave1 : std_logic_vector(15 downto 0);
signal drdy_out_ssit_slave1 : std_logic;
signal eoc_out_ssit_slave1 : std_logic;
signal eos_out_ssit_slave1 : std_logic;
signal busy_out_ssit_slave1 : std_logic;
signal channel_out_ssit_slave1 : std_logic_vector(5 downto 0);
signal ot_out_ssit_slave1 : std_logic;
signal jtaglocked_out_ssit_slave1 : std_logic;
signal jtagbusy_out_ssit_slave1 : std_logic;
signal jtagmodified_out_ssit_slave1 : std_logic;
signal muxaddr_out_ssit_slave1 : std_logic_vector(4 downto 0);

begin

          ot_out <= ot_out_ssit_master or ot_out_ssit_slave0 or ot_out_ssit_slave1;
          user_supply0_alarm_out <= alm_int(8) or alm_int_ssit_slave0(8) or alm_int_ssit_slave1(8);
          alarm_out <= alm_int(7) or alm_int_ssit_slave0(7) or alm_int_ssit_slave1(7);
          vbram_alarm_out <= alm_int(3) or alm_int_ssit_slave0(3) or alm_int_ssit_slave1(3);
          vccaux_alarm_out <= alm_int(2) or alm_int_ssit_slave0(2) or alm_int_ssit_slave1(2);
          vccint_alarm_out <= alm_int(1) or alm_int_ssit_slave0(1) or alm_int_ssit_slave1(1);


   dummy_aux_channel_n <= (others => 'Z');
   dummy_aux_channel_p <= (others => 'Z');

   aux_channel_p(0) <= '0';
   aux_channel_n(0) <= '0';
   aux_channel_p(1) <= '0';
   aux_channel_n(1) <= '0';
   aux_channel_p(2) <= '0';
   aux_channel_n(2) <= '0';
   aux_channel_p(3) <= '0';
   aux_channel_n(3) <= '0';
   aux_channel_p(4) <= '0';
   aux_channel_n(4) <= '0';
   aux_channel_p(5) <= '0';
   aux_channel_n(5) <= '0';
   aux_channel_p(6) <= '0';
   aux_channel_n(6) <= '0';
   aux_channel_p(7) <= '0';
   aux_channel_n(7) <= '0';
   aux_channel_p(8) <= '0';
   aux_channel_n(8) <= '0';
   aux_channel_p(9) <= '0';
   aux_channel_n(9) <= '0';
   aux_channel_p(10) <= '0';
   aux_channel_n(10) <= '0';
   aux_channel_p(11) <= '0';
   aux_channel_n(11) <= '0';
   aux_channel_p(12) <= '0';
   aux_channel_n(12) <= '0';
   aux_channel_p(13) <= '0';
   aux_channel_n(13) <= '0';
   aux_channel_p(14) <= '0';
   aux_channel_n(14) <= '0';
   aux_channel_p(15) <= '0';
   aux_channel_n(15) <= '0';
-- inout logic for i2c_sda and i2c_sclk ports
          i2c_sda_iobuf: IOBUF 
            port map (O => i2c_sda_int, 
             IO => i2c_sda,
             I => '0',
             T => i2c_sda_ts);
         
          i2c_sclk_iobuf: IOBUF 
            port map (O => i2c_sclk_int, 
             IO => i2c_sclk,
             I => '0',
             T => i2c_sclk_ts);
 i2c_sclk_ts <= i2c_sclk_ts_master and i2c_sclk_ts_slave0 and i2c_sclk_ts_slave1;
 i2c_sda_ts <= i2c_sda_ts_master and i2c_sda_ts_slave0 and i2c_sda_ts_slave1;


 inst_sysmon: SYSMONE4
     generic map(
        COMMON_N_SOURCE => X"FFFF", --Source for Common N Channels
        INIT_40 => X"0000", -- config reg 0
        INIT_41 => X"2E92", -- config reg 1
        INIT_42 => X"1400", -- config reg 2
        INIT_43 => X"208E", -- config reg 3
        INIT_44 => X"0000", -- config reg 4
        INIT_45 => X"EECC", -- Analog Bus Register
        INIT_46 => X"0001", -- Sequencer Channel selection (Vuser0-3)
        INIT_47 => X"0000", -- Sequencer Average selection (Vuser0-3)
        INIT_48 => X"4701", -- Sequencer channel selection
        INIT_49 => X"0000", -- Sequencer channel selection
        INIT_4A => X"0000", -- Sequencer Average selection
        INIT_4B => X"0000", -- Sequencer Average selection
        INIT_4C => X"0000", -- Sequencer Bipolar selection
        INIT_4D => X"0000", -- Sequencer Bipolar selection
        INIT_4E => X"0000", -- Sequencer Acq time selection
        INIT_4F => X"0000", -- Sequencer Acq time selection
        INIT_50 => X"B794", -- Temp alarm trigger
        INIT_51 => X"4E81", -- Vccint upper alarm limit
        INIT_52 => X"A147", -- Vccaux upper alarm limit
        INIT_53 => X"BF13", -- Temp alarm OT upper
        INIT_54 => X"AB02", -- Temp alarm reset
        INIT_55 => X"3C96", -- Vccint lower alarm limit
        INIT_56 => X"9111", -- Vccaux lower alarm limit
        INIT_57 => X"B794", -- Temp alarm OT reset
        INIT_58 => X"4E81", -- Vccbram upper alarm limit
        INIT_5C => X"4369", -- Vbccram lower alarm limit
        INIT_59 => X"4963", -- vccpsintlp upper alarm limit
        INIT_5D => X"451E", -- vccpsintlp lower alarm limit
        INIT_5A => X"4963", -- vccpsintfp upper alarm limit
        INIT_5E => X"451E", -- vccpsintfp lower alarm limit
        INIT_5B => X"9A74", -- vccpsaux upper alarm limit
        INIT_5F => X"91EB", -- vccpsaux lower alarm limit
        INIT_60 => X"4E81", -- Vuser0 upper alarm limit
        INIT_61 => X"4DA7", -- Vuser1 upper alarm limit
        INIT_62 => X"9A74", -- Vuser2 upper alarm limit
        INIT_63 => X"9A74", -- Vuser3 upper alarm limit
        INIT_68 => X"3C96", -- Vuser0 lower alarm limit
        INIT_69 => X"4BF2", -- Vuser1 lower alarm limit
        INIT_6A => X"98BF", -- Vuser2 lower alarm limit
        INIT_6B => X"98BF", -- Vuser3 lower alarm limit
        INIT_7A => X"0000", -- DUAL0 Register
        INIT_7B => X"0000", -- DUAL1 Register
        INIT_7C => X"0000", -- DUAL2 Register 
        INIT_7D => X"0000", -- DUAL3 Register
        SYSMON_VUSER0_BANK    => 45,
        SYSMON_VUSER0_MONITOR => "VCCINT",
        SIM_DEVICE => "ULTRASCALE_PLUS",
        SIM_MONITOR_FILE => "design.dat"
        )

port map (
        ADC_DATA            => open,
        CONVST              => '0',
        CONVSTCLK           => '0',
        DADDR               => daddr_in,
        DCLK                => dclk_in,
        DEN                 => den_in_ssit_master,
        DI(15 downto 0)     => di_in(15 downto 0),
        DWE                 => dwe_in,
        RESET               => reset_in,
        VAUXN(15 downto 0)  => aux_channel_n(15 downto 0),
        VAUXP(15 downto 0)  => aux_channel_p(15 downto 0),
        ALM                 => alm_int,
        BUSY                => busy_out_ssit_master,
        CHANNEL             => channel_out_ssit_master,
        DO(15 downto 0)     => do_out_ssit_master(15 downto 0),
        DRDY                => drdy_out_ssit_master,
        EOC                 => eoc_out_ssit_master,
        EOS                 => eos_out_ssit_master,
        JTAGBUSY            => open,
        JTAGLOCKED          => open,
        JTAGMODIFIED        => open,
        OT                  => ot_out_ssit_master,
        I2C_SCLK             => i2c_sclk_int,
        I2C_SDA              => i2c_sda_int,
        I2C_SCLK_TS          => i2c_sclk_ts_master,
        I2C_SDA_TS           => i2c_sda_ts_master,
        SMBALERT_TS           => open,
     
        MUXADDR             => open,
        VN                  => vn,
        VP                  => vp
         );

inst_sysmon_ssit_slave0: SYSMONE4 
     generic map (
        COMMON_N_SOURCE => X"FFFF", --Source for Common N Channels
        INIT_40 => X"0000", -- config reg 0
        INIT_41 => X"2E92", -- config reg 1
        INIT_42 => X"1400", -- config reg 2
        INIT_43 => X"208E", -- config reg 3
        INIT_44 => X"0000", -- config reg 4
        INIT_45 => X"EDCC", -- Analog Bus Register
        INIT_46 => X"0001", -- Sequencer Channel selection (Vuser0-3)
        INIT_47 => X"0000", -- Sequencer Average selection (Vuser0-3)
        INIT_48 => X"0100", -- Sequencer channel selection
        INIT_49 => X"0000", -- Sequencer channel selection
        INIT_4A => X"0000", -- Sequencer Average selection
        INIT_4B => X"0000", -- Sequencer Average selection
        INIT_4C => X"0000", -- Sequencer Bipolar selection
        INIT_4D => X"0000", -- Sequencer Bipolar selection
        INIT_4E => X"0000", -- Sequencer Acq time selection
        INIT_4F => X"0000", -- Sequencer Acq time selection
        INIT_50 => X"B794", -- Temp alarm trigger
        INIT_51 => X"4E81", -- Vccint upper alarm limit
        INIT_52 => X"A147", -- Vccaux upper alarm limit
        INIT_53 => X"BF13", -- Temp alarm OT upper
        INIT_54 => X"AB02", -- Temp alarm reset
        INIT_55 => X"3C96", -- Vccint lower alarm limit
        INIT_56 => X"9111", -- Vccaux lower alarm limit
        INIT_57 => X"B794", -- Temp alarm OT reset
        INIT_58 => X"4E81", -- VCCBRAM upper alarm limit
        INIT_5C => X"4369", --  VCCBRAM lower alarm limit
        INIT_59 => X"4963", -- vccpsintlp upper alarm limit
        INIT_5D => X"451E", --  vccpsintlp lower alarm limit
        INIT_5A => X"4963", -- vccpsintfp upper alarm limit
        INIT_5E => X"451E", --  vccpsintfp lower alarm limit
        INIT_5B => X"9A74", -- vccpsaux upper alarm limit
        INIT_5F => X"91EB", --  vccpsaux lower alarm limit
        INIT_60 => X"4E81", -- Vuser0 upper alarm limit
        INIT_61 => X"4DA7", -- Vuser1 upper alarm limit
        INIT_62 => X"9A74", -- Vuser2 upper alarm limit
        INIT_63 => X"9A74", -- Vuser3 upper alarm limit
        INIT_68 => X"3C96", -- Vuser0 lower alarm limit
        INIT_69 => X"4BF2", -- Vuser1 lower alarm limit
        INIT_6A => X"98BF", -- Vuser2 lower alarm limit
        INIT_6B => X"98BF", -- Vuser3 lower alarm limit
        INIT_7A => X"0000", -- DUAL0 Register
        INIT_7B => X"0000", -- DUAL1 Register
        INIT_7C => X"0000", -- DUAL2 Register 
        INIT_7D => X"0000", -- DUAL3 Register
        SYSMON_VUSER0_BANK => 40,
        SYSMON_VUSER0_MONITOR => "VCCINT",
        SIM_DEVICE => "ULTRASCALE_PLUS",
        SIM_MONITOR_FILE => "design.dat"
        )
port map (
        ADC_DATA            => open,
        CONVST              => '0',
        CONVSTCLK           => '0',
        DADDR               => daddr_in,
        DCLK                => dclk_in,
        DEN                 => den_in_ssit_slave0,
        DI(15 downto 0)     => di_in(15 downto 0),
        DWE                 => dwe_in,
        RESET               => reset_in,
        VAUXN               => dummy_aux_channel_n,
        VAUXP               => dummy_aux_channel_p,
        ALM                 => alm_int_ssit_slave0,
        BUSY                => busy_out_ssit_slave0,
        CHANNEL             => channel_out_ssit_slave0,
        DO(15 downto 0)     => do_out_ssit_slave0(15 downto 0),
        DRDY                => drdy_out_ssit_slave0,
        EOC                 => eoc_out_ssit_slave0,
        EOS                 => eos_out_ssit_slave0,
        JTAGBUSY            => open,
        JTAGLOCKED          => open,
        JTAGMODIFIED        => open,
        OT                  => ot_out_ssit_slave0,
        I2C_SCLK             => i2c_sclk_int,
        I2C_SDA              => i2c_sda_int,
        I2C_SCLK_TS          => i2c_sclk_ts_slave0,
        I2C_SDA_TS           => i2c_sda_ts_slave0,
        SMBALERT_TS           => open,
     
        MUXADDR             => open,
        VN                  => vn_ssit_slave0,
        VP                  => vp_ssit_slave0
         );


inst_sysmon_ssit_slave1: SYSMONE4 
     generic map (
        COMMON_N_SOURCE => X"FFFF", --Source for Common N Channels
        INIT_40 => X"0000", -- config reg 0
        INIT_41 => X"2E92", -- config reg 1
        INIT_42 => X"1400", -- config reg 2
        INIT_43 => X"208E", -- config reg 3
        INIT_44 => X"0000", -- config reg 4
        INIT_45 => X"EDCC", -- Analog Bus Register
        INIT_46 => X"0001", -- Sequencer Channel selection (Vuser0-3)
        INIT_47 => X"0000", -- Sequencer Average selection (Vuser0-3)
        INIT_48 => X"0100", -- Sequencer channel selection
        INIT_49 => X"0000", -- Sequencer channel selection
        INIT_4A => X"0000", -- Sequencer Average selection
        INIT_4B => X"0000", -- Sequencer Average selection
        INIT_4C => X"0000", -- Sequencer Bipolar selection
        INIT_4D => X"0000", -- Sequencer Bipolar selection
        INIT_4E => X"0000", -- Sequencer Acq time selection
        INIT_4F => X"0000", -- Sequencer Acq time selection
        INIT_50 => X"B794", -- Temp alarm trigger
        INIT_51 => X"4E81", -- Vccint upper alarm limit
        INIT_52 => X"A147", -- Vccaux upper alarm limit
        INIT_53 => X"BF13", -- Temp alarm OT upper
        INIT_54 => X"AB02", -- Temp alarm reset
        INIT_55 => X"3C96", -- Vccint lower alarm limit
        INIT_56 => X"9111", -- Vccaux lower alarm limit
        INIT_57 => X"B794", -- Temp alarm OT reset
        INIT_58 => X"4E81", -- VCCBRAM upper alarm limit
        INIT_5C => X"4369", --  VCCBRAM lower alarm limit
        INIT_59 => X"4963", -- vccpsintlp upper alarm limit
        INIT_5D => X"451E", --  vccpsintlp lower alarm limit
        INIT_5A => X"4963", -- vccpsintfp upper alarm limit
        INIT_5E => X"451E", --  vccpsintfp lower alarm limit
        INIT_5B => X"9A74", -- vccpsaux upper alarm limit
        INIT_5F => X"91EB", --  vccpsaux lower alarm limit
        INIT_60 => X"4E81", -- Vuser0 upper alarm limit
        INIT_61 => X"4DA7", -- Vuser1 upper alarm limit
        INIT_62 => X"9A74", -- Vuser2 upper alarm limit
        INIT_63 => X"9A74", -- Vuser3 upper alarm limit
        INIT_68 => X"3C96", -- Vuser0 lower alarm limit
        INIT_69 => X"4BF2", -- Vuser1 lower alarm limit
        INIT_6A => X"98BF", -- Vuser2 lower alarm limit
        INIT_6B => X"98BF", -- Vuser3 lower alarm limit
        INIT_7A => X"0000", -- DUAL0 Register
        INIT_7B => X"0000", -- DUAL1 Register
        INIT_7C => X"0000", -- DUAL2 Register 
        INIT_7D => X"0000", -- DUAL3 Register
        SYSMON_VUSER0_BANK => 70,
        SYSMON_VUSER0_MONITOR => "VCCINT",
        SIM_DEVICE => "ULTRASCALE_PLUS",
        SIM_MONITOR_FILE => "design.dat"
)

port map (
        ADC_DATA            => open,
        CONVST              => '0',
        CONVSTCLK           => '0',
        DADDR               => daddr_in,
        DCLK                => dclk_in,
        DEN                 => den_in_ssit_slave1,
        DI(15 downto 0)     => di_in(15 downto 0),
        DWE                 => dwe_in,
        RESET               => reset_in,
        VAUXN               => dummy_aux_channel_n,
        VAUXP               => dummy_aux_channel_p,
        ALM                 => alm_int_ssit_slave1,
        BUSY                => busy_out_ssit_slave1,
        CHANNEL             => channel_out_ssit_slave1,
        DO(15 downto 0)     => do_out_ssit_slave1(15 downto 0),
        DRDY                => drdy_out_ssit_slave1,
        EOC                 => eoc_out_ssit_slave1,
        EOS                 => eos_out_ssit_slave1,
        JTAGBUSY            => open,
        JTAGLOCKED          => open,
        JTAGMODIFIED        => open,
        OT                  => ot_out_ssit_slave1,
        I2C_SCLK             => i2c_sclk_int,
        I2C_SDA              => i2c_sda_int,
        I2C_SCLK_TS          => i2c_sclk_ts_slave1,
        I2C_SDA_TS           => i2c_sda_ts_slave1,
        SMBALERT_TS           => open,
     
        MUXADDR             => open,
        VN                  => vn_ssit_slave1,
        VP                  => vp_ssit_slave1
         );


    den_in_ssit_master <= den_in when (sysmon_slave_sel = "00") else 
                          '0';
    den_in_ssit_slave0 <= den_in when (sysmon_slave_sel = "01") else 
                          '0';
    den_in_ssit_slave1 <= den_in when (sysmon_slave_sel = "10") else 
                          '0';
    drdy_out <= drdy_out_ssit_master or drdy_out_ssit_slave0 or drdy_out_ssit_slave1;
    do_out <= do_out_ssit_master when (drdy_out_ssit_master = '1') else 
                   do_out_ssit_slave0 when (drdy_out_ssit_slave0 = '1') else
                   do_out_ssit_slave1 when (drdy_out_ssit_slave1 = '1') else 
                   "0000000000000000";


    channel_out <= channel_out_ssit_master when (sysmon_slave_sel = "00") else 
                   channel_out_ssit_slave0 when (sysmon_slave_sel = "01") else
                   channel_out_ssit_slave1 when (sysmon_slave_sel = "10") else
                   "000000";
    eoc_out <= eoc_out_ssit_master when (sysmon_slave_sel = "00") else 
                   eoc_out_ssit_slave0 when (sysmon_slave_sel = "01") else
                   eoc_out_ssit_slave1 when (sysmon_slave_sel = "10") else
                   '0';
    eos_out <= eos_out_ssit_master when (sysmon_slave_sel = "00") else 
                   eos_out_ssit_slave0 when (sysmon_slave_sel = "01") else 
                   eos_out_ssit_slave1 when (sysmon_slave_sel = "10") else
                   '0';
    busy_out <= busy_out_ssit_master when (sysmon_slave_sel = "00") else 
                   busy_out_ssit_slave0 when (sysmon_slave_sel = "01") else 
                   busy_out_ssit_slave1 when (sysmon_slave_sel = "10") else
                   '0';
end xilinx;

