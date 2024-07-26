/obj/machinery/reagent_refinery/hub
	name = "Industrial Chemical Hub"
	desc = "A platform for loading and unloading cargo tug tankers."
	icon = 'modular_outpost/icons/obj/machines/refinery_machines.dmi'
	icon_state = "hub"
	density = FALSE
	anchored = TRUE
	use_power = USE_POWER_IDLE
	idle_power_usage = 0
	active_power_usage = 10
	circuit = /obj/item/weapon/circuitboard/industrial_reagent_hub
	default_max_vol = 0

/obj/machinery/reagent_refinery/hub/Initialize()
	. = ..()
	// TODO - Remove this bit once machines are converted to Initialize
	if(ispath(circuit))
		circuit = new circuit(src)
	default_apply_parts()
	update_icon()

/obj/machinery/reagent_refinery/hub/process()
	if(!anchored)
		return

	power_change()
	if(stat & (NOPOWER|BROKEN))
		return

	if (amount_per_transfer_from_this <= 0)
		return

	var/obj/machinery/reagent_refinery/target = locate(/obj/machinery/reagent_refinery) in get_step(loc,dir)
	if(target && target.dir != reverse_dir[dir])
		var/obj/vehicle/train/trolly_tank/tanker = locate(/obj/vehicle/train/trolly_tank) in loc
		if(tanker && tanker.reagents.total_volume > 0)
			// dump reagents to next refinery machine
			transfer_tank( tanker.reagents, target, dir)

/obj/machinery/reagent_refinery/hub/update_icon()
	cut_overlays()
	var/turf/T = get_step(get_turf(src),dir)
	var/obj/machinery/other = locate(/obj/machinery/reagent_refinery) in T
	if(!other) // snowflake grinders...
		other = locate(/obj/machinery/reagentgrinder/industrial) in T
	var/intake = FALSE
	if(other && other.anchored)
		// weird handling for side connections... Otherwise, anything pointing into use gets connected back!
		if(istype(other,/obj/machinery/reagent_refinery/filter))
			var/obj/machinery/reagent_refinery/filter/filt = other
			var/check_dir = 0
			if(filt.filter_side == 1)
				check_dir = turn(filt.dir, 270)
			else
				check_dir = turn(filt.dir, 90)
			if(check_dir == reverse_dir[dir])
				intake = TRUE
		if(other.dir == reverse_dir[dir])
			intake = TRUE
	// Get main dir pipe
	if(intake)
		var/image/pipe = image(icon, icon_state = "hub_intakes", dir = dir)
		add_overlay(pipe)
	else
		var/image/pipe = image(icon, icon_state = "hub_cons", dir = dir)
		add_overlay(pipe)

/obj/machinery/reagent_refinery/hub/verb/rotate_clockwise()
	set name = "Rotate Hub Clockwise"
	set category = "Object"
	set src in view(1)

	if (usr.stat || usr.restrained() || anchored)
		return

	src.set_dir(turn(src.dir, 270))
	update_icon()

/obj/machinery/reagent_refinery/hub/verb/rotate_counterclockwise()
	set name = "Rotate Hub Counterclockwise"
	set category = "Object"
	set src in view(1)

	if (usr.stat || usr.restrained() || anchored)
		return

	src.set_dir(turn(src.dir, 90))
	update_icon()

/obj/machinery/reagent_refinery/hub/examine(mob/user, infix, suffix)
	. = ..()
	. += "It is pumping chemicals at a rate of [amount_per_transfer_from_this]u."

// pointless because no density
/obj/machinery/reagent_refinery/hub/can_climb(var/mob/living/user, post_climb_check=0)
	return FALSE
