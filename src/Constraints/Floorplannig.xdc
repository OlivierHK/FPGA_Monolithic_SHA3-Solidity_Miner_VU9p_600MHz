create_pblock pblock_0
add_cells_to_pblock [get_pblocks pblock_0] [get_cells -quiet [list {GEN_SOLIDITY_CORE[0].SHA3_Solidity_coreX_arch}]]
resize_pblock [get_pblocks pblock_0] -add {SLICE_X0Y823:SLICE_X83Y899}
resize_pblock [get_pblocks pblock_0] -add {CMACE4_X0Y8:CMACE4_X0Y8}
resize_pblock [get_pblocks pblock_0] -add {DSP48E2_X0Y330:DSP48E2_X9Y359}
resize_pblock [get_pblocks pblock_0] -add {RAMB18_X0Y330:RAMB18_X5Y359}
resize_pblock [get_pblocks pblock_0] -add {RAMB36_X0Y165:RAMB36_X5Y179}
resize_pblock [get_pblocks pblock_0] -add {URAM288_X0Y220:URAM288_X1Y239}
set_property IS_SOFT FALSE [get_pblocks pblock_0]
#resize_pblock [get_pblocks pblock_0] -add {DSP48E2_X0Y330:DSP48E2_X9Y359}
#resize_pblock [get_pblocks pblock_0] -add {RAMB18_X0Y330:RAMB18_X5Y359}
#resize_pblock [get_pblocks pblock_0] -add {RAMB36_X0Y165:RAMB36_X5Y179}
#resize_pblock [get_pblocks pblock_0] -add {URAM288_X0Y220:URAM288_X1Y239}

create_pblock pblock_1
add_cells_to_pblock [get_pblocks pblock_1] [get_cells -quiet [list {GEN_SOLIDITY_CORE[1].SHA3_Solidity_coreX_arch}]]
resize_pblock [get_pblocks pblock_1] -add {SLICE_X85Y823:SLICE_X168Y899}
resize_pblock [get_pblocks pblock_1] -add {DSP48E2_X10Y330:DSP48E2_X18Y359}
resize_pblock [get_pblocks pblock_1] -add {RAMB18_X6Y330:RAMB18_X11Y359}
resize_pblock [get_pblocks pblock_1] -add {RAMB36_X6Y165:RAMB36_X11Y179}
resize_pblock [get_pblocks pblock_1] -add {URAM288_X2Y220:URAM288_X3Y239}
set_property IS_SOFT FALSE [get_pblocks pblock_1]
#resize_pblock [get_pblocks pblock_1] -add {BUFG_GT_X1Y336:BUFG_GT_X1Y359}
#resize_pblock [get_pblocks pblock_1] -add {BUFG_GT_SYNC_X1Y210:BUFG_GT_SYNC_X1Y224}
#resize_pblock [get_pblocks pblock_1] -add {DSP48E2_X10Y330:DSP48E2_X18Y359}
#resize_pblock [get_pblocks pblock_1] -add {RAMB18_X6Y330:RAMB18_X11Y359}
#resize_pblock [get_pblocks pblock_1] -add {RAMB36_X6Y165:RAMB36_X11Y179}
#resize_pblock [get_pblocks pblock_1] -add {URAM288_X2Y220:URAM288_X3Y239}

create_pblock pblock_2
add_cells_to_pblock [get_pblocks pblock_2] [get_cells -quiet [list {GEN_SOLIDITY_CORE[2].SHA3_Solidity_coreX_arch}]]
resize_pblock [get_pblocks pblock_2] -add {SLICE_X0Y750:SLICE_X83Y822}
resize_pblock [get_pblocks pblock_2] -add {DSP48E2_X0Y300:DSP48E2_X9Y327}
resize_pblock [get_pblocks pblock_2] -add {RAMB18_X0Y300:RAMB18_X5Y327}
resize_pblock [get_pblocks pblock_2] -add {RAMB36_X0Y150:RAMB36_X5Y163}
resize_pblock [get_pblocks pblock_2] -add {URAM288_X0Y200:URAM288_X1Y215}
set_property IS_SOFT FALSE [get_pblocks pblock_2]
#resize_pblock [get_pblocks pblock_2] -add {DSP48E2_X0Y300:DSP48E2_X9Y327}
#resize_pblock [get_pblocks pblock_2] -add {RAMB18_X0Y300:RAMB18_X5Y327}
#resize_pblock [get_pblocks pblock_2] -add {RAMB36_X0Y150:RAMB36_X5Y163}
#resize_pblock [get_pblocks pblock_2] -add {URAM288_X0Y200:URAM288_X1Y215}

