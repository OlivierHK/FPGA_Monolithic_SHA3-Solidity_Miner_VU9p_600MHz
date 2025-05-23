##################################################################################################
# This TCL script is used to do basic project setup and clarify the DRP settings
#
# XAPP888 TCL commands:
#       xapp888_create_project <> - Basic project setup. Adjust as needed
#       xapp888_help <>           - Descriptions of added TCL commands
#
# XAPP888 TCL DRP Settings:
#       xapp888_drp_settings <CLKFBOUT_MULT>  <DIVCLK_DIVIDE> <PHASE> <HIGH|LOW|high|low>
#            - Displays & Returns the ordered pairs of DRP addresses & Data
#
#       xapp888_drp_clkout <DIVIDE>  <Duty Cycle e.g. 0.5> <Phase e.g.11.25> <CLKOUT0 to CLKOUT6>
#            - Displays & Returns the ordered pairs of DRP addresses & Data
#
#       xapp888_merge_drp_clkout <list>
#            - Returns the ordered DRP addresses/data merging fractional address 07 & 13
#
# Revision History:
#       1/15/15 - Added TCL DRP commands
#       2/23/16 - Adjusted for CDDCEN in fractional calculations
#       3/17/16 - Added min duty cycle check
#       2/28/17 - Updated for UltraScale+
#       10/17/17 -Rounded floating point pmphasecycles for int to return correct value
#       7/10/18 - Fixed duty cycles for divide > 64
#       05 Oct 2018 - Text updates.
#
##################################################################################################

proc xapp888_create_project {} {
    create_project xapp888_ultrascale  -force xapp888_ultrascale -part xcku040-ffva1156-1-c
    add_files -norecurse {mmcme3_drp_func.h mmcme4_drp.v top_mmcme4.v  top_mmcme4.xdc}
    import_files -force -norecurse
    import_files -fileset sim_1 -norecurse {top_mmcme3_tb.v}
    update_compile_order -fileset sim_1
}

proc xapp888_merge_drp {list} {
    set count_07 0
    set merge_07 ""
    set count_13 0
    set merge_13 ""
    set drp_merged ""
    for {set i 0} { $i <= [expr [llength $list]/2] } {incr i} {
        if {[string match [lindex $list [expr $i*2]] 07]} {
            incr count_07; set merge_07 "$merge_07 [lindex $list [expr 2*$i + 1] ]"
        } elseif {[string match [lindex $list [expr $i*2]] 13]} {
            incr count_13; set merge_13 "$merge_13 [lindex $list [expr 2*$i + 1] ]"
        } else {
            set drp_merged "$drp_merged [lindex $list [expr $i * 2]] [lindex $list [expr $i * 2 + 1]]"
        }
    }

    if {[llength $merge_07] > 1 } {set drp_07_merged [format %04x [expr 0x[lindex $merge_07 0] | 0x[lindex $merge_07 1]]]} else {set drp_07_merged [lindex $merge_07 0]}
    if {[llength $merge_13] > 1} {set drp_13_merged  [format %04x [expr 0x[lindex $merge_13 0] | 0x[lindex $merge_13 1]]]} else {set drp_13_merged [lindex $merge_13 0]}
    if {$count_07 >2} {
            puts "ERROR: Too many shared addresses for 07. Only the first 2 terms are being marged. $merge_07"
    } elseif {$count_07 > 0} {
        set drp_merged "$drp_merged  07 $drp_07_merged"
    }
    if {$count_13 >2} {
        puts "ERROR: Too many shared addresses for 13. Only the first 2 terms are being merged. $merge_13"
    } elseif {$count_13 > 0} {
        set drp_merged "$drp_merged 13 $drp_13_merged"
    }
    puts "$list has been changed to $drp_merged"
    return $drp_merged
}
proc xapp888_drp_clkout_frac {divide phase} {
    set divide_frac [expr fmod($divide, 1)]
    set divide_frac_8ths [scan [expr $divide_frac * 8] %d]
    set divide_int [scan [expr floor($divide)] %d]

    set even_part_high [scan [expr floor($divide_int / 2)] %d]
    set even_part_low $even_part_high

    set odd [expr $divide_int - $even_part_high - $even_part_low]
    set odd_and_frac [scan [expr 8 * $odd + $divide_frac_8ths] %d]

    if {$odd_and_frac <=9} {set lt_frac [expr $even_part_high - 1]} else {set lt_frac $even_part_high}
    if {$odd_and_frac <=8} {set ht_frac [expr $even_part_low - 1]} else {set ht_frac $even_part_low}

    set pmfall [scan [expr $odd * 4 + floor($divide_frac_8ths / 2)] %d]
    set pmrise 0
    set dt [scan [expr floor($phase * $divide / 360)] %d]
    set pmrise [scan [expr floor( 8 * (($phase * $divide /360 ) - $dt)+ 0.5 )] %d]
    set pmfall [scan [expr $pmfall + $pmrise] %d]

    #puts "Fractional Requested phase is: $phase; Given divide=$divide then phase increments in [format %f [expr 45.000/$divide ]  ];  "
    #puts "Fractional - Requested phase is: $phase; Actual Given divide=$divide then phase increments in [format %f [expr 45.000/$divide ]  ];  "
    #puts "DT will be $phasecycles, PM will be $pmphasecycles"
    #puts "Phase will be shifted by VCO period * $phasecycles.[expr 1000*$pmphasecycles / 8]"
    #puts "Phase will be shifted by [format %f [expr $phasecycles * 360.000 / $divide]] + [format %f  [expr $pmphasecycles * 45.000 / $divide]] = [format %f [expr ( $phasecycles * 360.000 / $divide) + ($pmphasecycles * 45.000 / $divide) ] ]"
    ##puts "Requested Phase is: $phase; Actual: [format %f [expr ( $phasecycles * 360.000 / $divide) + ($pmphasecycles * 45.000 / $divide) ] ];  "

    if {$odd_and_frac <=9 && $odd_and_frac >=2 || $divide == 2.125} {set wf_fall 1} else {set wf_fall 0}
    if {$odd_and_frac <=8 && $odd_and_frac >=1} {set wf_rise 1} else {set wf_rise 0}

    set dt [scan [expr $dt + floor($pmrise / 8)] %d]
    set pmrise [scan [expr fmod($pmrise , 8)] %d]
    set pmfall [scan [expr fmod($pmfall , 8)] %d]

    set reg1       "[xapp888_dec2bin $pmrise 3]1[xapp888_dec2bin $ht_frac 6][xapp888_dec2bin $lt_frac 6]"
    set reg2       "0[xapp888_dec2bin $divide_frac_8ths 3]1[expr $wf_rise]0000[xapp888_dec2bin $dt 6]"
#For olympus only return 4 bits as the leading 00 was causing problems due to CDDC_EN bits shifting everything
    set regshared  "[xapp888_dec2bin $pmfall 3][expr $wf_fall]"

    return "$reg1 $reg2 $regshared "
}

proc xapp888_drp_clkout {divide dutycycle phase clkout} {
    set clkout_lower [string tolower $clkout]
        switch -glob -- $clkout_lower {
            clkout0  {  set daddr_reg1 08
                        set daddr_reg2 09
                        }
            clkout1  {  set daddr_reg1 0A
                        set daddr_reg2 0B
                        }
            clkout2  {  set daddr_reg1 0C
                        set daddr_reg2 0D
                        }
            clkout3  {  set daddr_reg1 0E
                        set daddr_reg2 0F
                        }
            clkout4  {  set daddr_reg1 10
                        set daddr_reg2 11
                        }
            clkout5  {  set daddr_reg1 06
                        set daddr_reg2 07
                        }
            clkout6  {  set daddr_reg1 12
                        set daddr_reg2 13
                        }
    }
        if {$phase < 0} {set phase [expr 360 + $phase]}

# Calculate phase for PM and O counter.
# Round counter phase setting up if => 0.5 to closes possible phase
        set phase_in_cycles [expr $phase / 360.0 * $divide]
        set phasecycles_dec [expr (8 * $phase_in_cycles)]
        set phasecycles_int [expr int($phasecycles_dec)]
        set phasecycles_rem [expr ($phasecycles_dec - $phasecycles_int )]
        if {$phasecycles_rem >= 0.5} {set phasecycles_int [expr ($phasecycles_int + 1)]}
        set phasecycles [expr int($phasecycles_int / 8)]
        set pmphasecycles [expr ($phasecycles_int - $phasecycles * 8)]
# Duty cycle stuff
       if {$divide < 64} {
            set min_dc [expr 1.0 / $divide]
            set max_dc [expr ($divide - 0.5) / $divide]
       } else {
            set min_dc [expr ($divide - 64.0) / $divide]
            set max_dc [expr (64 + 0.5) / $divide]
       }
        if {$dutycycle < $min_dc} {puts "\n\tWARNING: Min duty cycle violation $dutycycle < $min_dc\n\t         Changing dutycycle to $min_dc\n"; set dutycycle $min_dc}
        if {$dutycycle > $max_dc} {puts "\n\tWARNING: Max duty cycle is $dutycycle > $max_dc\n\t         Changing dutycycle to $max_dc\n"; set dutycycle $max_dc}

####    puts "Requested phase is: $phase; Given divide=$divide then phase increments in [format %f [expr 45.000/$divide ]  ];  "
#    puts " DT will be $phasecycles, PM will be $pmphasecycles"
#    puts " Phase will be shifted by VCO period * $phasecycles.[expr 1000*$pmphasecycles / 8]"
#    puts " Phase will be shifted by [format %f [expr $phasecycles * 360.000 / $divide]] + [format %f  [expr $pmphasecycles * 45.000 / $divide]] = [format %f [expr ( $phasecycles * 360.000 / $divide) + ($pmphasecycles * 45.000 / $divide) ] ]"
####    puts "Requested Phase is: $phase; Actual: [format %f [expr ( $phasecycles * 360.000 / $divide) + ($pmphasecycles * 45.000 / $divide) ] ];  "

#puts "[expr $pmphasecycles * 45 / $divide]"

        set ht [scan [expr int($dutycycle * [expr ($divide ) ])] %d]
        set lt [scan [expr $divide - $ht] %d]
        set even_high [scan [expr $divide / 2] %d]
        set odd [expr $divide - $even_high * 2]

        if {$divide == 1} {
             set drp_reg1 "[xapp888_bin2hex [binary scan [binary format I $pmphasecycles] B32 var;string range $var end-2 end]1000001000001]"
             set drp_reg2 "[xapp888_bin2hex 00000000[expr $odd]1[xapp888_dec2bin $phasecycles 6] ]"
####             puts "DADDR_$daddr_reg1: $drp_reg1\t-[string toupper $clkout] Register 1"
####             puts "DADDR_$daddr_reg2: $drp_reg2\t-[string toupper $clkout] Register 2"
             return " $daddr_reg1$drp_reg1 $daddr_reg2$drp_reg2"
        } elseif {[expr fmod($divide,1)] == 0  }  {
             set drp_reg1 "[xapp888_bin2hex [binary scan [binary format I $pmphasecycles] B32 var;string range $var end-2 end]1[xapp888_dec2bin4ltht $ht][xapp888_dec2bin4ltht $lt]]"
             set drp_reg2 "[xapp888_bin2hex 00000000[expr $odd]0[xapp888_dec2bin $phasecycles 6] ]"
####             puts "DADDR_$daddr_reg1: $drp_reg1\t-[string toupper $clkout] Register 1: Requested Phase is: $phase; Actual: [format %f [expr ( $phasecycles * 360.000 / $divide) + ($pmphasecycles * 45.000 / $divide) ] ]"
####             puts "DADDR_$daddr_reg2: $drp_reg2\t-[string toupper $clkout] Register 2"
             return " $daddr_reg1$drp_reg1 $daddr_reg2$drp_reg2"
        } elseif {[string tolower $clkout] == "clkout0" } {
            set drp_frac_registers [xapp888_drp_clkout_frac $divide $phase ]
            set drp_reg1 [xapp888_bin2hex [lindex $drp_frac_registers 0]]
            set drp_reg2 [xapp888_bin2hex [lindex $drp_frac_registers 1]]
            #       For Olympus, CDDCEN shifts the PM_F/WF_F bits to be 15:12 instead of 13:10
            set drp_regshared [xapp888_bin2hex [lindex $drp_frac_registers 2]000000000000]
####            puts "DADDR_$daddr_reg2: $drp_reg2\t-[string toupper $clkout] Register 1: Requested Phase is: $phase; Actual: [format %f [expr ( $phasecycles * 360.000 / $divide) + ($pmphasecycles * 45.000 / $divide) ] ]"
####            puts "DADDR_$daddr_reg1: $drp_reg1\t-[string toupper $clkout] Register 2"
####            puts "DADDR_07: $drp_regshared\t-[string toupper $clkout] Register Shared with CLKOUT5"
            return "  08$drp_reg1 09$drp_reg2 07$drp_regshared"
        }  else {puts "\nERROR: Fractional divide setting only supported for CLKOUT0. Output clock set to [string toupper $clkout] \n"
    }
}

