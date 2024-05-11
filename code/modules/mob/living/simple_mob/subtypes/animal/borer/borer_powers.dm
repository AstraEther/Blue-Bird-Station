/mob/living/simple_mob/animal/borer/verb/release_host()
	set category = "Abilities"
	set name = "Release Host"
	set desc = "Slither out of your host."

	if(!host)
		to_chat(src, "You are not inside a host body.")
		return

	if(stat)
		to_chat(src, "You cannot leave your host in your current state.")

	if(docile)
		to_chat(src, span_blue("You are feeling far too docile to do that."))
		return

	if(!host || !src) return

	to_chat(src, "You begin disconnecting from [host]'s synapses and prodding at their internal ear canal.")

	if(!host.stat)
		to_chat(host, "An odd, uncomfortable pressure begins to build inside your skull, behind your ear...")

	spawn(100)

		if(!host || !src) return

		if(src.stat)
			to_chat(src, "You cannot release your host in your current state.")
			return

		to_chat(src, "You wiggle out of [host]'s ear and plop to the ground.")
		if(host.mind)
			if(!host.stat)
				to_chat(host, "<span class='danger'>Something slimy wiggles out of your ear and plops to the ground!</span>")
			to_chat(host, "<span class='danger'>As though waking from a dream, you shake off the insidious mind control of the brain worm. Your thoughts are your own again.</span>")

		detatch()
		leave_host()

/mob/living/simple_mob/animal/borer/verb/infest()
	set category = "Abilities"
	set name = "Infest"
	set desc = "Infest a suitable humanoid host."

	if(host)
		to_chat(src, "You are already within a host.")
		return

	if(stat)
		to_chat(src, "You cannot infest a target in your current state.")
		return

	var/list/choices = list()
	for(var/mob/living/carbon/C in view(1,src))
		if(src.Adjacent(C))
			choices += C

	if(!choices.len)
		to_chat(src, "There are no viable hosts within range...")
		return

	// Outpost 21 edit begin - borer fixes
	var/mob/living/carbon/M = choices[1]
	if(choices.len > 1)
		M = tgui_input_list(src, "Who do you wish to infest?", "Target Choice", choices)

	if(!M || !src)
		return

	if(!(src.Adjacent(M)))
		to_chat(src, "<span class='warning'>\The [M] has escaped your range...</span>")
		return
	// Outpost 21 edit end

	if(M.has_brain_worms())
		to_chat(src, "You cannot infest someone who is already infested!")
		return

	if(istype(M,/mob/living/carbon/human))
		var/mob/living/carbon/human/H = M

		var/obj/item/organ/external/E = H.organs_by_name[BP_HEAD]
		if(!E || E.is_stump())
			to_chat(src, "\The [H] does not have a head!")

		if(!H.should_have_organ("brain"))
			to_chat(src, "\The [H] does not seem to have an ear canal to breach.")
			return

		if(H.check_head_coverage())
			to_chat(src, "You cannot get through that host's protective gear.")
			return

	to_chat(M, "Something slimy begins probing at the opening of your ear canal...")
	to_chat(src, "You slither up [M] and begin probing at their ear canal...")

	if(!do_after(src,30))
		to_chat(src, "As [M] moves away, you are dislodged and fall to the ground.")
		return

	if(!M || !src) return

	if(src.stat)
		to_chat(src, "You cannot infest a target in your current state.")
		return

	if(M in view(1, src))
		to_chat(src, "You wiggle into [M]'s ear.")
		if(!M.stat)
			to_chat(M, "Something disgusting and slimy wiggles into your ear!")

		src.host = M
		src.forceMove(M)

		//Update their traitor status.
		if(host.mind)
			borers.add_antagonist_mind(host.mind, 1, borers.faction_role_text, borers.faction_welcome)

		if(istype(M,/mob/living/carbon/human))
			var/mob/living/carbon/human/H = M
			var/obj/item/organ/I = H.internal_organs_by_name["brain"]
			if(!I) // No brain organ, so the borer moves in and replaces it permanently.
				replace_brain()
			else
				// If they're in normally, implant removal can get them out.
				var/obj/item/organ/external/head = H.get_organ(BP_HEAD)
				head.implants += src

		return
	else
		to_chat(src, "They are no longer in range!")
		return

