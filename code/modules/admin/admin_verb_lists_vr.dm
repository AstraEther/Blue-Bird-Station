//admin verb groups - They can overlap if you so wish. Only one of each verb will exist in the verbs list regardless
var/list/admin_verbs_default = list(
//	/datum/admins/proc/show_player_panel,	//shows an interface for individual players, with various links (links require additional flags, //VOREStation Remove,
//	/client/proc/player_panel_new, //shows an interface for all players, with links to various panels, //VOREStation Remove,
//	/client/proc/player_panel,			//VOREStation Remove,
	/client/proc/deadmin_self,			//destroys our own admin datum so we can play as a regular player,
	/client/proc/cmd_admin_say,			//VOREStation Add,
	/client/proc/cmd_mod_say,			//VOREStation Add,
	/client/proc/cmd_event_say,			//VOREStation Add,
	/client/proc/cmd_mentor_ticket_panel,
	/client/proc/cmd_mentor_say,
//	/client/proc/hide_verbs,			//hides all our adminverbs, //VOREStation Remove,
//	/client/proc/hide_most_verbs,		//hides all our hideable adminverbs, //VOREStation Remove,
//	/client/proc/debug_variables,		//allows us to -see- the variables of any instance in the game. +VAREDIT needed to modify, //VOREStation Remove,
//	/client/proc/mark_datum_mapview,	//VOREStation Remove,
//	/client/proc/cmd_check_new_players,	//allows us to see every new player, //VOREStation Remove,
//	/client/proc/check_antagonists,		//shows all antags,
//	/client/proc/cmd_mod_say,
//	/client/proc/deadchat				//toggles deadchat on/off,
//	/client/proc/toggle_ahelp_sound,
	/client/proc/debugstatpanel,
	)

