/obj/item/weapon/dnainjector
	name = "\improper DNA injector"
	desc = "This injects the person with DNA."
	icon = 'icons/obj/items.dmi'
	icon_state = "dnainjector"
	var/block=0
	var/datum/dna2/record/buf=null
	var/s_time = 10.0
	throw_speed = 1
	throw_range = 5
	w_class = ITEMSIZE_TINY
	slot_flags = SLOT_EARS
	var/uses = 1
	var/nofail
	var/is_bullet = 0
	var/inuse = 0

	// USE ONLY IN PREMADE SYRINGES.  WILL NOT WORK OTHERWISE.
	var/datatype=0
	var/value=0

	// Traitgenes edit begin - Removed subtype, replaced with flag. Allows for safe injectors. Mostly for admin usage.
	var/has_radiation = TRUE
	// Traitgenes edit end

/obj/item/weapon/dnainjector/Initialize() // Traitgenes edit - Moved to init
	if(datatype && block)
		buf=new
		buf.dna=new
		buf.types = datatype
		buf.dna.ResetSE()
		//testing("[name]: DNA2 SE blocks prior to SetValue: [english_list(buf.dna.SE)]")
		SetValue(src.value)
		//testing("[name]: DNA2 SE blocks after SetValue: [english_list(buf.dna.SE)]")
	. = ..() // Traitgenes edit - Moved to init

/obj/item/weapon/dnainjector/proc/GetRealBlock(var/selblock)
	if(selblock==0)
		return block
	else
		return selblock

/obj/item/weapon/dnainjector/proc/GetState(var/selblock=0)
	var/real_block=GetRealBlock(selblock)
	if(buf.types&DNA2_BUF_SE)
		return buf.dna.GetSEState(real_block)
	else
		return buf.dna.GetUIState(real_block)

/obj/item/weapon/dnainjector/proc/SetState(var/on, var/selblock=0)
	var/real_block=GetRealBlock(selblock)
	if(buf.types&DNA2_BUF_SE)
		return buf.dna.SetSEState(real_block,on)
	else
		return buf.dna.SetUIState(real_block,on)

/obj/item/weapon/dnainjector/proc/GetValue(var/selblock=0)
	var/real_block=GetRealBlock(selblock)
	if(buf.types&DNA2_BUF_SE)
		return buf.dna.GetSEValue(real_block)
	else
		return buf.dna.GetUIValue(real_block)

/obj/item/weapon/dnainjector/proc/SetValue(var/val,var/selblock=0)
	var/real_block=GetRealBlock(selblock)
	if(buf.types&DNA2_BUF_SE)
		return buf.dna.SetSEValue(real_block,val)
	else
		return buf.dna.SetUIValue(real_block,val)

/obj/item/weapon/dnainjector/proc/inject(mob/M as mob, mob/user as mob)
	if(istype(M,/mob/living) && has_radiation)
		var/mob/living/L = M
		L.apply_effect(rand(5,20), IRRADIATE, check_protection = 0)
		L.apply_damage(max(2,L.getCloneLoss()), CLONE)

	if (!(NOCLONE in M.mutations) && !M.isSynthetic()) // prevents drained people from having their DNA changed, Traitgenes edit - Synthetics cannot be mutated
		if (buf.types & DNA2_BUF_UI)
			if (!block) //isolated block?
				M.UpdateAppearance(buf.dna.UI.Copy())
				if (buf.types & DNA2_BUF_UE) //unique enzymes? yes
					M.real_name = buf.dna.real_name
					M.name = buf.dna.real_name
				uses--
			else
				M.dna.SetUIValue(block,src.GetValue())
				M.UpdateAppearance()
				uses--
		if (buf.types & DNA2_BUF_SE)
			if (!block) //isolated block?
				M.dna.SE = buf.dna.SE.Copy()
				M.dna.UpdateSE()
			else
				M.dna.SetSEValue(block,src.GetValue())
			uses--
			// Traitgenes edit - Moved gene checks to after side effects
			if(prob(5))
				trigger_side_effect(M)
		// Traitgenes edit begin - Do gene updates here, and more comprehensively
		if(ishuman(M))
			var/mob/living/carbon/human/H = M
			H.sync_dna_traits(FALSE,FALSE)
			H.sync_organ_dna()
		M.regenerate_icons()
		// Traitgenes edit end

	spawn(0)//this prevents the collapse of space-time continuum
		if (user)
			user.drop_from_inventory(src)
		qdel(src)
	return uses

