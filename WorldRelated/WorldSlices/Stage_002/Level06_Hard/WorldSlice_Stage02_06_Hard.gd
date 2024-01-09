extends "res://WorldRelated/AbstractWorldSlice.gd"

#

onready var portal_for_transition = $ObjectContainer/Portal

onready var PDAR_fast_checkpoint = $AreaRegionContainer/PlayerDetectionAreaRegion_FastCheckpoint
onready var fast_spawn_pos_2d = $MiscContainer/FastSpawnPos2D
onready var spawn_position_2d = $PlayerSpawnCoordsContainer/SpawnPosition2D

#

var triggered_cam_area : bool = false

#

func _init():
	can_spawn_player_when_no_current_player_in_GE = true
	

func as_test__override__do_insta_win():
	#as_test__override__do_insta_win__template_capture_all_points()
	StoreOfLevels.unlock_stage_03__and_start_at_stage_03_01_on_level_finish__if_appropriate()
	game_elements.game_result_manager.end_game__as_win()
	


func _on_after_game_start_init():
	._on_after_game_start_init()
	
	portal_for_transition.connect("player_entered__as_scene_transition", self, "_on_player_entered__as_scene_transition")


func _before_player_spawned_signal_emitted__chance_for_changes(arg_player):
	._before_player_spawned_signal_emitted__chance_for_changes(arg_player)
	
	if SingletonsAndConsts.if_level_id_has_restart_only_persisting_data(StoreOfLevels.LevelIds.LEVEL_06__STAGE_2__HARD):
		var is_fast_respawn = SingletonsAndConsts.get_restart_only_persisting_data_of_level_id(StoreOfLevels.LevelIds.LEVEL_06__STAGE_2__HARD)
		
		if is_fast_respawn:
			arg_player.global_position = fast_spawn_pos_2d.global_position
	

###################

func _on_player_entered__as_scene_transition(arg_player):
	SingletonsAndConsts.current_game_elements.configure_game_state_for_cutscene_occurance(true, true)
	
	#
	
	StoreOfLevels.unlock_stage_03__and_start_at_stage_03_01_on_level_finish__if_appropriate()
	
	#
	
	var tweener = create_tween()
	tweener.tween_callback(self, "_on_wait_after_portal_enter_done").set_delay(2.0)

func _on_wait_after_portal_enter_done():
	game_elements.game_result_manager.end_game__as_win()
	
	


##

func _on_PlayerDetectionAreaRegion_FastCheckpoint_player_entered_in_area():
	#level_id_to_non_save_persisting_data[StoreOfLevels.LevelIds.LEVEL_06__STAGE_2__HARD] = true
	SingletonsAndConsts.set_restart_only_persisting_data_of_level_id(StoreOfLevels.LevelIds.LEVEL_06__STAGE_2__HARD, true)


##


func _on_PDAR_SpecialCamGiver_player_entered_in_area():
	if !triggered_cam_area:
		if CameraManager.is_at_default_zoom():
			CameraManager.start_camera_zoom_change__with_default_player_initialized_vals()
		
		triggered_cam_area = true

#

func _on_PDAR_SpecialCamAngleActiveArea_player_entered_in_area():
	pass # Replace with function body.
	

func _on_PDAR_SpecialCamAngleActiveArea_player_exited_in_area():
	pass # Replace with function body.
	


