var/global/list/sheet_reagents = list( //have a number of reageents divisible by REAGENTS_PER_SHEET (default 20) unless you like decimals,
	/obj/item/stack/material/plastic = list("carbon","carbon","oxygen","chlorine","sulper"),
	/obj/item/stack/material/copper = list("copper"),
	/obj/item/stack/material/wood = list("carbon","woodpulp","nitrogen","potassium","sodium"),
	/obj/item/stack/material/stick = list("carbon","woodpulp","nitrogen","potassium","sodium"),
	/obj/item/stack/material/log = list("carbon","woodpulp","nitrogen","potassium","sodium"),
	/obj/item/stack/material/algae = list("carbon","nitrogen","nitrogen","phosphorus","phosphorus"),
	/obj/item/stack/material/cardboard = list("paper"),
	/obj/item/stack/material/graphite = list("carbon"),
	/obj/item/stack/material/aluminium = list("aluminium"),
	/obj/item/stack/material/glass/reinforced = list("silicon","silicon","silicon","iron","carbon"),
	/obj/item/stack/material/leather = list("carbon","carbon","protein","protein","triglyceride"),
	/obj/item/stack/material/cloth = list("carbon","carbon","carbon","protein","sodium"),
	/obj/item/stack/material/fiber = list("carbon","carbon","carbon","protein","sodium"),
	/obj/item/stack/material/fur = list("carbon","carbon","carbon","protein","sodium"),
	/obj/item/stack/material/deuterium = list("hydrogen"),
	/obj/item/stack/material/glass/phoronrglass = list("silicon","silicon","silicon","phoron","phoron"),
	/obj/item/stack/material/diamond = list("carbon"),
	/obj/item/stack/material/durasteel = list("iron","iron","carbon","carbon","platinum"),
	/obj/item/stack/material/wax = list("ethanol","triglyceride"),
	// Original grinder
	/obj/item/stack/material/iron = list("iron"),
	/obj/item/stack/material/uranium = list("uranium"),
	/obj/item/stack/material/phoron = list("phoron"),
	/obj/item/stack/material/gold = list("gold"),
	/obj/item/stack/material/silver = list("silver"),
	/obj/item/stack/material/platinum = list("platinum"),
	/obj/item/stack/material/mhydrogen = list("hydrogen"),
	/obj/item/stack/material/steel = list("iron", "carbon"),
	/obj/item/stack/material/plasteel = list("iron", "iron", "carbon", "carbon", "platinum"), //8 iron, 8 carbon, 4 platinum,
	/obj/item/stack/material/snow = list("water"),
	/obj/item/stack/material/sandstone = list("silicon", "oxygen"),
	/obj/item/stack/material/glass = list("silicon"),
	/obj/item/stack/material/glass/phoronglass = list("platinum", "silicon", "silicon", "silicon"), //5 platinum, 15 silicon,
	/obj/item/stack/material/supermatter = list("supermatter")
	)

var/global/list/ore_reagents = list( //have a number of reageents divisible by REAGENTS_PER_ORE (default 20) unless you like decimals.
	/obj/item/weapon/ore/glass = list("silicon"),
	/obj/item/weapon/ore/iron = list("iron"),
	/obj/item/weapon/ore/coal = list("carbon"),
	///obj/item/weapon/ore/copper = list("copper"),
	///obj/item/weapon/ore/tin = list("tin"),
	///obj/item/weapon/ore/void_opal = list("silicon","silicon","oxygen","water"),
	///obj/item/weapon/ore/painite = list("calcium","aluminum","oxygen","oxygen"),
	///obj/item/weapon/ore/quartz = list("silicon","oxygen"),
	///obj/item/weapon/ore/bauxite = list("aluminum","aluminum"),
	/obj/item/weapon/ore/phoron = list("phoron"),
	/obj/item/weapon/ore/silver = list("silver"),
	/obj/item/weapon/ore/gold = list("gold"),
	/obj/item/weapon/ore/marble = list("silicon","aluminum","aluminum","sodium","calcium"), // Some nice variety here
	/obj/item/weapon/ore/uranium = list("uranium"),
	/obj/item/weapon/ore/diamond = list("carbon"),
	/obj/item/weapon/ore/osmium = list("platinum"), // should be osmium
	/obj/item/weapon/ore/lead = list("lead"),
	/obj/item/weapon/ore/hydrogen = list("hydrogen"),
	/obj/item/weapon/ore/verdantium = list("radium","phoron","nitrogen","phosphorus","sodium"), // Some fun stuff to be useful with
	/obj/item/weapon/ore/rutile = list("tungsten","oxygen") // Should be titanium
)
