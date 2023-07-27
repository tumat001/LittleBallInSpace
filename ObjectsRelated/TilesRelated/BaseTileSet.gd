extends KinematicBody2D


onready var tilemap = $TileMap

const ENERGIZED_MODULATE := Color(217/255.0, 164/255.0, 2/255.0)
const NORMAL_MODULATE := Color(1, 1, 1)
const INSTANT_GROUND_MODULATE := Color(172/255.0, 68/255.0, 2/255.0)

#

enum EnergyMode {
	NORMAL = 0,
	ENERGIZED = 1,
	INSTANT_GROUND = 2,
}

export(EnergyMode) var energy_mode : int setget set_energy_mode

#

func set_energy_mode(arg_val):
	energy_mode = arg_val
	
	if is_inside_tree():
		_update_display_based_on_energy_mode()

#

func _ready():
	_update_display_based_on_energy_mode()


func _update_display_based_on_energy_mode():
	if energy_mode == EnergyMode.ENERGIZED:
		tilemap.modulate = ENERGIZED_MODULATE
	elif energy_mode == EnergyMode.NORMAL:
		tilemap.modulate = NORMAL_MODULATE
	elif energy_mode == EnergyMode.INSTANT_GROUND:
		tilemap.modulate = INSTANT_GROUND_MODULATE

#


func get_tilemap():
	return tilemap
