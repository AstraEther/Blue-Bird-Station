/datum/reagent/blood
	data = new/list("donor" = null, "viruses" = null, "species" = SPECIES_HUMAN, "blood_DNA" = null, "blood_type" = null, "blood_colour" = "#A10808", "resistances" = null, "trace_chem" = null, "antibodies" = list(), "changeling" = FALSE) // Outpost 21 edit - changling blood effects
	name = "Blood"
	id = "blood"
	taste_description = "iron"
	taste_mult = 1.3
	reagent_state = LIQUID
	metabolism = REM * 5
	mrate_static = TRUE
	affects_dead = 1 //so you can pump blood into someone before defibbing them
	color = "#C80000"
	var/volume_mod = 1	// So if you add different subtypes of blood, you can affect how much vessel blood each unit of reagent adds

	glass_name = "tomato juice"
	glass_desc = "Are you sure this is tomato juice?"

/datum/reagent/blood/initialize_data(var/newdata)
	..()
	if(data && data["blood_colour"])
		color = data["blood_colour"]

	return

/datum/reagent/blood/get_data() // Just in case you have a reagent that handles data differently.
	var/t = data.Copy()
	if(t["viruses"])
		var/list/v = t["viruses"]
		t["viruses"] = v.Copy()
	return t

/datum/reagent/blood/touch_turf(var/turf/simulated/T)
	if(!istype(T) || volume < 3)
		return

	..()

	if(!data["donor"] || istype(data["donor"], /mob/living/carbon/human))
		blood_splatter(T, src, 1)
	else if(istype(data["donor"], /mob/living/carbon/alien))
		var/obj/effect/decal/cleanable/blood/B = blood_splatter(T, src, 1)
		if(B)
			B.blood_DNA["UNKNOWN DNA STRUCTURE"] = "X*"

/datum/reagent/blood/affect_ingest(var/mob/living/carbon/M, var/alien, var/removed)

	var/effective_dose = dose
	if(issmall(M)) effective_dose *= 2

	var/is_vampire = FALSE //VOREStation Edit START
	if(ishuman(M))
		var/mob/living/carbon/human/H = M
		if(H.species.bloodsucker)
			H.adjust_nutrition(removed*30)
			is_vampire = TRUE //VOREStation Edit END
	if(alien == IS_SLIME)	// Treat it like nutriment for the jello, but not equivalent.
		if(data["species"] == M.species.name)	// Unless it's Promethean goo, then refill this one's goo.
			M.inject_blood(src, volume * volume_mod)
			remove_self(volume)
			return

		M.heal_organ_damage(0.2 * removed * volume_mod, 0)	// More 'effective' blood means more usable material.
		M.adjust_nutrition(20 * removed * volume_mod)
		M.add_chemical_effect(CE_BLOODRESTORE, 4 * removed)
		//M.adjustToxLoss(removed / 2)	// Still has some water in the form of plasma. | CHOMP EDIT - No. Soda does not kill a prommie, their own blood should not either.
		return

	if(effective_dose > 5)
		if(!is_vampire) //VOREStation Edit.
			M.adjustToxLoss(removed) //VOREStation Edit.
	if(effective_dose > 15)
		if(!is_vampire) //VOREStation Edit.
			M.adjustToxLoss(removed) //VOREStation Edit.
	if(data && data["viruses"])
		var/list/vlist = data["viruses"]
		if(vlist.len)
			for(var/ID in vlist)
				if(!ID)
					continue
				var/datum/disease/D = ID
				if((D.spread_flags & SPECIAL) || (D.spread_flags & NON_CONTAGIOUS))
					continue
				M.ContractDisease(D)

/datum/reagent/blood/affect_touch(var/mob/living/carbon/M, var/alien, var/removed)
	if(ishuman(M))
		var/mob/living/carbon/human/H = M
		if(H.isSynthetic())
			return
	if(alien == IS_SLIME)
		affect_ingest(M, alien, removed)
		return
	if(data && data["viruses"])
		var/list/vlist = data["viruses"]
		if(vlist.len)
			for(var/ID in vlist)
				var/datum/disease/D = ID
				if((D.spread_flags & SPECIAL) || (D.spread_flags & NON_CONTAGIOUS))
					continue
				M.ContractDisease(D)
	if(data && data["resistances"])
		M.resistances |= data["resistances"]

