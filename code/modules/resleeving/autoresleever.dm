/obj/machinery/transhuman/autoresleever
	name = "automatic resleever"
	desc = "Uses advanced technology to detect when someone needs to be resleeved, and automatically prints and sleeves them into a new body. It even generates its own biomass!"
	icon = 'icons/obj/machines/autoresleever.dmi'
	icon_state = "autoresleever"
	density = TRUE
	anchored = TRUE
	var/equip_body = FALSE				//If true, this will spawn the person with equipment
	var/default_job = JOB_ALT_VISITOR		//The job that will be assigned if equip_body is true and the ghost doesn't have a job
	var/ghost_spawns = FALSE			//If true, allows ghosts who haven't been spawned yet to spawn
	var/vore_respawn = 30 MINUTES		//The time to wait if you died from vore // Outpost 21 edit - 30 mins instead of 5
	var/respawn = 30 MINUTES			//The time to wait if you didn't die from vore
	var/spawn_slots = -1				//How many people can be spawned from this? If -1 it's unlimited
	var/spawntype						//The kind of mob that will be spawned, if set.
	// Outpost 21 addition begin - Our resleever works different
	var/allow_ghosts_to_trigger = TRUE // If true, enables standard behavior
	var/releaseturf
	var/throw_dir = WEST
	// Outpost 21 addition end

/obj/machinery/transhuman/autoresleever/update_icon()
	. = ..()
	if(stat)
		icon_state = "autoresleever-o"
	else
		icon_state = "autoresleever"

/obj/machinery/transhuman/autoresleever/power_change()
	. = ..()
	update_icon()

/obj/machinery/transhuman/autoresleever/attack_ghost(mob/observer/dead/user as mob)
	// Outpost 21 addition begin - Our resleever works different
	if(!allow_ghosts_to_trigger)
		return
	// Outpost 21 addition end
	update_icon()
	if(spawn_slots == 0)
		to_chat(user, "<span class='warning'>There are no more respawn slots.</span>")
		return
	if(user.mind)
		if(user.mind.vore_death)
			if(vore_respawn <= world.time - user.timeofdeath)
				autoresleeve(user)
			else
				to_chat(user, "<span class='warning'>You must wait [((vore_respawn - (world.time - user.timeofdeath)) * 0.1) / 60] minutes to use \the [src].</span>")
				return
		else if(respawn <= world.time - user.timeofdeath)
			autoresleeve(user)
		else
			to_chat(user, "<span class='warning'>You must wait [((respawn - (world.time - user.timeofdeath)) * 0.1) /60] minutes to use \the [src].</span>")
			return
	else if(spawntype)
		if(tgui_alert(user, "This [src] spawns something special, would you like to play as it?", "Creachur", list("No","Yes")) == "Yes")
			autoresleeve(user)
	else if(ghost_spawns)
		if(tgui_alert(user, "Would you like to be spawned here as your presently loaded character?", "Spawn here", list("No","Yes")) == "Yes")
			autoresleeve(user)
	else
		to_chat(user, "<span class='warning'>You need to have been spawned in order to respawn here.</span>")

/obj/machinery/transhuman/autoresleever/attackby(var/mob/user)	//Let's not let people mess with this.
	// Outpost 21 addition begin - Our resleever works different
	if(!allow_ghosts_to_trigger)
		return
	// Outpost 21 addition end
	update_icon()
	if(istype(user,/mob/observer/dead))
		attack_ghost(user)
	else
		return

