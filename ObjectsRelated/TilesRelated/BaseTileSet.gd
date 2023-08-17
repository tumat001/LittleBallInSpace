extends StaticBody2D


const ObjectDetailsPanel = preload("res://GameFrontHUDRelated/Subs/TooltipRelateds/ObjectDetails/ObjectDetailsPanel.gd")
const ObjectDetailsPanel_Scene = preload("res://GameFrontHUDRelated/Subs/TooltipRelateds/ObjectDetails/ObjectDetailsPanel.tscn")

const LightTextureConstructor = preload("res://MiscRelated/Light2DRelated/LightTextureConstructor.gd")

##

signal light_2d_glowables_node_2d_container_setted()

##

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



export(bool) var has_glowables : bool = false
var _light_2d_glowables_node_2d_container : Node2D setget set_light_2d_glowables_node_2d_container


var _player setget set_player, get_player


var _applied_changes_for_breakable : bool
var break_on_player_contact : bool



var _can_induce_rotation_change__due_to_cell_v_changes : bool = true
var _can_induce_rotation_after_delay_timer : Timer

const SPEED_SLOWDOWN_COOLDOWN : float = 0.1
var _induce_speed_slowdown_on_break_cooldown_timer : Timer
var _can_induce_speed_slowdown : bool = true


#

enum TilemapModulateIds {
	ENERGY_MODE = 0
	BUTTON_ASSOCIATED = 1
}
var _modulates_of_tilemap : Dictionary

#


var _save_tiles_data_next_frame__for_rewind_save__count : int
var _saved_cell_data_queue : Array

# structure: cell_pos -> [cell id, cell auto-coord, other datas<dict>]
var _cell_metadatas = {}

#

#var changing_colls__from_fill_and_unfilled = false
#var changing_colls__rid_changed_colls : Array 

#

var _object_details_panel_tooltip

#

var is_class_type_base_tileset : bool = true

#

var is_responsible_for_own_movement__for_rewind : bool = true setget set_is_responsible_for_own_movement__for_rewind

#

onready var tilemap = $TileMap

#

func set_player(arg_player):
	_player = arg_player

func get_player():
	return _player

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
	
	SingletonsAndConsts.current_rewind_manager.connect("rewinding_started", self, "_on_rewinding_started")
	
	_update_display_based_on_has_glowables()

func _update_display_based_on_energy_mode():
	if energy_mode == EnergyMode.ENERGIZED:
		#tilemap.modulate = ENERGIZED_MODULATE
		set_modulate_for_tilemap(TilemapModulateIds.ENERGY_MODE, ENERGIZED_MODULATE)
	elif energy_mode == EnergyMode.NORMAL:
		#tilemap.modulate = NORMAL_MODULATE
		set_modulate_for_tilemap(TilemapModulateIds.ENERGY_MODE, NORMAL_MODULATE)
	elif energy_mode == EnergyMode.INSTANT_GROUND:
		#tilemap.modulate = INSTANT_GROUND_MODULATE
		set_modulate_for_tilemap(TilemapModulateIds.ENERGY_MODE, INSTANT_GROUND_MODULATE)
		

#

func set_modulate_for_tilemap(arg_id, arg_modulate):
	_modulates_of_tilemap[arg_id] = arg_modulate
	_update_tilemap_modulate()
	

func remove_modulate_from_tilemap(arg_id):
	_modulates_of_tilemap.erase(arg_id)
	_update_tilemap_modulate()

func _update_tilemap_modulate():
	if _modulates_of_tilemap.size() > 0:
		var color_total : Color = Color(0, 0, 0, 0)
		for id in _modulates_of_tilemap.keys():
			color_total += _modulates_of_tilemap[id]
		
		tilemap.modulate = color_total / _modulates_of_tilemap.size()
		
	else:
		tilemap.modulate = Color(1, 1, 1, 1)

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
		
		make_tileset_rewindable()

func make_tileset_rewindable():
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
	_player.remove_on_ground_count_with_identif__from_breakable_tile__before_breaking(arg_tile_coord, self)
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

func _create_default_arr_data_for_setting_tiles__separated_arrs(arg_coords : Array, arg_tile_ids : Array, arg_autotile_coords : Array):
	var arr = []
	
	for i in arg_coords.size():
		arr.append([arg_coords[i], arg_tile_ids[i], arg_autotile_coords[i], false, false, false])
	
	return arr

