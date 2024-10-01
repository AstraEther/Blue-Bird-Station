/obj/machinery/reagentgrinder

	name = "All-In-One Grinder"
	desc = "Grinds stuff into itty bitty bits."
	icon = 'icons/obj/kitchen.dmi'
	icon_state = "juicer1"
	density = FALSE
	anchored = FALSE
	use_power = USE_POWER_IDLE
	idle_power_usage = 5
	active_power_usage = 100
	circuit = /obj/item/circuitboard/grinder
	var/inuse = 0
	var/obj/item/reagent_containers/beaker = null
	var/limit = 10
	var/list/holdingitems = list()
	// Outpost 21 edit - Moved grindable list to global for wiki

	/* Outpost 21 edit - disable radial menu
	var/static/radial_examine = image(icon = 'icons/mob/radial.dmi', icon_state = "radial_examine")
	var/static/radial_eject = image(icon = 'icons/mob/radial.dmi', icon_state = "radial_eject")
	var/static/radial_grind = image(icon = 'icons/mob/radial.dmi', icon_state = "radial_grind")
	// var/static/radial_juice = image(icon = 'icons/mob/radial.dmi', icon_state = "radial_juice")
	// var/static/radial_mix = image(icon = 'icons/mob/radial.dmi', icon_state = "radial_mix")
	*/

/obj/machinery/reagentgrinder/Initialize()
	. = ..()
	beaker = new /obj/item/reagent_containers/glass/beaker/large(src)
	default_apply_parts()

/obj/machinery/reagentgrinder/examine(mob/user)
	. = ..()
	if(!in_range(user, src) && !issilicon(user) && !isobserver(user))
		. += "<span class='warning'>You're too far away to examine [src]'s contents and display!</span>"
		return

	if(inuse)
		. += "<span class='warning'>\The [src] is operating.</span>"
		return

	if(beaker || length(holdingitems))
		. += "<span class='notice'>\The [src] contains:</span>"
		if(beaker)
			. += "<span class='notice'>- \A [beaker].</span>"
		for(var/obj/item/O as anything in holdingitems)
			. += "<span class='notice'>- \A [O.name].</span>"

	if(!(stat & (NOPOWER|BROKEN)))
		. += "<span class='notice'>The status display reads:</span>\n"
		if(beaker)
			for(var/datum/reagent/R in beaker.reagents.reagent_list)
				. += "<span class='notice'>- [R.volume] units of [R.name].</span>"

/obj/machinery/reagentgrinder/update_icon()
	icon_state = "juicer"+num2text(!isnull(beaker))
	return

/obj/machinery/reagentgrinder/attackby(var/obj/item/O as obj, var/mob/user as mob)
	if(beaker)
		if(default_deconstruction_screwdriver(user, O))
			return
		if(default_deconstruction_crowbar(user, O))
			return

	//VOREStation edit start - for solargrubs
	if (istype(O, /obj/item/multitool))
		return ..()
	//VOREStation edit end

	if (istype(O,/obj/item/reagent_containers/glass) || \
		istype(O,/obj/item/reagent_containers/food/drinks/glass2) || \
		istype(O,/obj/item/reagent_containers/food/drinks/shaker))

		if (beaker)
			return 1
		else
			src.beaker =  O
			user.drop_item()
			O.loc = src
			update_icon()
			src.updateUsrDialog()
			return 0

	if(holdingitems && holdingitems.len >= limit)
		to_chat(user, "The machine cannot hold anymore items.")
		return 1

	if(!istype(O))
		return

	if(istype(O,/obj/item/storage/bag/plants))
		var/obj/item/storage/bag/plants/bag = O
		var/failed = 1
		for(var/obj/item/G in O.contents)
			if(!G.reagents || !G.reagents.total_volume)
				continue
			failed = 0
			bag.remove_from_storage(G, src)
			holdingitems += G
			if(holdingitems && holdingitems.len >= limit)
				break

		if(failed)
			to_chat(user, "Nothing in the plant bag is usable.")
			return 1

		if(!O.contents.len)
			to_chat(user, "You empty \the [O] into \the [src].")
		else
			to_chat(user, "You fill \the [src] from \the [O].")

		src.updateUsrDialog()
		return 0

	if(istype(O,/obj/item/gripper))
		var/obj/item/gripper/B = O	//B, for Borg.
		if(!B.wrapped)
			to_chat(user, "\The [B] is not holding anything.")
			return 0
		else
			var/B_held = B.wrapped
			to_chat(user, "You use \the [B] to load \the [src] with \the [B_held].")

		return 0

	if(!global.sheet_reagents[O.type] && !global.ore_reagents[O.type] && (!O.reagents || !O.reagents.total_volume)) // Outpost 21 edit - ore grinding. globalized lists
		to_chat(user, "\The [O] is not suitable for blending.")
		return 1

	user.remove_from_mob(O)
	O.loc = src
	holdingitems += O
	//CHOMPedit start
	if(istype(O,/obj/item/stack/material/supermatter))
		var/obj/item/stack/material/supermatter/S = O
		set_light(l_range = max(1, S.get_amount()/10), l_power = max(1, S.get_amount()/10), l_color = "#8A8A00")
		addtimer(CALLBACK(src, PROC_REF(puny_protons)), 30 SECONDS)
	//CHOMPedit end
	return 0