/obj/machinery/transhuman/autoresleever/proc/autoresleeve(var/mob/observer/dead/ghost,var/idscan = FALSE)
	if(stat)
		to_chat(ghost, "<span class='warning'>Auto-resleever has recieved your ID. Unfortunately it is not functional...</span>")
		return
	if(!istype(ghost,/mob/observer/dead))
		to_chat(ghost, "<span class='warning'>Auto-resleever has recieved your ID. Unfortunately you are inhabiting an animal and cannot be auto-resleeved. You may click the auto-resleever to resleeve yourself when your death timer has ended.</span>") // Outpost 21 edit - actually inform players
		return
	if(ghost.mind && ghost.mind.current && ghost.mind.current.stat != DEAD && ghost.mind.current.enabled == TRUE) //CHOMPEdit - Disabled body shouldn't block this.
		if(istype(ghost.mind.current.loc, /obj/item/mmi))
			if(tgui_alert(ghost, "Your brain is still alive, using the auto-resleever will delete that brain. Are you sure?", "Delete Brain", list("No","Yes")) != "Yes")
				return
			if(istype(ghost.mind.current.loc, /obj/item/mmi))
				qdel(ghost.mind.current.loc)
		else
			to_chat(ghost, "<span class='warning'>Your body is still alive, you cannot be resleeved.</span>")
			return

	var/client/ghost_client = ghost.client

	if(!is_alien_whitelisted(ghost, GLOB.all_species[ghost_client?.prefs?.species]) && !check_rights(R_ADMIN, 0)) // Prevents a ghost ghosting in on a slot and spawning via a resleever with race they're not whitelisted for, getting around normal join restrictions.
		to_chat(ghost, "<span class='warning'>You are not whitelisted to spawn as this species!</span>")
		return

	// CHOMPedit start
	var/datum/species/chosen_species
	if(ghost.client.prefs.species) // In case we somehow don't have a species set here.
		chosen_species = GLOB.all_species[ghost_client.prefs.species]

	if((chosen_species.spawn_flags & SPECIES_IS_WHITELISTED) || (chosen_species.spawn_flags & SPECIES_IS_RESTRICTED))
		to_chat(ghost, "<span class='warning'>This species cannot be resleeved!</span>")
		return
	// CHOMPEdit End: Add checks for Whitelist + Resleeving

	//Name matching is ugly but mind doesn't persist to look at.
	var/charjob
	var/datum/data/record/record_found
	record_found = find_general_record("name",ghost_client.prefs.real_name)

	//Found their record, they were spawned previously
	if(record_found)
		charjob = record_found.fields["real_rank"]
	else if(equip_body || ghost_spawns)
		charjob = default_job
	else
		to_chat(ghost, "<span class='warning'>It appears as though your loaded character has not been spawned this round, or has quit the round. If you died as a different character, please load them, and try again.</span>")
		return

	//For logging later
	var/player_key = ghost_client.key
	var/picked_ckey = ghost_client.ckey
	var/picked_slot = ghost_client.prefs.default_slot

	var/spawnloc = get_turf(src)
	// Outpost 21 edit begin - release turf behaviors
	if(releaseturf)
		spawnloc = get_step( releaseturf, throw_dir)
	// Outpost 21 edit end
	//Did we actually get a loc to spawn them?
	if(!spawnloc)
		to_chat(ghost, "<span class='warning'>Could not find a valid location to spawn your character.</span>")
		return

	if(spawntype)
		var/spawnthing = new spawntype(spawnloc)
		if(isliving(spawnthing))
			var/mob/living/L = spawnthing
			L.key = player_key
			L.ckey = picked_ckey
			log_admin("[L.ckey]'s has been spawned as [L] via \the [src].")
			message_admins("[L.ckey]'s has been spawned as [L] via \the [src].")
		else
			to_chat(ghost, "<span class='warning'>You can't play as a [spawnthing]...</span>")
			return
		if(spawn_slots == -1)
			return
		else if(spawn_slots == 0)
			return
		else
			spawn_slots --
			return

	if(tgui_alert(ghost, "Would you like to be resleeved?", "Resleeve", list("No","Yes")) != "Yes")
		return
	var/mob/living/carbon/human/new_character
	// Outpost 21 edit begin - release turf behaviors
	if(!releaseturf)
		new_character = new(spawnloc)
	else
		// spawn inside, release after
		new_character = new(src)
	// Outpost 21 edit end

	//We were able to spawn them, right?
	if(!new_character)
		to_chat(ghost, "Something went wrong and spawning failed.")
		return

	//Write the appearance and whatnot out to the character
	ghost_client.prefs.copy_to(new_character)
	if(new_character.dna)
		new_character.dna.ResetUIFrom(new_character)
		new_character.sync_dna_traits(TRUE) // Traitgenes edit - Sync traits to genetics if needed
		new_character.sync_organ_dna()
	if(ghost.mind)
		ghost.mind.transfer_to(new_character)

	new_character.key = player_key

	//Were they any particular special role? If so, copy.
	if(new_character.mind)
		new_character.mind.loaded_from_ckey = picked_ckey
		new_character.mind.loaded_from_slot = picked_slot
		var/datum/antagonist/antag_data = get_antag_data(new_character.mind.special_role)
		if(antag_data)
			antag_data.add_antagonist(new_character.mind)
			antag_data.place_mob(new_character)

	for(var/lang in ghost_client.prefs.alternate_languages)
		var/datum/language/chosen_language = GLOB.all_languages[lang]
		if(chosen_language)
			if(is_lang_whitelisted(ghost,chosen_language) || (new_character.species && (chosen_language.name in new_character.species.secondary_langs)))
				new_character.add_language(lang)
	for(var/key in ghost_client.prefs.language_custom_keys)
		if(ghost_client.prefs.language_custom_keys[key])
			var/datum/language/keylang = GLOB.all_languages[ghost_client.prefs.language_custom_keys[key]]
			if(keylang)
				new_character.language_keys[key] = keylang
	// VOREStation Add: Preferred Language Setting;
	if(ghost_client.prefs.preferred_language) // Do we have a preferred language?
		var/datum/language/def_lang = GLOB.all_languages[ghost_client.prefs.preferred_language]
		if(def_lang)
			new_character.default_language = def_lang
	// VOREStation Add End

	//If desired, apply equipment.
	if(equip_body)
		if(charjob)
			job_master.EquipRank(new_character, charjob, 1)
			new_character.mind.assigned_role = charjob
			new_character.mind.role_alt_title = job_master.GetPlayerAltTitle(new_character, charjob)

	//A redraw for good measure
	new_character.regenerate_icons()

	new_character.update_transform()

	log_admin("[new_character.ckey]'s character [new_character.real_name] has been auto-resleeved.")
	message_admins("[new_character.ckey]'s character [new_character.real_name] has been auto-resleeved.")

	/* Outpost 21 edit - remove backup implanter
	var/obj/item/implant/backup/imp = new(src)

	if(imp.handle_implant(new_character,new_character.zone_sel.selecting))
		imp.post_implant(new_character)
	*/

	var/datum/transcore_db/db = SStranscore.db_by_mind_name(new_character.mind.name)
	if(db)
		var/datum/transhuman/mind_record/record = db.backed_up[new_character.mind.name]
		if((world.time - record.last_notification) < 30 MINUTES)
			global_announcer.autosay("[new_character.name] has been resleeved by the automatic resleeving system.", "TransCore Oversight", new_character.isSynthetic() ? "Science" : "Medical")
		/* Outpost 21 edit - Nif removal
		spawn(0)	//Wait a second for nif to do its thing if there is one
		if(record.nif_path)
			var/obj/item/nif/nif
			if(new_character.nif)
				nif = new_character.nif
			else
				nif = new record.nif_path(new_character,null,record.nif_savedata)
			spawn(0)	//Wait another second in case we just gave them a new nif
			if(nif)	//Now restore the software
				for(var/path in record.nif_software)
					new path(nif)
				nif.durability = record.nif_durability
		*/

	// Outpost 21 edit begin - release turf behaviors
	if(releaseturf)
		outpost_post_sleeve(idscan,new_character,spawnloc)
	// Outpost 21 edit end

	if(spawn_slots == -1)
		return
	else if(spawn_slots == 0)
		return
	else
		spawn_slots --
		return

