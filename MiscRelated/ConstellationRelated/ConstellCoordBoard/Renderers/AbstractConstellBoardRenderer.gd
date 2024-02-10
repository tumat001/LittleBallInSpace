extends Node2D

#

#const DRAW_CONFIG__DELTA_FOR_HALF_PROGRRESS : float = 0.15
#
#
#
#enum DirId {
#	UP = 0,
#	DOWN = 1,
#	LEFT = 2,
#	RIGHT = 3,
#
#	SOURCE = 10,
#}
#const RENDER_DET_KEY__GLOW_PROGRESS_RATIO_FROM_SOURCE = "glowProgressFromSource"
#const RENDER_DET_KEY__GLOW_PROGRESS_RATIO_TO_DEST = "glowProgressToDest"
##const RENDER_DET_KEY__DIR_ID_SOURCE_OF_PROGRESS = "dirSource"
##const RENDER_DET_KEY__DIR_IDS_DESTINATION_PROGRESS = "dirDestinations"
#const RENDER_DET_KEY__DIR_AS_VEC_SOURCE_OF_PROGRESS = "dirSource"
#const RENDER_DET_KEY__DIRS_AS_VEC_DESTINATION_PROGRESS = "dirDestinations"
#const RENDER_DET_KEY__ELE_TYPE = "eleType"



const DRAW_ELE__PATH_LINE_WIDTH : float = 2.0
const DRAW_ELE__PATH_LINE_HALF_LENGTH : float = 8.0
const DRAW_ELE__LEVEL_RECT_SIZE : Vector2 = Vector2(15, 15)
const DRAW_ELE__LAYOUT_RADIUS : float = 8.0
const DRAW_ELE__CUSTOM_PATH_LAYOUT_TO_LAYOUT_LINE_WIDTH : float = 1.0

const DRAW_ELE__CELL_LW : float = DRAW_ELE__PATH_LINE_HALF_LENGTH * 2
const DRAW_ELE__CELL_SIZE = Vector2(DRAW_ELE__CELL_LW, DRAW_ELE__CELL_LW)

const DRAW_ELE__COLOR__MOST_ELES := Color("#FEEDBA")

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

