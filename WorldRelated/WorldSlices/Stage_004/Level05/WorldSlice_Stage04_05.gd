extends "res://WorldRelated/AbstractWorldSlice.gd"


func _init():
	can_spawn_player_when_no_current_player_in_GE = true
	

func as_test__override__do_insta_win():
	#StoreOfLevels.unlock_stage_05__and_unhide_eles_to_layout_05()
	as_test__override__do_insta_win__template_capture_all_points()
	

func _on_after_game_start_init():
	._on_after_game_start_init()
	



func _on_PlayerCaptureAreaRegion_region_area_captured():
	StoreOfLevels.unlock_stage_05__and_unhide_eles_to_layout_05()

