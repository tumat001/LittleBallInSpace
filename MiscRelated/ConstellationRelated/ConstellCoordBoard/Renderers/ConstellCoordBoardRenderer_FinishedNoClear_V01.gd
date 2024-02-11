#NOTE: make sure to call config_parent_viewport and supply the parent viewport
extends "res://MiscRelated/ConstellationRelated/ConstellCoordBoard/Renderers/AbstractConstellBoardRenderer.gd"

#

const ConstellCoordBoardRenderer_InProgress_V01 = preload("res://MiscRelated/ConstellationRelated/ConstellCoordBoard/Renderers/ConstellCoordBoardRenderer_InProgress_V01.gd")
const ConstellCoordBoard = preload("res://MiscRelated/ConstellationRelated/ConstellCoordBoard/ConstellCoordBoard.gd")
const ConstellCoordDet = ConstellCoordBoard.CoordDetails



var board_renderer_in_progress : ConstellCoordBoardRenderer_InProgress_V01 setget set_board_renderer_in_progress

#

const RENDER_DET_KEY__DIR_AS_VEC_SOURCE_OF_PROGRESS = "dirSource"
const RENDER_DET_KEY__DIRS_AS_VEC_DESTINATION_PROGRESS = "dirDestinations"
const RENDER_DET_KEY__ELE_TYPE = "eleType"
const RENDER_DET_KEY__POSITION = "position"

const RENDER_DET_KEY__METADATA_IS_TYPE_LEVEL_LIT_UP = "isTypeLevelLitUp"

#

var _render_det_map_list_for_only_next_draw_call : Array

var _pre_calced__pos_to_rect_map : Dictionary

#

func _ready():
	pass

#

func config_parent_viewport(arg_viewport : Viewport):
	arg_viewport.transparent_bg = true
	arg_viewport.render_target_clear_mode = Viewport.CLEAR_MODE_NEVER
	arg_viewport.gui_disable_input = true
	#arg_viewport.render_target_v_flip = true
	arg_viewport.usage = Viewport.USAGE_2D

#

func set_board_renderer_in_progress(arg_board):
	board_renderer_in_progress = arg_board
	
	board_renderer_in_progress.connect("in_progress_render_det_finished", self, "_on_board_renderer_in_prog__in_progress_render_det_finished")

#

func _on_board_renderer_in_prog__in_progress_render_det_finished(arg_render_det_map, arg_coord):
	var render_map = _conv_renderer_det_map_and_coord__to_own_det_map(arg_render_det_map, arg_coord)
	_render_det_map_list_for_only_next_draw_call.append(render_map)
	
	update()

func _conv_renderer_det_map_and_coord__to_own_det_map(arg_render_det_map, arg_coord):
	var render_map = {}
	render_map[RENDER_DET_KEY__DIR_AS_VEC_SOURCE_OF_PROGRESS] = arg_render_det_map[ConstellCoordBoardRenderer_InProgress_V01.RENDER_DET_KEY__DIR_AS_VEC_SOURCE_OF_PROGRESS]
	render_map[RENDER_DET_KEY__DIRS_AS_VEC_DESTINATION_PROGRESS] = arg_render_det_map[ConstellCoordBoardRenderer_InProgress_V01.RENDER_DET_KEY__DIRS_AS_VEC_DESTINATION_PROGRESS]
	render_map[RENDER_DET_KEY__ELE_TYPE] = arg_render_det_map[ConstellCoordBoardRenderer_InProgress_V01.RENDER_DET_KEY__ELE_TYPE]
	render_map[RENDER_DET_KEY__POSITION] = board_renderer_in_progress.get_pre_calced_pos_of_coord(arg_coord)
	render_map[RENDER_DET_KEY__METADATA_IS_TYPE_LEVEL_LIT_UP] = arg_render_det_map[ConstellCoordBoardRenderer_InProgress_V01.RENDER_DET_KEY__METADATA_IS_TYPE_LEVEL_LIT_UP]
	
	return render_map



