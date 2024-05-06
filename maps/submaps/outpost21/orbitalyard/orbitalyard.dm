// This causes PoI maps to get 'checked' and compiled, when undergoing a unit test.
// This is so CI can validate PoIs, and ensure future changes don't break PoIs, as PoIs are loaded at runtime and the compiler can't catch errors.
// When adding a new PoI, please add it to this list.
#if MAP_TEST
#include "chunk_A.dmm"
#include "chunk_B.dmm"
#include "chunk_C.dmm"
#include "scaff_A.dmm"
#include "scaff_B.dmm"
#include "scaff_C.dmm"
#include "structure_A.dmm"
#include "giant_asteroid_A.dmm"
#include "structure_A.dmm"
#include "platform_A.dmm"
#include "container_LOST.dmm"
#endif

/datum/map_template/outpost21/space/orbitalyard
	name = "Space Content - Spooce"
	desc = "Used to fill extra space to explore in the orbital yard."
	annihilate = TRUE

/datum/map_template/outpost21/space/orbitalyard_huge
	name = "Space Content - Thats no moon"
	desc = "Used to make the orbital yard a FUN place to explore."
	annihilate = TRUE


//////////////////////////////////////////////////////////////
// Generic floating junk
/datum/map_template/outpost21/space/orbitalyard/chunk_A
	name = "Asteroid Variant A"
	desc = "Random asteroid."
	mappath = 'maps/submaps/outpost21/orbitalyard/chunk_A.dmm'
	allow_duplicates = TRUE
	cost = 5

/datum/map_template/outpost21/space/orbitalyard/chunk_B
	name = "Asteroid Variant B"
	desc = "Random asteroid."
	mappath = 'maps/submaps/outpost21/orbitalyard/chunk_B.dmm'
	allow_duplicates = TRUE
	cost = 5

/datum/map_template/outpost21/space/orbitalyard/chunk_C
	name = "Asteroid Variant C"
	desc = "Random asteroid."
	mappath = 'maps/submaps/outpost21/orbitalyard/chunk_C.dmm'
	allow_duplicates = TRUE
	cost = 5


/datum/map_template/outpost21/space/orbitalyard/scaff_A
	name = "Scaffolding Variant A"
	desc = "Random construction."
	mappath = 'maps/submaps/outpost21/orbitalyard/scaff_A.dmm'
	allow_duplicates = TRUE
	cost = 5

/datum/map_template/outpost21/space/orbitalyard/scaff_B
	name = "Scaffolding Variant B"
	desc = "Random construction."
	mappath = 'maps/submaps/outpost21/orbitalyard/scaff_B.dmm'
	allow_duplicates = TRUE
	cost = 5


/datum/map_template/outpost21/space/orbitalyard/scaff_C
	name = "Scaffolding Variant C"
	desc = "Random construction."
	mappath = 'maps/submaps/outpost21/orbitalyard/scaff_C.dmm'
	allow_duplicates = TRUE
	cost = 5


/datum/map_template/outpost21/space/orbitalyard/platform_A
	name = "Platform Variant A"
	desc = "Random platform."
	mappath = 'maps/submaps/outpost21/orbitalyard/platform_A.dmm'
	allow_duplicates = TRUE
	cost = 2


/datum/map_template/outpost21/space/orbitalyard/container_LOST
	name = "Lost Container"
	desc = "Random platform."
	mappath = 'maps/submaps/outpost21/orbitalyard/container_LOST.dmm'
	allow_duplicates = TRUE
	cost = 2

//////////////////////////////////////////////////////////////
// Huge structures in the yard (usually one at a time...)
/datum/map_template/outpost21/space/orbitalyard_huge/giant_asteroid_A
	name = "Giant Asteroid Variant A"
	desc = "Random Giant asteroid."
	mappath = 'maps/submaps/outpost21/orbitalyard/giant_asteroid_A.dmm'
	allow_duplicates = TRUE
	cost = 40

/datum/map_template/outpost21/space/orbitalyard_huge/giant_asteroid_B
	name = "Giant Asteroid Variant B"
	desc = "Random Giant asteroid."
	mappath = 'maps/submaps/outpost21/orbitalyard/giant_asteroid_B.dmm'
	allow_duplicates = FALSE // has secret in it
	fixed_orientation = TRUE
	cost = 50

/datum/map_template/outpost21/space/orbitalyard_huge/structure_A
	name = "Structure Variant A"
	desc = "Destroyed ruins of a facility."
	mappath = 'maps/submaps/outpost21/orbitalyard/structure_A.dmm'
	allow_duplicates = FALSE
	fixed_orientation = TRUE
	cost = 55

/datum/map_template/outpost21/space/orbitalyard_huge/structure_B
	name = "Structure Variant B"
	desc = "Destroyed ruins of a facility."
	mappath = 'maps/submaps/outpost21/orbitalyard/structure_B.dmm'
	allow_duplicates = FALSE
	fixed_orientation = TRUE
	cost = 55


//////////////////////////////////////////////////////////////
// Area definitions
/area/submap/outpost21/asteroid_generic
	name = "\improper Asteroids"
	icon_state = "red2"
	has_gravity = 0
	ambience = AMBIENCE_OUTPOST21_SPACE
	base_turf = /turf/space

/area/submap/outpost21/asteroid_generic/has_gravity()
	return 0

/area/submap/outpost21/structure_generic
	name = "\improper Ruined Facility"
	icon_state = "red2"
	has_gravity = 0
	ambience = AMBIENCE_OUTPOST21_SPACE
	base_turf = /turf/space

/area/submap/outpost21/structure_generic/has_gravity()
	return 0
