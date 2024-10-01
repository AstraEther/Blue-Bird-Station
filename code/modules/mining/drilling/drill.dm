/obj/machinery/mining
	icon = 'icons/obj/mining_drill.dmi'
	anchored = FALSE
	use_power = USE_POWER_OFF //The drill takes power directly from a cell.
	density = TRUE
	layer = MOB_LAYER+0.1 //So it draws over mobs in the tile north of it.

/obj/machinery/mining/drill
	name = "mining drill head"
	desc = "An enormous drill."
	icon_state = "mining_drill"
	circuit = /obj/item/circuitboard/miningdrill
	var/braces_needed = 2
	var/total_brace_tier = 0
	var/list/obj/machinery/mining/brace/supports = list()
	var/supported = 0
	var/active = 0
	var/list/resource_field = list()
	var/list/gas_field = list() // Outpost 21 edit - gas drilling
	var/obj/item/radio/intercom/faultreporter
	var/drill_range = 5
	var/offset = 2
	var/current_capacity = 0
	var/drill_moles_per_tick = 0 // Outpost 21 edit - gas drilling

	var/list/stored_ore = list(
		"sand" = 0,
		"hematite" = 0,
		"carbon" = 0,
		"raw copper" = 0,
		"raw tin" = 0,
		"void opal" = 0,
		"painite" = 0,
		"quartz" = 0,
		"raw bauxite" = 0,
		"phoron" = 0,
		"silver" = 0,
		"gold" = 0,
		"marble" = 0,
		"uranium" = 0,
		"diamond" = 0,
		"platinum" = 0,
		"lead" = 0,
		"mhydrogen" = 0,
		"verdantium" = 0,
		"rutile" = 0)

	var/list/ore_types = list(
		"hematite" = /obj/item/ore/iron,
		"uranium" = /obj/item/ore/uranium,
		"gold" = /obj/item/ore/gold,
		"silver" = /obj/item/ore/silver,
		"diamond" = /obj/item/ore/diamond,
		"phoron" = /obj/item/ore/phoron,
		"platinum" = /obj/item/ore/osmium,
		"mhydrogen" = /obj/item/ore/hydrogen,
		"sand" = /obj/item/ore/glass,
		"carbon" = /obj/item/ore/coal,
		"copper" = /obj/item/ore/copper,
		"tin" = /obj/item/ore/tin,
		"bauxite" = /obj/item/ore/bauxite,
		"rutile" = /obj/item/ore/rutile
		)

	//Upgrades
	var/harvest_speed
	var/capacity
	var/charge_use
	var/exotic_drilling
	var/obj/item/cell/cell = null

	// Found with an advanced laser. exotic_drilling >= 1
	var/list/ore_types_uncommon = list(
		MAT_MARBLE = /obj/item/ore/marble,
		MAT_PAINITE = /obj/item/ore/painite,
		MAT_QUARTZ = /obj/item/ore/quartz,
		MAT_LEAD = /obj/item/ore/lead
		)

	// Found with an ultra laser. exotic_drilling >= 2
	var/list/ore_types_rare = list(
		MAT_VOPAL = /obj/item/ore/void_opal,
		MAT_VERDANTIUM = /obj/item/ore/verdantium
		)

	//Flags
	var/need_update_field = 0
	var/need_player_check = 0


/obj/machinery/mining/drill/examine(mob/user) //Let's inform people about stuff. Let people KNOW how it works.
	. = ..()
	if(Adjacent(user))
		if(cell)
			. += "The drill's cell is [round(cell.percent() )]% charged."
			if(charge_use) //Prevention of dividing by 0 errors.
				. += "The drill reads that it can mine for [round((cell.charge/charge_use)/60)] more minutes before the cell depletes."
		else
			. += "The drill has no cell installed."
		if(drill_range)
			. += "The drill will mine in a range of [drill_range] tiles."
		if(harvest_speed)
			. += "The drill can mine [harvest_speed] [(harvest_speed == 1)? "ore" : "ores"] a second!"
		if(exotic_drilling)
			. += "The drill is upgraded and is capable of mining [(exotic_drilling == 1)? "moderately further" : "as deep as possible"]!"
		if(capacity && current_capacity)
			. += "The drill currently has [current_capacity] capacity taken up and can fit [capacity - current_capacity] more ore."

