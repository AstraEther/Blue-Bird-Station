///////////////////// Mob Living /////////////////////
/mob/living
	var/showvoreprefs = TRUE			// Determines if the mechanical vore preferences button will be displayed on the mob or not.
	var/list/temp_language_sources = list()	//VOREStation Addition - Absorbs add languages to the pred
	var/list/temp_languages = list()		//VOREStation Addition - Absorbs add languages to the pred
	var/prey_controlled = FALSE			//VOREStation Addition
	var/weight = 137					// Weight for mobs for weightgain system
	var/weight_gain = 1 				// How fast you gain weight
	var/weight_loss = 0.5 				// How fast you lose weight
	var/vore_egg_type = "egg" 			// Default egg type.
	var/feral = 0 						// How feral the mob is, if at all. Does nothing for non xenochimera at the moment.
	var/revive_ready = REVIVING_READY	// Only used for creatures that have the xenochimera regen ability, so far.
	var/revive_finished = 0				// Only used for xenochimera regen, allows us to find out when the regen will finish.
	var/metabolism = 0.0015
	var/no_vore = FALSE					// If the character/mob can vore.
	var/restrict_vore_ventcrawl = FALSE // Self explanatory
	var/absorbing_prey = 0 				// Determines if the person is using the succubus drain or not. See station_special_abilities_vr.
	var/drain_finalized = 0				// Determines if the succubus drain will be KO'd/absorbed. Can be toggled on at any time.
	var/fuzzy = 0						// Preference toggle for sharp/fuzzy icon.
//	var/voice_freq = 0					// Preference for character voice frequency		CHOMPEdit - Moved to modular_chomp/code/modules/mob/mob.dm
//	var/list/voice_sounds_list = list()	// The sound list containing our voice sounds!	CHOMPEdit - Moved to modular_chomp/code/modules/mob/mob.dm
	var/next_preyloop					// For Fancy sound internal loop
	var/stuffing_feeder = FALSE			// Can feed foods to others whole, like trash eater can eat them on their own.
	var/adminbus_trash = FALSE			// For abusing trash eater for event shenanigans.
	var/adminbus_eat_minerals = FALSE	// This creature subsists on a diet of pure adminium.
	var/vis_height = 32					// Sprite height used for resize features.
	var/appendage_color = "#e03997" //Default pink. Used for the 'long_vore' trait.
	var/appendage_alt_setting = FALSE	// Dictates if 'long_vore' user pulls prey to them or not. 1 = user thrown towards target.
	var/digestion_in_progress = FALSE	// CHOMPEdit: Gradual corpse gurgles
	var/regen_sounds = list(
		'sound/effects/mob_effects/xenochimera/regen_1.ogg',
		'sound/effects/mob_effects/xenochimera/regen_2.ogg',
		'sound/effects/mob_effects/xenochimera/regen_4.ogg',
		'sound/effects/mob_effects/xenochimera/regen_3.ogg',
		'sound/effects/mob_effects/xenochimera/regen_5.ogg'
	)
	var/trash_catching = FALSE				//Toggle for trash throw vore from chompstation
	var/list/trait_injection_reagents = list()	//List of all the reagents allowed to be used for injection via venom bite
	var/trait_injection_selected = null			//RSEdit: What trait reagent you're injecting.
	var/trait_injection_amount = 5				//RSEdit: How much you're injecting with traits.
	var/trait_injection_verb = "bites"			//RSEdit: Which fluffy manner you're doing the injecting.

//
// Hook for generic creation of stuff on new creatures
//
/hook/living_new/proc/vore_setup(mob/living/M)

	//Tries to load prefs if a client is present otherwise gives freebie stomach
	spawn(2 SECONDS)
		if(!QDELETED(M))
			M.init_vore()

	//return TRUE to hook-caller
	return TRUE

/mob/proc/init_vore()
	//Something else made organs, meanwhile.
	if(!isnewplayer(src))
		AddElement(/datum/element/slosh) // CHOMPEdit - Sloshy element
	if(LAZYLEN(vore_organs))
		/* // Outpost 21 edit - Nif removal
		//CHOMPAdd Start
		if(!soulgem)
			soulgem = new(src)
		//CHOMPAdd End
		*/
		return TRUE

	//We'll load our client's organs if we have one
	if(client && client.prefs_vr)
		if(!copy_from_prefs_vr())
			to_chat(src,span_warning("ERROR: You seem to have saved VOREStation prefs, but they couldn't be loaded."))
			return FALSE
		if(LAZYLEN(vore_organs))
			vore_selected = vore_organs[1]
			return TRUE

	//Or, we can create a basic one for them
	if(!LAZYLEN(vore_organs) && isliving(src))
		LAZYINITLIST(vore_organs)
		var/obj/belly/B = new /obj/belly(src)
		vore_selected = B
		B.immutable = TRUE
		B.name = "Stomach"
		B.desc = "It appears to be rather warm and wet. Makes sense, considering it's inside \the [name]."
		B.can_taste = TRUE
		if(ishuman(src))
			var/mob/living/carbon/human/H = src
			if(istype(H.species,/datum/species/monkey))
				allow_spontaneous_tf = TRUE
		/* // Outpost 21 edit - Nif removal
		//CHOMPAdd Start
		if(!soulgem)
			soulgem = new(src)
		return TRUE
		//CHOMPAdd End
		*/

/mob/living/init_vore()
	if(no_vore)
		return FALSE
	return ..()

//
// Hide vore organs in contents
//
///mob/living/view_variables_filter_contents(list/L)
//	. = ..()
//	var/len_before = L.len
//	L -= vore_organs
//	. += len_before - L.len
//
//
// Handle being clicked, perhaps with something to devour
//
/mob/living/proc/vore_attackby(obj/item/I, mob/user)
	//Handle case: /obj/item/grab
	if(istype(I, /obj/item/grab))
		var/obj/item/grab/G = I
		var/mob/living/carbon/victim = G.affecting

		//Has to be aggressive grab, has to be living click-er and non-silicon grabbed
		if(G.state >= GRAB_AGGRESSIVE && (isliving(user) && !issilicon(G.affecting)))
			var/mob/living/attacker = user  // Typecast to living

			// src is the mob clicked on and attempted predator

			///// If user clicked on themselves
			if(src == G.assailant && is_vore_predator(src))
				if(istype(victim) && !victim.client && !victim.ai_holder)
					log_and_message_admins("[key_name_admin(src)] attempted to eat [key_name_admin(G.affecting)] whilst they were AFK ([G.affecting ? ADMIN_JMP(G.affecting) : "null"])")
				if(feed_grabbed_to_self(src, G.affecting))
					qdel(G)
					return TRUE
				else
					log_debug("[attacker] attempted to feed [G.affecting] to [user] ([user.type]) but it failed.")

			///// If user clicked on their grabbed target
			else if((src == G.affecting) && (attacker.a_intent == I_GRAB) && (attacker.zone_sel.selecting == BP_TORSO) && (is_vore_predator(G.affecting)))
				if(istype(victim) && !victim.client && !victim.ai_holder) //Check whether the victim is: A carbon mob, has no client, but has a ckey. This should indicate an SSD player.
					log_and_message_admins("[key_name_admin(attacker)] attempted to force feed themselves to [key_name_admin(G.affecting)] whilst they were AFK ([G.affecting ? ADMIN_JMP(G.affecting) : "null"])")
				if(!G.affecting.feeding)
					to_chat(user, span_vnotice("[G.affecting] isn't willing to be fed."))
					log_and_message_admins("[key_name_admin(src)] attempted to feed themselves to [key_name_admin(G.affecting)] against their prefs ([G.affecting ? ADMIN_JMP(G.affecting) : "null"])")
					return FALSE

				if(attacker.feed_self_to_grabbed(attacker, G.affecting))
					qdel(G)
					return TRUE
				else
					log_debug("[attacker] attempted to feed [user] to [G.affecting] ([G.affecting ? G.affecting.type : "null"]) but it failed.")

			///// If user clicked on anyone else but their grabbed target
			else if((src != G.affecting) && (src != G.assailant) && (is_vore_predator(src)))
				if(istype(victim) && !victim.client && !victim.ai_holder)
					log_and_message_admins("[key_name_admin(attacker)] attempted to feed [key_name_admin(G.affecting)] to [key_name_admin(src)] whilst [key_name_admin(G.affecting)] was AFK ([G.affecting ? ADMIN_JMP(G.affecting) : "null"])")
				var/mob/living/carbon/victim_fed = src
				if(istype(victim_fed) && !victim_fed.client && !victim_fed.ai_holder)
					log_and_message_admins("[key_name_admin(attacker)] attempted to feed [key_name_admin(G.affecting)] to [key_name_admin(src)] whilst [key_name_admin(src)] was AFK ([G.affecting ? ADMIN_JMP(G.affecting) : "null"])")

				if(!feeding)
					to_chat(user, span_vnotice("[src] isn't willing to be fed."))
					log_and_message_admins("[key_name_admin(attacker)] attempted to feed [key_name_admin(G.affecting)] to [key_name_admin(src)] against predator's prefs ([src ? ADMIN_JMP(src) : "null"])")
					return FALSE
				if(!(G.affecting.devourable))
					to_chat(user, span_vnotice("[G.affecting] isn't able to be devoured."))
					log_and_message_admins("[key_name_admin(attacker)] attempted to feed [key_name_admin(G.affecting)] to [key_name_admin(src)] against prey's prefs ([G.affecting ? ADMIN_JMP(G.affecting) : "null"])")
					return FALSE
				if(attacker.feed_grabbed_to_other(attacker, G.affecting, src))
					qdel(G)
					return TRUE
				else
					log_debug("[attacker] attempted to feed [G.affecting] to [src] ([type]) but it failed.")

	//Handle case: /obj/item/holder
	else if(istype(I, /obj/item/holder))
		var/obj/item/holder/H = I

		if(!isliving(user))
			return FALSE // return FALSE to continue upper procs

		var/mob/living/attacker = user  // Typecast to living
		if(is_vore_predator(src))
			for(var/mob/living/M in H.contents)
				if(attacker.eat_held_mob(attacker, M, src))
					return TRUE //return TRUE to exit upper procs
		else
			log_debug("[attacker] attempted to feed [H.contents] to [src] ([type]) but it failed.")

	//Handle case: /obj/item/radio/beacon
	else if(istype(I,/obj/item/radio/beacon))
		var/confirm = tgui_alert(user, "[src == user ? "Eat the beacon?" : "Feed the beacon to [src]?"]", "Confirmation", list("Yes!", "Cancel"))
		if(confirm == "Yes!")
			var/obj/belly/B = tgui_input_list(user, "Which belly?", "Select A Belly", vore_organs) //ChompEDIT - user, not usr
			if(!istype(B))
				return TRUE
			visible_message(span_warning("[user] is trying to stuff a beacon into [src]'s [lowertext(B.name)]!"),
				span_warning("[user] is trying to stuff a beacon into you!"))
			if(do_after(user,30,src))
				user.drop_item()
				I.forceMove(B)
				return TRUE
			else
				return TRUE //You don't get to hit someone 'later'

	return FALSE