// outpost 21 (large)edit begin - removing radial menu
/obj/machinery/reagentgrinder/AltClick(var/mob/user)
	. = ..()
	grind_verb()

/obj/machinery/reagentgrinder/attack_hand(var/mob/user)
	//interact(user)
	if(isAI(user))
		return
	if(inuse || user.incapacitated() || !Adjacent(user))
		return

	if(beaker)
		replace_beaker(user)
		return

	if(length(holdingitems))
		eject(user)
		return

/obj/machinery/reagentgrinder/verb/grind_verb()
	set name = "Grind"
	set category = "Object"
	set src in oview(1)

	if(inuse || usr.incapacitated() || !Adjacent(usr) || stat & NOPOWER)
		return
	if(isAI(usr))
		return
	if(!beaker)
		to_chat(usr, "No beaker inserted.")
	else if(!length(holdingitems))
		to_chat(usr, "\the [src] is empty.")
	else
		grind(usr)

/obj/machinery/reagentgrinder/verb/eject_verb()
	set name = "Eject Contents"
	set category = "Object"
	set src in oview(1)

	if(inuse || usr.incapacitated() || !Adjacent(usr))
		return
	if(isAI(usr))
		return
	if(!length(holdingitems))
		to_chat(usr, "\the [src] is already empty.")
	else
		eject(usr)

/obj/machinery/reagentgrinder/verb/remove_beaker()
	set name = "Remove Beaker"
	set category = "Object"
	set src in oview(1)

	if(inuse || usr.incapacitated() || !Adjacent(usr))
		return
	if(isAI(usr))
		return
	if(!beaker)
		to_chat(usr, "No beaker inserted.")
	else
		replace_beaker(usr)

/*
/obj/machinery/reagentgrinder/interact(mob/user as mob) // The microwave Menu //I am reasonably certain that this is not a microwave
	if(inuse || user.incapacitated())
		return

	var/list/options = list()

	if(beaker || length(holdingitems))
		options["eject"] = radial_eject

	if(isAI(user))
		if(stat & NOPOWER)
			return
		options["examine"] = radial_examine

	// if there is no power or it's broken, the procs will fail but the buttons will still show
	if(length(holdingitems))
		options["grind"] = radial_grind

	var/choice
	if(length(options) < 1)
		return
	if(length(options) == 1)
		for(var/key in options)
			choice = key
	else
		choice = show_radial_menu(user, src, options, require_near = !issilicon(user))

	// post choice verification
	if(inuse || (isAI(user) && stat & NOPOWER) || user.incapacitated())
		return

	switch(choice)
		if("eject")
			eject(user)
		if("grind")
			grind(user)
		if("examine")
			examine(user)
*/

/obj/machinery/reagentgrinder/proc/eject(mob/user)
	if(user.incapacitated())
		return
	for(var/obj/item/O in holdingitems)
		O.loc = src.loc
		holdingitems -= O
	holdingitems.Cut()
	//if(beaker)
	//	replace_beaker(user)

/obj/machinery/reagentgrinder/proc/grind(var/mob/user)

	power_change()
	if(stat & (NOPOWER|BROKEN))
		return

	// Sanity check.
	if (!beaker || (beaker && beaker.reagents.total_volume >= beaker.reagents.maximum_volume))
		return

	playsound(src, 'sound/machines/blender.ogg', 50, 1)
	inuse = 1

	// Reset the machine.
	spawn(60)
		inuse = 0

	process_contents() // Outpost 21 edit - seperate this out for industrial grinder use

