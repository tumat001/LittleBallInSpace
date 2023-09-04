extends "res://WorldRelated/AbstractWorldSlice.gd"


func _init():
	can_spawn_player_when_no_current_player_in_GE = true
	is_player_capture_area_style_one_at_a_time__in_node_order = true



func _on_after_game_start_init():
	._on_after_game_start_init()
	
	game_elements.get_current_player().is_show_lines_to_uncaptured_player_capture_regions = true
	make_first_pca_region_visible()