proc xapp888_drp_calc_m {divide phase} {
    set phasecycles [expr int(($divide*$phase)/360)]
    set pmphase [expr ($phase - ($phasecycles *360)/$divide)]
    set pmphasecycles [scan [expr int(($pmphase *$divide)/ 45)] %d]

    set ht [scan [expr ($divide ) / 2] %d]
    set lt [scan [expr $divide - $ht] %d]
    set odd [expr $lt - $ht]
    set daddr_reg1 14
    set daddr_reg2 15
    set daddr_regshared 13
    if {$divide == 1} {
        set drp_reg1 "[xapp888_bin2hex [binary scan [binary format I $pmphasecycles] B32 var;string range $var end-2 end]1000001000001]"
        set drp_reg2 "[xapp888_bin2hex 00000000[expr $odd]1[xapp888_dec2bin $phasecycles 6] ]"
####        puts "DADDR_$daddr_reg1: $drp_reg1\t-CLKFBOUT Register 1- "
####        puts "DADDR_$daddr_reg2: $drp_reg2\t-CLKFBOUT Register 2- "
        puts " WARNING: M set to 1 is out of legal range"
        return "  $daddr_reg1$drp_reg1  $daddr_reg2$drp_reg2"
    } elseif {$divide > 128 || $divide < 2  } {
        puts "DADDR_14: ERROR: M must be 2 to 128\t-CLKFBOUT Register 2-"
        puts "DADDR_15: ERROR: M must be 2 to 128\t-CLKFBOUT Register 2-\tNOTE: The calculations are only for the non-fractional settings. CLKFBOUT must use an integer divide value for these DRP settings to work"
        return "14 ERROR 15 ERROR "
    } elseif {[expr fmod($divide,1)] > 0} {
        set drp_frac_registers [xapp888_drp_clkout_frac $divide $phase ]
        set drp_reg1 [xapp888_bin2hex [lindex $drp_frac_registers 0]]
        set drp_reg2 [xapp888_bin2hex [lindex $drp_frac_registers 1]]
#       For Olympus, CDDC_EN shifts the PM_F/WF_F bits to be 15:12 instead of 13:10
        set drp_regshared [xapp888_bin2hex [lindex $drp_frac_registers 2]000000000000]
####        puts "DADDR_$daddr_reg1: $drp_reg1\t-CLKFBOUT Register 1- "
####        puts "DADDR_$daddr_reg2: $drp_reg2\t-CLKFBOUT Register 2- "
####        puts "DADDR_$daddr_regshared: $drp_regshared\t-CLKFBOUT Register Shared with CLKOUT6- "
        return "  $daddr_reg1$drp_reg1  $daddr_reg2$drp_reg2  13$drp_regshared"
    } else {
####        puts "DADDR_$daddr_reg1: [xapp888_bin2hex [binary scan [binary format I $pmphasecycles] B32 var;string range $var end-2 end]1[xapp888_dec2bin4ltht $ht][xapp888_dec2bin4ltht $lt]]\t-CLKFBOUT Register 1- "
####        puts "DADDR_$daddr_reg2: [xapp888_bin2hex 00000000[expr $odd]0[binary scan [binary format I $phasecycles] B32 var;string range $var end-5 end] ]\t-CLKFBOUT Register 2- "
        return "  $daddr_reg1[xapp888_bin2hex [binary scan [binary format I $pmphasecycles] B32 var;string range $var end-2 end]1[xapp888_dec2bin4ltht $ht][xapp888_dec2bin4ltht $lt]]  $daddr_reg2[xapp888_bin2hex 00000000[expr $odd]0[binary scan [binary format I $phasecycles] B32 var;string range $var end-5 end] ]"
    }
}

proc xapp888_drp_calc_d {divide} {
    set ht [scan [expr ($divide ) / 2] %d]
    set lt [scan [expr $divide - $ht] %d]
    if {$divide == 1} {
####        puts "DADDR_16: [xapp888_bin2hex 0001000001000001]\t-DIVCLK Register $divide-"
        return "16 [xapp888_bin2hex 0001000001000001]"
    } elseif { $divide > 106} {
        puts "DADDR_16: ERROR D must be 1 to 106"
        return "16 ERROR"
    } else {
####        puts "DADDR_16: [xapp888_bin2hex 0000[xapp888_dec2bin4ltht\
              $ht][xapp888_dec2bin4ltht $lt]]\t-DIVCLK Register $divide-" }

        return "  16[xapp888_bin2hex 0000[xapp888_dec2bin4ltht $ht][xapp888_dec2bin4ltht $lt] ]"
}

proc xapp888_dec2bin4ltht {dec} {
     binary scan [binary format c $dec] B* bin
     string range $bin end-5 end
}