var/list/admin_verbs_admin = list(
	/client/proc/toggle_vantag_hud,
	/datum/admins/proc/set_tcrystals,
	/datum/admins/proc/add_tcrystals,
	/client/proc/invisimin,				//allows our mob to go invisible/visible,
	/datum/admins/proc/show_traitor_panel,	//interface which shows a mob's mind.,
	/datum/admins/proc/show_game_mode,  //Configuration window for the current game mode.,
	/datum/admins/proc/force_mode_latespawn, //Force the mode to try a latespawn proc,
	/datum/admins/proc/force_antag_latespawn, //Force a specific template to try a latespawn proc,
	/datum/admins/proc/toggleenter,		//toggles whether people can join the current game,
	/datum/admins/proc/toggleguests,	//toggles whether guests can join the current game,
	/datum/admins/proc/announce,		//priority announce something to all clients.,
	/datum/admins/proc/intercom,		//send a fake intercom message, like an arrivals announcement,
	/datum/admins/proc/intercom_convo,	//send a fake intercom conversation, like an ATC exchange,
	/client/proc/colorooc,				//allows us to set a custom colour for everythign we say in ooc,
	/client/proc/admin_ghost,			//allows us to ghost/reenter body at will,
	/datum/admins/proc/show_player_panel,	//shows an interface for individual players, with various links (links require additional flags, //VOREStation Add,
	/client/proc/player_panel_new, //shows an interface for all players, with links to various panels, //VOREStation Add,
	/client/proc/player_panel,			//VOREStation Add,
	/client/proc/hide_verbs,			//hides all our adminverbs, //VOREStation Add,
	/client/proc/hide_most_verbs,		//hides all our hideable adminverbs, //VOREStation Add,
	/client/proc/debug_variables,		//allows us to -see- the variables of any instance in the game. +VAREDIT needed to modify, //VOREStation Add,
	/client/proc/mark_datum_mapview,	//VOREStation Add,
	/client/proc/cmd_check_new_players,	//allows us to see every new player, //VOREStation Add,
	/client/proc/toggle_view_range,		//changes how far we can see,
	/datum/admins/proc/view_txt_log,	//shows the server log (diary) for today,
	/datum/admins/proc/view_atk_log,	//shows the server combat-log, doesn't do anything presently,
	/client/proc/cmd_admin_pm_context,	//right-click adminPM interface,
	/client/proc/cmd_admin_pm_panel,	//admin-pm list,
	/client/proc/cmd_admin_subtle_message,	//send an message to somebody as a 'voice in their head',
	/client/proc/cmd_admin_delete,		//delete an instance/object/mob/etc,
	/client/proc/cmd_admin_check_contents,	//displays the contents of an instance,
	/client/proc/cmd_admin_check_player_logs,	//checks a player's attack logs,
	/client/proc/cmd_admin_check_dialogue_logs,	//checks a player's dialogue logs,
	/datum/admins/proc/access_news_network,	//allows access of newscasters,
	/client/proc/giveruntimelog,		//allows us to give access to runtime logs to somebody,
	/client/proc/getserverlog,			//allows us to fetch server logs (diary) for other days,
	/client/proc/jumptocoord,			//we ghost and jump to a coordinate,
	/client/proc/Getmob,				//teleports a mob to our location,
	/client/proc/Getkey,				//teleports a mob with a certain ckey to our location,
//	/client/proc/sendmob,				//sends a mob somewhere, -Removed due to it needing two sorting procs to work, which were executed every time an admin right-clicked. ~Errorage,
	/client/proc/Jump,
	/client/proc/jumptokey,				//allows us to jump to the location of a mob with a certain ckey,
	/client/proc/jumptomob,				//allows us to jump to a specific mob,
	/client/proc/jumptoturf,			//allows us to jump to a specific turf,
	/client/proc/admin_call_shuttle,	//allows us to call the emergency shuttle,
	/client/proc/admin_cancel_shuttle,	//allows us to cancel the emergency shuttle, sending it back to CentCom,
	/client/proc/cmd_admin_direct_narrate,	//send text directly to a player with no padding. Useful for narratives and fluff-text,
	/client/proc/cmd_admin_world_narrate,	//sends text to all players with no padding,
	/client/proc/cmd_admin_z_narrate, //VOREStation Add,
	/client/proc/cmd_admin_create_centcom_report,
	/client/proc/check_words,			//displays cult-words,
	/client/proc/check_ai_laws,			//shows AI and borg laws,
	/client/proc/rename_silicon,		//properly renames silicons,
	/client/proc/manage_silicon_laws,	// Allows viewing and editing silicon laws. ,
	/client/proc/modify_robot,
	/client/proc/check_antagonists,
	/client/proc/admin_memo,			//admin memo system. show/delete/write. +SERVER needed to delete admin memos of others,
	/client/proc/dsay,					//talk in deadchat using our ckey/fakekey,
//	/client/proc/toggle_hear_deadcast,	//toggles whether we hear deadchat,
	/client/proc/investigate_show,		//various admintools for investigation. Such as a singulo grief-log,
	/client/proc/secrets,
	/datum/admins/proc/toggleooc,		//toggles ooc on/off for everyone,
	/datum/admins/proc/togglelooc,		//toggles looc on/off for everyone,
	/datum/admins/proc/toggleoocdead,	//toggles ooc on/off for everyone who is dead,
	/datum/admins/proc/togglehubvisibility, //toggles visibility on the BYOND Hub.,
	/datum/admins/proc/toggledsay,		//toggles dsay on/off for everyone,
	/client/proc/game_panel,			//game panel, allows to change game-mode etc,
	/client/proc/cmd_admin_say,			//admin-only ooc chat,
	/client/proc/cmd_mod_say,
	/client/proc/cmd_event_say,
	/datum/admins/proc/PlayerNotes,
	/datum/admins/proc/show_player_info,
	/client/proc/free_slot,			//frees slot for chosen job,
	/client/proc/cmd_admin_change_custom_event,
	/client/proc/cmd_admin_rejuvenate,
	/client/proc/toggleghostwriters,
	/client/proc/toggledrones,
	/datum/admins/proc/show_skills,
	/client/proc/check_customitem_activity,
	/client/proc/man_up,
	/client/proc/global_man_up,
	/client/proc/response_team, // Response Teams admin verb,
	/client/proc/trader_ship, // Trader ship admin verb,
	/client/proc/toggle_antagHUD_use,
	/client/proc/toggle_antagHUD_restrictions,
	/client/proc/allow_character_respawn,    // Allows a ghost to respawn ,
	/client/proc/event_manager_panel,
	/client/proc/empty_ai_core_toggle_latejoin,
	/client/proc/empty_ai_core_toggle_latejoin,
	/client/proc/aooc,
	/client/proc/change_human_appearance_admin,	// Allows an admin to change the basic appearance of human-based mobs ,
	/client/proc/change_human_appearance_self,	// Allows the human-based mob itself change its basic appearance ,
	/client/proc/change_security_level,
	/client/proc/view_chemical_reaction_logs,
	/client/proc/makepAI,
	/datum/admins/proc/paralyze_mob,
	/client/proc/fixatmos,
	/* Outpost 21 edit - Nif removal
	/datum/admins/proc/quick_nif, //VOREStation Add,
	/datum/admins/proc/quick_authentic_nif, //CHOMPStation add
	*/
	/datum/admins/proc/set_uplink, //VOREStation Add,
	/datum/admins/proc/sendFax,
	/client/proc/despawn_player,
	/datum/admins/proc/view_feedback,
	/client/proc/make_mentor,
	/client/proc/unmake_mentor,
	/client/proc/removetickets,
	/client/proc/delbook,
	/client/proc/toggle_spawning_with_recolour,
	/client/proc/start_vote,
	/client/proc/reload_jobwhitelist, //ChompADD
	/client/proc/reload_alienwhitelist //ChompADD
	)

