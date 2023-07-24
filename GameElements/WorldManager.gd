extends Node

const AbstractWorldSlice = preload("res://WorldRelated/AbstractWorldSlice.gd")



var game_elements
var _all_world_slices : Array


######

func add_world_slice(arg_world_slice_id, arg_glob_pos : Vector2):
	var world_slice = StoreOfWorldSlices.load_world_slice_from_id(arg_world_slice_id)
	world_slice.global_position = arg_glob_pos
	world_slice.game_elements = game_elements
	
	add_child(world_slice)
	_register_world_slice(world_slice)


func _register_world_slice(arg_world_slice : AbstractWorldSlice):
	_all_world_slices.append(arg_world_slice)
	
	arg_world_slice.connect("player_spawned", self, "_on_player_spawned", [], CONNECT_PERSIST)

func get_world_slice_with_id(arg_world_id) -> AbstractWorldSlice:
	for world_slice in _all_world_slices:
		if world_slice.world_id == arg_world_id:
			return world_slice
	
	return null

func get_world_slice__can_spawn_player_when_no_current_player_in_GE() -> AbstractWorldSlice:
	for world_slice in _all_world_slices:
		if world_slice.can_spawn_player_when_no_current_player_in_GE:
			return world_slice
	
	return null

##

func _on_player_spawned(arg_player):
	add_child(arg_player)

