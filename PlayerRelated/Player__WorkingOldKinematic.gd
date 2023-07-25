extends KinematicBody2D

const ConditionalClauses = preload("res://MiscRelated/ClauseRelated/ConditionalClauses.gd")

const BaseTileSet = preload("res://ObjectsRelated/TilesRelated/BaseTileSet.gd")

const BaseObject = preload("res://ObjectsRelated/Objects/BaseObject.gd")

const PlayerModi_Energy = preload("res://PlayerRelated/PlayerModi/Imps/EnergyRelated/PlayerModi_Energy.gd")


signal last_calculated_object_mass_changed(arg_val)

signal unhandled_key_input_received(event)

signal request_rotate(arg_data)



signal body_shape_exited(body_rid, body, body_shape_index, local_shape_index)
signal body_shape_entered(body_rid, body, body_shape_index, local_shape_index)

#

enum BlockPlayerMoveLeftAndRightClauseIds {
	NOT_ON_GROUND = 0
}

var block_player_move_left_and_right_cond_clauses : ConditionalClauses
var last_calc_can_player_move_left_and_right : bool

var _is_on_ground : bool
var _is_on_ground__with_energy : bool

var _on_ground_any_identif_list : Array
var _on_ground_any_identif_list__with_energy : Array


var _is_moving_left : bool
var _is_moving_right : bool

#

var _player_prev_global_position : Vector2
var _player_pos_change_from_last_frame : Vector2
var _player_linear_velocity : Vector2

#

enum BlockRotateClauseIds {
	IS_ROTATING = 0
	HAS_SPEED = 1
}
var block_rotate_cond_clause : ConditionalClauses
var last_calc_is_rotate_ready : bool


#


#var player_rad_rotation_modi : float  replaced with CameraManager.current_cam_rotation

const MIN_ANGLE_DIFF_TO_TRIGGER_ROTATION : float = -45.0 * (PI / 180)
const MIN_ANGLE_DIFF_TO_TRIGGER_ROTATION__OTHER_SIDE : float = -135.0 * (PI / 180)



#var _pos_change_at_request_for_rotate_at_next_physics_step : Vector2
#var _requesting_rotate_at_next_physics_step : bool
#var _ground_identif_on_rotate


class RotationRequestData:
	var angle
	var ground_identif_on_rotate


#

const MAX_PLAYER_MOVE_LEFT_RIGHT_SPEED = 200
const ON_INPUT_PLAYER_MOVE_LEFT_RIGHT_PER_SEC = 200
const PLAYER_MOV_MULTIPLER_ON_OPPOSITE_CURR_SPEED : float = 1.5
var _current_player_left_right_move_speed : float

##

enum IgnoreOutsideInducedForcesClauseIds {
	IS_ON_GROUND = 1
}
var ignore_outside_induced_forces_cond_clauses : ConditionalClauses
var last_calc_ignore_outside_induced_forces : bool

var _all_outside_induced_forces_list : Array
var _all_inside_induced_forces_list : Array

###


var _base_object_mass : float = 140.0
var _flat_mass_id_to_amount_map : Dictionary
var last_calculated_object_mass : float

#

var _all_nodes_to_rotate_with_cam : Array


#

class ShapePointsData:
	# seg and midpoint ->: [x, y, midpoint, perpend_angle]
	var list_of__segments_and_midpoint_and_perpend_angle : Array
	

const CIRCLE_PARTITION = (2*PI/8) #North, NW, W, ...

var _shape_points_to_data_map : Dictionary


#

var _objects_to_not_collide_with : Array
var _objects_to_collide_with_after_exit : Array
var _objects_to_add_mask_layer_collision_after_exit : Array

#

# do not set these vars. use methods. but getting is fine
var player_modi__energy : PlayerModi_Energy
var is_player_modi_energy_set : bool

const IN_ENERGY__ENERGY_CHARGE_PER_SEC__PERCENT = 0.3
const OUT_ENERGY__ENERGY_DISCHARGE_PER_SEC__FLAT = 1.0


#

onready var sprite_layer = $SpriteLayer

onready var floor_area_2d = $FloorArea2D
onready var floor_area_2d_coll_shape = $FloorArea2D/CollisionShape2D

#onready var remote_transform_2d = $RemoteTransform2D

#