func _create_default_arr_data_for_setting_tiles__in_one_arr(arg_coords_ids_and_auto_coords):
	var arr = []
	for data in arg_coords_ids_and_auto_coords:
		arr.append([data[0], data[1], data[2], false, false, false])
	
	return arr



func _set_tiles_at_coords(arg_arr_data, 
		arg_update_dirty_quadrants : bool, arg_save_tiles_data_next_frame__for_rewind_save : bool = true):
	
	if arg_save_tiles_data_next_frame__for_rewind_save:
		_save_tiles_data_next_frame__for_rewind_save__count += 1
		_saved_cell_data_queue.append(_generate_cells_save_data())
	
	#tilemap.set_collision_mask_bit(0, false)
	
	for data in arg_arr_data:
		var arg_coords = data[0]
		var arg_tile_id = data[1]
		var arg_autotile_coords = data[2]
		var arg_flip_x = data[3]
		var arg_flip_y = data[4]
		var arg_transpose = data[5]
		
		if is_instance_valid(_player):
			_player.remove_on_ground_count_with_identif__from_any_purpose__changing_tiles__before_change(arg_coords, self)
		
		tilemap.set_cellv(arg_coords, arg_tile_id, arg_flip_x, arg_flip_y, arg_transpose, arg_autotile_coords)
		
	
	#tilemap.fix_invalid_tiles()
	
	#tilemap.set_collision_mask_bit(0, true)
	
	if arg_update_dirty_quadrants:
		#tilemap.update_dirty_quadrants()
		tilemap.call_deferred("update_dirty_quadrants")
		#call_deferred("_tilemap_update_dirty_quadrants")
	
	if arg_save_tiles_data_next_frame__for_rewind_save:
		_update_cells_save_data()
		



# make arr version of this
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
	
	if is_instance_valid(_player):
		_player.remove_on_ground_count_with_identif__from_any_purpose__changing_tiles__before_change(arg_coords, self)
	#changing_colls__rid_changed_colls.append(arg_coords)
	
	#if !SingletonsAndConsts.current_rewind_manager.is_rewinding:
	#	changing_colls__from_fill_and_unfilled = true
	#set_deferred("changing_colls__from_fill_and_unfilled", false)
	
	#tilemap.set_collision_mask_bit(0, false)
	tilemap.set_cellv(arg_coords, arg_tile_id, arg_flip_x, arg_flip_y, arg_transpose, arg_autotile_coords)
	#tilemap.set_collision_mask_bit(0, true)
	#tilemap.call_deferred("set_collision_mask_bit", 0, true)
	
	#tilemap.fix_invalid_tiles()
	
	if arg_update_dirty_quadrants:
		#tilemap.update_dirty_quadrants()
		#tilemap.call_deferred("update_dirty_quadrants")
		call_deferred("_tilemap_update_dirty_quadrants")
	
	if arg_save_tiles_data_next_frame__for_rewind_save:
		_update_cells_save_data()
		


#func _tilemap_update_dirty_quadrants():
#	tilemap.update_dirty_quadrants()
#	changing_colls__from_fill_and_unfilled = false

#

func convert_all_filled_tiles_to_unfilled():
	var at_least_one_changed : bool = false
	var cell_coords_id_and_auto_coords : Array = []
	
	for cell_coord in tilemap.get_used_cells():
		var id = tilemap.get_cellv(cell_coord)
		var old_id = id
		var unfilled_id_tentative = TileConstants.convert_filled_tile_id__to_unfilled(id)
		if unfilled_id_tentative != null:
			id = unfilled_id_tentative
		var auto_coord = tilemap.get_cell_autotile_coord(cell_coord.x, cell_coord.y)
		
		if id != old_id:
			at_least_one_changed = true
			cell_coords_id_and_auto_coords.append([cell_coord, id, auto_coord])
			
	
	if at_least_one_changed:
		#changing_colls__from_fill_and_unfilled = true
		
		_save_tiles_data_next_frame__for_rewind_save__count += 1
		_saved_cell_data_queue.append(_generate_cells_save_data())
		#print("saved cell data: %s" % _generate_cells_save_data())
		
		#for cell_coords_id_and_auto_coord in cell_coords_id_and_auto_coords:
		#	#coords, id, and auto coord
		#	_set_tile_at_coords(cell_coords_id_and_auto_coord[0], cell_coords_id_and_auto_coord[1], cell_coords_id_and_auto_coord[2], false, false)
		#	
		
		var completed_data__cell_coords_id_auto_coords : Array = _create_default_arr_data_for_setting_tiles__in_one_arr(cell_coords_id_and_auto_coords)
		_set_tiles_at_coords(completed_data__cell_coords_id_auto_coords, true, true)
		
		#tilemap.call_deferred("update_dirty_quadrants")
		
		#_update_cells_save_data()
		#print("updated cell data: %s" % _cell_metadatas)
		#print("--------")
		
		