proc xapp888_cpres {div bw} {
    #CP_RES_LFHF
    set div [scan $div %d]
    set bw_lower [string tolower $bw]
    if {$bw_lower == "low" } then {
        switch -glob -- $div {
       	1    {set CP 0011 ; set RES 1111  ; set LFHF 11 }
       	2    {set CP 0011 ; set RES 1111  ; set LFHF 11 }
       	3    {set CP 0011 ; set RES 1101  ; set LFHF 11 }
       	4    {set CP 0011 ; set RES 0101  ; set LFHF 11 }
       	5    {set CP 0011 ; set RES 1001  ; set LFHF 11 }
       	6    {set CP 0011 ; set RES 1110  ; set LFHF 11 }
       	7    {set CP 0011 ; set RES 1110  ; set LFHF 11 }
       	8    {set CP 0011 ; set RES 0001  ; set LFHF 11 }
       	9    {set CP 0011 ; set RES 0110  ; set LFHF 11 }
       	10   {set CP 0011 ; set RES 0110  ; set LFHF 11 }
       	11   {set CP 0011 ; set RES 0110  ; set LFHF 11 }
       	12   {set CP 0011 ; set RES 1010  ; set LFHF 11 }
       	13   {set CP 0011 ; set RES 1010  ; set LFHF 11 }
       	14   {set CP 0011 ; set RES 1010  ; set LFHF 11 }
       	15   {set CP 0100 ; set RES 0110  ; set LFHF 11 }
       	16   {set CP 0011 ; set RES 1100  ; set LFHF 11 }
       	17   {set CP 1110 ; set RES 0110  ; set LFHF 11 }
       	18   {set CP 1111 ; set RES 0110  ; set LFHF 11 }
       	19   {set CP 1110 ; set RES 1010  ; set LFHF 11 }
       	20   {set CP 1110 ; set RES 1010  ; set LFHF 11 }
       	21   {set CP 1111 ; set RES 1010  ; set LFHF 11 }
       	22   {set CP 1111 ; set RES 1010  ; set LFHF 11 }
       	23   {set CP 1111 ; set RES 1010  ; set LFHF 11 }
       	24   {set CP 1111 ; set RES 1010  ; set LFHF 11 }
       	25   {set CP 1111 ; set RES 1010  ; set LFHF 11 }
       	26   {set CP 1101 ; set RES 1100  ; set LFHF 11 }
       	27   {set CP 1101 ; set RES 1100  ; set LFHF 11 }
       	28   {set CP 1101 ; set RES 1100  ; set LFHF 11 }
       	29   {set CP 1110 ; set RES 1100  ; set LFHF 11 }
       	30   {set CP 1110 ; set RES 1100  ; set LFHF 11 }
       	31   {set CP 1110 ; set RES 1100  ; set LFHF 11 }
       	32   {set CP 1111 ; set RES 1100  ; set LFHF 11 }
       	33   {set CP 1111 ; set RES 1100  ; set LFHF 11 }
       	34   {set CP 1111 ; set RES 1100  ; set LFHF 11 }
       	35   {set CP 1111 ; set RES 1100  ; set LFHF 11 }
       	36   {set CP 1111 ; set RES 1100  ; set LFHF 11 }
       	37   {set CP 1111 ; set RES 1100  ; set LFHF 11 }
       	38   {set CP 1110 ; set RES 0010  ; set LFHF 11 }
       	39   {set CP 1110 ; set RES 0010  ; set LFHF 11 }
       	40   {set CP 1110 ; set RES 0010  ; set LFHF 11 }
       	41   {set CP 1110 ; set RES 0010  ; set LFHF 11 }
       	42   {set CP 1111 ; set RES 0010  ; set LFHF 11 }
       	43   {set CP 1111 ; set RES 0010  ; set LFHF 11 }
       	44   {set CP 1111 ; set RES 0010  ; set LFHF 11 }
       	45   {set CP 1111 ; set RES 0010  ; set LFHF 11 }
       	46   {set CP 1111 ; set RES 0010  ; set LFHF 11 }
       	47   {set CP 1111 ; set RES 0010  ; set LFHF 11 }
       	48   {set CP 1111 ; set RES 0010  ; set LFHF 11 }
       	49   {set CP 1111 ; set RES 0010  ; set LFHF 11 }
       	50   {set CP 1111 ; set RES 0010  ; set LFHF 11 }
       	51   {set CP 1111 ; set RES 0010  ; set LFHF 11 }
       	52   {set CP 1111 ; set RES 0010  ; set LFHF 11 }
       	53   {set CP 1111 ; set RES 0010  ; set LFHF 11 }
       	54   {set CP 1111 ; set RES 0010  ; set LFHF 11 }
       	55   {set CP 1111 ; set RES 0010  ; set LFHF 11 }
       	56   {set CP 1111 ; set RES 0010  ; set LFHF 11 }
       	57   {set CP 1111 ; set RES 0010  ; set LFHF 11 }
       	58   {set CP 1111 ; set RES 0010  ; set LFHF 11 }
       	59   {set CP 1111 ; set RES 0010  ; set LFHF 11 }
       	60   {set CP 1111 ; set RES 0010  ; set LFHF 11 }
       	61   {set CP 1111 ; set RES 0010  ; set LFHF 11 }
       	62   {set CP 1111 ; set RES 0010  ; set LFHF 11 }
       	63   {set CP 1100 ; set RES 0100  ; set LFHF 11 }
       	64   {set CP 1100 ; set RES 0100  ; set LFHF 11 }
       	65   {set CP 1100 ; set RES 0100  ; set LFHF 11 }
       	66   {set CP 1100 ; set RES 0100  ; set LFHF 11 }
       	67   {set CP 1100 ; set RES 0100  ; set LFHF 11 }
       	68   {set CP 1100 ; set RES 0100  ; set LFHF 11 }
       	69   {set CP 1100 ; set RES 0100  ; set LFHF 11 }
       	70   {set CP 1100 ; set RES 0100  ; set LFHF 11 }
       	71   {set CP 1101 ; set RES 0100  ; set LFHF 11 }
       	72   {set CP 1101 ; set RES 0100  ; set LFHF 11 }
       	73   {set CP 1101 ; set RES 0100  ; set LFHF 11 }
       	74   {set CP 1101 ; set RES 0100  ; set LFHF 11 }
       	75   {set CP 1101 ; set RES 0100  ; set LFHF 11 }
       	76   {set CP 1101 ; set RES 0100  ; set LFHF 11 }
       	77   {set CP 1101 ; set RES 0100  ; set LFHF 11 }
       	78   {set CP 1110 ; set RES 0100  ; set LFHF 11 }
       	79   {set CP 1110 ; set RES 0100  ; set LFHF 11 }
       	80   {set CP 1110 ; set RES 0100  ; set LFHF 11 }
       	81   {set CP 1110 ; set RES 0100  ; set LFHF 11 }
       	82   {set CP 1110 ; set RES 0100  ; set LFHF 11 }
       	83   {set CP 1110 ; set RES 0100  ; set LFHF 11 }
       	84   {set CP 1110 ; set RES 0100  ; set LFHF 11 }
       	85   {set CP 1110 ; set RES 0100  ; set LFHF 11 }
       	86   {set CP 1111 ; set RES 0100  ; set LFHF 11 }
       	87   {set CP 1111 ; set RES 0100  ; set LFHF 11 }
       	88   {set CP 1111 ; set RES 0100  ; set LFHF 11 }
       	89   {set CP 1111 ; set RES 0100  ; set LFHF 11 }
       	90   {set CP 1111 ; set RES 0100  ; set LFHF 11 }
       	91   {set CP 1111 ; set RES 0100  ; set LFHF 11 }
       	92   {set CP 1111 ; set RES 0100  ; set LFHF 11 }
       	93   {set CP 1111 ; set RES 0100  ; set LFHF 11 }
       	94   {set CP 1111 ; set RES 0100  ; set LFHF 11 }
       	95   {set CP 1111 ; set RES 0100  ; set LFHF 11 }
       	96   {set CP 1111 ; set RES 0100  ; set LFHF 11 }
       	97   {set CP 1111 ; set RES 0100  ; set LFHF 11 }
       	98   {set CP 1111 ; set RES 0100  ; set LFHF 11 }
       	99   {set CP 1111 ; set RES 0100  ; set LFHF 11 }
       	100  {set CP 1111 ; set RES 0100  ; set LFHF 11 }
       	101  {set CP 1111 ; set RES 0100  ; set LFHF 11 }
       	102  {set CP 1111 ; set RES 0100  ; set LFHF 11 }
       	103  {set CP 1111 ; set RES 0100  ; set LFHF 11 }
       	104  {set CP 1111 ; set RES 0100  ; set LFHF 11 }
       	105  {set CP 1111 ; set RES 0100  ; set LFHF 11 }
       	106  {set CP 1111 ; set RES 0100  ; set LFHF 11 }
       	107  {set CP 1111 ; set RES 0100  ; set LFHF 11 }
       	108  {set CP 1111 ; set RES 0100  ; set LFHF 11 }
       	109  {set CP 1111 ; set RES 0100  ; set LFHF 11 }
       	110  {set CP 1111 ; set RES 0100  ; set LFHF 11 }
       	111  {set CP 1111 ; set RES 0100  ; set LFHF 11 }
       	112  {set CP 1111 ; set RES 0100  ; set LFHF 11 }
       	113  {set CP 1111 ; set RES 0100  ; set LFHF 11 }
       	114  {set CP 1111 ; set RES 0100  ; set LFHF 11 }
       	115  {set CP 1111 ; set RES 0100  ; set LFHF 11 }
       	116  {set CP 1111 ; set RES 0100  ; set LFHF 11 }
       	117  {set CP 1111 ; set RES 0100  ; set LFHF 11 }
       	118  {set CP 1111 ; set RES 0100  ; set LFHF 11 }
       	119  {set CP 1111 ; set RES 0100  ; set LFHF 11 }
       	120  {set CP 1101 ; set RES 1000  ; set LFHF 11 }
       	121  {set CP 1101 ; set RES 1000  ; set LFHF 11 }
       	122  {set CP 1101 ; set RES 1000  ; set LFHF 11 }
       	123  {set CP 1101 ; set RES 1000  ; set LFHF 11 }
       	124  {set CP 1101 ; set RES 1000  ; set LFHF 11 }
       	125  {set CP 1101 ; set RES 1000  ; set LFHF 11 }
       	126  {set CP 1101 ; set RES 1000  ; set LFHF 11 }
       	127  {set CP 1101 ; set RES 1000  ; set LFHF 11 }
       	128  {set CP 1101 ; set RES 1000  ; set LFHF 11 }
        }
    } else {
      # HIGH or OTIMIZED
        switch -glob -- $div {
           1    {set CP 0111 ; set RES 1111  ; set LFHF 11 }
           2    {set CP 0111 ; set RES 1111  ; set LFHF 11 }
           3    {set CP 1110 ; set RES 1111  ; set LFHF 11 }
           4    {set CP 1111 ; set RES 1111  ; set LFHF 11 }
           5    {set CP 1111 ; set RES 1011  ; set LFHF 11 }
           6    {set CP 1111 ; set RES 1101  ; set LFHF 11 }
           7    {set CP 1111 ; set RES 0011  ; set LFHF 11 }
           8    {set CP 1110 ; set RES 0101  ; set LFHF 11 }
           9    {set CP 1111 ; set RES 1001  ; set LFHF 11 }
           10   {set CP 1111 ; set RES 1001  ; set LFHF 11 }
           11   {set CP 1110 ; set RES 1110  ; set LFHF 11 }
           12   {set CP 1111 ; set RES 1110  ; set LFHF 11 }
           13   {set CP 1111 ; set RES 0001  ; set LFHF 11 }
           14   {set CP 1111 ; set RES 0001  ; set LFHF 11 }
           15   {set CP 1111 ; set RES 0001  ; set LFHF 11 }
           16   {set CP 1110 ; set RES 0110  ; set LFHF 11 }
           17   {set CP 1110 ; set RES 0110  ; set LFHF 11 }
           18   {set CP 1111 ; set RES 0110  ; set LFHF 11 }
           19   {set CP 1110 ; set RES 1010  ; set LFHF 11 }
           20   {set CP 1110 ; set RES 1010  ; set LFHF 11 }
           21   {set CP 1111 ; set RES 1010  ; set LFHF 11 }
           22   {set CP 1111 ; set RES 1010  ; set LFHF 11 }
           23   {set CP 1111 ; set RES 1010  ; set LFHF 11 }
           24   {set CP 1111 ; set RES 1010  ; set LFHF 11 }
           25   {set CP 1111 ; set RES 1010  ; set LFHF 11 }
           26   {set CP 1101 ; set RES 1100  ; set LFHF 11 }
           27   {set CP 1101 ; set RES 1100  ; set LFHF 11 }
           28   {set CP 1101 ; set RES 1100  ; set LFHF 11 }
           29   {set CP 1110 ; set RES 1100  ; set LFHF 11 }
           30   {set CP 1110 ; set RES 1100  ; set LFHF 11 }
           31   {set CP 1110 ; set RES 1100  ; set LFHF 11 }
           32   {set CP 1111 ; set RES 1100  ; set LFHF 11 }
           33   {set CP 1111 ; set RES 1100  ; set LFHF 11 }
           34   {set CP 1111 ; set RES 1100  ; set LFHF 11 }
           35   {set CP 1111 ; set RES 1100  ; set LFHF 11 }
           36   {set CP 1111 ; set RES 1100  ; set LFHF 11 }
           37   {set CP 1111 ; set RES 1100  ; set LFHF 11 }
           38   {set CP 1110 ; set RES 0010  ; set LFHF 11 }
           39   {set CP 1110 ; set RES 0010  ; set LFHF 11 }
           40   {set CP 1110 ; set RES 0010  ; set LFHF 11 }
           41   {set CP 1110 ; set RES 0010  ; set LFHF 11 }
           42   {set CP 1111 ; set RES 0010  ; set LFHF 11 }
           43   {set CP 1111 ; set RES 0010  ; set LFHF 11 }
           44   {set CP 1111 ; set RES 0010  ; set LFHF 11 }
           45   {set CP 1111 ; set RES 0010  ; set LFHF 11 }
           46   {set CP 1111 ; set RES 0010  ; set LFHF 11 }
           47   {set CP 1111 ; set RES 0010  ; set LFHF 11 }
           48   {set CP 1111 ; set RES 0010  ; set LFHF 11 }
           49   {set CP 1111 ; set RES 0010  ; set LFHF 11 }
           50   {set CP 1111 ; set RES 0010  ; set LFHF 11 }
           51   {set CP 1111 ; set RES 0010  ; set LFHF 11 }
           52   {set CP 1111 ; set RES 0010  ; set LFHF 11 }
           53   {set CP 1111 ; set RES 0010  ; set LFHF 11 }
           54   {set CP 1111 ; set RES 0010  ; set LFHF 11 }
           55   {set CP 1111 ; set RES 0010  ; set LFHF 11 }
           56   {set CP 1111 ; set RES 0010  ; set LFHF 11 }
           57   {set CP 1111 ; set RES 0010  ; set LFHF 11 }
           58   {set CP 1111 ; set RES 0010  ; set LFHF 11 }
           59   {set CP 1111 ; set RES 0010  ; set LFHF 11 }
           60   {set CP 1111 ; set RES 0010  ; set LFHF 11 }
           61   {set CP 1111 ; set RES 0010  ; set LFHF 11 }
           62   {set CP 1111 ; set RES 0010  ; set LFHF 11 }
           63   {set CP 1100 ; set RES 0100  ; set LFHF 11 }
           64   {set CP 1100 ; set RES 0100  ; set LFHF 11 }
           65   {set CP 1100 ; set RES 0100  ; set LFHF 11 }
           66   {set CP 1100 ; set RES 0100  ; set LFHF 11 }
           67   {set CP 1100 ; set RES 0100  ; set LFHF 11 }
           68   {set CP 1100 ; set RES 0100  ; set LFHF 11 }
           69   {set CP 1100 ; set RES 0100  ; set LFHF 11 }
           70   {set CP 1100 ; set RES 0100  ; set LFHF 11 }
           71   {set CP 1101 ; set RES 0100  ; set LFHF 11 }
           72   {set CP 1101 ; set RES 0100  ; set LFHF 11 }
           73   {set CP 1101 ; set RES 0100  ; set LFHF 11 }
           74   {set CP 1101 ; set RES 0100  ; set LFHF 11 }
           75   {set CP 1101 ; set RES 0100  ; set LFHF 11 }
           76   {set CP 1101 ; set RES 0100  ; set LFHF 11 }
           77   {set CP 1101 ; set RES 0100  ; set LFHF 11 }
           78   {set CP 1110 ; set RES 0100  ; set LFHF 11 }
           79   {set CP 1110 ; set RES 0100  ; set LFHF 11 }
           80   {set CP 1110 ; set RES 0100  ; set LFHF 11 }
           81   {set CP 1110 ; set RES 0100  ; set LFHF 11 }
           82   {set CP 1110 ; set RES 0100  ; set LFHF 11 }
           83   {set CP 1110 ; set RES 0100  ; set LFHF 11 }
           84   {set CP 1110 ; set RES 0100  ; set LFHF 11 }
           85   {set CP 1110 ; set RES 0100  ; set LFHF 11 }
           86   {set CP 1111 ; set RES 0100  ; set LFHF 11 }
           87   {set CP 1111 ; set RES 0100  ; set LFHF 11 }
           88   {set CP 1111 ; set RES 0100  ; set LFHF 11 }
           89   {set CP 1111 ; set RES 0100  ; set LFHF 11 }
           90   {set CP 1111 ; set RES 0100  ; set LFHF 11 }
           91   {set CP 1111 ; set RES 0100  ; set LFHF 11 }
           92   {set CP 1111 ; set RES 0100  ; set LFHF 11 }
           93   {set CP 1111 ; set RES 0100  ; set LFHF 11 }
           94   {set CP 1111 ; set RES 0100  ; set LFHF 11 }
           95   {set CP 1111 ; set RES 0100  ; set LFHF 11 }
           96   {set CP 1111 ; set RES 0100  ; set LFHF 11 }
           97   {set CP 1111 ; set RES 0100  ; set LFHF 11 }
           98   {set CP 1111 ; set RES 0100  ; set LFHF 11 }
           99   {set CP 1111 ; set RES 0100  ; set LFHF 11 }
           100  {set CP 1111 ; set RES 0100  ; set LFHF 11 }
           101  {set CP 1111 ; set RES 0100  ; set LFHF 11 }
           102  {set CP 1111 ; set RES 0100  ; set LFHF 11 }
           103  {set CP 1111 ; set RES 0100  ; set LFHF 11 }
           104  {set CP 1111 ; set RES 0100  ; set LFHF 11 }
           105  {set CP 1111 ; set RES 0100  ; set LFHF 11 }
           106  {set CP 1111 ; set RES 0100  ; set LFHF 11 }
           107  {set CP 1111 ; set RES 0100  ; set LFHF 11 }
           108  {set CP 1111 ; set RES 0100  ; set LFHF 11 }
           109  {set CP 1111 ; set RES 0100  ; set LFHF 11 }
           110  {set CP 1111 ; set RES 0100  ; set LFHF 11 }
           111  {set CP 1111 ; set RES 0100  ; set LFHF 11 }
           112  {set CP 1111 ; set RES 0100  ; set LFHF 11 }
           113  {set CP 1111 ; set RES 0100  ; set LFHF 11 }
           114  {set CP 1111 ; set RES 0100  ; set LFHF 11 }
           115  {set CP 1111 ; set RES 0100  ; set LFHF 11 }
           116  {set CP 1111 ; set RES 0100  ; set LFHF 11 }
           117  {set CP 1111 ; set RES 0100  ; set LFHF 11 }
           118  {set CP 1111 ; set RES 0100  ; set LFHF 11 }
           119  {set CP 1111 ; set RES 0100  ; set LFHF 11 }
           120  {set CP 1101 ; set RES 1000  ; set LFHF 11 }
           121  {set CP 1101 ; set RES 1000  ; set LFHF 11 }
           122  {set CP 1101 ; set RES 1000  ; set LFHF 11 }
           123  {set CP 1101 ; set RES 1000  ; set LFHF 11 }
           124  {set CP 1101 ; set RES 1000  ; set LFHF 11 }
           125  {set CP 1101 ; set RES 1000  ; set LFHF 11 }
           126  {set CP 1101 ; set RES 1000  ; set LFHF 11 }
           127  {set CP 1101 ; set RES 1000  ; set LFHF 11 }
           128  {set CP 1101 ; set RES 1000  ; set LFHF 11 }
       }
    }
####        puts "DADDR_4E: [xapp888_bin2hex "[string index $CP 0]00[string range \
             $CP 1 2]00[string index $CP 3]00000000"]\t-Filter Register 1: M \
             set to $div with $bw bandwidth-"
