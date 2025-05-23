-- Copyright 1986-2022 Xilinx, Inc. All Rights Reserved.
-- --------------------------------------------------------------------------------
-- Tool Version: Vivado v.2022.2 (win64) Build 3671981 Fri Oct 14 05:00:03 MDT 2022
-- Date        : Thu Apr 20 00:06:51 2023
-- Host        : DESKTOP-K57QLE9 running 64-bit major release  (build 9200)
-- Command     : write_vhdl -force -mode funcsim {c:/Projects/Alto-Ultra+ -
--               0xbitcoin/project_1/project_1.gen/sources_1/ip/system_management_wiz_0_2/system_management_wiz_0_sim_netlist.vhdl}
-- Design      : system_management_wiz_0
-- Purpose     : This VHDL netlist is a functional simulation representation of the design and should not be modified or
--               synthesized. This netlist cannot be used for SDF annotated simulation.
-- Device      : xcvu9p-flga2104-2-i
-- --------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
library UNISIM;
use UNISIM.VCOMPONENTS.ALL;
entity system_management_wiz_0_sysmon is
  port (
    sysmon_slave_sel : in STD_LOGIC_VECTOR ( 1 downto 0 );
    daddr_in : in STD_LOGIC_VECTOR ( 7 downto 0 );
    den_in : in STD_LOGIC;
    di_in : in STD_LOGIC_VECTOR ( 15 downto 0 );
    dwe_in : in STD_LOGIC;
    do_out : out STD_LOGIC_VECTOR ( 15 downto 0 );
    drdy_out : out STD_LOGIC;
    dclk_in : in STD_LOGIC;
    reset_in : in STD_LOGIC;
    vp : in STD_LOGIC;
    vn : in STD_LOGIC;
    busy_out : out STD_LOGIC;
    channel_out : out STD_LOGIC_VECTOR ( 5 downto 0 );
    eoc_out : out STD_LOGIC;
    eos_out : out STD_LOGIC;
    ot_out : out STD_LOGIC;
    user_supply0_alarm_out : out STD_LOGIC;
    vccaux_alarm_out : out STD_LOGIC;
    vccint_alarm_out : out STD_LOGIC;
    vbram_alarm_out : out STD_LOGIC;
    i2c_sclk : inout STD_LOGIC;
    i2c_sda : inout STD_LOGIC;
    alarm_out : out STD_LOGIC
  );
end system_management_wiz_0_sysmon;

