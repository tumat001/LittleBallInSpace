extends KinematicBody2D


#const TileConstants = preload("res://ObjectsRelated/TilesRelated/TileConstants.gd")


const ENERGIZED_MODULATE := Color(217/255.0, 164/255.0, 2/255.0)
const NORMAL_MODULATE := Color(1, 1, 1)
const INSTANT_GROUND_MODULATE := Color(172/255.0, 68/255.0, 2/255.0)

#

enum EnergyMode {
	NORMAL = 0,
	ENERGIZED = 1,
	INSTANT_GROUND = 2,
}

var _is_energy_mode_set : bool = false
export(EnergyMode) var energy_mode : int setget set_energy_mode

# if this is changable beyond ready, make rewind system take it to account
const MOMENTUM_BREAKING_POINT__NEVER_BREAK = -1
export(float) var momentum_breaking_point : float = MOMENTUM_BREAKING_POINT__NEVER_BREAK setget set_momentum_breaking_point
var _is_breakable : bool

# if this is changable beyond ready, make rewind system take it to account
const SPEED_SLOWDOWN_RATIO__GLASS = 0.2
export(float) var speed_slowdown_on_tile_break : float = SPEED_SLOWDOWN_RATIO__GLASS


var _player setget set_player


var _applied_changes_for_breakable : bool
var break_on_player_contact : bool



var _can_induce_rotation_change__due_to_cell_v_changes : bool = true
var _can_induce_rotation_after_delay_timer : Timer

const SPEED_SLOWDOWN_COOLDOWN : float = 0.1
var _induce_speed_slowdown_on_break_cooldown_timer : Timer
var _can_induce_speed_slowdown : bool = true

#

# TODO: use these when making moving tilesets
var velocity = Vector2(0, 0)

#


var _save_tiles_data_next_frame__for_rewind_save__count : int
var _saved_cell_data_queue : Array

# structure: cell_pos -> [cell id, cell auto-coord, other datas<dict>]
var _cell_metadatas = {}

#

onready var tilemap = $TileMap

#

func set_player(arg_player):
	_player = arg_player

#

func set_energy_mode(arg_val):
	var old_val = energy_mode
	energy_mode = arg_val
	
	if is_inside_tree() and (old_val != energy_mode or !_is_energy_mode_set):
		_is_energy_mode_set = true
		_update_display_based_on_energy_mode()

#

func _ready():
	_update_display_based_on_energy_mode()
	_update_properties_based_on_is_breakable()
	

func _update_display_based_on_energy_mode():
	if energy_mode == EnergyMode.ENERGIZED:
		tilemap.modulate = ENERGIZED_MODULATE
	elif energy_mode == EnergyMode.NORMAL:
		tilemap.modulate = NORMAL_MODULATE
	elif energy_mode == EnergyMode.INSTANT_GROUND:
		tilemap.modulate = INSTANT_GROUND_MODULATE

#

func set_momentum_breaking_point(arg_val):
	momentum_breaking_point = arg_val
	
	if is_inside_tree():
		_update_properties_based_on_is_breakable()

func _update_properties_based_on_is_breakable():
	if momentum_breaking_point == MOMENTUM_BREAKING_POINT__NEVER_BREAK:
		_is_breakable = false
		set_process(false)
		
	else:
		_init_can_induce_rotation_after_delay_timer()
		_init_induce_speed_slowdown_on_break_cooldown_timer()
		
		_is_breakable = true
		set_process(true)
		
		is_rewindable = true
		SingletonsAndConsts.current_rewind_manager.add_to_rewindables(self)
		
		_update_cells_save_data()
		#_save_tiles_data_next_frame__for_rewind_save = true
		_save_tiles_data_next_frame__for_rewind_save__count += 1

func is_breakable() -> bool:
	return _is_breakable


func _init_can_induce_rotation_after_delay_timer():
	if !is_instance_valid(_can_induce_rotation_after_delay_timer):
		_can_induce_rotation_after_delay_timer = Timer.new()
		_can_induce_rotation_after_delay_timer.one_shot = true
		_can_induce_rotation_after_delay_timer.connect("timeout", self, "_on_can_induce_rotation_after_delay_timer_timeout", [], CONNECT_PERSIST)
		add_child(_can_induce_rotation_after_delay_timer)

func _on_can_induce_rotation_after_delay_timer_timeout():
	_can_induce_rotation_change__due_to_cell_v_changes = true