####        puts "DADDR_4F: [xapp888_bin2hex "[string index $RES 0]00[string range \
             $RES 1 2]00[string index $RES 3][string index $LFHF 0]00[string \
             index $LFHF 1]0000"]\t-Filter Register 2: M set to $div with $bw bandwidth-"
        return "  4F[xapp888_bin2hex "[string index $RES 0]00[string range \
               $RES 1 2]00[string index $RES 3][string index $LFHF 0]00[string\
               index $LFHF 1]0000"] 4E[xapp888_bin2hex "[string index \
               $CP 0]00[string range $CP 1 2]00[string index $CP 3]00000000"]"
}

proc xapp888_locking {div} {
        # LockRefDly_LockFBDly_LockCnt_LockSatHigh_UnlockCnt
        set div [scan $div %d]
        switch -glob -- $div {
            1 {set LockRefDly 00110 ; set LockFBDly 00110 ; set LockCnt  1111101000 ; set LockSatHigh 1111101001 ; set UnlockCnt 0000000001}
            2 {set LockRefDly 00110 ; set LockFBDly 00110 ; set LockCnt  1111101000 ; set LockSatHigh 1111101001 ; set UnlockCnt 0000000001}
            3 {set LockRefDly 01000 ; set LockFBDly 01000 ; set LockCnt  1111101000 ; set LockSatHigh 1111101001 ; set UnlockCnt 0000000001}
            4 {set LockRefDly 01011 ; set LockFBDly 01011 ; set LockCnt  1111101000 ; set LockSatHigh 1111101001 ; set UnlockCnt 0000000001}
            5 {set LockRefDly 01110 ; set LockFBDly 01110 ; set LockCnt  1111101000 ; set LockSatHigh 1111101001 ; set UnlockCnt 0000000001}
            6 {set LockRefDly 10001 ; set LockFBDly 10001 ; set LockCnt  1111101000 ; set LockSatHigh 1111101001 ; set UnlockCnt 0000000001}
            7 {set LockRefDly 10011 ; set LockFBDly 10011 ; set LockCnt  1111101000 ; set LockSatHigh 1111101001 ; set UnlockCnt 0000000001}
            8 {set LockRefDly 10110 ; set LockFBDly 10110 ; set LockCnt  1111101000 ; set LockSatHigh 1111101001 ; set UnlockCnt 0000000001}
            9 {set LockRefDly 11001 ; set LockFBDly 11001 ; set LockCnt  1111101000 ; set LockSatHigh 1111101001 ; set UnlockCnt 0000000001}
            10 {set LockRefDly 11100 ; set LockFBDly 11100 ; set LockCnt  1111101000 ; set LockSatHigh 1111101001 ; set UnlockCnt 0000000001}
            11 {set LockRefDly 11111 ; set LockFBDly 11111 ; set LockCnt  1110000100 ; set LockSatHigh 1111101001 ; set UnlockCnt 0000000001}
            12 {set LockRefDly 11111 ; set LockFBDly 11111 ; set LockCnt  1100111001 ; set LockSatHigh 1111101001 ; set UnlockCnt 0000000001}
            13 {set LockRefDly 11111 ; set LockFBDly 11111 ; set LockCnt  1011101110 ; set LockSatHigh 1111101001 ; set UnlockCnt 0000000001}
            14 {set LockRefDly 11111 ; set LockFBDly 11111 ; set LockCnt  1010111100 ; set LockSatHigh 1111101001 ; set UnlockCnt 0000000001}
            15 {set LockRefDly 11111 ; set LockFBDly 11111 ; set LockCnt  1010001010 ; set LockSatHigh 1111101001 ; set UnlockCnt 0000000001}
            16 {set LockRefDly 11111 ; set LockFBDly 11111 ; set LockCnt  1001110001 ; set LockSatHigh 1111101001 ; set UnlockCnt 0000000001}
            17 {set LockRefDly 11111 ; set LockFBDly 11111 ; set LockCnt  1000111111 ; set LockSatHigh 1111101001 ; set UnlockCnt 0000000001}
            18 {set LockRefDly 11111 ; set LockFBDly 11111 ; set LockCnt  1000100110 ; set LockSatHigh 1111101001 ; set UnlockCnt 0000000001}
            19 {set LockRefDly 11111 ; set LockFBDly 11111 ; set LockCnt  1000001101 ; set LockSatHigh 1111101001 ; set UnlockCnt 0000000001}
            20 {set LockRefDly 11111 ; set LockFBDly 11111 ; set LockCnt  0111110100 ; set LockSatHigh 1111101001 ; set UnlockCnt 0000000001}
            21 {set LockRefDly 11111 ; set LockFBDly 11111 ; set LockCnt  0111011011 ; set LockSatHigh 1111101001 ; set UnlockCnt 0000000001}
            22 {set LockRefDly 11111 ; set LockFBDly 11111 ; set LockCnt  0111000010 ; set LockSatHigh 1111101001 ; set UnlockCnt 0000000001}
            23 {set LockRefDly 11111 ; set LockFBDly 11111 ; set LockCnt  0110101001 ; set LockSatHigh 1111101001 ; set UnlockCnt 0000000001}
            24 {set LockRefDly 11111 ; set LockFBDly 11111 ; set LockCnt  0110010000 ; set LockSatHigh 1111101001 ; set UnlockCnt 0000000001}
            25 {set LockRefDly 11111 ; set LockFBDly 11111 ; set LockCnt  0110010000 ; set LockSatHigh 1111101001 ; set UnlockCnt 0000000001}
            26 {set LockRefDly 11111 ; set LockFBDly 11111 ; set LockCnt  0101110111 ; set LockSatHigh 1111101001 ; set UnlockCnt 0000000001}
            27 {set LockRefDly 11111 ; set LockFBDly 11111 ; set LockCnt  0101011110 ; set LockSatHigh 1111101001 ; set UnlockCnt 0000000001}
            28 {set LockRefDly 11111 ; set LockFBDly 11111 ; set LockCnt  0101011110 ; set LockSatHigh 1111101001 ; set UnlockCnt 0000000001}
            29 {set LockRefDly 11111 ; set LockFBDly 11111 ; set LockCnt  0101000101 ; set LockSatHigh 1111101001 ; set UnlockCnt 0000000001}
            30 {set LockRefDly 11111 ; set LockFBDly 11111 ; set LockCnt  0101000101 ; set LockSatHigh 1111101001 ; set UnlockCnt 0000000001}
            31 {set LockRefDly 11111 ; set LockFBDly 11111 ; set LockCnt  0100101100 ; set LockSatHigh 1111101001 ; set UnlockCnt 0000000001}
            32 {set LockRefDly 11111 ; set LockFBDly 11111 ; set LockCnt  0100101100 ; set LockSatHigh 1111101001 ; set UnlockCnt 0000000001}
            33 {set LockRefDly 11111 ; set LockFBDly 11111 ; set LockCnt  0100101100 ; set LockSatHigh 1111101001 ; set UnlockCnt 0000000001}
            34 {set LockRefDly 11111 ; set LockFBDly 11111 ; set LockCnt  0100010011 ; set LockSatHigh 1111101001 ; set UnlockCnt 0000000001}
            35 {set LockRefDly 11111 ; set LockFBDly 11111 ; set LockCnt  0100010011 ; set LockSatHigh 1111101001 ; set UnlockCnt 0000000001}
            36 {set LockRefDly 11111 ; set LockFBDly 11111 ; set LockCnt  0100010011 ; set LockSatHigh 1111101001 ; set UnlockCnt 0000000001}
            37 {set LockRefDly 11111 ; set LockFBDly 11111 ; set LockCnt  0011111010 ; set LockSatHigh 1111101001 ; set UnlockCnt 0000000001}
            38 {set LockRefDly 11111 ; set LockFBDly 11111 ; set LockCnt  0011111010 ; set LockSatHigh 1111101001 ; set UnlockCnt 0000000001}
            39 {set LockRefDly 11111 ; set LockFBDly 11111 ; set LockCnt  0011111010 ; set LockSatHigh 1111101001 ; set UnlockCnt 0000000001}
            40 {set LockRefDly 11111 ; set LockFBDly 11111 ; set LockCnt  0011111010 ; set LockSatHigh 1111101001 ; set UnlockCnt 0000000001}
            41 {set LockRefDly 11111 ; set LockFBDly 11111 ; set LockCnt  0011111010 ; set LockSatHigh 1111101001 ; set UnlockCnt 0000000001}
            42 {set LockRefDly 11111 ; set LockFBDly 11111 ; set LockCnt  0011111010 ; set LockSatHigh 1111101001 ; set UnlockCnt 0000000001}
            43 {set LockRefDly 11111 ; set LockFBDly 11111 ; set LockCnt  0011111010 ; set LockSatHigh 1111101001 ; set UnlockCnt 0000000001}
            44 {set LockRefDly 11111 ; set LockFBDly 11111 ; set LockCnt  0011111010 ; set LockSatHigh 1111101001 ; set UnlockCnt 0000000001}
            45 {set LockRefDly 11111 ; set LockFBDly 11111 ; set LockCnt  0011111010 ; set LockSatHigh 1111101001 ; set UnlockCnt 0000000001}
            46 {set LockRefDly 11111 ; set LockFBDly 11111 ; set LockCnt  0011111010 ; set LockSatHigh 1111101001 ; set UnlockCnt 0000000001}
            47 {set LockRefDly 11111 ; set LockFBDly 11111 ; set LockCnt  0011111010 ; set LockSatHigh 1111101001 ; set UnlockCnt 0000000001}
            48 {set LockRefDly 11111 ; set LockFBDly 11111 ; set LockCnt  0011111010 ; set LockSatHigh 1111101001 ; set UnlockCnt 0000000001}
            49 {set LockRefDly 11111 ; set LockFBDly 11111 ; set LockCnt  0011111010 ; set LockSatHigh 1111101001 ; set UnlockCnt 0000000001}
            50 {set LockRefDly 11111 ; set LockFBDly 11111 ; set LockCnt  0011111010 ; set LockSatHigh 1111101001 ; set UnlockCnt 0000000001}
            51 {set LockRefDly 11111 ; set LockFBDly 11111 ; set LockCnt  0011111010 ; set LockSatHigh 1111101001 ; set UnlockCnt 0000000001}
            52 {set LockRefDly 11111 ; set LockFBDly 11111 ; set LockCnt  0011111010 ; set LockSatHigh 1111101001 ; set UnlockCnt 0000000001}
            53 {set LockRefDly 11111 ; set LockFBDly 11111 ; set LockCnt  0011111010 ; set LockSatHigh 1111101001 ; set UnlockCnt 0000000001}
            54 {set LockRefDly 11111 ; set LockFBDly 11111 ; set LockCnt  0011111010 ; set LockSatHigh 1111101001 ; set UnlockCnt 0000000001}
            55 {set LockRefDly 11111 ; set LockFBDly 11111 ; set LockCnt  0011111010 ; set LockSatHigh 1111101001 ; set UnlockCnt 0000000001}
            56 {set LockRefDly 11111 ; set LockFBDly 11111 ; set LockCnt  0011111010 ; set LockSatHigh 1111101001 ; set UnlockCnt 0000000001}
            57 {set LockRefDly 11111 ; set LockFBDly 11111 ; set LockCnt  0011111010 ; set LockSatHigh 1111101001 ; set UnlockCnt 0000000001}
            58 {set LockRefDly 11111 ; set LockFBDly 11111 ; set LockCnt  0011111010 ; set LockSatHigh 1111101001 ; set UnlockCnt 0000000001}
            59 {set LockRefDly 11111 ; set LockFBDly 11111 ; set LockCnt  0011111010 ; set LockSatHigh 1111101001 ; set UnlockCnt 0000000001}
            60 {set LockRefDly 11111 ; set LockFBDly 11111 ; set LockCnt  0011111010 ; set LockSatHigh 1111101001 ; set UnlockCnt 0000000001}
            61 {set LockRefDly 11111 ; set LockFBDly 11111 ; set LockCnt  0011111010 ; set LockSatHigh 1111101001 ; set UnlockCnt 0000000001}
            62 {set LockRefDly 11111 ; set LockFBDly 11111 ; set LockCnt  0011111010 ; set LockSatHigh 1111101001 ; set UnlockCnt 0000000001}
            63 {set LockRefDly 11111 ; set LockFBDly 11111 ; set LockCnt  0011111010 ; set LockSatHigh 1111101001 ; set UnlockCnt 0000000001}
            64 {set LockRefDly 11111 ; set LockFBDly 11111 ; set LockCnt  0011111010 ; set LockSatHigh 1111101001 ; set UnlockCnt 0000000001}
            65 {set LockRefDly 11111 ; set LockFBDly 11111 ; set LockCnt  0011111010 ; set LockSatHigh 1111101001 ; set UnlockCnt 0000000001}
            66 {set LockRefDly 11111 ; set LockFBDly 11111 ; set LockCnt  0011111010 ; set LockSatHigh 1111101001 ; set UnlockCnt 0000000001}
            67 {set LockRefDly 11111 ; set LockFBDly 11111 ; set LockCnt  0011111010 ; set LockSatHigh 1111101001 ; set UnlockCnt 0000000001}
            68 {set LockRefDly 11111 ; set LockFBDly 11111 ; set LockCnt  0011111010 ; set LockSatHigh 1111101001 ; set UnlockCnt 0000000001}
            69 {set LockRefDly 11111 ; set LockFBDly 11111 ; set LockCnt  0011111010 ; set LockSatHigh 1111101001 ; set UnlockCnt 0000000001}
            70 {set LockRefDly 11111 ; set LockFBDly 11111 ; set LockCnt  0011111010 ; set LockSatHigh 1111101001 ; set UnlockCnt 0000000001}
            71 {set LockRefDly 11111 ; set LockFBDly 11111 ; set LockCnt  0011111010 ; set LockSatHigh 1111101001 ; set UnlockCnt 0000000001}
            72 {set LockRefDly 11111 ; set LockFBDly 11111 ; set LockCnt  0011111010 ; set LockSatHigh 1111101001 ; set UnlockCnt 0000000001}
            73 {set LockRefDly 11111 ; set LockFBDly 11111 ; set LockCnt  0011111010 ; set LockSatHigh 1111101001 ; set UnlockCnt 0000000001}
            74 {set LockRefDly 11111 ; set LockFBDly 11111 ; set LockCnt  0011111010 ; set LockSatHigh 1111101001 ; set UnlockCnt 0000000001}
            75 {set LockRefDly 11111 ; set LockFBDly 11111 ; set LockCnt  0011111010 ; set LockSatHigh 1111101001 ; set UnlockCnt 0000000001}
            76 {set LockRefDly 11111 ; set LockFBDly 11111 ; set LockCnt  0011111010 ; set LockSatHigh 1111101001 ; set UnlockCnt 0000000001}
            77 {set LockRefDly 11111 ; set LockFBDly 11111 ; set LockCnt  0011111010 ; set LockSatHigh 1111101001 ; set UnlockCnt 0000000001}
            78 {set LockRefDly 11111 ; set LockFBDly 11111 ; set LockCnt  0011111010 ; set LockSatHigh 1111101001 ; set UnlockCnt 0000000001}
            79 {set LockRefDly 11111 ; set LockFBDly 11111 ; set LockCnt  0011111010 ; set LockSatHigh 1111101001 ; set UnlockCnt 0000000001}
            80 {set LockRefDly 11111 ; set LockFBDly 11111 ; set LockCnt  0011111010 ; set LockSatHigh 1111101001 ; set UnlockCnt 0000000001}
            81 {set LockRefDly 11111 ; set LockFBDly 11111 ; set LockCnt  0011111010 ; set LockSatHigh 1111101001 ; set UnlockCnt 0000000001}
            82 {set LockRefDly 11111 ; set LockFBDly 11111 ; set LockCnt  0011111010 ; set LockSatHigh 1111101001 ; set UnlockCnt 0000000001}
            83 {set LockRefDly 11111 ; set LockFBDly 11111 ; set LockCnt  0011111010 ; set LockSatHigh 1111101001 ; set UnlockCnt 0000000001}
            84 {set LockRefDly 11111 ; set LockFBDly 11111 ; set LockCnt  0011111010 ; set LockSatHigh 1111101001 ; set UnlockCnt 0000000001}
            85 {set LockRefDly 11111 ; set LockFBDly 11111 ; set LockCnt  0011111010 ; set LockSatHigh 1111101001 ; set UnlockCnt 0000000001}
            86 {set LockRefDly 11111 ; set LockFBDly 11111 ; set LockCnt  0011111010 ; set LockSatHigh 1111101001 ; set UnlockCnt 0000000001}
            87 {set LockRefDly 11111 ; set LockFBDly 11111 ; set LockCnt  0011111010 ; set LockSatHigh 1111101001 ; set UnlockCnt 0000000001}
            88 {set LockRefDly 11111 ; set LockFBDly 11111 ; set LockCnt  0011111010 ; set LockSatHigh 1111101001 ; set UnlockCnt 0000000001}
            89 {set LockRefDly 11111 ; set LockFBDly 11111 ; set LockCnt  0011111010 ; set LockSatHigh 1111101001 ; set UnlockCnt 0000000001}
            90 {set LockRefDly 11111 ; set LockFBDly 11111 ; set LockCnt  0011111010 ; set LockSatHigh 1111101001 ; set UnlockCnt 0000000001}
            91 {set LockRefDly 11111 ; set LockFBDly 11111 ; set LockCnt  0011111010 ; set LockSatHigh 1111101001 ; set UnlockCnt 0000000001}
            92 {set LockRefDly 11111 ; set LockFBDly 11111 ; set LockCnt  0011111010 ; set LockSatHigh 1111101001 ; set UnlockCnt 0000000001}
            93 {set LockRefDly 11111 ; set LockFBDly 11111 ; set LockCnt  0011111010 ; set LockSatHigh 1111101001 ; set UnlockCnt 0000000001}
            94 {set LockRefDly 11111 ; set LockFBDly 11111 ; set LockCnt  0011111010 ; set LockSatHigh 1111101001 ; set UnlockCnt 0000000001}
            95 {set LockRefDly 11111 ; set LockFBDly 11111 ; set LockCnt  0011111010 ; set LockSatHigh 1111101001 ; set UnlockCnt 0000000001}
            96 {set LockRefDly 11111 ; set LockFBDly 11111 ; set LockCnt  0011111010 ; set LockSatHigh 1111101001 ; set UnlockCnt 0000000001}
            97 {set LockRefDly 11111 ; set LockFBDly 11111 ; set LockCnt  0011111010 ; set LockSatHigh 1111101001 ; set UnlockCnt 0000000001}
            98 {set LockRefDly 11111 ; set LockFBDly 11111 ; set LockCnt  0011111010 ; set LockSatHigh 1111101001 ; set UnlockCnt 0000000001}
            99 {set LockRefDly 11111 ; set LockFBDly 11111 ; set LockCnt  0011111010 ; set LockSatHigh 1111101001 ; set UnlockCnt 0000000001}
            100 {set LockRefDly 11111 ; set LockFBDly 11111 ; set LockCnt  0011111010 ; set LockSatHigh 1111101001 ; set UnlockCnt 0000000001}
            101 {set LockRefDly 11111 ; set LockFBDly 11111 ; set LockCnt  0011111010 ; set LockSatHigh 1111101001 ; set UnlockCnt 0000000001}
            102 {set LockRefDly 11111 ; set LockFBDly 11111 ; set LockCnt  0011111010 ; set LockSatHigh 1111101001 ; set UnlockCnt 0000000001}
            103 {set LockRefDly 11111 ; set LockFBDly 11111 ; set LockCnt  0011111010 ; set LockSatHigh 1111101001 ; set UnlockCnt 0000000001}
            104 {set LockRefDly 11111 ; set LockFBDly 11111 ; set LockCnt  0011111010 ; set LockSatHigh 1111101001 ; set UnlockCnt 0000000001}
            105 {set LockRefDly 11111 ; set LockFBDly 11111 ; set LockCnt  0011111010 ; set LockSatHigh 1111101001 ; set UnlockCnt 0000000001}
            106 {set LockRefDly 11111 ; set LockFBDly 11111 ; set LockCnt  0011111010 ; set LockSatHigh 1111101001 ; set UnlockCnt 0000000001}
            107 {set LockRefDly 11111 ; set LockFBDly 11111 ; set LockCnt  0011111010 ; set LockSatHigh 1111101001 ; set UnlockCnt 0000000001}
            108 {set LockRefDly 11111 ; set LockFBDly 11111 ; set LockCnt  0011111010 ; set LockSatHigh 1111101001 ; set UnlockCnt 0000000001}
            109 {set LockRefDly 11111 ; set LockFBDly 11111 ; set LockCnt  0011111010 ; set LockSatHigh 1111101001 ; set UnlockCnt 0000000001}
            110 {set LockRefDly 11111 ; set LockFBDly 11111 ; set LockCnt  0011111010 ; set LockSatHigh 1111101001 ; set UnlockCnt 0000000001}
            111 {set LockRefDly 11111 ; set LockFBDly 11111 ; set LockCnt  0011111010 ; set LockSatHigh 1111101001 ; set UnlockCnt 0000000001}
            112 {set LockRefDly 11111 ; set LockFBDly 11111 ; set LockCnt  0011111010 ; set LockSatHigh 1111101001 ; set UnlockCnt 0000000001}
            113 {set LockRefDly 11111 ; set LockFBDly 11111 ; set LockCnt  0011111010 ; set LockSatHigh 1111101001 ; set UnlockCnt 0000000001}
            114 {set LockRefDly 11111 ; set LockFBDly 11111 ; set LockCnt  0011111010 ; set LockSatHigh 1111101001 ; set UnlockCnt 0000000001}
            115 {set LockRefDly 11111 ; set LockFBDly 11111 ; set LockCnt  0011111010 ; set LockSatHigh 1111101001 ; set UnlockCnt 0000000001}
            116 {set LockRefDly 11111 ; set LockFBDly 11111 ; set LockCnt  0011111010 ; set LockSatHigh 1111101001 ; set UnlockCnt 0000000001}
            117 {set LockRefDly 11111 ; set LockFBDly 11111 ; set LockCnt  0011111010 ; set LockSatHigh 1111101001 ; set UnlockCnt 0000000001}
            118 {set LockRefDly 11111 ; set LockFBDly 11111 ; set LockCnt  0011111010 ; set LockSatHigh 1111101001 ; set UnlockCnt 0000000001}
            119 {set LockRefDly 11111 ; set LockFBDly 11111 ; set LockCnt  0011111010 ; set LockSatHigh 1111101001 ; set UnlockCnt 0000000001}
            120 {set LockRefDly 11111 ; set LockFBDly 11111 ; set LockCnt  0011111010 ; set LockSatHigh 1111101001 ; set UnlockCnt 0000000001}
            121 {set LockRefDly 11111 ; set LockFBDly 11111 ; set LockCnt  0011111010 ; set LockSatHigh 1111101001 ; set UnlockCnt 0000000001}
            122 {set LockRefDly 11111 ; set LockFBDly 11111 ; set LockCnt  0011111010 ; set LockSatHigh 1111101001 ; set UnlockCnt 0000000001}
            123 {set LockRefDly 11111 ; set LockFBDly 11111 ; set LockCnt  0011111010 ; set LockSatHigh 1111101001 ; set UnlockCnt 0000000001}
            124 {set LockRefDly 11111 ; set LockFBDly 11111 ; set LockCnt  0011111010 ; set LockSatHigh 1111101001 ; set UnlockCnt 0000000001}
            125 {set LockRefDly 11111 ; set LockFBDly 11111 ; set LockCnt  0011111010 ; set LockSatHigh 1111101001 ; set UnlockCnt 0000000001}
            126 {set LockRefDly 11111 ; set LockFBDly 11111 ; set LockCnt  0011111010 ; set LockSatHigh 1111101001 ; set UnlockCnt 0000000001}
            127 {set LockRefDly 11111 ; set LockFBDly 11111 ; set LockCnt  0011111010 ; set LockSatHigh 1111101001 ; set UnlockCnt 0000000001}
            128 {set LockRefDly 11111 ; set LockFBDly 11111 ; set LockCnt  0011111010 ; set LockSatHigh 1111101001 ; set UnlockCnt 0000000001}
         }
        #puts "debug: $LockRefDly\_$LockFBDly\_$LockCnt\_$LockSatHigh\_$UnlockCnt"
####        puts "DADDR_27: FFFF\t-Power register leaving all interpolators on - "
####        puts "DADDR_18: [xapp888_bin2hex 000000$LockCnt]\t-Lock Register 1: for M set to $div -"
####        puts "DADDR_19: [xapp888_bin2hex 0$LockFBDly$UnlockCnt]\t-Lock Register 2: for M set to $div"
####        puts "DADDR_1A: [xapp888_bin2hex 0$LockRefDly$LockSatHigh]\t-Lock Register 3: for M set to $div"

        return "27FFFF  18[xapp888_bin2hex 000000$LockCnt]  19[xapp888_bin2hex 0$LockFBDly$UnlockCnt] 1A[xapp888_bin2hex 0$LockRefDly$LockSatHigh]  "
}