//
// Our custom resist catches for /mob/living
//
/mob/living/proc/vore_process_resist()
	//Are we resisting from inside a belly?
	// if(isbelly(loc))
	// 	var/obj/belly/B = loc
	// 	B.relay_resist(src)
	// 	return TRUE //resist() on living does this TRUE thing.
	// Note: This is no longer required, as the refactors to resisting allow bellies to just define container_resist

	//Other overridden resists go here
	return FALSE

//
//	Verb for saving vore preferences to save file
//
/mob/proc/save_vore_prefs()
	if(!client || !client.prefs_vr)
		return FALSE
	if(!copy_to_prefs_vr())
		return FALSE
	if(!client.prefs_vr.save_vore())
		return FALSE

	return TRUE

/mob/proc/apply_vore_prefs()
	if(!client || !client.prefs_vr)
		return FALSE
	if(!client.prefs_vr.load_vore())
		return FALSE
	if(!copy_from_prefs_vr())
		return FALSE

	return TRUE

/mob/proc/copy_to_prefs_vr()
	if(!client || !client.prefs_vr)
		to_chat(src,span_warning("You attempted to save your vore prefs but somehow you're in this character without a client.prefs_vr variable. Tell a dev."))
		return FALSE

	var/datum/vore_preferences/P = client.prefs_vr

	P.digestable = src.digestable
	P.devourable = src.devourable
	P.feeding = src.feeding
	P.absorbable = src.absorbable
	P.resizable = src.resizable
	P.digest_leave_remains = src.digest_leave_remains
	P.allowmobvore = src.allowmobvore
	P.vore_taste = src.vore_taste
	P.vore_smell = src.vore_smell
	P.permit_healbelly = src.permit_healbelly
	P.noisy = src.noisy
	P.selective_preference = src.selective_preference
	P.show_vore_fx = src.show_vore_fx
	P.can_be_drop_prey = src.can_be_drop_prey
	P.can_be_drop_pred = src.can_be_drop_pred
	P.allow_spontaneous_tf = src.allow_spontaneous_tf
	P.step_mechanics_pref = src.step_mechanics_pref
	P.pickup_pref = src.pickup_pref
	P.drop_vore = src.drop_vore
	P.slip_vore = src.slip_vore
	P.throw_vore = src.throw_vore
	P.food_vore = src.food_vore
	P.digest_pain = src.digest_pain
	P.stumble_vore = src.stumble_vore
	P.eating_privacy_global = src.eating_privacy_global
	P.allow_mimicry = src.allow_mimicry

	P.nutrition_message_visible = src.nutrition_message_visible
	P.nutrition_messages = src.nutrition_messages
	P.weight_message_visible = src.weight_message_visible
	P.weight_messages = src.weight_messages
	P.vore_sprite_color = src.vore_sprite_color // CHOMPEdit
	P.allow_mind_transfer = src.allow_mind_transfer

	//CHOMP stuff Start
	P.phase_vore = src.phase_vore
	P.noisy_full = src.noisy_full
	P.latejoin_vore = src.latejoin_vore
	P.latejoin_prey = src.latejoin_prey
	P.receive_reagents = src.receive_reagents
	P.give_reagents = src.give_reagents
	P.apply_reagents = src.apply_reagents
	P.autotransferable = src.autotransferable
	P.strip_pref = src.strip_pref
	P.vore_sprite_multiply = src.vore_sprite_multiply
	P.no_latejoin_vore_warning = src.no_latejoin_vore_warning
	P.no_latejoin_prey_warning = src.no_latejoin_prey_warning
	P.no_latejoin_vore_warning_time = src.no_latejoin_vore_warning_time
	P.no_latejoin_prey_warning_time = src.no_latejoin_prey_warning_time
	P.no_latejoin_vore_warning_persists = src.no_latejoin_vore_warning_persists
	P.no_latejoin_prey_warning_persists = src.no_latejoin_prey_warning_persists
	P.belly_rub_target = src.belly_rub_target
	P.soulcatcher_pref_flags = src.soulcatcher_pref_flags
	//CHOMP Stuff End

	var/list/serialized = list()
	for(var/obj/belly/B as anything in src.vore_organs)
		serialized += list(B.serialize()) //Can't add a list as an object to another list in Byond. Thanks.

	P.belly_prefs = serialized

	// P.soulcatcher_prefs = src.soulgem.serialize() // CHOMPAdd // Outpost 21 edit - Nif removal
	return TRUE

//
//	Proc for applying vore preferences, given bellies
//
/mob/proc/copy_from_prefs_vr(var/bellies = TRUE, var/full_vorgans = FALSE) //CHOMPedit: full_vorgans var to bypass 1-belly load optimization.
	if(!client || !client.prefs_vr)
		to_chat(src,span_warning("You attempted to apply your vore prefs but somehow you're in this character without a client.prefs_vr variable. Tell a dev."))
		return FALSE

	var/datum/vore_preferences/P = client.prefs_vr

	digestable = P.digestable
	devourable = P.devourable
	feeding = P.feeding
	absorbable = P.absorbable
	resizable = P.resizable
	digest_leave_remains = P.digest_leave_remains
	allowmobvore = P.allowmobvore
	vore_taste = P.vore_taste
	vore_smell = P.vore_smell
	permit_healbelly = P.permit_healbelly
	selective_preference = P.selective_preference
	noisy = P.noisy
	show_vore_fx = P.show_vore_fx
	can_be_drop_prey = P.can_be_drop_prey
	can_be_drop_pred = P.can_be_drop_pred
//	allow_inbelly_spawning = P.allow_inbelly_spawning //CHOMP Removal: we have vore spawning at home. Actually if this were to be enabled, it would break anyway. Just leaving this here as a reference to it.
	allow_spontaneous_tf = P.allow_spontaneous_tf
	step_mechanics_pref = P.step_mechanics_pref
	pickup_pref = P.pickup_pref
	drop_vore = P.drop_vore
	slip_vore = P.slip_vore
	throw_vore = P.throw_vore
	stumble_vore = P.stumble_vore
	food_vore = P.food_vore
	digest_pain = P.digest_pain
	eating_privacy_global = P.eating_privacy_global
	allow_mimicry = P.allow_mimicry

	nutrition_message_visible = P.nutrition_message_visible
	nutrition_messages = P.nutrition_messages
	weight_message_visible = P.weight_message_visible
	weight_messages = P.weight_messages
	vore_sprite_color = P.vore_sprite_color //CHOMPEdit
	allow_mind_transfer = P.allow_mind_transfer

	//CHOMP stuff
	phase_vore = P.phase_vore
	noisy_full = P.noisy_full
	latejoin_vore = P.latejoin_vore
	latejoin_prey = P.latejoin_prey
	receive_reagents = P.receive_reagents
	give_reagents = P.give_reagents
	apply_reagents = P.apply_reagents
	autotransferable = P.autotransferable
	strip_pref = P.strip_pref
	vore_sprite_multiply = P.vore_sprite_multiply
	no_latejoin_vore_warning = P.no_latejoin_vore_warning
	no_latejoin_prey_warning = P.no_latejoin_prey_warning
	no_latejoin_vore_warning_time = P.no_latejoin_vore_warning_time
	no_latejoin_prey_warning_time = P.no_latejoin_prey_warning_time
	no_latejoin_vore_warning_persists = P.no_latejoin_vore_warning_persists
	no_latejoin_prey_warning_persists = P.no_latejoin_prey_warning_persists
	belly_rub_target = P.belly_rub_target
	soulcatcher_pref_flags = P.soulcatcher_pref_flags

	if(bellies)
		if(isliving(src))
			var/mob/living/L = src
			L.release_vore_contents(silent = TRUE)
		QDEL_LIST(vore_organs) // CHOMPedit
		for(var/entry in P.belly_prefs)
			list_to_object(entry,src)
		if(!vore_organs.len)
			var/obj/belly/B = new /obj/belly(src)
			vore_selected = B
			B.immutable = TRUE
			B.name = "Stomach"
			B.desc = "It appears to be rather warm and wet. Makes sense, considering it's inside \the [name]."
			B.can_taste = TRUE
		else
			vore_selected = vore_organs[1]

		/* Outpost 21 edit - Nif removal
		//CHOMPAdd Start
		if(soulgem)
			src.soulgem.release_mobs()
			QDEL_NULL(soulgem)
		if(P.soulcatcher_prefs.len)
			soulgem = list_to_object(P.soulcatcher_prefs, src)
		else
			soulgem = new(src)
		//CHMPAdd End
		*/

	return TRUE

/mob/proc/load_vore_prefs_from_slot()

	var/datum/preferences/P = client.prefs

	var/remembered_default = P.load_vore_prefs_from_client(src) //Loads the preferences of a chosen slot
	if(!remembered_default)
		return

	apply_vore_prefs() //Applies the vore preferences of said slot

	if(remembered_default)
		P.return_to_character_slot(src, remembered_default) //sets you back to the original default slot

	return TRUE


/datum/preferences/proc/load_vore_prefs_from_client(mob/user)
	if(selecting_slots)
		to_chat(user, span_warning("You already have a slot selection dialog open!"))
		return
	if(!savefile)
		return

	var/list/charlist = list()

	var/default
	for(var/i in 1 to CONFIG_GET(number/character_slots))
		var/list/save_data = savefile.get_entry("character[i]", list())
		var/name = save_data["real_name"]
		var/nickname = save_data["nickname"]

		if(!name)
			name = "[i] - \[Unused Slot\]"
		else if(i == default_slot)
			name = "►[i] - [name]"
			default = "[name][nickname ? " ([nickname])" : ""]"
		else
			name = "[i] - [name]"

		charlist["[name][nickname ? " ([nickname])" : ""]"] = i

	var/remember_default = default_slot

	selecting_slots = TRUE
	var/choice = tgui_input_list(user, "Select a character to load:", "Load Slot", charlist, default)
	selecting_slots = FALSE
	if(!choice)
		return

	var/slotnum = charlist[choice]
	if(!slotnum)
		error("Player picked [choice] slot to load, but that wasn't one we sent.")
		return

	load_character(slotnum)
	attempt_vr(user.client?.prefs_vr,"load_vore","") //VOREStation Edit
	sanitize_preferences()

	return remember_default

/datum/preferences/proc/return_to_character_slot(mob/user, var/remembered_default)
	load_character(remembered_default)
	attempt_vr(user.client?.prefs_vr,"load_vore","") //VOREStation Edit
	sanitize_preferences()

//
// Release everything in every vore organ
//
/mob/living/proc/release_vore_contents(var/include_absorbed = TRUE, var/silent = FALSE)
	for(var/obj/belly/B as anything in vore_organs)
		B.release_all_contents(include_absorbed, silent)

