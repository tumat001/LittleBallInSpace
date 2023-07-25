extends KinematicBody2D


onready var tilemap = $TileMap

const ENERGIZED_MODULATE := Color(217/255.0, 164/255.0, 2/255.0)
const NORMAL_MODULATE := Color(1, 1, 1)


#

export(bool) var is_energized : bool setget set_is_energized

#

func set_is_energized(arg_val):
	is_energized = arg_val
	
	if is_inside_tree():
		_update_display_based_on_is_energized()

#

func _ready():
	_update_display_based_on_is_energized()


func _update_display_based_on_is_energized():
	if is_energized:
		tilemap.modulate = ENERGIZED_MODULATE
	else:
		tilemap.modulate = NORMAL_MODULATE


#


func get_tilemap():
	return tilemap