/*
/mob/living/simple_mob/animal/borer/verb/devour_brain()
	set category = "Abilities"
	set name = "Devour Brain"
	set desc = "Take permanent control of a dead host."

	if(!host)
		to_chat(src, "You are not inside a host body.")
		return

	if(host.stat != 2)
		to_chat(src, "Your host is still alive.")
		return

	if(stat)
		to_chat(src, "You cannot do that in your current state.")

	if(docile)
		to_chat(src, "<font color='blue'>You are feeling far too docile to do that.</font>")
		return


	to_chat(src, "<span class = 'danger'>It only takes a few moments to render the dead host brain down into a nutrient-rich slurry...</span>")
	replace_brain()
*/

// BRAIN WORM ZOMBIES AAAAH.
/mob/living/simple_mob/animal/borer/proc/replace_brain()

	var/mob/living/carbon/human/H = host

	if(!istype(host))
		to_chat(src, "This host does not have a suitable brain.")
		return

	to_chat(src, "<span class = 'danger'>You settle into the empty brainpan and begin to expand, fusing inextricably with the dead flesh of [H].</span>")

	H.add_language("Cortical Link")

	if(host.stat == 2)
		add_verb(H,/mob/living/carbon/human/proc/jumpstart) //CHOMPEdit TGPanel

	add_verb(H,/mob/living/carbon/human/proc/psychic_whisper) //CHOMPEdit TGPanel
	add_verb(H,/mob/living/carbon/human/proc/tackle) //CHOMPEdit TGPanel
	if(antag)
		add_verb(H,/mob/living/carbon/proc/spawn_larvae) //CHOMPEdit TGPanel

	if(H.client)
		H.ghostize(0)

	if(src.mind)
		src.mind.special_role = "Borer Husk"
		src.mind.transfer_to(host)

	H.ChangeToHusk()

	var/obj/item/organ/internal/borer/B = new(H)
	H.internal_organs_by_name["brain"] = B
	H.internal_organs |= B

	var/obj/item/organ/external/affecting = H.get_organ(BP_HEAD)
	affecting.implants -= src

	var/s2h_id = src.computer_id
	var/s2h_ip= src.lastKnownIP
	src.computer_id = null
	src.lastKnownIP = null

	if(!H.computer_id)
		H.computer_id = s2h_id

	if(!H.lastKnownIP)
		H.lastKnownIP = s2h_ip

/mob/living/simple_mob/animal/borer/verb/secrete_chemicals()
	set category = "Abilities"
	set name = "Secrete Chemicals"
	set desc = "Push some chemicals into your host's bloodstream."

	if(!host)
		to_chat(src, "You are not inside a host body.")
		return

	if(stat)
		to_chat(src, "You cannot secrete chemicals in your current state.")

	if(docile)
		to_chat(src, span_blue("You are feeling far too docile to do that."))
		return

	// Outpost 21 edit begin - borer fixes
	if(chemicals < 50)
		to_chat(src, "You don't have enough chemicals!")
		return

	var/injectsize = 10
	var/chem = tgui_input_list(usr	, "Select a chemical to secrete."
									, "Chemicals", list("Repair Brain Tissue (alkysine)"
									,"Repair Body (bicaridine)"
									,"Make Drunk (ethanol)"
									,"Cure Drunk (ethylredoxrazine)"
									,"Enhance Speed (hyperzine)"
									,"Pain Killer (tramadol)"
									,"Euphoric High (bliss)"
									,"Stablize Mind (citalopram)"
								))
	switch(chem) // scan for simplified name
		if("Repair Brain Tissue (alkysine)")
			chem = "alkysine"
		if("Repair Body (bicaridine)")
			chem = "bicaridine"
		if("Make Drunk (ethanol)")
			chem = "ethanol"
			injectsize = 5
		if("Cure Drunk (ethylredoxrazine)")
			chem = "ethylredoxrazine"
		if("Enhance Speed (hyperzine)")
			chem = "hyperzine"
		if("Pain Killer (tramadol)")
			chem = "tramadol"
		if("Euphoric High (bliss)")
			chem = "bliss"
			injectsize = 5
		if("Stablize Mind (citalopram)")
			chem = "citalopram"
		else
			if(chem)
				// why did this happen?
				to_chat(src, "<font color='red'><B>The option [chem] did not link to any valid option, inform a dev that the switch in borer_powers.dm/secrete_chemicals() is broken</B></font>")
				chem = null
	// Outpost 21 edit end

	if(!chem || chemicals < 50 || !host || controlling || !src || stat) //Sanity check.
		return

	to_chat(src, span_red("<B>You squirt a measure of [chem] from your reservoirs into [host]'s bloodstream.</B>"))
	host.reagents.add_reagent(chem, injectsize) // Outpost 21 edit - borer fixes
	chemicals -= 50