architecture STRUCTURE of system_management_wiz_0_sysmon is
  signal DEN : STD_LOGIC;
  signal DO : STD_LOGIC_VECTOR ( 15 downto 0 );
  signal T : STD_LOGIC;
  signal T0_out : STD_LOGIC;
  signal alm_int : STD_LOGIC_VECTOR ( 8 downto 1 );
  signal alm_int_ssit_slave0 : STD_LOGIC_VECTOR ( 8 downto 1 );
  signal alm_int_ssit_slave1 : STD_LOGIC_VECTOR ( 8 downto 1 );
  signal busy_out_ssit_master : STD_LOGIC;
  signal busy_out_ssit_slave0 : STD_LOGIC;
  signal busy_out_ssit_slave1 : STD_LOGIC;
  signal channel_out_ssit_master : STD_LOGIC_VECTOR ( 5 downto 0 );
  signal channel_out_ssit_slave0 : STD_LOGIC_VECTOR ( 5 downto 0 );
  signal channel_out_ssit_slave1 : STD_LOGIC_VECTOR ( 5 downto 0 );
  signal drdy_out_ssit_master : STD_LOGIC;
  signal drdy_out_ssit_slave0 : STD_LOGIC;
  signal drdy_out_ssit_slave1 : STD_LOGIC;
  signal dummy_aux_channel_n : STD_LOGIC_VECTOR ( 15 downto 0 );
  signal dummy_aux_channel_p : STD_LOGIC_VECTOR ( 15 downto 0 );
  signal eoc_out_ssit_master : STD_LOGIC;
  signal eoc_out_ssit_slave0 : STD_LOGIC;
  signal eoc_out_ssit_slave1 : STD_LOGIC;
  signal eos_out_ssit_master : STD_LOGIC;
  signal eos_out_ssit_slave0 : STD_LOGIC;
  signal eos_out_ssit_slave1 : STD_LOGIC;
  signal i2c_sclk_int : STD_LOGIC;
  signal i2c_sclk_ts_master : STD_LOGIC;
  signal i2c_sclk_ts_slave0 : STD_LOGIC;
  signal i2c_sclk_ts_slave1 : STD_LOGIC;
  signal i2c_sda_int : STD_LOGIC;
  signal i2c_sda_ts_master : STD_LOGIC;
  signal i2c_sda_ts_slave0 : STD_LOGIC;
  signal i2c_sda_ts_slave1 : STD_LOGIC;
  signal inst_sysmon_ssit_slave0_i_1_n_0 : STD_LOGIC;
  signal inst_sysmon_ssit_slave0_n_43 : STD_LOGIC;
  signal inst_sysmon_ssit_slave0_n_44 : STD_LOGIC;
  signal inst_sysmon_ssit_slave0_n_45 : STD_LOGIC;
  signal inst_sysmon_ssit_slave0_n_46 : STD_LOGIC;
  signal inst_sysmon_ssit_slave0_n_47 : STD_LOGIC;
  signal inst_sysmon_ssit_slave0_n_48 : STD_LOGIC;
  signal inst_sysmon_ssit_slave0_n_49 : STD_LOGIC;
  signal inst_sysmon_ssit_slave0_n_50 : STD_LOGIC;
  signal inst_sysmon_ssit_slave0_n_51 : STD_LOGIC;
  signal inst_sysmon_ssit_slave0_n_52 : STD_LOGIC;
  signal inst_sysmon_ssit_slave0_n_53 : STD_LOGIC;
  signal inst_sysmon_ssit_slave0_n_54 : STD_LOGIC;
  signal inst_sysmon_ssit_slave0_n_55 : STD_LOGIC;
  signal inst_sysmon_ssit_slave0_n_56 : STD_LOGIC;
  signal inst_sysmon_ssit_slave0_n_57 : STD_LOGIC;
  signal inst_sysmon_ssit_slave0_n_58 : STD_LOGIC;
  signal inst_sysmon_ssit_slave1_i_1_n_0 : STD_LOGIC;
  signal inst_sysmon_ssit_slave1_n_43 : STD_LOGIC;
  signal inst_sysmon_ssit_slave1_n_44 : STD_LOGIC;
  signal inst_sysmon_ssit_slave1_n_45 : STD_LOGIC;
  signal inst_sysmon_ssit_slave1_n_46 : STD_LOGIC;
  signal inst_sysmon_ssit_slave1_n_47 : STD_LOGIC;
  signal inst_sysmon_ssit_slave1_n_48 : STD_LOGIC;
  signal inst_sysmon_ssit_slave1_n_49 : STD_LOGIC;
  signal inst_sysmon_ssit_slave1_n_50 : STD_LOGIC;
  signal inst_sysmon_ssit_slave1_n_51 : STD_LOGIC;
  signal inst_sysmon_ssit_slave1_n_52 : STD_LOGIC;
  signal inst_sysmon_ssit_slave1_n_53 : STD_LOGIC;
  signal inst_sysmon_ssit_slave1_n_54 : STD_LOGIC;
  signal inst_sysmon_ssit_slave1_n_55 : STD_LOGIC;
  signal inst_sysmon_ssit_slave1_n_56 : STD_LOGIC;
  signal inst_sysmon_ssit_slave1_n_57 : STD_LOGIC;
  signal inst_sysmon_ssit_slave1_n_58 : STD_LOGIC;
  signal ot_out_ssit_master : STD_LOGIC;
  signal ot_out_ssit_slave0 : STD_LOGIC;
  signal ot_out_ssit_slave1 : STD_LOGIC;
  signal NLW_inst_sysmon_JTAGBUSY_UNCONNECTED : STD_LOGIC;
  signal NLW_inst_sysmon_JTAGLOCKED_UNCONNECTED : STD_LOGIC;
  signal NLW_inst_sysmon_JTAGMODIFIED_UNCONNECTED : STD_LOGIC;
  signal NLW_inst_sysmon_SMBALERT_TS_UNCONNECTED : STD_LOGIC;
  signal NLW_inst_sysmon_ADC_DATA_UNCONNECTED : STD_LOGIC_VECTOR ( 15 downto 0 );
  signal NLW_inst_sysmon_ALM_UNCONNECTED : STD_LOGIC_VECTOR ( 15 downto 0 );
  signal NLW_inst_sysmon_MUXADDR_UNCONNECTED : STD_LOGIC_VECTOR ( 4 downto 0 );
  signal NLW_inst_sysmon_ssit_slave0_JTAGBUSY_UNCONNECTED : STD_LOGIC;
  signal NLW_inst_sysmon_ssit_slave0_JTAGLOCKED_UNCONNECTED : STD_LOGIC;
  signal NLW_inst_sysmon_ssit_slave0_JTAGMODIFIED_UNCONNECTED : STD_LOGIC;
  signal NLW_inst_sysmon_ssit_slave0_SMBALERT_TS_UNCONNECTED : STD_LOGIC;
  signal NLW_inst_sysmon_ssit_slave0_VN_UNCONNECTED : STD_LOGIC;
  signal NLW_inst_sysmon_ssit_slave0_VP_UNCONNECTED : STD_LOGIC;
  signal NLW_inst_sysmon_ssit_slave0_ADC_DATA_UNCONNECTED : STD_LOGIC_VECTOR ( 15 downto 0 );
  signal NLW_inst_sysmon_ssit_slave0_ALM_UNCONNECTED : STD_LOGIC_VECTOR ( 15 downto 0 );
  signal NLW_inst_sysmon_ssit_slave0_MUXADDR_UNCONNECTED : STD_LOGIC_VECTOR ( 4 downto 0 );
  signal NLW_inst_sysmon_ssit_slave1_JTAGBUSY_UNCONNECTED : STD_LOGIC;
  signal NLW_inst_sysmon_ssit_slave1_JTAGLOCKED_UNCONNECTED : STD_LOGIC;
  signal NLW_inst_sysmon_ssit_slave1_JTAGMODIFIED_UNCONNECTED : STD_LOGIC;
  signal NLW_inst_sysmon_ssit_slave1_SMBALERT_TS_UNCONNECTED : STD_LOGIC;
  signal NLW_inst_sysmon_ssit_slave1_VN_UNCONNECTED : STD_LOGIC;
  signal NLW_inst_sysmon_ssit_slave1_VP_UNCONNECTED : STD_LOGIC;
  signal NLW_inst_sysmon_ssit_slave1_ADC_DATA_UNCONNECTED : STD_LOGIC_VECTOR ( 15 downto 0 );
  signal NLW_inst_sysmon_ssit_slave1_ALM_UNCONNECTED : STD_LOGIC_VECTOR ( 15 downto 0 );
  signal NLW_inst_sysmon_ssit_slave1_MUXADDR_UNCONNECTED : STD_LOGIC_VECTOR ( 4 downto 0 );
  attribute box_type : string;
  attribute box_type of i2c_sclk_iobuf : label is "PRIMITIVE";
  attribute box_type of i2c_sda_iobuf : label is "PRIMITIVE";
  attribute box_type of inst_sysmon : label is "PRIMITIVE";
  attribute box_type of inst_sysmon_ssit_slave0 : label is "PRIMITIVE";
  attribute SOFT_HLUTNM : string;
  attribute SOFT_HLUTNM of inst_sysmon_ssit_slave0_i_1 : label is "soft_lutpair0";
  attribute box_type of inst_sysmon_ssit_slave1 : label is "PRIMITIVE";
  attribute SOFT_HLUTNM of inst_sysmon_ssit_slave1_i_1 : label is "soft_lutpair0";
