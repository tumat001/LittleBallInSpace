extends "res://WorldRelated/AbstractWorldSlice.gd"


func _init():
	can_spawn_player_when_no_current_player_in_GE = true
	

func as_test__override__do_insta_win():
	as_test__override__do_insta_win__template_capture_all_points()
	
	GameSettingsManager.set_secondary_game_control_id__unlocked_status(GameSettingsManager.SecondaryControlId.MOUSE_SCROLL__LAUNCH_BALL, true)


func _on_after_game_start_init():
	._on_after_game_start_init()
	
	GameSettingsManager.set_secondary_game_control_id__unlocked_status(GameSettingsManager.SecondaryControlId.MOUSE_SCROLL__LAUNCH_BALL, true)