func _init_induce_speed_slowdown_on_break_cooldown_timer():
	if !is_instance_valid(_induce_speed_slowdown_on_break_cooldown_timer):
		_induce_speed_slowdown_on_break_cooldown_timer = Timer.new()
		_induce_speed_slowdown_on_break_cooldown_timer.one_shot = true
		_induce_speed_slowdown_on_break_cooldown_timer.connect("timeout", self, "_on_induce_speed_slowdown_on_break_cooldown_timer_timeout", [], CONNECT_PERSIST)
		add_child(_induce_speed_slowdown_on_break_cooldown_timer)

func _on_induce_speed_slowdown_on_break_cooldown_timer_timeout():
	_can_induce_speed_slowdown = true


#

func _process(delta):
	if !SingletonsAndConsts.current_rewind_manager.is_rewinding:
		if _is_breakable:
			var momentum_mag = _player.get_momentum_mag__using_linear_velocity()
			if momentum_mag >= momentum_breaking_point:
				_apply_visual_changes__breakable()
				_make_self_breakable_on_player_contact()
				
			else:
				_unapply_visual_changes__breakable()
				_make_self_not_breakable_on_player_contact()
			

func _apply_visual_changes__breakable():
	if !_applied_changes_for_breakable:
		_applied_changes_for_breakable = true
		
		for cell_pos in tilemap.get_used_cells():
			var cell_id = tilemap.get_cellv(cell_pos)
			var cell_autocord = tilemap.get_cell_autotile_coord(cell_pos.x, cell_pos.y)
			var breakable_glowing_cell_id_equi = TileConstants.convert_non_glowing_breakable_tile_id__to_glowing(cell_id)
			
			if breakable_glowing_cell_id_equi != null:
				_set_tile_at_coords(cell_pos, breakable_glowing_cell_id_equi, cell_autocord, false, false)
			else:
				print("BASE TILE SET: setting from unbreakable to breakable: texture id error")
		
		tilemap.update_dirty_quadrants()
		
		_can_induce_rotation_change__due_to_cell_v_changes = false
		#set_deferred("_can_induce_rotation_change__due_to_cell_v_changes", true)
		_set_true__can_induce_rotation_change__due_to_cell_v_changes__after_small_delay()

func _unapply_visual_changes__breakable():
	if _applied_changes_for_breakable:
		_applied_changes_for_breakable = false
		
		for cell_pos in tilemap.get_used_cells():
			var cell_id = tilemap.get_cellv(cell_pos)
			var cell_autocord = tilemap.get_cell_autotile_coord(cell_pos.x, cell_pos.y)
			var breakable_non_glowing_cell_id_equi = TileConstants.convert_glowing_breakable_tile_id__to_non_glowing(cell_id)
			
			if breakable_non_glowing_cell_id_equi != null:
				_set_tile_at_coords(cell_pos, breakable_non_glowing_cell_id_equi, cell_autocord, false, false)
			else:
				print("BASE TILE SET: setting from breakable to unbreakable: texture id error")
		
		tilemap.update_dirty_quadrants()
		
		_can_induce_rotation_change__due_to_cell_v_changes = false
		#set_deferred("_can_induce_rotation_change__due_to_cell_v_changes", true)
		_set_true__can_induce_rotation_change__due_to_cell_v_changes__after_small_delay()


func _set_true__can_induce_rotation_change__due_to_cell_v_changes__after_small_delay():
	_can_induce_rotation_after_delay_timer.start(0.25)




func _make_self_breakable_on_player_contact():
	if !break_on_player_contact:
		break_on_player_contact = true
		
		#set_collision_layer_bit(2, false)
		set_collision_mask_bit(0, false)
		
		#PhysicsServer.body_add_collision_exception(get_rid(), _player.get_rid())

func _make_self_not_breakable_on_player_contact():
	if break_on_player_contact:
		break_on_player_contact = false
		
		#set_collision_layer_bit(2, true)
		set_collision_mask_bit(0, true)
		
		#PhysicsServer.body_remove_collision_exception(get_rid(), _player.get_rid())