var/list/admin_verbs_ban = list(
	/client/proc/unban_panel,
	/client/proc/jobbans
	)

var/list/admin_verbs_sounds = list(
	/client/proc/play_local_sound,
	/client/proc/play_sound,
	/client/proc/play_server_sound,
	/client/proc/play_web_sound,
	/client/proc/play_z_sound
	)

var/list/admin_verbs_fun = list(
	/client/proc/object_talk,
	/datum/admins/proc/cmd_admin_dress,
	/client/proc/cmd_admin_gib_self,
	/client/proc/drop_bomb,
	/client/proc/everyone_random,
	/client/proc/cinematic,
	/datum/admins/proc/toggle_aliens,
	/datum/admins/proc/toggle_space_ninja,
	/client/proc/cmd_admin_add_freeform_ai_law,
	/client/proc/cmd_admin_add_random_ai_law,
	/client/proc/make_sound,
	/client/proc/toggle_random_events,
	/client/proc/editappear,
	/client/proc/roll_dices,
	/datum/admins/proc/call_supply_drop,
	/datum/admins/proc/call_drop_pod,
//	/client/proc/smite,  //Replaced by player_effects
	/client/proc/player_effects,
	/client/proc/admin_lightning_strike,
	/client/proc/resize, //VOREStation Add,
	/client/proc/tgui_admin_lists, //CHOMPStation Add
	/client/proc/cmd_admin_droppod_deploy,
	/client/proc/adminorbit, //VOREStation Add
	/client/proc/add_mob_for_narration,	//VOREStation Add
	/client/proc/remove_mob_for_narration,	//VOREStation Add
	/client/proc/narrate_mob,	//VOREStation Add
	/client/proc/narrate_mob_args, //VOREStation Add
	/client/proc/getPlayerStatus, //VORESTation Add
	/client/proc/manage_event_triggers,
	/client/proc/fake_pdaconvos

	)

var/list/admin_verbs_spawn = list(
	/datum/admins/proc/spawn_fruit,
	/datum/admins/proc/spawn_custom_item,
	/datum/admins/proc/check_custom_items,
	/datum/admins/proc/spawn_plant,
	/datum/admins/proc/spawn_atom,		//allows us to spawn instances,
	/datum/admins/proc/spawn_mail,	// CHOMPStation Add
	/client/proc/cmd_admin_droppod_spawn,
	/client/proc/respawn_character,
	/client/proc/spawn_character_mob,  //VOREStation Add,
	/client/proc/spawn_chemdisp_cartridge,
	/client/proc/map_template_load,
	/client/proc/map_template_upload,
	/client/proc/map_template_load_on_new_z,
	/client/proc/eventkit_open_mob_spawner,
	/client/proc/generic_structure, //VOREStation Add
	/client/proc/generic_item, //VOREStation Add
	/client/proc/create_gm_message,
	/client/proc/remove_gm_message,
	/client/proc/AdminCreateVirus,
	/client/proc/ReleaseVirus
	)