proc xapp888_bin2hex {bits} {
    set abits ""
    for {set i 0} {$i <= [expr 15 - [string length $bits]] } {incr i} {
        append abits 0}
    append abits "$bits"
    set binValue [binary format B16 $abits]
    binary scan $binValue H4 hex
    return $hex
    }

proc xapp888_hex2bin {hex} {
    for {set i 0} { $i <= [string length $hex]} { incr i 1} {
        append convert2bin [string map -nocase {
            0 0000 1 0001 2 0010 3 0011 4 0100 5 0101 6 0110 7 0111
            8 1000 9 1001 a 1010 b 1011 c 1100 d 1101 e 1110 f 1111
            } [string index $hex $i ] ]
        }
    return $convert2bin
}

proc xapp888_dec2hex {value} {
   # Creates a 16 bit hex number from a signed decimal number
   # Replace all non-decimal characters
   regsub -all {[^0-9\.\-]} $value {} newtemp
   set value [string trim $newtemp]
   if {$value < 65535 && $value >= 0} {
      set tempvalue [format "%#010X" [expr $value]]
      return [string range $tempvalue 6 9]
   } elseif {$value < 0} {
      puts "Unsigned value"
      return "0000"
   } else {
      puts "Violates 16 bit range"
      return "FFFF"
   }
}
proc xapp888_drp_settings {m d phase bw} {
    if {$phase < 0} {set phase [expr 360 + $phase]}
    set data_m [xapp888_drp_calc_m $m $phase]
    set data_d [xapp888_drp_calc_d $d]
    set data_cpres [xapp888_cpres $m $bw]
    set data_locking [xapp888_locking $m]
    return "$data_m $data_d $data_cpres $data_locking"
}
proc xapp888_dec2bin {dec bits} {
    return [binary scan [binary format I $dec] B32 var;string range $var end-[expr $bits-1] end]
}
proc xapp888_help {} {
    puts "\n\n   -------------------------------------------------------------------------------------\
    \n   NOTES:\n   The following TCL commands are being added to give example calculations\
    \n   for drp programming values for MMCME4 (Ultrascale-Plus).
    \n   This script can be altered to adjust for those differences but exact settings should be reviewed.\
    \n\n   Also please note that this is a subset of the full programming options.\
    \n   Fine phase shifting and dynamic phase shifting is not directly supported by\
    \n   these scripts.\
    \n\n    xapp888_drp_settings <CLKFBOUT_MULT>  <DIVCLK_DIVIDE> <PHASE> <BANDWIDTH>\
    \n        - BANDWIDTH can be set to: LOW, HIGH or OPTIMIZED (case insensitive).
    \n        - Displays & Returns the ordered pairs of DRP addresses & Data
    \n      xapp888_drp_clkout <DIVIDE>  <Duty Cycle e.g. 0.5> <Phase e.g.11.25> <CLKOUT0 to CLKOUT6> \
    \n        - Displays & Returns per output the ordered pairs of DRP addresses & Data
    \n      xapp888_help <>
    \n\n   For Example:\
    \n\t   xapp888_drp_settings <m> <d> <phase> <bw>;\
    \n\t   xapp888_drp_clkout <div> <dc> <phase> clkout0;\
    \n\t   xapp888_drp_clkout <div> <dc> <phase> clkout1;\
    \n\t   xapp888_drp_clkout <div> <dc> <phase> clkout2;\
    \n\t   xapp888_drp_clkout <div> <dc> <phase> clkout3;\
    \n\t   xapp888_drp_clkout <div> <dc> <phase> clkout4;\
    \n\t   xapp888_drp_clkout <div> <dc> <phase> clkout5;\
    \n\t   xapp888_drp_clkout <div> <dc> <phase> clkout6;\
    \n\n   To show how to use the xapp888_merg_drp command the following is an arbitrary example"
    puts {          set drp "[xapp888_drp_settings 2.125 2 0 high]"}
    puts {          set drp "$drp [xapp888_drp_clkout 3.75 0.5 90 clkout0]"}
    puts {          for {set i 1} {$i <= 6} {incr i} {set drp "$drp [xapp888_drp_clkout 7 0.5 90 clkout$i]"} }
    puts {          xapp888_merge_drp $drp}
    puts "   -------------------------------------------------------------------------------------"
}

