tool
extends Node2D

#

const BaseTileSet = preload("res://ObjectsRelated/TilesRelated/BaseTileSet.gd")

#

export(TileSet) var tileset : TileSet = preload("res://ObjectsRelated/TilesRelated/TileAssets/MainTileSet.tres") setget set_tileset
export(float) var radius_for_spawn : float setget set_radius_for_spawn
# normal for tiles is 9 particles. having this be 2 = 18 particles. 2 of which will be duplicate/same in texture
export(int) var particle_count_multiplier : int = 1 setget set_particle_count_multiplier

enum TileSetTemplateId {
	NONE = 0,
	
	SIMPLE_METAL_V01 = 100,
	SPACESHIP_METAL_V01 = 200,
	DARK_METAL_V01 = 300,
	HOSTILE_SHIP_METAL_V01 = 400,
}
export(TileSetTemplateId) var tile_set_template_id
export(bool) var spawn_fragments_at_ready : bool = true

var tileset_id : int
var tileset_autocoords : Vector2

#

var _all_unspawned_unadded_fragments : Array
var _all_fragments : Array

#

var _adder_tween : SceneTreeTween

var _rng_to_use : RandomNumberGenerator

#

func _ready():
	if !Engine.editor_hint:
		_rng_to_use = StoreOfRNG.get_rng(StoreOfRNG.RNGSource.NON_ESSENTIAL)
		
		
		if tile_set_template_id != TileSetTemplateId.NONE:
			if tile_set_template_id == TileSetTemplateId.SIMPLE_METAL_V01:
				config_particles__to_simple_metal__v1()
			elif tile_set_template_id == TileSetTemplateId.SPACESHIP_METAL_V01:
				config_particles__to_spaceship_metal()
			elif tile_set_template_id == TileSetTemplateId.DARK_METAL_V01:
				config_particles__to_dark_metal()
			elif tile_set_template_id == TileSetTemplateId.HOSTILE_SHIP_METAL_V01:
				config_particles__to_hostile_ship_metal()
			
		
		if spawn_fragments_at_ready:
			summon_particles()

#

func set_tileset(arg_map):
	tileset = arg_map

func set_radius_for_spawn(arg_radius):
	radius_for_spawn = arg_radius
	
	if Engine.editor_hint:
		update()

func set_particle_count_multiplier(arg_count):
	particle_count_multiplier = arg_count

#


func config_particles__to_simple_metal__v1(auto_coords : Vector2 = Vector2(0, 0)):
	tileset_id = TileConstants.SIMPLE_METAL_TILE_ID__01
	tileset_autocoords = auto_coords

func config_particles__to_spaceship_metal(auto_coords : Vector2 = Vector2(0, 0)):
	tileset_id = TileConstants.SPACESHIP_TILE_ID__01
	tileset_autocoords = auto_coords

func config_particles__to_dark_metal(auto_coords : Vector2 = Vector2(0, 0)):
	tileset_id = TileConstants.DARK_METAL_TILE_ID
	tileset_autocoords = auto_coords

func config_particles__to_hostile_ship_metal(auto_coords : Vector2 = Vector2(0, 0)):
	tileset_id = TileConstants.HOSTILE_SHIP_METAL_TILE_ID__01
	tileset_autocoords = auto_coords

#

