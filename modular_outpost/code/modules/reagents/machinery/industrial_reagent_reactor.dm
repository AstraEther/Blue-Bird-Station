/obj/machinery/reagent_refinery/reactor
	name = "Industrial Chemical Reactor"
	desc = "A reinforced chamber for high temperature distillation. Can be connected to a pipe network to change the interior atmosphere. It outputs chemicals on a timer, to allow for distillation."
	icon = 'modular_outpost/icons/obj/machines/refinery_machines.dmi'
	icon_state = "reactor"
	density = TRUE
	anchored = TRUE
	use_power = USE_POWER_IDLE
	idle_power_usage = 0
	active_power_usage = 500
	circuit = /obj/item/weapon/circuitboard/industrial_reagent_reactor
	default_max_vol = 2500
	var/obj/machinery/portable_atmospherics/canister/internal_tank
	var/toggle_mode = 0 // 0 = intake and boil, 1 = output
	var/next_mode_toggle = 0

	var/dis_time = 30
	var/drain_time = 10

/obj/machinery/reagent_refinery/reactor/Initialize()
	. = ..()
	// TODO - Remove this bit once machines are converted to Initialize
	if(ispath(circuit))
		circuit = new circuit(src)
	default_apply_parts()
	update_icon()
	internal_tank = new /obj/machinery/portable_atmospherics/canister/empty()
	update_gas_network()
	toggle_mode = 0 // 0 = intake and boil, 1 = output
	next_mode_toggle = world.time + dis_time SECONDS

/obj/machinery/reagent_refinery/reactor/Destroy()
	. = ..()
	qdel_null(internal_tank)

/obj/machinery/reagent_refinery/reactor/process()
	if(!anchored)
		return

	power_change()
	if(stat & (NOPOWER|BROKEN))
		return

	if(next_mode_toggle < world.time)
		if(toggle_mode == 0) // 0 = intake and boil, 1 = output
			if(reagents && reagents.total_volume > 0 && amount_per_transfer_from_this > 0)
				toggle_mode = 1 // Only drain if anything in it!
			next_mode_toggle = world.time + drain_time SECONDS
		else
			toggle_mode = 0
			next_mode_toggle = world.time + dis_time SECONDS

	if(amount_per_transfer_from_this <= 0 || reagents.total_volume <= 0)
		return

	if(toggle_mode == 0)
		// perform reactions
		reagents.handle_distilling()
	else
		// dump reagents to next refinery machine
		var/obj/machinery/reagent_refinery/target = locate(/obj/machinery/reagent_refinery) in get_step(loc,dir)
		if(target)
			transfer_tank( reagents, target, dir)

/obj/machinery/reagent_refinery/reactor/update_icon()
	cut_overlays()
	// Get main dir pipe
	var/image/pipe = image(icon, icon_state = "reactor_cons", dir = dir)
	add_overlay(pipe)
	if(anchored)
		for(var/direction in cardinal)
			var/turf/T = get_step(get_turf(src),direction)
			var/obj/machinery/other = locate(/obj/machinery/reagent_refinery) in T
			if(!other) // snowflake grinders...
				other = locate(/obj/machinery/reagentgrinder/industrial) in T
			if(other && other.anchored)
				// Waste processors do not connect to anything as outgoing
				if(istype(other,/obj/machinery/reagent_refinery/waste_processor))
					continue
				// weird handling for side connections... Otherwise, anything pointing into use gets connected back!
				if(istype(other,/obj/machinery/reagent_refinery/filter))
					var/obj/machinery/reagent_refinery/filter/filt = other
					var/check_dir = 0
					if(filt.filter_side == 1)
						check_dir = turn(filt.dir, 270)
					else
						check_dir = turn(filt.dir, 90)
					if(check_dir == reverse_dir[direction] && dir != direction)
						var/image/intake = image(icon, icon_state = "reactor_intakes", dir = direction)
						add_overlay(intake)
						continue
				if(other.dir == reverse_dir[direction] && dir != direction)
					var/image/intake = image(icon, icon_state = "reactor_intakes", dir = direction)
					add_overlay(intake)

/obj/machinery/reagent_refinery/reactor/verb/rotate_clockwise()
	set name = "Rotate Reactor Clockwise"
	set category = "Object"
	set src in view(1)

	if (usr.stat || usr.restrained() || anchored)
		return

	src.set_dir(turn(src.dir, 270))
	update_icon()

/obj/machinery/reagent_refinery/reactor/verb/rotate_counterclockwise()
	set name = "Rotate Reactor Counterclockwise"
	set category = "Object"
	set src in view(1)

	if (usr.stat || usr.restrained() || anchored)
		return

	src.set_dir(turn(src.dir, 90))
	update_icon()

/obj/machinery/reagent_refinery/reactor/examine(mob/user, infix, suffix)
	. = ..()
	. += "The meter shows [reagents.total_volume]u / [reagents.maximum_volume]u. It is pumping chemicals at a rate of [amount_per_transfer_from_this]u."
	var/datum/gas_mixture/GM = internal_tank.return_air()
	. += "The internal temperature is [GM.temperature]k at [GM.return_pressure()]kpa. It is currently in a [toggle_mode ? "pumping cycle" : "distilling cycle"]."

/obj/machinery/reagent_refinery/reactor/attackby(var/obj/item/O as obj, var/mob/user as mob)
	. = ..()
	if(O.has_tool_quality(TOOL_WRENCH))
		update_gas_network() // Handles anchoring
		toggle_mode = 0
		next_mode_toggle = world.time + dis_time SECONDS

/obj/machinery/reagent_refinery/reactor/proc/update_gas_network()
	if(!internal_tank)
		return
	// think of this as we JUST anchored/deanchored
	var/obj/machinery/atmospherics/portables_connector/pad = locate() in get_turf(src)
	if(pad && !pad.connected_device)
		if(anchored)
			// Perform the connection, forcibly... we're ignoring adjacency checks with this
			internal_tank.connected_port = pad
			pad.connected_device = src
			pad.on = 1 //Activate port updates
			// Actually enforce the air sharing
			var/datum/pipe_network/network = pad.return_network(src)
			if(network && !network.gases.Find(internal_tank.air_contents))
				network.gases += internal_tank.air_contents
				network.update = 1
			// Sfx
			playsound(src, 'sound/mecha/gasconnected.ogg', 50, 1)
		else
			internal_tank.disconnect()
			playsound(src, 'sound/mecha/gasdisconnected.ogg', 50, 1)
	else if(internal_tank.connected_port)
		internal_tank.disconnect() // How did we get here? qdelled pad?
		playsound(src, 'sound/mecha/gasdisconnected.ogg', 50, 1)

/obj/machinery/reagent_refinery/reactor/return_air()
	if(internal_tank)
		return internal_tank.return_air()
	. = ..()