create_pblock pblock_3
add_cells_to_pblock [get_pblocks pblock_3] [get_cells -quiet [list {GEN_SOLIDITY_CORE[3].SHA3_Solidity_coreX_arch}]]
resize_pblock [get_pblocks pblock_3] -add {SLICE_X85Y750:SLICE_X168Y822}
resize_pblock [get_pblocks pblock_3] -add {DSP48E2_X10Y300:DSP48E2_X18Y327}
resize_pblock [get_pblocks pblock_3] -add {RAMB18_X6Y300:RAMB18_X11Y327}
resize_pblock [get_pblocks pblock_3] -add {RAMB36_X6Y150:RAMB36_X11Y163}
resize_pblock [get_pblocks pblock_3] -add {URAM288_X2Y200:URAM288_X3Y215}
set_property IS_SOFT FALSE [get_pblocks pblock_3]
#resize_pblock [get_pblocks pblock_3] -add {DSP48E2_X10Y300:DSP48E2_X18Y327}
#resize_pblock [get_pblocks pblock_3] -add {RAMB18_X6Y300:RAMB18_X11Y327}
#resize_pblock [get_pblocks pblock_3] -add {RAMB36_X6Y150:RAMB36_X11Y163}
#resize_pblock [get_pblocks pblock_3] -add {URAM288_X2Y200:URAM288_X3Y215}

create_pblock pblock_4
add_cells_to_pblock [get_pblocks pblock_4] [get_cells -quiet [list {GEN_SOLIDITY_CORE[4].SHA3_Solidity_coreX_arch}]]
resize_pblock [get_pblocks pblock_4] -add {SLICE_X0Y677:SLICE_X83Y749}
resize_pblock [get_pblocks pblock_4] -add {DSP48E2_X0Y272:DSP48E2_X9Y299}
resize_pblock [get_pblocks pblock_4] -add {RAMB18_X0Y272:RAMB18_X5Y299}
resize_pblock [get_pblocks pblock_4] -add {RAMB36_X0Y136:RAMB36_X5Y149}
resize_pblock [get_pblocks pblock_4] -add {URAM288_X0Y184:URAM288_X1Y199}
set_property IS_SOFT FALSE [get_pblocks pblock_4]
#resize_pblock [get_pblocks pblock_4] -add {DSP48E2_X0Y272:DSP48E2_X9Y299}
#resize_pblock [get_pblocks pblock_4] -add {RAMB18_X0Y272:RAMB18_X5Y299}
#resize_pblock [get_pblocks pblock_4] -add {RAMB36_X0Y136:RAMB36_X5Y149}
#resize_pblock [get_pblocks pblock_4] -add {URAM288_X0Y184:URAM288_X1Y199}

create_pblock pblock_5
add_cells_to_pblock [get_pblocks pblock_5] [get_cells -quiet [list {GEN_SOLIDITY_CORE[5].SHA3_Solidity_coreX_arch}]]
resize_pblock [get_pblocks pblock_5] -add {SLICE_X85Y677:SLICE_X168Y749}
resize_pblock [get_pblocks pblock_5] -add {DSP48E2_X10Y272:DSP48E2_X18Y299}
resize_pblock [get_pblocks pblock_5] -add {RAMB18_X6Y272:RAMB18_X11Y299}
resize_pblock [get_pblocks pblock_5] -add {RAMB36_X6Y136:RAMB36_X11Y149}
resize_pblock [get_pblocks pblock_5] -add {URAM288_X2Y184:URAM288_X3Y199}
set_property IS_SOFT FALSE [get_pblocks pblock_5]
#resize_pblock [get_pblocks pblock_5] -add {DSP48E2_X10Y272:DSP48E2_X18Y299}
#resize_pblock [get_pblocks pblock_5] -add {RAMB18_X6Y272:RAMB18_X11Y299}
#resize_pblock [get_pblocks pblock_5] -add {RAMB36_X6Y136:RAMB36_X11Y149}
#resize_pblock [get_pblocks pblock_5] -add {URAM288_X2Y184:URAM288_X3Y199}