func convert_all_unfilled_tiles_to_filled():
	var at_least_one_changed : bool = false
	var cell_coords_id_and_auto_coords : Array = []
	for cell_coords in tilemap.get_used_cells():
		var id = tilemap.get_cellv(cell_coords)
		var old_id = id
		var filled_id_tentative = TileConstants.convert_unfilled_tile_id__to_filled(id)
		if filled_id_tentative != null:
			id = filled_id_tentative
		var auto_coords = tilemap.get_cell_autotile_coord(cell_coords.x, cell_coords.y)
		
		if id != old_id:
			at_least_one_changed = true
			cell_coords_id_and_auto_coords.append([cell_coords, id, auto_coords])
	
	if at_least_one_changed:
		#changing_colls__from_fill_and_unfilled = true
		
		_save_tiles_data_next_frame__for_rewind_save__count += 1
		_saved_cell_data_queue.append(_generate_cells_save_data())
		
		
		var completed_data__cell_coords_id_auto_coords : Array = _create_default_arr_data_for_setting_tiles__in_one_arr(cell_coords_id_and_auto_coords)
		_set_tiles_at_coords(completed_data__cell_coords_id_auto_coords, true, true)
		
		
		#for cell_coords_id_and_auto_coord in cell_coords_id_and_auto_coords:
		#	_set_tile_at_coords(cell_coords_id_and_auto_coord[0], cell_coords_id_and_auto_coord[1], cell_coords_id_and_auto_coord[2], false, false)
		
		#tilemap.call_deferred("update_dirty_quadrants")
		
		#_update_cells_save_data()
		
		

func toggle_fill_to_unfilled_and_vise_versa():
	var at_least_one_changed : bool = false
	var cell_coords_id_and_auto_coords : Array = []
	for cell_coords in tilemap.get_used_cells():
		var id = tilemap.get_cellv(cell_coords)
		var old_id = id
		
		if TileConstants.is_tile_id_fillable_or_unfillable(id):
			if TileConstants.is_tile_id_filled(id):
				var unfilled_id_tentative = TileConstants.convert_filled_tile_id__to_unfilled(id)
				if unfilled_id_tentative != null:
					id = unfilled_id_tentative
				
				#print("unfiled")
				
			else:
				var filled_id_tentative = TileConstants.convert_unfilled_tile_id__to_filled(id)
				if filled_id_tentative != null:
					id = filled_id_tentative
				
				#print("filled")
				
			
			#print("id: %s, old: %s" % [id, old_id])
			#print("---------")
			
			var auto_coords = tilemap.get_cell_autotile_coord(cell_coords.x, cell_coords.y)
			
			if id != old_id:
				at_least_one_changed = true
				cell_coords_id_and_auto_coords.append([cell_coords, id, auto_coords])
	
	if at_least_one_changed:
		#changing_colls__from_fill_and_unfilled = true
		
		_save_tiles_data_next_frame__for_rewind_save__count += 1
		_saved_cell_data_queue.append(_generate_cells_save_data())
		
		
		var completed_data__cell_coords_id_auto_coords : Array = _create_default_arr_data_for_setting_tiles__in_one_arr(cell_coords_id_and_auto_coords)
		_set_tiles_at_coords(completed_data__cell_coords_id_auto_coords, true, true)
		
		#for cell_coords_id_and_auto_coord in cell_coords_id_and_auto_coords:
		#	_set_tile_at_coords(cell_coords_id_and_auto_coord[0], cell_coords_id_and_auto_coord[1], cell_coords_id_and_auto_coord[2], false, false)
		
		#tilemap.call_deferred("update_dirty_quadrants")
		
		#_update_cells_save_data()
		
	
	



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
		
		# if saved cell coord exists in current
		if _cell_metadatas.has(cell_coord):
			var curr_data = _cell_metadatas[cell_coord]
			var curr_cell_id = curr_data[0]
			var curr_auto_coords = curr_data[1]
			
			if TileConstants.is_tile_id_glowing(curr_cell_id):
				curr_cell_id = TileConstants.convert_glowing_breakable_tile_id__to_non_glowing(curr_cell_id)
			
			if saved_cell_id != curr_cell_id or saved_auto_coords != curr_auto_coords:
				_set_tile_at_coords(cell_coord, saved_cell_id, saved_auto_coords, false, false)
			
			
		else: # if saved cell coord does not exist in current
			
			_set_tile_at_coords(cell_coord, saved_cell_id, saved_auto_coords, false, false)
			
		
	
	for cell_coord in _cell_metadatas:
		if !arg_saved_cell_save_data.has(cell_coord):
			_set_tile_at_coords(cell_coord, -1, Vector2(0, 0), false, false)
			
		else:
			pass
			