//
// Returns examine messages for bellies
//
/mob/living/proc/examine_bellies()
	if(!show_pudge()) //Some clothing or equipment can hide this.
		return list()

	var/list/message_list = list()
	for(var/obj/belly/B as anything in vore_organs)
		var/bellymessage = B.get_examine_msg()
		if(bellymessage) message_list += bellymessage

		bellymessage = B.get_examine_msg_absorbed()
		if(bellymessage) message_list += bellymessage

	return message_list

//
// Whether or not people can see our belly messages
//
/mob/living/proc/show_pudge()
	return TRUE //Can override if you want.

/mob/living/carbon/human/show_pudge()
	//A uniform could hide it.
	if(istype(w_uniform,/obj/item/clothing))
		var/obj/item/clothing/under = w_uniform
		if(istype(under) && under.hides_bulges)
			return FALSE

	//We return as soon as we find one, no need for 'else' really.
	if(istype(wear_suit,/obj/item/clothing))
		var/obj/item/clothing/suit = wear_suit
		if(istype(suit) && suit.hides_bulges)
			return FALSE

	return ..()

//
// Clearly super important. Obviously.
//
/mob/living/proc/lick(mob/living/tasted in living_mobs_in_view(1, TRUE)) //CHOMPEdit
	set name = "Lick"
	set category = "IC.Game"
	set desc = "Lick someone nearby!"
	set popup_menu = FALSE // Stop licking by accident!

	if(!istype(tasted))
		return

	if(!checkClickCooldown() || incapacitated(INCAPACITATION_KNOCKOUT)) //CHOMPEdit
		return

	setClickCooldown(DEFAULT_ATTACK_COOLDOWN)
	if(tasted == src) //CHOMPEdit Start
		visible_message(span_vwarning("[src] licks themself!"),span_notice("You lick yourself. You taste rather like [tasted.get_taste_message()]."),span_infoplain(span_bold("Slurp!")))
		balloon_alert_visible("Licks themself!", "Tastes like [tasted.get_taste_message()]")
	else
		visible_message(span_vwarning("[src] licks [tasted]!"),span_notice("You lick [tasted]. They taste rather like [tasted.get_taste_message()]."),span_infoplain(span_bold("Slurp!")))
		balloon_alert_visible("Licks [tasted]!", "Tastes like [tasted.get_taste_message()]")
		//CHOMPEdit End


/mob/living/proc/get_taste_message(allow_generic = 1)
	if(!vore_taste && !allow_generic)
		return FALSE

	var/taste_message = ""
	if(vore_taste && (vore_taste != ""))
		taste_message += "[vore_taste]"
	else
		if(ishuman(src))
			var/mob/living/carbon/human/H = src
			taste_message += "a normal [H.custom_species ? H.custom_species : H.species.name]"
		else
			taste_message += "a plain old normal [src]"

	if(ishuman(src))
		var/mob/living/carbon/human/H = src
		if(H.touching.reagent_list.len) //Just the first one otherwise I'll go insane.
			var/datum/reagent/R = H.touching.reagent_list[1]
			taste_message += " You also get the flavor of [R.taste_description] from something on them"
	return taste_message



//This is just the above proc but switched about.
/mob/living/proc/smell(mob/living/smelled in living_mobs(1, TRUE)) //CHOMPEdit
	set name = "Smell"
	set category = "IC.Game"
	set desc = "Smell someone nearby!"
	set popup_menu = FALSE

	if(!istype(smelled))
		return
	if(!checkClickCooldown() || incapacitated(INCAPACITATION_KNOCKOUT)) //CHOMPEdit
		return

	setClickCooldown(DEFAULT_ATTACK_COOLDOWN)
	if(smelled == src) //CHOMPEdit Start
		visible_message(span_vwarning("[src] smells themself!"),span_notice("You smell yourself. You smell like [smelled.get_smell_message()]."),span_infoplain(span_bold("Sniff!")))
		balloon_alert_visible("Smells themself!", "Smells like [smelled.get_smell_message()]")
	else
		visible_message(span_vwarning("[src] smells [smelled]!"),span_notice("You smell [smelled]. They smell like [smelled.get_smell_message()]."),span_infoplain(span_bold("Sniff!")))
		balloon_alert_visible("Smells [smelled]!", "Smells like [smelled.get_smell_message()]")
		//CHOMPEdit End

/mob/living/proc/get_smell_message(allow_generic = 1)
	if(!vore_smell && !allow_generic)
		return FALSE

	var/smell_message = ""
	if(vore_smell && (vore_smell != ""))
		smell_message += "[vore_smell]"
	else
		if(ishuman(src))
			var/mob/living/carbon/human/H = src
			smell_message += "a normal [H.custom_species ? H.custom_species : H.species.name]"
		else
			smell_message += "a plain old normal [src]"

	return smell_message




//
// OOC Escape code for pref-breaking or AFK preds
//
/mob/living/proc/escapeOOC()
	set name = "OOC Escape"
	set category = "OOC.Vore"

	//You're in a belly!
	if(isbelly(loc))
		//You've been taken over by a morph
		if(istype(src, /mob/living/simple_mob/vore/morph/dominated_prey))
			var/mob/living/simple_mob/vore/morph/dominated_prey/s = src
			s.undo_prey_takeover(TRUE)
			return
		var/obj/belly/B = loc
		var/confirm = tgui_alert(src, "Please feel free to press use this button at any time you are uncomfortable and in a belly. Consent is important.", "Confirmation", list("Okay", "Cancel")) //CHOMPedit
		if(confirm != "Okay" || loc != B)
			return
		//Actual escaping
		absorbed = FALSE	//Make sure we're not absorbed
		muffled = FALSE		//Removes Muffling
		forceMove(get_turf(src)) //Just move me up to the turf, let's not cascade through bellies, there's been a problem, let's just leave.
		SetSleeping(0) //Wake up instantly if asleep
		for(var/mob/living/simple_mob/SA in range(10))
			LAZYSET(SA.prey_excludes, src, world.time)
		log_and_message_admins("[key_name(src)] used the OOC escape button to get out of [key_name(B.owner)] ([B.owner ? "<a href='?_src_=holder;[HrefToken()];adminplayerobservecoodjump=1;X=[B.owner.x];Y=[B.owner.y];Z=[B.owner.z]'>JMP</a>" : "null"])")

		B.owner.update_fullness() //CHOMPEdit - This is run whenever a belly's contents are changed.
		if(!ishuman(B.owner))
			B.owner.update_icons()

	//You're in a dogborg!
	else if(istype(loc, /obj/item/dogborg/sleeper))
		var/mob/living/silicon/pred = loc.loc //Thing holding the belly!
		var/obj/item/dogborg/sleeper/belly = loc //The belly!

		var/confirm = tgui_alert(src, "You're in a cyborg sleeper. This is for escaping from preference-breaking or if your predator disconnects/AFKs. If your preferences were being broken, please admin-help as well.", "Confirmation", list("Okay", "Cancel"))
		if(confirm != "Okay" || loc != belly)
			return
		//Actual escaping
		log_and_message_admins("[key_name(src)] used the OOC escape button to get out of [key_name(pred)] (BORG) ([pred ? "<a href='?_src_=holder;[HrefToken()];adminplayerobservecoodjump=1;X=[pred.x];Y=[pred.y];Z=[pred.z]'>JMP</a>" : "null"])")
		belly.go_out(src) //Just force-ejects from the borg as if they'd clicked the eject button.

	//You're in an AI hologram!
	else if(istype(loc, /obj/effect/overlay/aiholo))
		var/obj/effect/overlay/aiholo/holo = loc
		holo.drop_prey() //Easiest way
		log_and_message_admins("[key_name(src)] used the OOC escape button to get out of [key_name(holo.master)] (AI HOLO) ([holo ? "<a href='?_src_=holder;[HrefToken()];adminplayerobservecoodjump=1;X=[holo.x];Y=[holo.y];Z=[holo.z]'>JMP</a>" : "null"])")

	//You're in a capture crystal! ((It's not vore but close enough!))
	else if(iscapturecrystal(loc))
		var/obj/item/capture_crystal/crystal = loc
		crystal.unleash()
		crystal.bound_mob = null
		crystal.bound_mob = capture_crystal = 0
		clear_fullscreen(ATOM_BELLY_FULLSCREEN) // CHOMPedit
		log_and_message_admins("[key_name(src)] used the OOC escape button to get out of [crystal] owned by [crystal.owner]. [ADMIN_FLW(src)]")

	//You've been turned into an item!
	else if(tf_mob_holder && istype(src, /mob/living/voice) && istype(src.loc, /obj/item))
		var/obj/item/item_to_destroy = src.loc //If so, let's destroy the item they just TF'd out of.
		//CHOMPEdit Start - If tf_mob_holder is not located in src, then it's a Mind Binder OOC Escape
		var/mob/living/ourmob = tf_mob_holder
		if(ourmob.loc != src)
			if(isnull(ourmob.loc))
				to_chat(src,span_notice("You have no body."))
				src.tf_mob_holder = null
				return
			if(ourmob.ckey)
				to_chat(src,span_notice("Your body appears to be in someone else's control."))
				return
			src.mind.transfer_to(ourmob)
			item_to_destroy.possessed_voice -= src
			qdel(src)
			log_and_message_admins("[key_name(src)] used the OOC escape button to revert back to their original form from being TFed into an object.")
			return
		//CHOMPEdit End
		if(istype(src.loc, /obj/item/clothing)) //Are they in clothes? Delete the item then revert them.
			qdel(item_to_destroy)
			log_and_message_admins("[key_name(src)] used the OOC escape button to revert back to their original form from being TFed into an object.")
			revert_mob_tf()
		else //Are they in any other type of object? If qdel is done first, the mob is deleted from the world.
			forceMove(get_turf(src))
			qdel(item_to_destroy)
			log_and_message_admins("[key_name(src)] used the OOC escape button to revert back to their original form from being TFed into an object.")
			revert_mob_tf()

	//You've been turned into a mob!
	else if(tf_mob_holder)
		log_and_message_admins("[key_name(src)] used the OOC escape button to revert back to their original form from being TFed into another mob.")
		revert_mob_tf()

	else if(istype(loc, /obj/item/holder/micro) && (istype(loc.loc, /obj/machinery/microwave)))
		forceMove(get_turf(src))
		log_and_message_admins("[key_name(src)] used the OOC escape button to get out of a microwave.")

	else if(istype(loc, /obj/structure/gargoyle) && loc:was_rayed)
		var/obj/structure/gargoyle/G = loc
		G.can_revert = TRUE
		qdel(G)
		log_and_message_admins("[key_name(src)] used the OOC escape button to revert back from being petrified.")

	//CHOMPEdit - In-shoe OOC escape. Checking voices as precaution if something akin to obj TF or possession happens
	else if(!istype(src, /mob/living/voice) && istype(src.loc, /obj/item/clothing/shoes))
		var/obj/item/clothing/shoes/S = src.loc
		forceMove(get_turf(src))
		log_and_message_admins("[key_name(src)] used the OOC escape button to escape from of a pair of shoes. [ADMIN_FLW(src)] - Shoes [ADMIN_VV(S)]")

	//You are in food and for some reason can't resist out
	else if(istype(loc, /obj/item/reagent_containers/food))
		var/obj/item/reagent_containers/food/F = src.loc
		if(F.food_inserted_micros)
			F.food_inserted_micros -= src
		src.forceMove(get_turf(F))
		log_and_message_admins("[key_name(src)] used the OOC escape button to get out of a food item.")

	//Don't appear to be in a vore situation
	else
		to_chat(src,span_warning("You aren't inside anyone, though, is the thing."))