// Outpost 21 edit begin - seperate this out for industrial grinder use
/obj/machinery/reagentgrinder/proc/process_contents()
	// Process.
	var/original_volume = beaker.reagents.total_volume // Outpost 21 edit - keep track of if we gained any reagents
	for (var/obj/item/O in holdingitems)
		//CHOMPedit start
		if(istype(O,/obj/item/stack/material/supermatter))
			var/regrets = 0
			for(var/obj/item/stack/material/supermatter/S in holdingitems)
				regrets += S.get_amount()
			puny_protons(regrets)
			return
		//CHOMPedit end

		var/remaining_volume = beaker.reagents.maximum_volume - beaker.reagents.total_volume
		if(remaining_volume <= 0)
			break

		if(global.sheet_reagents[O.type]) // Outpost 21 edit - globalized grinding list
			var/obj/item/stack/stack = O
			if(istype(stack))
				var/list/sheet_components = global.sheet_reagents[stack.type] // Outpost 21 edit - globalized grinding list
				var/amount_to_take = max(0,min(stack.get_amount(),round(remaining_volume/REAGENTS_PER_SHEET)))
				if(amount_to_take)
					stack.use(amount_to_take)
					if(QDELETED(stack))
						holdingitems -= stack
					if(islist(sheet_components))
						amount_to_take = (amount_to_take/(sheet_components.len))
						for(var/i in sheet_components)
							beaker.reagents.add_reagent(i, (amount_to_take*REAGENTS_PER_SHEET))
					else
						beaker.reagents.add_reagent(sheet_components, (amount_to_take*REAGENTS_PER_SHEET))
					continue

		// Outpost 21 addition begin - Ore grinding
		if(global.ore_reagents[O.type])
			var/obj/item/weapon/ore/R = O
			if(istype(R))
				var/list/ore_components = global.ore_reagents[R.type]
				if(remaining_volume >= REAGENTS_PER_ORE)
					holdingitems -= R
					qdel(R)
					if(islist(ore_components))
						var/amount_to_take = (REAGENTS_PER_ORE/(ore_components.len))
						for(var/i in ore_components)
							beaker.reagents.add_reagent(i, amount_to_take)
					else
						beaker.reagents.add_reagent(ore_components, REAGENTS_PER_ORE)
					continue
		// Outpost 21 addition end

		if(O.reagents)
			O.reagents.trans_to_obj(beaker, min(O.reagents.total_volume, remaining_volume))
			if(O.reagents.total_volume == 0)
				holdingitems -= O
				qdel(O)
			if (beaker.reagents.total_volume >= beaker.reagents.maximum_volume)
				break

	// if we gained regents then return true
	return original_volume < beaker.reagents.total_volume // Outpost 21 edit - keep track of if we gained any reagents
// Outpost 21 edit end

/obj/machinery/reagentgrinder/proc/replace_beaker(var/mob/living/user, var/obj/item/reagent_containers/new_beaker)
	if(!user)
		return FALSE
	if(beaker)
		if(!user.incapacitated() && Adjacent(user))
			user.put_in_hands(beaker)
		else
			beaker.forceMove(drop_location())
		beaker = null
	if(new_beaker)
		beaker = new_beaker
	update_icon()
	return TRUE
// outpost 21 (large)edit end - Yes, that is basically all of the file above us!

// CHOMPedit start: Repurposed coffee grinders and supermatter do not mix.
/obj/machinery/reagentgrinder/proc/puny_protons(regrets = 0)
	set_light(0)
	if(regrets > 0) // If you thought grinding supermatter would end well. Values taken from ex_act() for the supermatter stacks.
		SSradiation.radiate(get_turf(src), 15 + regrets * 4)
		explosion(get_turf(src), round(regrets / 12) , round(regrets / 6), round(regrets / 3), round(regrets / 25))
		qdel(src)
		return

	else // If you added supermatter but didn't try grinding it, or somehow this is negative.
		for(var/obj/item/stack/material/supermatter/S in holdingitems)
			S.loc = src.loc
			holdingitems -= S
			regrets += S.get_amount()
		SSradiation.radiate(get_turf(src), 15 + regrets)
		visible_message("<span class=\"warning\">\The [src] glows brightly, bursting into flames and flashing into ash.</span>",\
		"<span class=\"warning\">You hear an unearthly shriek, burning heat washing over you.</span>")
		new /obj/effect/decal/cleanable/ash(src.loc)
		qdel(src)
// CHOMPedit end