/mob/living/simple_mob/animal/borer/verb/dominate_victim()
	set category = "Abilities"
	set name = "Paralyze Victim"
	set desc = "Freeze the limbs of a potential host with supernatural fear."

	if(world.time - used_dominate < 150)
		to_chat(src, "You cannot use that ability again so soon.")
		return

	if(host)
		to_chat(src, "You cannot do that from within a host body.")
		return

	if(src.stat)
		to_chat(src, "You cannot do that in your current state.")
		return

	var/list/choices = list()
	for(var/mob/living/carbon/C in view(3,src))
		if(C.stat != 2)
			choices += C

	if(world.time - used_dominate < 150)
		to_chat(src, "You cannot use that ability again so soon.")
		return

	// Outpost 21 edit begin - borer fixes
	if(!choices.len)
		to_chat(src, "<span class='notice'>There are no viable targets within range...</span>")
		return

	var/mob/living/carbon/M = choices[1]
	if(choices.len > 1)
		tgui_input_list(src, "Who do you wish to dominate?", "Target Choice", choices)
	// Outpost 21 edit end

	if(!M || !src) return

	// Outpost 21 edit begin - borer fixes
	if(!(M in view(3,src)))
		to_chat(src, "<span class='warning'>\The [M] escaped your influence...</span>")
		return
	// Outpost 21 edit end

	if(M.has_brain_worms())
		to_chat(src, "You cannot infest someone who is already infested!")
		return

	to_chat(src, span_red("You focus your psychic lance on [M] and freeze their limbs with a wave of terrible dread."))
	to_chat(M, span_red("You feel a creeping, horrible sense of dread come over you, freezing your limbs and setting your heart racing."))
	M.Weaken(10)

	used_dominate = world.time

/mob/living/simple_mob/animal/borer/verb/bond_brain()
	set category = "Abilities"
	set name = "Assume Control"
	set desc = "Fully connect to the brain of your host."

	if(!host)
		to_chat(src, "You are not inside a host body.")
		return

	if(src.stat)
		to_chat(src, "You cannot do that in your current state.")
		return

	if(docile)
		to_chat(src, span_blue("You are feeling far too docile to do that."))
		return

	to_chat(src, "You begin delicately adjusting your connection to the host brain...")

	spawn(100+(host.brainloss*5))

		if(!host || !src || controlling)
			return
		else

			to_chat(src, span_red("<B>You plunge your probosci deep into the cortex of the host brain, interfacing directly with their nervous system.</B>"))
			to_chat(host, span_red("<B>You feel a strange shifting sensation behind your eyes as an alien consciousness displaces yours.</B>"))
			host.add_language("Cortical Link")

			// host -> brain
			var/h2b_id = host.computer_id
			var/h2b_ip= host.lastKnownIP
			host.computer_id = null
			host.lastKnownIP = null

			qdel(host_brain)
			host_brain = new(src)

			host_brain.ckey = host.ckey

			host_brain.name = host.name

			if(!host_brain.computer_id)
				host_brain.computer_id = h2b_id

			if(!host_brain.lastKnownIP)
				host_brain.lastKnownIP = h2b_ip

			// self -> host
			var/s2h_id = src.computer_id
			var/s2h_ip= src.lastKnownIP
			src.computer_id = null
			src.lastKnownIP = null

			host.ckey = src.ckey

			if(!host.computer_id)
				host.computer_id = s2h_id

			if(!host.lastKnownIP)
				host.lastKnownIP = s2h_ip

			controlling = 1

			add_verb(host,/mob/living/carbon/proc/release_control)  //CHOMPEdit
			add_verb(host,/mob/living/carbon/proc/punish_host)  //CHOMPEdit
			if(antag)
				add_verb(host,/mob/living/carbon/proc/spawn_larvae)  //CHOMPEdit

			return

/mob/living/carbon/human/proc/jumpstart()
	set category = "Abilities"
	set name = "Revive Host"
	set desc = "Send a jolt of electricity through your host, reviving them."

	if(stat != 2)
		to_chat(usr, "Your host is already alive.")
		return

	remove_verb(src,/mob/living/carbon/human/proc/jumpstart) //CHOMPEdit TGPanel
	visible_message("<span class='warning'>With a hideous, rattling moan, [src] shudders back to life!</span>")

	rejuvenate()
	restore_blood()
	fixblood()
	update_canmove()
