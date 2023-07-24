extends Node2D

const Player = preload("res://PlayerRelated/Player.gd")
const Player_Scene = preload("res://PlayerRelated/Player.tscn")

#

signal player_spawned(arg_player)

########

var _player_global_spawn_coords : Array

var can_spawn_player_when_no_current_player_in_GE : bool

var world_id

var game_elements setget set_game_elements

#

onready var tile_container = $TileContainer
onready var object_container = $ObjectContainer
onready var player_spawn_coords_container = $PlayerSpawnCoordsContainer

####

func set_game_elements(arg_elements):
	game_elements = arg_elements
	
	game_elements.connect("after_game_start_init", self, "_on_after_game_start_init")

#

func _ready():
	_initialize_spawn_coords()

func _initialize_spawn_coords():
	for child in player_spawn_coords_container.get_children():
		_player_global_spawn_coords.append(child.global_position)



func spawn_player_at_spawn_coords_index(arg_i = 0):
	var player = Player_Scene.instance()
	
	var spawn_pos = _player_global_spawn_coords[arg_i]
	player.global_position = global_position + spawn_pos
	
	emit_signal("player_spawned", player)
	
	return player

####

func _on_after_game_start_init():
	pass
	
