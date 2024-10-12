// Bitflags for mutations.
#define STRUCDNASIZE 27
#define   UNIDNASIZE 13

// Generic mutations:
#define TK              1
#define COLD_RESISTANCE 2
#define XRAY            3
#define HULK            4
#define CLUMSY          5
#define FAT             6
#define HUSK            7
#define NOCLONE         8
#define LASER           9  // Harm intent - click anywhere to shoot lasers from eyes.
#define HEAL            10 // Healing people with hands.
#define FLASHPROOF		11 // Outpost 21 edit - Flashproof eye genes replacing nif

#define SKELETON      29
#define PLANT         30

// Other Mutations:
#define mNobreath      100 // No need to breathe.
#define mRemote        101 // Remote viewing.
#define mRegen         102 // Health regeneration.
#define mRun           103 // No slowdown.
#define mRemotetalk    104 // Remote talking.
#define mMorph         105 // Hanging appearance.
#define mBlend         106 // Nothing. (seriously nothing)
#define mHallucination 107 // Hallucinations.
#define mFingerprints  108 // No fingerprints.
#define mShock         109 // Insulated hands.
#define mSmallsize     110 // Table climbing.

// disabilities
#define NEARSIGHTED 0x1
#define EPILEPSY    0x2
#define COUGHING    0x4
#define TOURETTES   0x8
#define NERVOUS     0x10
// Outpost 21 edit begin - more disabilities
#define DEPRESSION     	0x20	// Roleplay drugs
#define SCHIZOPHRENIA  	0x40	// Roleplay drugs
#define WINGDINGS     	0x80	// Better handling as disability
#define DETERIORATE     0x100	// Body melts slowly, medical loves you!
#define GIBBING     	0x200	// Landmine for genetics to find
#define CENSORED     	0x400	// Cannot swear
// Outpost 21 edit end

// sdisabilities
#define BLIND 0x1
#define MUTE  0x2
#define DEAF  0x4

/* Traitgenes edit - Blocks have finally been retired, huzzah!
// The way blocks are handled badly needs a rewrite, this is horrible.
// Too much of a project to handle at the moment, TODO for later.
var/BLINDBLOCK    = 0
var/DEAFBLOCK     = 0
var/HULKBLOCK     = 0
var/TELEBLOCK     = 0
var/FIREBLOCK     = 0
var/XRAYBLOCK     = 0
var/CLUMSYBLOCK   = 0
var/FAKEBLOCK     = 0
var/COUGHBLOCK    = 0
var/GLASSESBLOCK  = 0
var/EPILEPSYBLOCK = 0
var/TWITCHBLOCK   = 0
var/NERVOUSBLOCK  = 0
var/MONKEYBLOCK   = STRUCDNASIZE

var/BLOCKADD = 0
var/DIFFMUT  = 0

var/HEADACHEBLOCK      = 0
var/NOBREATHBLOCK      = 0
var/REMOTEVIEWBLOCK    = 0
var/REGENERATEBLOCK    = 0
var/INCREASERUNBLOCK   = 0
var/REMOTETALKBLOCK    = 0
var/MORPHBLOCK         = 0
var/BLENDBLOCK         = 0
var/HALLUCINATIONBLOCK = 0
var/NOPRINTSBLOCK      = 0
var/SHOCKIMMUNITYBLOCK = 0
var/SMALLSIZEBLOCK     = 0
*/

// Define block bounds (off-low,off-high,on-low,on-high)
// Used in setupgame.dm
#define DNA_DEFAULT_BOUNDS list(1,2049,2050,4095)
#define DNA_HARDER_BOUNDS  list(1,3049,3050,4095)
#define DNA_HARD_BOUNDS    list(1,3490,3500,4095)

// UI Indices (can change to mutblock style, if desired)
#define DNA_UI_HAIR_R      1
#define DNA_UI_HAIR_G      2
#define DNA_UI_HAIR_B      3
#define DNA_UI_BEARD_R     4
#define DNA_UI_BEARD_G     5
#define DNA_UI_BEARD_B     6
#define DNA_UI_SKIN_TONE   7
#define DNA_UI_SKIN_R      8
#define DNA_UI_SKIN_G      9
#define DNA_UI_SKIN_B      10
#define DNA_UI_EYES_R      11
#define DNA_UI_EYES_G      12
#define DNA_UI_EYES_B      13
#define DNA_UI_GENDER      14
#define DNA_UI_BEARD_STYLE 15
#define DNA_UI_HAIR_STYLE  16
#define DNA_UI_EAR_STYLE   17 // VOREStation snippet.
#define DNA_UI_TAIL_STYLE  18
#define DNA_UI_PLAYERSCALE 19
#define DNA_UI_TAIL_R      20
#define DNA_UI_TAIL_G      21
#define DNA_UI_TAIL_B      22
#define DNA_UI_TAIL2_R     23
#define DNA_UI_TAIL2_G     24
#define DNA_UI_TAIL2_B     25
#define DNA_UI_TAIL3_R     26
#define DNA_UI_TAIL3_G     27
#define DNA_UI_TAIL3_B     28
#define DNA_UI_EARS_R      29
#define DNA_UI_EARS_G      30
#define DNA_UI_EARS_B      31
#define DNA_UI_EARS2_R     32
#define DNA_UI_EARS2_G     33
#define DNA_UI_EARS2_B     34
#define DNA_UI_EARS3_R     35
#define DNA_UI_EARS3_G     36
#define DNA_UI_EARS3_B     37
#define DNA_UI_WING_STYLE  38
#define DNA_UI_WING_R      39
#define DNA_UI_WING_G      40
#define DNA_UI_WING_B      41
#define DNA_UI_WING2_R     42
#define DNA_UI_WING2_G     43
#define DNA_UI_WING2_B     44
#define DNA_UI_WING3_R     45
#define DNA_UI_WING3_G     46
#define DNA_UI_WING3_B     47 // VOREStation snippet end.
#define DNA_UI_LENGTH      47 // VOREStation Edit - Needs to match the highest number above.

#define DNA_SE_LENGTH 84 // Traitgenes edit - Expanded from 49 to 84, there have been a considerable expansion of genes.
// This leaves room for future expansion. This can be arbitrarily raised without worry if genes start to get crowded.
// The dna editor is 7 cols, and this should probably be multiples of it. Should have more than 10 empty genes after setup. - Willbird

//DNA modifiers
// Buffer datatype flags.
#define DNA2_BUF_UI 1
#define DNA2_BUF_UE 2
#define DNA2_BUF_SE 4