begin
  dummy_aux_channel_n(0) <= 'Z';
  dummy_aux_channel_n(10) <= 'Z';
  dummy_aux_channel_n(11) <= 'Z';
  dummy_aux_channel_n(12) <= 'Z';
  dummy_aux_channel_n(13) <= 'Z';
  dummy_aux_channel_n(14) <= 'Z';
  dummy_aux_channel_n(15) <= 'Z';
  dummy_aux_channel_n(1) <= 'Z';
  dummy_aux_channel_n(2) <= 'Z';
  dummy_aux_channel_n(3) <= 'Z';
  dummy_aux_channel_n(4) <= 'Z';
  dummy_aux_channel_n(5) <= 'Z';
  dummy_aux_channel_n(6) <= 'Z';
  dummy_aux_channel_n(7) <= 'Z';
  dummy_aux_channel_n(8) <= 'Z';
  dummy_aux_channel_n(9) <= 'Z';
  dummy_aux_channel_p(0) <= 'Z';
  dummy_aux_channel_p(10) <= 'Z';
  dummy_aux_channel_p(11) <= 'Z';
  dummy_aux_channel_p(12) <= 'Z';
  dummy_aux_channel_p(13) <= 'Z';
  dummy_aux_channel_p(14) <= 'Z';
  dummy_aux_channel_p(15) <= 'Z';
  dummy_aux_channel_p(1) <= 'Z';
  dummy_aux_channel_p(2) <= 'Z';
  dummy_aux_channel_p(3) <= 'Z';
  dummy_aux_channel_p(4) <= 'Z';
  dummy_aux_channel_p(5) <= 'Z';
  dummy_aux_channel_p(6) <= 'Z';
  dummy_aux_channel_p(7) <= 'Z';
  dummy_aux_channel_p(8) <= 'Z';
  dummy_aux_channel_p(9) <= 'Z';
alarm_out_INST_0: unisim.vcomponents.LUT3
    generic map(
      INIT => X"FE"
    )
        port map (
      I0 => alm_int(7),
      I1 => alm_int_ssit_slave0(7),
      I2 => alm_int_ssit_slave1(7),
      O => alarm_out
    );
busy_out_INST_0: unisim.vcomponents.LUT5
    generic map(
      INIT => X"30BB3088"
    )
        port map (
      I0 => busy_out_ssit_slave0,
      I1 => sysmon_slave_sel(0),
      I2 => busy_out_ssit_slave1,
      I3 => sysmon_slave_sel(1),
      I4 => busy_out_ssit_master,
      O => busy_out
    );
\channel_out[0]_INST_0\: unisim.vcomponents.LUT5
    generic map(
      INIT => X"30BB3088"
    )
        port map (
      I0 => channel_out_ssit_slave0(0),
      I1 => sysmon_slave_sel(0),
      I2 => channel_out_ssit_slave1(0),
      I3 => sysmon_slave_sel(1),
      I4 => channel_out_ssit_master(0),
      O => channel_out(0)
    );
\channel_out[1]_INST_0\: unisim.vcomponents.LUT5
    generic map(
      INIT => X"30BB3088"
    )
        port map (
      I0 => channel_out_ssit_slave0(1),
      I1 => sysmon_slave_sel(0),
      I2 => channel_out_ssit_slave1(1),
      I3 => sysmon_slave_sel(1),
      I4 => channel_out_ssit_master(1),
      O => channel_out(1)
    );
\channel_out[2]_INST_0\: unisim.vcomponents.LUT5
    generic map(
      INIT => X"30BB3088"
    )
        port map (
      I0 => channel_out_ssit_slave0(2),
      I1 => sysmon_slave_sel(0),
      I2 => channel_out_ssit_slave1(2),
      I3 => sysmon_slave_sel(1),
      I4 => channel_out_ssit_master(2),
      O => channel_out(2)
    );
\channel_out[3]_INST_0\: unisim.vcomponents.LUT5
    generic map(
      INIT => X"30BB3088"
    )
        port map (
      I0 => channel_out_ssit_slave0(3),
      I1 => sysmon_slave_sel(0),
      I2 => channel_out_ssit_slave1(3),
      I3 => sysmon_slave_sel(1),
      I4 => channel_out_ssit_master(3),
      O => channel_out(3)
    );
\channel_out[4]_INST_0\: unisim.vcomponents.LUT5
    generic map(
      INIT => X"30BB3088"
    )
        port map (
      I0 => channel_out_ssit_slave0(4),
      I1 => sysmon_slave_sel(0),
      I2 => channel_out_ssit_slave1(4),
      I3 => sysmon_slave_sel(1),
      I4 => channel_out_ssit_master(4),
      O => channel_out(4)
    );
\channel_out[5]_INST_0\: unisim.vcomponents.LUT5
    generic map(
      INIT => X"30BB3088"
    )
        port map (
      I0 => channel_out_ssit_slave0(5),
      I1 => sysmon_slave_sel(0),
      I2 => channel_out_ssit_slave1(5),
      I3 => sysmon_slave_sel(1),
      I4 => channel_out_ssit_master(5),
      O => channel_out(5)
    );
\do_out[0]_INST_0\: unisim.vcomponents.LUT6
    generic map(
      INIT => X"B8BBB888B888B888"
    )
        port map (
      I0 => DO(0),
      I1 => drdy_out_ssit_master,
      I2 => inst_sysmon_ssit_slave0_n_58,
      I3 => drdy_out_ssit_slave0,
      I4 => drdy_out_ssit_slave1,
      I5 => inst_sysmon_ssit_slave1_n_58,
      O => do_out(0)
    );
\do_out[10]_INST_0\: unisim.vcomponents.LUT6
    generic map(
      INIT => X"B8BBB888B888B888"
    )
        port map (
      I0 => DO(10),
      I1 => drdy_out_ssit_master,
      I2 => inst_sysmon_ssit_slave0_n_48,
      I3 => drdy_out_ssit_slave0,
      I4 => drdy_out_ssit_slave1,
      I5 => inst_sysmon_ssit_slave1_n_48,
      O => do_out(10)
    );
\do_out[11]_INST_0\: unisim.vcomponents.LUT6
    generic map(
      INIT => X"B8BBB888B888B888"
    )
        port map (
      I0 => DO(11),
      I1 => drdy_out_ssit_master,
      I2 => inst_sysmon_ssit_slave0_n_47,
      I3 => drdy_out_ssit_slave0,
      I4 => drdy_out_ssit_slave1,
      I5 => inst_sysmon_ssit_slave1_n_47,
      O => do_out(11)
    );
\do_out[12]_INST_0\: unisim.vcomponents.LUT6
    generic map(
      INIT => X"B8BBB888B888B888"
    )
        port map (
      I0 => DO(12),
      I1 => drdy_out_ssit_master,
      I2 => inst_sysmon_ssit_slave0_n_46,
      I3 => drdy_out_ssit_slave0,
      I4 => drdy_out_ssit_slave1,
      I5 => inst_sysmon_ssit_slave1_n_46,
      O => do_out(12)
    );
\do_out[13]_INST_0\: unisim.vcomponents.LUT6
    generic map(
      INIT => X"B8BBB888B888B888"
    )
        port map (
      I0 => DO(13),
      I1 => drdy_out_ssit_master,
      I2 => inst_sysmon_ssit_slave0_n_45,
      I3 => drdy_out_ssit_slave0,
      I4 => drdy_out_ssit_slave1,
      I5 => inst_sysmon_ssit_slave1_n_45,
      O => do_out(13)
    );
