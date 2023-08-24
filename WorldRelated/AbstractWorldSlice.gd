
# ALTHOUGH many abstract world slices can be added in a GE,
# the coin functionality prevents that....
extends Node2D

const Player = preload("res://PlayerRelated/Player.gd")
const Player_Scene = preload("res://PlayerRelated/Player.tscn")

#

signal player_spawned(arg_player)


signal all_PCA_region_areas_captured()
signal all_PCA_region_areas_uncaptured()

########

var _player_global_spawn_coords : Array

var can_spawn_player_when_no_current_player_in_GE : bool

var world_id

var game_elements setget set_game_elements

#

var _all_win_type_player_capture_area_region_to_is_captured_map : Dictionary

#

var _is_all_pca_regions_captured : bool = false

#

var _next_available_coin_id : int = 1

#

onready var tile_container = $TileContainer
onready var object_container = $ObjectContainer
onready var player_spawn_coords_container = $PlayerSpawnCoordsContainer
onready var area_region_container = $AreaRegionContainer
onready var coins_container = $CoinsContainer
onready var lights_container = $LightsContainer

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
	_initialize_coins()
	_initialize_base_tilesets()
	

func _initialize_spawn_coords():
	for child in player_spawn_coords_container.get_children():
		_player_global_spawn_coords.append(child.global_position)

#

func _initialize_coins():
	var coin_count = coins_container.get_child_count()
	
	for coin in coins_container.get_children():
		_configure_coin(coin)
	
	var curr_level_id = SingletonsAndConsts.current_base_level_id
	if coin_count != StoreOfLevels.get_coin_count_for_level(curr_level_id):
		print("level with id %s not having the correct coin amount." % [curr_level_id])


func _configure_coin(arg_coin):
	arg_coin.coin_id = str(_next_available_coin_id)
	_next_available_coin_id += 1
	
	if GameSaveManager.is_coin_id_collected_in_level(arg_coin.coin_id, SingletonsAndConsts.current_base_level_id):
		arg_coin.visible = false
		arg_coin.queue_free()
	


#

func spawn_player_at_spawn_coords_index(arg_i = 0):
	var player = Player_Scene.instance()
	
	var spawn_pos = _player_global_spawn_coords[arg_i]
	player.global_position = global_position + spawn_pos
	
	_before_player_spawned_signal_emitted__chance_for_changes(player)
	
	emit_signal("player_spawned", player)
	
	return player

func _before_player_spawned_signal_emitted__chance_for_changes(arg_player):
	pass


####

func _on_after_game_start_init():
	_attempt_set_player__to_all_base_tiles()
	_initialize_area_regions()
	
	if _is_all_PCAs_are_captured():
		_on_all_PCAs_captured()

func _initialize_area_regions():
	for child in area_region_container.get_children():
		#child.set_game_elements(game_elements)
		_add_and_register_area_region(child)

func _add_and_register_area_region(arg_region):
	if !area_region_container.get_children().has(arg_region):
		area_region_container.add_child(arg_region)
	
	arg_region.set_game_elements(game_elements)
	
	if arg_region.get("is_player_capture_area_region"):
		if arg_region.is_capture_type_win:
			_all_win_type_player_capture_area_region_to_is_captured_map[arg_region] = false
			
			arg_region.connect("region_area_captured", self, "_on_PCA_region_area_captured", [arg_region])
			arg_region.connect("region_area_uncaptured", self, "_on_PCA_region_area_uncaptured", [arg_region])


func _on_PCA_region_area_captured(arg_region):
	_all_win_type_player_capture_area_region_to_is_captured_map[arg_region] = true
	if _is_all_PCAs_are_captured():
		_on_all_PCAs_captured()

func _on_PCA_region_area_uncaptured(arg_region):
	_all_win_type_player_capture_area_region_to_is_captured_map[arg_region] = false
	
	var old_val = _is_all_pca_regions_captured
	_is_all_pca_regions_captured = false
	if old_val != _is_all_pca_regions_captured:
		emit_signal("all_PCA_region_areas_uncaptured")


func _is_all_PCAs_are_captured():
	for PCA_region in _all_win_type_player_capture_area_region_to_is_captured_map.keys():
		if !PCA_region.is_area_captured():
			return false
	
	return true

func _on_all_PCAs_captured():
	_is_all_pca_regions_captured = true
	
	#print("ABSTRACT_WORLD_SLICE: all pcas captured")
	emit_signal("all_PCA_region_areas_captured")


func is_all_PCA_regions_captured():
	return _is_all_pca_regions_captured


func get_all_win_type_player_capture_area_region_to_is_captured_map():
	return _all_win_type_player_capture_area_region_to_is_captured_map


#########

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


##

func _initialize_base_tilesets():
	for child in tile_container.get_children():
		child.set_light_2d_glowables_node_2d_container(lights_container)


