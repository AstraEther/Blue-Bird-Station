var/global/list/sheet_reagents = list( //have a number of reageents divisible by REAGENTS_PER_SHEET (default 20) unless you like decimals,
	/obj/item/stack/material/plastic = list("carbon","carbon","oxygen","chlorine","sulfur"),
	/obj/item/stack/material/copper = list("copper"),
	/obj/item/stack/material/tin = list("tin"),
	/obj/item/stack/material/wood = list("carbon","woodpulp","nitrogen","potassium","sodium"),
	/obj/item/stack/material/stick = list("carbon","woodpulp","nitrogen","potassium","sodium"),
	/obj/item/stack/material/log = list("carbon","woodpulp","nitrogen","potassium","sodium"),
	/obj/item/stack/material/algae = list("carbon","nitrogen","nitrogen","phosphorus","phosphorus"),
	/obj/item/stack/material/algae/ten = list("carbon","nitrogen","nitrogen","phosphorus","phosphorus"), // THIS, IS, STUPID
	/obj/item/stack/material/cardboard = list("paper"),
	/obj/item/stack/material/graphite = list("carbon"),
	/obj/item/stack/material/aluminium = list("aluminum"),
	/obj/item/stack/material/glass/reinforced = list("silicon","silicon","silicon","iron","carbon"),
	/obj/item/stack/material/leather = list("carbon","carbon","protein","protein","triglyceride"),
	/obj/item/stack/material/cloth = list("carbon","carbon","nitrogen","protein","sodium"),
	/obj/item/stack/material/fur = list("carbon","carbon","nitrogen","sulfur","sodium"),
	/obj/item/stack/material/fiber = list("carbon","carbon","nitrogen","potassium","sodium"),
	/obj/item/stack/material/deuterium = list("hydrogen"),
	/obj/item/stack/material/glass/phoronrglass = list("silicon","silicon","silicon","phoron","phoron"),
	/obj/item/stack/material/diamond = list("carbon"),
	/obj/item/stack/material/durasteel = list("iron","iron","carbon","carbon","platinum"),
	/obj/item/stack/material/wax = list("ethanol","triglyceride"),
	/obj/item/stack/material/bronze = list("copper","tin"),
	/obj/item/stack/material/titanium = list("titanium"),
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
	/obj/item/ore/glass = list("silicate"),
	/obj/item/ore/iron = list("iron"),
	/obj/item/ore/coal = list("carbon"),
	/obj/item/ore/copper = list("copper"),
	/obj/item/ore/tin = list("tin"),
	/obj/item/ore/void_opal = list("silicon","silicon","oxygen","water"),
	/obj/item/ore/painite = list("calcium","aluminum","oxygen","oxygen"),
	/obj/item/ore/quartz = list("silicon","oxygen"),
	/obj/item/ore/bauxite = list("aluminum","aluminum"),
	/obj/item/ore/phoron = list("phoron"),
	/obj/item/ore/silver = list("silver"),
	/obj/item/ore/gold = list("gold"),
	/obj/item/ore/marble = list("silicon","aluminum","aluminum","sodium","calcium"), // Some nice variety here
	/obj/item/ore/uranium = list("uranium"),
	/obj/item/ore/diamond = list("carbon"),
	/obj/item/ore/osmium = list("platinum"), // should be osmium
	/obj/item/ore/lead = list("lead"),
	/obj/item/ore/hydrogen = list("hydrogen"),
	/obj/item/ore/verdantium = list("radium","phoron","nitrogen","phosphorus","sodium"), // Some fun stuff to be useful with
	/obj/item/ore/rutile = list("titanium_diox")
)

var/global/list/reagent_sheets = list( // Recompressing reagents back into sheets
	"copper" 		= MAT_COPPER,
	"tin" 			= MAT_TIN,
	"paper" 		= "cardboard", // Why are you like this
	"woodpulp" 		= "cardboard", // Why are you like this
	"carbon" 		= MAT_GRAPHITE,
	"aluminum" 		= MAT_ALUMINIUM,
	"titanium" 		= MAT_TITANIUM,
	"iron" 			= MAT_IRON,
	"lead" 			= MAT_LEAD,
	"uranium"		= MAT_URANIUM,
	"phoron" 		= MAT_PHORON,
	"gold" 			= MAT_GOLD,
	"silver" 		= MAT_SILVER,
	"platinum" 		= MAT_PLATINUM,
	"silicon" 		= MAT_GLASS,
	// Mostly harmless
	"protein"		= "FLAG_SMOKE",
	"triglyceride" 	= "FLAG_SMOKE",
	"sodium"	 	= "FLAG_SMOKE",
	"phosphorus" 	= "FLAG_SMOKE",
	"ethanol" 		= "FLAG_SMOKE",
	// Extremely stupid ones
	"oxygen" 		= "FLAG_EXPLODE",
	"hydrogen" 		= "FLAG_EXPLODE",
	"supermatter" 	= "FLAG_EXPLODE",
	// Nothing is funnier to me
	"spideregg" 	= "FLAG_SPIDERS"
	)
