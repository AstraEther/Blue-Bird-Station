//////////////////////////////////////
// GEAR DISPENSER UNIT ///////////////
//////////////////////////////////////

#define GD_BUSY			1		// the dispenser is busy.
#define GD_ONEITEM		2		// only one type of suit comes out of this dispenser.
#define GD_NOGREED		4		// no-one is allowed more than one item from this TYPE of dispenser unless emagged
#define GD_UNLIMITED	8		// will not deplete amount when gear is taken

var/list/dispenser_presets = list()

// Standard generic item list
/datum/gear_disp
	var/name = "gear"
	var/list/to_spawn
	var/amount = 0
	var/list/req_one_access

/datum/gear_disp/proc/allowed(var/mob/living/carbon/human/user)
	if(LAZYLEN(req_one_access))
		var/accesses = user.GetAccess()
		return has_access(null, req_one_access, accesses)

	return 1

/datum/gear_disp/proc/spawn_gear(var/turf/T, var/mob/living/carbon/human/user)
	var/list/spawned = list()
	for(var/O in to_spawn)
		spawned += new O(T)
	return spawned

// For fluff/custom items
/datum/gear_disp/custom
	name = "custom"
	// Can do either/or of these
	var/ckey_allowed
	var/character_allowed

/datum/gear_disp/custom/allowed(var/mob/living/carbon/human/user)
	if(ckey_allowed && user.ckey != ckey_allowed)
		return 0

	if(character_allowed && user.real_name != character_allowed)
		return 0

	return ..()

/datum/gear_disp/trash
	name = "???"
	to_spawn = list(/obj/random/trash)
	amount = 50

// Voidsuits can have bits jammed onto them
/datum/gear_disp/voidsuit
	//var/list/to_spawn // Put other stuff that ISN'T one of the below
	var/voidsuit_type
	var/voidhelmet_type
	var/magboots_type
	var/life_support = TRUE // try to spawn a tank or suit cooler
	var/refit = TRUE // should we adapt this to the user's species

/datum/gear_disp/voidsuit/spawn_gear(var/turf/T, var/mob/living/carbon/human/user)
	ASSERT(voidsuit_type)
	. = ..()
	if(voidsuit_type && !ispath(voidsuit_type, /obj/item/clothing/suit/space/void))
		error("[src] can't spawn type [voidsuit_type] as a voidsuit")
		return
	if(voidhelmet_type && !ispath(voidhelmet_type, /obj/item/clothing/head/helmet/space/void))
		error("[src] can't spawn type [voidsuit_type] as a voidhelmet")
		return
	if(magboots_type && !ispath(magboots_type, /obj/item/clothing/shoes/magboots))
		error("[src] can't spawn type [magboots_type] as magboots")
		return

	var/obj/item/clothing/suit/space/void/voidsuit
	var/obj/item/clothing/head/helmet/space/void/voidhelmet
	var/obj/item/clothing/shoes/magboots/magboots

	var/spawned = list()

	voidsuit = new voidsuit_type(T)
	spawned += voidsuit
	// If we're supposed to make a helmet
	if(voidhelmet_type)
		// The coder may not have realized this type spawns its own helmet
		if(voidsuit.helmet)
			error("[src] created a voidsuit [voidsuit] and wants to add a helmet but it already has one")
		else
			voidhelmet = new voidhelmet_type(voidsuit)
			voidsuit.helmet = voidhelmet
			spawned += voidhelmet
	// If we're supposed to make boots
	if(magboots_type)
		// The coder may not have realized thist ype spawns its own boots
		if(voidsuit.boots)
			error("[src] created a voidsuit [voidsuit] and wants to add a helmet but it already has one")
		else
			magboots = new magboots_type(voidsuit)
			voidsuit.boots = magboots
			spawned += magboots

	if(refit)
		voidsuit.refit_for_species(user.species?.get_bodytype()) // does helmet and boots if they're attached

	if(life_support)
		if(user.isSynthetic())
			if(voidsuit.cooler)
				error("[src] created a voidsuit [voidsuit] and wants to add a suit cooler but it already has one")
			else
				var/obj/item/life_support = new /obj/item/suit_cooling_unit(voidsuit)
				voidsuit.cooler = life_support
				spawned += life_support
		else if(user.species?.breath_type)
			if(voidsuit.tank)
				error("[src] created a voidsuit [voidsuit] and wants to add a tank but it already has one")
			else
				//Create a tank (if such a thing exists for this species)
				var/tanktext = "/obj/item/tank/" + "[user.species?.breath_type]"
				var/obj/item/tank/tankpath = text2path(tanktext)

				if(tankpath)
					var/obj/item/life_support = new tankpath(voidsuit)
					voidsuit.tank = life_support
					spawned += life_support
				else
					voidsuit.audible_message("Dispenser warning: Unable to locate suitable airtank for user.")

	. += spawned