var/list/admin_verbs_server = list(
	/datum/admins/proc/capture_map,
	/client/proc/Set_Holiday,
	/client/proc/ToRban,
	/datum/admins/proc/startnow,
	/datum/admins/proc/restart,
	/datum/admins/proc/delay,
	/datum/admins/proc/toggleaban,
	/datum/admins/proc/togglepersistence,
	/client/proc/cmd_mod_say,
	/client/proc/toggle_log_hrefs,
	/datum/admins/proc/immreboot,
	/client/proc/everyone_random,
	/datum/admins/proc/toggleAI,
	/client/proc/cmd_admin_delete,		//delete an instance/object/mob/etc,
	/client/proc/cmd_debug_del_all,
	/datum/admins/proc/adrev,
	/datum/admins/proc/adspawn,
	/datum/admins/proc/adjump,
	/datum/admins/proc/toggle_aliens,
	/datum/admins/proc/toggle_space_ninja,
	/client/proc/toggle_random_events,
	/client/proc/check_customitem_activity,
	/client/proc/modify_server_news,
	/client/proc/recipe_dump,
	/client/proc/panicbunker,
	/client/proc/paranoia_logging,
	/client/proc/ip_reputation
	)

var/list/admin_verbs_debug = list(
	/client/proc/reload_configuration, // CHOMPEdit
	/client/proc/getruntimelog,                     //allows us to access runtime logs to somebody,
	/client/proc/cmd_admin_list_open_jobs,
	/client/proc/Debug2,
	/client/proc/kill_air,
	/client/proc/ZASSettings,
	/client/proc/cmd_debug_make_powernets,
	/client/proc/kill_airgroup,
	/client/proc/debug_controller,
	/client/proc/debug_antagonist_template,
	/client/proc/cmd_debug_mob_lists,
	/client/proc/cmd_debug_using_map,
	/client/proc/cmd_admin_delete,
	/client/proc/cmd_debug_del_all,
	/client/proc/cmd_debug_tog_aliens,
	/client/proc/cmd_display_del_log,
	/client/proc/cmd_display_init_log,
	// /client/proc/cmd_display_overlay_log,
	/client/proc/air_report,
	/client/proc/reload_admins,
	/client/proc/reload_eventMs,
	/client/proc/restart_controller,
	/datum/admins/proc/restart,
	/client/proc/print_random_map,
	/client/proc/create_random_map,
	/client/proc/apply_random_map,
	/client/proc/overlay_random_map,
	/client/proc/delete_random_map,
	/client/proc/show_plant_genes,
	/client/proc/enable_debug_verbs,
	/client/proc/callproc,
	/client/proc/callproc_datum,
	/client/proc/SDQL2_query,
	/client/proc/Jump,
	/client/proc/jumptomob,
	/client/proc/jumptocoord,
	/client/proc/dsay,
	/client/proc/admin_ghost,			//allows us to ghost/reenter body at will,
	/datum/admins/proc/show_player_panel,	//shows an interface for individual players, with various links (links require additional flags, //VOREStation Add,
	/client/proc/player_panel_new, //shows an interface for all players, with links to various panels, //VOREStation Add,
	/client/proc/player_panel,			//VOREStation Add,
	/client/proc/hide_verbs,			//hides all our adminverbs, //VOREStation Add,
	/client/proc/hide_most_verbs,		//hides all our hideable adminverbs, //VOREStation Add,
	/client/proc/debug_variables,		//allows us to -see- the variables of any instance in the game. +VAREDIT needed to modify, //VOREStation Add,
	/client/proc/mark_datum_mapview,	//VOREStation Add,
	/client/proc/cmd_check_new_players,	//allows us to see every new player, //VOREStation Add,
	/datum/admins/proc/view_runtimes,
	// /client/proc/show_gm_status, // VOREStation Edit - We don't use SSgame_master yet.
	/datum/admins/proc/set_uplink, //VOREStation Add,
	/datum/admins/proc/change_weather,
	/datum/admins/proc/change_time,
	/client/proc/admin_give_modifier,
	/client/proc/simple_DPS,
	/datum/admins/proc/view_feedback,
	/client/proc/stop_sounds,
	/* Outpost 21 edit - Nif removal
	/datum/admins/proc/quick_nif, //CHOMPStation Add,
	/datum/admins/proc/quick_authentic_nif, //CHOMPStation add
	*/
	/client/proc/reload_jobwhitelist, //ChompADD
	/client/proc/reload_alienwhitelist //ChompADD
	)

var/list/admin_verbs_paranoid_debug = list(
	/client/proc/callproc,
	/client/proc/callproc_datum,
	/client/proc/debug_controller
	)