func break_tile_coord__using_player(arg_tile_coord: Vector2, arg_player):
	var tile_local_pos_top_left = tilemap.map_to_world(arg_tile_coord)
	var tile_local_pos = tile_local_pos_top_left + (tilemap.cell_size / 2)
	var tile_global_pos = tilemap.to_global(tile_local_pos)

	var id = tilemap.get_cellv(arg_tile_coord)
	var breakable_id_tentative = TileConstants.convert_glowing_breakable_tile_id__to_non_glowing(id)
	if breakable_id_tentative != null:
		id = breakable_id_tentative
	var auto_coords = tilemap.get_cell_autotile_coord(arg_tile_coord.x, arg_tile_coord.y)
	var texture_of_tile_sheet = tilemap.tile_set.tile_get_texture(id)
	var texture_region = tilemap.tile_set.tile_get_region(id)

	if !TileConstants.has_atlas_img_for_tilesheet_on_region(id, texture_region):
		TileConstants.generate_atlas_img_for_tilesheet_on_region(id, texture_region, texture_of_tile_sheet)
	var texture_in_region = TileConstants.get_atlas_img_for_tilesheet_on_region(id, texture_region)

	if !TileConstants.has_atlas_textures_for_tile_sheet(id):
		TileConstants.generate_atlas_textures_for_tile_sheet(id, texture_in_region, tilemap.cell_size.x)
	var tile_texture = TileConstants.get_atlas_texture_from_tile_sheet_id(id, auto_coords)
	
	#_create_fragments(tile_local_pos_top_left, tile_global_pos, tile_texture, id, auto_coords)
	call_deferred("_create_fragments", tile_local_pos_top_left, tile_global_pos, tile_texture, id, auto_coords)
	
	####################
	
	#tilemap.set_cellv(arg_tile_coord, -1)
	_player.remove_on_ground_count_with_identif__from_breakable_tile__before_breaking(arg_tile_coord)
	_set_tile_at_coords(arg_tile_coord, -1, Vector2(0, 0), true)
	
	call_deferred("_attempt_induce_speed_slowdown_on_player", arg_player)

func _create_fragments(arg_tile_local_pos_top_left, arg_tile_global_pos, arg_tile_texture, arg_tile_id, arg_auto_coords):
	var fragments = TileConstants.generate_object_tile_fragments(arg_tile_local_pos_top_left, arg_tile_global_pos, arg_tile_texture, 9, arg_tile_id, arg_auto_coords)
	for fragment in fragments:
		SingletonsAndConsts.deferred_add_child_to_game_elements__other_node_hoster(fragment)

func _attempt_induce_speed_slowdown_on_player(arg_player):
	if is_instance_valid(arg_player):
		if _can_induce_speed_slowdown:
			_can_induce_speed_slowdown = false
			_induce_speed_slowdown_on_break_cooldown_timer.start(SPEED_SLOWDOWN_COOLDOWN)
			
			var slowdown_vec = arg_player.linear_velocity * -speed_slowdown_on_tile_break
			arg_player.apply_outside_induced_force(slowdown_vec)
	

#

func can_induce_rotation_change__due_to_cell_v_changes() -> bool:
	return _can_induce_rotation_change__due_to_cell_v_changes

#

func get_tilemap():
	return tilemap


#


func _set_tile_at_coords(arg_coords : Vector2, arg_tile_id : int, arg_autotile_coords = Vector2(0, 0),
		arg_update_dirty_quadrants : bool = false,
		arg_save_tiles_data_next_frame__for_rewind_save : bool = true,
		arg_flip_x : bool = false, arg_flip_y : bool = false,
		arg_transpose : bool = false):
	
	
	if arg_save_tiles_data_next_frame__for_rewind_save:
		#_save_tiles_data_next_frame__for_rewind_save = true
		_save_tiles_data_next_frame__for_rewind_save__count += 1
		#_saved_cell_data = _generate_cells_save_data()
		_saved_cell_data_queue.append(_generate_cells_save_data())
	
	tilemap.set_cellv(arg_coords, arg_tile_id, arg_flip_x, arg_flip_y, arg_transpose, arg_autotile_coords)
	
	if arg_update_dirty_quadrants:
		#tilemap.update_dirty_quadrants()
		tilemap.call_deferred("update_dirty_quadrants")
	
	if arg_save_tiles_data_next_frame__for_rewind_save:
		_update_cells_save_data()
		


###################### 
# REWIND RELATED
#####################

export(bool) var is_rewindable : bool

var _rewinded__velocity

#

func queue_free():
	if SingletonsAndConsts.current_rewind_manager.is_obj_registered_in_rewindables(self):
		SingletonsAndConsts.current_rewind_manager.connect("obj_removed_from_rewindables", self, "_on_obj_removed_from_rewindables")
		
		#collision_shape.set_deferred("disabled", true)
		visible = false
		
	else:
		.queue_free()
		

func _on_obj_removed_from_rewindables(arg_obj):
	if arg_obj == self:
		.queue_free()