//
// Eating procs depending on who clicked what
//

//CHOMPAdd Start
/mob/living/proc/feedable_bellies()
	var/list/bellies = list()
	for(var/obj/belly/Y in src.vore_organs)
		if(Y.is_feedable)
			bellies += Y
	return bellies
//CHOMPAdd End

/mob/living/proc/feed_grabbed_to_self(mob/living/user, mob/living/prey)
	var/belly = user.vore_selected
	return perform_the_nom(user, prey, user, belly)

/mob/living/proc/eat_held_mob(mob/living/user, mob/living/prey, mob/living/pred)
	var/belly
	if(user != pred)
		belly = tgui_input_list(user, "Choose Belly", "Belly Choice", pred.feedable_bellies())	//CHOMPEdit remove usr
	else
		belly = pred.vore_selected
	return perform_the_nom(user, prey, pred, belly)

/mob/living/proc/feed_self_to_grabbed(mob/living/user, mob/living/pred)
	var/belly = tgui_input_list(user, "Choose Belly", "Belly Choice", pred.feedable_bellies())	//CHOMPEdit - remove usr
	return perform_the_nom(user, user, pred, belly)

/mob/living/proc/feed_grabbed_to_other(mob/living/user, mob/living/prey, mob/living/pred)
	var/belly = tgui_input_list(user, "Choose Belly", "Belly Choice", pred.feedable_bellies())	//CHOMPEdit - remove usr
	return perform_the_nom(user, prey, pred, belly)

//
// Master vore proc that actually does vore procedures
//
/mob/living/proc/perform_the_nom(mob/living/user, mob/living/prey, mob/living/pred, obj/belly/belly, delay)
	//Sanity
	if(!user || !prey || !pred || !istype(belly) || !(belly in pred.vore_organs))
		log_debug("[user] attempted to feed [prey] to [pred], via [belly ? lowertext(belly.name) : "*null*"] but it went wrong.")
		return FALSE
	if(pred == prey)
		return FALSE

	// The belly selected at the time of noms
	var/attempt_msg = "ERROR: Vore message couldn't be created. Notify a dev. (at)"
	var/success_msg = "ERROR: Vore message couldn't be created. Notify a dev. (sc)"

	//Final distance check. Time has passed, menus have come and gone. Can't use do_after adjacent because doesn't behave for held micros
	var/user_to_pred = get_dist(get_turf(user),get_turf(pred))
	var/user_to_prey = get_dist(get_turf(user),get_turf(prey))

	if(user_to_pred > 1 || user_to_prey > 1)
		return FALSE

	if(!prey.devourable)
		to_chat(user, span_vnotice("They aren't able to be devoured."))
		log_and_message_admins("[key_name_admin(src)] attempted to devour [key_name_admin(prey)] against their prefs ([prey ? ADMIN_JMP(prey) : "null"])")
		return FALSE
	if(prey.absorbed || pred.absorbed)
		to_chat(user, span_vwarning("They aren't aren't in a state to be devoured."))
		return FALSE

	//Determining vore attempt privacy
	var/message_range = world.view
	if(!pred.is_slipping && !prey.is_slipping) //We only care about privacy preference if it's NOT a spontaneous vore.
		switch(belly.eating_privacy_local) //if("loud") case not added, as it would not modify message_range
			if("default")
				if(pred.eating_privacy_global)
					message_range = 1
			if("subtle")
				message_range = 1



	// Slipnoms from chompstation downstream, credit to cadyn for the original PR.
	// Prepare messages
	if(prey.is_slipping)
		attempt_msg = span_vwarning("It seems like [prey] is about to slide into [pred]'s [lowertext(belly.name)]!")
		success_msg = span_vwarning("[prey] suddenly slides into [pred]'s [lowertext(belly.name)]!")
	else if(pred.is_slipping)
		attempt_msg = span_vwarning("It seems like [prey] is gonna end up inside [pred]'s [lowertext(belly.name)] as [pred] comes sliding over!")
		success_msg = span_vwarning("[prey] suddenly slips inside of [pred]'s [lowertext(belly.name)] as [pred] slides into them!")
	else if(user == pred) //Feeding someone to yourself
		attempt_msg = span_vwarning("[pred] is attempting to [lowertext(belly.vore_verb)] [prey] into their [lowertext(belly.name)]!")
		success_msg = span_vwarning("[pred] manages to [lowertext(belly.vore_verb)] [prey] into their [lowertext(belly.name)]!")
	else //Feeding someone to another person
		attempt_msg = span_vwarning("[user] is attempting to make [pred] [lowertext(belly.vore_verb)] [prey] into their [lowertext(belly.name)]!")
		success_msg = span_vwarning("[user] manages to make [pred] [lowertext(belly.vore_verb)] [prey] into their [lowertext(belly.name)]!")

	// Announce that we start the attempt!


	user.visible_message(attempt_msg, range = message_range)


	// Now give the prey time to escape... return if they did
	var/swallow_time
	if(delay)
		swallow_time = delay
	else
		swallow_time = istype(prey, /mob/living/carbon/human) ? belly.human_prey_swallow_time : belly.nonhuman_prey_swallow_time

	// Their AI should get notified so they can stab us
	prey.ai_holder?.react_to_attack(user)

	//Timer and progress bar
	if(!user.client && prey.weakened > 0) // CHOMPEdit stop crwaling instantly break swallow attempt for mobvore
		prey.Stun(min(prey.weakened, 2)) // CHOMPEdit stop crwaling instantly break swallow attempt for mobvore
	if(!do_after(user, swallow_time, prey, exclusive = TASK_USER_EXCLUSIVE))
		return FALSE // Prey escpaed (or user disabled) before timer expired.

	// If we got this far, nom successful! Announce it!
	user.visible_message(success_msg, range = message_range)

	// Actually shove prey into the belly.
	if(istype(prey.loc, /obj/item/holder))
		var/obj/item/holder/H = prey.loc
		for(var/mob/living/M in H.contents)
			belly.nom_mob(M, user)
			if(M.loc == H) // In case nom_mob failed somehow.
				M.forceMove(get_turf(src))
		H.held_mob = null
		qdel(H)
	else
		belly.nom_mob(prey, user)

	user.update_icon()

	var/mob/living/carbon/victim = prey // Check for afk vore
	if(istype(victim) && !victim.client && !victim.ai_holder && victim.ckey)
		log_and_message_admins("[key_name_admin(pred)] ate [key_name_admin(prey)] whilst the prey was AFK ([pred ? ADMIN_JMP(pred) : "null"])")
	var/mob/living/carbon/victim_pred = pred // Check for afk vore
	if(istype(victim_pred) && !victim_pred.client && !victim_pred.ai_holder && victim_pred.ckey)
		log_and_message_admins("[key_name_admin(pred)] ate [key_name_admin(prey)] whilst the pred was AFK ([pred ? ADMIN_JMP(pred) : "null"])")

	// Inform Admins
	if(pred == user)
		add_attack_logs(pred, prey, "Eaten via [belly.name]")
	else
		add_attack_logs(user, pred, "Forced to eat [key_name(prey)]")
	return TRUE

//
// Magical pred-air breathing for inside preds
// overrides a proc defined on atom called by breathe.dm
//
/obj/belly/return_air()
	return return_air_for_internal_lifeform()

/obj/belly/return_air_for_internal_lifeform(var/mob/living/lifeform)
	//Free air until someone wants to code processing it for reals from predbreaths
	var/air_type = /datum/gas_mixture/belly_air
	if(istype(lifeform))	// If this doesn't succeed, then 'lifeform' is actually a bag or capture crystal with someone inside
		air_type = lifeform.get_perfect_belly_air_type()		// Without any overrides/changes, its gonna be /datum/gas_mixture/belly_air
	var/air = new air_type(1000)
	return air

/mob/living/proc/get_perfect_belly_air_type()
	return /datum/gas_mixture/belly_air

/mob/living/carbon/human/get_perfect_belly_air_type()
	if(species)
		return species.get_perfect_belly_air_type()
	return ..()

// This is about 0.896m^3 of atmosphere
/datum/gas_mixture/belly_air
    volume = 2500
    temperature = 293.150
    total_moles = 104

/datum/gas_mixture/belly_air/New()
    . = ..()
    gas = list(
        "oxygen" = 21,
        "nitrogen" = 79)

/datum/gas_mixture/belly_air/vox
    volume = 2500
    temperature = 293.150
    total_moles = 104

/datum/gas_mixture/belly_air/vox/New()
    . = ..()
    gas = list(
        "phoron" = 100) // Outpost 21 edit - phoron vox are correct thankyou

/datum/gas_mixture/belly_air/zaddat
    volume = 2500
    temperature = 293.150
    total_moles = 300

/datum/gas_mixture/belly_air/zaddat/New()
    . = ..()
    gas = list(
        "oxygen" = 100)

/datum/gas_mixture/belly_air/nitrogen_breather
    volume = 2500
    temperature = 293.150
    total_moles = 104

/datum/gas_mixture/belly_air/nitrogen_breather/New()
    . = ..()
    gas = list(
        "nitrogen" = 100)


/mob/living/proc/feed_grabbed_to_self_falling_nom(var/mob/living/user, var/mob/living/prey)
	var/belly = user.vore_selected
	return perform_the_nom(user, prey, user, belly, delay = 1) //1/10th of a second is probably fine.

/mob/living/proc/glow_toggle()
	set name = "Glow (Toggle)"
	set category = "Abilities.General"
	set desc = "Toggle your glowing on/off!"

	//I don't really see a point to any sort of checking here.
	//If they're passed out, the light won't help them. Same with buckled. Really, I think it's fine to do this whenever.
	glow_toggle = !glow_toggle

	to_chat(src,span_notice("You " + span_bold("[glow_toggle ? "en" : "dis"]") + "able your body's glow."))

/mob/living/proc/glow_color()
	set name = "Glow (Set Color)"
	set category = "Abilities.Settings"
	set desc = "Pick a color for your body's glow."

	//Again, no real need for a check on this. I'm unsure how it could be somehow abused.
	//Even if they open the box 900 times, who cares, they get the wrong color and do it again.
	var/new_color = input(src,"Select a new color","Body Glow",glow_color) as color
	if(new_color)
		glow_color = new_color

/obj/item
	var/trash_eatable = TRUE

/mob/living/proc/get_digestion_nutrition_modifier()
	return 1

/mob/living/proc/get_digestion_efficiency_modifier()
	return 1

