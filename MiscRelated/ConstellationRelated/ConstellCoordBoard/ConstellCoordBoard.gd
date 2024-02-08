extends Reference


const GUI_AbstractLevelLayout = preload("res://_NonMainGameRelateds/_LevelSelectionRelated/GUIRelateds/GUI_LevelLayout/GUI_AbstractLevelLayout.gd")


class CoordDetails:
	enum LayoutElementTypeId {
		PATH = 0,
		LEVEL = 1,
		TO_LAYOUT = 2,
		
		CUSTOM_PATH_FROM_LAYOUT_TO_LAYOUT = 10,
	}
	var layout_element_type : int
	var level_id
	var level_layout_id
	
	const NONE_ADJACENT_COORD = Vector2(-1, -1)
	var adjacent_coord__left : Vector2 = NONE_ADJACENT_COORD 
	var adjacent_coord__right : Vector2 = NONE_ADJACENT_COORD
	var adjacent_coord__up : Vector2 = NONE_ADJACENT_COORD
	var adjacent_coord__down : Vector2 = NONE_ADJACENT_COORD
	

# coord example: Vector(1, 1) --> 2nd ele from top, 2nd ele from left
# shifted so that at least one element is at (0, x) and another element at (x, 0)
var coord_to_details_map : Dictionary

# top is always 0
# left is always 0
var _bot_coord : int = 0
var _right_coord : int = 0

#

func config_coords_based_on_gui_level_layout(arg_gui_level_layout : GUI_AbstractLevelLayout):
	var top_left_coord = arg_gui_level_layout.get_top_left_corner_rect_pos() / GUI_AbstractLevelLayout.TILE_WIDTH
	var rect_pos_to_layout_ele_map = arg_gui_level_layout.get_rect_position_to_layout_ele_map()
	for rect_pos in rect_pos_to_layout_ele_map.keys():
		var layout_ele = rect_pos_to_layout_ele_map[rect_pos]
		
		var coord = rect_pos / GUI_AbstractLevelLayout.TILE_WIDTH
		_construct_and_register_coord_details_from_layout_ele(layout_ele, coord)
		
		_update_bot_and_right_coord_based_on_coord(coord)

func _update_bot_and_right_coord_based_on_coord(arg_coord : Vector2):
	if _bot_coord < arg_coord.y:
		_bot_coord = arg_coord.y
	if _right_coord < arg_coord.x:
		_right_coord = arg_coord.x


func _construct_and_register_coord_details_from_layout_ele(arg_layout_ele, arg_coord) -> CoordDetails:
	var coord_details = CoordDetails.new()
	if arg_layout_ele.is_path:
		coord_details.layout_element_type = CoordDetails.LayoutElementTypeId.PATH
	elif arg_layout_ele.level_details != null:
		coord_details.layout_element_type = CoordDetails.LayoutElementTypeId.LEVEL
		coord_details.level_id = arg_layout_ele.level_details.level_id
	elif arg_layout_ele.level_layout_details != null:
		coord_details.layout_element_type = CoordDetails.LayoutElementTypeId.TO_LAYOUT
		coord_details.level_layout_id = arg_layout_ele.level_layout_details.level_layout_id
	
	if is_instance_valid(arg_layout_ele.layout_element_tile__left):
		coord_details.adjacent_coord__left = arg_layout_ele.layout_element_tile__left.rect_position / GUI_AbstractLevelLayout.TILE_WIDTH
	if is_instance_valid(arg_layout_ele.layout_element_tile__right):
		coord_details.adjacent_coord__right = arg_layout_ele.layout_element_tile__right.rect_position / GUI_AbstractLevelLayout.TILE_WIDTH
	if is_instance_valid(arg_layout_ele.layout_element_tile__up):
		coord_details.adjacent_coord__up = arg_layout_ele.layout_element_tile__up.rect_position / GUI_AbstractLevelLayout.TILE_WIDTH
	if is_instance_valid(arg_layout_ele.layout_element_tile__down):
		coord_details.adjacent_coord__down = arg_layout_ele.layout_element_tile__down.rect_position / GUI_AbstractLevelLayout.TILE_WIDTH
	
	coord_to_details_map[arg_coord] = coord_details
	
	return coord_details