// For fluff/custom voidsuits
/datum/gear_disp/voidsuit/custom
	name = "custom voidsuit"
	// Can do either/or of these
	var/ckey_allowed
	var/character_allowed

/datum/gear_disp/voidsuit/custom/allowed(var/mob/living/carbon/human/user)
	if(ckey_allowed && user.ckey != ckey_allowed)
		return 0

	if(character_allowed && user.real_name != character_allowed)
		return 0

	return ..()

// The dispenser itself
/obj/machinery/gear_dispenser
	name = "gear dispenser"
	desc = "An industrial U-Tak-It Dispenser unit designed to fetch all kinds of equipment."
	icon = 'icons/obj/suitdispenser.dmi'
	icon_state = "geardispenser"
	anchored = 1
	density = 1
	var/list/dispenses = list(/datum/gear_disp/trash) // put your gear datums here!
	var/datum/gear_disp/one_setting
	var/global/list/gear_distributed_to = list()
	var/dispenser_flags = GD_NOGREED|GD_UNLIMITED
	//req_one_access = list(whatever) // Note that each gear datum can have access, too.

/obj/machinery/gear_dispenser/custom/emag_act(remaining_charges, mob/user, emag_source)
	to_chat(user, span_warning("Your moral standards prevent you from emagging this machine!"))
	return -1 // Letting people emag this one would be bad times

/obj/machinery/gear_dispenser/Initialize()
	. = ..()
	if(!gear_distributed_to["[type]"] && (dispenser_flags & GD_NOGREED))
		gear_distributed_to["[type]"] = list()
	var/list/real_gear_list = list()
	for(var/gear in dispenses)
		var/datum/gear_disp/S = new gear
		real_gear_list[S.name] = S
	if(one_setting)
		one_setting = new one_setting
	dispenses = real_gear_list


/obj/machinery/gear_dispenser/attack_hand(var/mob/living/carbon/human/user)
	if(!can_use(user))
		return
	dispenser_flags |= GD_BUSY
	if(!(dispenser_flags & GD_ONEITEM))
		var/list/gear_list = get_gear_list(user)

		if(!LAZYLEN(gear_list))
			to_chat(user, span_warning("\The [src] doesn't have anything to dispense for you!"))
			dispenser_flags &= ~GD_BUSY
			return

		var/choice = input("Select equipment to dispense.", "Equipment Dispenser") as null|anything in gear_list

		if(!choice)
			dispenser_flags &= ~GD_BUSY
			return

		dispense(gear_list[choice],user)
	else
		dispense(one_setting,user)