var/list/admin_verbs_possess = list(
	/proc/possess,
	/proc/release
	)
var/list/admin_verbs_permissions = list(
	/client/proc/edit_admin_permissions
	)
var/list/admin_verbs_rejuv = list(
	/client/proc/respawn_character
	)

//verbs which can be hidden - needs work
var/list/admin_verbs_hideable = list(
	/client/proc/deadmin_self,
//	/client/proc/deadchat,
	/datum/admins/proc/show_traitor_panel,
	/datum/admins/proc/toggleenter,
	/datum/admins/proc/toggleguests,
	/datum/admins/proc/announce,
	/client/proc/colorooc,
	/client/proc/admin_ghost,
	/client/proc/toggle_view_range,
	/datum/admins/proc/view_txt_log,
	/datum/admins/proc/view_atk_log,
	/client/proc/cmd_admin_subtle_message,
	/client/proc/cmd_admin_check_contents,
	/client/proc/cmd_admin_check_player_logs,
	/client/proc/cmd_admin_check_dialogue_logs,
	/datum/admins/proc/access_news_network,
	/client/proc/admin_call_shuttle,
	/client/proc/admin_cancel_shuttle,
	/client/proc/cmd_admin_direct_narrate,
	/client/proc/cmd_admin_world_narrate,
	/client/proc/cmd_admin_z_narrate, //VOREStation Add,
	/client/proc/check_words,
	/client/proc/play_local_sound,
	/client/proc/play_sound,
	/client/proc/play_server_sound,
	/client/proc/play_web_sound,
	/client/proc/object_talk,
	/datum/admins/proc/cmd_admin_dress,
	/client/proc/cmd_admin_gib_self,
	/client/proc/drop_bomb,
	/client/proc/cinematic,
	/datum/admins/proc/toggle_aliens,
	/datum/admins/proc/toggle_space_ninja,
	/client/proc/cmd_admin_add_freeform_ai_law,
	/client/proc/cmd_admin_add_random_ai_law,
	/client/proc/cmd_admin_create_centcom_report,
	/client/proc/make_sound,
	/client/proc/toggle_random_events,
	/client/proc/cmd_admin_add_random_ai_law,
	/client/proc/Set_Holiday,
	/client/proc/ToRban,
	/datum/admins/proc/startnow,
	/datum/admins/proc/restart,
	/datum/admins/proc/delay,
	/datum/admins/proc/toggleaban,
	/client/proc/toggle_log_hrefs,
	/datum/admins/proc/immreboot,
	/client/proc/everyone_random,
	/datum/admins/proc/toggleAI,
	/datum/admins/proc/adrev,
	/datum/admins/proc/adspawn,
	/datum/admins/proc/adjump,
	/client/proc/restart_controller,
	/client/proc/cmd_admin_list_open_jobs,
	/client/proc/callproc,
	/client/proc/callproc_datum,
	/client/proc/Debug2,
	/client/proc/reload_admins,
	/client/proc/kill_air,
	/client/proc/cmd_debug_make_powernets,
	/client/proc/kill_airgroup,
	/client/proc/debug_controller,
	/client/proc/startSinglo,
	/client/proc/simple_DPS,
	/client/proc/cmd_debug_mob_lists,
	/client/proc/cmd_debug_using_map,
	/client/proc/cmd_debug_del_all,
	/client/proc/cmd_debug_tog_aliens,
	/client/proc/cmd_display_del_log,
	/client/proc/air_report,
	/client/proc/enable_debug_verbs,
	/client/proc/roll_dices,
	/proc/possess,
	/proc/release,
	/datum/admins/proc/set_uplink, //VOREStation Add,
	/datum/admins/proc/set_tcrystals,
	/client/proc/stop_sounds
	)
