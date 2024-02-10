extends "res://MiscRelated/ConstellationRelated/ConstellCoordBoard/Renderers/AbstractConstellBoardRenderer.gd"


signal in_progress_render_det_finished(arg_render_det_map, arg_coord)
signal all_finished()

const ConstellCoordBoard = preload("res://MiscRelated/ConstellationRelated/ConstellCoordBoard/ConstellCoordBoard.gd")
const ConstellCoordDet = ConstellCoordBoard.CoordDetails

#


const DRAW_CONFIG__DELTA_FOR_HALF_PROGRRESS : float = 0.15

#

enum DirId {
	UP = 0,
	DOWN = 1,
	LEFT = 2,
	RIGHT = 3,
	
	SOURCE = 10,
}
const RENDER_DET_KEY__GLOW_PROGRESS_RATIO_FROM_SOURCE = "glowProgressFromSource"
const RENDER_DET_KEY__GLOW_PROGRESS_RATIO_TO_DEST = "glowProgressToDest"
#const RENDER_DET_KEY__DIR_ID_SOURCE_OF_PROGRESS = "dirSource"
#const RENDER_DET_KEY__DIR_IDS_DESTINATION_PROGRESS = "dirDestinations"
const RENDER_DET_KEY__DIR_AS_VEC_SOURCE_OF_PROGRESS = "dirSource"
const RENDER_DET_KEY__DIRS_AS_VEC_DESTINATION_PROGRESS = "dirDestinations"
const RENDER_DET_KEY__ELE_TYPE = "eleType"

#var _curr_coord_to_render_details_map_map : Dictionary
#var _curr_coord_to_render_details_map_map__path : Dictionary = {}
#var _curr_coord_to_render_details_map_map__level : Dictionary = {}
#var _curr_coord_to_render_details_map_map__layout : Dictionary = {}
#var _curr_coord_to_render_details_map_map__custom_path_layout_to_layout : Dictionary = {}
#var _all_curr_coord_map_maps : Array = [
#	_curr_coord_to_render_details_map_map__path,
#	_curr_coord_to_render_details_map_map__level,
#	_curr_coord_to_render_details_map_map__layout,
#	_curr_coord_to_render_details_map_map__custom_path_layout_to_layout,
#
#]

var _curr_coord_to_render_details_map__all : Dictionary

# the reason for no set is to make this update only when the board is ready
# update via: update_config_based_on_curr_constell_coord_board
var constell_coord_board : ConstellCoordBoard

var _curr_coord_to_is_finished_map : Dictionary
var _unfinished_coord_count : int  # separate val, but done this way to preserve calc speed


var _pre_calced__coord_to_pos_map : Dictionary
var _pre_calced__coord_to_rect_map : Dictionary   
#var _pre_calced__rect2 : Rect2   #cant do this cause rect2 has pos...


#enum DrawElementId {
#	PATH = 0,
#	LEVEL = 1,
#	LAYOUT = 2,
#}
#const DRAW_ELE_DET_KEY__COLOR = "drawEleColor"
#const DRAW_ELE_DET_KEY__DRAW_PARAMS = "drawParams"

#

var all_draw_pos_shift : Vector2


#

#const DRAW_ELE__PATH_LINE_WIDTH : float = 2.0
#const DRAW_ELE__PATH_LINE_HALF_LENGTH : float = 4.0
#const DRAW_ELE__LEVEL_RECT_SIZE : Vector2 = Vector2(6, 6)
#const DRAW_ELE__LAYOUT_RADIUS : float = 3.0
#const DRAW_ELE__CUSTOM_PATH_LAYOUT_TO_LAYOUT_LINE_WIDTH : float = 1.0
#
#const DRAW_ELE__CELL_LW : float = DRAW_ELE__PATH_LINE_HALF_LENGTH * 2
#const DRAW_ELE__CELL_SIZE = Vector2(DRAW_ELE__CELL_LW, DRAW_ELE__CELL_LW)
#
#const DRAW_ELE__COLOR__MOST_ELES := Color("#FEEDBA")

#

var _last_delta : float


#

var _interp_tweener : SceneTreeTween

#

var _dir_id_to_vec_map : Dictionary
var _cached_dir_ids_to_vecs_map : Dictionary

var _vec_to_dir_id_map : Dictionary

##

func _init():
	_interp_tweener = SceneTreeTween.new()
	_init_dir_id_to_vec_map()
	_init_vec_to_dir_id_map()
	

func _init_dir_id_to_vec_map():
	_dir_id_to_vec_map = {
		DirId.UP : Vector2(0, -1),
		DirId.DOWN : Vector2(0, 1),
		DirId.LEFT : Vector2(-1, 0),
		DirId.RIGHT : Vector2(1, 0),
		
		DirId.SOURCE : Vector2(0, 0)
	}