/mob/living/proc/eat_trash()
	set name = "Eat Trash"
	set category = "Abilities.Vore"
	set desc = "Consume held garbage."

	if(!vore_selected)
		to_chat(src,span_warning("You either don't have a belly selected, or don't have a belly!"))
		return

	var/obj/item/I = get_active_hand()
	if(!I)
		to_chat(src, span_notice("You are not holding anything."))
		return

	if(is_type_in_list(I,item_vore_blacklist) && !adminbus_trash) //If someone has adminbus, they can eat whatever they want.
		to_chat(src, span_warning("You are not allowed to eat this."))
		return

	if(!I.trash_eatable) //OOC pref. This /IS/ respected, even if adminbus_trash is enabled
		to_chat(src, span_warning("You can't eat that so casually!"))
		return

	if(istype(I, /obj/item/paicard))
		var/obj/item/paicard/palcard = I
		var/mob/living/silicon/pai/pocketpal = palcard.pai
		if(pocketpal && (!pocketpal.devourable))
			to_chat(src, span_warning("\The [pocketpal] doesn't allow you to eat it."))
			return

	if(istype(I, /obj/item/book))
		var/obj/item/book/book = I
		if(book.carved)
			to_chat(src, span_warning("\The [book] is not worth eating without the filling."))
			return

	if(is_type_in_list(I,edible_trash) | adminbus_trash || is_type_in_list(I,edible_tech) && isSynthetic()) //chompstation add synth check
		if(I.hidden_uplink)
			to_chat(src, span_warning("You really should not be eating this."))
			message_admins("[key_name(src)] has attempted to ingest an uplink item. ([src ? ADMIN_JMP(src) : "null"])")
			return
		if(istype(I,/obj/item/pda))
			var/obj/item/pda/P = I
			if(P.owner)
				var/watching = FALSE
				for(var/mob/living/carbon/human/H in view(src))
					if(H.real_name == P.owner && H.client)
						watching = TRUE
						break
				if(!watching)
					return
				else
					visible_message(span_warning("[src] is threatening to make [P] disappear!"))
					if(P.id)
						var/confirm = tgui_alert(src, "The PDA you're holding contains a vulnerable ID card. Will you risk it?", "Confirmation", list("Definitely", "Cancel"))
						if(confirm != "Definitely")
							return
					if(!do_after(src, 100, P))
						return
					visible_message(span_warning("[src] successfully makes [P] disappear!"))
			to_chat(src, span_notice("You can taste the sweet flavor of delicious technology."))
			drop_item()
			I.forceMove(vore_selected)
			updateVRPanel()
			return
		if(istype(I,/obj/item/clothing/shoes))
			var/obj/item/clothing/shoes/S = I
			if(S.holding)
				to_chat(src, span_warning("There's something inside!"))
				return
		if(iscapturecrystal(I))
			var/obj/item/capture_crystal/C = I
			if(!C.bound_mob.devourable)
				to_chat(src, span_warning("That doesn't seem like a good idea. (\The [C.bound_mob]'s prefs don't allow it.)"))
				return
		drop_item()
		I.forceMove(vore_selected)
		updateVRPanel()

		log_admin("VORE: [src] used Eat Trash to swallow [I].")

		if(istype(I,/obj/item/flashlight/flare) || istype(I,/obj/item/flame/match) || istype(I,/obj/item/storage/box/matches))
			to_chat(src, span_notice("You can taste the flavor of spicy cardboard."))
		else if(istype(I,/obj/item/flashlight/glowstick))
			to_chat(src, span_notice("You found out the glowy juice only tastes like regret."))
		else if(istype(I,/obj/item/trash/cigbutt))
			to_chat(src, span_notice("You can taste the flavor of bitter ash. Classy."))
		else if(istype(I,/obj/item/clothing/mask/smokable))
			var/obj/item/clothing/mask/smokable/C = I
			if(C.lit)
				to_chat(src, span_notice("You can taste the flavor of burning ash. Spicy!"))
			else
				to_chat(src, span_notice("You can taste the flavor of aromatic rolling paper and funny looks."))
		else if(istype(I,/obj/item/paper))
			to_chat(src, span_notice("You can taste the dry flavor of bureaucracy."))
		else if(istype(I,/obj/item/book))
			to_chat(src, span_notice("You can taste the dry flavor of knowledge."))
		else if(istype(I,/obj/item/dice)) //CHOMPedit: Removed roulette ball because that's not active here.
			to_chat(src, span_notice("You can taste the bitter flavor of cheating."))
		else if(istype(I,/obj/item/lipstick))
			to_chat(src, span_notice("You can taste the flavor of couture and style. Toddler at the make-up bag style."))
		else if(istype(I,/obj/item/soap))
			to_chat(src, span_notice("You can taste the bitter flavor of verbal purification."))
		else if(istype(I,/obj/item/spacecash) || istype(I,/obj/item/storage/wallet))
			to_chat(src, span_notice("You can taste the flavor of wealth and reckless waste."))
		else if(istype(I,/obj/item/broken_bottle) || istype(I,/obj/item/material/shard))
			to_chat(src, span_notice("You can taste the flavor of pain. This can't possibly be healthy for your guts."))
		else if(istype(I,/obj/item/light))
			var/obj/item/light/L = I
			if(L.status == LIGHT_BROKEN)
				to_chat(src, span_notice("You can taste the flavor of pain. This can't possibly be healthy for your guts."))
			else
				to_chat(src, span_notice("You can taste the flavor of really bad ideas."))
		else if(istype(I,/obj/item/bikehorn/tinytether))
			to_chat(src, span_notice("You feel a rush of power swallowing such a large, err, tiny structure."))
		else if(istype(I,/obj/item/mmi/digital/posibrain) || istype(I,/obj/item/aicard))
			to_chat(src, span_notice("You can taste the sweet flavor of digital friendship. Or maybe it is something else."))
		else if(istype(I,/obj/item/paicard))
			to_chat(src, span_notice("You can taste the sweet flavor of digital friendship."))
			var/obj/item/paicard/ourcard = I
			if(ourcard.pai && ourcard.pai.client && isbelly(ourcard.loc))
				var/obj/belly/B = ourcard.loc
				to_chat(ourcard.pai, span_boldnotice("[B.desc]"))
		else if(istype(I,/obj/item/reagent_containers/food))
			var/obj/item/reagent_containers/food/F = I
			if(!F.reagents.total_volume)
				to_chat(src, span_notice("You can taste the flavor of garbage and leftovers. Delicious?"))
			else
				to_chat(src, span_notice("You can taste the flavor of gluttonous waste of food."))
		else if (istype(I,/obj/item/clothing/accessory/collar))
			to_chat(src, span_notice("You can taste the submissiveness in the wearer of [I]!"))
		else if(iscapturecrystal(I))
			var/obj/item/capture_crystal/C = I
			if(C.bound_mob && (C.bound_mob in C.contents))
				if(isbelly(C.loc))
					//var/obj/belly/B = C.loc //CHOMPedit
					//to_chat(C.bound_mob, span_notice("Outside of your crystal, you can see; " + span_notice("[B.desc]"))) //CHOMPedit: moved to modular_chomp capture_crystal.dm
					to_chat(src, span_notice("You can taste the the power of command."))
		// CHOMPedit begin
		else if(istype(I,/obj/item/starcaster_news))
			to_chat(src, span_notice("You can taste the dry flavor of digital garbage, oh wait its just the news."))
		else if(istype(I,/obj/item/newspaper))
			to_chat(src, span_notice("You can taste the dry flavor of garbage, oh wait its just the news."))
		else if (istype(I,/obj/item/cell))
			visible_message(span_warning("[src] sates their electric appetite with a [I]!"))
			to_chat(src, span_notice("You can taste the spicy flavor of electrolytes, yum."))
		else if (istype(I,/obj/item/walkpod))
			visible_message(span_warning("[src] sates their musical appetite with a [I]!"))
			to_chat(src, span_notice("You can taste the jazzy flavor of music."))
		else if (istype(I,/obj/item/mail/junkmail))
			visible_message(span_warning("[src] devours the [I]!"))
			to_chat(src, span_notice("You can taste the flavor of the galactic postal service."))
		else if (istype(I,/obj/item/gun/energy/sizegun))
			visible_message(span_warning("[src] devours the [I]!"))
			to_chat(src, span_notice("You didn't read the warning label, did you?"))
		else if (istype(I,/obj/item/slow_sizegun))
			visible_message(span_warning("[src] devours the [I]!"))
			to_chat(src, span_notice("You taste the flavor of sunday driver bluespace."))
		else if (istype(I,/obj/item/laser_pointer))
			visible_message(span_warning("[src] devours the [I]!"))
			to_chat(src, span_notice("You taste the flavor of a laser."))
		else if (istype(I,/obj/item/canvas))
			visible_message(span_warning("[src] devours the [I]!"))
			to_chat(src, span_notice("You taste the flavor of priceless artwork."))
		//CHOMPedit end

		else
			to_chat(src, span_notice("You can taste the flavor of garbage. Delicious."))
		visible_message(span_vwarning("[src] demonstrates the voracious capabilities of their [lowertext(vore_selected.name)] by making [I] disappear!")) //CHOMPedit
		return
	to_chat(src, span_notice("This snack is too powerful to go down that easily.")) //CHOMPEdit
	return

/mob/living/proc/toggle_trash_catching() //Ported from chompstation
	set name = "Toggle Trash Catching"
	set category = "Abilities.Vore"
	set desc = "Toggle Trash Eater throw vore abilities."
	trash_catching = !trash_catching
	to_chat(src, span_vwarning("Trash catching [trash_catching ? "enabled" : "disabled"].")) //CHOMPEdit

/mob/living/proc/eat_minerals() //Actual eating abstracted so the user isn't given a prompt due to an argument in this verb.
	set name = "Eat Minerals"
	set category = "Abilities.Vore"
	set desc = "Consume held raw ore, gems and refined minerals. Snack time!"

	handle_eat_minerals()