create_pblock pblock_6
add_cells_to_pblock [get_pblocks pblock_6] [get_cells -quiet [list {GEN_SOLIDITY_CORE[6].SHA3_Solidity_coreX_arch}]]
resize_pblock [get_pblocks pblock_6] -add {SLICE_X0Y600:SLICE_X83Y676}
resize_pblock [get_pblocks pblock_6] -add {CMACE4_X0Y6:CMACE4_X0Y6}
resize_pblock [get_pblocks pblock_6] -add {DSP48E2_X0Y240:DSP48E2_X9Y269}
resize_pblock [get_pblocks pblock_6] -add {LAGUNA_X0Y480:LAGUNA_X11Y599}
resize_pblock [get_pblocks pblock_6] -add {RAMB18_X0Y240:RAMB18_X5Y269}
resize_pblock [get_pblocks pblock_6] -add {RAMB36_X0Y120:RAMB36_X5Y134}
resize_pblock [get_pblocks pblock_6] -add {URAM288_X0Y160:URAM288_X1Y179}
set_property IS_SOFT FALSE [get_pblocks pblock_6]
#resize_pblock [get_pblocks pblock_6] -add {DSP48E2_X0Y240:DSP48E2_X9Y269}
#resize_pblock [get_pblocks pblock_6] -add {RAMB18_X0Y240:RAMB18_X5Y269}
#resize_pblock [get_pblocks pblock_6] -add {RAMB36_X0Y120:RAMB36_X5Y134}
#resize_pblock [get_pblocks pblock_6] -add {URAM288_X0Y160:URAM288_X1Y179}

create_pblock pblock_7
add_cells_to_pblock [get_pblocks pblock_7] [get_cells -quiet [list {GEN_SOLIDITY_CORE[7].SHA3_Solidity_coreX_arch}]]
resize_pblock [get_pblocks pblock_7] -add {SLICE_X85Y600:SLICE_X168Y676}
resize_pblock [get_pblocks pblock_7] -add {DSP48E2_X10Y240:DSP48E2_X18Y269}
resize_pblock [get_pblocks pblock_7] -add {LAGUNA_X12Y480:LAGUNA_X23Y599}
resize_pblock [get_pblocks pblock_7] -add {RAMB18_X6Y240:RAMB18_X11Y269}
resize_pblock [get_pblocks pblock_7] -add {RAMB36_X6Y120:RAMB36_X11Y134}
resize_pblock [get_pblocks pblock_7] -add {URAM288_X2Y160:URAM288_X3Y179}
set_property IS_SOFT FALSE [get_pblocks pblock_7]
#resize_pblock [get_pblocks pblock_7] -add {BUFG_GT_X1Y240:BUFG_GT_X1Y263}
#resize_pblock [get_pblocks pblock_7] -add {BUFG_GT_SYNC_X1Y150:BUFG_GT_SYNC_X1Y164}
#resize_pblock [get_pblocks pblock_7] -add {DSP48E2_X10Y240:DSP48E2_X18Y269}
#resize_pblock [get_pblocks pblock_7] -add {RAMB18_X6Y240:RAMB18_X11Y269}
#resize_pblock [get_pblocks pblock_7] -add {RAMB36_X6Y120:RAMB36_X11Y134}
#resize_pblock [get_pblocks pblock_7] -add {URAM288_X2Y160:URAM288_X3Y179}

create_pblock pblock_8
add_cells_to_pblock [get_pblocks pblock_8] [get_cells -quiet [list {GEN_SOLIDITY_CORE[8].SHA3_Solidity_coreX_arch}]]
resize_pblock [get_pblocks pblock_8] -add {SLICE_X85Y0:SLICE_X168Y76}
resize_pblock [get_pblocks pblock_8] -add {DSP48E2_X10Y0:DSP48E2_X18Y29}
resize_pblock [get_pblocks pblock_8] -add {RAMB18_X6Y0:RAMB18_X11Y29}
resize_pblock [get_pblocks pblock_8] -add {RAMB36_X6Y0:RAMB36_X11Y14}
resize_pblock [get_pblocks pblock_8] -add {URAM288_X2Y0:URAM288_X3Y19}
set_property IS_SOFT FALSE [get_pblocks pblock_8]
#resize_pblock [get_pblocks pblock_8] -add {BUFG_GT_X1Y0:BUFG_GT_X1Y23}
#resize_pblock [get_pblocks pblock_8] -add {BUFG_GT_SYNC_X1Y0:BUFG_GT_SYNC_X1Y14}
#resize_pblock [get_pblocks pblock_8] -add {DSP48E2_X10Y0:DSP48E2_X18Y29}
#resize_pblock [get_pblocks pblock_8] -add {RAMB18_X6Y0:RAMB18_X11Y29}
#resize_pblock [get_pblocks pblock_8] -add {RAMB36_X6Y0:RAMB36_X11Y14}
#resize_pblock [get_pblocks pblock_8] -add {URAM288_X2Y0:URAM288_X3Y19}