var/list/admin_verbs_mod = list(
	/client/proc/cmd_admin_pm_context,	//right-click adminPM interface,
	/client/proc/cmd_admin_pm_panel,	//admin-pm list,
	/client/proc/debug_variables,		//allows us to -see- the variables of any instance in the game.,
	/datum/admins/proc/PlayerNotes,
	/client/proc/admin_ghost,			//allows us to ghost/reenter body at will,
	/datum/admins/proc/show_player_panel,	//shows an interface for individual players, with various links (links require additional flags, //VOREStation Add,
	/client/proc/player_panel_new, //shows an interface for all players, with links to various panels, //VOREStation Add,
	/client/proc/player_panel,			//VOREStation Add,
	/client/proc/hide_verbs,			//hides all our adminverbs, //VOREStation Add,
	/client/proc/hide_most_verbs,		//hides all our hideable adminverbs, //VOREStation Add,
	/client/proc/debug_variables,		//allows us to -see- the variables of any instance in the game. +VAREDIT needed to modify, //VOREStation Add,
	/client/proc/mark_datum_mapview,	//VOREStation Add,
	/client/proc/cmd_check_new_players,	//allows us to see every new player, //VOREStation Add,
	/client/proc/cmd_mod_say,
	/client/proc/cmd_event_say,
	/datum/admins/proc/show_player_info,
	/datum/admins/proc/show_traitor_panel,
	/client/proc/colorooc,
	/client/proc/player_panel_new,
	/client/proc/dsay,
	/datum/admins/proc/show_skills,
	/datum/admins/proc/show_player_panel,
	/client/proc/check_antagonists,
	/client/proc/aooc,
	/client/proc/jobbans,
	/client/proc/cmd_admin_subtle_message, 	//send an message to somebody as a 'voice in their head',
	/datum/admins/proc/paralyze_mob,
	/client/proc/cmd_admin_direct_narrate,
	/client/proc/cmd_admin_z_narrate, //VOREStation Add,
	/client/proc/allow_character_respawn,   // Allows a ghost to respawn ,
	/datum/admins/proc/sendFax,
	/client/proc/getserverlog,			//allows us to fetch server logs (diary) for other days,
	/datum/admins/proc/view_persistent_data,
	/datum/admins/proc/view_txt_log,	//shows the server log (diary) for today,
	/datum/admins/proc/view_atk_log,		//shows the server combat-log, doesn't do anything presently,
	/client/proc/start_vote,
	// /datum/admins/proc/quick_nif, //CHOMPStation Add, Outpost 21 edit - Nif removal
	/client/proc/reload_jobwhitelist, //ChompADD
	/client/proc/reload_alienwhitelist //ChompADD
)

