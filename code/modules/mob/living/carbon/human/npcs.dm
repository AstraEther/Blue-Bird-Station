/obj/item/clothing/under/punpun
	name = "fancy uniform"
	desc = "It looks like it was tailored for a monkey."
	icon_state = "punpun"
	worn_state = "punpun"
	has_sensor = 0
	species_restricted = list("Monkey")

/mob/living/carbon/human/monkey/punpun/Initialize()
	. = ..()
	name = "Pun Pun"
	real_name = name
	w_uniform = new /obj/item/clothing/under/punpun(src)
	species.produceCopy(species.traits.Copy(),src,null,FALSE) // Traitgenes edit - Make the spawned monkeys have unique species datums.
	// I don't know why the above doesn't work for other monkeys, but at least punpun is fixed for being map spawned...
	regenerate_icons()
	can_be_drop_prey = TRUE //CHOMP Add
