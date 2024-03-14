extends "res://WorldRelated/AbstractWorldSlice.gd"

#const PlainTextFragment = preload("res://MiscRelated/TextInterpreterRelated/TextFragments/PlainTextFragment.gd")
#const StoreOfTransitionSprites = preload("res://_NonMainGameRelateds/_Master/TransitionsRelated/StoreOfTransitionSprites.gd")

const WSSS0201_FogAndStarStatusDisplayer = preload("res://WorldRelated/WorldSlices/Stage_Special002/Level01/Subs/WSSS0201_FogAndStarStatusDisplayer.gd")
const WSSS0201_FogAndStarStatusDisplayer_Scene = preload("res://WorldRelated/WorldSlices/Stage_Special002/Level01/Subs/WSSS0201_FogAndStarStatusDisplayer.tscn")

#

const STAR_COUNT_BUFFER = 6
var STARS_NEEDED : int

#

var wsss0201_fog_and_star_status_displayer : WSSS0201_FogAndStarStatusDisplayer

#

#var _transition_sprite

###

func _init():
	can_spawn_player_when_no_current_player_in_GE = true


func as_test__override__do_insta_win():
	as_test__override__do_insta_win__template_capture_all_points()


func _ready():
	# init stars needed --> the -2 is from this and the trophy level (next)
	STARS_NEEDED = StoreOfLevels.get_total_coin_count() - (2) - STAR_COUNT_BUFFER

#

func _on_after_game_start_init():
	._on_after_game_start_init()
	
	game_elements.game_result_manager.connect("game_result_decided", self, "_on_game_result_decided__wsss0201", [], CONNECT_ONESHOT)
	
	
	if game_elements.is_game_front_hud_initialized:
		_do_star_and_fog_actions_based_on_states()
	else:
		game_elements.connect("game_front_hud_initialized", self, "_on_game_front_hud_initialized", [], CONNECT_ONESHOT)

func _on_game_front_hud_initialized(arg_GFH):
	_do_star_and_fog_actions_based_on_states()


func _do_star_and_fog_actions_based_on_states():
	#note: temp for then testing first time occurance:
	#GameSaveManager.remove_metadata_of_level_id(StoreOfLevels.LevelIds.LEVEL_01__STAGE_SPECIAL_2)
	
	
	if !GameSaveManager.has_metadata_in_level_id(StoreOfLevels.LevelIds.LEVEL_01__STAGE_SPECIAL_2):
		
		_init_wsss0201_fog_and_star_status_displayer()
		_config_as_fog_and_star_display_active()
		
		if STARS_NEEDED > GameSaveManager.get_total_coin_collected_count():
			_do_star_and_fog_actions__fail_lift_fog()
			CameraManager.set_current_default_zoom_out_vec(Vector2.ONE)
			
		else:
			_do_star_and_fog_actions__success_lift_fog()
			
			GameSaveManager.set_metadata_of_level_id(StoreOfLevels.LevelIds.LEVEL_01__STAGE_SPECIAL_2, [true])
		
	else:
		pass
		


func _config_as_fog_and_star_display_active():
	SingletonsAndConsts.current_game_front_hud.set_control_container_visibility(false)
	SingletonsAndConsts.current_game_elements.configure_game_state_for_cutscene_occurance(true, true)

func _init_wsss0201_fog_and_star_status_displayer():
	wsss0201_fog_and_star_status_displayer = WSSS0201_FogAndStarStatusDisplayer_Scene.instance()
	
	SingletonsAndConsts.current_game_front_hud.add_node_to_above_other_hosters(wsss0201_fog_and_star_status_displayer)
	var lvl_ids = _get_lvls_considered_for_star_collecting()
	
	wsss0201_fog_and_star_status_displayer.init_with_vals(STARS_NEEDED, lvl_ids)
	wsss0201_fog_and_star_status_displayer.connect("main_fog_lifting_star_removal_phase_started", self, "_on_wsss0201_fogstarstatus_main_fog_lifting_star_removal_phase_started")


func _on_wsss0201_fogstarstatus_main_fog_lifting_star_removal_phase_started():
	_config_as_fog_and_star_display_ended()

func _config_as_fog_and_star_display_ended():
	SingletonsAndConsts.current_game_front_hud.set_control_container_visibility(true, true)
	SingletonsAndConsts.current_game_elements.configure_game_state_for_end_of_cutscene_occurance(true)
	