create_pblock pblock_9
add_cells_to_pblock [get_pblocks pblock_9] [get_cells -quiet [list {GEN_SOLIDITY_CORE[9].SHA3_Solidity_coreX_arch}]]
resize_pblock [get_pblocks pblock_9] -add {SLICE_X0Y0:SLICE_X83Y76}
resize_pblock [get_pblocks pblock_9] -add {CMACE4_X0Y0:CMACE4_X0Y0}
resize_pblock [get_pblocks pblock_9] -add {DSP48E2_X0Y0:DSP48E2_X9Y29}
resize_pblock [get_pblocks pblock_9] -add {RAMB18_X0Y0:RAMB18_X5Y29}
resize_pblock [get_pblocks pblock_9] -add {RAMB36_X0Y0:RAMB36_X5Y14}
resize_pblock [get_pblocks pblock_9] -add {URAM288_X0Y0:URAM288_X1Y19}
set_property IS_SOFT FALSE [get_pblocks pblock_9]
#resize_pblock [get_pblocks pblock_9] -add {BUFG_GT_X0Y0:BUFG_GT_X0Y23}
#resize_pblock [get_pblocks pblock_9] -add {BUFG_GT_SYNC_X0Y0:BUFG_GT_SYNC_X0Y14}
#resize_pblock [get_pblocks pblock_9] -add {DSP48E2_X0Y0:DSP48E2_X9Y29}
#resize_pblock [get_pblocks pblock_9] -add {RAMB18_X0Y0:RAMB18_X5Y29}
#resize_pblock [get_pblocks pblock_9] -add {RAMB36_X0Y0:RAMB36_X5Y14}
#resize_pblock [get_pblocks pblock_9] -add {URAM288_X0Y0:URAM288_X1Y19}

create_pblock pblock_10
add_cells_to_pblock [get_pblocks pblock_10] [get_cells -quiet [list {GEN_SOLIDITY_CORE[10].SHA3_Solidity_coreX_arch}]]
resize_pblock [get_pblocks pblock_10] -add {SLICE_X85Y77:SLICE_X168Y149}
resize_pblock [get_pblocks pblock_10] -add {DSP48E2_X10Y32:DSP48E2_X18Y59}
resize_pblock [get_pblocks pblock_10] -add {RAMB18_X6Y32:RAMB18_X11Y59}
resize_pblock [get_pblocks pblock_10] -add {RAMB36_X6Y16:RAMB36_X11Y29}
resize_pblock [get_pblocks pblock_10] -add {URAM288_X2Y24:URAM288_X3Y39}
set_property IS_SOFT FALSE [get_pblocks pblock_10]
#resize_pblock [get_pblocks pblock_10] -add {DSP48E2_X10Y32:DSP48E2_X18Y59}
#resize_pblock [get_pblocks pblock_10] -add {RAMB18_X6Y32:RAMB18_X11Y59}
#resize_pblock [get_pblocks pblock_10] -add {RAMB36_X6Y16:RAMB36_X11Y29}
#resize_pblock [get_pblocks pblock_10] -add {URAM288_X2Y24:URAM288_X3Y39}

create_pblock pblock_11
add_cells_to_pblock [get_pblocks pblock_11] [get_cells -quiet [list {GEN_SOLIDITY_CORE[11].SHA3_Solidity_coreX_arch}]]
resize_pblock [get_pblocks pblock_11] -add {SLICE_X0Y77:SLICE_X83Y149}
resize_pblock [get_pblocks pblock_11] -add {DSP48E2_X0Y32:DSP48E2_X9Y59}
resize_pblock [get_pblocks pblock_11] -add {RAMB18_X0Y32:RAMB18_X5Y59}
resize_pblock [get_pblocks pblock_11] -add {RAMB36_X0Y16:RAMB36_X5Y29}
resize_pblock [get_pblocks pblock_11] -add {URAM288_X0Y24:URAM288_X1Y39}
set_property IS_SOFT FALSE [get_pblocks pblock_11]
#resize_pblock [get_pblocks pblock_11] -add {DSP48E2_X0Y32:DSP48E2_X9Y59}
#resize_pblock [get_pblocks pblock_11] -add {RAMB18_X0Y32:RAMB18_X5Y59}
#resize_pblock [get_pblocks pblock_11] -add {RAMB36_X0Y16:RAMB36_X5Y29}
#resize_pblock [get_pblocks pblock_11] -add {URAM288_X0Y24:URAM288_X1Y39}

