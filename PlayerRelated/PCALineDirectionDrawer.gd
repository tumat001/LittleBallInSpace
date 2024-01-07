extends Node2D

#

const COLOR_OF_LINE = Color(30/255.0, 217/255.0, 2/255.0, 1.0) #Color(30/255.0, 217/255.0, 2/255.0, 0.8)
const THICKNESS_OF_LINE : int = 3

#

const DEFAULT_MOD_A_VAL : float = 0.8

var world_manager
var is_show_lines_to_uncaptured_player_capture_regions : bool = false setget set_is_show_lines_to_uncaptured_player_capture_regions

#

func _ready():
	modulate.a = DEFAULT_MOD_A_VAL
	
	set_process(false)
	
	world_manager = SingletonsAndConsts.current_game_elements.world_manager
	set_is_show_lines_to_uncaptured_player_capture_regions(is_show_lines_to_uncaptured_player_capture_regions)

#

func set_is_show_lines_to_uncaptured_player_capture_regions(arg_val):
	is_show_lines_to_uncaptured_player_capture_regions = arg_val
	
	if is_inside_tree():
		if !is_show_lines_to_uncaptured_player_capture_regions:
			set_process(false)
			update()
		else:
			set_process(true)

func _show_lines_towards_all_uncaptured_player_capture_area_regions():
	update()



func _process(delta):
	update()

func _draw():
	if !SingletonsAndConsts.current_rewind_manager.is_rewinding and is_show_lines_to_uncaptured_player_capture_regions:
		_draw_lines_towards_all_uncaptured_player_capture_area_regions()
	

func _draw_lines_towards_all_uncaptured_player_capture_area_regions():
	if is_show_lines_to_uncaptured_player_capture_regions:
		for uncaptured_pca in world_manager.get_all_uncaptured_pca():
			if uncaptured_pca.visible and uncaptured_pca.can_line_be_drawn_to_self_by_pca_line_dir_drawer:
				var line_beginning = Vector2(-45, 0)
				var line_ending = Vector2(-60, 0)
				
				var angle = global_position.angle_to_point(uncaptured_pca.main_collision_shape_2d.global_position)
				line_beginning = line_beginning.rotated(angle)
				line_ending = line_ending.rotated(angle)
				
				draw_line(line_beginning, line_ending, COLOR_OF_LINE, THICKNESS_OF_LINE, true)
				