func _init():
	block_player_move_left_and_right_cond_clauses = ConditionalClauses.new()
	block_player_move_left_and_right_cond_clauses.connect("clause_inserted", self, "_on_block_move_left_and_right_cond_clauses_updated", [], CONNECT_PERSIST)
	block_player_move_left_and_right_cond_clauses.connect("clause_removed", self, "_on_block_move_left_and_right_cond_clauses_updated", [], CONNECT_PERSIST)
	block_player_move_left_and_right_cond_clauses.attempt_insert_clause(BlockPlayerMoveLeftAndRightClauseIds.NOT_ON_GROUND)
	
	
	block_rotate_cond_clause = ConditionalClauses.new()
	block_rotate_cond_clause.connect("clause_inserted", self, "_on_block_rotate_cond_clause_updated", [], CONNECT_PERSIST)
	block_rotate_cond_clause.connect("clause_removed", self, "_on_block_rotate_cond_clause_updated", [], CONNECT_PERSIST)
	_update_last_calc_is_rotate_ready()
	
	
	ignore_outside_induced_forces_cond_clauses = ConditionalClauses.new()
	ignore_outside_induced_forces_cond_clauses.connect("clause_inserted", self, "_on_ignore_outside_induced_forces_cond_clauses_updated", [], CONNECT_PERSIST)
	ignore_outside_induced_forces_cond_clauses.connect("clause_removed", self, "_on_ignore_outside_induced_forces_cond_clauses_updated", [], CONNECT_PERSIST)
	_update_last_calc_ignore_outside_induced_forces()
	
	
	_update_last_calculated_object_mass()

#

func _on_block_move_left_and_right_cond_clauses_updated(arg_clause_id):
	_update_last_calc_can_move_left_and_right()
	

func _update_last_calc_can_move_left_and_right():
	last_calc_can_player_move_left_and_right = block_player_move_left_and_right_cond_clauses.is_passed


#

func _on_block_rotate_cond_clause_updated(arg_clause_id):
	_update_last_calc_is_rotate_ready()

func _update_last_calc_is_rotate_ready():
	last_calc_is_rotate_ready = block_rotate_cond_clause.is_passed

#

func _on_ignore_outside_induced_forces_cond_clauses_updated(arg_clause_id):
	_update_last_calc_ignore_outside_induced_forces()
	

func _update_last_calc_ignore_outside_induced_forces():
	last_calc_ignore_outside_induced_forces = !ignore_outside_induced_forces_cond_clauses.is_passed
	

#

func _update_last_calculated_object_mass():
	var total = _base_object_mass
	for mass in _flat_mass_id_to_amount_map:
		total += mass
	
	last_calculated_object_mass = total
	emit_signal("last_calculated_object_mass_changed", last_calculated_object_mass)


#######

func _on_FloorArea2D_body_shape_entered(body_rid, body, body_shape_index, local_shape_index):
	#TODO check if body is breakable. if it is, attempt break. if not broken, attempt do rotation
	
	if !has_object_to_not_collide_with(body):
		
		
		if body is BaseTileSet:
			_on_body_entered__tilemap(body_rid, body, body_shape_index, local_shape_index)
			
		elif body is BaseObject:
			_on_body_entered__base_object(body_rid, body, body_shape_index, local_shape_index)
			
	
	
	emit_signal("body_shape_entered", body_rid, body, body_shape_index, local_shape_index)



func _on_body_entered__tilemap(body_rid, body, body_shape_index, local_shape_index):
	var is_tileset_energized = body.is_energized
	
	
	var coordinate: Vector2 = Physics2DServer.body_get_shape_metadata(body.get_rid(), body_shape_index)
	var tilemap : TileMap = body.tilemap
	
	var tile_local_pos_top_left = tilemap.map_to_world(coordinate)
	var tile_local_pos = tile_local_pos_top_left + (tilemap.cell_size / 2)
	var tile_global_pos = tilemap.to_global(tile_local_pos)
	var tile_global_pos_top_left = tilemap.to_global(tile_local_pos_top_left)
	
	var body_shape_owner_id = body.shape_find_owner(body_shape_index)
	var body_shape_owner = body.shape_owner_get_owner(body_shape_owner_id)
	var body_shape_2d = body.shape_owner_get_shape(body_shape_owner_id, 0)
	var body_global_transform : Transform2D = body_shape_owner.global_transform
	
	
	var body_shape_points = body_shape_2d.points
	_calculate_and_store_midpoints_of_points(body_shape_points)
	
	var current_lowest_distance : float = 100000
	var midpoint_with_lowest_distance : Vector2
	var perpend_angle_with_lowest_distance : float
	var shape_data : ShapePointsData = _shape_points_to_data_map[body_shape_points]
	for seg_and_midpoint_and_perpend_angle in shape_data.list_of__segments_and_midpoint_and_perpend_angle:
		var midpoint = seg_and_midpoint_and_perpend_angle[2]
		var global_midpoint = midpoint + tile_global_pos_top_left
		
		var dist = global_position.distance_to(global_midpoint)
		if current_lowest_distance > dist:
			current_lowest_distance = dist
			midpoint_with_lowest_distance = midpoint
			perpend_angle_with_lowest_distance = seg_and_midpoint_and_perpend_angle[3]
	
	
	var is_same_angle_as_perpend_angle : bool = CameraManager.current_cam_rotation == perpend_angle_with_lowest_distance
	
	if !is_same_angle_as_perpend_angle:
		#_request_rotate__at_next_physics_step(_player_pos_change_from_last_frame, coordinate)
		_attempt_remove_on_ground_count__with_any_identif(coordinate)
		_request_rotate(perpend_angle_with_lowest_distance, coordinate, is_tileset_energized)
		_current_player_left_right_move_speed = 0
		
		clear_all_inside_induced_forces()
		clear_all_outside_induced_forces()
		
	else:
		_attempt_add_on_ground_count__with_any_indentif(coordinate, is_tileset_energized)
		clear_all_outside_induced_forces()
		clear_all_inside_induced_forces()
		