/mob/living/proc/handle_eat_minerals(obj/item/snack, mob/living/user)
	var/mob/living/feeder = user ? user : src //Whoever's doing the feeding - us or someone else.
	var/mob/living/carbon/human/H = src
	if(!(adminbus_eat_minerals || (istype(H) && H.species.eat_minerals))) //Am I awesome enough to eat a shiny rock?
		return

	if(!vore_selected)
		to_chat(src, span_warning("You either don't have a belly selected, or don't have a belly!"))
		return

	var/obj/item/I = (snack ? snack : feeder.get_active_hand())
	if(!I)
		to_chat(feeder, span_notice("You look longingly at your empty hands, imagining if they held something edible..."))
		return

	if(!istype(I))
		to_chat(src, span_notice("You pause for a moment to examine [I] and realize it's not even worth the energy to chew."))
		return

	var/list/nom = null
	var/datum/material/M = null
	if(istype(I, /obj/item/ore)) //Raw unrefined ore. Some things are just better untempered!
		var/obj/item/ore/O = I
		//List in list, define by material property of ore in code/mining/modules/ore.dm.
		//50 nutrition = 5 ore to get 250 nutrition. 250 is the beginning of the 'well fed' range.
		var/list/rock_munch = list(
			MAT_URANIUM		= list("nutrition" = 30, "remark" = "Crunching [O] in your jaws almost makes you wince, a horribly tangy and sour flavour radiating through your mouth. It goes down all the same.", "WTF" = FALSE),
			"hematite"		= list("nutrition" = 15, "remark" = "The familiar texture and taste of [O] does the job but leaves little to the imagination and hardly sates your appetite.", "WTF" = FALSE),
			"carbon"		= list("nutrition" = 15, "remark" = "Utterly bitter, crunching down on [O] only makes you long for better things. But a snack's a snack...", "WTF" = FALSE),
			"marble"		= list("nutrition" = 40, "remark" = "A fitting dessert, the sweet and savoury [O] lingers on the palate and satisfies your hunger.", "WTF" = FALSE),
			"sand"			= list("nutrition" = 0,  "remark" = "You crunch on [O] but its texture is almost gag-inducing. Stifling a cough, you somehow manage to swallow both [O] and your regrets.", "WTF" = FALSE),
			MAT_PHORON		= list("nutrition" = 30, "remark" = "Crunching [O] to dust between your jaw you find pleasant, comforting warmth filling your mouth that briefly spreads down the throat to your chest as you swallow.", "WTF" = FALSE),
			MAT_SILVER		= list("nutrition" = 40, "remark" = "[O] tastes quite nice indeed as you munch on it. A little tarnished, but that's just fine aging.", "WTF" = FALSE),
			MAT_GOLD		= list("nutrition" = 40, "remark" = "You taste supreme richness that exceeds expectations and satisfies your hunger.", "WTF" = FALSE),
			MAT_DIAMOND		= list("nutrition" = 50, "remark" = "The heavenly taste of [O] almost brings a tear to your eye. Its glimmering gloriousness is even better on the tongue than you imagined, so you savour it fondly.", "WTF" = FALSE),
			"platinum"		= list("nutrition" = 40, "remark" = "A bit tangy but elegantly balanced with a long faintly sour finish. Delectable.", "WTF" = FALSE),
			MAT_METALHYDROGEN = list("nutrition" = 30, "remark" = "Quite sweet on the tongue, you savour the light and easy to chew [O], finishing it quickly.", "WTF" = FALSE),
			"rutile"		= list("nutrition" = 50, "remark" = "A little... angular, you savour the light but chewy [O], finishing it quickly.", "WTF" = FALSE),
			MAT_VERDANTIUM	= list("nutrition" = 50, "remark" = "You taste scientific mystery and a rare delicacy. Your tastebuds tingle pleasantly as you eat [O] and the feeling warmly blossoms in your chest for a moment.", "WTF" = FALSE),
			MAT_LEAD		= list("nutrition" = 40, "remark" = "It takes some work to break down [O] but you manage it, unlocking lasting tangy goodness in the process. Yum.", "WTF" = FALSE)
		)
		if(O.material in rock_munch)
			nom	= rock_munch[O.material]
			M 	= name_to_material[O.material]
		else if(istype(O, /obj/item/ore/slag))
			nom	= list("nutrition" = 15, "remark" = "You taste dusty, crunchy mistakes. This is a travesty... but at least it is an edible one.",  "WTF" = FALSE)
		else //Random rock.
			nom = list("nutrition" = 0,  "remark" = "You taste stony, gravelly goodness - but you crave something with actual nutritional value.", "WTF" = FALSE)

	else if(istype(I, /obj/item/stack/material)) //The equivalent of a cooked meal I guess. Stuff that is compressed during refinement has had nutrition bumped up by 5.
		var/obj/item/stack/material/O = I
		var/list/refined_taste = list(
			MAT_URANIUM						= list("nutrition" = 30,  "remark" = "Crunching [O] in your jaws almost makes you wince, a horribly tangy and sour flavour radiating through your mouth. It goes down all the same.", "WTF" = FALSE),
			MAT_DIAMOND						= list("nutrition" = 55,  "remark" = "After significant effort to crumble the gem, you unlock heavenly flavour that almost brings a tear to your eye. Its glimmering gloriousness is even better on the tongue than you imagined, so you savour it fondly.", "WTF" = FALSE),
			MAT_GOLD						= list("nutrition" = 40,  "remark" = "You taste supreme richness that exceeds expectations and satisfies your hunger.", "WTF" = FALSE),
			MAT_SILVER						= list("nutrition" = 40,  "remark" = "[O] tastes quite nice indeed as you munch on it. A little tarnished, but that's just fine aging.", "WTF" = FALSE),
			MAT_PHORON						= list("nutrition" = 35,  "remark" = "Crunching [O] to dust between your jaw you find pleasant, comforting warmth filling your mouth that briefly spreads down the throat to your chest as you swallow.", "WTF" = FALSE),
			MAT_SANDSTONE					= list("nutrition" = 0,   "remark" = "You crumble [O] easily in your jaws but its texture is almost gag-inducing. Stifling a cough, you somehow manage to swallow both [O] and your regrets.", "WTF" = FALSE),
			MAT_MARBLE						= list("nutrition" = 40,  "remark" = "A fitting dessert, the sweet and savoury [O] lingers on the palate and satisfies your hunger.", "WTF" = FALSE),
			MAT_STEEL						= list("nutrition" = 20,  "remark" = "Rending the [O] apart with ease, you briefly enjoy a classic but unremarkable taste. You need something more substantial.", "WTF" = FALSE),
			MAT_PLASTEEL					= list("nutrition" = 40,  "remark" = "The elegant taste of a fine richly-augmented alloy, chewing away on [O] yields lasting and satisfying flavour with a traditional metallic tang.", "WTF" = FALSE),
			MAT_DURASTEEL					= list("nutrition" = 65,  "remark" = "After much grinding the [O] eventually yields a sublime rush of flavours dominated by glorious diamond, further improved by the rich balance platinum and tang carbonic steel both bring to the mix: A supremely full bodied and savoury experience.", "WTF" = FALSE),
			MAT_TITANIUM					= list("nutrition" = 45,  "remark" = "The trademark bite and density of [O], somehow light on the palate with a refreshing coolness that lasts. Much improved with refinement, it certainly hits the spot.", "WTF" = FALSE),
			MAT_TITANIUMGLASS				= list("nutrition" = 20,  "remark" = "Grinding [O] down with a satisfying crunch, you quickly feel a cool and refreshing rush of flavour. It almost makes you even hungrier...", "WTF" = FALSE),
			MAT_PLASTITANIUM				= list("nutrition" = 60,  "remark" = "A glorious marriage of richness and mildly sour with cool refreshing finish. [O] practically begs to be savoured, lingering on the palate long enough to tempt another bite.", "WTF" = FALSE),
			MAT_PLASTITANIUMGLASS			= list("nutrition" = 25,  "remark" = "After some work, you grind [O] down with a satisfying crunch to unleash a sublime mixture of mildly sour richness and cooling refreshment. It readily entices you for another bite.", "WTF" = FALSE),
			MAT_GLASS						= list("nutrition" = 0,   "remark" = "All crunch and nothing more, you effortlessly grind [O] down to find it only wets your appetite and dries the throat.", "WTF" = FALSE),
			"rglass"						= list("nutrition" = 5,   "remark" = "With a satisfying crunch, you grind [O] down with ease. It is barely palatable with a subtle metallic tang.", "WTF" = FALSE),
			MAT_BOROSILICATE				= list("nutrition" = 10,  "remark" = "With a satisfying crunch, you grind [O] down with ease and find it somewhat palatable due to a subtle but familiar rush of phoronic warmth.", "WTF" = FALSE),
			"reinforced borosilicate glass"	= list("nutrition" = 15,  "remark" = "With a satisfying crunch, you grind [O] down. It is quite palatable due to a subtle metallic tang and familiar rush of phoronic warmth.", "WTF" = FALSE),
			MAT_GRAPHITE					= list("nutrition" = 30,  "remark" = "Satisfyingly metallic with a mildly savoury tartness, you chew [O] until its flavour is no more but are left longing for another.", "WTF" = FALSE),
			MAT_OSMIUM						= list("nutrition" = 45,  "remark" = "Successive bites serve to almost chill your palate, a rush of rich and mildly sour flavour unlocked with the grinding of your powerful jaws. Delectable.", "WTF" = FALSE),
			MAT_METALHYDROGEN				= list("nutrition" = 35,  "remark" = "Quite sweet on the tongue, you savour the light and easy to chew [O], finishing it quickly.", "WTF" = FALSE),
			"platinum"						= list("nutrition" = 40,  "remark" = "A bit tangy but elegantly balanced with a long faintly sour finish. Delectable.", "WTF" = FALSE),
			MAT_IRON						= list("nutrition" = 15,  "remark" = "The familiar texture and taste of [O] does the job but leaves little to the imagination and hardly sates your appetite.", "WTF" = FALSE),
			MAT_LEAD						= list("nutrition" = 40,   "remark" = "It takes some work to break down [O] but you manage it, unlocking lasting tangy goodness in the process. Yum.", "WTF" = FALSE),
			MAT_VERDANTIUM					= list("nutrition" = 55,  "remark" = "You taste scientific mystery and a rare delicacy. Your tastebuds tingle pleasantly as you eat [O] and the feeling warmly blossoms in your chest for a moment.", "WTF" = FALSE),
			MAT_MORPHIUM					= list("nutrition" = 75,  "remark" = "The question, the answer and the taste: It all floods your mouth and your mind to momentarily overwhelm the senses. What the hell was that? Your mouth and throat are left tingling for a while.", "WTF" = 10),
			"alienalloy"					= list("nutrition" = 120, "remark" = "Working hard for so long to rend the material apart has left your jaw sore, but a veritable explosion of mind boggling indescribable flavour is unleashed. Completely alien sensations daze and overwhelm you while it feels like an interdimensional rift opened in your mouth, briefly numbing your face.", "WTF" = 15)
		)
		if(O.default_type in refined_taste)
			var/obj/item/stack/material/stack = O.split(1) //A little off the top.
			I	= stack
			nom	= refined_taste[O.default_type]
			M	= name_to_material[O.default_type]
	else if(istype(I, /obj/item/entrepreneur/crystal))
		nom = list("nutrition" = 100,  "remark" = "The crytal was particularly brittle and not difficult to break apart, but the inside was incredibly flavoursome. Though devoid of any actual healing power, it seems to be very nutritious!", "WTF" = FALSE)

	if(nom) //Ravenous 1-4, snackage confirmed. Clear for chowdown, over.
		playsound(src, 'sound/items/eatfood.ogg', rand(10,50), 1)
		var/T = (istype(M) ? M.hardness/40 : 1) SECONDS //1.5 seconds to eat a sheet of metal. 2.5 for durasteel and diamond & 1 by default (applies to some ores like raw carbon, slag, etc.
		to_chat(src, span_notice("You start crunching on [I] with your powerful jaws, attempting to tear it apart..."))
		if(do_after(feeder, T, ignore_movement = TRUE, exclusive = TASK_ALL_EXCLUSIVE)) //Eat on the move, but not multiple things at once.
			if(feeder != src)
				to_chat(feeder, span_notice("You feed [I] to [src]."))
				log_admin("VORE: [feeder] fed [src] [I].")
			else
				log_admin("VORE: [src] used Eat Minerals to swallow [I].")
			//Eat the ore using the vorebelly for the sound then get rid of the ore to prevent infinite nutrition.
			drop_from_inventory(I, vore_selected) //Never touches the ground - straight to the gut.
			visible_message("[src] crunches [I] to pieces and swallows it down.",
				span_notice("[nom["remark"]]"),
				span_notice("You hear the gnashing of jaws with some ominous grinding and crunching noises, then... Swallowing?"))

			adjust_nutrition(nom["nutrition"])
			qdel(I)

			if(nom["WTF"]) //Bites back.
				H.Weaken(2)
				H.Confuse(nom["WTF"])
				H.apply_effect(nom["WTF"], STUTTER)
				H.make_jittery(nom["WTF"])
				H.make_dizzy(nom["WTF"])
				H.druggy = max(H.druggy, nom["WTF"])

			return TRUE
		else
			to_chat(src, span_notice("You were interrupted while gnawing on [I]!"))

	else //Not the droids we're looking for.
		to_chat(src, span_notice("You pause for a moment to examine [I] and realize it's not even worth the energy to chew.")) //If it ain't ore or the type of sheets we can eat, bugger off!