create_pblock pblock_12
add_cells_to_pblock [get_pblocks pblock_12] [get_cells -quiet [list {GEN_SOLIDITY_CORE[12].SHA3_Solidity_coreX_arch}]]
resize_pblock [get_pblocks pblock_12] -add {SLICE_X85Y150:SLICE_X168Y222}
resize_pblock [get_pblocks pblock_12] -add {DSP48E2_X10Y60:DSP48E2_X18Y87}
resize_pblock [get_pblocks pblock_12] -add {RAMB18_X6Y60:RAMB18_X11Y87}
resize_pblock [get_pblocks pblock_12] -add {RAMB36_X6Y30:RAMB36_X11Y43}
resize_pblock [get_pblocks pblock_12] -add {URAM288_X2Y40:URAM288_X3Y55}
set_property IS_SOFT FALSE [get_pblocks pblock_12]
#resize_pblock [get_pblocks pblock_12] -add {DSP48E2_X10Y60:DSP48E2_X18Y87}
#resize_pblock [get_pblocks pblock_12] -add {RAMB18_X6Y60:RAMB18_X11Y87}
#resize_pblock [get_pblocks pblock_12] -add {RAMB36_X6Y30:RAMB36_X11Y43}
#resize_pblock [get_pblocks pblock_12] -add {URAM288_X2Y40:URAM288_X3Y55}

create_pblock pblock_13
add_cells_to_pblock [get_pblocks pblock_13] [get_cells -quiet [list {GEN_SOLIDITY_CORE[13].SHA3_Solidity_coreX_arch}]]
resize_pblock [get_pblocks pblock_13] -add {SLICE_X0Y150:SLICE_X83Y222}
resize_pblock [get_pblocks pblock_13] -add {DSP48E2_X0Y60:DSP48E2_X9Y87}
resize_pblock [get_pblocks pblock_13] -add {RAMB18_X0Y60:RAMB18_X5Y87}
resize_pblock [get_pblocks pblock_13] -add {RAMB36_X0Y30:RAMB36_X5Y43}
resize_pblock [get_pblocks pblock_13] -add {URAM288_X0Y40:URAM288_X1Y55}
set_property IS_SOFT FALSE [get_pblocks pblock_13]
#resize_pblock [get_pblocks pblock_13] -add {DSP48E2_X0Y60:DSP48E2_X9Y87}
#resize_pblock [get_pblocks pblock_13] -add {RAMB18_X0Y60:RAMB18_X5Y87}
#resize_pblock [get_pblocks pblock_13] -add {RAMB36_X0Y30:RAMB36_X5Y43}
#resize_pblock [get_pblocks pblock_13] -add {URAM288_X0Y40:URAM288_X1Y55}

create_pblock pblock_14
add_cells_to_pblock [get_pblocks pblock_14] [get_cells -quiet [list {GEN_SOLIDITY_CORE[14].SHA3_Solidity_coreX_arch}]]
resize_pblock [get_pblocks pblock_14] -add {SLICE_X85Y223:SLICE_X168Y299}
resize_pblock [get_pblocks pblock_14] -add {DSP48E2_X10Y90:DSP48E2_X18Y119}
resize_pblock [get_pblocks pblock_14] -add {LAGUNA_X12Y120:LAGUNA_X23Y239}
resize_pblock [get_pblocks pblock_14] -add {RAMB18_X6Y90:RAMB18_X11Y119}
resize_pblock [get_pblocks pblock_14] -add {RAMB36_X6Y45:RAMB36_X11Y59}
resize_pblock [get_pblocks pblock_14] -add {URAM288_X2Y60:URAM288_X3Y79}
set_property IS_SOFT FALSE [get_pblocks pblock_14]
#resize_pblock [get_pblocks pblock_14] -add {BUFG_GT_X1Y96:BUFG_GT_X1Y119}
#resize_pblock [get_pblocks pblock_14] -add {BUFG_GT_SYNC_X1Y60:BUFG_GT_SYNC_X1Y74}
#resize_pblock [get_pblocks pblock_14] -add {DSP48E2_X10Y90:DSP48E2_X18Y119}
#resize_pblock [get_pblocks pblock_14] -add {RAMB18_X6Y90:RAMB18_X11Y119}
#resize_pblock [get_pblocks pblock_14] -add {RAMB36_X6Y45:RAMB36_X11Y59}
#resize_pblock [get_pblocks pblock_14] -add {URAM288_X2Y60:URAM288_X3Y79}