\do_out[14]_INST_0\: unisim.vcomponents.LUT6
    generic map(
      INIT => X"B8BBB888B888B888"
    )
        port map (
      I0 => DO(14),
      I1 => drdy_out_ssit_master,
      I2 => inst_sysmon_ssit_slave0_n_44,
      I3 => drdy_out_ssit_slave0,
      I4 => drdy_out_ssit_slave1,
      I5 => inst_sysmon_ssit_slave1_n_44,
      O => do_out(14)
    );
\do_out[15]_INST_0\: unisim.vcomponents.LUT6
    generic map(
      INIT => X"B8BBB888B888B888"
    )
        port map (
      I0 => DO(15),
      I1 => drdy_out_ssit_master,
      I2 => inst_sysmon_ssit_slave0_n_43,
      I3 => drdy_out_ssit_slave0,
      I4 => drdy_out_ssit_slave1,
      I5 => inst_sysmon_ssit_slave1_n_43,
      O => do_out(15)
    );
\do_out[1]_INST_0\: unisim.vcomponents.LUT6
    generic map(
      INIT => X"B8BBB888B888B888"
    )
        port map (
      I0 => DO(1),
      I1 => drdy_out_ssit_master,
      I2 => inst_sysmon_ssit_slave0_n_57,
      I3 => drdy_out_ssit_slave0,
      I4 => drdy_out_ssit_slave1,
      I5 => inst_sysmon_ssit_slave1_n_57,
      O => do_out(1)
    );
\do_out[2]_INST_0\: unisim.vcomponents.LUT6
    generic map(
      INIT => X"B8BBB888B888B888"
    )
        port map (
      I0 => DO(2),
      I1 => drdy_out_ssit_master,
      I2 => inst_sysmon_ssit_slave0_n_56,
      I3 => drdy_out_ssit_slave0,
      I4 => drdy_out_ssit_slave1,
      I5 => inst_sysmon_ssit_slave1_n_56,
      O => do_out(2)
    );
\do_out[3]_INST_0\: unisim.vcomponents.LUT6
    generic map(
      INIT => X"B8BBB888B888B888"
    )
        port map (
      I0 => DO(3),
      I1 => drdy_out_ssit_master,
      I2 => inst_sysmon_ssit_slave0_n_55,
      I3 => drdy_out_ssit_slave0,
      I4 => drdy_out_ssit_slave1,
      I5 => inst_sysmon_ssit_slave1_n_55,
      O => do_out(3)
    );
\do_out[4]_INST_0\: unisim.vcomponents.LUT6
    generic map(
      INIT => X"B8BBB888B888B888"
    )
        port map (
      I0 => DO(4),
      I1 => drdy_out_ssit_master,
      I2 => inst_sysmon_ssit_slave0_n_54,
      I3 => drdy_out_ssit_slave0,
      I4 => drdy_out_ssit_slave1,
      I5 => inst_sysmon_ssit_slave1_n_54,
      O => do_out(4)
    );
\do_out[5]_INST_0\: unisim.vcomponents.LUT6
    generic map(
      INIT => X"B8BBB888B888B888"
    )
        port map (
      I0 => DO(5),
      I1 => drdy_out_ssit_master,
      I2 => inst_sysmon_ssit_slave0_n_53,
      I3 => drdy_out_ssit_slave0,
      I4 => drdy_out_ssit_slave1,
      I5 => inst_sysmon_ssit_slave1_n_53,
      O => do_out(5)
    );
\do_out[6]_INST_0\: unisim.vcomponents.LUT6
    generic map(
      INIT => X"B8BBB888B888B888"
    )
        port map (
      I0 => DO(6),
      I1 => drdy_out_ssit_master,
      I2 => inst_sysmon_ssit_slave0_n_52,
      I3 => drdy_out_ssit_slave0,
      I4 => drdy_out_ssit_slave1,
      I5 => inst_sysmon_ssit_slave1_n_52,
      O => do_out(6)
    );
\do_out[7]_INST_0\: unisim.vcomponents.LUT6
    generic map(
      INIT => X"B8BBB888B888B888"
    )
        port map (
      I0 => DO(7),
      I1 => drdy_out_ssit_master,
      I2 => inst_sysmon_ssit_slave0_n_51,
      I3 => drdy_out_ssit_slave0,
      I4 => drdy_out_ssit_slave1,
      I5 => inst_sysmon_ssit_slave1_n_51,
      O => do_out(7)
    );
\do_out[8]_INST_0\: unisim.vcomponents.LUT6
    generic map(
      INIT => X"B8BBB888B888B888"
    )
        port map (
      I0 => DO(8),
      I1 => drdy_out_ssit_master,
      I2 => inst_sysmon_ssit_slave0_n_50,
      I3 => drdy_out_ssit_slave0,
      I4 => drdy_out_ssit_slave1,
      I5 => inst_sysmon_ssit_slave1_n_50,
      O => do_out(8)
    );
\do_out[9]_INST_0\: unisim.vcomponents.LUT6
    generic map(
      INIT => X"B8BBB888B888B888"
    )
        port map (
      I0 => DO(9),
      I1 => drdy_out_ssit_master,
      I2 => inst_sysmon_ssit_slave0_n_49,
      I3 => drdy_out_ssit_slave0,
      I4 => drdy_out_ssit_slave1,
      I5 => inst_sysmon_ssit_slave1_n_49,
      O => do_out(9)
    );
drdy_out_INST_0: unisim.vcomponents.LUT3
    generic map(
      INIT => X"FE"
    )
        port map (
      I0 => drdy_out_ssit_master,
      I1 => drdy_out_ssit_slave0,
      I2 => drdy_out_ssit_slave1,
      O => drdy_out
    );
eoc_out_INST_0: unisim.vcomponents.LUT5
    generic map(
      INIT => X"30BB3088"
    )
        port map (
      I0 => eoc_out_ssit_slave0,
      I1 => sysmon_slave_sel(0),
      I2 => eoc_out_ssit_slave1,
      I3 => sysmon_slave_sel(1),
      I4 => eoc_out_ssit_master,
      O => eoc_out
    );