/obj/machinery/gear_dispenser/proc/can_use(var/mob/living/carbon/human/user)
	var/list/used_by = gear_distributed_to["[type]"]
	if(!istype(user))
		to_chat(user,span_warning("You can't use this!"))
		return 0
	if((dispenser_flags & GD_BUSY))
		to_chat(user,span_warning("Someone else is using this!"))
		return 0
	if((dispenser_flags & GD_ONEITEM) && !(dispenser_flags & GD_UNLIMITED) && !one_setting.amount)
		to_chat(user,span_warning("There's nothing in here!"))
		return 0
	if ((dispenser_flags & GD_NOGREED) && (user in used_by) && !emagged)
		to_chat(user,span_warning("You've already picked up your gear!"))
		playsound(src, 'sound/machines/buzz-sigh.ogg', 50, 0)
		return 0
	if(emagged)
		audible_message("!'^&YouVE alreaDY pIC&$!Ked UP yOU%r Ge^!ar.")
		playsound(src, 'sound/machines/buzz-sigh.ogg', 100, 0)
		return 1

	// And finally
	if(allowed(user))
		return 1
	else
		to_chat(user,span_warning("Your access is rejected!"))
		playsound(src, 'sound/machines/buzz-sigh.ogg', 100, 0)
		return 0


/obj/machinery/gear_dispenser/proc/get_gear_list(var/mob/living/carbon/human/user)
	if(emagged)
		return dispenses

	var/list/choices = list()
	for(var/choice in dispenses)
		var/datum/gear_disp/G = dispenses[choice]
		if(G.allowed(user))
			choices[choice] = G
	return choices

/obj/machinery/gear_dispenser/proc/dispense(var/datum/gear_disp/S,var/mob/living/carbon/human/user,var/greet=TRUE)
	if(!S.amount && !(dispenser_flags & GD_UNLIMITED))
		to_chat(user,span_warning("There are no more [S.name]s left!"))
		dispenser_flags &= ~GD_BUSY
		return 1
	else if(!(dispenser_flags & GD_UNLIMITED))
		S.amount--
	if((dispenser_flags & GD_NOGREED) && !emagged)
		gear_distributed_to["[type]"] |= user
	flick("[icon_state]-scan",src)
	visible_message("\The [src] scans its user.", runemessage = "hums")
	sleep(30)
	flick("[icon_state]-dispense",src)
	dispenser_flags |= GD_BUSY
	sleep(15)
	dispenser_flags &= ~GD_BUSY

	var/turf/T = get_turf(src)
	if(!(S && T)) // in case we got destroyed while we slept
		return 1

	S.spawn_gear(T, user)

	if(emagged)
		emagged = FALSE
	if(greet && user && !user.stat) // in case we got destroyed while we slept
		to_chat(user,span_notice("[S.name] dispensing processed. Have a good day."))

/obj/machinery/gear_dispenser/proc/fit_for(var/obj/item/clothing/C, var/mob/living/carbon/human/H)
	if(!istype(C))
		error("Suit dispenser thought [C] was a clothing item")
		return
	C.refit_for_species(H.species?.get_bodytype())
	if(istype(C, /obj/item/clothing/suit/space/void))
		var/obj/item/clothing/suit/space/void/V = C
		V.helmet?.refit_for_species(H.species?.get_bodytype())

/obj/machinery/gear_dispenser/emag_act(remaining_charges, mob/user, emag_source)
	. = ..()
	if(!emagged)
		emagged = TRUE
		visible_message(span_warning("\The [user] slides a weird looking ID into \the [src]!"),span_warning("You temporarily short the safety mechanisms."))
		return 1


// Just a different sprite
/obj/machinery/gear_dispenser/suit
	name = "suit dispenser"
	desc = "An industrial U-Tak-It Dispenser unit designed to fetch all kinds of space suits."
	icon_state = "suitdispenser2"

/obj/machinery/gear_dispenser/suit_old
	name = "duit dispenser"
	desc = "An industrial U-Tak-It Dispenser unit designed to fetch all kinds of space suits. An older model."
	icon_state = "suitdispenser"

// For fluff/custom items
/obj/machinery/gear_dispenser/custom
	name = "personal gear dispenser"

/obj/machinery/gear_dispenser/custom/Initialize()
	dispenses = subtypesof(/datum/gear_disp/custom)
	. = ..()


