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

#set_property LOC MMCM_X1Y7 [get_cells uut_CLOCK_MODULE/u_MMCME0_CLKIN_DEJITTERING/MMCME4_ADV_inst]

set_property LOC MMCM_X1Y7 [get_cells uut_CLOCK_MODULE/u_MMCME1_CLK_12M/MMCME4_ADV_inst]
#set_property CLOCK_DEDICATED_ROUTE SAME_CMT_COLUMN [get_nets uut_CLOCK_MODULE/u_MMCME1_CLK_12M/o_CLK_out1]


set_property LOC MMCM_X1Y6 [get_cells uut_CLOCK_MODULE/u_MMCME2_0_CLK_HASH/MMCME4_ADV_inst]
set_property LOC MMCM_X1Y8 [get_cells uut_CLOCK_MODULE/u_MMCME2_1_CLK_HASH/MMCME4_ADV_inst]
#set_property CLOCK_DEDICATED_ROUTE SAME_CMT_COLUMN [get_nets uut_CLOCK_MODULE/u_MMCME2_1_CLK_HASH/o_CLK_out0]
#set_property CLOCK_DEDICATED_ROUTE SAME_CMT_COLUMN [get_nets uut_CLOCK_MODULE/u_MMCME2_0_CLK_HASH/o_CLK_out0]
set_property CLOCK_REGION X4Y7 [get_cells uut_CLOCK_MODULE/BUFGMUX_1_inst]


#set_property CLOCK_DEDICATED_ROUTE ANY_CMT_COLUMN [get_nets uut_CLOCK_MODULE/u_MMCME2_1_CLK_HASH/o_CLK_out0]
#set_property CLOCK_DEDICATED_ROUTE FALSE [get_nets uut_CLOCK_MODULE/u_MMCME2_0_CLK_HASH/o_CLK_out0]
#set_property CLOCK_DEDICATED_ROUTE ANY_CMT_COLUMN [get_nets uut_CLOCK_MODULE/u_MMCME2_1_CLK_HASH/r_CLK_HASH_1]
#set_property CLOCK_DEDICATED_ROUTE FALSE [get_nets uut_CLOCK_MODULE/u_MMCME2_0_CLK_HASH/r_CLK_HASH_0]
###renaming generated clock name
#create_generated_clock -name CLK_12M \[get_pins uut_CLOCK_MODULE/u_MMCME1_CLK_12M/MMCME4_ADV_inst/CLKOUT0]
#create_generated_clock -name CLK_500M \[get_pins uut_CLOCK_MODULE/BUFGMUX_1_inst/O]


######################################################################################################
#input clock constraint. Need create clock. Timing constraint (Fmax) will propagate then thru MMCMx.
create_clock -period 10.000 -name i_CLK_100M [get_ports i_CLK_100M]
set_input_jitter [get_clocks -of_objects [get_ports i_CLK_100M]] 0.000

###################################renaming generated clock name#######################################
create_generated_clock -name CLK_MMCME_1_125M [get_pins uut_CLOCK_MODULE/u_MMCME1_CLK_12M/MMCME4_ADV_inst/CLKOUT1]
create_generated_clock -name CLK_MMCME_1_12M [get_pins uut_CLOCK_MODULE/u_MMCME1_CLK_12M/MMCME4_ADV_inst/CLKOUT0]
create_generated_clock -name CLK_MMCME_2_0 [get_pins uut_CLOCK_MODULE/u_MMCME2_0_CLK_HASH/MMCME4_ADV_inst/CLKOUT0]
create_generated_clock -name CLK_MMCME_2_1 [get_pins uut_CLOCK_MODULE/u_MMCME2_1_CLK_HASH/MMCME4_ADV_inst/CLKOUT0]



############################################################################################################################################################################################################
#BUFMUX_1 constraint, and timing update to set Fmax at 600Mhz.

#optionnal constraint. From K1.
#logically separate MMCM_2_0 and MMCM_2_1 clock output. Pre-BUFG. (random name given by Vivado). Can be found by running report_clocks Tcl command.
#set_clock_groups -logically_exclusive -group r_CLK_out0_MMCME_2 -group r_CLK_out0_MMCME_3
set_clock_groups -logically_exclusive -group CLK_MMCME_2_0 -group CLK_MMCME_2_1

#Create generated clock between MUX I1 and MUX O. Multiply by the output by 5 (5x120=600MHz).
create_generated_clock -name clk_500M_1 -source [get_pins uut_CLOCK_MODULE/BUFGMUX_1_inst/I1] -multiply_by 6 [get_pins uut_CLOCK_MODULE/BUFGMUX_1_inst/O]

