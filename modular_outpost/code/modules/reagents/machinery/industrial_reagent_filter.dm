/obj/machinery/reagent_refinery/filter
	name = "Industrial Chemical Filter"
	desc = "Identifies and extracts specific chemicals."
	icon = 'modular_outpost/icons/obj/machines/refinery_machines.dmi'
	icon_state = "filter_l"
	density = TRUE
	anchored = TRUE
	use_power = USE_POWER_IDLE
	idle_power_usage = 5
	active_power_usage = 50
	circuit = /obj/item/weapon/circuitboard/industrial_reagent_pump
	var/filter_side = -1 // L
	var/filter_reagent_id = ""

/obj/machinery/reagent_refinery/filter/alt
	filter_side = 1 // R
	icon_state = "filter_r"

/obj/machinery/reagent_refinery/filter/Initialize()
	. = ..()
	// TODO - Remove this bit once machines are converted to Initialize
	if(ispath(circuit))
		circuit = new circuit(src)
	default_apply_parts()
	update_icon()

/obj/machinery/reagent_refinery/filter/process()
	if(!anchored)
		return

	power_change()
	if(stat & (NOPOWER|BROKEN))
		return

	// extract and filter side products
	if(filter_reagent_id == "")
		return // MUST BE SET
	if(amount_per_transfer_from_this <= 0)
		return
	if(filter_reagent_id != "-1" || filter_reagent_id == "-2") // disabled check, and "all" check
		var/check_dir = 0
		if(filter_side == 1)
			check_dir = turn(src.dir, 270)
		else
			check_dir = turn(src.dir, 90)
		var/obj/machinery/reagent_refinery/filter_target = locate(/obj/machinery/reagent_refinery) in get_step(get_turf(src),check_dir)
		if(filter_target && reagents.total_volume > 0)
			transfer_tank( filter_target, check_dir, filter_reagent_id == "-2" ? "" : filter_reagent_id)
	// dump reagents to next refinery machine if all of the target reagent has been filtered out
	if(filter_reagent_id != "-2") // "all" filter option pushes it all out the side path
		var/obj/machinery/reagent_refinery/target = locate(/obj/machinery/reagent_refinery) in get_step(get_turf(src),dir)
		if(target && reagents.total_volume > 0)
			transfer_tank( target, target.dir)

/obj/machinery/reagent_refinery/filter/update_icon()
	cut_overlays()
	icon_state = "filter_[filter_side == 1 ? "r" : "l"]"

	if(reagents.total_volume > 0)
		var/image/filling = image(icon, loc, "[icon_state]_r",dir = dir)
		filling.color = reagents.get_color()
		add_overlay(filling)

/obj/machinery/reagent_refinery/filter/attack_hand(mob/user)
	set_filter()

/obj/machinery/reagent_refinery/filter/verb/set_filter()
	set name = "Set Filter Chemical"
	set category = "Object"
	set src in view(1)

	if (usr.stat || usr.restrained())
		return

	// Get a list of reagents currently inside!
	var/list/tgui_list = list("None" = "","Bypass" = "-1","All" = "-2")
	for(var/datum/reagent/R in reagents.reagent_list)
		if(R)
			tgui_list[R.name] = R.id
	var/select = tgui_input_list(usr, "Select chemical to filter:", "Chemical Select", tgui_list)

	if (usr.stat || usr.restrained())
		return

	// Select if possible
	if(select && select != "")
		filter_reagent_id = tgui_list[select]

/obj/machinery/reagent_refinery/filter/verb/rotate_clockwise()
	set name = "Rotate Filter Clockwise"
	set category = "Object"
	set src in view(1)

	if (usr.stat || usr.restrained() || anchored)
		return

	src.set_dir(turn(src.dir, 270))
	update_icon()

/obj/machinery/reagent_refinery/filter/verb/rotate_counterclockwise()
	set name = "Rotate Filter Counterclockwise"
	set category = "Object"
	set src in view(1)

	if (usr.stat || usr.restrained() || anchored)
		return

	src.set_dir(turn(src.dir, 90))
	update_icon()

/obj/machinery/reagent_refinery/filter/verb/flip_filter()
	set name = "Flip Filter Direction"
	set category = "Object"
	set src in view(1)

	if (usr.stat || usr.restrained() || anchored)
		return

	filter_side *= -1
	update_icon()

/obj/machinery/reagent_refinery/filter/examine(mob/user, infix, suffix)
	. = ..()
	var/filter = "disabled"
	if(filter_reagent_id == "-1")
		filter = "filtering out nothing"
	else if(filter_reagent_id != "-2")
		filter = "filtering out everything"
	else if(filter_reagent_id != "")
		var/datum/reagent/R = SSchemistry.chemical_reagents[filter_reagent_id]
		filter = R.name
	. += "The meter shows [FLOOR((reagents.total_volume / reagents.maximum_volume) * 100,1)]% full. It is currently [filter]."