/obj/machinery/mining/drill/Initialize()
	. = ..()
	if(ispath(cell))
		cell = new cell(src)
	default_apply_parts()
	faultreporter = new /obj/item/radio/intercom{channels=list("Supply")}(null)

/obj/machinery/mining/drill/Destroy()
	qdel_null(faultreporter)
	qdel_null(cell)
	return ..()

/obj/machinery/mining/drill/dismantle()
	if(cell)
		cell.forceMove(loc)
		cell = null
	return ..()

/obj/machinery/mining/drill/get_cell()
	return cell

/obj/machinery/mining/drill/loaded
	cell = /obj/item/cell/high

/obj/machinery/mining/drill/process()

	if(need_player_check)
		return

	check_supports()

	if(!active) return

	if(!anchored || !use_cell_power())
		system_error("System configuration or charge error.")
		return

	if(need_update_field)
		get_resource_field()

	if(world.time % 10 == 0)
		update_icon()

	if(!active)
		return

	//Drill through the flooring, if any.
	if(istype(get_turf(src), /turf/simulated/mineral))
		var/turf/simulated/mineral/M = get_turf(src)
		M.GetDrilled()
	// Outpost 21 edit begin -extract gasses!
	else if(istype(get_turf(src), /turf/simulated/floor/gas_crack))
		if(gas_field.len)
			//Create gas mixture to hold data for passing
			var/datum/gas_mixture/GM = new
			for(var/gas in gas_field)
				GM.adjust_multi(gas, drill_moles_per_tick)
			GM.temperature = 423  // ~150C

			var/atom/location = src.loc
			location.assume_air(GM)
	// Outpost 21 edit end
	else if(istype(get_turf(src), /turf/simulated))
		var/turf/simulated/T = get_turf(src)
		T.ex_act(2.0)

	//Dig out the tasty ores.
	if(resource_field.len)
		var/turf/simulated/harvesting = pick(resource_field)

		while(resource_field.len && !harvesting.resources)
			harvesting.has_resources = 0
			harvesting.resources = null
			resource_field -= harvesting
			if(resource_field.len) // runtime protection
				harvesting = pick(resource_field)
			else
				harvesting = null

		if(!harvesting) return

		var/total_harvest = harvest_speed //Ore harvest-per-tick.
		var/found_resource = 0 //If this doesn't get set, the area is depleted and the drill errors out.

		for(var/metal in ore_types)

			if(current_capacity >= capacity)
				system_error("Insufficient storage space.")
				active = 0
				need_player_check = 1
				update_icon()
				return

			if(contents.len + total_harvest >= capacity)
				total_harvest = capacity - contents.len

			if(total_harvest <= 0) break
			if(harvesting.resources[metal])

				found_resource  = 1

				var/create_ore = 0
				if(harvesting.resources[metal] >= total_harvest)
					harvesting.resources[metal] -= total_harvest
					create_ore = total_harvest
					total_harvest = 0
				else
					total_harvest -= harvesting.resources[metal]
					create_ore = harvesting.resources[metal]
					harvesting.resources[metal] = 0

				for(var/i=1, i <= create_ore, i++)
					stored_ore[metal]++	// Adds the ore to the drill.
					current_capacity++	// Adds the ore to the drill's capacity.

		if(!found_resource)	// If a drill can't see an advanced material, it will destroy it while going through.
			harvesting.has_resources = 0
			harvesting.resources = null
			resource_field -= harvesting

	else if(!gas_field.len) // Outpost 21 edit - won't stop digging if gas pressure is detected
		active = 0
		need_player_check = 1
		update_icon()
		system_error("Resources depleted.")