func _calculate_and_store_midpoints_of_points(arg_points : PoolVector2Array):
	if !_shape_points_to_data_map.has(arg_points):
		
		var data_map = ShapePointsData.new()
		data_map.list_of__segments_and_midpoint_and_perpend_angle = _convert_arr_of_clockwise_points_to_segments_and_midpoint_and_perpend(arg_points)
		_shape_points_to_data_map[arg_points] = data_map
		
	


func _convert_arr_of_clockwise_points_to_segments_and_midpoint_and_perpend(arg_points : PoolVector2Array):
	var segments_and_midpoint : Array = []
	for i in arg_points.size():
		var next_i = i + 1
		if next_i >= arg_points.size():
			next_i = 0
		
		var a = arg_points[i]
		var b = arg_points[next_i]
		var mid_point = (a + b) / 2
		var perpend_angle = b.angle_to_point(a) #a.angle_to_point(b) + PI/2
		
		var translated = perpend_angle / CIRCLE_PARTITION
		var perfected_translated = round(translated)
		var perfected_angle = perfected_translated * CIRCLE_PARTITION
		
		segments_and_midpoint.append([a, b, mid_point, perfected_angle])
		
	
	return segments_and_midpoint


##

func _on_FloorArea2D_body_shape_exited(body_rid, body, body_shape_index, local_shape_index):
	if body is BaseTileSet:
		var coordinate: Vector2 = Physics2DServer.body_get_shape_metadata(body.get_rid(), body_shape_index)
		
		_attempt_remove_on_ground_count__with_any_identif(coordinate)
	
	
	if _objects_to_collide_with_after_exit.has(body):
		remove_objects_to_not_collide_with(body)
		remove_objects_to_collide_with_after_exit(body)
	
	if _objects_to_add_mask_layer_collision_after_exit.has(body):
		body.set_collision_mask_bit(0, true)
		remove_objects_to_add_mask_layer_collision_after_exit(body)
	
	emit_signal("body_shape_exited", body_rid, body, body_shape_index, local_shape_index)



#func _on_FloorArea2D_area_shape_entered(area_rid, area, area_shape_index, local_shape_index):
#	#TODO check if body is breakable. if it is, attempt break. if not broken, attempt do rotation
#	pass
##	var body_shape_owner_id = area.shape_find_owner(area_shape_index)
##	var body_shape_owner = area.shape_owner_get_owner(body_shape_owner_id)
##	var body_shape_2d = area.shape_owner_get_shape(body_shape_owner_id, 0)
##	var body_global_transform = body_shape_owner.global_transform
##
##	var area_shape_owner_id = shape_find_owner(local_shape_index)
##	var area_shape_owner = shape_owner_get_owner(area_shape_owner_id)
##	var area_shape_2d = shape_owner_get_shape(area_shape_owner_id, 0)
##	var area_global_transform = area_shape_owner.global_transform
##
##	var collision_points = area_shape_2d.collide_and_get_contacts(area_global_transform,
##		body_shape_2d,
##		body_global_transform)
##
##	print(collision_points)
#
#
#func _on_FloorArea2D_area_shape_exited(area_rid, area, area_shape_index, local_shape_index):
#	pass # Replace with function body.


##############


func _attempt_add_on_ground_count__with_any_indentif(arg_identif, arg_is_tileset_energized):
	if !_on_ground_any_identif_list.has(arg_identif):
		_on_ground_any_identif_list.append(arg_identif)
		
		if arg_is_tileset_energized:
			if !_on_ground_any_identif_list__with_energy.has(arg_identif):
				_on_ground_any_identif_list__with_energy.append(arg_identif)
		
		_update_is_on_ground__and_update_others()