////////////////////////////// ERT SUIT DISPENSERS ///////////////////////////
// Non-sealed armor
/datum/gear_disp/ert/security_armor
	name = "Security (Armor)"
	to_spawn = list(/obj/item/clothing/suit/armor/vest/ert/security,/obj/item/clothing/head/helmet/ert/security)

/datum/gear_disp/ert/medical_armor
	name = "Medical (Armor)"
	to_spawn = list(/obj/item/clothing/suit/armor/vest/ert/medical,/obj/item/clothing/head/helmet/ert/medical)

/datum/gear_disp/ert/engineer_armor
	name = "Engineering (Armor)"
	to_spawn = list(/obj/item/clothing/suit/armor/vest/ert/engineer,/obj/item/clothing/head/helmet/ert/engineer)
/*
/datum/gear_disp/ert/commander_armor
	name = "Commander (Armor)"
	to_spawn = list(/obj/item/clothing/suit/armor/vest/ert/command,/obj/item/clothing/head/helmet/ert/command)
	amount = 1
*/
// Voidsuit versions
/datum/gear_disp/voidsuit/ert/security_void
	name = "Security (Voidsuit)"
	voidsuit_type = /obj/item/clothing/suit/space/void/responseteam/security
	refit = TRUE
	magboots_type = /obj/item/clothing/shoes/magboots/adv

/datum/gear_disp/voidsuit/ert/medical_void
	name = "Medical (Voidsuit)"
	voidsuit_type = /obj/item/clothing/suit/space/void/responseteam/medical
	refit = TRUE
	magboots_type = /obj/item/clothing/shoes/magboots/adv

/datum/gear_disp/voidsuit/ert/engineer_void
	name = "Engineering (Voidsuit)"
	voidsuit_type = /obj/item/clothing/suit/space/void/responseteam/engineer
	refit = TRUE
	magboots_type = /obj/item/clothing/shoes/magboots/adv
/*
/datum/gear_disp/ert/commander_void
	name = "Commander (Voidsuit)"
	to_spawn = list(/obj/item/clothing/suit/space/void/responseteam/command)
	refit = TRUE
	amount = 1
*/
// Hardsuit versions
/datum/gear_disp/ert/security_rig
	name = "Security (Hardsuit)"
	to_spawn = list(/obj/item/rig/ert/security)

/datum/gear_disp/ert/medical_rig
	name = "Medical (Hardsuit)"
	to_spawn = list(/obj/item/rig/ert/medical)

/datum/gear_disp/ert/engineer_rig
	name = "Engineering (Hardsuit)"
	to_spawn = list(/obj/item/rig/ert/engineer)
/*
/datum/gear_disp/ert/commander_rig
	name = "Commander (Hardsuit)"
	to_spawn = list(/obj/item/rig/ert)
	amount = 1
*/


/obj/machinery/gear_dispenser/suit/ert
	name = "ERT Suit Dispenser"
	desc = "An industrial U-Tak-It Dispenser unit designed to fetch all kinds of space suits. This one distribributes Emergency Responder space suits."
	icon_state = "suitdispenserERT"
	dispenses = list(
		/datum/gear_disp/ert/security_armor,
		/datum/gear_disp/ert/medical_armor,
		/datum/gear_disp/ert/engineer_armor,
		/datum/gear_disp/voidsuit/ert/security_void,
		/datum/gear_disp/voidsuit/ert/medical_void,
		/datum/gear_disp/voidsuit/ert/engineer_void,
		/datum/gear_disp/ert/security_rig,
		/datum/gear_disp/ert/medical_rig,
		/datum/gear_disp/ert/engineer_rig,
	)
	req_one_access = list(access_cent_specops)


////////////////////////////// STATION SUIT DISPENSERS ///////////////////////////
/datum/gear_disp/station/standard
	name = "Standard (Softsuit)"
	to_spawn = list(/obj/item/clothing/head/helmet/space, /obj/item/clothing/suit/space)