func _draw():
	for render_det_map in _render_det_map_list_for_only_next_draw_call:
		_draw_render_det_map(render_det_map)
		
	
	_render_det_map_list_for_only_next_draw_call.clear()

func _draw_render_det_map(arg_render_det_map : Dictionary):
	match arg_render_det_map[RENDER_DET_KEY__ELE_TYPE]:
		ConstellCoordDet.LayoutElementTypeId.PATH:
			_draw_render_det_map__path(arg_render_det_map)
		ConstellCoordDet.LayoutElementTypeId.LEVEL:
			_draw_render_det_map__level(arg_render_det_map)
		ConstellCoordDet.LayoutElementTypeId.TO_LAYOUT:
			_draw_render_det_map__layout(arg_render_det_map)
		ConstellCoordDet.LayoutElementTypeId.CUSTOM_PATH_FROM_LAYOUT_TO_LAYOUT:
			_draw_render_det_map__custom_path_from_layout_to_layout(arg_render_det_map)
		


func _draw_render_det_map__path(arg_render_det_map, arg_line_width = DRAW_ELE__PATH_LINE_WIDTH, arg_base_color = DRAW_ELE__COLOR__MOST_ELES):
	var dir_as_vec__from_source = arg_render_det_map[RENDER_DET_KEY__DIR_AS_VEC_SOURCE_OF_PROGRESS]
	var dirs_as_vec__to_dest = arg_render_det_map[RENDER_DET_KEY__DIRS_AS_VEC_DESTINATION_PROGRESS]
	
	var pos = arg_render_det_map[RENDER_DET_KEY__POSITION]
	
	draw_line(pos - (dir_as_vec__from_source * DRAW_ELE__PATH_LINE_HALF_LENGTH), pos, arg_base_color, arg_line_width)
	for dir_as_vec_to_dest in dirs_as_vec__to_dest:
		draw_line(pos, pos + (dir_as_vec_to_dest * DRAW_ELE__PATH_LINE_HALF_LENGTH), arg_base_color, arg_line_width)


func _draw_render_det_map__level(arg_render_det_map):
	#_draw_render_det_map__path(arg_render_det_map)
	
	var pos = arg_render_det_map[RENDER_DET_KEY__POSITION]
	
	var rect = _get_or_gen_calc_level_rect_for_coord(pos)
	var is_lit_up = arg_render_det_map[RENDER_DET_KEY__METADATA_IS_TYPE_LEVEL_LIT_UP]
	
	var color_to_use : Color
	if is_lit_up:
		color_to_use = DRAW_ELE__COLOR__MOST_ELES
	else:
		color_to_use = DRAW_ELE__COLOR__UNLIT_LEVEL
	
	draw_rect(rect, color_to_use, true)

func _get_or_gen_calc_level_rect_for_coord(pos):
	if _pre_calced__pos_to_rect_map.has(pos):
		return _pre_calced__pos_to_rect_map[pos]
	
	var rect := Rect2(pos - (DRAW_ELE__CELL_SIZE/2), DRAW_ELE__CELL_SIZE)
	
	_pre_calced__pos_to_rect_map[pos] = rect
	return rect



func _draw_render_det_map__layout(arg_render_det_map):
	#_draw_render_det_map__path(arg_render_det_map)
	
	var pos = arg_render_det_map[RENDER_DET_KEY__POSITION]
	draw_circle(pos, DRAW_ELE__LAYOUT_RADIUS, DRAW_ELE__COLOR__LAYOUT)


func _draw_render_det_map__custom_path_from_layout_to_layout(arg_render_det_map):
	_draw_render_det_map__path(arg_render_det_map, DRAW_ELE__CUSTOM_PATH_LAYOUT_TO_LAYOUT_LINE_WIDTH, DRAW_ELE__COLOR__CUSTOM_PATH)
	