eos_out_INST_0: unisim.vcomponents.LUT5
    generic map(
      INIT => X"30BB3088"
    )
        port map (
      I0 => eos_out_ssit_slave0,
      I1 => sysmon_slave_sel(0),
      I2 => eos_out_ssit_slave1,
      I3 => sysmon_slave_sel(1),
      I4 => eos_out_ssit_master,
      O => eos_out
    );
i2c_sclk_iobuf: unisim.vcomponents.IOBUF
    generic map(
      IOSTANDARD => "DEFAULT"
    )
        port map (
      I => '0',
      IO => i2c_sclk,
      O => i2c_sclk_int,
      T => T0_out
    );
i2c_sclk_iobuf_i_1: unisim.vcomponents.LUT3
    generic map(
      INIT => X"80"
    )
        port map (
      I0 => i2c_sclk_ts_master,
      I1 => i2c_sclk_ts_slave0,
      I2 => i2c_sclk_ts_slave1,
      O => T0_out
    );
i2c_sda_iobuf: unisim.vcomponents.IOBUF
    generic map(
      IOSTANDARD => "DEFAULT"
    )
        port map (
      I => '0',
      IO => i2c_sda,
      O => i2c_sda_int,
      T => T
    );
i2c_sda_iobuf_i_1: unisim.vcomponents.LUT3
    generic map(
      INIT => X"80"
    )
        port map (
      I0 => i2c_sda_ts_master,
      I1 => i2c_sda_ts_slave0,
      I2 => i2c_sda_ts_slave1,
      O => T
    );
inst_sysmon: unisim.vcomponents.SYSMONE4
    generic map(
      COMMON_N_SOURCE => X"FFFF",
      INIT_40 => X"0000",
      INIT_41 => X"2E92",
      INIT_42 => X"1400",
      INIT_43 => X"208E",
      INIT_44 => X"0000",
      INIT_45 => X"EECC",
      INIT_46 => X"0001",
      INIT_47 => X"0000",
      INIT_48 => X"4701",
      INIT_49 => X"0000",
      INIT_4A => X"0000",
      INIT_4B => X"0000",
      INIT_4C => X"0000",
      INIT_4D => X"0000",
      INIT_4E => X"0000",
      INIT_4F => X"0000",
      INIT_50 => X"B794",
      INIT_51 => X"4E81",
      INIT_52 => X"A147",
      INIT_53 => X"BF13",
      INIT_54 => X"AB02",
      INIT_55 => X"3C96",
      INIT_56 => X"9111",
      INIT_57 => X"B794",
      INIT_58 => X"4E81",
      INIT_59 => X"4963",
      INIT_5A => X"4963",
      INIT_5B => X"9A74",
      INIT_5C => X"4369",
      INIT_5D => X"451E",
      INIT_5E => X"451E",
      INIT_5F => X"91EB",
      INIT_60 => X"4E81",
      INIT_61 => X"4DA7",
      INIT_62 => X"9A74",
      INIT_63 => X"9A74",
      INIT_64 => X"0000",
      INIT_65 => X"0000",
      INIT_66 => X"0000",
      INIT_67 => X"0000",
      INIT_68 => X"3C96",
      INIT_69 => X"4BF2",
      INIT_6A => X"98BF",
      INIT_6B => X"98BF",
      INIT_6C => X"0000",
      INIT_6D => X"0000",
      INIT_6E => X"0000",
      INIT_6F => X"0000",
      INIT_70 => X"0000",
      INIT_71 => X"0000",
      INIT_72 => X"0000",
      INIT_73 => X"0000",
      INIT_74 => X"0000",
      INIT_75 => X"0000",
      INIT_76 => X"0000",
      INIT_77 => X"0000",
      INIT_78 => X"0000",
      INIT_79 => X"0000",
      INIT_7A => X"0000",
      INIT_7B => X"0000",
      INIT_7C => X"0000",
      INIT_7D => X"0000",
      INIT_7E => X"0000",
      INIT_7F => X"0000",
      IS_CONVSTCLK_INVERTED => '0',
      IS_DCLK_INVERTED => '0',
      SIM_DEVICE => "ULTRASCALE_PLUS",
      SIM_MONITOR_FILE => "design.dat",
      SYSMON_VUSER0_BANK => 45,
      SYSMON_VUSER0_MONITOR => "VCCINT",
      SYSMON_VUSER1_BANK => 0,
      SYSMON_VUSER1_MONITOR => "NONE",
      SYSMON_VUSER2_BANK => 0,
      SYSMON_VUSER2_MONITOR => "NONE",
      SYSMON_VUSER3_BANK => 0,
      SYSMON_VUSER3_MONITOR => "NONE"
    )
        port map (
      ADC_DATA(15 downto 0) => NLW_inst_sysmon_ADC_DATA_UNCONNECTED(15 downto 0),
      ALM(15 downto 9) => NLW_inst_sysmon_ALM_UNCONNECTED(15 downto 9),
      ALM(8 downto 7) => alm_int(8 downto 7),
      ALM(6 downto 4) => NLW_inst_sysmon_ALM_UNCONNECTED(6 downto 4),
      ALM(3 downto 1) => alm_int(3 downto 1),
      ALM(0) => NLW_inst_sysmon_ALM_UNCONNECTED(0),
      BUSY => busy_out_ssit_master,
      CHANNEL(5 downto 0) => channel_out_ssit_master(5 downto 0),
      CONVST => '0',
      CONVSTCLK => '0',
      DADDR(7 downto 0) => daddr_in(7 downto 0),
      DCLK => dclk_in,
      DEN => DEN,
      DI(15 downto 0) => di_in(15 downto 0),
      DO(15 downto 0) => DO(15 downto 0),
      DRDY => drdy_out_ssit_master,
      DWE => dwe_in,
      EOC => eoc_out_ssit_master,
      EOS => eos_out_ssit_master,
      I2C_SCLK => i2c_sclk_int,
      I2C_SCLK_TS => i2c_sclk_ts_master,
      I2C_SDA => i2c_sda_int,
      I2C_SDA_TS => i2c_sda_ts_master,
      JTAGBUSY => NLW_inst_sysmon_JTAGBUSY_UNCONNECTED,
      JTAGLOCKED => NLW_inst_sysmon_JTAGLOCKED_UNCONNECTED,
      JTAGMODIFIED => NLW_inst_sysmon_JTAGMODIFIED_UNCONNECTED,
      MUXADDR(4 downto 0) => NLW_inst_sysmon_MUXADDR_UNCONNECTED(4 downto 0),
      OT => ot_out_ssit_master,
      RESET => reset_in,
      SMBALERT_TS => NLW_inst_sysmon_SMBALERT_TS_UNCONNECTED,
      VAUXN(15 downto 0) => B"0000000000000000",
      VAUXP(15 downto 0) => B"0000000000000000",
      VN => '0',
      VP => '0'
    );