/datum/reagent/blood/mix_data(newdata, newamount)
	if(!data || !newdata)
		return

	// Outpost 21 edit blood - changling blood effects
	if(newdata["species"] != "synthetic" && (data["changeling"] || newdata["changeling"]))
		data["changeling"] = TRUE;
	// Outpost 21 edit end

	if(data["viruses"] || newdata["viruses"])
		var/list/mix1 = data["viruses"]
		var/list/mix2 = newdata["viruses"]

		var/list/to_mix = list()
		var/list/preserve = list()

		for(var/datum/disease/advance/AD in mix1)
			to_mix += AD
		for(var/datum/disease/advance/AD in mix2)
			to_mix += AD

		var/datum/disease/advance/mixed_AD = Advance_Mix(to_mix)

		if(mixed_AD)
			preserve += mixed_AD

		for(var/datum/disease/D1 in mix1)
			if(!istype(D1, /datum/disease/advance))
				var/keep = TRUE
				for(var/datum/disease/D2 in preserve)
					if(D1.IsSame(D2))
						keep = FALSE
						break
				if(keep)
					preserve += D1

		for(var/datum/disease/D1 in mix2)
			if(!istype(D1, /datum/disease/advance))
				var/keep = TRUE
				for(var/datum/disease/D2 in preserve)
					if(D1.IsSame(D2))
						keep = FALSE
						break
				if(keep)
					preserve += D1

		data["viruses"] = preserve

/datum/reagent/blood/affect_blood(var/mob/living/carbon/M, var/alien, var/removed)
	if(alien == IS_SLIME)	//They don't have blood, so it seems weird that they would instantly 'process' the chemical like another species does.
		affect_ingest(M, alien, removed)
		return

	if(M.isSynthetic())
		return

	if(ishuman(M))
		var/mob/living/carbon/human/H = M

		var/datum/reagent/blood/recipient = H.get_blood(H.vessel)

		if(recipient && blood_incompatible(data["blood_type"], recipient.data["blood_type"], data["species"], recipient.data["species"]))
			H.inject_blood(src, removed * volume_mod)

			if(!H.isSynthetic() && data["species"] == "synthetic")	// Remember not to inject oil into your veins, it's bad for you.
				H.reagents.add_reagent("toxin", removed * 1.5)

			return

	M.inject_blood(src, volume * volume_mod)
	remove_self(volume)

// Outpost 21 edit begin - changeling blood test
/datum/reagent/blood/proc/changling_blood_test(var/datum/reagents/holder)
	if(data["changeling"])
		var/location = get_turf(holder.my_atom)
		holder.my_atom.visible_message(span_danger("The blood in \the [holder.my_atom] screams and leaps out!"))
		if(istype(holder.my_atom,/obj/item/reagent_containers/glass))
			holder.splash(location, holder.total_volume)
		holder.clear_reagents() // lets be sure it's all gone if it was in something weird instead
		playsound(holder.my_atom, 'sound/effects/splat.ogg', 50, 1)
		playsound(holder.my_atom, 'sound/voice/hiss6.ogg', 50, 1)
		return TRUE
	return FALSE
// Outpost 21 edit end

/datum/reagent/blood/synthblood
	name = "synthetic blood"
	id = "synthblood"
	color = "#999966"
	volume_mod = 2

/datum/reagent/blood/synthblood/initialize_data(var/newdata)
	..()
	if(data && !data["blood_type"])
		data["blood_type"] = "O-"
	if(data && data["species"])
		data["species"] = null
	return

/datum/reagent/blood/synthblood/dilute
	name = "synthetic plasma"
	id = "synthblood_dilute"
	color = "#cacaaf"
	volume_mod = 1.2

// pure concentrated antibodies
/datum/reagent/antibodies
	data = list("antibodies"=list())
	name = "Antibodies"
	taste_description = "slime"
	id = "antibodies"
	reagent_state = LIQUID
	color = "#0050F0"
	mrate_static = TRUE

/datum/reagent/antibodies/affect_blood(var/mob/living/carbon/M, var/alien, var/removed)
	if(src.data)
		M.antibodies |= src.data["antibodies"]
	..()

#define WATER_LATENT_HEAT 19000 // How much heat is removed when applied to a hot turf, in J/unit (19000 makes 120 u of water roughly equivalent to 4L)

/datum/reagent/water
	name = "Water"
	id = "water"
	taste_description = "water"
	description = "A ubiquitous chemical substance that is composed of hydrogen and oxygen."
	reagent_state = LIQUID
	color = "#0064C877"
	metabolism = REM * 10

	glass_name = "water"
	glass_desc = "The father of all refreshments."