func _attempt_remove_on_ground_count__with_any_identif(arg_identif):
	if _on_ground_any_identif_list.has(arg_identif):
		_on_ground_any_identif_list.erase(arg_identif)
		
		if _on_ground_any_identif_list__with_energy.has(arg_identif):
			_on_ground_any_identif_list__with_energy.erase(arg_identif)
		
		_update_is_on_ground__and_update_others()



func _update_is_on_ground__and_update_others():
	if _on_ground_any_identif_list.size() != 0:
		block_player_move_left_and_right_cond_clauses.remove_clause(BlockPlayerMoveLeftAndRightClauseIds.NOT_ON_GROUND)
		
		_is_on_ground = true
		
	else:
		block_player_move_left_and_right_cond_clauses.attempt_insert_clause(BlockPlayerMoveLeftAndRightClauseIds.NOT_ON_GROUND)
		
		_is_on_ground = false
	
	
	if _on_ground_any_identif_list__with_energy.size() != 0:
		_is_on_ground__with_energy = true
	else:
		_is_on_ground__with_energy = false


##

func _unhandled_key_input(event):
	var is_consumed = false
	
	if event.is_action_released("ui_left"):
		_is_moving_left = false
		
	elif event.is_action_released("ui_right"):
		_is_moving_right = false
		
	else:
		if event.is_action("ui_left"):
			_is_moving_left = true
		elif event.is_action("ui_right"):
			_is_moving_right = true
			
		
	
	
	if !is_consumed:
		emit_signal("unhandled_key_input_received", event)



func _physics_process(delta):
	if last_calc_can_player_move_left_and_right:
		if _is_moving_left:
			var speed_modi = ON_INPUT_PLAYER_MOVE_LEFT_RIGHT_PER_SEC * delta
			if _current_player_left_right_move_speed > 0:
				speed_modi *= PLAYER_MOV_MULTIPLER_ON_OPPOSITE_CURR_SPEED
			_current_player_left_right_move_speed -= speed_modi
			
			if _current_player_left_right_move_speed < -MAX_PLAYER_MOVE_LEFT_RIGHT_SPEED:
				_current_player_left_right_move_speed = -MAX_PLAYER_MOVE_LEFT_RIGHT_SPEED
			
		elif _is_moving_right:
			var speed_modi = ON_INPUT_PLAYER_MOVE_LEFT_RIGHT_PER_SEC * delta
			if _current_player_left_right_move_speed < 0:
				speed_modi *= PLAYER_MOV_MULTIPLER_ON_OPPOSITE_CURR_SPEED
			_current_player_left_right_move_speed += speed_modi
			
			if _current_player_left_right_move_speed > MAX_PLAYER_MOVE_LEFT_RIGHT_SPEED:
				_current_player_left_right_move_speed = MAX_PLAYER_MOVE_LEFT_RIGHT_SPEED
		
		#var final_mov = Vector2(_current_player_left_right_move_speed, 0)
		#apply_central_impulse(final_mov)
	
	
	var final_mov = Vector2(_current_player_left_right_move_speed, 0)
	final_mov = final_mov.rotated(CameraManager.current_cam_rotation)
	
	for vec2 in _all_inside_induced_forces_list:
		final_mov += vec2
	for vec2 in _all_outside_induced_forces_list:
		final_mov += vec2
	
	var mov_as_vec_occurred = move_and_slide(final_mov, Vector2(0, 0))
	# todo clean this up. Make the curr left right speed equal to mov vec occurred "x" magnitude
	if mov_as_vec_occurred == Vector2.ZERO:
		_current_player_left_right_move_speed = 0
		
		clear_all_inside_induced_forces()
		clear_all_outside_induced_forces()
	
	#
	
	var prev_pos_change_from_last_frame = _player_pos_change_from_last_frame
	_player_pos_change_from_last_frame = global_position - _player_prev_global_position
	_player_linear_velocity = _player_pos_change_from_last_frame / delta
	_player_prev_global_position = global_position
	
	
	if _player_pos_change_from_last_frame == Vector2.ZERO:
		_current_player_left_right_move_speed = 0
		
		clear_all_inside_induced_forces()
		clear_all_outside_induced_forces()
	
	#if _requesting_rotate_at_next_physics_step:
	#	if _player_pos_change_from_last_frame != _pos_change_at_request_for_rotate_at_next_physics_step:
	#		_request_rotate(_player_pos_change_from_last_frame, prev_pos_change_from_last_frame)

