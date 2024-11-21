/datum/trait/negative
	category = TRAIT_TYPE_NEGATIVE

/datum/trait/negative/speed_slow
	name = "Slowdown"
	desc = "Allows you to move slower on average than baseline."
	cost = -3
	var_changes = list("slowdown" = 0.5)
	banned_species = list(SPECIES_ALRAUNE, SPECIES_SHADEKIN_CREW, SPECIES_DIONA, SPECIES_UNATHI) //These are already this slow.
	custom_only = FALSE

/datum/trait/negative/speed_slow_plus
	name = "Slowdown, Major"
	desc = "Allows you to move MUCH slower on average than baseline."
	cost = -5
	var_changes = list("slowdown" = 1.0)
	custom_only = FALSE
	banned_species = list(SPECIES_DIONA) //Diona are even slower than this

/datum/trait/negative/weakling
	name = "Weakling"
	desc = "Causes heavy equipment to slow you down more when carried."
	cost = -1
	var_changes = list("item_slowdown_mod" = 1.5)
	custom_only = FALSE
	banned_species = list(SPECIES_SHADEKIN_CREW, SPECIES_TESHARI) //These are already this weak.

/datum/trait/negative/weakling_plus
	name = "Weakling, Major"
	desc = "Allows you to carry heavy equipment with much more slowdown."
	cost = -2
	var_changes = list("item_slowdown_mod" = 2.0)
	custom_only = FALSE
	banned_species = list(SPECIES_TESHARI) //These are already this weak.

/datum/trait/negative/endurance_low
	name = "Low Endurance"
	desc = "Reduces your maximum total hitpoints to 75.  You require only 150 damage in total to die, compared to 200 normally. You will go into crit after losing 75 HP, compared to crit at 100 HP." // CHOMPEdit: Clarity for players' sake.
	cost = -4  //Chompedit makes you a lot squishier, should not be only 2 points.  (based on the brute and burn vulnerability costs)
	var_changes = list("total_health" = 75)
	custom_only = FALSE
	banned_species = list(SPECIES_TESHARI, SPECIES_SHADEKIN_CREW) //These are already this weak.

/datum/trait/negative/endurance_low/apply(var/datum/species/S,var/mob/living/carbon/human/H)
	..()
	H.setMaxHealth(S.total_health)

/datum/trait/negative/endurance_very_low
	name = "Low Endurance, Major"
	desc = "Reduces your maximum total hitpoints to 50.  You require only 100 damage in total to die, compared to 200 normally. You will go into crit after losing 50 HP, compared to crit at 100 HP." // CHOMPEdit: Clarity for players' sake.
	cost = -8 //Teshari HP. This makes the person a lot more suseptable to getting stunned, killed, etc.  //Chompedit: Has no business being only 3 points, while others that function similarly but are nowhere near as crippling are 3 as well.
	var_changes = list("total_health" = 50)
	custom_only = FALSE
	banned_species = list(SPECIES_TESHARI) //These are already this weak.

/datum/trait/negative/endurance_very_low/apply(var/datum/species/S,var/mob/living/carbon/human/H)
	..()
	H.setMaxHealth(S.total_health)

/datum/trait/negative/minor_brute_weak
	name = "Brute Weakness, Minor"
	desc = "Increases damage from brute damage sources by 15%"
	cost = -1
	custom_only = FALSE
	var_changes = list("brute_mod" = 1.15)
	banned_species = list(SPECIES_TESHARI, SPECIES_TAJ, SPECIES_ZADDAT, SPECIES_SHADEKIN_CREW) //These are already this weak.

/datum/trait/negative/brute_weak
	name = "Brute Weakness"
	desc = "Increases damage from brute damage sources by 20%"
	cost = -2
	custom_only = FALSE
	var_changes = list("brute_mod" = 1.2) //ChompEDIT 25% --> 20%
	banned_species = list(SPECIES_TESHARI, SPECIES_SHADEKIN_CREW) //These are already this weak.

/datum/trait/negative/brute_weak_plus
	name = "Brute Weakness, Major"
	desc = "Increases damage from brute damage sources by 50%"
	cost = -3
	custom_only = FALSE
	var_changes = list("brute_mod" = 1.5)

/datum/trait/negative/minor_burn_weak
	name = "Burn Weakness, Minor"
	desc = "Increases damage from burn damage sources by 15%"
	cost = -1
	var_changes = list("burn_mod" = 1.15)

/datum/trait/negative/burn_weak
	name = "Burn Weakness"
	desc = "Increases damage from burn damage sources by 20%"
	cost = -2
	var_changes = list("burn_mod" = 1.2)

/datum/trait/negative/burn_weak_plus
	name = "Burn Weakness, Major"
	desc = "Increases damage from burn damage sources by 50%"
	cost = -3
	var_changes = list("burn_mod" = 1.5)

/datum/trait/negative/conductive
	name = "Conductive"
	desc = "Increases your susceptibility to electric shocks by 25%"
	cost = -2 //CHOMPEdit
	var_changes = list("siemens_coefficient" = 1.25) //This makes you a lot weaker to tasers.