# arg_dir_type::: up = 0, down = 1, left = 2, right = 3
func _construct_and_register_coord_details__custom_path_layout_to_layout(arg_coord : Vector2, arg_adjacent_coord : Vector2, arg_dir_type : int):
	var coord_details = CoordDetails.new()
	
	coord_details.layout_element_type = CoordDetails.LayoutElementTypeId.CUSTOM_PATH_FROM_LAYOUT_TO_LAYOUT
	
	add_adjacency_of_coord_det(coord_details, arg_coord, arg_dir_type)
	
	coord_to_details_map[arg_coord] = coord_details
	
	return coord_details

# arg_dir_type::: up = 0, down = 1, left = 2, right = 3
func _construct_and_register_coord_details__custom_path_layout_to_layout__arr(arg_coord : Vector2, arg_adjacent_coords : Array, arg_dir_types : Array):
	var coord_details = CoordDetails.new()
	
	coord_details.layout_element_type = CoordDetails.LayoutElementTypeId.CUSTOM_PATH_FROM_LAYOUT_TO_LAYOUT
	
	var i = 0
	for dir_type in arg_dir_types:
		var adjacent_coord = arg_adjacent_coords[i]
		add_adjacency_of_coord_det(coord_details, adjacent_coord, dir_type)
		
		i += 1
	
	coord_to_details_map[arg_coord] = coord_details
	
	return coord_details

# arg_dir_type::: up = 0, down = 1, left = 2, right = 3
func add_adjacency_of_coord_det(arg_coord_det : CoordDetails, arg_adjacent_coord : Vector2, arg_dir_type : int):
	match arg_dir_type:
		0:
			arg_coord_det.adjacent_coord__up = arg_adjacent_coord
		1:
			arg_coord_det.adjacent_coord__down = arg_adjacent_coord
		2:
			arg_coord_det.adjacent_coord__left = arg_adjacent_coord
		3:
			arg_coord_det.adjacent_coord__right = arg_adjacent_coord
	



# can override/overlap, so make sure to place it in such a way to not override/overlap.
# arg_top_left_coord_offset cannot be in the negatives
func combine_with_constel_coord_board(arg_constell_coord_board, arg_top_left_coord_offset : Vector2):
	if arg_top_left_coord_offset.x < 0 or arg_top_left_coord_offset.y < 0:
		print("ConstellCoordBoard: arg_top_left_coord_offset should not be negative in any axis")
		return
	
	for extr_coord in arg_constell_coord_board.coord_to_details_map:
		var extr_details = arg_constell_coord_board.coord_to_details_map[extr_coord]
		
		var final_coord = extr_coord + arg_top_left_coord_offset
		coord_to_details_map[final_coord] = extr_details
		
		_update_bot_and_right_coord_based_on_coord(final_coord)



func connect_coords_with_custom_path_layout_to_layout(arg_coord_01 : Vector2, arg_coord_02 : Vector2):
	var coord_diff : Vector2 = arg_coord_01 - arg_coord_02
	var abs_coord_dif = coord_diff.abs()
	
	
	var x_sign = sign(coord_diff.x)
	var y_sign = sign(coord_diff.y)
	
	var x_axis__dir_type = _get_dir_type_from_x_sign(x_sign)
	var y_axis__dir_type = _get_dir_type_from_y_sign(y_sign)
	
	
	var prev_adjacent_coord : Vector2 = arg_coord_01
	
	var curr_x : int = 0
	var curr_y : int = 0 
	
	
	if abs_coord_dif.x > abs_coord_dif.y:
		for iy in abs_coord_dif.y:
			iy += 1
			iy *= y_sign
			curr_y = iy * -1
			
			var new_coord = arg_coord_01 + Vector2(curr_x, curr_y)
			_construct_and_register_coord_details__custom_path_layout_to_layout(new_coord, prev_adjacent_coord, y_axis__dir_type)
		
		for ix in abs_coord_dif.x:
			ix += 1
			ix *= x_sign
			curr_x = ix * -1
			
			var new_coord = arg_coord_01 + Vector2(curr_x, curr_y)
			_construct_and_register_coord_details__custom_path_layout_to_layout(new_coord, prev_adjacent_coord, x_axis__dir_type)
		
		
	else:
		pass
		
	

# arg_dir_type::: up = 0, down = 1, left = 2, right = 3
func _get_dir_type_from_x_sign(arg_x_sign):
	if arg_x_sign > 0:
		return 3
	else:
		return 2

# arg_dir_type::: up = 0, down = 1, left = 2, right = 3
func _get_dir_type_from_y_sign(arg_y_sign):
	if arg_y_sign > 0:
		return 1
	else:
		return 0

##

func get_bot_coord() -> int:
	return _bot_coord

func get_right_coord() -> int:
	return _right_coord