// Outpost 21 edit begin - our resleever works different
/obj/machinery/transhuman/autoresleever/proc/link_gibber(var/obj/machinery/gibber/G)
	G.sleevelink = src
	releaseturf = get_turf(G)
	throw_dir = G.gib_throw_dir

/obj/machinery/transhuman/autoresleever/proc/get_id_trigger(var/obj/item/card/id/D)
	if(stat || isnull(releaseturf))
		return

	// what even happened?
	if(isnull(D))
		src.visible_message("[src] flashes 'Invalid ID!', and lets out a loud incorrect sounding beep!")
		playsound(src, 'sound/machines/defib_failed.ogg', 50, 0)
		return

	// do not let guest IDs be used
	if(istype(D,/obj/item/card/id/guest))
		src.visible_message("[src] flashes 'Temporary guest ID identified!', and lets out a loud incorrect sounding beep!")
		playsound(src, 'sound/machines/defib_failed.ogg', 50, 0)
		return

	//Name matching is ugly but mind doesn't persist to look at.
	var/datum/transcore_db/db = SStranscore.db_by_mind_name(D.registered_name)
	if(isnull(db))
		src.visible_message("[src] flashes 'No records detected for [D.registered_name]!', and lets out a loud incorrect sounding beep!")
		playsound(src, 'sound/machines/defib_failed.ogg', 50, 0)
		return

	var/datum/transhuman/mind_record/recordM = db.backed_up[D.registered_name]
	var/datum/transhuman/body_record/recordB = db.body_scans[D.registered_name]

	if(isnull(recordM))
		src.visible_message("[src] flashes 'No mind records detected for [D.registered_name]!', and lets out a loud incorrect sounding beep!")
		playsound(src, 'sound/machines/defib_failed.ogg', 50, 0)
		if((world.time - recordM.last_notification) < 30 MINUTES)
			global_announcer.autosay("[D.registered_name] was unable to be resleeved, no records loaded or records are corrupted. Informing [using_map.dock_name].", "TransCore Oversight", "Medical")
		return

	if(isnull(recordB) || isnull(recordB.mydna) || isnull(recordB.mydna.dna))
		src.visible_message("[src] flashes 'No body records for [D.registered_name], or dna was corrupted!', and lets out a loud incorrect sounding beep!")
		playsound(src, 'sound/machines/defib_failed.ogg', 50, 0)
		if((world.time - recordM.last_notification) < 30 MINUTES)
			global_announcer.autosay("[D.registered_name] was unable to be resleeved, no records loaded or records are corrupted. Informing [using_map.dock_name].", "TransCore Oversight", "Medical")
		return

	var/datum/species/chosen_species = GLOB.all_species[recordB.mydna.dna.species]
	if(chosen_species.flags & NO_SCAN) // Sanity. Prevents species like Xenochimera, Proteans, etc from rejoining the round via resleeve, as they should have their own methods of doing so already, as agreed to when you whitelist as them.
		src.visible_message("[src] flashes 'Could not resleeve [D.registered_name]. Invalid species!', and lets out a loud incorrect sounding beep!")
		playsound(src, 'sound/machines/defib_failed.ogg', 50, 0)
		if((world.time - recordM.last_notification) < 30 MINUTES)
			global_announcer.autosay("[D.registered_name] was unable to be resleeved by the automatic resleeving system.", "TransCore Oversight", "Medical")
		return

	// solve the ghost from mind refs
	var/mob/ghost
	var/client/ghost_client
	for(var/client/C in GLOB.clients)
		if(C.ckey == recordM.ckey)
			ghost_client = C
			ghost = ghost_client.mob
			break

	// Avoiding some funny messages
	if(!stat && istype(ghost,/mob/observer/dead))
		to_chat(ghost, "<span class='warning'>Your ID has arrived at the autosleever!</span>")
		autoresleeve(ghost,TRUE)