func get_rewind_save_state():
	#var state : Physics2DDirectBodyState = Physics2DServer.body_get_direct_state(get_rid())
	var save_state = {
		"velocity" : velocity,
		"rotation" : rotation,
		"transform" : transform,
		
		"energy_mode" : energy_mode,
		
		#"applied_changes_for_breakable" : _applied_changes_for_breakable,
	}
	
	#if _save_tiles_data_next_frame__for_rewind_save:
	if _save_tiles_data_next_frame__for_rewind_save__count > 0:
		#_save_tiles_data_next_frame__for_rewind_save = false
		_save_tiles_data_next_frame__for_rewind_save__count -= 1
		save_state["cell_save_data"] = _saved_cell_data_queue.pop_front()#_saved_cell_data
		#print(save_state["cell_save_data"])
	
	return save_state

func load_into_rewind_save_state(arg_state):
	_rewinded__velocity = arg_state["velocity"]
	rotation = arg_state["rotation"]
	transform = arg_state["transform"]
	set_energy_mode(arg_state["energy_mode"])
	#_applied_changes_for_breakable = arg_state["applied_changes_for_breakable"]
	
	if arg_state.has("cell_save_data"):
		var saved_cell_data = arg_state["cell_save_data"]
		if saved_cell_data != null:
			_update_cells_based_on_saved_difference_from_current(saved_cell_data)
	

func destroy_from_rewind_save_state():
	.queue_free()
	


func stared_rewind():
	pass
	#_save_tiles_data_next_frame__for_rewind_save = true
	#mode = RigidBody2D.MODE_STATIC
	#collision_shape.set_deferred("disabled", true)
	

func ended_rewind():
	velocity = _rewinded__velocity
	_applied_changes_for_breakable = false
	#mode = RigidBody2D.MODE_RIGID
	#collision_shape.set_deferred("disabled", false)
	
	#_use_integ_forces_new_vals = true
	



func _has_cell_metadatas():
	return _cell_metadatas.size() != 0

func _update_cells_save_data():
	_cell_metadatas = _generate_cells_save_data()

func _generate_cells_save_data():
	var metadatas = {}
	for cell_coords in tilemap.get_used_cells():
		var cell_id = tilemap.get_cellv(cell_coords)
		var auto_coords = tilemap.get_cell_autotile_coord(cell_coords.x, cell_coords.y)
		
		var data = []
		data.append(cell_id)
		data.append(auto_coords)
		
		metadatas[cell_coords] = data
	
	
	return metadatas


func _update_cells_based_on_saved_difference_from_current(arg_saved_cell_save_data):
	for cell_coord in arg_saved_cell_save_data.keys():
		var saved_data = arg_saved_cell_save_data[cell_coord]
		var saved_cell_id = saved_data[0]
		var saved_auto_coords = saved_data[1]
		
		if TileConstants.is_tile_id_glowing(saved_cell_id):
			saved_cell_id = TileConstants.convert_glowing_breakable_tile_id__to_non_glowing(saved_cell_id)
		
		if _cell_metadatas.has(cell_coord):
			var curr_data = _cell_metadatas[cell_coord]
			var curr_cell_id = curr_data[0]
			var curr_auto_coords = curr_data[1]
			
			if TileConstants.is_tile_id_glowing(curr_cell_id):
				curr_cell_id = TileConstants.convert_glowing_breakable_tile_id__to_non_glowing(curr_cell_id)
			
			
			if saved_cell_id != curr_cell_id or saved_auto_coords != curr_auto_coords:
				_set_tile_at_coords(cell_coord, saved_cell_id, saved_auto_coords, false, false)
			
		else:
			_set_tile_at_coords(cell_coord, saved_cell_id, saved_auto_coords, false, false)
			
		
	
	for cell_coord in _cell_metadatas:
		if !arg_saved_cell_save_data.has(cell_coord):
			_set_tile_at_coords(cell_coord, -1, Vector2(0, 0), false, false)
			
		else:
			var curr_data = _cell_metadatas[cell_coord]
			var curr_cell_id = curr_data[0]
			var curr_auto_coords = curr_data[1]
			
			var saved_data = arg_saved_cell_save_data[cell_coord]
			var saved_cell_id = saved_data[0]
			var saved_auto_coords = saved_data[1]
			
			if TileConstants.is_tile_id_glowing(saved_cell_id):
				saved_cell_id = TileConstants.convert_glowing_breakable_tile_id__to_non_glowing(saved_cell_id)
			if TileConstants.is_tile_id_glowing(curr_cell_id):
				curr_cell_id = TileConstants.convert_glowing_breakable_tile_id__to_non_glowing(curr_cell_id)
			
			
			if saved_cell_id != curr_cell_id or saved_auto_coords != curr_auto_coords:
				_set_tile_at_coords(cell_coord, saved_cell_id, saved_auto_coords, false, false)
	
	#
	
	tilemap.update_dirty_quadrants()
	
	_cell_metadatas = arg_saved_cell_save_data


