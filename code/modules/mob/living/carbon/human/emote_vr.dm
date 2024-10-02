/mob/living/carbon/human/verb/toggle_resizing_immunity()
	set name = "Toggle Resizing Immunity"
	set desc = "Toggles your ability to resist resizing attempts"
	set category = "IC.Settings" //CHOMPEdit

	resizable = !resizable
	to_chat(src, "<span class='notice'>You are now [resizable ? "susceptible" : "immune"] to being resized.</span>")


/mob/living/carbon/human/proc/handle_flip_vr()
	var/original_density = density
	var/original_passflags = pass_flags

	//Briefly un-dense to dodge projectiles
	density = FALSE

	//Parkour!
	var/parkour_chance = 20 //Default
	if(species)
		parkour_chance = species.agility
	if(prob(parkour_chance))
		pass_flags |= PASSTABLE
	else
		Confuse(1) //Thud

		// outpost 21 edit begin - add the sillier interactions
		if(prob(2))
			AdjustWeakened(12)
			visible_message(span_warning("\The [src] collapses their ankle!"), span_warning("You collapses your ankle!"))
			if(prob(50))
				var/obj/item/organ/external/left_leg = get_organ(BP_L_LEG)
				if(left_leg)
					left_leg.fracture()
			else
				var/obj/item/organ/external/right_leg = get_organ(BP_R_LEG)
				if(right_leg)
					right_leg.fracture()
		// outpost 21 edit end

	if(dir & WEST)
		SpinAnimation(7,1,0)
	else
		SpinAnimation(7,1,1)

	// Outpost 21 edit begin - You aren't smart, are you?
	if(isturf(loc))
		for(var/obj/structure/stairs/top/S in loc.contents)
			S.use_stairs_instant(src)
			visible_message(span_warning("\The [src] falls down the stairs!"), span_warning("You fall down the stairs!"))
			Confuse(10) //Thud
			AdjustWeakened(12)
			adjustBruteLoss(8)
			if(prob(80))
				if(prob(50))
					var/obj/item/organ/external/left_leg = get_organ(BP_L_LEG)
					if(left_leg)
						left_leg.fracture()
				else
					var/obj/item/organ/external/right_leg = get_organ(BP_R_LEG)
					if(right_leg)
						right_leg.fracture()
	// Outpost 21 edit end

	spawn(7)
		density = original_density
		pass_flags = original_passflags

/mob/living/carbon/human/verb/toggle_gender_identity_vr()
	set name = "Set Gender Identity"
	set desc = "Sets the pronouns when examined and performing an emote."
	set category = "IC.Settings" //CHOMPEdit
	var/new_gender_identity = tgui_input_list(usr, "Please select a gender Identity:", "Set Gender Identity", list(FEMALE, MALE, NEUTER, PLURAL, HERM))
	if(!new_gender_identity)
		return 0
	change_gender_identity(new_gender_identity)
	return 1

/mob/living/carbon/human/verb/switch_tail_layer()
	set name = "Switch tail layer"
	set category = "IC.Game" //CHOMPEdit
	set desc = "Switch tail layer on top."
	tail_alt = !tail_alt
	update_tail_showing()

/mob/living/carbon/human/verb/hide_wings_vr()
	set name = "Show/Hide wings"
	set category = "IC.Settings" //CHOMPEdit
	set desc = "Hide your wings, or show them if you already hid them."
	wings_hidden = !wings_hidden
	update_wing_showing()
	var/message = ""
	if(!wings_hidden)
		message = "reveals their wings!"
	else
		message = "hides their wings."
	visible_message("<span class='filter_notice'>[src] [message]</span>")

/mob/living/carbon/human/verb/hide_tail_vr()
	set name = "Show/Hide tail"
	set category = "IC.Game" //CHOMPEdit
	set desc = "Hide your tail, or show it if you already hid it."
	if(!tail_style) //Just some checks.
		to_chat(src,"<span class='notice'>You have no tail to hide!</span>")
		return
	else //They got a tail. Let's make sure it ain't hiding stuff!
		var/datum/sprite_accessory/tail/current_tail = tail_style
		if((current_tail.hide_body_parts && current_tail.hide_body_parts.len) || current_tail.clip_mask_state || current_tail.clip_mask)
			to_chat(src,"<span class='notice'>Your current tail is too considerable to hide!</span>")
			return
	if(species.tail) //If they're using this verb, they already have a custom tail. This prevents their species tail from showing.
		species.tail = null //Honestly, this should probably be done when a custom tail is chosen, but this is the only time it'd ever matter.
	tail_hidden = !tail_hidden
	update_tail_showing()
	var/message = ""
	if(!tail_hidden)
		message = "reveals their tail!"
	else
		message = "hides their tail."
	visible_message("<span class='filter_notice'>[src] [message]</span>")