/obj/machinery/transhuman/autoresleever/proc/outpost_post_sleeve(var/idscan, var/mob/living/carbon/human/new_character, var/spawnloc)
	var/confuse_amount = rand(8,26)
	var/blur_amount = rand(8,56)
	var/sickness_duration = rand(20,30) MINUTES

	// apply state
	new_character.confused = max(new_character.confused, confuse_amount)
	new_character.eye_blurry = max(new_character.eye_blurry, blur_amount)
	new_character.add_modifier(/datum/modifier/resleeving_sickness, sickness_duration)

	if(idscan) // Harmful respawn
		new_character.adjustOxyLoss( rand(5,25))
		new_character.adjustBruteLoss( rand(1,8), FALSE)
		new_character.adjustToxLoss( rand(0,12))
		new_character.adjustFireLoss( rand(0,8), FALSE)
		new_character.adjustCloneLoss( rand(0,6))
	new_character.sleeping = rand(4,6)
	new_character.Life() // Force lifetick for instant effect

	// Visuals and release
	playsound(src, 'sound/machines/defib_charge.ogg', 50, 0)
	spawn(1 SECONDS)
		playsound(src, "bodyfall", 50, 1)
		playsound(src, 'sound/machines/defib_zap.ogg', 50, 1, -1)

	spawn(5 SECONDS)
		new_character.forceMove(spawnloc)
		new_character.throw_at(get_edge_target_turf(src.loc, throw_dir), 1,5)
// Outpost 21 addition end
