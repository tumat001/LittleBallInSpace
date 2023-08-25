extends "res://WorldRelated/AbstractWorldSlice.gd"


onready var portal_for_transition = $ObjectContainer/Portal

#

func _init():
	can_spawn_player_when_no_current_player_in_GE = true
	


func _on_after_game_start_init():
	._on_after_game_start_init()
	
	portal_for_transition.connect("player_entered__as_scene_transition", self, "_on_player_entered__as_scene_transition")



func _on_player_entered__as_scene_transition(arg_player):
	SingletonsAndConsts.current_game_elements.configure_game_state_for_cutscene_occurance(true, true)
	
	#
	
	StoreOfLevels.unlock_stage_03__and_start_at_stage_03_01_on_level_finish__if_appropriate()
	
	#
	
	var tweener = create_tween()
	tweener.tween_callback(self, "_on_wait_after_portal_enter_done").set_delay(2.0)

func _on_wait_after_portal_enter_done():
	game_elements.game_result_manager.end_game__as_win()
	
	