create_pblock pblock_15
add_cells_to_pblock [get_pblocks pblock_15] [get_cells -quiet [list {GEN_SOLIDITY_CORE[15].SHA3_Solidity_coreX_arch}]]
resize_pblock [get_pblocks pblock_15] -add {SLICE_X0Y223:SLICE_X83Y299}
resize_pblock [get_pblocks pblock_15] -add {CMACE4_X0Y2:CMACE4_X0Y2}
resize_pblock [get_pblocks pblock_15] -add {DSP48E2_X0Y90:DSP48E2_X9Y119}
resize_pblock [get_pblocks pblock_15] -add {LAGUNA_X0Y120:LAGUNA_X11Y239}
resize_pblock [get_pblocks pblock_15] -add {RAMB18_X0Y90:RAMB18_X5Y119}
resize_pblock [get_pblocks pblock_15] -add {RAMB36_X0Y45:RAMB36_X5Y59}
resize_pblock [get_pblocks pblock_15] -add {URAM288_X0Y60:URAM288_X1Y79}
set_property IS_SOFT FALSE [get_pblocks pblock_15]
#resize_pblock [get_pblocks pblock_15] -add {DSP48E2_X0Y90:DSP48E2_X9Y119}
#resize_pblock [get_pblocks pblock_15] -add {RAMB18_X0Y90:RAMB18_X5Y119}
#resize_pblock [get_pblocks pblock_15] -add {RAMB36_X0Y45:RAMB36_X5Y59}
#resize_pblock [get_pblocks pblock_15] -add {URAM288_X0Y60:URAM288_X1Y79}

create_pblock pblock_16
add_cells_to_pblock [get_pblocks pblock_16] [get_cells -quiet [list {GEN_SOLIDITY_CORE[16].SHA3_Solidity_coreX_arch}]]
resize_pblock [get_pblocks pblock_16] -add {SLICE_X0Y523:SLICE_X83Y599}
resize_pblock [get_pblocks pblock_16] -add {CMACE4_X0Y5:CMACE4_X0Y5}
resize_pblock [get_pblocks pblock_16] -add {DSP48E2_X0Y210:DSP48E2_X9Y239}
resize_pblock [get_pblocks pblock_16] -add {LAGUNA_X0Y360:LAGUNA_X11Y479}
resize_pblock [get_pblocks pblock_16] -add {RAMB18_X0Y210:RAMB18_X5Y239}
resize_pblock [get_pblocks pblock_16] -add {RAMB36_X0Y105:RAMB36_X5Y119}
resize_pblock [get_pblocks pblock_16] -add {URAM288_X0Y140:URAM288_X1Y159}
set_property IS_SOFT FALSE [get_pblocks pblock_16]
#resize_pblock [get_pblocks pblock_16] -add {BUFG_GT_X0Y216:BUFG_GT_X0Y239}
#resize_pblock [get_pblocks pblock_16] -add {BUFG_GT_SYNC_X0Y135:BUFG_GT_SYNC_X0Y149}
#resize_pblock [get_pblocks pblock_16] -add {DSP48E2_X0Y210:DSP48E2_X9Y239}
#resize_pblock [get_pblocks pblock_16] -add {RAMB18_X0Y210:RAMB18_X5Y239}
#resize_pblock [get_pblocks pblock_16] -add {RAMB36_X0Y105:RAMB36_X5Y119}
#resize_pblock [get_pblocks pblock_16] -add {URAM288_X0Y140:URAM288_X1Y159}

create_pblock pblock_17
add_cells_to_pblock [get_pblocks pblock_17] [get_cells -quiet [list {GEN_SOLIDITY_CORE[17].SHA3_Solidity_coreX_arch}]]
resize_pblock [get_pblocks pblock_17] -add {SLICE_X85Y523:SLICE_X168Y599}
resize_pblock [get_pblocks pblock_17] -add {DSP48E2_X10Y210:DSP48E2_X18Y239}
resize_pblock [get_pblocks pblock_17] -add {LAGUNA_X12Y360:LAGUNA_X23Y479}
resize_pblock [get_pblocks pblock_17] -add {RAMB18_X6Y210:RAMB18_X11Y239}
resize_pblock [get_pblocks pblock_17] -add {RAMB36_X6Y105:RAMB36_X11Y119}
resize_pblock [get_pblocks pblock_17] -add {URAM288_X2Y140:URAM288_X3Y159}
set_property IS_SOFT FALSE [get_pblocks pblock_17]
#resize_pblock [get_pblocks pblock_17] -add {DSP48E2_X10Y210:DSP48E2_X18Y239}
#resize_pblock [get_pblocks pblock_17] -add {RAMB18_X6Y210:RAMB18_X11Y239}
#resize_pblock [get_pblocks pblock_17] -add {RAMB36_X6Y105:RAMB36_X11Y119}
#resize_pblock [get_pblocks pblock_17] -add {URAM288_X2Y140:URAM288_X3Y159}