func _get_lvls_considered_for_star_collecting():
	var lvl_ids_arr = StoreOfLevels.get_all_level_ids__not_including_tests()
	lvl_ids_arr.erase(StoreOfLevels.LevelIds.LEVEL_01__STAGE_SPECIAL_2)
	lvl_ids_arr.erase(StoreOfLevels.LevelIds.LEVEL_02__STAGE_SPECIAL_2)
	
	return lvl_ids_arr


func _do_star_and_fog_actions__fail_lift_fog():
	wsss0201_fog_and_star_status_displayer.start_display__as_failed_unlock()
	

func _do_star_and_fog_actions__success_lift_fog():
	wsss0201_fog_and_star_status_displayer.start_display__as_successful_unlock()
	


##
#
#func _do_actions_from_lack_of_stars():
#	is_darkened_by_no_stars = true
#
#	if game_elements.is_game_front_hud_initialized:
#		_do_actions_from_lack_of_stars__all_GFH_relateds()
#	else:
#		game_elements.connect("game_front_hud_initialized", self, "_on_game_front_hud_initialized", [], CONNECT_ONESHOT)
#
#func _on_game_front_hud_initialized(arg_GFH):
#	_do_actions_from_lack_of_stars__all_GFH_relateds()
#
#
#func _do_actions_from_lack_of_stars__all_GFH_relateds():
#	#_construct_fog_transition_sprite()
#	#_start_dialog__01()
#	_do_show_animation_for_lack_of_stars()


#func _construct_fog_transition_sprite():
#	_transition_sprite = SingletonsAndConsts.current_master.construct_transition__using_id(StoreOfTransitionSprites.TransitionSpriteIds.IN__STANDARD_CIRCLE__BLACK)
#
#	_transition_sprite.is_custom_controlled__avoid_auto_tweens = true
#
#	_transition_sprite.initial_ratio = 0.1
#	_transition_sprite.target_ratio = 0.1
#	_transition_sprite.wait_at_start = 0.0
#	_transition_sprite.duration = 1
#	_transition_sprite.trans_type = Tween.TRANS_LINEAR
#	#SingletonsAndConsts.current_master.play_transition__alter_no_states(_transition_sprite)
#
#	_transition_sprite.queue_free_on_end_of_transition = false
#	#SingletonsAndConsts.add_child_to_game_elements__other_node_hoster(_transition_sprite)
#
#
#	SingletonsAndConsts.current_game_front_hud.add_node_to_other_hosters(_transition_sprite)
#	_transition_sprite.start_transition()
#	_transition_sprite.modulate.a = 1.0


#func _start_dialog__01():
#	var plain_fragment__x_stars_needed = PlainTextFragment.new(PlainTextFragment.DESCRIPTION_TYPE.STAR, "%s stars" % STARS_NEEDED)
#	var plain_fragment__x_curr_stars = PlainTextFragment.new(PlainTextFragment.DESCRIPTION_TYPE.STAR, "%s stars" % GameSaveManager.get_total_coin_collected_count())
#
#
#	var dialog_desc = [
#		["It's too dark here! You'll need at least |0| to lift the darkness.", [plain_fragment__x_stars_needed]],
#		["Right now, you have |0|.", [plain_fragment__x_curr_stars]],
#	]
#
#	#
#
#	SingletonsAndConsts.current_game_front_hud.game_dialog_panel.connect("display_of_desc_finished", self, "_on_display_of_desc_finished__01", [], CONNECT_ONESHOT)
#	SingletonsAndConsts.current_game_front_hud.game_dialog_panel.start_display_of_descs(dialog_desc, 7.5, 0, null)
#	SingletonsAndConsts.current_game_front_hud.game_dialog_panel.show_self()
#
#func _on_display_of_desc_finished__01(arg_data):
#	SingletonsAndConsts.current_game_front_hud.game_dialog_panel.hide_self()


#func _do_show_animation_for_lack_of_stars():
#	game_elements.configure_game_state_for_cutscene_occurance(true, true)
#
#


#####################

func _on_game_result_decided__wsss0201(arg_result):
	if game_elements.game_result_manager.is_game_result_win():
		var successful = StoreOfLevels.attempt_do_unlock_actions_on_finish_level_01_of_stage_special_02()
		if successful:
			StoreOfLevels.directly_go_to_spec02_02_on_level_finish()
		
#		if is_darkened_by_no_stars:
#			if !GameSaveManager.has_metadata_in_level_id(SingletonsAndConsts.current_base_level_id):
#				GameSaveManager.set_metadata_of_level_id(SingletonsAndConsts.current_base_level_id, true)


