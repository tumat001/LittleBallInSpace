extends KinematicBody2D

const ConditionalClauses = preload("res://MiscRelated/ClauseRelated/ConditionalClauses.gd")

const BaseTileSet = preload("res://ObjectsRelated/TilesRelated/BaseTileSet.gd")



signal last_calculated_object_mass_changed(arg_val)

signal unhandled_key_input_received(event)

signal request_rotate(arg_data)

#

enum BlockPlayerMoveLeftAndRightClauseIds {
	NOT_ON_GROUND = 0
}

var block_player_move_left_and_right_cond_clauses : ConditionalClauses
var last_calc_can_player_move_left_and_right : bool

var _is_on_ground : bool

var _on_ground_any_identif_list : Array


var _is_moving_left : bool
var _is_moving_right : bool

#

var _player_prev_global_position : Vector2
var _player_pos_change_from_last_frame : Vector2

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



var _pos_change_at_request_for_rotate_at_next_physics_step : Vector2
var _requesting_rotate_at_next_physics_step : bool
var _ground_identif_on_rotate


class RotationRequestData:
	var player_pos_change_from_last_frame : Vector2
	var player_pos_change_from_last_last_frame : Vector2
	var ground_identif_on_rotate
	
	const partition = (2*PI/8)  #every 45 deg is the rotation of cam
	
	
	func get_perfected_angle_from_player_pos_change():
		
		#player_pos_change_from_last_last_frame.rotated(CameraManager.current_cam_rotation)
		var llf_angle = player_pos_change_from_last_last_frame.angle()
		var llf_translated = llf_angle / partition
		var llf_perfected_translated = round(llf_translated)
		var llf_perfected_angle = llf_perfected_translated * partition
		
		
		#player_pos_change_from_last_frame.rotated(CameraManager.current_cam_rotation)
		var angle = player_pos_change_from_last_frame.angle()
		var translated = angle / partition
		var perfected_translated = round(translated)
		var perfected_angle = perfected_translated * partition
		
		#if llf_perfected_angle == 0:
		#	return 
		#elif llf_perfected_angle == PI:
		#	
		
		print("llf_perf angle: %s. perf angle: %s" % [llf_perfected_angle, perfected_angle])
		#if perfected_angle == PI or perfected_angle == 0:
		#	if llf_perfected_angle == 0:
		#		perfected_angle = -PI/2
		#	elif llf_perfected_angle == PI:
		#		perfected_angle = PI/2
		
		
		if perfected_angle == llf_perfected_angle:
			perfected_angle -= PI/2
		elif perfected_angle - llf_perfected_angle == PI:
			perfected_angle += PI/2
		
		return perfected_angle
	


#

const MAX_PLAYER_MOVE_LEFT_RIGHT_SPEED = 150
const ON_INPUT_PLAYER_MOVE_LEFT_RIGHT_PER_SEC = 150
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


var _base_object_mass : float = 100.0
var _flat_mass_id_to_amount_map : Dictionary
var last_calculated_object_mass : float

#

var _all_nodes_to_rotate_with_cam : Array

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
	
	if body is BaseTileSet:
		var coordinate: Vector2 = Physics2DServer.body_get_shape_metadata(body.get_rid(), body_shape_index)
		var tilemap : TileMap = body.tilemap
		
		var tile_local_pos_top_left = tilemap.map_to_world(coordinate)
		var tile_local_pos = tile_local_pos_top_left + (tilemap.cell_size / 2)
		var tile_global_pos = tilemap.to_global(tile_local_pos)
		
		
		var angle = global_position.angle_to_point(tile_global_pos)
		print("angle of self to tile: %s" % rad2deg(angle))
		if CameraManager.current_cam_rotation >= 0 or is_equal_approx(CameraManager.current_cam_rotation, -180.0):
			angle -= CameraManager.current_cam_rotation
		else:
			angle += CameraManager.current_cam_rotation
		print("curr cam rotation on bodyshape entered: %s" % rad2deg(CameraManager.current_cam_rotation))
		
		if !(angle < MIN_ANGLE_DIFF_TO_TRIGGER_ROTATION and angle > MIN_ANGLE_DIFF_TO_TRIGGER_ROTATION__OTHER_SIDE):
			print("requested rotate at angle: %s" % rad2deg(angle))
			_request_rotate__at_next_physics_step(_player_pos_change_from_last_frame, coordinate)
			_attempt_remove_on_ground_count__with_any_identif(coordinate)
			
		else:
			_attempt_add_on_ground_count__with_any_indentif(coordinate)
			clear_all_outside_induced_forces()
			clear_all_inside_induced_forces()
	
