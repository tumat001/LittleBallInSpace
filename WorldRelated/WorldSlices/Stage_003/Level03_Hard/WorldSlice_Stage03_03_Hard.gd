extends "res://WorldRelated/AbstractWorldSlice.gd"


var _is_first_time__do_cutscenes : bool

#

func _init():
	can_spawn_player_when_no_current_player_in_GE = true
	

func as_test__override__do_insta_win():
	as_test__override__do_insta_win__template_capture_all_points()
	


func _on_after_game_start_init():
	._on_after_game_start_init()
	
	if SingletonsAndConsts.if_level_id_has_single_game_session_persisting_data(StoreOfLevels.LevelIds.LEVEL_03__STAGE_3__HARD):
		var is_fast_respawn = SingletonsAndConsts.get_single_game_session_persisting_data_of_level_id(StoreOfLevels.LevelIds.LEVEL_03__STAGE_3__HARD)
		
		if is_fast_respawn:
			_is_first_time__do_cutscenes = false
			
		else:
			_is_first_time__do_cutscenes = true
		
		
	else:
		_is_first_time__do_cutscenes = true
	
	SingletonsAndConsts.set_single_game_session_persisting_data_of_level_id(StoreOfLevels.LevelIds.LEVEL_03__STAGE_3__HARD, true)
	
	###
	
	_show_lines_to_pca__temporarily()
	



func _show_lines_to_pca__temporarily():
	var player = game_elements.get_current_player()
	player.is_show_lines_to_uncaptured_player_capture_regions = true
	
	var pca_line_drawer = player.pca_line_direction_drawer
	
	var pca_line_shower_tween = create_tween()
	if _is_first_time__do_cutscenes:
		pca_line_shower_tween.tween_interval(12.0)
	else:
		pca_line_shower_tween.tween_interval(4.0)
	pca_line_shower_tween.tween_property(pca_line_drawer, "modulate:a", 0.0, 2.0)
	pca_line_shower_tween.tween_callback(pca_line_drawer, "set_is_show_lines_to_uncaptured_player_capture_regions", [false])
	pca_line_shower_tween.tween_property(pca_line_drawer, "modulate:a", 1.0, 0.0)

