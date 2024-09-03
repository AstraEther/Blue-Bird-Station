//Simulated
/turf/simulated/open/muriki
	edge_blending_priority = 0.5 //Turfs which also have e_b_p and higher than this will plop decorative edges onto this turf
/turf/simulated/open/muriki/New()
	..()
	if(outdoors)
		SSplanets.addTurf(src)

/turf/simulated/open
	dynamic_lighting = 1 //I don't care if there's no true multiz lighting, this looks so much nicer it's not even funny -KK (from turf_yw)

/turf/simulated/floor/indoorrocks //Not outdoor rocks to prevent weather fuckery
	name = "rocks"
	desc = "Hard as a rock."
	icon = 'icons/turf/outdoors.dmi'
	icon_state = "rock"
	edge_blending_priority = 1

/turf/simulated/mineral/vacuum
	oxygen = 0
	nitrogen = 0
	temperature	= TCMB
/turf/simulated/mineral/floor/vacuum
	oxygen = 0
	nitrogen = 0
	temperature	= TCMB
/turf/simulated/floor/shuttle/black
	icon = 'icons/turf/shuttle_white.dmi'
	icon_state = "floor_black"

	//This proc is responsible for ore generation on surface turfs
/turf/simulated/mineral/muriki/make_ore(var/rare_ore)
	if(mineral || ignore_mapgen)
		return
	var/mineral_name
	if(rare_ore)
		mineral_name = pickweight(list(
			"marble" = 3,
			"uranium" = 10,
			"platinum" = 10,
			"hematite" = 20,
			"carbon" = 20,
			"diamond" = 1,
			"gold" = 8,
			"silver" = 8,
			"phoron" = 18,
			"lead" = 2,
			"verdantium" = 1))
	else
		mineral_name = pickweight(list(
			"marble" = 2,
			"uranium" = 5,
			"platinum" = 5,
			"hematite" = 35,
			"carbon" = 35,
			"gold" = 3,
			"silver" = 3,
			"phoron" = 25,
			"lead" = 1))
	if(mineral_name && (mineral_name in GLOB.ore_data))
		mineral = GLOB.ore_data[mineral_name]
		UpdateMineral()
	update_icon()

/turf/simulated/mineral/muriki/rich/make_ore(var/rare_ore)
	if(mineral || ignore_mapgen)
		return
	var/mineral_name
	if(rare_ore)
		mineral_name = pickweight(list(
			"uranium" = 10,
			"platinum" = 10,
			"hematite" = 10,
			"carbon" = 10,
			"diamond" = 4,
			"gold" = 15,
			"silver" = 15))
	else
		mineral_name = pickweight(list(
			"uranium" = 7,
			"platinum" = 7,
			"hematite" = 28,
			"carbon" = 28,
			"diamond" = 2,
			"gold" = 7,
			"silver" = 7))
	if(mineral_name && (mineral_name in GLOB.ore_data))
		mineral = GLOB.ore_data[mineral_name]
		UpdateMineral()
	update_icon()

/turf/unsimulated/mineral/muriki
	blocks_air = TRUE

/turf/unsimulated/floor/steel
	icon = 'icons/turf/flooring/tiles_vr.dmi'
	icon_state = "steel"

/turf/unsimulated/wall
	blocks_air = 1

/turf/unsimulated/wall/planetary
	blocks_air = 0

// Some turfs to make floors look better in centcom tram station.
/turf/unsimulated/floor/techfloor_grid
	name = "floor"
	icon = 'icons/turf/flooring/techfloor.dmi'
	icon_state = "techfloor_grid"

/turf/unsimulated/floor/maglev
	name = "maglev track"
	desc = "Magnetic levitation tram tracks. Caution! Electrified!"
	icon = 'icons/turf/flooring/maglevs.dmi'
	icon_state = "maglevup"

/turf/unsimulated/wall/transit
	icon = 'icons/turf/transit_vr.dmi'

/turf/unsimulated/floor/transit
	icon = 'icons/turf/transit_vr.dmi'

/obj/effect/floor_decal/transit/orange
	icon = 'icons/turf/transit_vr.dmi'
	icon_state = "transit_techfloororange_edges"

/obj/effect/transit/light
	icon = 'icons/turf/transit_128.dmi'
	icon_state = "tube1-2"

// Bluespace jump turf!
/turf/space/bluespace
	name = "bluespace"
	icon = 'icons/turf/space_vr.dmi'
	icon_state = "bluespace"
/turf/space/bluespace/Initialize()
	..()
	icon = 'icons/turf/space_vr.dmi'
	icon_state = "bluespace"

// Desert jump turf!
/turf/space/sandyscroll
	name = "sand transit"
	icon = 'icons/turf/transit_vr.dmi'
	icon_state = "desert_ns"
/turf/space/sandyscroll/New()
	..()
	icon_state = "desert_ns"

//Sky stuff!
// A simple turf to fake the appearance of flying.
/turf/simulated/sky/muriki
	color = "#E0FFFF"

/turf/simulated/sky/muriki/Initialize()
	SSplanets.addTurf(src)
	set_light(2, 2, "#E0FFFF")