/mob/living/proc/toggle_stuffing_mode()
	set name = "Toggle feeding mode"
	set category = "Abilities.Vore"
	set desc = "Switch whether you will try to feed other people food whole or normally, bite by bite."

	stuffing_feeder = !stuffing_feeder
	to_chat(src, span_notice("You will [stuffing_feeder ? "now" : "no longer"] try to feed food whole."))

/mob/living/proc/switch_scaling()
	set name = "Switch scaling mode"
	set category = "Preferences.Game"
	set desc = "Switch sharp/fuzzy scaling for current mob."
	appearance_flags ^= PIXEL_SCALE
	fuzzy = !fuzzy
	update_transform()

/mob/living/proc/center_offset()
	set name = "Switch center offset mode"
	set category = "Preferences.Game"
	set desc = "Switch sprite center offset to fix even/odd symmetry."
	offset_override = !offset_override
	update_transform()

/mob/living/examine(mob/user, infix, suffix)
	. = ..()
	if(custom_link)
		. += "Custom link: " + span_linkify("[custom_link]")
	if(ooc_notes)
		. += "OOC Notes: <a href='?src=\ref[src];ooc_notes=1'>\[View\]</a> - <a href='?src=\ref[src];print_ooc_notes_to_chat=1'>\[Print\]</a>"
	. += "<a href='?src=\ref[src];vore_prefs=1'>\[Mechanical Vore Preferences\]</a>"


/mob/living/Topic(href, href_list)	//Can't find any instances of Topic() being overridden by /mob/living in polaris' base code, even though /mob/living/carbon/human's Topic() has a ..() call
	if(href_list["vore_prefs"])
		display_voreprefs(usr)
	if(href_list["ooc_notes"])
		src.Examine_OOC()
	if(href_list["edit_ooc_notes"])
		if(usr == src)
			set_metainfo_panel(usr) //ChompEDIT - usr arg
	if(href_list["edit_ooc_note_likes"])
		if(usr == src)
			set_metainfo_likes(usr) //ChompEDIT - usr arg
	if(href_list["edit_ooc_note_dislikes"])
		if(usr == src)
			set_metainfo_dislikes(usr) //ChompEDIT - usr arg
	if(href_list["save_ooc_panel"])
		if(usr == src)
			save_ooc_panel(usr) //ChompEDIT - usr arg
	if(href_list["print_ooc_notes_to_chat"])
		print_ooc_notes_to_chat(usr) //ChompEDIT - usr arg
	//CHOMPEdit Start
	if(href_list["edit_ooc_note_favs"])
		if(usr == src)
			set_metainfo_favs(usr) //ChompEDIT - usr arg
	if(href_list["edit_ooc_note_maybes"])
		if(usr == src)
			set_metainfo_maybes(usr) //ChompEDIT - usr arg
	if(href_list["set_metainfo_ooc_style"])
		set_metainfo_ooc_style(usr) //ChompEDIT - usr arg
	//CHOMPEdit End
	return ..()

/mob/living/proc/display_voreprefs(mob/user)	//Called by Topic() calls on instances of /mob/living (and subtypes) containing vore_prefs as an argument
	if(!user)
		CRASH("display_voreprefs() was called without an associated user.")
	var/dat = "<br>" + span_bold("[src]'s vore preferences") + "<br><br>"
	if(!client?.prefs?.read_preference(/datum/preference/toggle/show_ooc))
		dat += span_red(span_bold("OOC DISABLED")) + "<br>"
	if(!client?.prefs?.read_preference(/datum/preference/toggle/show_looc))
		dat += span_red(span_bold("LOOC DISABLED")) + "<br>"
	//CHOMPEdit Start
	dat += span_bold("Devourable:") + " [devourable ? span_green("Enabled") : span_red("Disabled")]<br>"
	if(devourable)
		dat += span_bold("Healbelly permission:") + " [permit_healbelly ? span_green("Allowed") : span_red("Disallowed")]<br>"
		dat += span_bold("Digestable:") + " [digestable ? span_green("Enabled") : span_red("Disabled")]<br>"
		dat += span_bold("Absorption Permission:") + " [absorbable ? span_green("Allowed") : span_red("Disallowed")]<br>"
		dat += span_bold("Selective Mode Pref:") + " [src.selective_preference]<br>"
		dat += span_bold("Mob Vore:") + " [allowmobvore ? span_green("Enabled") : span_red("Disabled")]<br>"
		dat += span_bold("Autotransferable:") + " [autotransferable ? span_green("Enabled") : span_red("Disabled")]<br>"
		dat += span_bold("Can be stripped:") + " [strip_pref ? span_green("Allowed") : span_red("Disallowed")]<br>"
		dat += span_bold("Applying reagents:") + " [apply_reagents ? span_green("Allowed") : span_red("Disallowed")]<br>"
		dat += span_bold("Leaves Remains:") + " [digest_leave_remains ? span_green("Enabled") : span_red("Disabled")]<br>"
	dat += span_bold("Spontaneous vore prey:") + " [can_be_drop_prey ? span_green("Enabled") : span_red("Disabled")]<br>"
	dat += span_bold("Spontaneous vore pred:") + " [can_be_drop_pred ? span_green("Enabled") : span_red("Disabled")]<br>"
	if(can_be_drop_prey || can_be_drop_pred)
		dat += span_bold("Drop Vore:") + " [drop_vore ? span_green("Enabled") : span_red("Disabled")]<br>"
		dat += span_bold("Slip Vore:") + " [slip_vore ? span_green("Enabled") : span_red("Disabled")]<br>"
		dat += span_bold("Stumble Vore:") + " [stumble_vore ? span_green("Enabled") : span_red("Disabled")]<br>"
		dat += span_bold("Throw vore:") + " [throw_vore ? span_green("Enabled") : span_red("Disabled")]<br>"
		dat += span_bold("Food Vore:") + " [food_vore ? span_green("Enabled") : span_red("Disabled")]<br>"
		dat += span_bold("Phase Vore:") + " [phase_vore ? span_green("Enabled") : span_red("Disabled")]<br>"
	dat += span_bold("Can be stepped on/over:") + " [step_mechanics_pref ? span_green("Allowed") : span_red("Disallowed")]<br>"
	dat += span_bold("Can be picked up:") + " [pickup_pref ? span_green("Allowed") : span_red("Disallowed")]<br>"
	dat += span_bold("Can be resized:") + " [resizable ? span_green("Allowed") : span_red("Disallowed")]<br>"
	dat += span_bold("Spontaneous transformation:") + " [allow_spontaneous_tf ? span_green("Enabled") : span_red("Disabled")]<br>"
	dat += span_bold("Mind transfer:") + " [allow_mind_transfer ? span_green("Allowed") : span_red("Disallowed")]<br>"
	dat += span_bold("Allow Mimicry:") + " [allow_mimicry ? span_green("Yes") : span_red("No")]<br>"
	dat += span_bold("Feedable:") + " [feeding ? span_green("Enabled") : span_red("Disabled")]<br>"
	dat += span_bold("Receiving liquids:") + " [receive_reagents ? span_green("Enabled") : span_red("Disabled")]<br>"
	dat += span_bold("Giving liquids:") + " [give_reagents ? span_green("Enabled") : span_red("Disabled")]<br>"
	dat += span_bold("Late join spawn point belly:") + " [latejoin_vore ? span_green("Enabled") : span_red("Disabled")]<br>"
	if(latejoin_vore)
		dat += span_bold("Late join spawn auto accept:") + " [no_latejoin_vore_warning ? span_green("Enabled") : span_red("Disabled")]<br>"
	dat += span_bold("Can be late join prey:") + " [latejoin_prey ? span_green("Enabled") : span_red("Disabled")]<br>"
	if(latejoin_prey)
		dat += span_bold("Late join prey auto accept:") + " [no_latejoin_prey_warning ? span_green("Enabled") : span_red("Disabled")]<br>"
	dat += span_bold("Global Vore Privacy is:") + " [eating_privacy_global ? span_green("Subtle") : span_red("Loud")]<br>"
	dat += span_bold("Current active belly:") + " [vore_selected ? vore_selected.name : "None"]<br>"
	dat += span_bold("Belly rub target:") + " [belly_rub_target ? belly_rub_target : (vore_selected ? vore_selected.name : "None")]<br>"
	//CHOMPEdit End
	var/datum/browser/popup = new(user, "[name]mvp", "Vore Prefs: [src]", 300, 700, src)
	popup.set_content(dat)
	popup.open()

// Full screen belly overlays!
/obj/screen/fullscreen/belly
	icon = 'modular_chomp/icons/mob/vore_fullscreens/screen_full_vore_ch.dmi' //CHOMPedit

/obj/screen/fullscreen/belly/fixed //CHOMPedit: tweaking to preserve save data
	icon = 'icons/mob/screen_full_vore.dmi' //CHOMPedit: tweaking to preserve save data
	icon_state = ""

/* //Chomp DISABLE - use our solution, not upstream's.
/obj/screen/fullscreen/belly/colorized/overlay
	icon = 'icons/mob/screen_full_colorized_vore_overlays.dmi'
*/ //Chomp DISABLE End

