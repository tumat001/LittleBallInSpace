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
	#adjacenties are Vector2.ONE with rotation
	var adjacent_coord__left : Vector2 = NONE_ADJACENT_COORD 
	var adjacent_coord__right : Vector2 = NONE_ADJACENT_COORD
	var adjacent_coord__up : Vector2 = NONE_ADJACENT_COORD
	var adjacent_coord__down : Vector2 = NONE_ADJACENT_COORD
	
	
	var metadata__is_type_level_lit_up : bool = false
	

# coord example: Vector(1, 1) --> 2nd ele from top, 2nd ele from left
# shifted so that at least one element is at (0, x) and another element at (x, 0)
var coord_to_details_map : Dictionary

# top is always 0
# left is always 0
var _bot_coord : int = 0
var _right_coord : int = 0

#####

func add_gui_level_layout_to_board(arg_gui_level_layout : GUI_AbstractLevelLayout, arg_coord_shift : Vector2):
	var top_left_coord = arg_gui_level_layout.get_top_left_corner_rect_pos() / GUI_AbstractLevelLayout.TILE_WIDTH
	
	var rect_pos_to_layout_ele_map = arg_gui_level_layout.get__rect_position_to_layout_ele_map()
	for rect_pos in rect_pos_to_layout_ele_map.keys():
		var layout_ele = rect_pos_to_layout_ele_map[rect_pos]
		
		var coord = (rect_pos / GUI_AbstractLevelLayout.TILE_WIDTH) + arg_coord_shift - top_left_coord
		_construct_and_register_coord_details_from_layout_ele(layout_ele, coord)
		
		_update_bot_and_right_coord_based_on_coord(coord)
	
	
	#print(rect_pos_to_layout_ele_map.keys())
	#print(coord_to_details_map.keys())

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
		
		# the tentative is equal to this lvl, which should always be true
		if GameSaveManager.is_all_coins_collected_in_level(coord_details.level_id) or (GameSaveManager.get_tentative_coin_ids_collected_in_curr_level_id__count() == 1 and coord_details.level_id == StoreOfLevels.LevelIds.LEVEL_02__STAGE_SPECIAL_2):
			coord_details.metadata__is_type_level_lit_up = true
		else:
			coord_details.metadata__is_type_level_lit_up = false
		
	elif arg_layout_ele.level_layout_details != null:
		coord_details.layout_element_type = CoordDetails.LayoutElementTypeId.TO_LAYOUT
		coord_details.level_layout_id = arg_layout_ele.level_layout_details.level_layout_id
		
	
	if is_instance_valid(arg_layout_ele.layout_element_tile__left):
		add_adjacency_of_coord_det(coord_details, arg_coord, 2)
		#coord_details.adjacent_coord__left = Vector2(-1, 0) #arg_layout_ele.layout_element_tile__left.rect_position / GUI_AbstractLevelLayout.TILE_WIDTH
	if is_instance_valid(arg_layout_ele.layout_element_tile__right):
		add_adjacency_of_coord_det(coord_details, arg_coord, 3)
		#coord_details.adjacent_coord__right = Vector2(1, 0)#arg_layout_ele.layout_element_tile__right.rect_position / GUI_AbstractLevelLayout.TILE_WIDTH
	if is_instance_valid(arg_layout_ele.layout_element_tile__up):
		add_adjacency_of_coord_det(coord_details, arg_coord, 0)
		#coord_details.adjacent_coord__up = Vector2(0, -1)# arg_layout_ele.layout_element_tile__up.rect_position / GUI_AbstractLevelLayout.TILE_WIDTH
	if is_instance_valid(arg_layout_ele.layout_element_tile__down):
		add_adjacency_of_coord_det(coord_details, arg_coord, 1)
		#coord_details.adjacent_coord__down = Vector2(0, 1)#arg_layout_ele.layout_element_tile__down.rect_position / GUI_AbstractLevelLayout.TILE_WIDTH
	
	if coord_to_details_map.has(arg_coord):
		print("ERR: OVERLAP in ConstellCoordBoard")
	coord_to_details_map[arg_coord] = coord_details
	
	return coord_details

# arg_dir_type::: up = 0, down = 1, left = 2, right = 3
func _construct_and_register_coord_details__custom_path_layout_to_layout(arg_coord : Vector2, arg_adjacent_coord : Vector2, arg_dir_type : int):
	var coord_details = CoordDetails.new()
	
	coord_details.layout_element_type = CoordDetails.LayoutElementTypeId.CUSTOM_PATH_FROM_LAYOUT_TO_LAYOUT
	
	#add_adjacency_of_coord_det(coord_details, arg_coord, arg_dir_type)
	add_adjacency_of_coord_det(coord_details, arg_coord, arg_dir_type)
	
	if coord_to_details_map.has(arg_coord):
		print("ERR: coord override!!")
	coord_to_details_map[arg_coord] = coord_details
	
	return coord_details