func _init_vec_to_dir_id_map():
	_vec_to_dir_id_map = {}
	for dir_id in _dir_id_to_vec_map:
		var vec = _dir_id_to_vec_map[dir_id]
		_vec_to_dir_id_map[vec] = dir_id

#

func _ready():
	set_process(false)

#

func update_config_based_on_curr_constell_coord_board():
	_curr_coord_to_is_finished_map.clear()
	for coord in constell_coord_board.coord_to_details_map.keys():
		_curr_coord_to_is_finished_map[coord] = false
		_unfinished_coord_count = _curr_coord_to_is_finished_map.size()
		
		_pre_calced__coord_to_pos_map[coord] = calc_center_pos_for_coord(coord)


# assumes it starts at eletype: level
func start_constellation_light_up_at_coord(arg_coord):
	_start_light_up_coord(arg_coord, DirId.SOURCE)
	
	set_process(true)


func _start_light_up_coord(arg_coord, arg_dir_source_type):
	var coord_det : ConstellCoordDet = constell_coord_board.coord_to_details_map[arg_coord]
	var det_map = _generate_render_details_from_coord_details(coord_det, arg_dir_source_type)
	
	_curr_coord_to_render_details_map__all[arg_coord] = det_map
	
#	match coord_det.layout_element_type:
#		ConstellCoordDet.LayoutElementTypeId.PATH:
#			_append_in_progress_render__type_path(det_map, arg_coord)
#		ConstellCoordDet.LayoutElementTypeId.LEVEL:
#			pass
#		ConstellCoordDet.LayoutElementTypeId.LAYOUT:
#			pass
#		ConstellCoordDet.LayoutElementTypeId.CUSTOM_PATH_FROM_LAYOUT_TO_LAYOUT:
#			pass
#
#
#func _append_in_progress_render__type_path(arg_det_map : Dictionary, arg_coord):
#	#_curr_coord_to_render_details_map_map__path[arg_coord] = arg_det_map
#	_curr_coord_to_render_details_map__all[arg_coord] = arg_det_map
#
#func _append_in_progress_render__type_level(arg_det_map : Dictionary, arg_coord):
#	#_curr_coord_to_render_details_map_map__level[arg_coord] = arg_det_map
#	_curr_coord_to_render_details_map__all[arg_coord] = arg_det_map
#
#func _append_in_progress_render__type_layout(arg_det_map : Dictionary, arg_coord):
#	#_curr_coord_to_render_details_map_map__layout[arg_coord] = arg_det_map
#	_curr_coord_to_render_details_map__all[arg_coord] = arg_det_map
#
#func _append_in_progress_render__type_custom_path_layout_to_layout(arg_det_map : Dictionary, arg_coord):
#	#_curr_coord_to_render_details_map_map__custom_path_layout_to_layout[arg_coord] = arg_det_map
#	_curr_coord_to_render_details_map__all[arg_coord] = arg_det_map

###

func _generate_render_details_from_coord_details(arg_coord_det : ConstellCoordDet, arg_dir_source_type : int):
	var dir_dests = []
	if arg_coord_det.adjacent_coord__up != ConstellCoordDet.NONE_ADJACENT_COORD:
		dir_dests.append(DirId.UP)
	if arg_coord_det.adjacent_coord__down != ConstellCoordDet.NONE_ADJACENT_COORD:
		dir_dests.append(DirId.DOWN)
	if arg_coord_det.adjacent_coord__left != ConstellCoordDet.NONE_ADJACENT_COORD:
		dir_dests.append(DirId.LEFT)
	if arg_coord_det.adjacent_coord__right != ConstellCoordDet.NONE_ADJACENT_COORD:
		dir_dests.append(DirId.RIGHT)
	
	#
	
	return {
		RENDER_DET_KEY__GLOW_PROGRESS_RATIO_FROM_SOURCE : 0.0,
		RENDER_DET_KEY__GLOW_PROGRESS_RATIO_TO_DEST : 0.0,
		#RENDER_DET_KEY__DIR_AS_VEC_SOURCE_OF_PROGRESS : arg_dir_source_type,
		#RENDER_DET_KEY__DIRS_AS_VEC_DESTINATION_PROGRESS : dir_dests,
		
		RENDER_DET_KEY__DIR_AS_VEC_SOURCE_OF_PROGRESS : _dir_id_to_vec_map[arg_dir_source_type],
		RENDER_DET_KEY__DIRS_AS_VEC_DESTINATION_PROGRESS : _conv_dir_ids_to_dirs_as_vec(dir_dests),
		
		RENDER_DET_KEY__ELE_TYPE : arg_coord_det.layout_element_type,
	}

