extends "res://WorldRelated/AbstractWorldSlice.gd"


func _init():
	can_spawn_player_when_no_current_player_in_GE = true
	

func as_test__override__do_insta_win():
	as_test__override__do_insta_win__template_capture_all_points()
	

func _on_after_game_start_init():
	._on_after_game_start_init()
	
	#game_elements.get_current_player().is_show_lines_to_uncaptured_player_capture_regions = true

