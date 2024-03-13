extends "res://WorldRelated/AbstractWorldSlice.gd"

const PlainTextFragment = preload("res://MiscRelated/TextInterpreterRelated/TextFragments/PlainTextFragment.gd")
const StoreOfVicDefAnim = preload("res://GameFrontHUDRelated/NonGameSubs/VicDefAnimRelated/StoreOfVicDefAnim.gd")
const StoreOfTransitionSprites = preload("res://_NonMainGameRelateds/_Master/TransitionsRelated/StoreOfTransitionSprites.gd")



var _is_first_time_playing_this_lvl : bool

#

onready var spaceship_breakable_tileset = $TileContainer/BaseTileSet_SpaceshipBreakable

###

func _init():
	can_spawn_player_when_no_current_player_in_GE = true
	is_player_capture_area_style_one_at_a_time__in_node_order = true

func as_test__override__do_insta_win():
	as_test__override__do_insta_win__template_capture_all_points()
	#_on_PCA_Last_region_area_captured()
	


func _on_after_game_start_init():
	._on_after_game_start_init()
	
	
	if !GameSaveManager.is_level_id_finished(StoreOfLevels.LevelIds.LEVEL_02__STAGE_5):
		_is_first_time_playing_this_lvl = true
		SingletonsAndConsts.current_base_level.anim_type_to_use_on_vic = StoreOfVicDefAnim.AnimTypes.NONE
		SingletonsAndConsts.current_level_details.transition_id__exiting_level__out = StoreOfTransitionSprites.TransitionSpriteIds.OUT__STANDARD_FADE__BLACK__LONG
		#SingletonsAndConsts.interrupt_return_to_screen_layout_panel__go_directly_to_level = true
		
	else:
		_is_first_time_playing_this_lvl = false
		SingletonsAndConsts.current_base_level.anim_type_to_use_on_vic = StoreOfVicDefAnim.AnimTypes.ACTION
		SingletonsAndConsts.current_level_details.transition_id__exiting_level__out = StoreOfTransitionSprites.TransitionSpriteIds.OUT__STANDARD_CIRCLE__BLACK
	
	
	game_elements.get_current_player().is_show_lines_to_uncaptured_player_capture_regions = true

#########

func _on_PDAR_Dialog01_player_entered_in_area():
	make_first_pca_region_visible()


##########

func _on_PCA_Last_region_area_captured():
	if _is_first_time_playing_this_lvl:
		StoreOfLevels.unlock_relateds_after_winning_stage_05_level_02()
		
		SingletonsAndConsts.current_game_elements.configure_game_state_for_cutscene_occurance(true, true)
		
		game_elements.ban_rewind_manager_to_store_and_cast_rewind()
		
		#SingletonsAndConsts.show_end_game_result_pre_hud = true
		SingletonsAndConsts.interrupt_return_to_screen_layout_panel__for_any_ending_cutscene = true
		
		call_deferred("_deferred_last_region_captured")

func _deferred_last_region_captured():
	SingletonsAndConsts.current_master.show_ending_summary_wsp()
	
	game_elements.game_result_manager.end_game__as_win()
	


#