/mob/living/proc/vorebelly_printout() //Spew the vorepanel belly messages into chat window for copypasting.
	set name = "X-Print Vorebelly Settings"
	set category = "Preferences.Vore"
	set desc = "Print out your vorebelly messages into chat for copypasting."

	var/result = tgui_alert(src, "Would you rather open the export panel?", "Selected Belly Export", list("Open Panel", "Print to Chat"))
	if(!result)
		return
	if(result == "Open Panel")
		var/mob/living/user = usr
		if(!user)
			to_chat(usr,span_notice("Mob undefined: [user]"))
			return FALSE

		var/datum/vore_look/export_panel/exportPanel
		if(!exportPanel)
			exportPanel = new(usr)

		if(!exportPanel)
			to_chat(user,span_notice("Export panel undefined: [exportPanel]"))
			return

		exportPanel.tgui_interact(user)
	else
		for(var/belly in vore_organs)
			if(isbelly(belly))
				var/obj/belly/B = belly
				to_chat(src, span_chatexport(span_bold("Belly name:") + " [B.name]"))
				to_chat(src, span_chatexport(span_bold("Belly desc:") + " [B.desc]"))
				to_chat(src, span_chatexport(span_bold("Belly absorbed desc:") + " [B.absorbed_desc]"))
				to_chat(src, span_chatexport(span_bold("Vore verb:") + " [B.vore_verb]"))
				to_chat(src, span_chatexport(span_bold("Struggle messages (outside):")))
				for(var/msg in B.struggle_messages_outside)
					to_chat(src, span_chatexport("[msg]"))
				to_chat(src, span_chatexport(span_bold("Struggle messages (inside):")))
				for(var/msg in B.struggle_messages_inside)
					to_chat(src, span_chatexport("[msg]"))
				to_chat(src, span_chatexport(span_bold("Absorbed struggle messages (outside):")))
				for(var/msg in B.absorbed_struggle_messages_outside)
					to_chat(src, span_chatexport("[msg]"))
				to_chat(src, span_chatexport(span_bold("Absorbed struggle messages (inside):")))
				for(var/msg in B.absorbed_struggle_messages_inside)
					to_chat(src, span_chatexport("[msg]"))
				to_chat(src, span_chatexport(span_bold("Escape attempt messages (owner):")))
				for(var/msg in B.escape_attempt_messages_owner)
					to_chat(src, span_chatexport("[msg]"))
				to_chat(src, span_chatexport(span_bold("Escape attempt messages (prey):")))
				for(var/msg in B.escape_attempt_messages_prey)
					to_chat(src, span_chatexport("[msg]"))
				to_chat(src, span_chatexport(span_bold("Escape messages (owner):")))
				for(var/msg in B.escape_messages_owner)
					to_chat(src, span_chatexport("[msg]"))
				to_chat(src, span_chatexport(span_bold("Escape messages (prey):")))
				for(var/msg in B.escape_messages_prey)
					to_chat(src, span_chatexport("[msg]"))
				to_chat(src, span_chatexport(span_bold("Escape messages (outside):")))
				for(var/msg in B.escape_messages_outside)
					to_chat(src, span_chatexport("[msg]"))
				to_chat(src, span_chatexport(span_bold("Escape item messages (owner):")))
				for(var/msg in B.escape_item_messages_owner)
					to_chat(src, span_chatexport("[msg]"))
				to_chat(src, span_chatexport(span_bold("Escape item messages (prey):")))
				for(var/msg in B.escape_item_messages_prey)
					to_chat(src, span_chatexport("[msg]"))
				to_chat(src, span_chatexport(span_bold("Escape item messages (outside):")))
				for(var/msg in B.escape_item_messages_outside)
					to_chat(src, span_chatexport("[msg]"))
				to_chat(src, span_chatexport(span_bold("Escape fail messages (owner):")))
				for(var/msg in B.escape_fail_messages_owner)
					to_chat(src, span_chatexport("[msg]"))
				to_chat(src, span_chatexport(span_bold("Escape fail messages (prey):")))
				for(var/msg in B.escape_fail_messages_prey)
					to_chat(src, span_chatexport("[msg]"))
				to_chat(src, span_chatexport(span_bold("Absorbed escape attempt messages (owner):")))
				for(var/msg in B.escape_attempt_absorbed_messages_owner)
					to_chat(src, span_chatexport("[msg]"))
				to_chat(src, span_chatexport(span_bold("Absorbed escape attempt messages (prey):")))
				for(var/msg in B.escape_attempt_absorbed_messages_prey)
					to_chat(src, span_chatexport("[msg]"))
				to_chat(src, span_chatexport(span_bold("Absorbed escape messages (owner):")))
				for(var/msg in B.escape_absorbed_messages_owner)
					to_chat(src, span_chatexport("[msg]"))
				to_chat(src, span_chatexport(span_bold("Absorbed escape messages (prey):")))
				for(var/msg in B.escape_absorbed_messages_prey)
					to_chat(src, span_chatexport("[msg]"))
				to_chat(src, span_chatexport(span_bold("Absorbed escape messages (outside):")))
				for(var/msg in B.escape_absorbed_messages_outside)
					to_chat(src, span_chatexport("[msg]"))
				to_chat(src, span_chatexport(span_bold("Absorbed escape fail messages (owner):")))
				for(var/msg in B.escape_fail_absorbed_messages_owner)
					to_chat(src, span_chatexport("[msg]"))
				to_chat(src, span_chatexport(span_bold("Absorbed escape fail messages (prey):")))
				for(var/msg in B.escape_fail_absorbed_messages_prey)
					to_chat(src, span_chatexport("[msg]"))
				to_chat(src, span_chatexport(span_bold("Primary transfer messages (owner):")))
				for(var/msg in B.primary_transfer_messages_owner)
					to_chat(src, span_chatexport("[msg]"))
				to_chat(src, span_chatexport(span_bold("Primary transfer messages (prey):")))
				for(var/msg in B.primary_transfer_messages_prey)
					to_chat(src, span_chatexport("[msg]"))
				to_chat(src, span_chatexport(span_bold("Secondary transfer messages (owner):")))
				for(var/msg in B.secondary_transfer_messages_owner)
					to_chat(src, span_chatexport("[msg]"))
				to_chat(src, span_chatexport(span_bold("Secondary transfer messages (prey):")))
				for(var/msg in B.secondary_transfer_messages_prey)
					to_chat(src, span_chatexport("[msg]"))
				to_chat(src, span_chatexport(span_bold("Digest chance messages (owner):")))
				for(var/msg in B.digest_chance_messages_owner)
					to_chat(src, span_chatexport("[msg]"))
				to_chat(src, span_chatexport(span_bold("Digest chance messages  (prey):")))
				for(var/msg in B.digest_chance_messages_prey)
					to_chat(src, span_chatexport("[msg]"))
				to_chat(src, span_chatexport(span_bold("Absorb chance messages (owner):")))
				for(var/msg in B.absorb_chance_messages_owner)
					to_chat(src, span_chatexport("[msg]"))
				to_chat(src, span_chatexport(span_bold("Absorb chance messages  (prey):")))
				for(var/msg in B.absorb_chance_messages_prey)
					to_chat(src, span_chatexport("[msg]"))
				to_chat(src, span_chatexport(span_bold("Digest messages (owner):")))
				for(var/msg in B.digest_messages_owner)
					to_chat(src, span_chatexport("[msg]"))
				to_chat(src, span_chatexport(span_bold("Digest messages (prey):")))
				for(var/msg in B.digest_messages_prey)
					to_chat(src, span_chatexport("[msg]"))
				to_chat(src, span_chatexport(span_bold("Absorb messages (owner):")))
				for(var/msg in B.absorb_messages_owner)
					to_chat(src, span_chatexport("[msg]"))
				to_chat(src, span_chatexport(span_bold("Absorb messages (prey):")))
				for(var/msg in B.absorb_messages_prey)
					to_chat(src, span_chatexport("[msg]"))
				to_chat(src, span_chatexport(span_bold("Unabsorb messages (owner):")))
				for(var/msg in B.unabsorb_messages_owner)
					to_chat(src, span_chatexport("[msg]"))
				to_chat(src, span_chatexport(span_bold("Unabsorb messages (prey):")))
				for(var/msg in B.unabsorb_messages_prey)
					to_chat(src, span_chatexport("[msg]"))
				to_chat(src, span_chatexport(span_bold("Examine messages (when full):")))
				for(var/msg in B.examine_messages)
					to_chat(src, span_chatexport("[msg]"))
				to_chat(src, span_chatexport(span_bold("Examine messages (with absorbed victims):")))
				for(var/msg in B.examine_messages_absorbed)
					to_chat(src, span_chatexport("[msg]"))
				to_chat(src, span_chatexport(span_bold("Emote lists:")))
				for(var/EL in B.emote_lists)
					to_chat(src, span_chatexport(span_bold("[EL]:")))
					for(var/msg in B.emote_lists[EL])
						to_chat(src, span_chatexport("[msg]"))

/**
 * Small helper component to manage the vore panel HUD icon
 */
/datum/component/vore_panel
	var/obj/screen/vore_panel/screen_icon

/datum/component/vore_panel/Initialize()
	if(!isliving(parent))
		return COMPONENT_INCOMPATIBLE
	. = ..()

/datum/component/vore_panel/RegisterWithParent()
	. = ..()
	RegisterSignal(parent, COMSIG_MOB_CLIENT_LOGIN, PROC_REF(create_mob_button))
	var/mob/living/owner = parent
	if(owner.client)
		create_mob_button(parent)
	add_verb(owner, /mob/proc/insidePanel)
	if(!owner.vorePanel) //CHOMPEdit
		owner.vorePanel = new(owner)

/datum/component/vore_panel/UnregisterFromParent()
	. = ..()
	UnregisterSignal(parent, COMSIG_MOB_CLIENT_LOGIN)
	var/mob/living/owner = parent
	if(screen_icon)
		owner?.client?.screen -= screen_icon
		UnregisterSignal(screen_icon, COMSIG_CLICK)
		qdel_null(screen_icon)
	remove_verb(owner, /mob/proc/insidePanel)
	qdel_null(owner.vorePanel)

/datum/component/vore_panel/proc/create_mob_button(mob/user)
	var/datum/hud/HUD = user.hud_used
	if(!screen_icon)
		screen_icon = new()
		RegisterSignal(screen_icon, COMSIG_CLICK, PROC_REF(vore_panel_click))
	if(ispAI(user))
		screen_icon.icon = 'icons/mob/pai_hud.dmi'
		screen_icon.screen_loc = ui_acti
	else
		screen_icon.icon = HUD.ui_style
		screen_icon.color = HUD.ui_color
		screen_icon.alpha = HUD.ui_alpha
	LAZYADD(HUD.other_important, screen_icon)
	user.client?.screen += screen_icon

/datum/component/vore_panel/proc/vore_panel_click(source, location, control, params, user)
	var/mob/living/owner = user
	if(istype(owner) && owner.vorePanel)
		INVOKE_ASYNC(owner, TYPE_PROC_REF(/mob/living, insidePanel), owner) //CHOMPEdit
/**
 * Screen object for vore panel
 */
/obj/screen/vore_panel
	name = "vore panel"
	icon = 'icons/mob/screen/midnight.dmi'
	icon_state = "vore"
	screen_loc = ui_smallquad