inst_sysmon_i_1: unisim.vcomponents.LUT3
    generic map(
      INIT => X"02"
    )
        port map (
      I0 => den_in,
      I1 => sysmon_slave_sel(0),
      I2 => sysmon_slave_sel(1),
      O => DEN
    );
inst_sysmon_ssit_slave0: unisim.vcomponents.SYSMONE4
    generic map(
      COMMON_N_SOURCE => X"FFFF",
      INIT_40 => X"0000",
      INIT_41 => X"2E92",
      INIT_42 => X"1400",
      INIT_43 => X"208E",
      INIT_44 => X"0000",
      INIT_45 => X"EDCC",
      INIT_46 => X"0001",
      INIT_47 => X"0000",
      INIT_48 => X"0100",
      INIT_49 => X"0000",
      INIT_4A => X"0000",
      INIT_4B => X"0000",
      INIT_4C => X"0000",
      INIT_4D => X"0000",
      INIT_4E => X"0000",
      INIT_4F => X"0000",
      INIT_50 => X"B794",
      INIT_51 => X"4E81",
      INIT_52 => X"A147",
      INIT_53 => X"BF13",
      INIT_54 => X"AB02",
      INIT_55 => X"3C96",
      INIT_56 => X"9111",
      INIT_57 => X"B794",
      INIT_58 => X"4E81",
      INIT_59 => X"4963",
      INIT_5A => X"4963",
      INIT_5B => X"9A74",
      INIT_5C => X"4369",
      INIT_5D => X"451E",
      INIT_5E => X"451E",
      INIT_5F => X"91EB",
      INIT_60 => X"4E81",
      INIT_61 => X"4DA7",
      INIT_62 => X"9A74",
      INIT_63 => X"9A74",
      INIT_64 => X"0000",
      INIT_65 => X"0000",
      INIT_66 => X"0000",
      INIT_67 => X"0000",
      INIT_68 => X"3C96",
      INIT_69 => X"4BF2",
      INIT_6A => X"98BF",
      INIT_6B => X"98BF",
      INIT_6C => X"0000",
      INIT_6D => X"0000",
      INIT_6E => X"0000",
      INIT_6F => X"0000",
      INIT_70 => X"0000",
      INIT_71 => X"0000",
      INIT_72 => X"0000",
      INIT_73 => X"0000",
      INIT_74 => X"0000",
      INIT_75 => X"0000",
      INIT_76 => X"0000",
      INIT_77 => X"0000",
      INIT_78 => X"0000",
      INIT_79 => X"0000",
      INIT_7A => X"0000",
      INIT_7B => X"0000",
      INIT_7C => X"0000",
      INIT_7D => X"0000",
      INIT_7E => X"0000",
      INIT_7F => X"0000",
      IS_CONVSTCLK_INVERTED => '0',
      IS_DCLK_INVERTED => '0',
      SIM_DEVICE => "ULTRASCALE_PLUS",
      SIM_MONITOR_FILE => "design.dat",
      SYSMON_VUSER0_BANK => 40,
      SYSMON_VUSER0_MONITOR => "VCCINT",
      SYSMON_VUSER1_BANK => 0,
      SYSMON_VUSER1_MONITOR => "NONE",
      SYSMON_VUSER2_BANK => 0,
      SYSMON_VUSER2_MONITOR => "NONE",
      SYSMON_VUSER3_BANK => 0,
      SYSMON_VUSER3_MONITOR => "NONE"
    )
        port map (
      ADC_DATA(15 downto 0) => NLW_inst_sysmon_ssit_slave0_ADC_DATA_UNCONNECTED(15 downto 0),
      ALM(15 downto 9) => NLW_inst_sysmon_ssit_slave0_ALM_UNCONNECTED(15 downto 9),
      ALM(8 downto 7) => alm_int_ssit_slave0(8 downto 7),
      ALM(6 downto 4) => NLW_inst_sysmon_ssit_slave0_ALM_UNCONNECTED(6 downto 4),
      ALM(3 downto 1) => alm_int_ssit_slave0(3 downto 1),
      ALM(0) => NLW_inst_sysmon_ssit_slave0_ALM_UNCONNECTED(0),
      BUSY => busy_out_ssit_slave0,
      CHANNEL(5 downto 0) => channel_out_ssit_slave0(5 downto 0),
      CONVST => '0',
      CONVSTCLK => '0',
      DADDR(7 downto 0) => daddr_in(7 downto 0),
      DCLK => dclk_in,
      DEN => inst_sysmon_ssit_slave0_i_1_n_0,
      DI(15 downto 0) => di_in(15 downto 0),
      DO(15) => inst_sysmon_ssit_slave0_n_43,
      DO(14) => inst_sysmon_ssit_slave0_n_44,
      DO(13) => inst_sysmon_ssit_slave0_n_45,
      DO(12) => inst_sysmon_ssit_slave0_n_46,
      DO(11) => inst_sysmon_ssit_slave0_n_47,
      DO(10) => inst_sysmon_ssit_slave0_n_48,
      DO(9) => inst_sysmon_ssit_slave0_n_49,
      DO(8) => inst_sysmon_ssit_slave0_n_50,
      DO(7) => inst_sysmon_ssit_slave0_n_51,
      DO(6) => inst_sysmon_ssit_slave0_n_52,
      DO(5) => inst_sysmon_ssit_slave0_n_53,
      DO(4) => inst_sysmon_ssit_slave0_n_54,
      DO(3) => inst_sysmon_ssit_slave0_n_55,
      DO(2) => inst_sysmon_ssit_slave0_n_56,
      DO(1) => inst_sysmon_ssit_slave0_n_57,
      DO(0) => inst_sysmon_ssit_slave0_n_58,
      DRDY => drdy_out_ssit_slave0,
      DWE => dwe_in,
      EOC => eoc_out_ssit_slave0,
      EOS => eos_out_ssit_slave0,
      I2C_SCLK => i2c_sclk_int,
      I2C_SCLK_TS => i2c_sclk_ts_slave0,
      I2C_SDA => i2c_sda_int,
      I2C_SDA_TS => i2c_sda_ts_slave0,
      JTAGBUSY => NLW_inst_sysmon_ssit_slave0_JTAGBUSY_UNCONNECTED,
      JTAGLOCKED => NLW_inst_sysmon_ssit_slave0_JTAGLOCKED_UNCONNECTED,
      JTAGMODIFIED => NLW_inst_sysmon_ssit_slave0_JTAGMODIFIED_UNCONNECTED,
      MUXADDR(4 downto 0) => NLW_inst_sysmon_ssit_slave0_MUXADDR_UNCONNECTED(4 downto 0),
      OT => ot_out_ssit_slave0,
      RESET => reset_in,
      SMBALERT_TS => NLW_inst_sysmon_ssit_slave0_SMBALERT_TS_UNCONNECTED,
      VAUXN(15 downto 0) => dummy_aux_channel_n(15 downto 0),
      VAUXP(15 downto 0) => dummy_aux_channel_p(15 downto 0),
      VN => NLW_inst_sysmon_ssit_slave0_VN_UNCONNECTED,
      VP => NLW_inst_sysmon_ssit_slave0_VP_UNCONNECTED
    );