create_pblock pblock_18
add_cells_to_pblock [get_pblocks pblock_18] [get_cells -quiet [list {GEN_SOLIDITY_CORE[18].SHA3_Solidity_coreX_arch}]]
resize_pblock [get_pblocks pblock_18] -add {SLICE_X0Y450:SLICE_X83Y522}
resize_pblock [get_pblocks pblock_18] -add {DSP48E2_X0Y180:DSP48E2_X9Y207}
resize_pblock [get_pblocks pblock_18] -add {RAMB18_X0Y180:RAMB18_X5Y207}
resize_pblock [get_pblocks pblock_18] -add {RAMB36_X0Y90:RAMB36_X5Y103}
resize_pblock [get_pblocks pblock_18] -add {URAM288_X0Y120:URAM288_X1Y135}
set_property IS_SOFT FALSE [get_pblocks pblock_18]
#resize_pblock [get_pblocks pblock_18] -add {DSP48E2_X0Y180:DSP48E2_X9Y207}
#resize_pblock [get_pblocks pblock_18] -add {RAMB18_X0Y180:RAMB18_X5Y207}
#resize_pblock [get_pblocks pblock_18] -add {RAMB36_X0Y90:RAMB36_X5Y103}
#resize_pblock [get_pblocks pblock_18] -add {URAM288_X0Y120:URAM288_X1Y135}

create_pblock pblock_19
add_cells_to_pblock [get_pblocks pblock_19] [get_cells -quiet [list {GEN_SOLIDITY_CORE[19].SHA3_Solidity_coreX_arch}]]
resize_pblock [get_pblocks pblock_19] -add {SLICE_X85Y450:SLICE_X168Y522}
resize_pblock [get_pblocks pblock_19] -add {DSP48E2_X10Y180:DSP48E2_X18Y207}
resize_pblock [get_pblocks pblock_19] -add {RAMB18_X6Y180:RAMB18_X11Y207}
resize_pblock [get_pblocks pblock_19] -add {RAMB36_X6Y90:RAMB36_X11Y103}
resize_pblock [get_pblocks pblock_19] -add {URAM288_X2Y120:URAM288_X3Y135}
set_property IS_SOFT FALSE [get_pblocks pblock_19]
#resize_pblock [get_pblocks pblock_19] -add {DSP48E2_X10Y180:DSP48E2_X18Y207}
#resize_pblock [get_pblocks pblock_19] -add {RAMB18_X6Y180:RAMB18_X11Y207}
#resize_pblock [get_pblocks pblock_19] -add {RAMB36_X6Y90:RAMB36_X11Y103}
#resize_pblock [get_pblocks pblock_19] -add {URAM288_X2Y120:URAM288_X3Y135}


create_pblock pblock_20
add_cells_to_pblock [get_pblocks pblock_20] [get_cells -quiet [list {GEN_SOLIDITY_CORE[20].SHA3_Solidity_coreX_arch}]]
resize_pblock [get_pblocks pblock_20] -add {SLICE_X0Y300:SLICE_X83Y376}
resize_pblock [get_pblocks pblock_20] -add {CMACE4_X0Y3:CMACE4_X0Y3}
resize_pblock [get_pblocks pblock_20] -add {DSP48E2_X0Y120:DSP48E2_X9Y149}
resize_pblock [get_pblocks pblock_20] -add {LAGUNA_X0Y240:LAGUNA_X11Y359}
resize_pblock [get_pblocks pblock_20] -add {RAMB18_X0Y120:RAMB18_X5Y149}
resize_pblock [get_pblocks pblock_20] -add {RAMB36_X0Y60:RAMB36_X5Y74}
resize_pblock [get_pblocks pblock_20] -add {URAM288_X0Y80:URAM288_X1Y99}
set_property IS_SOFT FALSE [get_pblocks pblock_20]
#resize_pblock [get_pblocks pblock_20] -add {BUFG_GT_X0Y120:BUFG_GT_X0Y143}
#resize_pblock [get_pblocks pblock_20] -add {BUFG_GT_SYNC_X0Y75:BUFG_GT_SYNC_X0Y89}
#resize_pblock [get_pblocks pblock_20] -add {DSP48E2_X0Y120:DSP48E2_X9Y149}
#resize_pblock [get_pblocks pblock_20] -add {RAMB18_X0Y120:RAMB18_X5Y149}
#resize_pblock [get_pblocks pblock_20] -add {RAMB36_X0Y60:RAMB36_X5Y74}
#resize_pblock [get_pblocks pblock_20] -add {URAM288_X0Y80:URAM288_X1Y99}