func _conv_dir_ids_to_dirs_as_vec(arg_dir_ids : Array):
	if _cached_dir_ids_to_vecs_map.has(arg_dir_ids):
		return _cached_dir_ids_to_vecs_map[arg_dir_ids]
	
	var vecs : Array = []
	for id in arg_dir_ids:
		if id == DirId.SOURCE:
			vecs.clear()
			for dir_id in DirId.values():
				if dir_id != DirId.SOURCE:
					vecs.append(_dir_id_to_vec_map[dir_id])
			
			break
		
		vecs.append(_dir_id_to_vec_map[id])
	
	_cached_dir_ids_to_vecs_map[arg_dir_ids] = vecs
	
	return vecs


func calc_center_pos_for_coord(arg_coord : Vector2):
	return all_draw_pos_shift + (arg_coord * DRAW_ELE__CELL_LW)



#

func _process(delta):
	_last_delta += delta
	
	update()

func _draw():
	for coord in _curr_coord_to_render_details_map__all.keys():
		var render_det_map = _curr_coord_to_render_details_map__all[coord]
		var excess_delta = _last_delta
		while excess_delta > 0:
			excess_delta = _delta_advance_progress_of_render_det_map(render_det_map, excess_delta, coord)
		
		_draw_render_det_map_in_coord(render_det_map, coord)
	
	_last_delta = 0
	

func _delta_advance_progress_of_render_det_map(arg_render_det_map : Dictionary, delta : float, arg_coord : Vector2):
	var excess_ratio = delta / DRAW_CONFIG__DELTA_FOR_HALF_PROGRRESS 
	var prog_from_source = arg_render_det_map[RENDER_DET_KEY__GLOW_PROGRESS_RATIO_FROM_SOURCE]
	if prog_from_source < 1:
		prog_from_source += excess_ratio
		if prog_from_source < 1:
			excess_ratio = prog_from_source - 1
			prog_from_source = 1
		else:
			excess_ratio = 0
		
		arg_render_det_map[RENDER_DET_KEY__GLOW_PROGRESS_RATIO_FROM_SOURCE] = prog_from_source
	
	if excess_ratio > 0:
		var prog_to_dest = arg_render_det_map[RENDER_DET_KEY__GLOW_PROGRESS_RATIO_TO_DEST]
		if prog_to_dest < 1:
			prog_to_dest += excess_ratio
			if prog_to_dest < 1:
				excess_ratio = prog_to_dest - 1
				prog_to_dest = 1
			else:
				excess_ratio = 0
		
		arg_render_det_map[RENDER_DET_KEY__GLOW_PROGRESS_RATIO_TO_DEST] = prog_to_dest
		
		if prog_to_dest <= 1:
			_finished_in_progress_render_det(arg_render_det_map, arg_coord)
	
	return excess_ratio


func _finished_in_progress_render_det(arg_render_det_map, arg_coord):
	_curr_coord_to_render_details_map__all.erase(arg_coord)
	_curr_coord_to_is_finished_map[arg_coord] = true
	_unfinished_coord_count -= 1
	
	_add_unfinished_adjacent_coords_of_coord_to_next_render_pass(arg_render_det_map, arg_coord)
	
	emit_signal("in_progress_render_det_finished", arg_render_det_map, arg_coord)
	if _unfinished_coord_count == 0:
		set_process(false)
		emit_signal("all_finished")
		update()

func _add_unfinished_adjacent_coords_of_coord_to_next_render_pass(arg_render_det_map, arg_coord):
	for dir_as_vec in arg_render_det_map[RENDER_DET_KEY__DIRS_AS_VEC_DESTINATION_PROGRESS]:
		var adjacent_coord = arg_coord + dir_as_vec
		#note: inefficient but whatevs. just make it work
		if _curr_coord_to_is_finished_map.has(adjacent_coord):
			if !_curr_coord_to_is_finished_map[adjacent_coord]:
				_start_light_up_coord(adjacent_coord, _vec_to_dir_id_map[dir_as_vec])
				
		


func _draw_render_det_map_in_coord(arg_render_det_map, arg_coord):
	match arg_render_det_map[RENDER_DET_KEY__ELE_TYPE]:
		ConstellCoordDet.LayoutElementTypeId.PATH:
			_draw_render_det_map_in_coord__path(arg_render_det_map, arg_coord)
		ConstellCoordDet.LayoutElementTypeId.LEVEL:
			_draw_render_det_map_in_coord__level(arg_render_det_map, arg_coord)
		ConstellCoordDet.LayoutElementTypeId.TO_LAYOUT:
			_draw_render_det_map_in_coord__layout(arg_render_det_map, arg_coord)
		ConstellCoordDet.LayoutElementTypeId.CUSTOM_PATH_FROM_LAYOUT_TO_LAYOUT:
			_draw_render_det_map_in_coord__custom_path_from_layout_to_layout(arg_render_det_map, arg_coord)
		