inst_sysmon_ssit_slave0_i_1: unisim.vcomponents.LUT3
    generic map(
      INIT => X"40"
    )
        port map (
      I0 => sysmon_slave_sel(1),
      I1 => sysmon_slave_sel(0),
      I2 => den_in,
      O => inst_sysmon_ssit_slave0_i_1_n_0
    );
inst_sysmon_ssit_slave1: unisim.vcomponents.SYSMONE4
    generic map(
      COMMON_N_SOURCE => X"FFFF",
      INIT_40 => X"0000",
      INIT_41 => X"2E92",
      INIT_42 => X"1400",
      INIT_43 => X"208E",
      INIT_44 => X"0000",
      INIT_45 => X"EDCC",
      INIT_46 => X"0001",
      INIT_47 => X"0000",
      INIT_48 => X"0100",
      INIT_49 => X"0000",
      INIT_4A => X"0000",
      INIT_4B => X"0000",
      INIT_4C => X"0000",
      INIT_4D => X"0000",
      INIT_4E => X"0000",
      INIT_4F => X"0000",
      INIT_50 => X"B794",
      INIT_51 => X"4E81",
      INIT_52 => X"A147",
      INIT_53 => X"BF13",
      INIT_54 => X"AB02",
      INIT_55 => X"3C96",
      INIT_56 => X"9111",
      INIT_57 => X"B794",
      INIT_58 => X"4E81",
      INIT_59 => X"4963",
      INIT_5A => X"4963",
      INIT_5B => X"9A74",
      INIT_5C => X"4369",
      INIT_5D => X"451E",
      INIT_5E => X"451E",
      INIT_5F => X"91EB",
      INIT_60 => X"4E81",
      INIT_61 => X"4DA7",
      INIT_62 => X"9A74",
      INIT_63 => X"9A74",
      INIT_64 => X"0000",
      INIT_65 => X"0000",
      INIT_66 => X"0000",
      INIT_67 => X"0000",
      INIT_68 => X"3C96",
      INIT_69 => X"4BF2",
      INIT_6A => X"98BF",
      INIT_6B => X"98BF",
      INIT_6C => X"0000",
      INIT_6D => X"0000",
      INIT_6E => X"0000",
      INIT_6F => X"0000",
      INIT_70 => X"0000",
      INIT_71 => X"0000",
      INIT_72 => X"0000",
      INIT_73 => X"0000",
      INIT_74 => X"0000",
      INIT_75 => X"0000",
      INIT_76 => X"0000",
      INIT_77 => X"0000",
      INIT_78 => X"0000",
      INIT_79 => X"0000",
      INIT_7A => X"0000",
      INIT_7B => X"0000",
      INIT_7C => X"0000",
      INIT_7D => X"0000",
      INIT_7E => X"0000",
      INIT_7F => X"0000",
      IS_CONVSTCLK_INVERTED => '0',
      IS_DCLK_INVERTED => '0',
      SIM_DEVICE => "ULTRASCALE_PLUS",
      SIM_MONITOR_FILE => "design.dat",
      SYSMON_VUSER0_BANK => 70,
      SYSMON_VUSER0_MONITOR => "VCCINT",
      SYSMON_VUSER1_BANK => 0,
      SYSMON_VUSER1_MONITOR => "NONE",
      SYSMON_VUSER2_BANK => 0,
      SYSMON_VUSER2_MONITOR => "NONE",
      SYSMON_VUSER3_BANK => 0,
      SYSMON_VUSER3_MONITOR => "NONE"
    )
        port map (
      ADC_DATA(15 downto 0) => NLW_inst_sysmon_ssit_slave1_ADC_DATA_UNCONNECTED(15 downto 0),
      ALM(15 downto 9) => NLW_inst_sysmon_ssit_slave1_ALM_UNCONNECTED(15 downto 9),
      ALM(8 downto 7) => alm_int_ssit_slave1(8 downto 7),
      ALM(6 downto 4) => NLW_inst_sysmon_ssit_slave1_ALM_UNCONNECTED(6 downto 4),
      ALM(3 downto 1) => alm_int_ssit_slave1(3 downto 1),
      ALM(0) => NLW_inst_sysmon_ssit_slave1_ALM_UNCONNECTED(0),
      BUSY => busy_out_ssit_slave1,
      CHANNEL(5 downto 0) => channel_out_ssit_slave1(5 downto 0),
      CONVST => '0',
      CONVSTCLK => '0',
      DADDR(7 downto 0) => daddr_in(7 downto 0),
      DCLK => dclk_in,
      DEN => inst_sysmon_ssit_slave1_i_1_n_0,
      DI(15 downto 0) => di_in(15 downto 0),
      DO(15) => inst_sysmon_ssit_slave1_n_43,
      DO(14) => inst_sysmon_ssit_slave1_n_44,
      DO(13) => inst_sysmon_ssit_slave1_n_45,
      DO(12) => inst_sysmon_ssit_slave1_n_46,
      DO(11) => inst_sysmon_ssit_slave1_n_47,
      DO(10) => inst_sysmon_ssit_slave1_n_48,
      DO(9) => inst_sysmon_ssit_slave1_n_49,
      DO(8) => inst_sysmon_ssit_slave1_n_50,
      DO(7) => inst_sysmon_ssit_slave1_n_51,
      DO(6) => inst_sysmon_ssit_slave1_n_52,
      DO(5) => inst_sysmon_ssit_slave1_n_53,
      DO(4) => inst_sysmon_ssit_slave1_n_54,
      DO(3) => inst_sysmon_ssit_slave1_n_55,
      DO(2) => inst_sysmon_ssit_slave1_n_56,
      DO(1) => inst_sysmon_ssit_slave1_n_57,
      DO(0) => inst_sysmon_ssit_slave1_n_58,
      DRDY => drdy_out_ssit_slave1,
      DWE => dwe_in,
      EOC => eoc_out_ssit_slave1,
      EOS => eos_out_ssit_slave1,
      I2C_SCLK => i2c_sclk_int,
      I2C_SCLK_TS => i2c_sclk_ts_slave1,
      I2C_SDA => i2c_sda_int,
      I2C_SDA_TS => i2c_sda_ts_slave1,
      JTAGBUSY => NLW_inst_sysmon_ssit_slave1_JTAGBUSY_UNCONNECTED,
      JTAGLOCKED => NLW_inst_sysmon_ssit_slave1_JTAGLOCKED_UNCONNECTED,
      JTAGMODIFIED => NLW_inst_sysmon_ssit_slave1_JTAGMODIFIED_UNCONNECTED,
      MUXADDR(4 downto 0) => NLW_inst_sysmon_ssit_slave1_MUXADDR_UNCONNECTED(4 downto 0),
      OT => ot_out_ssit_slave1,
      RESET => reset_in,
      SMBALERT_TS => NLW_inst_sysmon_ssit_slave1_SMBALERT_TS_UNCONNECTED,
      VAUXN(15 downto 0) => dummy_aux_channel_n(15 downto 0),
      VAUXP(15 downto 0) => dummy_aux_channel_p(15 downto 0),
      VN => NLW_inst_sysmon_ssit_slave1_VN_UNCONNECTED,
      VP => NLW_inst_sysmon_ssit_slave1_VP_UNCONNECTED
    );