# Create generated clock between MUX I0 and MUX O. Multiply by the output by 5 (5x120=600MHz).
# Add back a clock master as reference which is MMCME_2_0 clock output 0 name (random name given by Vivado). Can be found by running report_clocks Tcl command.
#create_generated_clock -name clk_500M_0 -source [get_pins uut_CLOCK_MODULE/BUFGMUX_1_inst/I0] -multiply_by 6 -add -master_clock r_CLK_out0_MMCME_2 [get_pins uut_CLOCK_MODULE/BUFGMUX_1_inst/O]
#create_generated_clock -name clk_500M_0 -source [get_pins uut_CLOCK_MODULE/BUFGMUX_1_inst/I0] -multiply_by 6 -add -master_clock [get_pins uut_CLOCK_MODULE/u_MMCME2_0_CLK_HASH/MMCME4_ADV_inst/CLKOUT0] [get_pins uut_CLOCK_MODULE/BUFGMUX_1_inst/O]
create_generated_clock -name clk_500M_0 -source [get_pins uut_CLOCK_MODULE/BUFGMUX_1_inst/I0] -multiply_by 6 -add -master_clock CLK_MMCME_2_0 [get_pins uut_CLOCK_MODULE/BUFGMUX_1_inst/O]

# separate physiscally the two new generated clocks.
set_clock_groups -physically_exclusive -group clk_500M_0 -group clk_500M_1
############################################################################################################################################################################################################



##########################Not sure those help#########################################
#set_false_path -from [get_clocks CLK_MMCME_1_125M] -to [get_clocks CLK_MMCME_1_12M]
#set_false_path -from [get_clocks CLK_MMCME_1_12M] -to [get_clocks CLK_MMCME_1_125M]

#set_false_path -from [get_clocks CLK_MMCME_1_125M] -to [get_clocks clk_500M_0]
#set_false_path -from [get_clocks CLK_MMCME_1_125M] -to [get_clocks clk_500M_1]

#set_false_path -from [get_clocks clk_500M_0] -to [get_clocks CLK_MMCME_1_125M]
#set_false_path -from [get_clocks clk_500M_1] -to [get_clocks CLK_MMCME_1_125M]

########################## 12MH-125MHz CDC #########################################
#set_false_path -from [get_clocks CLK_MMCME_1_12M] -to [get_clocks clk_500M_0]
#set_false_path -from [get_clocks CLK_MMCME_1_12M] -to [get_clocks clk_500M_1]

#set_false_path -from [get_clocks clk_500M_0] -to [get_clocks CLK_MMCME_1_12M]
#set_false_path -from [get_clocks clk_500M_1] -to [get_clocks CLK_MMCME_1_12M]


#CDC control signal for FIFO module. Max delay is source clock period.
#set_max_delay -from [get_cells GEN_SOLIDITY_CORE[*].SHA3_Solidity_coreX_arch/r_en_toggle_12M_reg] -to [get_cells GEN_SOLIDITY_CORE[*].SHA3_Solidity_coreX_arch/r_en_toggle_500MZZZ_reg] -datapath_only 10

#CDC for header and starting "golden" nonce.
set_max_delay -from [get_cells GEN_SOLIDITY_CORE[*].SHA3_Solidity_coreX_arch/r_new_job_toggle_12MZZ_reg] -to [get_cells GEN_SOLIDITY_CORE[*].SHA3_Solidity_coreX_arch/r_new_job_toggle_500M_reg] -datapath_only 10
#set_bus_skew max skew delay is equal to receive clock period.
set_bus_skew -from [get_cells GEN_SOLIDITY_CORE[*].SHA3_Solidity_coreX_arch/r_header_in_12M_reg*] -to [get_cells GEN_SOLIDITY_CORE[*].SHA3_Solidity_coreX_arch/r_header_in_500M_reg*] 10
#data set_max_delay max delay is the smallest period of the two clocks. 
set_max_delay -datapath_only -from [get_cells GEN_SOLIDITY_CORE[*].SHA3_Solidity_coreX_arch/r_header_in_12M_reg*] -to [get_cells GEN_SOLIDITY_CORE[*].SHA3_Solidity_coreX_arch/r_header_in_500M_reg*] 10
#set_bus_skew max skew delay is equal to receive clock period.
set_bus_skew -from [get_cells GEN_SOLIDITY_CORE[*].SHA3_Solidity_coreX_arch/r_golden_nonce_init_12M_reg*] -to [get_cells GEN_SOLIDITY_CORE[*].SHA3_Solidity_coreX_arch/r_golden_nonce_init_500M_reg*] 10
#data set_max_delay max delay is the smallest period of the two clocks. 
set_max_delay -datapath_only -from [get_cells GEN_SOLIDITY_CORE[*].SHA3_Solidity_coreX_arch/r_golden_nonce_init_12M_reg*] -to [get_cells GEN_SOLIDITY_CORE[*].SHA3_Solidity_coreX_arch/r_golden_nonce_init_500M_reg*] 10


 
#CDC control signal for output. Max delay is source clock period.
set_max_delay -from [get_cells GEN_SOLIDITY_CORE[*].SHA3_Solidity_coreX_arch/r_Golden_Ticket_toggle_reg] -to [get_cells GEN_SOLIDITY_CORE[*].SHA3_Solidity_coreX_arch/r_Golden_Ticket_toggle_12M_reg] -datapath_only 1.666
#set_bus_skew max skew delay is equal to receive clock period.
set_bus_skew -from [get_cells GEN_SOLIDITY_CORE[*].SHA3_Solidity_coreX_arch/r_golden_nonce_reg_reg*] -to [get_cells GEN_SOLIDITY_CORE[*].SHA3_Solidity_coreX_arch/r_Golden_nonce_12M_reg*] 10
#data set_max_delay max delay is the smallest period of the two clocks. 
set_max_delay -datapath_only -from [get_cells GEN_SOLIDITY_CORE[*].SHA3_Solidity_coreX_arch/r_golden_nonce_reg_reg*] -to [get_cells GEN_SOLIDITY_CORE[*].SHA3_Solidity_coreX_arch/r_Golden_nonce_12M_reg*] 1.666