#			var curr_data = _cell_metadatas[cell_coord]
#			var curr_cell_id = curr_data[0]
#			var curr_auto_coords = curr_data[1]
#
#			var saved_data = arg_saved_cell_save_data[cell_coord]
#			var saved_cell_id = saved_data[0]
#			var saved_auto_coords = saved_data[1]
#
#			if TileConstants.is_tile_id_glowing(saved_cell_id):
#				saved_cell_id = TileConstants.convert_glowing_breakable_tile_id__to_non_glowing(saved_cell_id)
#			if TileConstants.is_tile_id_glowing(curr_cell_id):
#				curr_cell_id = TileConstants.convert_glowing_breakable_tile_id__to_non_glowing(curr_cell_id)
#
#
#			if saved_cell_id != curr_cell_id or saved_auto_coords != curr_auto_coords:
#				_set_tile_at_coords(cell_coord, saved_cell_id, saved_auto_coords, false, false)
	
	#
	
	tilemap.update_dirty_quadrants()
	
	_cell_metadatas = arg_saved_cell_save_data


######


func _on_BaseTileSet_mouse_entered():
	if !SingletonsAndConsts.current_rewind_manager.is_rewinding:
		var desc = ObjectDetailsPanel.generate_descs__for_tileset(self)
		if desc.size() != 0:
			_object_details_panel_tooltip = ObjectDetailsPanel_Scene.instance()
			
			SingletonsAndConsts.current_game_front_hud.add_node_to_tooltip_container(_object_details_panel_tooltip)
			
			_object_details_panel_tooltip.show_descs(desc)


func _on_BaseTileSet_mouse_exited():
	_queue_free_object_details_tooltip()

func _on_rewinding_started():
	_queue_free_object_details_tooltip()

func _queue_free_object_details_tooltip():
	if is_instance_valid(_object_details_panel_tooltip):
		_object_details_panel_tooltip.queue_free()
	

#

func set_is_responsible_for_own_movement__for_rewind(arg_val):
	is_responsible_for_own_movement__for_rewind = arg_val
	

#


func set_light_2d_glowables_node_2d_container(arg_node : Node2D):
	_light_2d_glowables_node_2d_container = arg_node
	
	emit_signal("light_2d_glowables_node_2d_container_setted", _light_2d_glowables_node_2d_container)

#

func _update_display_based_on_has_glowables():
	if has_glowables:
		if is_instance_valid(_light_2d_glowables_node_2d_container):
			call_deferred("_deferred__create_light_2ds_based_on_curr_tiles")
		else:
			connect("light_2d_glowables_node_2d_container_setted", self, "_on_light_2d_glowables_node_2d_container_setted__for_light_2d_creation", [], CONNECT_ONESHOT)

func _on_light_2d_glowables_node_2d_container_setted__for_light_2d_creation(arg_node_container):
	call_deferred("_deferred__create_light_2ds_based_on_curr_tiles")