# arg_dir_type::: up = 0, down = 1, left = 2, right = 3
func _construct_and_register_coord_details__custom_path_layout_to_layout__arr(arg_coord : Vector2, arg_adjacent_coords : Array, arg_dir_types : Array):
	var coord_details = CoordDetails.new()
	
	coord_details.layout_element_type = CoordDetails.LayoutElementTypeId.CUSTOM_PATH_FROM_LAYOUT_TO_LAYOUT
	
	var i = 0
	for dir_type in arg_dir_types:
		var adjacent_coord = arg_adjacent_coords[i]
		#add_adjacency_of_coord_det(coord_details, adjacent_coord, dir_type)
		add_adjacency_of_coord_det(coord_details, arg_coord, dir_type)
		
		i += 1
	
	coord_to_details_map[arg_coord] = coord_details
	
	return coord_details

# arg_dir_type::: up = 0, down = 1, left = 2, right = 3
func add_adjacency_of_coord_det(arg_coord_det : CoordDetails, arg_coord_of_det : Vector2, arg_dir_type : int):
	match arg_dir_type:
		0:
			arg_coord_det.adjacent_coord__up = Vector2(0, -1) #arg_adjacent_coord
		1:
			arg_coord_det.adjacent_coord__down = Vector2(0, 1)
		2:
			arg_coord_det.adjacent_coord__left = Vector2(-1, 0)
		3:
			arg_coord_det.adjacent_coord__right = Vector2(1, 0)
	
	
#	if arg_coord_of_det == Vector2(33, 27):
#	#if arg_coord_of_det == Vector2(51, 13):
#		print("ARG COORD DET with dir: %s" % arg_dir_type)
#		if arg_dir_type == 0:
#			pass
	
	#print("added adjacency: %s, %s" % [arg_coord_of_det, arg_dir_type])



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


# does shortest axis first then longer one
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
		
		var det = _loop_thru_abs_coord_dif__y(abs_coord_dif, y_sign, curr_x, curr_y, arg_coord_01, arg_coord_02, prev_adjacent_coord, y_axis__dir_type)
		curr_y = det[0]
		prev_adjacent_coord = det[1]
		var at_least_one_setted = det[2]
		
		#first
		var coord_det_of_01 : CoordDetails = coord_to_details_map[arg_coord_01]
		var setted__coord_det_of_01_adj : bool = false
		if at_least_one_setted:
			add_adjacency_of_coord_det(coord_det_of_01, arg_coord_01, (y_axis__dir_type))
			setted__coord_det_of_01_adj = true
		
		
		var det02 = _loop_thru_abs_coord_dif__x(abs_coord_dif, x_sign, curr_x, curr_y, arg_coord_01, arg_coord_02, prev_adjacent_coord, x_axis__dir_type)
		at_least_one_setted = det02[2]
		
		#last
		var coord_det_of_02 : CoordDetails = coord_to_details_map[arg_coord_02]
		if at_least_one_setted:
			add_adjacency_of_coord_det(coord_det_of_02, arg_coord_02, (x_axis__dir_type))
			if !setted__coord_det_of_01_adj:
				add_adjacency_of_coord_det(coord_det_of_01, arg_coord_01, _get_reverse_of_dir_type__x(x_axis__dir_type))
			
		else:
			print("ERR: ConstellBoard: not one setted -- y")
			#add_adjacency_of_coord_det(coord_det_of_02, arg_coord_02, (y_axis__dir_type))
			#if !setted__coord_det_of_01_adj:
			#	add_adjacency_of_coord_det(coord_det_of_01, arg_coord_01, _get_reverse_of_dir_type__y(y_axis__dir_type))
			
		
	else:
		
		var det = _loop_thru_abs_coord_dif__x(abs_coord_dif, x_sign, curr_x, curr_y, arg_coord_01, arg_coord_02, prev_adjacent_coord, x_axis__dir_type)
		curr_x = det[0]
		prev_adjacent_coord = det[1]
		var at_least_one_setted = det[2]
		
		#first
		var coord_det_of_01 : CoordDetails = coord_to_details_map[arg_coord_01]
		var setted__coord_det_of_01_adj : bool = false
		if at_least_one_setted:
			add_adjacency_of_coord_det(coord_det_of_01, arg_coord_01, (x_axis__dir_type))
			setted__coord_det_of_01_adj = true
		
		
		var det02 = _loop_thru_abs_coord_dif__y(abs_coord_dif, y_sign, curr_x, curr_y, arg_coord_01, arg_coord_02, prev_adjacent_coord, y_axis__dir_type)
		at_least_one_setted = det02[2]
		
		#last
		var coord_det_of_02 : CoordDetails = coord_to_details_map[arg_coord_02]
		if at_least_one_setted:
			add_adjacency_of_coord_det(coord_det_of_02, arg_coord_02, (y_axis__dir_type))
			if !setted__coord_det_of_01_adj:
				add_adjacency_of_coord_det(coord_det_of_01, arg_coord_01, _get_reverse_of_dir_type__y(y_axis__dir_type))
		else:
			print("ERR: ConstellBoard: not one setted -- x")
			#add_adjacency_of_coord_det(coord_det_of_02, arg_coord_02, (x_axis__dir_type))
			#if !setted__coord_det_of_01_adj:
			#	add_adjacency_of_coord_det(coord_det_of_01, arg_coord_01, _get_reverse_of_dir_type__x(x_axis__dir_type))