#	#note: does not work. Above works but needs polishing when rotation happens...
#	var body_shape_owner_id = body.shape_find_owner(body_shape_index)
#	var body_shape_owner = body.shape_owner_get_owner(body_shape_owner_id)
#	var body_shape_2d = body.shape_owner_get_shape(body_shape_owner_id, 0)
#	var body_global_transform : Transform2D = body_shape_owner.global_transform
#
#	var area_shape_owner_id = shape_find_owner(local_shape_index)
#	var area_shape_owner = shape_owner_get_owner(area_shape_owner_id)
#	var area_shape_2d = shape_owner_get_shape(area_shape_owner_id, 0)
#	var area_global_transform = area_shape_owner.global_transform
#
#
#	var coordinate: Vector2 = Physics2DServer.body_get_shape_metadata(body.get_rid(), body_shape_index)
#	var tilemap : TileMap = body.tilemap
#
#	var tile_local_pos_top_left = tilemap.map_to_world(coordinate)
#	var tile_local_pos = tile_local_pos_top_left + (tilemap.cell_size / 2)
#	var tile_global_pos = tilemap.to_global(tile_local_pos)
#	body_global_transform.origin += tile_global_pos
#
#	print(area_global_transform.origin)
#	print(body_global_transform.origin)
#
#	var collision_points = area_shape_2d.collide_and_get_contacts(area_global_transform,
#		body_shape_2d,
#		body_global_transform)
#
#	print(collision_points)
#	print(_player_pos_change_from_last_frame)
#	print("-----------")


func _on_FloorArea2D_body_shape_exited(body_rid, body, body_shape_index, local_shape_index):
	if body is BaseTileSet:
		var coordinate: Vector2 = Physics2DServer.body_get_shape_metadata(body.get_rid(), body_shape_index)
		
		_attempt_remove_on_ground_count__with_any_identif(coordinate)
		
		print("exited")




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


func _attempt_add_on_ground_count__with_any_indentif(arg_identif):
	if !_on_ground_any_identif_list.has(arg_identif):
		_on_ground_any_identif_list.append(arg_identif)
		
		_update_is_on_ground__and_update_others()

func _attempt_remove_on_ground_count__with_any_identif(arg_identif):
	if _on_ground_any_identif_list.has(arg_identif):
		_on_ground_any_identif_list.erase(arg_identif)
		
		_update_is_on_ground__and_update_others()



func _update_is_on_ground__and_update_others():
	print("on ground count: %s" %  _on_ground_any_identif_list.size())
	
	if _on_ground_any_identif_list.size() != 0:
		block_player_move_left_and_right_cond_clauses.remove_clause(BlockPlayerMoveLeftAndRightClauseIds.NOT_ON_GROUND)
		
		_is_on_ground = true
		
	else:
		block_player_move_left_and_right_cond_clauses.attempt_insert_clause(BlockPlayerMoveLeftAndRightClauseIds.NOT_ON_GROUND)
		
		_is_on_ground = false
		


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
	
	
	#
	
	var prev_pos_change_from_last_frame = _player_pos_change_from_last_frame
	_player_pos_change_from_last_frame = global_position - _player_prev_global_position
	_player_prev_global_position = global_position
	
	
	if _requesting_rotate_at_next_physics_step:
		if _player_pos_change_from_last_frame != _pos_change_at_request_for_rotate_at_next_physics_step:
			_request_rotate(_player_pos_change_from_last_frame, prev_pos_change_from_last_frame)

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


#############

func _ready():
	_player_prev_global_position = global_position
	
	_make_node_rotate_with_cam(sprite_layer)
	
	#
	
	CameraManager.connect("current_cam_rotation_changed", self, "_on_cam_rotated")
	
	#

func _make_node_rotate_with_cam(arg_node):
	_all_nodes_to_rotate_with_cam.append(arg_node)
	


#

func _request_rotate__at_next_physics_step(arg_curr_pos_change, arg_any_identif):
	_pos_change_at_request_for_rotate_at_next_physics_step = arg_curr_pos_change
	_requesting_rotate_at_next_physics_step = true
	_ground_identif_on_rotate = arg_any_identif

func _request_rotate(arg_pos_change, arg_prev_pos_change):
	_requesting_rotate_at_next_physics_step = false
	
	var data = RotationRequestData.new()
	data.player_pos_change_from_last_frame = arg_pos_change
	data.player_pos_change_from_last_last_frame = arg_prev_pos_change
	data.ground_identif_on_rotate = _ground_identif_on_rotate
	
	
	_current_player_left_right_move_speed = 0
	_attempt_add_on_ground_count__with_any_indentif(_ground_identif_on_rotate)
	
	emit_signal("request_rotate", data)


#

#func rad_rotate__from_cam_rotation(arg_rad_rotation):
#	#player_rad_rotation_modi += arg_rad_rotation
#	pass

func _on_cam_rotated(arg_new_angle):
	print("cam rotated")
	
	
	#floor_area_2d.monitorable = false
	#floor_area_2d.set_deferred("monitorable", true)
	#floor_area_2d_coll_shape.disabled = true
	#floor_area_2d_coll_shape.set_deferred("disabled", false)
	


#


func receive_cam_focus__as_child(arg_cam : Camera2D):
	add_child(arg_cam)
	

###################

func apply_inside_induced_force(arg_vector : Vector2):
	_all_inside_induced_forces_list.append(arg_vector)
	

func clear_all_inside_induced_forces():
	_all_inside_induced_forces_list.clear()

func clear_all_outside_induced_forces():
	_all_outside_induced_forces_list.clear()