#nonce multicycle_path. 
set_multicycle_path 25 -setup -from [get_pins GEN_SOLIDITY_CORE[*].SHA3_Solidity_coreX_arch/r_golden_nonceZ_reg*/C] -to [get_pins GEN_SOLIDITY_CORE[*].SHA3_Solidity_coreX_arch/r_golden_nonceZZ_reg*/D]
set_multicycle_path 24 -hold -from [get_pins GEN_SOLIDITY_CORE[*].SHA3_Solidity_coreX_arch/r_golden_nonceZ_reg*/C] -to [get_pins GEN_SOLIDITY_CORE[*].SHA3_Solidity_coreX_arch/r_golden_nonceZZ_reg*/D]


#####constraints to pass rst_500M from 12M to 500M clock domain.
#set_max_delay -datapath_only -from [get_pins u_rst_sync/r_SYNCED_nRST_500M_reg/C] -to [get_pins u_rst_sync/r_SYNCED_nRST_500MZ_reg/D] 1.666
set_false_path -from [get_pins GEN_SOLIDITY_CORE[*].SHA3_Solidity_coreX_arch/r_SYNCED_nRST_500M_reg/C] -to [get_pins GEN_SOLIDITY_CORE[*].SHA3_Solidity_coreX_arch/r_nRST_500M_local_reg/D]

#####constraints to avoid warning on reading nRST_500M on 12MHz Domain###### set_max_delay is on a timing path. So start from clock and end on data.
#set_max_delay -datapath_only -from [get_pins u_rst_sync/o_SYNCED_nRST_500M_reg/C] -to [get_pins r_SYNCED_nRST_500M_SYNC_12M_reg/D] 80
#set_false_path -from [get_pins u_rst_sync/o_SYNCED_nRST_500M_reg/C] -to [get_pins r_SYNCED_nRST_500M_SYNC_12M_reg/D]


#####constraint to make ignore timing and avoid warning on the asynchonous pin input/output######
set_output_delay -min 2.000 [get_ports {o_DEBUG_PORT[*]}]
set_output_delay -max 100.000 [get_ports {o_DEBUG_PORT[*]}]
set_false_path -to [get_ports {o_DEBUG_PORT[*]}]

set_output_delay -min 2.000 [get_ports o_UART_TXD]
set_output_delay -max 100.000 [get_ports o_UART_TXD]
set_false_path -to [get_ports o_UART_TXD]

set_input_delay -min 2.000 [get_ports i_UART_RXD]
set_input_delay -max 100.000 [get_ports i_UART_RXD]
set_false_path -from [get_ports i_UART_RXD]

set_input_delay -min 2.000 [get_ports i_RST_N]
set_input_delay -max 100.000 [get_ports i_RST_N]
set_false_path -from [get_ports i_RST_N]

set_input_delay -min 2.000 [get_ports io_i2c_sclk]
set_input_delay -max 100.000 [get_ports io_i2c_sclk]
set_output_delay -min 2.000 [get_ports io_i2c_sclk]
set_output_delay -max 100.000 [get_ports io_i2c_sclk]
set_false_path -to [get_ports io_i2c_sclk]

set_input_delay -min 2.000 [get_ports io_i2c_sda]
set_input_delay -max 100.000 [get_ports io_i2c_sda]
set_output_delay -min 2.000 [get_ports io_i2c_sda]
set_output_delay -max 100.000 [get_ports io_i2c_sda]
set_false_path -to [get_ports io_i2c_sda]

##################################################################################################





################################################################
set_operating_conditions -board_layers 8to11

set_property BITSTREAM.CONFIG.UNUSEDPIN PULLUP [current_design]
set_property CONFIG_MODE SPIx4 [current_design]
set_property BITSTREAM.STARTUP.MATCH_CYCLE NOWAIT [current_design]
set_property BITSTREAM.CONFIG.SPI_BUSWIDTH 4 [current_design]





