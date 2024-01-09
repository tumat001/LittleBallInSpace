extends "res://WorldRelated/AbstractWorldSlice.gd"



func _init():
	can_spawn_player_when_no_current_player_in_GE = true
	

func as_test__override__do_insta_win():
	as_test__override__do_insta_win__template_capture_all_points()
	


func _on_after_game_start_init():
	._on_after_game_start_init()
	
	game_elements.game_result_manager.connect("game_result_decided", self, "_on_game_result_decided", [], CONNECT_ONESHOT)

func _on_game_result_decided(arg_result):
	if arg_result == game_elements.game_result_manager.GameResult.WIN:
		StoreOfLevels.unlock_stage_07__and_unhide_eles_to_layout_07()
	