var/list/admin_verbs_event_manager = list(
	/client/proc/toggle_vantag_hud,
	/client/proc/cmd_event_say,
	/client/proc/cmd_admin_pm_context,
	/client/proc/cmd_admin_pm_panel,
	/client/proc/admin_ghost,
	/datum/admins/proc/show_player_panel,	//shows an interface for individual players, with various links (links require additional flags, //VOREStation Add,
	/client/proc/player_panel_new, //shows an interface for all players, with links to various panels, //VOREStation Add,
	/client/proc/player_panel,			//VOREStation Add,
	/client/proc/hide_verbs,			//hides all our adminverbs, //VOREStation Add,
	/client/proc/hide_most_verbs,		//hides all our hideable adminverbs, //VOREStation Add,
	/client/proc/debug_variables,		//allows us to -see- the variables of any instance in the game. +VAREDIT needed to modify, //VOREStation Add,
	/client/proc/mark_datum_mapview,	//VOREStation Add,
	/client/proc/cmd_check_new_players,	//allows us to see every new player, //VOREStation Add,
	/datum/admins/proc/show_player_info,
	/client/proc/dsay,
	/client/proc/cmd_admin_subtle_message,
	/client/proc/debug_variables,
	/client/proc/check_antagonists,
	/client/proc/aooc,
	/datum/admins/proc/paralyze_mob,
	/client/proc/cmd_admin_direct_narrate,
	/client/proc/cmd_admin_z_narrate, //VOREStation Add,
	/client/proc/allow_character_respawn,
	/datum/admins/proc/sendFax,
	/client/proc/respawn_character,
	/proc/possess,
	/proc/release,
	/datum/admins/proc/change_weather,
	/datum/admins/proc/change_time,
	/client/proc/admin_give_modifier,
	/client/proc/Jump,
	/client/proc/jumptomob,
	/client/proc/jumptocoord,
	/client/proc/cmd_admin_delete,
	/datum/admins/proc/delay,
	/client/proc/Set_Holiday,
	/client/proc/make_sound,
	/client/proc/toggle_random_events,
	/datum/admins/proc/cmd_admin_dress,
	/client/proc/cmd_admin_gib_self,
	/client/proc/drop_bomb,
	/client/proc/cmd_admin_add_freeform_ai_law,
	/client/proc/cmd_admin_add_random_ai_law,
	/client/proc/make_sound,
	/client/proc/toggle_random_events,
	/client/proc/editappear,
	/client/proc/roll_dices,
	/datum/admins/proc/call_supply_drop,
	/datum/admins/proc/call_drop_pod,
	/datum/admins/proc/PlayerNotes,
	/client/proc/callproc,
	/client/proc/callproc_datum,
	/client/proc/debug_controller,
	// /client/proc/show_gm_status,  // VOREStation Edit - We don't use SSgame_master yet.
	/datum/admins/proc/change_weather,
	/datum/admins/proc/change_time,
	/client/proc/admin_give_modifier,
	/datum/admins/proc/cmd_admin_dress,
	/client/proc/cmd_admin_gib_self,
	/datum/admins/proc/set_tcrystals,
	/datum/admins/proc/add_tcrystals,
	/client/proc/invisimin,                         //allows our mob to go invisible/visible,
	/datum/admins/proc/show_traitor_panel,  //interface which shows a mob's mind.,
	/datum/admins/proc/show_game_mode,  //Configuration window for the current game mode.,
	/datum/admins/proc/force_mode_latespawn, //Force the mode to try a latespawn proc,
	/datum/admins/proc/force_antag_latespawn, //Force a specific template to try a latespawn proc,
	/datum/admins/proc/announce,            //priority announce something to all clients.,
	/datum/admins/proc/intercom,            //send a fake intercom message, like an arrivals announcement,
	/datum/admins/proc/intercom_convo,      //send a fake intercom conversation, like an ATC exchange,
	/client/proc/colorooc,                          //allows us to set a custom colour for everythign we say in ooc,
	/client/proc/admin_ghost,                       //allows us to ghost/reenter body at will,
	/client/proc/toggle_view_range,         //changes how far we can see,
	/client/proc/cmd_admin_pm_context,      //right-click adminPM interface,
	/client/proc/cmd_admin_pm_panel,        //admin-pm list,
	/client/proc/cmd_admin_subtle_message,  //send an message to somebody as a 'voice in their head',
	/client/proc/cmd_admin_delete,          //delete an instance/object/mob/etc,
	/client/proc/cmd_admin_check_contents,  //displays the contents of an instance,
	/client/proc/cmd_admin_check_player_logs,       //checks a player's attack logs,
	/client/proc/cmd_admin_check_dialogue_logs,     //checks a player's dialogue logs,
	/datum/admins/proc/access_news_network, //allows access of newscasters,
	/client/proc/jumptocoord,                       //we ghost and jump to a coordinate,
	/client/proc/Getmob,                            //teleports a mob to our location,
	/client/proc/Getkey,                            //teleports a mob with a certain ckey to our location,
	/client/proc/Jump,
	/client/proc/jumptokey,                         //allows us to jump to the location of a mob with a certain ckey,
	/client/proc/jumptomob,                         //allows us to jump to a specific mob,
	/client/proc/jumptoturf,                        //allows us to jump to a specific turf,
	/client/proc/admin_call_shuttle,        //allows us to call the emergency shuttle,
	/client/proc/admin_cancel_shuttle,      //allows us to cancel the emergency shuttle, sending it back to CentCom,
	/client/proc/cmd_admin_direct_narrate,  //send text directly to a player with no padding. Useful for narratives and fluff-text,
	/client/proc/cmd_admin_world_narrate,   //sends text to all players with no padding,
	/client/proc/cmd_admin_z_narrate, //VOREStation Add,
	/client/proc/cmd_admin_create_centcom_report,
	/client/proc/check_words,                       //displays cult-words,
	/client/proc/check_ai_laws,                     //shows AI and borg laws,
	/client/proc/rename_silicon,            //properly renames silicons,
	/client/proc/manage_silicon_laws,       // Allows viewing and editing silicon laws. ,
	/client/proc/modify_robot,
	/client/proc/check_antagonists,
	/client/proc/admin_memo,                        //admin memo system. show/delete/write. +SERVER needed to delete admin memos of others,
	/client/proc/dsay,                                      //talk in deadchat using our ckey/fakekey,
	/client/proc/secrets,
	/client/proc/game_panel,                        //game panel, allows to change game-mode etc,
	/client/proc/cmd_mod_say,
	/client/proc/cmd_event_say,
	/datum/admins/proc/show_player_info,
	/client/proc/free_slot,                 //frees slot for chosen job,
	/client/proc/cmd_admin_change_custom_event,
	/client/proc/cmd_admin_rejuvenate,
	/client/proc/toggleghostwriters,
	/datum/admins/proc/show_skills,
	/client/proc/man_up,
	/client/proc/global_man_up,
	/client/proc/response_team, // Response Teams admin verb,
	/client/proc/trader_ship, // Trader ship admin verb,
	/client/proc/allow_character_respawn,    // Allows a ghost to respawn ,
	/client/proc/event_manager_panel,
	/client/proc/aooc,
	/client/proc/change_human_appearance_admin,     // Allows an admin to change the basic appearance of human-based mobs ,
	/client/proc/change_human_appearance_self,      // Allows the human-based mob itself change its basic appearance ,
	/client/proc/change_security_level,
	/client/proc/makepAI,
	/datum/admins/proc/paralyze_mob,
	/client/proc/fixatmos,
	/datum/admins/proc/sendFax,
	/client/proc/despawn_player,
	/datum/admins/proc/view_feedback,
	/datum/admins/proc/capture_map,
	/client/proc/Set_Holiday,
	/datum/admins/proc/startnow,
	/datum/admins/proc/restart,
	/datum/admins/proc/delay,
	/client/proc/cmd_mod_say,
	/datum/admins/proc/immreboot,
	/client/proc/everyone_random,
	/client/proc/cmd_admin_delete,		//delete an instance/object/mob/etc,
	/client/proc/cmd_debug_del_all,
	/client/proc/toggle_random_events,
	/client/proc/modify_server_news,
	/client/proc/toggle_spawning_with_recolour,
	/client/proc/start_vote,
	/client/proc/AdminCreateVirus,
	/client/proc/ReleaseVirus,
	/* Outpost 21 edit - Nif removal
	/datum/admins/proc/quick_nif, //CHOMPStation Add,
	/datum/admins/proc/quick_authentic_nif, //CHOMPStation add
	*/
	/client/proc/reload_jobwhitelist, //ChompADD
	/client/proc/reload_alienwhitelist //ChompADD
)