/turf/simulated/sky/muriki/north
	dir = NORTH
/turf/simulated/sky/muriki/south
	dir = SOUTH
/turf/simulated/sky/muriki/east
	dir = EAST
/turf/simulated/sky/muriki/west
	dir = WEST

/turf/simulated/sky/muriki/moving
	icon_state = "sky_fast"
/turf/simulated/sky/muriki/moving/north
	dir = NORTH
/turf/simulated/sky/muriki/moving/south
	dir = SOUTH
/turf/simulated/sky/muriki/moving/east
	dir = EAST
/turf/simulated/sky/muriki/moving/west
	dir = WEST

/turf/simulated/sky/snowscroll
	name = "snow transit"
	icon = 'icons/turf/transit_yw.dmi'
	icon_state = "snow_ns"

/turf/simulated/sky/snowscroll/Initialize()
	SSplanets.addTurf(src)
	set_light(2, 2, "#E0FFFF")

// TRAM USE  - TODO: Compare with existing maglev tracks on the virgo maps. I sense redundant code. Also needs to be moved to a higher level.
// The tram's electrified maglev tracks
/turf/simulated/floor/maglev
	name = "maglev track"
	desc = "Magnetic levitation tram tracks. Caution! Electrified!"
	icon = 'icons/turf/flooring/maglevs.dmi'
	icon_state = "maglevup"

	var/area/shock_area = /area/engineering/engine_smes // engine power hue hue hue

/turf/simulated/floor/maglev/Initialize()
	. = ..()
	shock_area = locate(shock_area)

// Walking on maglev tracks will shock you! Horray!
/turf/simulated/floor/maglev/Entered(var/atom/movable/AM, var/atom/old_loc)
	if(locate(/obj/structure/catwalk) in AM.loc)
		// safe to walk over!
		return
	if(isliving(AM) && prob(80))
		track_zap(AM)
/turf/simulated/floor/maglev/attack_hand(var/mob/user)
	if(prob(95))
		track_zap(user)
/turf/simulated/floor/maglev/proc/track_zap(var/mob/living/user)
	if (!istype(user)) return
	if (user.is_incorporeal()) return
	if (electrocute_mob(user, shock_area, src))
		var/datum/effect/effect/system/spark_spread/s = new /datum/effect/effect/system/spark_spread
		s.set_up(5, 1, src)
		s.start()

// override of newly added unsimulated deathdrop tile with black darkness appearance!
/turf/unsimulated/deathdrop/elevator_shaft
	death_message = "You fall into the elevator shaft, the thin atmosphere inside does little to slow you down and by the time you hit the bottom there is nothing more than a bloody smear. The damage you did to the elevator and the cost of your potential resleeve will be deducted from your pay."

/turf/simulated/deathdrop/elevator_shaft
	death_message = "You fall into the elevator shaft, the thin atmosphere inside does little to slow you down and by the time you hit the bottom there is nothing more than a bloody smear. The damage you did to the elevator and the cost of your potential resleeve will be deducted from your pay."

/turf/simulated/deathdrop/liminal
	death_message = "You pass into the empty darkness ahead of you, and fall into another repeating room. There is no way back. You cease to exist in the world you once called home. Now there is only the same room, over and over, over and over, over and over, over and over, over and over, over and over, over and over, over and over, over and over, over and over, over and over, over and over, over and over, over and over, over and over..."

/turf/simulated/deathdrop/liminal_home_pit
	death_message = "The wind rushes past you as you fall into the darkness... Then you wake up."

/turf/simulated/deathdrop/liminal_home_pit/Entered(atom/A)
	spawn(0)
		if(A.is_incorporeal())
			return
		if(istype( A, /atom/movable))
			var/atom/movable/AM = A
			if(!AM.can_fall()) // flying checks
				return
		if(ismob( A))
			var/mob/M = A
			var/list/redexitlist = list()
			for(var/obj/effect/landmark/R in landmarks_list)
				if(R.name == "redexit")
					redexitlist += R

			if(redexitlist.len > 0)
				var/obj/effect/landmark/L = pick( redexitlist)
				do_teleport(M, L.loc, 0,local = FALSE)
				to_chat( A, "<span class='danger'>[death_message]</span>")
				// passout on return to reality
				if(ishuman(M))
					var/mob/living/carbon/human/H = M
					H.AdjustSleeping(15)
					H.AdjustWeakened(3)
					H.adjustHalLoss(-9)

/turf/unsimulated/deathdrop/waterfall
	death_message = "The increasing speed and current of the river swiftly drags you into the rapids, destoying any boat you had and cracking your body against the rocks. The harsh acids of the water then make short work at dissolving your corpse, lost to the river forever."
	icon = 'icons/turf/outdoors_op.dmi'
	icon_state = "searapids" // So it shows up in the map editor as water.

/turf/simulated/deathdrop/waterfall
	death_message = "The increasing speed and current of the river swiftly drags you into the rapids, destoying any boat you had and cracking your body against the rocks. The harsh acids of the water then make short work at dissolving your corpse, lost to the river forever."
	icon = 'icons/turf/outdoors_op.dmi'
	icon_state = "searapids" // So it shows up in the map editor as water.