func _loop_thru_abs_coord_dif__y(abs_coord_dif, y_sign, curr_x, curr_y, arg_coord_01, arg_coord_02, prev_adjacent_coord, y_axis__dir_type, final_coord_adjacency = CoordDetails.NONE_ADJACENT_COORD):
	var last_coord_det : CoordDetails = coord_to_details_map[arg_coord_01]
	var at_least_one_setted : bool = false
	for iy in abs_coord_dif.y:
		iy += 1
		iy *= y_sign
		curr_y = iy * -1
		
		add_adjacency_of_coord_det(last_coord_det, prev_adjacent_coord, _get_reverse_of_dir_type__y(y_axis__dir_type))
		
		var new_coord = arg_coord_01 + Vector2(curr_x, curr_y)
		if new_coord == arg_coord_02:
			break
		
		#var add_adjacency_in_curr_dir = curr_y != arg_coord_02.y
		last_coord_det = _construct_and_register_coord_details__custom_path_layout_to_layout(new_coord, prev_adjacent_coord, y_axis__dir_type)
		prev_adjacent_coord = new_coord
		
		at_least_one_setted = true
	
	#if final_coord_adjacency != CoordDetails.NONE_ADJACENT_COORD:
#	if last_coord_det != null:
#		#add_adjacency_of_coord_det(last_coord_det, final_coord_adjacency, y_axis__dir_type)
#		add_adjacency_of_coord_det(last_coord_det, _get_reverse_of_dir_type__y(y_axis__dir_type))
#
	
	return [curr_y, prev_adjacent_coord, at_least_one_setted]

func _loop_thru_abs_coord_dif__x(abs_coord_dif, x_sign, curr_x, curr_y, arg_coord_01, arg_coord_02, prev_adjacent_coord, x_axis__dir_type, final_coord_adjacency = CoordDetails.NONE_ADJACENT_COORD):
	var last_coord_det : CoordDetails = coord_to_details_map[arg_coord_01]
	var at_least_one_setted = false
	for ix in abs_coord_dif.x:
		ix += 1
		ix *= x_sign
		curr_x = ix * -1
		
		add_adjacency_of_coord_det(last_coord_det, prev_adjacent_coord, _get_reverse_of_dir_type__x(x_axis__dir_type))
		
		var new_coord = arg_coord_01 + Vector2(curr_x, curr_y)
		if new_coord == arg_coord_02:
			break
		
		#var add_adjacency_in_curr_dir = curr_x != arg_coord_02.x
		last_coord_det = _construct_and_register_coord_details__custom_path_layout_to_layout(new_coord, prev_adjacent_coord, x_axis__dir_type)
		prev_adjacent_coord = new_coord
		
		at_least_one_setted = true
	
	#if final_coord_adjacency != CoordDetails.NONE_ADJACENT_COORD:
#	if last_coord_det != null:
#		#add_adjacency_of_coord_det(last_coord_det, final_coord_adjacency, x_axis__dir_type)
#		add_adjacency_of_coord_det(last_coord_det, _get_reverse_of_dir_type__x(x_axis__dir_type))
#
	
	return [curr_x, prev_adjacent_coord, at_least_one_setted]


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


# arg_dir_type::: up = 0, down = 1, left = 2, right = 3
func _get_reverse_of_dir_type__x(arg_dir_x):
	if arg_dir_x == 2:
		return 3
	elif arg_dir_x == 3:
		return 2

# arg_dir_type::: up = 0, down = 1, left = 2, right = 3
func _get_reverse_of_dir_type__y(arg_dir_y):
	if arg_dir_y == 0:
		return 1
	elif arg_dir_y == 1:
		return 0


##

func get_bot_coord_of_board() -> int:
	return _bot_coord

func get_right_coord_of_board() -> int:
	return _right_coord


