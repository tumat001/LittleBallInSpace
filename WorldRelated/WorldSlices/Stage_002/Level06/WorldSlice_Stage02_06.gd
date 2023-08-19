extends "res://WorldRelated/AbstractWorldSlice.gd"

#

onready var portal_for_transition = $ObjectContainer/Portal

onready var PDAR_fast_checkpoint = $AreaRegionContainer/PlayerDetectionAreaRegion_FastCheckpoint
onready var fast_spawn_pos_2d = $MiscContainer/FastSpawnPos2D
onready var spawn_position_2d = $PlayerSpawnCoordsContainer/SpawnPosition2D

#

func _init():
	can_spawn_player_when_no_current_player_in_GE = true
	


func _on_after_game_start_init():
	._on_after_game_start_init()
	
	portal_for_transition.connect("player_entered__as_scene_transition", self, "_on_player_entered__as_scene_transition")


func _before_player_spawned_signal_emitted__chance_for_changes(arg_player):
	._before_player_spawned_signal_emitted__chance_for_changes(arg_player)
	
	if SingletonsAndConsts.if_level_id_has_restart_only_persisting_data(StoreOfLevels.LevelIds.LEVEL_06__STAGE_2):
		var is_fast_respawn = SingletonsAndConsts.get_restart_only_persisting_data_of_level_id(StoreOfLevels.LevelIds.LEVEL_06__STAGE_2)
		
		if is_fast_respawn:
			arg_player.global_position = fast_spawn_pos_2d.global_position
	

###################

func _on_player_entered__as_scene_transition(arg_player):
	SingletonsAndConsts.current_game_elements.configure_game_state_for_cutscene_occurance(true, true)
	
	#
	
	GameSaveManager.last_hovered_over_level_layout_element_id = 0 # the first one
	GameSaveManager.last_opened_level_layout_id = StoreOfLevelLayouts.LevelLayoutIds.LAYOUT_03
	
	SingletonsAndConsts.interrupt_return_to_screen_layout_panel__go_directly_to_level = true
	SingletonsAndConsts.level_id_to_go_directly_to__after_interrupt_to_return_to_screen_layout_panel = StoreOfLevels.LevelIds.LEVEL_01__STAGE_3
	
	
	GameSaveManager.set_layout_element_id__is_invis(15, false)
	GameSaveManager.set_layout_element_id__is_invis(14, false)
	GameSaveManager.set_layout_element_id__is_invis(13, false)
	
	GameSaveManager.set_level_layout_id_status_completion(StoreOfLevelLayouts.LevelLayoutIds.LAYOUT_02, GameSaveManager.LEVEL_OR_LAYOUT_COMPLETION_STATUS__FINISHED)
	GameSaveManager.set_level_layout_id_status_completion(StoreOfLevelLayouts.LevelLayoutIds.LAYOUT_03, GameSaveManager.LEVEL_OR_LAYOUT_COMPLETION_STATUS__UNLOCKED)
	
	
	#
	
	var tweener = create_tween()
	tweener.tween_callback(self, "_on_wait_after_portal_enter_done").set_delay(2.0)

func _on_wait_after_portal_enter_done():
	game_elements.game_result_manager.end_game__as_win()
	
	


##

func _on_PlayerDetectionAreaRegion_FastCheckpoint_player_entered_in_area():
	#level_id_to_non_save_persisting_data[StoreOfLevels.LevelIds.LEVEL_06__STAGE_2] = true
	SingletonsAndConsts.set_restart_only_persisting_data_of_level_id(StoreOfLevels.LevelIds.LEVEL_06__STAGE_2, true)


##


func _on_PDAR_SpecialCamGiver_player_entered_in_area():
	pass # Replace with function body.
	

#

func _on_PDAR_SpecialCamAngleActiveArea_player_entered_in_area():
	pass # Replace with function body.
	

func _on_PDAR_SpecialCamAngleActiveArea_player_exited_in_area():
	pass # Replace with function body.
	


