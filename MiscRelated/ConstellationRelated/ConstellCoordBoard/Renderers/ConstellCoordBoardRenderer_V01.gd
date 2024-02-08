#NOTE: make sure this is placed in a separate VIEWPORT with CLEAR_MODE_NEVER
extends Node2D

const ConstellCoordBoard = preload("res://MiscRelated/ConstellationRelated/ConstellCoordBoard/ConstellCoordBoard.gd")


enum DirId {
	UP = 0,
	DOWN = 1,
	LEFT = 2,
	RIGHT = 3,
}
const RENDER_DET_KEY__GLOW_PROGRESS_RATIO = "glowProgress"
const RENDER_DET_KEY__DIR_ID_SOURCE_OF_PROGRESS = "dirSource"
const RENDER_DET_KEY__DIR_IDS_DESTINATION_PROGRESS = "dirDestinations"
const RENDER_DET_KEY__ELE_TYPE = "eleType"
var coord_to_render_details_map_map : Dictionary
var constell_coord_board : ConstellCoordBoard


func _ready():
	pass


# note: oh wait there is a problem for that hmmmmmmmm
# prev draw calls are not flushed! so only call those currently updating
func _draw():
	pass
	