/datum/trait/negative/conductive_plus
	name = "Conductive, Major"
	desc = "Increases your susceptibility to electric shocks by 100%"
	cost = -3 //CHOMPEdit
	var_changes = list("siemens_coefficient" = 2.0) //This makes you extremely weak to tasers.
	custom_only = FALSE
	varchange_type = TRAIT_VARCHANGE_LESS_BETTER

/datum/trait/negative/haemophilia
	name = "Haemophilia" // CHOMPEdit: Trait List Organization
	desc = "When you bleed, you bleed a LOT. Double the bloodloss rate." // CHOMPEdit: More Trait Feedback for players.
	cost = -2
	var_changes = list("bloodloss_rate" = 2)
	can_take = ORGANICS
	custom_only = FALSE
	varchange_type = TRAIT_VARCHANGE_LESS_BETTER

/datum/trait/negative/hollow
	name = "Hollow Bones/Aluminum Alloy"
	desc = "Your bones and robot limbs are much easier to break."
	cost = -3 // increased due to medical intervention needed.

/datum/trait/negative/hollow/apply(var/datum/species/S,var/mob/living/carbon/human/H)
	..()
	for(var/obj/item/organ/external/O in H.organs)
		O.min_broken_damage *= 0.5
		O.min_bruised_damage *= 0.5

/datum/trait/negative/lightweight
	name = "Lightweight"
	desc = "Your light weight and poor balance make you very susceptible to unhelpful bumping. Think of it like a bowling ball versus a pin. (STOP TAKING THIS AS SECURITY! We're MRP, so expect to lose your junk immediately, especially in events. - Love, Admins)" //CHOMP Edit btw
	cost = -2
	var_changes = list("lightweight" = 1)
	excludes = list(/datum/trait/negative/lightweight_light) //CHOMPedit Added a lesser version of this trait
	custom_only = FALSE

	// Traitgenes edit begin - Made into a gene trait
	is_genetrait = TRUE
	hidden = FALSE

	activation_message="You feel a little fragile..."
	// Traitgenes edit end

/datum/trait/negative/neural_hypersensitivity
	name = "Neural Hypersensitivity"
	desc = "Your nerves are particularly sensitive to physical changes, leading to experiencing twice the intensity of pain and pleasure alike. Makes all pain effects twice as strong, and occur at half as much damage."
	cost = -1
	var_changes = list("trauma_mod" = 2)
	can_take = ORGANICS
	custom_only = FALSE

/datum/trait/negative/breathes
	cost = -2
	can_take = ORGANICS

/datum/trait/negative/breathes/phoron
	name = "Phoron Breather"
	desc = "You breathe phoron instead of oxygen (which is poisonous to you), much like a Vox."
	var_changes = list("breath_type" = "phoron", "poison_type" = "oxygen", "ideal_air_type" = /datum/gas_mixture/belly_air/vox)

	// Traitgenes edit begin - Made into a gene trait
	is_genetrait = TRUE
	hidden = FALSE

	activation_message="Your chest hurts..."
	// Traitgenes edit end

/datum/trait/negative/breathes/nitrogen
	name = "Nitrogen Breather"
	desc = "You breathe nitrogen instead of oxygen (which is poisonous to you). Incidentally, phoron isn't poisonous to breathe to you."
	var_changes = list("breath_type" = "nitrogen", "poison_type" = "oxygen", "ideal_air_type" = /datum/gas_mixture/belly_air/nitrogen_breather)

	// Traitgenes edit begin - Made into a gene trait
	is_genetrait = TRUE
	hidden = FALSE

	activation_message="Your chest hurts..."
	// Traitgenes edit end

/datum/trait/negative/monolingual
	name = "Monolingual"
	desc = "You are not good at learning languages."
	cost = -1
	var_changes = list("num_alternate_languages" = 0)
	var_changes_pref = list("extra_languages" = -3)
	custom_only = FALSE
	varchange_type = TRAIT_VARCHANGE_MORE_BETTER

/datum/trait/negative/dark_blind
	name = "Nyctalopia"
	desc = "You cannot see in dark at all."
	cost = -1
	var_changes = list("darksight" = 0)
	custom_only = FALSE
	varchange_type = TRAIT_VARCHANGE_MORE_BETTER

/* // CHOMPedit: commented out because we disabled baymiss so this does nothing.
/datum/trait/negative/bad_shooter
	name = "Bad Shot"
	desc = "You are terrible at aiming."
	cost = -1
	var_changes = list("gun_accuracy_mod" = -35)
	custom_only = FALSE
	varchange_type = TRAIT_VARCHANGE_MORE_BETTER
*/

/datum/trait/negative/bad_swimmer
	name = "Bad Swimmer"
	desc = "You can't swim very well, all water slows you down a lot and you drown in deep water. You also swim up and down 25% slower."
	cost = -1
	custom_only = FALSE
	var_changes = list("bad_swimmer" = 1, "water_movement" = 4, "swim_mult" = 1.25)
	varchange_type = TRAIT_VARCHANGE_LESS_BETTER
	excludes = list(/datum/trait/positive/good_swimmer)