#var _interp_tweener : SceneTreeTween
#
#
##
#
#var _pre_calced__coord_to_pos_map : Dictionary
#var _pre_calced__coord_to_rect_map : Dictionary
#
#
#var _dir_id_to_vec_map : Dictionary
#var _cached_dir_ids_to_vecs_map : Dictionary
#
#var _vec_to_dir_id_map : Dictionary
#
#####
#
#func _init():
#	_interp_tweener = SceneTreeTween.new()
#	_init_dir_id_to_vec_map()
#	_init_vec_to_dir_id_map()
#
#func _init_dir_id_to_vec_map():
#	_dir_id_to_vec_map = {
#		DirId.UP : Vector2(0, -1),
#		DirId.DOWN : Vector2(0, 1),
#		DirId.LEFT : Vector2(-1, 0),
#		DirId.RIGHT : Vector2(1, 0)
#	}
#
#func _init_vec_to_dir_id_map():
#	_vec_to_dir_id_map = {}
#	for dir_id in _dir_id_to_vec_map:
#		var vec = _dir_id_to_vec_map[dir_id]
#		_vec_to_dir_id_map[vec] = dir_id
#
##
#
#func _draw_render_det_map_in_coord(arg_render_det_map, arg_coord):
#	match arg_render_det_map.RENDER_DET_KEY__ELE_TYPE:
#		ConstellCoordDet.LayoutElementTypeId.PATH:
#			_draw_render_det_map_in_coord__path(arg_render_det_map, arg_coord)
#		ConstellCoordDet.LayoutElementTypeId.LEVEL:
#			_draw_render_det_map_in_coord__level(arg_render_det_map, arg_coord)
#		ConstellCoordDet.LayoutElementTypeId.LAYOUT:
#			_draw_render_det_map_in_coord__layout(arg_render_det_map, arg_coord)
#		ConstellCoordDet.LayoutElementTypeId.CUSTOM_PATH_FROM_LAYOUT_TO_LAYOUT:
#			_draw_render_det_map_in_coord__custom_path_from_layout_to_layout(arg_render_det_map, arg_coord)
#
#
#func _draw_render_det_map_in_coord__path(arg_render_det_map, arg_coord, arg_line_width = DRAW_ELE__PATH_LINE_WIDTH):
#	var prog_ratio__from_source = arg_render_det_map[RENDER_DET_KEY__GLOW_PROGRESS_RATIO_FROM_SOURCE]
#	var prog_ratio__to_dest = arg_render_det_map[RENDER_DET_KEY__GLOW_PROGRESS_RATIO_TO_DEST]
#
#	var dir_as_vec__from_source = arg_render_det_map[RENDER_DET_KEY__DIR_AS_VEC_SOURCE_OF_PROGRESS]
#	var dirs_as_vec__to_dest = arg_render_det_map[RENDER_DET_KEY__DIRS_AS_VEC_DESTINATION_PROGRESS]
#
#	var pos = _pre_calced__coord_to_pos_map[arg_coord]
#	#source
#	draw_line(pos - (dir_as_vec__from_source * DRAW_ELE__PATH_LINE_HALF_LENGTH * prog_ratio__from_source), pos, DRAW_ELE__COLOR__MOST_ELES, arg_line_width)
#	#dest
#	if prog_ratio__to_dest > 0:
#		for dir_as_vec_to_dest in dirs_as_vec__to_dest:
#			draw_line(pos, pos + (dir_as_vec_to_dest * DRAW_ELE__PATH_LINE_HALF_LENGTH * prog_ratio__to_dest), DRAW_ELE__COLOR__MOST_ELES, arg_line_width)
#
#
#func _draw_render_det_map_in_coord__level(arg_render_det_map, arg_coord):
#	_draw_render_det_map_in_coord__path(arg_render_det_map, arg_coord)
#
#	var color_to_use = _get_mod_a_to_use(arg_render_det_map)
#	var rect = _get_or_gen_calc_level_rect_for_coord(arg_coord)
#	draw_rect(rect, color_to_use, true)
#
#func _get_mod_a_to_use(arg_render_det_map : Dictionary):
#	var prog_ratio__from_source = arg_render_det_map[RENDER_DET_KEY__GLOW_PROGRESS_RATIO_FROM_SOURCE]
#	var prog_ratio__to_dest = arg_render_det_map[RENDER_DET_KEY__GLOW_PROGRESS_RATIO_TO_DEST]
#	var total_prog_ratio = (prog_ratio__from_source + prog_ratio__to_dest) / 2.0
#
#	var color_to_use = DRAW_ELE__COLOR__MOST_ELES
#	color_to_use.a = total_prog_ratio
#
#	return color_to_use
#
#func _get_or_gen_calc_level_rect_for_coord(arg_coord):
#	if _pre_calced__coord_to_rect_map.has(arg_coord):
#		return _pre_calced__coord_to_rect_map[arg_coord]
#
#	var pos = _pre_calced__coord_to_pos_map[arg_coord]
#	var rect := Rect2(pos - (DRAW_ELE__CELL_SIZE/2), DRAW_ELE__CELL_SIZE)
#
#	_pre_calced__coord_to_rect_map[arg_coord] = rect
#	return rect
#
#
#
#func _draw_render_det_map_in_coord__layout(arg_render_det_map, arg_coord):
#	_draw_render_det_map_in_coord__path(arg_render_det_map, arg_coord)
#
#	var color_to_use = _get_mod_a_to_use(arg_render_det_map)
#	draw_circle(_pre_calced__coord_to_pos_map[arg_coord], DRAW_ELE__LAYOUT_RADIUS, color_to_use)
#
#func _draw_render_det_map_in_coord__custom_path_from_layout_to_layout(arg_render_det_map, arg_coord):
#	_draw_render_det_map_in_coord__path(arg_render_det_map, arg_coord, DRAW_ELE__CUSTOM_PATH_LAYOUT_TO_LAYOUT_LINE_WIDTH)
#
#