/obj/machinery/mining/drill/attack_ai(var/mob/user as mob)
	return src.attack_hand(user)

/obj/machinery/mining/drill/attackby(obj/item/O as obj, mob/user as mob)
	if(!active)
		if(istype(O, /obj/item/multitool))
			var/newtag = text2num(sanitizeSafe(tgui_input_text(user, "Enter new ID number or leave empty to cancel.", "Assign ID number", null, 4), 4))
			if(newtag)
				name = "[initial(name)] #[newtag]"
				to_chat(user, "<span class='notice'>You changed the drill ID to: [newtag]</span>")
			else
				name = "[initial(name)]"
				to_chat(user, SPAN_NOTICE("You removed the drill's ID and any extraneous labels."))
			return
		if(default_deconstruction_screwdriver(user, O))
			return
		if(default_deconstruction_crowbar(user, O))
			return
		if(default_part_replacement(user, O))
			return
	if(!panel_open || active) return ..()

	if(istype(O, /obj/item/cell))
		if(cell)
			// to_chat(user, "The drill already has a cell installed.")
			balloon_alert(user, "The drill already has a cell installed.") // CHOMPEdit - Changed to balloon alert
		else
			user.drop_item()
			O.forceMove(src)
			cell = O
			component_parts += O
			// to_chat(user, "You install \the [O].")
			balloon_alert(user, "You install \the [O]") // CHOMPEdit - Changed to balloon alert
		return
	..()

/obj/machinery/mining/drill/attack_hand(mob/user as mob)
	check_supports()
	RefreshParts()

	if (panel_open && cell && user.Adjacent(src))
		// to_chat(user, "You take out \the [cell].")
		balloon_alert(user, "You take out \the [cell]") // CHOMPEdit - Changed to balloon alert
		user.put_in_hands(cell)
		component_parts -= cell
		cell = null
		return
	else if(need_player_check)
		// to_chat(user, "You hit the manual override and reset the drill's error checking.")
		balloon_alert(user, "Manual override hit, the drill's error checking resets.") // CHOMPEdit - Changed to balloon alert
		need_player_check = 0
		if(anchored)
			get_resource_field()
		update_icon()
		return
	else if(supported && !panel_open)
		if(use_cell_power())
			active = !active
			if(active)
				visible_message("<b>\The [src]</b> lurches downwards, grinding noisily.")
				need_update_field = 1
				harvest_speed *= total_brace_tier
				charge_use *= total_brace_tier
			else
				visible_message("<b>\The [src]</b> shudders to a grinding halt.")
		else
			to_chat(user, "<span class='notice'>The drill is unpowered.</span>")
	else
		to_chat(user, "<span class='notice'>Turning on a piece of industrial machinery without sufficient bracing or wires exposed is a bad idea.</span>")

	update_icon()

/obj/machinery/mining/drill/update_icon()
	if(need_player_check)
		icon_state = "mining_drill_error"
	else if(active)
		icon_state = "mining_drill_active"
	else if(supported)
		icon_state = "mining_drill_braced"
	else
		icon_state = "mining_drill"
	return

/obj/machinery/mining/drill/RefreshParts()
	..()
	harvest_speed = 0
	capacity = 0
	charge_use = 50
	drill_range = 5
	offset = 2

	for(var/obj/item/stock_parts/P in component_parts)
		if(istype(P, /obj/item/stock_parts/micro_laser))
			harvest_speed = P.rating ** 2 // 1, 4, 9, 16, 25
			exotic_drilling = P.rating - 1
			if(exotic_drilling >= 1)
				ore_types |= ore_types_uncommon
				if(exotic_drilling >= 2)
					ore_types |= ore_types_rare
			else
				ore_types -= ore_types_uncommon
				ore_types -= ore_types_rare
			if(P.rating > 3) // are we t4+?
				// default drill range 5, offset 2
				if(P.rating >= 5) // t5
					drill_range = 9
					offset = 4
				else if(P.rating >= 4) // t4
					drill_range = 7
					offset = 3
		if(istype(P, /obj/item/stock_parts/matter_bin))
			capacity = 200 * P.rating
		if(istype(P, /obj/item/stock_parts/capacitor))
			charge_use -= 10 * P.rating
	cell = locate(/obj/item/cell) in src