####copy here all the generated Tcl command
 puts "[ xapp888_drp_settings 60 6 0 HIGH      ]"
 puts "[ xapp888_drp_clkout 12 0.5 0 CLKOUT0     ]"
 puts "[ xapp888_drp_settings 63 6 0 HIGH      ]"
 puts "[ xapp888_drp_clkout 12 0.5 0 CLKOUT0     ]"
 puts [ xapp888_drp_settings 55 5 0 HIGH      ]
 puts [ xapp888_drp_clkout 12 0.5 0 CLKOUT0     ]
 puts [ xapp888_drp_settings 46 4 0 HIGH      ]
 puts [ xapp888_drp_clkout 12 0.5 0 CLKOUT0     ]
 puts [ xapp888_drp_settings 64 8 0 HIGH      ]
 puts [ xapp888_drp_clkout 8 0.5 0 CLKOUT0      ]
 puts [ xapp888_drp_settings 50 4 0 HIGH      ]
 puts [ xapp888_drp_clkout 12 0.5 0 CLKOUT0     ]
 puts [ xapp888_drp_settings 52 4 0 HIGH      ]
 puts [ xapp888_drp_clkout 12 0.5 0 CLKOUT0     ]
 puts [ xapp888_drp_settings 63 7 0 HIGH      ]
 puts [ xapp888_drp_clkout 8 0.5 0 CLKOUT0      ]
 puts [ xapp888_drp_settings 63 6 0 HIGH      ]
 puts [ xapp888_drp_clkout 9 0.5 0 CLKOUT0      ]
 puts [ xapp888_drp_settings 58 6 0 HIGH      ]
 puts [ xapp888_drp_clkout 8 0.5 0 CLKOUT0      ]
 puts [ xapp888_drp_settings 60 6 0 HIGH      ]
 puts [ xapp888_drp_clkout 8 0.5 0 CLKOUT0      ]
 puts [ xapp888_drp_settings 62 6 0 HIGH      ]
 puts [ xapp888_drp_clkout 8 0.5 0 CLKOUT0      ]
 puts [ xapp888_drp_settings 64 6 0 HIGH      ]
 puts [ xapp888_drp_clkout 8 0.5 0 CLKOUT0      ]
 puts [ xapp888_drp_settings 55 5 0 HIGH      ]
 puts [ xapp888_drp_clkout 8 0.5 0 CLKOUT0      ]
 puts [ xapp888_drp_settings 51 4 0 HIGH      ]
 puts [ xapp888_drp_clkout 9 0.5 0 CLKOUT0      ]
 puts [ xapp888_drp_settings 35 3 0 HIGH      ]
 puts [ xapp888_drp_clkout 8 0.5 0 CLKOUT0      ]
 puts [ xapp888_drp_settings 63 6 0 HIGH      ]
 puts [ xapp888_drp_clkout 7 0.5 0 CLKOUT0      ]
 puts [ xapp888_drp_settings 37 3 0 HIGH      ]
 puts [ xapp888_drp_clkout 8 0.5 0 CLKOUT0      ]
 puts [ xapp888_drp_settings 57 6 0 HIGH      ]
 puts [ xapp888_drp_clkout 6 0.5 0 CLKOUT0      ]
 puts [ xapp888_drp_settings 52 4 0 HIGH      ]
 puts [ xapp888_drp_clkout 8 0.5 0 CLKOUT0      ]
 puts [ xapp888_drp_settings 60 6 0 HIGH      ]
 puts [ xapp888_drp_clkout 6 0.5 0 CLKOUT0      ]
 puts [ xapp888_drp_settings 41 4 0 HIGH      ]
 puts [ xapp888_drp_clkout 6 0.5 0 CLKOUT0      ]
 puts [ xapp888_drp_settings 63 6 0 HIGH      ]
 puts [ xapp888_drp_clkout 6 0.5 0 CLKOUT0      ]
 puts [ xapp888_drp_settings 43 4 0 HIGH      ]
 puts [ xapp888_drp_clkout 6 0.5 0 CLKOUT0      ]
 puts [ xapp888_drp_settings 55 5 0 HIGH      ]
 puts [ xapp888_drp_clkout 6 0.5 0 CLKOUT0      ]
 puts [ xapp888_drp_settings 60 8 0 HIGH      ]
 puts [ xapp888_drp_clkout 4 0.5 0 CLKOUT0      ]
 puts [ xapp888_drp_settings 46 4 0 HIGH      ]
 puts [ xapp888_drp_clkout 6 0.5 0 CLKOUT0      ]
 puts [ xapp888_drp_settings 47 4 0 HIGH      ]
 puts [ xapp888_drp_clkout 6 0.5 0 CLKOUT0      ]
 puts [ xapp888_drp_settings 64 8 0 HIGH      ]
 puts [ xapp888_drp_clkout 4 0.5 0 CLKOUT0      ]
 puts [ xapp888_drp_settings 49 4 0 HIGH      ]
 puts [ xapp888_drp_clkout 6 0.5 0 CLKOUT0      ]
 puts [ xapp888_drp_settings 50 4 0 HIGH      ]
 puts [ xapp888_drp_clkout 6 0.5 0 CLKOUT0      ]
 puts [ xapp888_drp_settings 51 4 0 HIGH      ]
 puts [ xapp888_drp_clkout 6 0.5 0 CLKOUT0      ]
 puts [ xapp888_drp_settings 52 4 0 HIGH      ]
 puts [ xapp888_drp_clkout 6 0.5 0 CLKOUT0      ]
 puts [ xapp888_drp_settings 53 4 0 HIGH      ]
 puts [ xapp888_drp_clkout 6 0.5 0 CLKOUT0      ]
 puts [ xapp888_drp_settings 63 7 0 HIGH      ]
 puts [ xapp888_drp_clkout 4 0.5 0 CLKOUT0      ]
 puts [ xapp888_drp_settings 55 6 0 HIGH      ]
 puts [ xapp888_drp_clkout 4 0.5 0 CLKOUT0      ]
 puts [ xapp888_drp_settings 63 9 0 HIGH      ]
 puts [ xapp888_drp_clkout 3 0.5 0 CLKOUT0      ]
 puts [ xapp888_drp_settings 57 6 0 HIGH      ]
 puts [ xapp888_drp_clkout 4 0.5 0 CLKOUT0      ]
 puts [ xapp888_drp_settings 58 6 0 HIGH      ]
 puts [ xapp888_drp_clkout 4 0.5 0 CLKOUT0      ]
 puts [ xapp888_drp_settings 59 6 0 HIGH      ]
 puts [ xapp888_drp_clkout 4 0.5 0 CLKOUT0      ]
 puts [ xapp888_drp_settings 60 6 0 HIGH      ]
 puts [ xapp888_drp_clkout 4 0.5 0 CLKOUT0      ]
 puts [ xapp888_drp_settings 61 6 0 HIGH      ]
 puts [ xapp888_drp_clkout 4 0.5 0 CLKOUT0      ]
 puts [ xapp888_drp_settings 62 6 0 HIGH      ]
 puts [ xapp888_drp_clkout 4 0.5 0 CLKOUT0      ]
 puts [ xapp888_drp_settings 63 6 0 HIGH      ]
 puts [ xapp888_drp_clkout 4 0.5 0 CLKOUT0      ]
 puts [ xapp888_drp_settings 64 6 0 HIGH      ]
 puts [ xapp888_drp_clkout 4 0.5 0 CLKOUT0      ]
 puts [ xapp888_drp_settings 64 6 0 HIGH      ]
 puts [ xapp888_drp_clkout 4 0.5 0 CLKOUT0      ]
 puts [ xapp888_drp_settings 55 5 0 HIGH      ]
 puts [ xapp888_drp_clkout 4 0.5 0 CLKOUT0      ]
 puts [ xapp888_drp_settings 55 5 0 HIGH      ]
 puts [ xapp888_drp_clkout 4 0.5 0 CLKOUT0      ]
 puts [ xapp888_drp_settings 51 6 0 HIGH      ]
 puts [ xapp888_drp_clkout 3 0.5 0 CLKOUT0      ]
 puts [ xapp888_drp_settings 46 4 0 HIGH      ]
 puts [ xapp888_drp_clkout 4 0.5 0 CLKOUT0      ]
 puts [ xapp888_drp_settings 35 3 0 HIGH      ]
 puts [ xapp888_drp_clkout 4 0.5 0 CLKOUT0      ]
 puts [ xapp888_drp_settings 35 3 0 HIGH      ]
 puts [ xapp888_drp_clkout 4 0.5 0 CLKOUT0      ]
 puts [ xapp888_drp_settings 63 7 0 HIGH      ]
 puts [ xapp888_drp_clkout 3 0.5 0 CLKOUT0      ]
 puts [ xapp888_drp_settings 63 7 0 HIGH      ]
 puts [ xapp888_drp_clkout 3 0.5 0 CLKOUT0      ]
 puts [ xapp888_drp_settings 37 3 0 HIGH      ]
 puts [ xapp888_drp_clkout 4 0.5 0 CLKOUT0      ]
 puts [ xapp888_drp_settings 50 4 0 HIGH      ]
 puts [ xapp888_drp_clkout 4 0.5 0 CLKOUT0      ]
 puts [ xapp888_drp_settings 57 6 0 HIGH      ]
 puts [ xapp888_drp_clkout 3 0.5 0 CLKOUT0      ]
 puts [ xapp888_drp_settings 57 6 0 HIGH      ]
 puts [ xapp888_drp_clkout 3 0.5 0 CLKOUT0      ]
 puts [ xapp888_drp_settings 52 4 0 HIGH      ]
 puts [ xapp888_drp_clkout 4 0.5 0 CLKOUT0      ]
 puts [ xapp888_drp_settings 52 4 0 HIGH      ]
 puts [ xapp888_drp_clkout 4 0.5 0 CLKOUT0      ]
 puts [ xapp888_drp_settings 60 6 0 HIGH      ]
 puts [ xapp888_drp_clkout 3 0.5 0 CLKOUT0      ]
 puts [ xapp888_drp_settings 54 8 0 HIGH      ]
 puts [ xapp888_drp_clkout 2 0.5 0 CLKOUT0      ]
 puts [ xapp888_drp_settings 41 4 0 HIGH      ]
 puts [ xapp888_drp_clkout 3 0.5 0 CLKOUT0      ]
 puts [ xapp888_drp_settings 41 4 0 HIGH      ]
 puts [ xapp888_drp_clkout 3 0.5 0 CLKOUT0      ]
 puts [ xapp888_drp_settings 63 6 0 HIGH      ]
 puts [ xapp888_drp_clkout 3 0.5 0 CLKOUT0      ]
 puts [ xapp888_drp_settings 63 6 0 HIGH      ]
 puts [ xapp888_drp_clkout 3 0.5 0 CLKOUT0      ]
 puts [ xapp888_drp_settings 43 4 0 HIGH      ]
 puts [ xapp888_drp_clkout 3 0.5 0 CLKOUT0      ]
 puts [ xapp888_drp_settings 58 8 0 HIGH      ]
 puts [ xapp888_drp_clkout 2 0.5 0 CLKOUT0      ]
 puts [ xapp888_drp_settings 55 5 0 HIGH      ]
 puts [ xapp888_drp_clkout 3 0.5 0 CLKOUT0      ]
 puts [ xapp888_drp_settings 55 5 0 HIGH      ]
 puts [ xapp888_drp_clkout 3 0.5 0 CLKOUT0      ]
 puts [ xapp888_drp_settings 60 8 0 HIGH      ]
 puts [ xapp888_drp_clkout 2 0.5 0 CLKOUT0      ]
 puts [ xapp888_drp_settings 60 8 0 HIGH      ]
 puts [ xapp888_drp_clkout 2 0.5 0 CLKOUT0      ]
 puts [ xapp888_drp_settings 46 4 0 HIGH      ]
 puts [ xapp888_drp_clkout 3 0.5 0 CLKOUT0      ]
 puts [ xapp888_drp_settings 62 8 0 HIGH      ]
 puts [ xapp888_drp_clkout 2 0.5 0 CLKOUT0      ]
 puts [ xapp888_drp_settings 47 4 0 HIGH      ]
 puts [ xapp888_drp_clkout 3 0.5 0 CLKOUT0      ]
 puts [ xapp888_drp_settings 47 4 0 HIGH      ]
 puts [ xapp888_drp_clkout 3 0.5 0 CLKOUT0      ]
 puts [ xapp888_drp_settings 64 8 0 HIGH      ]
 puts [ xapp888_drp_clkout 2 0.5 0 CLKOUT0      ]
 puts [ xapp888_drp_settings 64 8 0 HIGH      ]
 puts [ xapp888_drp_clkout 2 0.5 0 CLKOUT0      ]
 puts [ xapp888_drp_settings 49 4 0 HIGH      ]
 puts [ xapp888_drp_clkout 3 0.5 0 CLKOUT0      ]
 puts [ xapp888_drp_settings 33 4 0 HIGH      ]
 puts [ xapp888_drp_clkout 2 0.5 0 CLKOUT0      ]
 puts [ xapp888_drp_settings 50 4 0 HIGH      ]
 puts [ xapp888_drp_clkout 3 0.5 0 CLKOUT0      ]
 puts [ xapp888_drp_settings 50 4 0 HIGH      ]
 puts [ xapp888_drp_clkout 3 0.5 0 CLKOUT0      ]
 puts [ xapp888_drp_settings 51 4 0 HIGH      ]
 puts [ xapp888_drp_clkout 3 0.5 0 CLKOUT0      ]
 puts [ xapp888_drp_settings 51 4 0 HIGH      ]
 puts [ xapp888_drp_clkout 3 0.5 0 CLKOUT0      ]
 puts [ xapp888_drp_settings 52 4 0 HIGH      ]
 puts [ xapp888_drp_clkout 3 0.5 0 CLKOUT0      ]
 puts [ xapp888_drp_settings 35 4 0 HIGH      ]
 puts [ xapp888_drp_clkout 2 0.5 0 CLKOUT0      ]
 puts [ xapp888_drp_settings 53 4 0 HIGH      ]
 puts [ xapp888_drp_clkout 3 0.5 0 CLKOUT0      ]
 puts [ xapp888_drp_settings 53 4 0 HIGH      ]
 puts [ xapp888_drp_clkout 3 0.5 0 CLKOUT0      ]
 puts [ xapp888_drp_settings 63 7 0 HIGH      ]
 puts [ xapp888_drp_clkout 2 0.5 0 CLKOUT0      ]
 puts [ xapp888_drp_settings 63 7 0 HIGH      ]
 puts [ xapp888_drp_clkout 2 0.5 0 CLKOUT0      ]
 puts [ xapp888_drp_settings 55 6 0 HIGH      ]
 puts [ xapp888_drp_clkout 2 0.5 0 CLKOUT0      ]
 puts [ xapp888_drp_settings 37 4 0 HIGH      ]
 puts [ xapp888_drp_clkout 2 0.5 0 CLKOUT0      ]
 puts [ xapp888_drp_settings 56 6 0 HIGH      ]
 puts [ xapp888_drp_clkout 2 0.5 0 CLKOUT0      ]
 puts [ xapp888_drp_settings 56 6 0 HIGH      ]
 puts [ xapp888_drp_clkout 2 0.5 0 CLKOUT0      ]
 puts [ xapp888_drp_settings 57 6 0 HIGH      ]
 puts [ xapp888_drp_clkout 2 0.5 0 CLKOUT0      ]
 puts [ xapp888_drp_settings 57 6 0 HIGH      ]
 puts [ xapp888_drp_clkout 2 0.5 0 CLKOUT0      ]
 puts [ xapp888_drp_settings 58 6 0 HIGH      ]
 puts [ xapp888_drp_clkout 2 0.5 0 CLKOUT0      ]
 puts [ xapp888_drp_settings 39 4 0 HIGH      ]
 puts [ xapp888_drp_clkout 2 0.5 0 CLKOUT0      ]
 puts [ xapp888_drp_settings 59 6 0 HIGH      ]
 puts [ xapp888_drp_clkout 2 0.5 0 CLKOUT0      ]
 puts [ xapp888_drp_settings 59 6 0 HIGH      ]
 puts [ xapp888_drp_clkout 2 0.5 0 CLKOUT0      ]
 puts [ xapp888_drp_settings 60 6 0 HIGH      ]
 puts [ xapp888_drp_clkout 2 0.5 0 CLKOUT0      ]
 puts [ xapp888_drp_settings 60 6 0 HIGH      ]
 puts [ xapp888_drp_clkout 2 0.5 0 CLKOUT0      ]
 puts [ xapp888_drp_settings 61 6 0 HIGH      ]
 puts [ xapp888_drp_clkout 2 0.5 0 CLKOUT0      ]
 puts [ xapp888_drp_settings 41 4 0 HIGH      ]
 puts [ xapp888_drp_clkout 2 0.5 0 CLKOUT0      ]
 puts [ xapp888_drp_settings 62 6 0 HIGH      ]
 puts [ xapp888_drp_clkout 2 0.5 0 CLKOUT0      ]
 puts [ xapp888_drp_settings 62 6 0 HIGH      ]
 puts [ xapp888_drp_clkout 2 0.5 0 CLKOUT0      ]
 puts [ xapp888_drp_settings 63 6 0 HIGH      ]
 puts [ xapp888_drp_clkout 2 0.5 0 CLKOUT0      ]
 puts [ xapp888_drp_settings 63 6 0 HIGH      ]
 puts [ xapp888_drp_clkout 2 0.5 0 CLKOUT0      ]
 puts [ xapp888_drp_settings 64 6 0 HIGH      ]
 puts [ xapp888_drp_clkout 2 0.5 0 CLKOUT0      ]
 puts [ xapp888_drp_settings 43 4 0 HIGH      ]
 puts [ xapp888_drp_clkout 2 0.5 0 CLKOUT0      ]
 puts [ xapp888_drp_settings 43 4 0 HIGH      ]
 puts [ xapp888_drp_clkout 2 0.5 0 CLKOUT0      ]
 puts [ xapp888_drp_settings 43 4 0 HIGH      ]
 puts [ xapp888_drp_clkout 2 0.5 0 CLKOUT0      ]
 puts [ xapp888_drp_settings 55 5 0 HIGH      ]
 puts [ xapp888_drp_clkout 2 0.5 0 CLKOUT0      ]
 puts [ xapp888_drp_settings 55 5 0 HIGH      ]
 puts [ xapp888_drp_clkout 2 0.5 0 CLKOUT0      ]
 puts [ xapp888_drp_settings 55 5 0 HIGH      ]
 puts [ xapp888_drp_clkout 2 0.5 0 CLKOUT0      ]
 puts [ xapp888_drp_settings 45 4 0 HIGH      ]
 puts [ xapp888_drp_clkout 2 0.5 0 CLKOUT0      ]
 puts [ xapp888_drp_settings 34 3 0 HIGH      ]
 puts [ xapp888_drp_clkout 2 0.5 0 CLKOUT0      ]
 puts [ xapp888_drp_settings 34 3 0 HIGH      ]
 puts [ xapp888_drp_clkout 2 0.5 0 CLKOUT0      ]
 puts [ xapp888_drp_settings 46 4 0 HIGH      ]
 puts [ xapp888_drp_clkout 2 0.5 0 CLKOUT0      ]
 puts [ xapp888_drp_settings 46 4 0 HIGH      ]
 puts [ xapp888_drp_clkout 2 0.5 0 CLKOUT0      ]
 puts [ xapp888_drp_settings 35 3 0 HIGH      ]
 puts [ xapp888_drp_clkout 2 0.5 0 CLKOUT0      ]
 puts [ xapp888_drp_settings 47 4 0 HIGH      ]
 puts [ xapp888_drp_clkout 2 0.5 0 CLKOUT0      ]
 puts [ xapp888_drp_settings 47 4 0 HIGH      ]
 puts [ xapp888_drp_clkout 2 0.5 0 CLKOUT0      ]
 puts [ xapp888_drp_settings 47 4 0 HIGH      ]
 puts [ xapp888_drp_clkout 2 0.5 0 CLKOUT0      ]
 puts [ xapp888_drp_settings 60 5 0 HIGH      ]
 puts [ xapp888_drp_clkout 2 0.5 0 CLKOUT0      ]
 puts [ xapp888_drp_settings 60 5 0 HIGH      ]
 puts [ xapp888_drp_clkout 2 0.5 0 CLKOUT0      ]
 puts [ xapp888_drp_settings 60 5 0 HIGH      ]
 puts [ xapp888_drp_clkout 2 0.5 0 CLKOUT0      ]
 puts [ xapp888_drp_settings 49 4 0 HIGH      ]
 puts [ xapp888_drp_clkout 2 0.5 0 CLKOUT0      ]
 puts [ xapp888_drp_settings 37 3 0 HIGH      ]
 puts [ xapp888_drp_clkout 2 0.5 0 CLKOUT0      ]
 puts [ xapp888_drp_settings 37 3 0 HIGH      ]
 puts [ xapp888_drp_clkout 2 0.5 0 CLKOUT0      ]
 puts [ xapp888_drp_settings 50 4 0 HIGH      ]
 puts [ xapp888_drp_clkout 2 0.5 0 CLKOUT0      ]
 puts [ xapp888_drp_settings 50 4 0 HIGH      ]
 puts [ xapp888_drp_clkout 2 0.5 0 CLKOUT0      ]
 puts [ xapp888_drp_settings 38 3 0 HIGH      ]
 puts [ xapp888_drp_clkout 2 0.5 0 CLKOUT0      ]
 puts [ xapp888_drp_settings 51 4 0 HIGH      ]
 puts [ xapp888_drp_clkout 2 0.5 0 CLKOUT0      ]
 puts [ xapp888_drp_settings 51 4 0 HIGH      ]
 puts [ xapp888_drp_clkout 2 0.5 0 CLKOUT0      ]
 puts [ xapp888_drp_settings 51 4 0 HIGH      ]
 puts [ xapp888_drp_clkout 2 0.5 0 CLKOUT0      ]
 puts [ xapp888_drp_settings 52 4 0 HIGH      ]
 puts [ xapp888_drp_clkout 2 0.5 0 CLKOUT0      ]
 puts [ xapp888_drp_settings 52 4 0 HIGH      ]
 puts [ xapp888_drp_clkout 2 0.5 0 CLKOUT0      ]
 puts [ xapp888_drp_settings 52 4 0 HIGH      ]
 puts [ xapp888_drp_clkout 2 0.5 0 CLKOUT0      ]
 puts [ xapp888_drp_settings 53 4 0 HIGH      ]
 puts [ xapp888_drp_clkout 2 0.5 0 CLKOUT0      ]
 puts [ xapp888_drp_settings 40 3 0 HIGH      ]
 puts [ xapp888_drp_clkout 2 0.5 0 CLKOUT0      ]
####end of hte copied generated Tcl Command.



#xapp888_help