/obj/item/weapon/dnainjector/attack(mob/M as mob, mob/user as mob)
	if (!istype(M, /mob))
		return
	if (!usr.IsAdvancedToolUser())
		return
	if(inuse)
		return 0

	user.visible_message("<span class='danger'>\The [user] is trying to inject \the [M] with \the [src]!</span>")
	inuse = 1
	s_time = world.time
	spawn(50)
		inuse = 0

	if(!do_after(user,50))
		return

	user.setClickCooldown(DEFAULT_QUICK_COOLDOWN)
	user.do_attack_animation(M)

	M.visible_message("<span class='danger'>\The [M] has been injected with \the [src] by \the [user].</span>")

	var/mob/living/carbon/human/H = M
	if(!istype(H))
		to_chat(user, "<span class='warning'>Apparently it didn't work...</span>")
		return


	// Used by admin log.
	var/injected_with_monkey = ""
	/* Traitgenes edit - No monkey gene, doesn't work with the marking overlays anyway
	if((buf.types & DNA2_BUF_SE) && (block ? (GetState() && block == MONKEYBLOCK) : GetState(MONKEYBLOCK)))
		injected_with_monkey = " <span class='danger'>(MONKEY)</span>"
	*/

	add_attack_logs(user,M,"[injected_with_monkey] used the [name] on")

	// Apply the DNA shit.
	inject(M, user)
	return


// Traitgenes edit begin - Injectors are randomized now due to no hardcoded genes. Split into good or bad, and then versions that specify what they do on the label.
// Otherwise scroll down further for how to make unique injectors
/obj/item/weapon/dnainjector/proc/pick_block(var/datum/gene/trait/G, var/labeled, var/allow_disable)
	if(G)
		block = G.block
		datatype = DNA2_BUF_SE
		value = 0xFFF
		if(allow_disable)
			value = pick(0x000,0xFFF)
		if(labeled)
			name = initial(name) + " - [value == 0x000 ? "Removes" : ""] [G.get_name()]"

/obj/item/weapon/dnainjector/random
	name = "\improper DNA injector"
	desc = "This injects the person with DNA."

// Purely rando
/obj/item/weapon/dnainjector/random/Initialize()
	pick_block( pick(GLOB.dna_genes_good + GLOB.dna_genes_neutral + GLOB.dna_genes_bad), FALSE, TRUE)
	. = ..()

/obj/item/weapon/dnainjector/random_labeled/Initialize()
	pick_block( pick(GLOB.dna_genes_good + GLOB.dna_genes_neutral + GLOB.dna_genes_bad), TRUE, TRUE)
	. = ..()

// Good/bad but also neutral genes mixed in, less OP selection of genes
/obj/item/weapon/dnainjector/random_good/Initialize()
	pick_block( pick(GLOB.dna_genes_good + GLOB.dna_genes_neutral ), FALSE, TRUE)
	. = ..()

/obj/item/weapon/dnainjector/random_good_labeled/Initialize()
	pick_block( pick(GLOB.dna_genes_good + GLOB.dna_genes_neutral ), TRUE, TRUE)
	. = ..()

/obj/item/weapon/dnainjector/random_bad/Initialize()
	pick_block( pick(GLOB.dna_genes_bad + GLOB.dna_genes_neutral ), FALSE, TRUE)
	. = ..()

/obj/item/weapon/dnainjector/random_bad_labeled/Initialize()
	pick_block( pick(GLOB.dna_genes_bad + GLOB.dna_genes_neutral ), TRUE, TRUE)
	. = ..()

// Purely good/bad genes, intended to be usually good rewards or punishments
/obj/item/weapon/dnainjector/random_verygood/Initialize()
	pick_block( pick(GLOB.dna_genes_good), FALSE, FALSE)
	. = ..()

/obj/item/weapon/dnainjector/random_verygood_labeled/Initialize()
	pick_block( pick(GLOB.dna_genes_good), TRUE, FALSE)
	. = ..()

/obj/item/weapon/dnainjector/random_verybad/Initialize()
	pick_block( pick(GLOB.dna_genes_bad), FALSE, FALSE)
	. = ..()