func _draw_render_det_map_in_coord__path(arg_render_det_map, arg_coord, arg_line_width = DRAW_ELE__PATH_LINE_WIDTH):
	var prog_ratio__from_source = arg_render_det_map[RENDER_DET_KEY__GLOW_PROGRESS_RATIO_FROM_SOURCE]
	var prog_ratio__to_dest = arg_render_det_map[RENDER_DET_KEY__GLOW_PROGRESS_RATIO_TO_DEST]
	
	var dir_as_vec__from_source = arg_render_det_map[RENDER_DET_KEY__DIR_AS_VEC_SOURCE_OF_PROGRESS]
	var dirs_as_vec__to_dest = arg_render_det_map[RENDER_DET_KEY__DIRS_AS_VEC_DESTINATION_PROGRESS]
	
	var pos = _pre_calced__coord_to_pos_map[arg_coord]
	#source
	draw_line(pos - (dir_as_vec__from_source * DRAW_ELE__PATH_LINE_HALF_LENGTH * prog_ratio__from_source), pos, DRAW_ELE__COLOR__MOST_ELES, arg_line_width)
	#dest
	if prog_ratio__to_dest > 0:
		for dir_as_vec_to_dest in dirs_as_vec__to_dest:
			draw_line(pos, pos + (dir_as_vec_to_dest * DRAW_ELE__PATH_LINE_HALF_LENGTH * prog_ratio__to_dest), DRAW_ELE__COLOR__MOST_ELES, arg_line_width)


func _draw_render_det_map_in_coord__level(arg_render_det_map, arg_coord):
	_draw_render_det_map_in_coord__path(arg_render_det_map, arg_coord)
	
	var color_to_use = _get_mod_a_to_use(arg_render_det_map)
	var rect = _get_or_gen_calc_level_rect_for_coord(arg_coord)
	draw_rect(rect, color_to_use, true)

func _get_mod_a_to_use(arg_render_det_map : Dictionary):
	var prog_ratio__from_source = arg_render_det_map[RENDER_DET_KEY__GLOW_PROGRESS_RATIO_FROM_SOURCE]
	var prog_ratio__to_dest = arg_render_det_map[RENDER_DET_KEY__GLOW_PROGRESS_RATIO_TO_DEST]
	var total_prog_ratio = (prog_ratio__from_source + prog_ratio__to_dest) / 2.0
	
	var color_to_use = DRAW_ELE__COLOR__MOST_ELES
	color_to_use.a = total_prog_ratio
	
	return color_to_use

func _get_or_gen_calc_level_rect_for_coord(arg_coord):
	if _pre_calced__coord_to_rect_map.has(arg_coord):
		return _pre_calced__coord_to_rect_map[arg_coord]
	
	var pos = _pre_calced__coord_to_pos_map[arg_coord]
	var rect := Rect2(pos - (DRAW_ELE__CELL_SIZE/2), DRAW_ELE__CELL_SIZE)
	
	_pre_calced__coord_to_rect_map[arg_coord] = rect
	return rect



func _draw_render_det_map_in_coord__layout(arg_render_det_map, arg_coord):
	_draw_render_det_map_in_coord__path(arg_render_det_map, arg_coord)
	
	var color_to_use = _get_mod_a_to_use(arg_render_det_map)
	draw_circle(_pre_calced__coord_to_pos_map[arg_coord], DRAW_ELE__LAYOUT_RADIUS, color_to_use)

func _draw_render_det_map_in_coord__custom_path_from_layout_to_layout(arg_render_det_map, arg_coord):
	_draw_render_det_map_in_coord__path(arg_render_det_map, arg_coord, DRAW_ELE__CUSTOM_PATH_LAYOUT_TO_LAYOUT_LINE_WIDTH)
	


########


func get_pre_calced_pos_of_coord(arg_coord):
	return _pre_calced__coord_to_pos_map[arg_coord]


#

func shift_all_draw_pos_shift_to_make_coord_at_pos(arg_coord : Vector2, arg_target_pos : Vector2):
	var curr_pos_of_coord = _pre_calced__coord_to_pos_map[arg_coord]
	var pos_diff_from_target = arg_target_pos - curr_pos_of_coord
	
	for coord in _pre_calced__coord_to_pos_map.keys():
		var coord_pos = _pre_calced__coord_to_pos_map[coord]
		_pre_calced__coord_to_pos_map[coord] = pos_diff_from_target + coord_pos
	