func _deferred__create_light_2ds_based_on_curr_tiles():
	for cell_coords in tilemap.get_used_cells():
		var cell_id = tilemap.get_cellv(cell_coords)
		var auto_coords = tilemap.get_cell_autotile_coord(cell_coords.x, cell_coords.y)
		
		
		var light_details = TileConstants.get_light_details_of_tile_id(cell_id, auto_coords)
		if light_details != null:
			var tile_local_pos_top_left = tilemap.map_to_world(cell_coords)
			var tile_local_pos = tile_local_pos_top_left + (tilemap.cell_size / 2)
			
			var light_2d = _create_light_2d_on_light_container()
			light_2d.position = tile_local_pos
			light_2d.texture = light_details.light_texture
			light_2d.rotation = light_details.rotation
			light_2d.offset = light_details.offset
			

func _create_light_2d_on_light_container() -> Light2D:
	var light2d = Light2D.new()
	_light_2d_glowables_node_2d_container.add_child(light2d)
	#SingletonsAndConsts.add_child_to_game_elements__other_node_hoster(light2d)
	
	return light2d


#

func has_tile_by_body_shape_index(arg_idx : int):
	var count = 0
	for owner_id in get_shape_owners():
		count += shape_owner_get_shape_count(owner_id)
	
	#print("count: %s, arg_idx: %s" % [count, arg_idx])
	return count - 1 > arg_idx
	
#	var count = shape_owner_get_shape_count(0)
#	print("count: %s, arg_idx: %s" % [count, arg_idx])
#	return count - 1 > arg_idx
	
#	var tile_count = tilemap.get_used_cells().size()
#	print("tile_count: %s, idx: %s" % [tile_count, arg_idx])
#	return tile_count - 1 > arg_idx



###################### 
# REWIND RELATED
#####################

export(bool) var is_rewindable : bool
var is_dead_but_reserved_for_rewind : bool


#

func queue_free():
	if SingletonsAndConsts.current_rewind_manager.is_obj_registered_in_rewindables(self):
		SingletonsAndConsts.current_rewind_manager.connect("obj_removed_from_rewindables", self, "_on_obj_removed_from_rewindables")
		
		#collision_shape.set_deferred("disabled", true)
		visible = false
		is_dead_but_reserved_for_rewind = true
		
	else:
		.queue_free()
		

func _on_obj_removed_from_rewindables(arg_obj):
	if arg_obj == self:
		.queue_free()



func get_rewind_save_state():
	#var state : Physics2DDirectBodyState = Physics2DServer.body_get_direct_state(get_rid())
	var save_state = {
		"is_responsible_for_own_movement__for_rewind" : is_responsible_for_own_movement__for_rewind,
		
		"energy_mode" : energy_mode,
		#"applied_changes_for_breakable" : _applied_changes_for_breakable,
	}
	
	if is_responsible_for_own_movement__for_rewind:
		save_state["rotation"] = rotation
		save_state["transform"] = transform
		
	
	#if _save_tiles_data_next_frame__for_rewind_save:
	if _save_tiles_data_next_frame__for_rewind_save__count > 0:
		#_save_tiles_data_next_frame__for_rewind_save = false
		_save_tiles_data_next_frame__for_rewind_save__count -= 1
		save_state["cell_save_data"] = _saved_cell_data_queue.pop_front()#_saved_cell_data
		#print(save_state["cell_save_data"])
	
	return save_state

func load_into_rewind_save_state(arg_state):
	var _is_responsible = arg_state["is_responsible_for_own_movement__for_rewind"]
	if _is_responsible:
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
	

func restore_from_destroyed_from_rewind():
	is_dead_but_reserved_for_rewind = false
	

func stared_rewind():
	pass
	#_save_tiles_data_next_frame__for_rewind_save = true
	#mode = RigidBody2D.MODE_STATIC
	#collision_shape.set_deferred("disabled", true)
	

func ended_rewind():
	if !is_dead_but_reserved_for_rewind:
		_applied_changes_for_breakable = false
		#mode = RigidBody2D.MODE_RIGID
		#collision_shape.set_deferred("disabled", false)
		
		#_use_integ_forces_new_vals = true
	