inst_sysmon_ssit_slave1_i_1: unisim.vcomponents.LUT3
    generic map(
      INIT => X"40"
    )
        port map (
      I0 => sysmon_slave_sel(0),
      I1 => den_in,
      I2 => sysmon_slave_sel(1),
      O => inst_sysmon_ssit_slave1_i_1_n_0
    );
ot_out_INST_0: unisim.vcomponents.LUT3
    generic map(
      INIT => X"FE"
    )
        port map (
      I0 => ot_out_ssit_master,
      I1 => ot_out_ssit_slave0,
      I2 => ot_out_ssit_slave1,
      O => ot_out
    );
user_supply0_alarm_out_INST_0: unisim.vcomponents.LUT3
    generic map(
      INIT => X"FE"
    )
        port map (
      I0 => alm_int(8),
      I1 => alm_int_ssit_slave0(8),
      I2 => alm_int_ssit_slave1(8),
      O => user_supply0_alarm_out
    );
vbram_alarm_out_INST_0: unisim.vcomponents.LUT3
    generic map(
      INIT => X"FE"
    )
        port map (
      I0 => alm_int(3),
      I1 => alm_int_ssit_slave0(3),
      I2 => alm_int_ssit_slave1(3),
      O => vbram_alarm_out
    );
vccaux_alarm_out_INST_0: unisim.vcomponents.LUT3
    generic map(
      INIT => X"FE"
    )
        port map (
      I0 => alm_int(2),
      I1 => alm_int_ssit_slave0(2),
      I2 => alm_int_ssit_slave1(2),
      O => vccaux_alarm_out
    );
vccint_alarm_out_INST_0: unisim.vcomponents.LUT3
    generic map(
      INIT => X"FE"
    )
        port map (
      I0 => alm_int(1),
      I1 => alm_int_ssit_slave0(1),
      I2 => alm_int_ssit_slave1(1),
      O => vccint_alarm_out
    );
end STRUCTURE;
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
library UNISIM;
use UNISIM.VCOMPONENTS.ALL;
entity system_management_wiz_0 is
  port (
    sysmon_slave_sel : in STD_LOGIC_VECTOR ( 1 downto 0 );
    daddr_in : in STD_LOGIC_VECTOR ( 7 downto 0 );
    den_in : in STD_LOGIC;
    di_in : in STD_LOGIC_VECTOR ( 15 downto 0 );
    dwe_in : in STD_LOGIC;
    do_out : out STD_LOGIC_VECTOR ( 15 downto 0 );
    drdy_out : out STD_LOGIC;
    dclk_in : in STD_LOGIC;
    reset_in : in STD_LOGIC;
    busy_out : out STD_LOGIC;
    channel_out : out STD_LOGIC_VECTOR ( 5 downto 0 );
    eoc_out : out STD_LOGIC;
    eos_out : out STD_LOGIC;
    ot_out : out STD_LOGIC;
    user_supply0_alarm_out : out STD_LOGIC;
    vccaux_alarm_out : out STD_LOGIC;
    vccint_alarm_out : out STD_LOGIC;
    vbram_alarm_out : out STD_LOGIC;
    i2c_sclk : inout STD_LOGIC;
    i2c_sda : inout STD_LOGIC;
    alarm_out : out STD_LOGIC
  );
  attribute NotValidForBitStream : boolean;
  attribute NotValidForBitStream of system_management_wiz_0 : entity is true;
end system_management_wiz_0;

architecture STRUCTURE of system_management_wiz_0 is
begin
U0: entity work.system_management_wiz_0_sysmon
     port map (
      alarm_out => alarm_out,
      busy_out => busy_out,
      channel_out(5 downto 0) => channel_out(5 downto 0),
      daddr_in(7 downto 0) => daddr_in(7 downto 0),
      dclk_in => dclk_in,
      den_in => den_in,
      di_in(15 downto 0) => di_in(15 downto 0),
      do_out(15 downto 0) => do_out(15 downto 0),
      drdy_out => drdy_out,
      dwe_in => dwe_in,
      eoc_out => eoc_out,
      eos_out => eos_out,
      i2c_sclk => i2c_sclk,
      i2c_sda => i2c_sda,
      ot_out => ot_out,
      reset_in => reset_in,
      sysmon_slave_sel(1 downto 0) => sysmon_slave_sel(1 downto 0),
      user_supply0_alarm_out => user_supply0_alarm_out,
      vbram_alarm_out => vbram_alarm_out,
      vccaux_alarm_out => vccaux_alarm_out,
      vccint_alarm_out => vccint_alarm_out,
      vn => '0',
      vp => '0'
    );
end STRUCTURE;
