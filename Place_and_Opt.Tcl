set dispScriptFile [file normalize [info script]]
set ScriptFolder [file dirname $dispScriptFile]

cd $ScriptFolder/.

# Post Place PhysOpt Looping
set NLOOPS 2 
set TNS_PREV 0

 

################################################## Opt_Design #######################################################################

#opt_design -resynth_seq_area
#opt_design -retarget -propconst -sweep                     -control_set_opt -aggressive_remap -merge_equivalent_drivers -bufg_opt -shift_register_opt
opt_design -retarget -propconst -sweep -control_set_opt -aggressive_remap -merge_equivalent_drivers -bufg_opt -shift_register_opt

set_clock_uncertainty 0.000 [get_clocks clk_500M_0]
set_clock_uncertainty 0.000 [get_clocks clk_500M_1]



################################################## Place #######################################################################

place_design -directive ExtraNetDelay_high -timing_summary
write_checkpoint -force post_place.dcp



################################################## Post-Place optimization #######################################################

for {set i 0} {$i < $NLOOPS} {incr i} { 
	if {[get_property SLACK [get_timing_paths ]] >= 0} {break}; #stop if timing is met
	phys_opt_design -directive AggressiveExplore

	phys_opt_design -directive AlternateReplication
	phys_opt_design -directive AggressiveFanoutOpt
	#phys_opt_design ‑fanout_opt ‑placement_opt ‑slr_crossing_opt ‑restruct_opt ‑interconnect_retime ‑lut_opt ‑casc_opt ‑cell_group_opt ‑critical_cell_opt ‑aggressive_hold_fix ‑retime ‑critical_pin_opt ‑sll_reg_hold_fix
	phys_opt_design -directive Explore
}
write_checkpoint -force post_place_opt.dcp


set_clock_uncertainty 0 [get_clocks clk_500M_0]; #reseting the clock over-constraints for the routing.
set_clock_uncertainty 0 [get_clocks clk_500M_1]



################################################## Routing #######################################################################

route_design -directive Explore -tns_cleanup
write_checkpoint -force post_route.dcp



############################################### Post-Route #######################################################################

for {set i 0} {$i < $NLOOPS} {incr i} { 
	if {[get_property SLACK [get_timing_paths ]] >= 0} {break}; #stop if timing is met
	phys_opt_design -directive AggressiveExplore;
	if {[get_property SLACK [get_timing_paths ]] >= 0} {break}; #stop if timing is met
	place_design -post_place_opt -timing_summary;# For each of the top few critical paths with timing violations, placer tries moving critical cells to improve delay. Any placement changes will result in unrouted connections, need a route_design after.
	route_design -directive Explore -tns_cleanup
	if {[get_property SLACK [get_timing_paths ]] >= 0} {break}; #stop if timing is met
	phys_opt_design -directive AggressiveExplore; #phys_opt_design at post-route stage will reroute any nets that might have been unrouted.
}
write_checkpoint -force post_route_opt.dcp


############################################### write Bitstream ##################################################################
write_bitstream -force Alto9p.bit

