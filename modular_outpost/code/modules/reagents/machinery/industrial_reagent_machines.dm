/obj/machinery/reagent_refinery
	var/default_max_vol = 120
	var/amount_per_transfer_from_this = 120
	var/possible_transfer_amounts = list(0,1,2,5,10,15,20,25,30,40,60,80,100,120)

/obj/machinery/reagent_refinery/Initialize(mapload)
	. = ..()
	// reagent control
	if(default_max_vol > 0)
		reagents = new/datum/reagents(default_max_vol)
		reagents.my_atom = src
	// Update neighbours and self for state
	update_neighbours()
	update_icon()

/obj/machinery/reagent_refinery/Destroy()
	if(reagents.reagent_list.len && reagents.total_volume > 30)
		visible_message(span_danger("\The [src] splashes everywhere as it is disassembled!"))
		reagents.splash_area(get_turf(src),2)
	. = ..()

/obj/machinery/reagent_refinery/Moved(atom/old_loc, direction, forced)
	. = ..()
	update_icon()

/obj/machinery/reagent_refinery/attackby(var/obj/item/O as obj, var/mob/user as mob)
	if(O.has_tool_quality(TOOL_WRENCH))
		for(var/obj/machinery/reagent_refinery/R in loc.contents)
			if(R != src)
				to_chat(usr,span_warning("You cannot anchor \the [src] until \The [R] is moved out of the way!"))
				return
		playsound(src, O.usesound, 75, 1)
		anchored = !anchored
		user.visible_message("[user.name] [anchored ? "secures" : "unsecures"] the bolts holding [src.name] to the floor.", \
					"You [anchored ? "secure" : "unsecure"] the bolts holding [src] to the floor.", \
					"You hear a ratchet.")
		update_neighbours()
		update_icon()
		return
	if(reagents && (istype(O,/obj/item/reagent_containers/glass) || \
		istype(O,/obj/item/reagent_containers/food/drinks/glass2) || \
		istype(O,/obj/item/reagent_containers/food/drinks/shaker)))
		// Transfer FROM internal beaker to this.
		if (reagents.total_volume <= 0)
			to_chat(usr,"\The [src] is empty. There is nothing to drain into \the [O].")
			return
		// Fill up the whole volume if we can, DUMP IT OUT
		var/obj/item/reagent_containers/C = O
		reagents.trans_to_obj(C, reagents.total_volume)
		playsound(src, 'sound/machines/reagent_dispense.ogg', 25, 1)
		to_chat(usr,"You drain \the [src] into \the [C].")
		return
	if(default_deconstruction_screwdriver(user, O))
		return
	if(default_deconstruction_crowbar(user, O))
		return
	. = ..()

/obj/machinery/reagent_refinery/proc/update_neighbours()
	// Update icons and neighbour icons to avoid loss of sanity
	for(var/direction in cardinal)
		var/turf/T = get_step(get_turf(src),direction)
		var/obj/machinery/other = locate(/obj/machinery/reagent_refinery) in T
		if(other && other.anchored)
			other.update_icon()


/obj/machinery/reagent_refinery/verb/set_APTFT() //set amount_per_transfer_from_this
	set name = "Set transfer amount"
	set category = "Object"
	set src in view(1)
	var/N = tgui_input_list(usr, "Amount per transfer from this:","[src]", possible_transfer_amounts)
	if (N)
		amount_per_transfer_from_this = N
	update_icon()

/obj/machinery/reagent_refinery/proc/handle_transfer(var/atom/origin_machine, var/datum/reagents/RT, var/source_forward_dir, var/filter_id = "") // Handle transfers in an override, instead of one monster function that typechecks like transfer_tank() used to be
	// Transfer to target in amounts every process tick!
	if(filter_id == "")
		var/amount = RT.trans_to_obj(src, amount_per_transfer_from_this)
		return amount
	// Split out reagent...
	// Yet another hack, because I refuse to rewrite base code for a module. It's a shame it can't just be forced.
	var/old_flags = flags
	flags |= OPENCONTAINER // trans_id_to expects an opencontainer flag, but this is closed plumbing...
	var/amount = RT.trans_id_to(src, filter_id, amount_per_transfer_from_this)
	flags = old_flags
	// End hacky flag stuff
	return amount

/obj/machinery/reagent_refinery/proc/transfer_tank( var/datum/reagents/RT, var/obj/machinery/reagent_refinery/target, var/source_forward_dir, var/filter_id = "")
	if(RT.total_volume <= 0 || !anchored || !target.anchored)
		return 0
	if(active_power_usage > 0 && !can_use_power_oneoff(active_power_usage))
		return 0
	if(!istype(target,/obj/machinery/reagent_refinery)) // cannot transfer into grinders anyway, so it's fine to do it this way.
		return 0
	var/transfered = target.handle_transfer(src,RT,source_forward_dir,filter_id)
	if(transfered > 0 && active_power_usage > 0)
		use_power_oneoff(active_power_usage)
	return transfered

// Climbing is kinda critical for these
/obj/machinery/reagent_refinery/verb/climb_on()
	set name = "Climb structure"
	set desc = "Climbs onto a structure."
	set category = "Object"
	set src in oview(1)

	do_climb(usr)

/obj/machinery/reagent_refinery/MouseDrop_T(mob/target, mob/user)
	var/mob/living/H = user
	if(istype(H) && can_climb(H) && target == user)
		do_climb(target)
	else
		return ..()

/obj/machinery/reagent_refinery/on_reagent_change(changetype)
	update_icon()