/obj/machinery/mining/drill/proc/check_supports()

	supported = 0
	total_brace_tier = 0

	if((!supports || !supports.len) && initial(anchored) == 0)
		icon_state = "mining_drill"
		anchored = FALSE
		active = 0
	else
		anchored = TRUE

	if(supports)
		if(supports.len >= braces_needed)
			supported = 1
		else for(var/obj/machinery/mining/brace/check in supports)
			if(check.brace_tier >= 3)
				supported = 1
		for(var/obj/machinery/mining/brace/check in supports)
			total_brace_tier += check.brace_tier

	update_icon()

/obj/machinery/mining/drill/proc/system_error(var/error)

	if(error)
		src.visible_message("<b>\The [src]</b> flashes a '[error]' warning.")
		faultreporter.autosay(error, src.name, "Supply", using_map.get_map_levels(z))
	need_player_check = 1
	active = 0
	update_icon()

/obj/machinery/mining/drill/proc/get_resource_field()

	resource_field = list()
	gas_field = list() // Outpost 21 edit - gas mining
	need_update_field = 0
	drill_moles_per_tick = 0 // Outpost 21 edit - gas mining

	var/turf/T = get_turf(src)
	if(!istype(T)) return

	var/tx = T.x - offset
	var/ty = T.y - offset
	var/turf/simulated/mine_turf
	for(var/iy = 0,iy < drill_range, iy++)
		for(var/ix = 0, ix < drill_range, ix++)
			mine_turf = locate(tx + ix, ty + iy, T.z)
			if(!istype(mine_turf, /turf/space/))
				if(mine_turf && mine_turf.has_resources)
					resource_field += mine_turf
				// Outpost 21 edit begin - gas mining
				if(istype(mine_turf,/turf/simulated/floor/gas_crack))
					drill_moles_per_tick += 2
					// Get gasses the cracks around us could give!
					if(mine_turf.oxygen && !("oxygen" in gas_field))
						gas_field.Add("oxygen")
					if(mine_turf.nitrogen && !("nitrogen" in gas_field))
						gas_field.Add("nitrogen")
					if(mine_turf.carbon_dioxide && !("carbon_dioxide" in gas_field))
						gas_field.Add("carbon_dioxide")
					if(mine_turf.phoron && !("phoron" in gas_field))
						gas_field.Add("phoron")
					if(mine_turf.nitrous_oxide && !("nitrous_oxide" in gas_field))
						gas_field.Add("nitrous_oxide")
					if(mine_turf.methane && !("methane" in gas_field))
						gas_field.Add("methane")
				// Outpost 21 edit end
	if(!resource_field.len && !gas_field.len) // Outpost 21 edit - gas mining
		system_error("Resources depleted.")

/obj/machinery/mining/drill/proc/use_cell_power()
	if(!cell) return 0
	if(cell.charge >= charge_use)
		cell.use(charge_use)
		return 1
	return 0

/obj/machinery/mining/drill/verb/unload()
	set name = "Unload Drill"
	set category = "Object"
	set src in oview(1)

	if(usr.stat) return

	var/obj/structure/ore_box/B = locate() in orange(1)
	if(B)
		for(var/ore in stored_ore)
			if(stored_ore[ore] > 0)
				var/ore_amount = stored_ore[ore]	// How many ores does the satchel have?
				B.stored_ore[ore] += ore_amount 	// Add the ore to the machine.
				stored_ore[ore] = 0 				// Set the value of the ore in the satchel to 0.
				current_capacity = 0				// Set the amount of ore in the drill to 0.
		// to_chat(usr, "<span class='notice'>You unload the drill's storage cache into the ore box.</span>")
		balloon_alert(usr, "You onload the drill's storage cache into the ore box.") // CHOMPEdit - Changed to balloon alert
	else
		// to_chat(usr, "<span class='notice'>You must move an ore box up to the drill before you can unload it.</span>")
		balloon_alert(usr, "Move an ore box to the droll before unloading it.") // CHOMPEdit - Changed to balloon alert


