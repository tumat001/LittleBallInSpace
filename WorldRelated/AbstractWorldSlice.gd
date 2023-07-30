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
	
	if !game_elements.is_game_after_init:
		game_elements.connect("after_game_start_init", self, "_on_after_game_start_init")
	else:
		_on_after_game_start_init()

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
	_attempt_set_player__to_all_base_tiles()
	


func _attempt_set_player__to_all_base_tiles():
	var player = game_elements.get_current_player()
	
	if is_instance_valid(player):
		if game_elements.is_connected("player_spawned", self, "_on_GE_player_spawned"):
			game_elements.disconnect("player_spawned", self, "_on_GE_player_spawned")
		
		for child in tile_container.get_children():
			child.set_player(player)
		
	else:
		if !game_elements.is_connected("player_spawned", self, "_on_GE_player_spawned"):
			game_elements.connect("player_spawned", self, "_on_GE_player_spawned")
		

func _on_GE_player_spawned(arg_player):
	_attempt_set_player__to_all_base_tiles()