/obj/item/weapon/dnainjector/random_verybad_labeled/Initialize()
	pick_block( pick(GLOB.dna_genes_bad), TRUE, FALSE)
	. = ..()

// Random neutral traits
/obj/item/weapon/dnainjector/random_neutral/Initialize()
	pick_block( pick(GLOB.dna_genes_neutral ), FALSE, TRUE)
	. = ..()

/obj/item/weapon/dnainjector/random_neutral_labeled/Initialize()
	pick_block( pick(GLOB.dna_genes_neutral ), TRUE, TRUE)
	. = ..()

// If you want a unique injector, use a subtype of these
/obj/item/weapon/dnainjector/set_trait
	var/trait_path

/obj/item/weapon/dnainjector/set_trait/Initialize()
	if(trait_path && GLOB.trait_to_dna_genes[trait_path])
		pick_block( GLOB.trait_to_dna_genes[trait_path], TRUE, FALSE)
	else
		qdel(src)
		return
	. = ..()

// Only has the superpowers for loot tables and other rewards
/obj/item/weapon/dnainjector/set_trait/hulk
	trait_path = /datum/trait/positive/superpower_hulk

/obj/item/weapon/dnainjector/set_trait/xray
	trait_path = /datum/trait/positive/superpower_xray

/obj/item/weapon/dnainjector/set_trait/tk
	trait_path = /datum/trait/positive/superpower_tk

/obj/item/weapon/dnainjector/set_trait/remotetalk
	trait_path = /datum/trait/positive/superpower_remotetalk

/obj/item/weapon/dnainjector/set_trait/remoteview
	trait_path = /datum/trait/positive/superpower_remoteview

/obj/item/weapon/dnainjector/set_trait/coldadapt
	trait_path = /datum/trait/neutral/coldadapt

/obj/item/weapon/dnainjector/set_trait/hotadapt
	trait_path = /datum/trait/neutral/hotadapt

/obj/item/weapon/dnainjector/set_trait/nobreathe
	trait_path = /datum/trait/positive/superpower_nobreathe

/obj/item/weapon/dnainjector/set_trait/regenerate
	trait_path = /datum/trait/positive/superpower_regenerate

/obj/item/weapon/dnainjector/set_trait/haste
	trait_path = /datum/trait/positive/speed_fast

/* Too out of date to port, only handles old UI values, can't do markings or other cosmetics... replace with promie verbs?
/obj/item/weapon/dnainjector/set_trait/morph
	trait_path = /datum/trait/positive/superpower_morph
*/

/obj/item/weapon/dnainjector/set_trait/nonconduct
	trait_path = /datum/trait/positive/nonconductive_plus

/obj/item/weapon/dnainjector/set_trait/table_passer
	trait_path = /datum/trait/positive/table_passer
// Traitgenes edit end