/client/proc/add_admin_verbs()
	if(holder)
		add_verb(src, admin_verbs_default)
		if(holder.rights & R_BUILDMODE)		add_verb(src, /client/proc/togglebuildmodeself)
		if(holder.rights & R_ADMIN)			add_verb(src, admin_verbs_admin)
		if(holder.rights & R_BAN)			add_verb(src, admin_verbs_ban)
		if(holder.rights & R_FUN)			add_verb(src, admin_verbs_fun)
		if(holder.rights & R_SERVER)		add_verb(src, admin_verbs_server)
		if(holder.rights & R_DEBUG)
			add_verb(src, admin_verbs_debug)
			if(CONFIG_GET(flag/debugparanoid) && !(holder.rights & R_ADMIN))
				remove_verb(src, admin_verbs_paranoid_debug)			//Right now it's just callproc but we can easily add others later on.
		if(holder.rights & R_POSSESS)		add_verb(src, admin_verbs_possess)
		if(holder.rights & R_PERMISSIONS)	add_verb(src, admin_verbs_permissions)
		if(holder.rights & R_STEALTH)		add_verb(src, /client/proc/stealth)
		if(holder.rights & R_REJUVINATE)	add_verb(src, admin_verbs_rejuv)
		if(holder.rights & R_SOUNDS)		add_verb(src, admin_verbs_sounds)
		if(holder.rights & R_SPAWN)			add_verb(src, admin_verbs_spawn)
		if(holder.rights & R_MOD)			add_verb(src, admin_verbs_mod)
		if(holder.rights & R_EVENT)			add_verb(src, admin_verbs_event_manager)

//CHOMPEdit Begin
/client/proc/remove_admin_verbs()
	remove_verb(src, list(
		admin_verbs_default,
		/client/proc/togglebuildmodeself,
		admin_verbs_admin,
		admin_verbs_ban,
		admin_verbs_fun,
		admin_verbs_server,
		admin_verbs_debug,
		admin_verbs_possess,
		admin_verbs_permissions,
		/client/proc/stealth,
		admin_verbs_rejuv,
		admin_verbs_sounds,
		admin_verbs_spawn,
		debug_verbs
		))
//CHOMPEdit End