/datum/reagent/water/touch_turf(var/turf/simulated/T)
	if(!istype(T))
		return

	..()

	var/datum/gas_mixture/environment = T.return_air()
	var/min_temperature = T0C + 100 // 100C, the boiling point of water

	var/hotspot = (locate(/obj/fire) in T)
	if(hotspot && !istype(T, /turf/space))
		var/datum/gas_mixture/lowertemp = T.remove_air(T:air:total_moles)
		lowertemp.temperature = max(min(lowertemp.temperature-2000, lowertemp.temperature / 2), 0)
		lowertemp.react()
		T.assume_air(lowertemp)
		qdel(hotspot)

	if (environment && environment.temperature > min_temperature) // Abstracted as steam or something
		var/removed_heat = between(0, volume * WATER_LATENT_HEAT, -environment.get_thermal_energy_change(min_temperature))
		environment.add_thermal_energy(-removed_heat)
		if (prob(5))
			T.visible_message(span_warning("The water sizzles as it lands on \the [T]!"))

	else if(volume >= 10)
		T.wet_floor(1)

/datum/reagent/water/touch_obj(var/obj/O, var/amount)
	..()
	if(istype(O, /obj/item/reagent_containers/food/snacks/monkeycube))
		var/obj/item/reagent_containers/food/snacks/monkeycube/cube = O
		if(!cube.wrapped)
			cube.Expand()
	else if(istype(O, /obj/item/reagent_containers/food/snacks/cube))
		var/obj/item/reagent_containers/food/snacks/cube/cube = O
		cube.Expand()
	else
		O.water_act(amount / 5)

/datum/reagent/water/touch_mob(var/mob/living/L, var/amount)
	..()
	if(istype(L))
		// First, kill slimes.
		if(istype(L, /mob/living/simple_mob/slime))
			var/mob/living/simple_mob/slime/S = L
			S.adjustToxLoss(15 * amount)
			S.visible_message(span_warning("[S]'s flesh sizzles where the water touches it!"), span_danger("Your flesh burns in the water!"))

		// Then extinguish people on fire.
		var/needed = max(0,L.fire_stacks) * 5
		if(amount > needed)
			L.ExtinguishMob()
		L.water_act(amount / 25) // Div by 25, as water_act multiplies it by 5 in order to calculate firestack modification.
		remove_self(needed)
		// Put out cigarettes if splashed.
		if(istype(L, /mob/living/carbon/human))
			var/mob/living/carbon/human/H = L
			if(H.wear_mask)
				if(istype(H.wear_mask, /obj/item/clothing/mask/smokable))
					var/obj/item/clothing/mask/smokable/S = H.wear_mask
					if(S.lit)
						S.quench()
						H.visible_message(span_notice("[H]\'s [S.name] is put out."))

//YWedit start, readds promethean damage that was removed by vorestation.
/datum/reagent/water/affect_blood(var/mob/living/carbon/M, var/alien, var/removed)
	if(alien == IS_SLIME)
		M.adjustToxLoss(6 * removed)
	else
		..()

/datum/reagent/water/affect_ingest(var/mob/living/carbon/M, var/alien, var/removed)
	if(alien == IS_SLIME)
		M.adjustToxLoss(6 * removed)
	else
		..()

/datum/reagent/water/affect_touch(var/mob/living/carbon/M, var/alien, var/removed)
	if(alien == IS_SLIME && prob(10))
		M.visible_message(span_warning("[M]'s flesh sizzles where the water touches it!"), span_danger("Your flesh burns in the water!"))
	..()
  //VOREStation Edit End,

#undef WATER_LATENT_HEAT

/datum/reagent/fuel
	name = "Welding fuel"
	id = "fuel"
	description = "Required for welders. Flamable."
	taste_description = "gross metal"
	reagent_state = LIQUID
	color = "#660000"

	glass_name = "welder fuel"
	glass_desc = "Unless you are an industrial tool, this is probably not safe for consumption."

/datum/reagent/fuel/touch_turf(var/turf/T, var/amount)
	..()
	new /obj/effect/decal/cleanable/liquid_fuel(T, amount, FALSE)
	remove_self(amount)
	return

/datum/reagent/fuel/affect_blood(var/mob/living/carbon/M, var/alien, var/removed)
	if(issmall(M)) removed *= 2
	M.adjustToxLoss(4 * removed)

/datum/reagent/fuel/touch_mob(var/mob/living/L, var/amount)
	..()
	if(istype(L))
		L.adjust_fire_stacks(amount / 10) // Splashing people with welding fuel to make them easy to ignite!