/datum/gear_disp/voidsuit/station/security
	name = "Security (Voidsuit)"
	voidsuit_type = /obj/item/clothing/suit/space/void/security
	voidhelmet_type = /obj/item/clothing/head/helmet/space/void/security
	refit = TRUE
	req_one_access = list(access_brig)

/datum/gear_disp/voidsuit/station/engineering
	name = "Engineering (Voidsuit)"
	voidsuit_type = /obj/item/clothing/suit/space/void/engineering
	voidhelmet_type = /obj/item/clothing/head/helmet/space/void/engineering
	refit = TRUE
	magboots_type = /obj/item/clothing/shoes/magboots
	req_one_access = list(access_engine)

/datum/gear_disp/voidsuit/station/medical
	name = "Medical (Voidsuit)"
	voidsuit_type = /obj/item/clothing/suit/space/void/medical
	voidhelmet_type = /obj/item/clothing/head/helmet/space/void/medical
	refit = TRUE
	req_one_access = list(access_medical)

/datum/gear_disp/voidsuit/station/atmos
	name = "Atmos Technician (Voidsuit)"
	voidsuit_type = /obj/item/clothing/suit/space/void/atmos
	voidhelmet_type = /obj/item/clothing/head/helmet/space/void/atmos
	refit = TRUE
	req_one_access = list(access_atmospherics)

/datum/gear_disp/voidsuit/station/paramedic
	name = "Paramedic (Voidsuit)"
	voidsuit_type = /obj/item/clothing/suit/space/void/medical/emt
	voidhelmet_type = /obj/item/clothing/head/helmet/space/void/medical/emt
	refit = TRUE
	req_one_access = list(access_medical) // we don't have separate paramedic access

/datum/gear_disp/voidsuit/station/mining
	name = "Mining (Voidsuit)"
	voidsuit_type = /obj/item/clothing/suit/space/void/mining
	voidhelmet_type = /obj/item/clothing/head/helmet/space/void/mining
	refit = TRUE
	req_one_access = list(access_mining)

/obj/machinery/gear_dispenser/suit/station
	name = "Station Suit Dispenser"
	desc = "An industrial U-Tak-It Dispenser unit designed to fetch all kinds of space suits. This one is specialised towards station workers."
	dispenses = list(
		/datum/gear_disp/station/standard,
		/datum/gear_disp/voidsuit/station/security,
		/datum/gear_disp/voidsuit/station/engineering,
		/datum/gear_disp/voidsuit/station/medical,
		/datum/gear_disp/voidsuit/station/atmos,
		/datum/gear_disp/voidsuit/station/paramedic
	)

////////////////////////////// SOFT SUIT DISPENSERS ///////////////////////////
/obj/machinery/gear_dispenser/suit/standard
	name = "Soft Suit Dispenser"
	desc = "An industrial U-Tak-It Dispenser unit designed to fetch a specific mass produced suit."
	dispenser_flags = GD_ONEITEM|GD_NOGREED|GD_UNLIMITED
	one_setting = /datum/gear_disp/station/standard

////////////////////////////// AUTOLOK SUIT DISPENSERS ///////////////////////////
/datum/gear_disp/voidsuit/autolok
	name = "AutoLok Voidsuit"
	voidsuit_type = /obj/item/clothing/suit/space/void/autolok
	refit = FALSE // it autofits

/obj/machinery/gear_dispenser/suit/autolok
	name = "AutoLok Suit Dispenser"
	desc = "An industrial U-Tak-It Dispenser unit designed to fetch a specific AutoLok mass produced suit."
	icon_state = "suitdispenserAL"
	dispenser_flags = GD_ONEITEM|GD_NOGREED|GD_UNLIMITED
	one_setting = /datum/gear_disp/voidsuit/autolok

#undef GD_BUSY
#undef GD_ONEITEM
#undef GD_NOGREED
#undef GD_UNLIMITED
