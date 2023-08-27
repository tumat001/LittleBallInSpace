extends Node

const AbstractWorldSlice = preload("res://WorldRelated/AbstractWorldSlice.gd")


signal all_PCAs_of_all_world_slices_captured()
signal all_PCAs_of_all_world_slices_uncaptured()


var game_elements setget set_game_elements
var _all_world_slices : Array

var _world_slice_to_is_captured_all_PCA_map : Dictionary

var _is_all_world_slice_PCAs_captured : bool = false

#

var _all_pca_to_is_captured_map : Dictionary

var _all_uncaptured_pca : Array

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
	arg_world_slice.connect("all_PCA_region_areas_captured", self, "_on_world_slice_all_PCA_region_areas_captured", [arg_world_slice])
	arg_world_slice.connect("all_PCA_region_areas_uncaptured", self, "_on_world_slice_all_PCA_region_areas_uncaptured", [arg_world_slice])
	
	arg_world_slice.connect("PCA_region_area_captured", self, "_on_PCA_region_area_captured")
	arg_world_slice.connect("PCA_region_area_uncaptured", self, "_on_PCA_region_area_uncaptured")
	
	if arg_world_slice.is_all_PCA_regions_captured():
		_world_slice_to_is_captured_all_PCA_map[arg_world_slice] = true
	else:
		_world_slice_to_is_captured_all_PCA_map[arg_world_slice] = false
	_update_is_all_world_slice_PCAs_captured(false)

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

##

func set_game_elements(arg_ele):
	game_elements = arg_ele
	
	if !game_elements.is_game_after_init:
		game_elements.connect("after_game_start_init", self, "_on_after_game_start_init")
	else:
		call_deferred("_update_all_pca_to_is_captured_map")

func _on_after_game_start_init():
	#_update_all_pca_to_is_captured_map()
	call_deferred("_update_all_pca_to_is_captured_map")

############


func _on_world_slice_all_PCA_region_areas_captured(arg_world_slice):
	_world_slice_to_is_captured_all_PCA_map[arg_world_slice] = true
	_update_is_all_world_slice_PCAs_captured(true)
	

func _on_world_slice_all_PCA_region_areas_uncaptured(arg_world_slice):
	_world_slice_to_is_captured_all_PCA_map[arg_world_slice] = false
	_update_is_all_world_slice_PCAs_captured(true)
	


func _update_is_all_world_slice_PCAs_captured(arg_emit_signal : bool):
	var old_val = _is_all_world_slice_PCAs_captured
	_is_all_world_slice_PCAs_captured = _is_all_PCAs_captured__internal_calcs()
	
	#
	
	#_update_all_pca_to_is_captured_map()
	
	#
	
	if arg_emit_signal:
		if old_val != _is_all_world_slice_PCAs_captured:
			if _is_all_world_slice_PCAs_captured:
				#print("WORLD_MANAGER: all pcas captured")
				emit_signal("all_PCAs_of_all_world_slices_captured")
				
			else:
				emit_signal("all_PCAs_of_all_world_slices_uncaptured")


func _is_all_PCAs_captured__internal_calcs():
	for is_captured in _world_slice_to_is_captured_all_PCA_map.values():
		if !is_captured:
			return false
	
	return true


func is_all_world_slice_PCAs_captured() -> bool:
	return _is_all_world_slice_PCAs_captured


#


func _on_PCA_region_area_captured(arg_region):
	_update_all_pca_to_is_captured_map()

func _on_PCA_region_area_uncaptured(arg_region):
	_update_all_pca_to_is_captured_map()


func _update_all_pca_to_is_captured_map():
	for world_slice in _world_slice_to_is_captured_all_PCA_map.keys():
		var all_win_type_pca_to_is_captured_map = world_slice.get_all_win_type_player_capture_area_region_to_is_captured_map()
		for pca in all_win_type_pca_to_is_captured_map.keys():
			var is_captured = all_win_type_pca_to_is_captured_map[pca]
			
			_all_pca_to_is_captured_map[pca] = is_captured
			
			if is_captured and _all_uncaptured_pca.has(pca):
				_all_uncaptured_pca.erase(pca)
			elif !is_captured and !_all_uncaptured_pca.has(pca):
				_all_uncaptured_pca.append(pca)
		

func get_all_uncaptured_pca():
	return _all_uncaptured_pca

#func _initialize_all_pca_to_is_captured_map():
#	for world_slice in _world_slice_to_is_captured_all_PCA_map.keys():
#		var all_win_type_pca_to_is_captured_map = world_slice.get_all_win_type_player_capture_area_region_to_is_captured_map()
#		for pca in all_win_type_pca_to_is_captured_map.keys():
#			var is_captured = all_win_type_pca_to_is_captured_map[pca]
#
#			_all_pca_to_is_captured_map[pca] = is_captured
#