/obj/machinery/mining/brace
	name = "mining drill brace"
	desc = "A machinery brace for an industrial drill. It looks easily two feet thick."
	icon_state = "mining_brace"
	circuit = /obj/item/circuitboard/miningdrillbrace
	var/brace_tier = 1
	var/obj/machinery/mining/drill/connected

/obj/machinery/mining/brace/examine(mob/user)
	. = ..()
	if(brace_tier >= 3)
		. += SPAN_NOTICE("The internals of the brace look resilient enough to support a drill by itself.")

/obj/machinery/mining/brace/Initialize()
	. = ..()
	default_apply_parts()

/obj/machinery/mining/brace/RefreshParts()
	..()
	brace_tier = 0
	for(var/obj/item/stock_parts/manipulator/M in component_parts)
		brace_tier += M.rating

/obj/machinery/mining/brace/attackby(obj/item/W as obj, mob/user as mob)
	if(connected && connected.active)
		// to_chat(user, "<span class='notice'>You can't work with the brace of a running drill!</span>")
		balloon_alert(user, "You can't work with the brace of a running drill.") // CHOMPEdit - Changed to balloon alert
		return

	if(default_deconstruction_screwdriver(user, W))
		return
	if(default_deconstruction_crowbar(user, W))
		return
	if(default_part_replacement(user,W))
		return

	if(W.has_tool_quality(TOOL_WRENCH))

		if(istype(get_turf(src), /turf/space))
			// to_chat(user, "<span class='notice'>You can't anchor something to empty space. Idiot.</span>")
			balloon_alert(user, "You can't anchor something to empty space. Idiot.") // CHOMPEdit - Changed to balloon alert
			return

		playsound(src, W.usesound, 100, 1)
		// to_chat(user, "<span class='notice'>You [anchored ? "un" : ""]anchor the brace.</span>")
		balloon_alert(user, "[anchored ? "Una" : "A"]nchored the brace") // CHOMPEdit - Changed to balloon alert

		anchored = !anchored
		if(anchored)
			connect()
		else
			disconnect()

/obj/machinery/mining/brace/proc/connect()

	var/turf/T = get_step(get_turf(src), src.dir)

	for(var/thing in T.contents)
		if(istype(thing, /obj/machinery/mining/drill))
			connected = thing
			break

	if(!connected)
		return

	if(!connected.supports)
		connected.supports = list()

	icon_state = "mining_brace_active"

	connected.supports += src
	connected.check_supports()

/obj/machinery/mining/brace/proc/disconnect()

	if(!connected) return

	if(!connected.supports) connected.supports = list()

	icon_state = "mining_brace"

	connected.supports -= src
	connected.check_supports()
	connected = null

/obj/machinery/mining/brace/verb/rotate_clockwise()
	set name = "Rotate Brace Clockwise"
	set category = "Object"
	set src in oview(1)

	if(usr.stat) return

	if (src.anchored)
		// to_chat(usr, "It is anchored in place!")
		balloon_alert(usr, "It is anchored in place!") // CHOMPEdit - Changed to balloon alert
		return 0

	src.set_dir(turn(src.dir, 270))
	return 1

//VOREstation edit: counter-clockwise rotation
/obj/machinery/mining/brace/verb/rotate_counterclockwise()
	set name = "Rotate Brace Counter-Clockwise"
	set category = "Object"
	set src in oview(1)

	if(usr.stat) return

	if (src.anchored)
		// to_chat(usr, "It is anchored in place!")
		balloon_alert(usr, "It is anchored in place!") // CHOMPEdit - Changed to balloon alert
		return 0

	src.set_dir(turn(src.dir, 90))
	return 1