func summon_particles(arg_within_duration_sec : float = 0.0):
	var texture_of_tile_sheet = tileset.tile_get_texture(tileset_id)
	var texture_region = tileset.tile_get_region(tileset_id)
	
	if !TileConstants.has_atlas_img_for_tilesheet_on_region(tileset_id, texture_region):
		TileConstants.generate_atlas_img_for_tilesheet_on_region(tileset_id, texture_region, texture_of_tile_sheet)
	var texture_in_region = TileConstants.get_atlas_img_for_tilesheet_on_region(tileset_id, texture_region)
	
	if !TileConstants.has_atlas_textures_for_tile_sheet(tileset_id):
		TileConstants.generate_atlas_textures_for_tile_sheet(tileset_id, texture_in_region, BaseTileSet.TILE_MAP_CELL_SIZE_X)
	var tile_texture = TileConstants.get_atlas_texture_from_tile_sheet_id(tileset_id, tileset_autocoords)
	
	#
	
	
	if is_zero_approx(arg_within_duration_sec):
		for i in particle_count_multiplier:
			var fragments = TileConstants.generate_object_tile_fragments(global_position, tile_texture, BaseTileSet.TILE_FRAGMENT_COUNT, tileset_id, tileset_autocoords)
		
			for fragment in fragments:
				_randomize_fragment_positions(fragment, _rng_to_use)
				SingletonsAndConsts.deferred_add_child_to_game_elements__other_node_hoster(fragment)
				
				fragment.sleeping = true
				_all_fragments.append(fragment)
		
	else:
		
		if particle_count_multiplier != 0:
			_adder_tween = create_tween()
			
			var frag_count = BaseTileSet.TILE_FRAGMENT_COUNT * particle_count_multiplier
			var per_frag_count_free_delay = arg_within_duration_sec / frag_count
			
			
			for i in particle_count_multiplier:
				var fragments = TileConstants.generate_object_tile_fragments(global_position, tile_texture, BaseTileSet.TILE_FRAGMENT_COUNT, tileset_id, tileset_autocoords)
				
				if fragments.size() != 0:
					_all_unspawned_unadded_fragments = fragments
					
					for fragment in fragments:
						_adder_tween.tween_interval(per_frag_count_free_delay)
						_adder_tween.tween_callback(self, "_queue_add_deferred_fragment", [fragment])


func _queue_add_deferred_fragment(arg_fragment):
	if _is_instance_valid_and_not_queued_free(arg_fragment):
		_randomize_fragment_positions(arg_fragment, _rng_to_use)
		
		SingletonsAndConsts.deferred_add_child_to_game_elements__other_node_hoster(arg_fragment)
		_all_fragments.append(arg_fragment)
		_all_unspawned_unadded_fragments.erase(arg_fragment)


func _randomize_fragment_positions(fragment, arg_rng : RandomNumberGenerator):
	var center = global_position
	var rand_rad = arg_rng.randf_range(0, radius_for_spawn)
	var rand_angle = arg_rng.randf_range(0, 2*PI)
	var rand_offset = Vector2(rand_rad, 0).rotated(rand_angle)
	
	var rand_rotation = arg_rng.randf_range(0, 2*PI)
	
	#
	
	fragment.global_position = center + rand_offset
	fragment.rotation = rand_rotation


#

func _draw():
	if Engine.editor_hint:
		draw_arc(Vector2(0, 0), radius_for_spawn, 0, PI*2, 64, Color(0, 0, 1), 3)

#

func queue_free_all_fragments(arg_within_duration_sec : float):
	if _adder_tween != null and _adder_tween.is_valid():
		_adder_tween.kill()
	
	if _all_unspawned_unadded_fragments.size() != 0:
		_all_fragments.append_array(_all_unspawned_unadded_fragments)
		_all_unspawned_unadded_fragments.clear()
	
	if is_zero_approx(arg_within_duration_sec):
		for frag in _all_fragments:
			if !frag.is_queued_for_deletion():
				frag.queue_free()
		_all_fragments.clear()
		
	else:
		if _all_fragments.size() != 0:
			var frag_count = _all_fragments.size()
			var per_frag_count_free_delay = arg_within_duration_sec / frag_count
			
			var free_tween = create_tween()
			for frag in _all_fragments:
				free_tween.tween_callback(self, "_attempt_free_frag", [frag])
				free_tween.tween_interval(per_frag_count_free_delay)


func _attempt_free_frag(arg_fragment):
	if _is_instance_valid_and_not_queued_free(arg_fragment):
		arg_fragment.queue_free()
		_all_fragments.erase(arg_fragment)


func _is_instance_valid_and_not_queued_free(arg_node):
	return is_instance_valid(arg_node) and !arg_node.is_queued_for_deletion()

#

func queue_free():
	.queue_free()
	
	for fragment in _all_unspawned_unadded_fragments:
		if _is_instance_valid_and_not_queued_free(fragment):
			fragment.queue_free()


