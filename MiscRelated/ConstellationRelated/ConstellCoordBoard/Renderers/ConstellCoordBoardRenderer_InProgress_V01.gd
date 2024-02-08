extends Node2D


signal in_progress_draw_element_finished(draw_element_id, arg_draw_element_details_map)


const ConstellCoordBoard = preload("res://MiscRelated/ConstellationRelated/ConstellCoordBoard/ConstellCoordBoard.gd")
const ConstellCoordDet = ConstellCoordBoard.CoordDetails



enum DirId {
	UP = 0,
	DOWN = 1,
	LEFT = 2,
	RIGHT = 3,
	
	SOURCE = 10,
}
const RENDER_DET_KEY__GLOW_PROGRESS_RATIO_FROM_SOURCE = "glowProgressFromSource"
const RENDER_DET_KEY__GLOW_PROGRESS_RATIO_TO_DEST = "glowProgressToDest"
const RENDER_DET_KEY__DIR_ID_SOURCE_OF_PROGRESS = "dirSource"
const RENDER_DET_KEY__DIR_IDS_DESTINATION_PROGRESS = "dirDestinations"
#const RENDER_DET_KEY__ELE_TYPE = "eleType"
#var _curr_coord_to_render_details_map_map : Dictionary
var _curr_coord_to_render_details_map_map__path : Dictionary
var _curr_coord_to_render_details_map_map__level : Dictionary
var _curr_coord_to_render_details_map_map__layout : Dictionary
var _curr_coord_to_render_details_map_map__custom_path_layout_to_layout : Dictionary

var constell_coord_board : ConstellCoordBoard

var _curr_coord_to_is_finished_map : Array

#enum DrawElementId {
#	PATH = 0,
#	LEVEL = 1,
#	LAYOUT = 2,
#}
#const DRAW_ELE_DET_KEY__COLOR = "drawEleColor"
#const DRAW_ELE_DET_KEY__DRAW_PARAMS = "drawParams"


var draw_pos_shift : Vector2
var draw_ele__line_width : float
var draw_ele__circle_radius : float


#

func update_config_based_on_curr_constell_coord_board():
	_curr_coord_to_is_finished_map.clear()
	for coord in constell_coord_board.coord_to_details_map.keys():
		_curr_coord_to_is_finished_map[coord] = false

# assumes it starts at level
func start_constellation_light_up_at_coord(arg_coord):
	_start_light_up_coord(arg_coord, DirId.SOURCE)
	


func _start_light_up_coord(arg_coord, arg_dir_source_type):
	var coord_det : ConstellCoordDet = constell_coord_board.coord_to_details_map[arg_coord]
	var det_map = _generate_render_details_from_coord_details(coord_det, arg_dir_source_type)
	
	match coord_det.layout_element_type:
		ConstellCoordDet.LayoutElementTypeId.PATH:
			_append_in_progress_render__type_path(det_map, arg_coord)
		ConstellCoordDet.LayoutElementTypeId.LEVEL:
			pass
		ConstellCoordDet.LayoutElementTypeId.LAYOUT:
			pass
		ConstellCoordDet.LayoutElementTypeId.CUSTOM_PATH_FROM_LAYOUT_TO_LAYOUT:
			pass
		

func _append_in_progress_render__type_path(arg_det_map : Dictionary, arg_coord):
	_curr_coord_to_render_details_map_map__path[arg_coord] = arg_det_map

func _append_in_progress_render__type_level(arg_det_map : Dictionary, arg_coord):
	_curr_coord_to_render_details_map_map__level[arg_coord] = arg_det_map

func _append_in_progress_render__type_layout(arg_det_map : Dictionary, arg_coord):
	_curr_coord_to_render_details_map_map__layout[arg_coord] = arg_det_map



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
		RENDER_DET_KEY__DIR_ID_SOURCE_OF_PROGRESS : arg_dir_source_type,
		RENDER_DET_KEY__DIR_IDS_DESTINATION_PROGRESS : dir_dests,
		#RENDER_DET_KEY__ELE_TYPE : arg_coord_det.layout_element_type
	}


#

func _draw():
	pass