/* Traitgenes edit - Disable old injectors
/obj/item/weapon/dnainjector/hulkmut
	name = "\improper DNA injector (Hulk)"
	desc = "This will make you big and strong, but give you a bad skin condition."
	datatype = DNA2_BUF_SE
	value = 0xFFF

/obj/item/weapon/dnainjector/hulkmut/New()
	block = HULKBLOCK
	..()

/obj/item/weapon/dnainjector/antihulk
	name = "\improper DNA injector (Anti-Hulk)"
	desc = "Cures green skin."
	datatype = DNA2_BUF_SE
	value = 0x001

/obj/item/weapon/dnainjector/antihulk/New()
	block = HULKBLOCK
	..()

/obj/item/weapon/dnainjector/xraymut
	name = "\improper DNA injector (Xray)"
	desc = "Finally you can see what the Site Manager does."
	datatype = DNA2_BUF_SE
	value = 0xFFF

/obj/item/weapon/dnainjector/xraymut/New()
	block = XRAYBLOCK
	..()

/obj/item/weapon/dnainjector/antixray
	name = "\improper DNA injector (Anti-Xray)"
	desc = "It will make you see harder."
	datatype = DNA2_BUF_SE
	value = 0x001

/obj/item/weapon/dnainjector/antixray/New()
	block = XRAYBLOCK
	..()

/obj/item/weapon/dnainjector/firemut
	name = "\improper DNA injector (Fire)"
	desc = "Gives you fire."
	datatype = DNA2_BUF_SE
	value = 0xFFF

/obj/item/weapon/dnainjector/firemut/New()
	block = FIREBLOCK
	..()

/obj/item/weapon/dnainjector/antifire
	name = "\improper DNA injector (Anti-Fire)"
	desc = "Cures fire."
	datatype = DNA2_BUF_SE
	value = 0x001

/obj/item/weapon/dnainjector/antifire/New()
	block = FIREBLOCK
	..()

/obj/item/weapon/dnainjector/telemut
	name = "\improper DNA injector (Tele.)"
	desc = "Super brain man!"
	datatype = DNA2_BUF_SE
	value = 0xFFF

/obj/item/weapon/dnainjector/telemut/New()
	block = TELEBLOCK
	..()

/obj/item/weapon/dnainjector/antitele
	name = "\improper DNA injector (Anti-Tele.)"
	desc = "Will make you not able to control your mind."
	datatype = DNA2_BUF_SE
	value = 0x001

/obj/item/weapon/dnainjector/antitele/New()
	block = TELEBLOCK
	..()

/obj/item/weapon/dnainjector/nobreath
	name = "\improper DNA injector (No Breath)"
	desc = "Hold your breath and count to infinity."
	datatype = DNA2_BUF_SE
	value = 0xFFF

/obj/item/weapon/dnainjector/nobreath/New()
	block = NOBREATHBLOCK
	..()

/obj/item/weapon/dnainjector/antinobreath
	name = "\improper DNA injector (Anti-No Breath)"
	desc = "Hold your breath and count to 100."
	datatype = DNA2_BUF_SE
	value = 0x001

/obj/item/weapon/dnainjector/antinobreath/New()
	block = NOBREATHBLOCK
	..()

/obj/item/weapon/dnainjector/remoteview
	name = "\improper DNA injector (Remote View)"
	desc = "Stare into the distance for a reason."
	datatype = DNA2_BUF_SE
	value = 0xFFF

/obj/item/weapon/dnainjector/remoteview/New()
	block = REMOTEVIEWBLOCK
	..()

/obj/item/weapon/dnainjector/antiremoteview
	name = "\improper DNA injector (Anti-Remote View)"
	desc = "Cures green skin."
	datatype = DNA2_BUF_SE
	value = 0x001

/obj/item/weapon/dnainjector/antiremoteview/New()
	block = REMOTEVIEWBLOCK
	..()

/obj/item/weapon/dnainjector/regenerate
	name = "\improper DNA injector (Regeneration)"
	desc = "Healthy but hungry."
	datatype = DNA2_BUF_SE
	value = 0xFFF

/obj/item/weapon/dnainjector/regenerate/New()
	block = REGENERATEBLOCK
	..()

/obj/item/weapon/dnainjector/antiregenerate
	name = "\improper DNA injector (Anti-Regeneration)"
	desc = "Sickly but sated."
	datatype = DNA2_BUF_SE
	value = 0x001

/obj/item/weapon/dnainjector/antiregenerate/New()
	block = REGENERATEBLOCK
	..()

/obj/item/weapon/dnainjector/runfast
	name = "\improper DNA injector (Increase Run)"
	desc = "Running Man."
	datatype = DNA2_BUF_SE
	value = 0xFFF

/obj/item/weapon/dnainjector/runfast/New()
	block = INCREASERUNBLOCK
	..()

/obj/item/weapon/dnainjector/antirunfast
	name = "\improper DNA injector (Anti-Increase Run)"
	desc = "Walking Man."
	datatype = DNA2_BUF_SE
	value = 0x001

/obj/item/weapon/dnainjector/antirunfast/New()
	block = INCREASERUNBLOCK
	..()

/obj/item/weapon/dnainjector/morph
	name = "\improper DNA injector (Morph)"
	desc = "A total makeover."
	datatype = DNA2_BUF_SE
	value = 0xFFF

/obj/item/weapon/dnainjector/morph/New()
	block = MORPHBLOCK
	..()

/obj/item/weapon/dnainjector/antimorph
	name = "\improper DNA injector (Anti-Morph)"
	desc = "Cures identity crisis."
	datatype = DNA2_BUF_SE
	value = 0x001

/obj/item/weapon/dnainjector/antimorph/New()
	block = MORPHBLOCK
	..()

/obj/item/weapon/dnainjector/noprints
	name = "\improper DNA injector (No Prints)"
	desc = "Better than a pair of budget insulated gloves."
	datatype = DNA2_BUF_SE
	value = 0xFFF

/obj/item/weapon/dnainjector/noprints/New()
	block = NOPRINTSBLOCK
	..()

/obj/item/weapon/dnainjector/antinoprints
	name = "\improper DNA injector (Anti-No Prints)"
	desc = "Not quite as good as a pair of budget insulated gloves."
	datatype = DNA2_BUF_SE
	value = 0x001

/obj/item/weapon/dnainjector/antinoprints/New()
	block = NOPRINTSBLOCK
	..()

/obj/item/weapon/dnainjector/insulation
	name = "\improper DNA injector (Shock Immunity)"
	desc = "Better than a pair of real insulated gloves."
	datatype = DNA2_BUF_SE
	value = 0xFFF

/obj/item/weapon/dnainjector/insulation/New()
	block = SHOCKIMMUNITYBLOCK
	..()

/obj/item/weapon/dnainjector/antiinsulation
	name = "\improper DNA injector (Anti-Shock Immunity)"
	desc = "Not quite as good as a pair of real insulated gloves."
	datatype = DNA2_BUF_SE
	value = 0x001

/obj/item/weapon/dnainjector/antiinsulation/New()
	block = SHOCKIMMUNITYBLOCK
	..()

/obj/item/weapon/dnainjector/midgit
	name = "\improper DNA injector (Small Size)"
	desc = "Makes you shrink."
	datatype = DNA2_BUF_SE
	value = 0xFFF

/obj/item/weapon/dnainjector/midgit/New()
	block = SMALLSIZEBLOCK
	..()

/obj/item/weapon/dnainjector/antimidgit
	name = "\improper DNA injector (Anti-Small Size)"
	desc = "Makes you grow. But not too much."
	datatype = DNA2_BUF_SE
	value = 0x001

/obj/item/weapon/dnainjector/antimidgit/New()
	block = SMALLSIZEBLOCK
	..()

/////////////////////////////////////
/obj/item/weapon/dnainjector/antiglasses
	name = "\improper DNA injector (Anti-Glasses)"
	desc = "Toss away those glasses!"
	datatype = DNA2_BUF_SE
	value = 0x001

/obj/item/weapon/dnainjector/antiglasses/New()
	block = GLASSESBLOCK
	..()

/obj/item/weapon/dnainjector/glassesmut
	name = "\improper DNA injector (Glasses)"
	desc = "Will make you need dorkish glasses."
	datatype = DNA2_BUF_SE
	value = 0xFFF

/obj/item/weapon/dnainjector/glassesmut/New()
	block = GLASSESBLOCK
	..()

/obj/item/weapon/dnainjector/epimut
	name = "\improper DNA injector (Epi.)"
	desc = "Shake shake shake the room!"
	datatype = DNA2_BUF_SE
	value = 0xFFF

/obj/item/weapon/dnainjector/epimut/New()
	block = HEADACHEBLOCK
	..()

/obj/item/weapon/dnainjector/antiepi
	name = "\improper DNA injector (Anti-Epi.)"
	desc = "Will fix you up from shaking the room."
	datatype = DNA2_BUF_SE
	value = 0x001

/obj/item/weapon/dnainjector/antiepi/New()
	block = HEADACHEBLOCK
	..()

/obj/item/weapon/dnainjector/anticough
	name = "\improper DNA injector (Anti-Cough)"
	desc = "Will stop that awful noise."
	datatype = DNA2_BUF_SE
	value = 0x001

/obj/item/weapon/dnainjector/anticough/New()
	block = COUGHBLOCK
	..()

/obj/item/weapon/dnainjector/coughmut
	name = "\improper DNA injector (Cough)"
	desc = "Will bring forth a sound of horror from your throat."
	datatype = DNA2_BUF_SE
	value = 0xFFF

/obj/item/weapon/dnainjector/coughmut/New()
	block = COUGHBLOCK
	..()

/obj/item/weapon/dnainjector/clumsymut
	name = "\improper DNA injector (Clumsy)"
	desc = "Makes clumsy minions."
	datatype = DNA2_BUF_SE
	value = 0xFFF

/obj/item/weapon/dnainjector/clumsymut/New()
	block = CLUMSYBLOCK
	..()

/obj/item/weapon/dnainjector/anticlumsy
	name = "\improper DNA injector (Anti-Clumy)"
	desc = "Cleans up confusion."
	datatype = DNA2_BUF_SE
	value = 0x001

/obj/item/weapon/dnainjector/anticlumsy/New()
	block = CLUMSYBLOCK
	..()

/obj/item/weapon/dnainjector/antitour
	name = "\improper DNA injector (Anti-Tour.)"
	desc = "Will cure tourrets."
	datatype = DNA2_BUF_SE
	value = 0x001

/obj/item/weapon/dnainjector/antitour/New()
	block = TWITCHBLOCK
	..()

/obj/item/weapon/dnainjector/tourmut
	name = "\improper DNA injector (Tour.)"
	desc = "Gives you a nasty case off tourrets."
	datatype = DNA2_BUF_SE
	value = 0xFFF

/obj/item/weapon/dnainjector/tourmut/New()
	block = TWITCHBLOCK
	..()

/obj/item/weapon/dnainjector/stuttmut
	name = "\improper DNA injector (Stutt.)"
	desc = "Makes you s-s-stuttterrr"
	datatype = DNA2_BUF_SE
	value = 0xFFF

/obj/item/weapon/dnainjector/stuttmut/New()
	block = NERVOUSBLOCK
	..()

/obj/item/weapon/dnainjector/antistutt
	name = "\improper DNA injector (Anti-Stutt.)"
	desc = "Fixes that speaking impairment."
	datatype = DNA2_BUF_SE
	value = 0x001

/obj/item/weapon/dnainjector/antistutt/New()
	block = NERVOUSBLOCK
	..()

/obj/item/weapon/dnainjector/blindmut
	name = "\improper DNA injector (Blind)"
	desc = "Makes you not see anything."
	datatype = DNA2_BUF_SE
	value = 0xFFF

/obj/item/weapon/dnainjector/blindmut/New()
	block = BLINDBLOCK
	..()

/obj/item/weapon/dnainjector/antiblind
	name = "\improper DNA injector (Anti-Blind)"
	desc = "ITS A MIRACLE!!!"
	datatype = DNA2_BUF_SE
	value = 0x001

/obj/item/weapon/dnainjector/antiblind/New()
	block = BLINDBLOCK
	..()

/obj/item/weapon/dnainjector/deafmut
	name = "\improper DNA injector (Deaf)"
	desc = "Sorry, what did you say?"
	datatype = DNA2_BUF_SE
	value = 0xFFF

/obj/item/weapon/dnainjector/deafmut/New()
	block = DEAFBLOCK
	..()

/obj/item/weapon/dnainjector/antideaf
	name = "\improper DNA injector (Anti-Deaf)"
	desc = "Will make you hear once more."
	datatype = DNA2_BUF_SE
	value = 0x001

/obj/item/weapon/dnainjector/antideaf/New()
	block = DEAFBLOCK
	..()

/obj/item/weapon/dnainjector/hallucination
	name = "\improper DNA injector (Halluctination)"
	desc = "What you see isn't always what you get."
	datatype = DNA2_BUF_SE
	value = 0xFFF

/obj/item/weapon/dnainjector/hallucination/New()
	block = HALLUCINATIONBLOCK
	..()

/obj/item/weapon/dnainjector/antihallucination
	name = "\improper DNA injector (Anti-Hallucination)"
	desc = "What you see is what you get."
	datatype = DNA2_BUF_SE
	value = 0x001

/obj/item/weapon/dnainjector/antihallucination/New()
	block = HALLUCINATIONBLOCK
	..()

/obj/item/weapon/dnainjector/h2m
	name = "\improper DNA injector (Human > Monkey)"
	desc = "Will make you a flea bag."
	datatype = DNA2_BUF_SE
	value = 0xFFF

/obj/item/weapon/dnainjector/h2m/New()
	block = MONKEYBLOCK
	..()

/obj/item/weapon/dnainjector/m2h
	name = "\improper DNA injector (Monkey > Human)"
	desc = "Will make you...less hairy."
	datatype = DNA2_BUF_SE
	value = 0x001

/obj/item/weapon/dnainjector/m2h/New()
	block = MONKEYBLOCK
	..()
*/