#func _remove_all_non_ground_parallel_impulses():
#	#todo make it depend on angle
#	var non_ground_forces = Vector2(0, linear_velocity.y)
#	apply_central_impulse(-non_ground_forces)
#
#
#func _remove_all_non_ground_parallel_velocity():
#	#todo make it depend on angle
#	linear_velocity.y = 0
#


func _process(delta):
	if is_player_modi_energy_set:
		if _is_on_ground__with_energy:
			player_modi__energy.inc_current_energy(player_modi__energy.get_max_energy() * IN_ENERGY__ENERGY_CHARGE_PER_SEC__PERCENT * delta)
			
		else:
			player_modi__energy.dec_current_energy(OUT_ENERGY__ENERGY_DISCHARGE_PER_SEC__FLAT * delta)
			

#############

func _ready():
	_player_prev_global_position = global_position
	
	_make_node_rotate_with_cam(sprite_layer)
	
	#
	

func _make_node_rotate_with_cam(arg_node):
	_all_nodes_to_rotate_with_cam.append(arg_node)
	


#


func _request_rotate(arg_angle, arg_ground_identif, arg_is_energized):
	
	var data = RotationRequestData.new()
	data.angle = arg_angle
	data.ground_identif_on_rotate = arg_ground_identif
	
	
	_current_player_left_right_move_speed = 0
	_attempt_add_on_ground_count__with_any_indentif(arg_ground_identif, arg_is_energized)
	
	emit_signal("request_rotate", data)


#



func receive_cam_focus__as_child(arg_cam : Camera2D):
	add_child(arg_cam)
	

#

func add_object_to_not_collide_with(arg_obj):
	if !_objects_to_not_collide_with.has(arg_obj):
		_objects_to_not_collide_with.append(arg_obj)
	

func remove_objects_to_not_collide_with(arg_obj):
	if _objects_to_not_collide_with.has(arg_obj):
		_objects_to_not_collide_with.erase(arg_obj)
	

func has_object_to_not_collide_with(arg_obj):
	return _objects_to_not_collide_with.has(arg_obj)



func add_objects_to_collide_with_after_exit(arg_obj):
	if !_objects_to_collide_with_after_exit.has(arg_obj):
		_objects_to_collide_with_after_exit.append(arg_obj)

func remove_objects_to_collide_with_after_exit(arg_obj):
	if _objects_to_collide_with_after_exit.has(arg_obj):
		_objects_to_collide_with_after_exit.erase(arg_obj)


func add_objects_to_add_mask_layer_collision_after_exit(arg_obj):
	if !_objects_to_add_mask_layer_collision_after_exit.has(arg_obj):
		_objects_to_add_mask_layer_collision_after_exit.append(arg_obj)

func remove_objects_to_add_mask_layer_collision_after_exit(arg_obj):
	if _objects_to_add_mask_layer_collision_after_exit.has(arg_obj):
		_objects_to_add_mask_layer_collision_after_exit.erase(arg_obj)

###################

func apply_inside_induced_force(arg_vector : Vector2):
	_all_inside_induced_forces_list.append(arg_vector)
	

func clear_all_inside_induced_forces():
	_all_inside_induced_forces_list.clear()

func clear_all_outside_induced_forces():
	_all_outside_induced_forces_list.clear()


func apply_outside_induced_force(arg_vector : Vector2):
	if !last_calc_ignore_outside_induced_forces:
		_all_outside_induced_forces_list.append(arg_vector)
	



func get_player_linear_velocity():
	return _player_linear_velocity

func is_player__method_identifier__for_base_object():
	return true

#

func _on_body_entered__base_object(body_rid, body, body_shape_index, local_shape_index):
	var base_object : BaseObject = body
	
	#var object_momentum : Vector2 = base_object.calculate_momentum() / last_calculated_object_mass
	#var self_momentum = get_player_linear_velocity() * last_calculated_object_mass
	
	#apply_outside_induced_force(-object_momentum)
	call_deferred("_deferred_body_entered_object__and_apply_force", base_object)

func _deferred_body_entered_object__and_apply_force(base_object):
	var object_momentum : Vector2 = base_object.calculate_momentum() / last_calculated_object_mass
	
	apply_outside_induced_force(-object_momentum)
	


########################

func set_player_modi_energy__from_modi_manager(arg_modi : PlayerModi_Energy):
	player_modi__energy = arg_modi
	is_player_modi_energy_set = true
	
	SingletonsAndConsts.current_game_front_hud.energy_panel.set_player_modi__energy(arg_modi)