create_pblock pblock_21
add_cells_to_pblock [get_pblocks pblock_21] [get_cells -quiet [list {GEN_SOLIDITY_CORE[21].SHA3_Solidity_coreX_arch}]]
resize_pblock [get_pblocks pblock_21] -add {SLICE_X85Y300:SLICE_X168Y376}
resize_pblock [get_pblocks pblock_21] -add {DSP48E2_X10Y120:DSP48E2_X18Y149}
resize_pblock [get_pblocks pblock_21] -add {LAGUNA_X12Y240:LAGUNA_X23Y359}
resize_pblock [get_pblocks pblock_21] -add {RAMB18_X6Y120:RAMB18_X11Y149}
resize_pblock [get_pblocks pblock_21] -add {RAMB36_X6Y60:RAMB36_X11Y74}
resize_pblock [get_pblocks pblock_21] -add {URAM288_X2Y80:URAM288_X3Y99}
set_property IS_SOFT FALSE [get_pblocks pblock_21]
#resize_pblock [get_pblocks pblock_21] -add {BUFG_GT_X1Y120:BUFG_GT_X1Y143}
#resize_pblock [get_pblocks pblock_21] -add {BUFG_GT_SYNC_X1Y75:BUFG_GT_SYNC_X1Y89}
#resize_pblock [get_pblocks pblock_21] -add {DSP48E2_X10Y120:DSP48E2_X18Y149}
#resize_pblock [get_pblocks pblock_21] -add {RAMB18_X6Y120:RAMB18_X11Y149}
#resize_pblock [get_pblocks pblock_21] -add {RAMB36_X6Y60:RAMB36_X11Y74}
#resize_pblock [get_pblocks pblock_21] -add {URAM288_X2Y80:URAM288_X3Y99}


create_pblock pblock_22
add_cells_to_pblock [get_pblocks pblock_22] [get_cells -quiet [list {GEN_SOLIDITY_CORE[22].SHA3_Solidity_coreX_arch}]]
resize_pblock [get_pblocks pblock_22] -add {SLICE_X0Y377:SLICE_X83Y449}
resize_pblock [get_pblocks pblock_22] -add {DSP48E2_X0Y152:DSP48E2_X9Y179}
resize_pblock [get_pblocks pblock_22] -add {RAMB18_X0Y152:RAMB18_X5Y179}
resize_pblock [get_pblocks pblock_22] -add {RAMB36_X0Y76:RAMB36_X5Y89}
resize_pblock [get_pblocks pblock_22] -add {URAM288_X0Y104:URAM288_X1Y119}
set_property IS_SOFT FALSE [get_pblocks pblock_22]
#resize_pblock [get_pblocks pblock_22] -add {DSP48E2_X0Y150:DSP48E2_X9Y177}
#resize_pblock [get_pblocks pblock_22] -add {RAMB18_X0Y150:RAMB18_X5Y177}
#resize_pblock [get_pblocks pblock_22] -add {RAMB36_X0Y75:RAMB36_X5Y88}
#resize_pblock [get_pblocks pblock_22] -add {URAM288_X0Y100:URAM288_X1Y115}




create_pblock pblock_23
add_cells_to_pblock [get_pblocks pblock_23] [get_cells -quiet [list {GEN_SOLIDITY_CORE[23].SHA3_Solidity_coreX_arch}]]
resize_pblock [get_pblocks pblock_23] -add {SLICE_X85Y377:SLICE_X168Y449}
resize_pblock [get_pblocks pblock_23] -add {DSP48E2_X10Y152:DSP48E2_X18Y179}
resize_pblock [get_pblocks pblock_23] -add {RAMB18_X6Y152:RAMB18_X11Y179}
resize_pblock [get_pblocks pblock_23] -add {RAMB36_X6Y76:RAMB36_X11Y89}
resize_pblock [get_pblocks pblock_23] -add {URAM288_X2Y104:URAM288_X3Y119}



