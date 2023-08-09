extends RigidBody2D

const ConditionalClauses = preload("res://MiscRelated/ClauseRelated/ConditionalClauses.gd")

const BaseTileSet = preload("res://ObjectsRelated/TilesRelated/BaseTileSet.gd")

const BaseObject = preload("res://ObjectsRelated/Objects/BaseObject.gd")

const PlayerModi_Energy = preload("res://PlayerRelated/PlayerModi/Imps/EnergyRelated/PlayerModi_Energy.gd")


#

signal last_calculated_object_mass_changed(arg_val)

signal unhandled_key_input_received(event)

signal request_rotate(arg_data)


signal current_health_changed(arg_val)
signal all_health_lost()
signal health_restored_from_zero()
signal health_reached_breakpoint(arg_breakpoint_val, arg_health_val_at_breakpoint)
signal health_fully_restored()


signal current_robot_health_changed(arg_val)
signal max_robot_health_changed(arg_val)

signal player_body_shape_exited(body_rid, body, body_shape_index, local_shape_index)
signal player_body_shape_entered(body_rid, body, body_shape_index, local_shape_index)

#

enum BlockPlayerMoveLeftAndRightClauseIds {
	NOT_ON_GROUND = 0,
	NO_ENERGY = 1,
}

var block_player_move_left_and_right_cond_clauses : ConditionalClauses
var last_calc_can_player_move_left_and_right : bool

var _is_on_ground : bool
var _is_on_ground__with_energy : bool
var _is_on_ground__with_instant_ground : bool

var _on_ground_any_identif_list : Array
#var _on_ground_any_identif_list__with_energy : Array
var _on_ground_any_identif_to_energy_mode_map : Dictionary

var _on_directly_below_ground_any_identif_list__rotating_area_2d : Array
var _is_directly_below_ground : bool

var _apply_ground_repelling_force : bool
var _cancel_next_apply_ground_repelling_force : bool

var _cam_angle_to_ground_attracting_velocity_map : Dictionary

#

var _is_moving_left : bool
var _is_moving_right : bool
var _is_move_breaking : bool

#

var _player_prev_global_position : Vector2
var _use_prev_glob_pos_for_rewind : bool
var _player_prev_global_position__for_rewind : Vector2

var _player_pos_change_from_last_frame : Vector2
var _player_linear_velocity : Vector2

#

enum BlockRotateClauseIds {
	IS_ROTATING = 0
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

const MAX_PLAYER_MOVE_LEFT_RIGHT_SPEED = 200.0
const ON_INPUT_PLAYER_MOVE_LEFT_RIGHT_PER_SEC = 200.0
const PLAYER_MOV_MULTIPLER_ON_OPPOSITE_CURR_SPEED : float = 1.5

var _current_player_left_right_move_speed : float
var _current_player_left_right_move_speed__from_last_integrate_forces : float
var _ignore_next_current_player_left_right_move_reset : bool
var _current_excess_player_left_right_move_speed_to_fight_counter_speed : Vector2

var _body_state_linear_velocity__without_modifications : Vector2

##

enum IgnoreOutsideInducedForcesClauseIds {
	IS_ON_GROUND = 1
}
var ignore_outside_induced_forces_cond_clauses : ConditionalClauses
var last_calc_ignore_outside_induced_forces : bool

var _all_outside_induced_forces_list : Array
var _all_inside_induced_forces_list : Array

###


var _base_object_mass : float = 140.0   # this can be changed in the very beginning, but dont afterwards
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

enum BlockAllInputsClauseIds {
	IN_CUTSCENE = 0
}
var block_all_inputs_cond_clauses : ConditionalClauses
var last_calc_block_all_inputs : bool

#

var _objects_to_not_collide_with : Array
var _objects_to_collide_with_after_exit : Array
var _objects_to_add_mask_layer_collision_after_exit : Array

#

var _is_stop_player_movement_at_next_frame : bool

#

# do not set these vars. use methods. but getting is fine
var player_modi__energy : PlayerModi_Energy
var is_player_modi_energy_set : bool

const IN_ENERGY_REGION__ENERGY_CHARGE_PER_SEC__PERCENT = 0.3
const IN_ENERGY__ENERGY_CHARGE_PER_SEC__PERCENT = 0.3
const OUT_ENERGY__ENERGY_DISCHARGE_PER_SEC__FLAT = 1.0
const OUT_ENERGY__ENERGY_DISCHARGE_PER_SEC__PERCENT__FROM_INSTANT_GROUND = 1.0

var _no_energy_consecutive_duration : float

###

const health_breakpoints = [
	33.3,
	66.6,
]

const above_highest_health_breakpoint_texture_file_path = "res://GameFrontHUDRelated/Subs/HealthPanel/Assets/HealthPanel_FillForeground_Type01.png"
const health_breakpoint_to_bar_texture_file_path_map : Dictionary = {
	33.3 : "res://GameFrontHUDRelated/Subs/HealthPanel/Assets/HealthPanel_FillForeground_Type03.png",
	66.6 : "res://GameFrontHUDRelated/Subs/HealthPanel/Assets/HealthPanel_FillForeground_Type02.png",
}

var _health_breakpoints_emitted : Array = []

var _max_health : float    # not meant to be changed, but if it is, then update HealthPanel's separator positioning
var _current_health : float
var _is_dead : bool

###

const MAX_HEALTH_DEFAULT = 100.0

var _max_robot_health : float = MAX_HEALTH_DEFAULT    # not meant to be changed,
var _current_robot_health : float = MAX_HEALTH_DEFAULT
var _is_robot_dead : bool

###

var _current_player_capture_area_region setget set_current_player_capture_area_region

##

var is_player : bool = true

##

const NO_ENERGY__INITIAL_HEALTH_LOSS_PER_SEC : float = 2.0
const NO_ENERGY__HEALTH_LOSS_PER_SEC_PER_SEC : float = 2.0
const NO_ENERGY__MAX_HEALTH_LOSS_PER_SEC : float = 10.0

###

const FACE_ANIMATION_NAME__NORMAL = "normal"
const FACE_ANIMATION_NAME__NORMAL_TO_OUCH = "normal_to_ouch"
const FACE_ANIMATION_NAME__OUCH = "ouch"
const FACE_ANIMATION_NAME__OUCH_TO_NORMAL = "ouch_to_normal"

#

onready var sprite_layer = $SpriteLayer

onready var collision_shape = $CollisionShape2D
onready var floor_area_2d = $FloorArea2D
onready var floor_area_2d_coll_shape = $FloorArea2D/CollisionShape2D

onready var rotating_for_floor_area_2d = $RotatingForFloorArea2D
onready var rotating_for_floor_area_2d_coll_shape = $RotatingForFloorArea2D/CollisionShape2D

onready var face_screen = $SpriteLayer/FaceScreen
onready var anim_on_screen = $SpriteLayer/AnimOnScreen
onready var main_body_sprite = $SpriteLayer/MainBodySprite

onready var pca_progress_drawer = $PCAProgressDrawer

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
	
	block_all_inputs_cond_clauses = ConditionalClauses.new()
	block_all_inputs_cond_clauses.connect("clause_inserted", self, "_on_block_all_inputs_cond_clauses_updated", [], CONNECT_PERSIST)
	block_all_inputs_cond_clauses.connect("clause_removed", self, "_on_block_all_inputs_cond_clauses_updated", [], CONNECT_PERSIST)
	_update_last_calc_block_all_inputs()
	
	#
	
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

func _on_block_all_inputs_cond_clauses_updated():
	_update_last_calc_block_all_inputs()

func _update_last_calc_block_all_inputs():
	last_calc_block_all_inputs = !block_all_inputs_cond_clauses.is_passed

#

func _update_last_calculated_object_mass():
	var total = _base_object_mass
	for mass in _flat_mass_id_to_amount_map:
		total += mass
	
	last_calculated_object_mass = total
	mass = last_calculated_object_mass
	emit_signal("last_calculated_object_mass_changed", last_calculated_object_mass)


#######

func _on_FloorArea2D_body_shape_entered(body_rid, body, body_shape_index, local_shape_index):
	if !has_object_to_not_collide_with(body):
		
		
		if body is BaseTileSet:
			_on_body_entered__tilemap(body_rid, body, body_shape_index, local_shape_index)
			
		elif body is BaseObject:
			_on_body_entered__base_object(body_rid, body, body_shape_index, local_shape_index)
			
	
	
	emit_signal("player_body_shape_entered", body_rid, body, body_shape_index, local_shape_index)



func _on_body_entered__tilemap(body_rid, body, body_shape_index, local_shape_index):
	
	if body.break_on_player_contact:
		var coordinate: Vector2 = Physics2DServer.body_get_shape_metadata(body.get_rid(), body_shape_index)
		
		body.break_tile_coord__using_player(coordinate, self)
		
		
	else:
		var tileset_energy_mode = body.energy_mode
		
		
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
			if body.can_induce_rotation_change__due_to_cell_v_changes():
				_attempt_remove_on_ground_count__with_any_identif(coordinate)
				_request_rotate(perpend_angle_with_lowest_distance, coordinate, tileset_energy_mode)
				if _ignore_next_current_player_left_right_move_reset:
					_ignore_next_current_player_left_right_move_reset = false
				else:
					_current_player_left_right_move_speed = 0
					_current_player_left_right_move_speed__from_last_integrate_forces = 0
					_current_excess_player_left_right_move_speed_to_fight_counter_speed = Vector2(0, 0)
				
				clear_all_inside_induced_forces()
				clear_all_outside_induced_forces()
				_cancel_next_apply_ground_repelling_force = false
		else:
			_attempt_add_on_ground_count__with_any_indentif(coordinate, tileset_energy_mode)
			clear_all_outside_induced_forces()
			clear_all_inside_induced_forces()
			_cancel_next_apply_ground_repelling_force = false


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
		if !body.break_on_player_contact and !body.changing_colls__from_fill_and_unfilled:
			var coordinate: Vector2 = Physics2DServer.body_get_shape_metadata(body.get_rid(), body_shape_index)
			
			_attempt_remove_on_ground_count__with_any_identif(coordinate)
		
		if !body.changing_colls__from_fill_and_unfilled:
			body.changing_colls__from_fill_and_unfilled = false
	
	if body is BaseObject:
		if _objects_to_collide_with_after_exit.has(body):
			remove_objects_to_not_collide_with(body)
			remove_objects_to_collide_with_after_exit(body)
		
		if _objects_to_add_mask_layer_collision_after_exit.has(body):
			#body.set_collision_mask_bit(0, true)
			remove_objects_to_add_mask_layer_collision_after_exit(body)
	
	emit_signal("player_body_shape_exited", body_rid, body, body_shape_index, local_shape_index)

func remove_on_ground_count_with_identif__from_breakable_tile__before_breaking(arg_coordinate):
	_attempt_remove_on_ground_count__with_any_identif(arg_coordinate)
	

func remove_on_ground_count_with_identif__from_any_purpose__changing_tiles__before_change(arg_coordinate):
	_attempt_remove_on_ground_count__with_any_identif(arg_coordinate)
	

#func _on_FloorArea2D_area_shape_entered(area_rid, area, area_shape_index, local_shape_index):
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


func _attempt_add_on_ground_count__with_any_indentif(arg_identif, arg_tileset_energy_mode):
	if !_on_ground_any_identif_list.has(arg_identif):
		_on_ground_any_identif_list.append(arg_identif)
		
		#if arg_tileset_energy_mode == BaseTileSet.EnergyMode.ENERGIZED:
		if !_on_ground_any_identif_to_energy_mode_map.has(arg_identif):
			_on_ground_any_identif_to_energy_mode_map[arg_identif] = arg_tileset_energy_mode
		
		
		_update_is_on_ground__and_update_others()

func _attempt_remove_on_ground_count__with_any_identif(arg_identif):
	if _on_ground_any_identif_list.has(arg_identif):
		_on_ground_any_identif_list.erase(arg_identif)
		
		#if _on_ground_any_identif_list__with_energy.has(arg_identif):
		#	_on_ground_any_identif_list__with_energy.erase(arg_identif)
		
		if _on_ground_any_identif_to_energy_mode_map.has(arg_identif):
			_on_ground_any_identif_to_energy_mode_map.erase(arg_identif)
		
		_update_is_on_ground__and_update_others()



func _update_is_on_ground__and_update_others():
	if _on_ground_any_identif_list.size() != 0:
		block_player_move_left_and_right_cond_clauses.remove_clause(BlockPlayerMoveLeftAndRightClauseIds.NOT_ON_GROUND)
		
		_is_on_ground = true
		
	else:
		block_player_move_left_and_right_cond_clauses.attempt_insert_clause(BlockPlayerMoveLeftAndRightClauseIds.NOT_ON_GROUND)
		
		_is_on_ground = false
		_current_excess_player_left_right_move_speed_to_fight_counter_speed = Vector2(0, 0)
	
	
	######
	var is_on_ground_with_energy : bool = false
	var is_on_ground_with_instant_ground : bool = false
	for identif in _on_ground_any_identif_to_energy_mode_map.keys():
		var energy_mode = _on_ground_any_identif_to_energy_mode_map[identif]
		
		if energy_mode == BaseTileSet.EnergyMode.ENERGIZED:
			is_on_ground_with_energy = true
		elif energy_mode == BaseTileSet.EnergyMode.INSTANT_GROUND:
			is_on_ground_with_instant_ground = true
	
	_is_on_ground__with_energy = is_on_ground_with_energy
	_is_on_ground__with_instant_ground = is_on_ground_with_instant_ground
	

##

func _unhandled_key_input(event):
	# NOTE:
	# IF making a persisting action (ex: moving left while holding),
	# update method: stop_all_persisting_actions to include reversal of those actions
	
	
	if !last_calc_block_all_inputs:
		#if !SingletonsAndConsts.current_rewind_manager.is_rewinding:
		var is_consumed = false
		
		if event.is_action_released("ui_left"):
			_is_moving_left = false
			
		elif event.is_action_released("ui_right"):
			_is_moving_right = false
			
		elif event.is_action_released("ui_down"):
			pass
			#_is_move_breaking = false
			
		else:
			if event.is_action("ui_left"):
				_is_moving_left = true
			elif event.is_action("ui_right"):
				_is_moving_right = true
			elif event.is_action("ui_down"):
				pass
				#_is_move_breaking = true
			
		
		if !SingletonsAndConsts.current_rewind_manager.is_rewinding:
			if event.is_action_pressed("game_zoom_out"):
				CameraManager.start_camera_zoom_change__with_default_player_initialized_vals()
				is_consumed = true
				
			elif event.is_action_released("game_zoom_out"):
				CameraManager.reset_camera_zoom_level()
				is_consumed = true
				
			
			
			if !is_consumed:
				emit_signal("unhandled_key_input_received", event)


func stop_all_persisting_actions():
	if _is_moving_left:
		_is_moving_left = false
	
	if _is_moving_right:
		_is_moving_right = false
	
	if _is_move_breaking:
		_is_move_breaking = false


func stop_player_movement():
	_is_stop_player_movement_at_next_frame = true

##########################################

# note: after phy, it is followed by integ, never by another phy.
func _physics_process(delta):
	if !SingletonsAndConsts.current_rewind_manager.is_rewinding:
		
		if last_calc_can_player_move_left_and_right:
			if _is_moving_left:
				var speed_modi = ON_INPUT_PLAYER_MOVE_LEFT_RIGHT_PER_SEC * delta
				if _current_player_left_right_move_speed > 0:
					_current_excess_player_left_right_move_speed_to_fight_counter_speed = Vector2(0, 0)
					speed_modi *= PLAYER_MOV_MULTIPLER_ON_OPPOSITE_CURR_SPEED
				_current_player_left_right_move_speed -= speed_modi
				
				if _current_player_left_right_move_speed < -MAX_PLAYER_MOVE_LEFT_RIGHT_SPEED:
					var excess = -MAX_PLAYER_MOVE_LEFT_RIGHT_SPEED - _current_player_left_right_move_speed
					_current_player_left_right_move_speed = -MAX_PLAYER_MOVE_LEFT_RIGHT_SPEED
					
					var mov_of_left_right = _get_cleaned_vector(Vector2(_current_player_left_right_move_speed, 0).rotated(CameraManager.current_cam_rotation))
					
					var scalar_quo = _get_scalar_quotient_of_vector_using_vec_divisior__max_one(linear_velocity, mov_of_left_right)
					var is_curr_mov_left_right_fit_in_linear_vel = scalar_quo >= 1
					
					#print("scalar quo: %s. mov_left_right: %s" % [scalar_quo, mov_of_left_right])
					if !is_curr_mov_left_right_fit_in_linear_vel:
						var diff = linear_velocity - mov_of_left_right
						
						var mov_of_excess = _get_cleaned_vector(Vector2(excess, 0).rotated(CameraManager.current_cam_rotation))
						var quo_of_excess = _get_scalar_quotient_of_vector_using_vec_divisior__max_one(diff, mov_of_excess)
						var excess_scale
						if quo_of_excess > 0:
							excess_scale = min(1, quo_of_excess)
						else:
							excess_scale = max(-1, quo_of_excess)
						
						#print("diff: %s, mov_of_excess: %s " % [diff, mov_of_excess])
						#print("excess scale: %s, quo of excess: %s" % [excess_scale, quo_of_excess])
						
						_current_excess_player_left_right_move_speed_to_fight_counter_speed = -mov_of_excess * excess_scale
						
					else:
						_current_excess_player_left_right_move_speed_to_fight_counter_speed = Vector2(0, 0)
					
				
			elif _is_moving_right:
				var speed_modi = ON_INPUT_PLAYER_MOVE_LEFT_RIGHT_PER_SEC * delta
				if _current_player_left_right_move_speed < 0:
					_current_excess_player_left_right_move_speed_to_fight_counter_speed = Vector2(0, 0)
					speed_modi *= PLAYER_MOV_MULTIPLER_ON_OPPOSITE_CURR_SPEED
				_current_player_left_right_move_speed += speed_modi
				
				if _current_player_left_right_move_speed > MAX_PLAYER_MOVE_LEFT_RIGHT_SPEED:
					var excess = MAX_PLAYER_MOVE_LEFT_RIGHT_SPEED - _current_player_left_right_move_speed
					_current_player_left_right_move_speed = MAX_PLAYER_MOVE_LEFT_RIGHT_SPEED
					
					var mov_of_left_right = _get_cleaned_vector(Vector2(_current_player_left_right_move_speed, 0).rotated(CameraManager.current_cam_rotation))
					
					var scalar_quo = _get_scalar_quotient_of_vector_using_vec_divisior__max_one(linear_velocity, mov_of_left_right)
					var is_curr_mov_left_right_fit_in_linear_vel = scalar_quo >= 1
					if !is_curr_mov_left_right_fit_in_linear_vel:
						var diff = linear_velocity - mov_of_left_right
						
						var mov_of_excess = _get_cleaned_vector(Vector2(excess, 0).rotated(CameraManager.current_cam_rotation))
						var quo_of_excess = _get_scalar_quotient_of_vector_using_vec_divisior__max_one(diff, mov_of_excess)
						var excess_scale
						if quo_of_excess > 0:
							excess_scale = min(1, quo_of_excess)
						else:
							excess_scale = max(-1, quo_of_excess)
						
						_current_excess_player_left_right_move_speed_to_fight_counter_speed = -mov_of_excess * excess_scale
						
					else:
						_current_excess_player_left_right_move_speed_to_fight_counter_speed = Vector2(0, 0)
					
				
				
			elif _is_move_breaking:
				
				var speed_modi = ON_INPUT_PLAYER_MOVE_LEFT_RIGHT_PER_SEC * delta
				if _current_player_left_right_move_speed < 0:
					_current_excess_player_left_right_move_speed_to_fight_counter_speed = Vector2(0, 0)
					speed_modi *= PLAYER_MOV_MULTIPLER_ON_OPPOSITE_CURR_SPEED
					_current_player_left_right_move_speed += speed_modi
					
					if _current_player_left_right_move_speed > MAX_PLAYER_MOVE_LEFT_RIGHT_SPEED:
						_current_player_left_right_move_speed = MAX_PLAYER_MOVE_LEFT_RIGHT_SPEED
					elif _current_player_left_right_move_speed > 0:
						_current_player_left_right_move_speed = 0
					
				elif _current_player_left_right_move_speed > 0:
					_current_excess_player_left_right_move_speed_to_fight_counter_speed = Vector2(0, 0)
					speed_modi *= PLAYER_MOV_MULTIPLER_ON_OPPOSITE_CURR_SPEED
					_current_player_left_right_move_speed -= speed_modi
					
					if _current_player_left_right_move_speed < -MAX_PLAYER_MOVE_LEFT_RIGHT_SPEED:
						_current_player_left_right_move_speed = -MAX_PLAYER_MOVE_LEFT_RIGHT_SPEED
					elif _current_player_left_right_move_speed < 0:
						_current_player_left_right_move_speed = 0
					
				
			
			#var final_mov = Vector2(_current_player_left_right_move_speed, 0)
			#apply_central_impulse(final_mov)
			
		
		# check linear velocity.x or y, depending on rotation
		# if linear velocity.x or y is less than _current_player_left_right_move_speed even if _current_player_left_right_move_speed is max, then store excess speed generated this frame in a var
		# then use that var to add onto the linear velocity in _integrate_forces
		
		
		_player_prev_global_position__for_rewind = global_position - _player_pos_change_from_last_frame
		
		if _use_prev_glob_pos_for_rewind:
			_player_prev_global_position = _player_prev_global_position__for_rewind
			
		
		var prev_pos_change_from_last_frame = _player_pos_change_from_last_frame
		_player_pos_change_from_last_frame = global_position - _player_prev_global_position
		_player_linear_velocity = _player_pos_change_from_last_frame / delta
		_player_prev_global_position = global_position
		
		
		_do_effects_based_on_pos_changes(prev_pos_change_from_last_frame, _player_pos_change_from_last_frame, delta)
		


#func _get_scalar_diff_of_vector_using_vec_substraction__max_one(arg_vec_minuend : Vector2, arg_vec_subtrahend : Vector2):
#	var x_diff = float(arg_vec_minuend.x) - arg_vec_subtrahend.x
#	var y_diff = float(arg_vec_minuend.y) - arg_vec_subtrahend.y
#
#	return 

func _get_cleaned_vector(vec2 : Vector2):
	return Vector2(round(vec2.x), round(vec2.y))

func _get_scalar_quotient_of_vector_using_vec_divisior__max_one(arg_vec_dividend : Vector2, arg_vec_divisor : Vector2):
	var x_quotient = 99999
	if arg_vec_divisor.x != 0:
		x_quotient = float(arg_vec_dividend.x) / arg_vec_divisor.x
	var y_quotient = 99999
	if arg_vec_divisor.y != 0:
		y_quotient = float(arg_vec_dividend.y) / arg_vec_divisor.y
		
	
	#if x_quotient < 0:
	#	x_quotient = 0
	#if y_quotient < 0:
	#	y_quotient = 0
	
	var neg_multipler = 1
	if x_quotient < 0 or y_quotient < 0:
		neg_multipler = -1
	
	var min_quotient = min(abs(x_quotient), abs(y_quotient)) * neg_multipler
	
	if neg_multipler == 1:
		return max(0, min_quotient)
	else:
		return min(0, min_quotient)

func _integrate_forces(state):
	#print("lin_vel: %s, extra_counter force: %s" % [linear_velocity, _current_excess_player_left_right_move_speed_to_fight_counter_speed])
	
	if !SingletonsAndConsts.current_rewind_manager.is_rewinding:
		
		if _use_integ_forces_new_vals:
			state.angular_velocity = _rewinded__angular_velocity
			state.linear_velocity = _rewinded__linear_velocity
			state.sleeping = _rewinded__sleeping
			state.transform = _rewinded__transform
			
			_use_integ_forces_new_vals = false
			
		
		
		########################
		
		#
		
		var mov_speed = _current_player_left_right_move_speed - _current_player_left_right_move_speed__from_last_integrate_forces
		_current_player_left_right_move_speed__from_last_integrate_forces = _current_player_left_right_move_speed
		
		var final_mov = Vector2(mov_speed, 0)
		final_mov = final_mov.rotated(CameraManager.current_cam_rotation)
		
		final_mov += _current_excess_player_left_right_move_speed_to_fight_counter_speed
		
		#
		
		for vec2 in _all_inside_induced_forces_list:
			final_mov += vec2
		clear_all_inside_induced_forces()
		for vec2 in _all_outside_induced_forces_list:
			final_mov += vec2
		clear_all_outside_induced_forces()
		
		
		#
		
		var make_x_zero : bool = false
		var make_y_zero : bool = false
		
		if _is_directly_below_ground:
			final_mov += _cam_angle_to_ground_attracting_velocity_map[CameraManager.current_cam_rotation] 
		
		if _apply_ground_repelling_force:
			#final_mov -= _cam_angle_to_ground_attracting_velocity_map[CameraManager.current_cam_rotation]
			
			#var pos_modi = _cam_angle_to_ground_attracting_velocity_map[CameraManager.current_cam_rotation] / 2
			#state.transform.origin -= pos_modi
			
			#_apply_ground_repelling_force = false
			
			var vel = _cam_angle_to_ground_attracting_velocity_map[CameraManager.current_cam_rotation]
			if vel.x != 0:
				make_x_zero = true
			elif vel.y != 0:
				make_y_zero = true
			
			_apply_ground_repelling_force = false
		
		#
		
		var undeltad_mov_speed = _current_player_left_right_move_speed
		var undeltad_mov = Vector2(undeltad_mov_speed, 0)
		undeltad_mov = undeltad_mov.rotated(CameraManager.current_cam_rotation)
		
		_body_state_linear_velocity__without_modifications = state.linear_velocity - undeltad_mov
		
		#
		
		if _is_stop_player_movement_at_next_frame:
			_is_stop_player_movement_at_next_frame = false
			make_x_zero = true
			make_y_zero = true
		
		state.linear_velocity += final_mov
		if make_x_zero:
			state.linear_velocity.x = 0
		elif make_y_zero:
			state.linear_velocity.y = 0
		
		#
		
		#var diff_in_linear_velocity = state.linear_velocity - linear_velocity_of_old
		#_play_effects_based_on_change_in_linear_velocity(diff_in_linear_velocity)
		
		#
		
		if _player_pos_change_from_last_frame == Vector2.ZERO:
			if _ignore_next_current_player_left_right_move_reset:
				pass
			else:
				_current_player_left_right_move_speed = 0
				_current_player_left_right_move_speed__from_last_integrate_forces = 0
				_current_excess_player_left_right_move_speed_to_fight_counter_speed = Vector2(0, 0)
			
			clear_all_inside_induced_forces()
			clear_all_outside_induced_forces()
		
		
	else:
		pass


func _process(delta):
	if !SingletonsAndConsts.current_rewind_manager.is_rewinding:
		if is_player_modi_energy_set:
			if _is_on_ground__with_instant_ground:
				player_modi__energy.dec_current_energy(player_modi__energy.get_max_energy() * OUT_ENERGY__ENERGY_DISCHARGE_PER_SEC__PERCENT__FROM_INSTANT_GROUND * delta)
				player_modi__energy.set_forecasted_energy_consume(player_modi__energy.ForecastConsumeId.INSTANT_GROUND, player_modi__energy.get_max_energy())
				
			elif _is_on_ground__with_energy:
				player_modi__energy.inc_current_energy(player_modi__energy.get_max_energy() * IN_ENERGY__ENERGY_CHARGE_PER_SEC__PERCENT * delta)
				player_modi__energy.remove_forecasted_energy_consume(player_modi__energy.ForecastConsumeId.INSTANT_GROUND)
				
			else:
				player_modi__energy.dec_current_energy(OUT_ENERGY__ENERGY_DISCHARGE_PER_SEC__FLAT * delta)
				player_modi__energy.remove_forecasted_energy_consume(player_modi__energy.ForecastConsumeId.INSTANT_GROUND)
			
			
			if player_modi__energy.is_no_energy():
				_no_energy_consecutive_duration += delta
				
				var loss = NO_ENERGY__INITIAL_HEALTH_LOSS_PER_SEC + (NO_ENERGY__HEALTH_LOSS_PER_SEC_PER_SEC * _no_energy_consecutive_duration)
				if loss > NO_ENERGY__MAX_HEALTH_LOSS_PER_SEC:
					loss = NO_ENERGY__MAX_HEALTH_LOSS_PER_SEC
				loss *= delta
				
				set_current_health(_current_health - loss)
				
			else:
				_no_energy_consecutive_duration = 0



#############

func _ready():
	_calculate_and_store_ground_attracting_velocity_at_cam_angle(CameraManager.current_cam_rotation)
	
	#
	
	_player_prev_global_position = global_position
	
	#_make_node_rotate_with_cam(sprite_layer)
	_make_node_rotate_with_cam(face_screen)
	_make_node_rotate_with_cam(anim_on_screen)
	_make_node_rotate_with_cam(pca_progress_drawer)
	
	CameraManager.connect("cam_visual_rotation_changed", self, "_rotate_nodes_to_rotate_with_cam", [], CONNECT_PERSIST)
	
	mode = RigidBody2D.MODE_CHARACTER
	
	########
	
	SingletonsAndConsts.current_rewind_manager.connect("done_ending_rewind", self, "_on_rewind_manager__ended_rewind__iterated_over_all", [], CONNECT_PERSIST)
	SingletonsAndConsts.current_rewind_manager.add_to_rewindables(self)
	CameraManager.connect("current_cam_rotation_changed", self, "_on_cam_manager_rotation_changed", [], CONNECT_PERSIST)
	_ready__include_relevant_objs_for_rewind()
	

func _make_node_rotate_with_cam(arg_node):
	_all_nodes_to_rotate_with_cam.append(arg_node)
	

#

func initialize_health_panel_relateds():
	var param = SingletonsAndConsts.current_game_front_hud.health_panel.DisplayParams.new()
	param.player = self
	param.max_health = _max_health
	param.current_health = _current_health
	param.is_dead = _is_dead
	param.health_breakpoints = health_breakpoints
	
	SingletonsAndConsts.current_game_front_hud.health_panel.configure_update_to_param(param)

#


func _request_rotate(arg_angle, arg_ground_identif, arg_tileset_energy_mode):
	var data = RotationRequestData.new()
	data.angle = arg_angle
	data.ground_identif_on_rotate = arg_ground_identif
	
	if !_cam_angle_to_ground_attracting_velocity_map.has(arg_angle):
		_calculate_and_store_ground_attracting_velocity_at_cam_angle(arg_angle)
	
	
	_attempt_add_on_ground_count__with_any_indentif(arg_ground_identif, arg_tileset_energy_mode)
	
	
	emit_signal("request_rotate", data)

func _on_cam_manager_rotation_changed(arg_angle):
	if !SingletonsAndConsts.current_rewind_manager.is_rewinding:
		_current_player_left_right_move_speed = 0
		_current_player_left_right_move_speed__from_last_integrate_forces = 0
		_current_excess_player_left_right_move_speed_to_fight_counter_speed = Vector2(0, 0)
	
	rotating_for_floor_area_2d.rotation = arg_angle



func _calculate_and_store_ground_attracting_velocity_at_cam_angle(arg_angle):
	var velocity = Vector2(0, 0.8).rotated(arg_angle)
	var cleaned_velocity = Vector2(stepify(velocity.x, 0.01), stepify(velocity.y, 0.01)) 
	_cam_angle_to_ground_attracting_velocity_map[arg_angle] = cleaned_velocity

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
		
		arg_obj.block_can_collide_with_player_cond_clauses.attempt_insert_clause(arg_obj.BlockCollisionWithPlayerClauseIds.BLOCK_UNTIL_EXIT_PLAYER)

func remove_objects_to_add_mask_layer_collision_after_exit(arg_obj):
	if _objects_to_add_mask_layer_collision_after_exit.has(arg_obj):
		_objects_to_add_mask_layer_collision_after_exit.erase(arg_obj)
		
		arg_obj.block_can_collide_with_player_cond_clauses.remove_clause(arg_obj.BlockCollisionWithPlayerClauseIds.BLOCK_UNTIL_EXIT_PLAYER)
		

###################

func is_on_ground():
	return _is_on_ground



func apply_inside_induced_force(arg_vector : Vector2):
	_all_inside_induced_forces_list.append(arg_vector)
	
	_cancel_next_apply_ground_repelling_force = true

func clear_all_inside_induced_forces():
	_all_inside_induced_forces_list.clear()

func clear_all_outside_induced_forces():
	_all_outside_induced_forces_list.clear()


func apply_outside_induced_force(arg_vector : Vector2):
	if !last_calc_ignore_outside_induced_forces:
		_all_outside_induced_forces_list.append(arg_vector)
		
		_cancel_next_apply_ground_repelling_force = true



func get_player_linear_velocity():
	return _player_linear_velocity

func is_player__method_identifier__for_base_object():
	return true

#

func _on_body_entered__base_object(body_rid, body, body_shape_index, local_shape_index):
	var base_object : BaseObject = body
	
#	#var object_momentum : Vector2 = base_object.calculate_momentum() / last_calculated_object_mass
#	#var self_momentum = get_player_linear_velocity() * last_calculated_object_mass
#
#	#apply_outside_induced_force(-object_momentum)
#	call_deferred("_deferred_body_entered_object__and_apply_force", base_object)
#
#func _deferred_body_entered_object__and_apply_force(base_object):
#	var object_momentum : Vector2 = base_object.calculate_momentum() / last_calculated_object_mass
#
#	apply_outside_induced_force(-object_momentum)
#


########################

func set_player_modi_energy__from_modi_manager(arg_modi : PlayerModi_Energy):
	player_modi__energy = arg_modi
	is_player_modi_energy_set = true
	
	SingletonsAndConsts.current_game_front_hud.energy_panel.set_player_modi__energy(arg_modi)
	
	player_modi__energy.connect("discarged_to_zero_energy", self, "_update_self_based_on_has_energy")
	player_modi__energy.connect("recharged_from_no_energy", self, "_update_self_based_on_has_energy")
	_update_self_based_on_has_energy()

func _update_self_based_on_has_energy():
	var has_no_energy = player_modi__energy.is_no_energy()
	
	if has_no_energy:
		_update_self_based_on_has_energy__no_energy()
	else:
		_update_self_based_on_has_energy__has_energy()


func _update_self_based_on_has_energy__no_energy():
	block_player_move_left_and_right_cond_clauses.attempt_insert_clause(BlockPlayerMoveLeftAndRightClauseIds.NO_ENERGY)
	
	face_screen.texture = preload("res://PlayerRelated/PlayerModel/Assets/PlayerModel_FaceScreen_NoEnergy.png")
	main_body_sprite.texture = preload("res://PlayerRelated/PlayerModel/Assets/PlayerModel_MainBody_NoEnergy.png")
	anim_on_screen.visible = false

func _update_self_based_on_has_energy__has_energy():
	block_player_move_left_and_right_cond_clauses.remove_clause(BlockPlayerMoveLeftAndRightClauseIds.NO_ENERGY)
	
	face_screen.texture = preload("res://PlayerRelated/PlayerModel/Assets/PlayerModel_FaceScreen.png")
	main_body_sprite.texture = preload("res://PlayerRelated/PlayerModel/Assets/PlayerModel_MainBody.png")
	anim_on_screen.visible = true



##

func _on_RotatingForFloorArea2D_body_entered(body):
	if !_on_directly_below_ground_any_identif_list__rotating_area_2d.has(body):
		_on_directly_below_ground_any_identif_list__rotating_area_2d.append(body)
		_is_directly_below_ground = true


func _on_RotatingForFloorArea2D_body_exited(body):
	if _on_directly_below_ground_any_identif_list__rotating_area_2d.has(body):
		_on_directly_below_ground_any_identif_list__rotating_area_2d.erase(body)
		
		_is_directly_below_ground = _on_directly_below_ground_any_identif_list__rotating_area_2d.size() != 0
		if !_is_directly_below_ground:
			if !_cancel_next_apply_ground_repelling_force:
				_apply_ground_repelling_force = true
			else:
				_cancel_next_apply_ground_repelling_force = false
			
			_current_excess_player_left_right_move_speed_to_fight_counter_speed = Vector2(0, 0)

#######################

func _rotate_nodes_to_rotate_with_cam(arg_angle):
	for node in _all_nodes_to_rotate_with_cam:
		node.rotation = arg_angle
		
	

########


## does not work well
#func _play_effects_based_on_change_in_linear_velocity(arg_diff : Vector2):
#	var diff_magnitude = arg_diff.length()
#
#	print(diff_magnitude)
#
#	if diff_magnitude >= 2: #200:
#		var stress = diff_magnitude / 10 #2000
#
#		CameraManager.camera.add_stress(stress)
#

func _do_effects_based_on_pos_changes(arg_prev_pos_change_from_last_frame : Vector2, arg_player_pos_change_from_last_frame : Vector2, delta):
	var prev_pos_mag = arg_prev_pos_change_from_last_frame.length()
	var curr_pos_mag = arg_player_pos_change_from_last_frame.length()
	 
	if prev_pos_mag > curr_pos_mag:  # from fast to slow
		var diff = (prev_pos_mag - curr_pos_mag) / delta
		
		if diff > 220:
			var stress = diff / 220
			CameraManager.camera.add_stress(stress)
		
		if diff > 450:
			var tweener = create_tween()
			tweener.tween_callback(self, "_play_normal_to_ouch", [0.5])
			tweener.tween_callback(self, "_play_ouch_to_normal", [0.9]).set_delay(0.9)
			
		elif diff > 300:
			var tweener = create_tween()
			tweener.tween_callback(self, "_play_normal_to_ouch", [0.5])
			tweener.tween_callback(self, "_play_ouch_to_normal", [0.65]).set_delay(0.65)
			
		elif diff > 220:
			var tweener = create_tween()
			tweener.tween_callback(self, "_play_normal_to_ouch", [0.5])
			tweener.tween_callback(self, "_play_ouch_to_normal", [0.5]).set_delay(0.5)
			
		
		#print("diff: %s, prev_mag: %s, curr_mag: %s. |||||||| for_rewind: %s, prev_pos: %s, prev_change: %s, glob_pos: %s, pos_change: %s, use: %s" % [diff, prev_pos_mag, curr_pos_mag, _player_prev_global_position__for_rewind, _player_prev_global_position, arg_player_pos_change_from_last_frame, global_position, _player_pos_change_from_last_frame, _use_prev_glob_pos_for_rewind])
		_use_prev_glob_pos_for_rewind = false

func _play_normal_to_ouch(arg_duration : float):
	var frame_count = anim_on_screen.frames.get_frame_count(FACE_ANIMATION_NAME__NORMAL_TO_OUCH)
	var fps = frame_count / arg_duration
	
	anim_on_screen.frames.set_animation_speed(FACE_ANIMATION_NAME__NORMAL_TO_OUCH, fps)
	anim_on_screen.play(FACE_ANIMATION_NAME__NORMAL_TO_OUCH)

func _play_ouch_to_normal(arg_duration : float):
	var frame_count = anim_on_screen.frames.get_frame_count(FACE_ANIMATION_NAME__OUCH_TO_NORMAL)
	var fps = frame_count / arg_duration
	
	anim_on_screen.frames.set_animation_speed(FACE_ANIMATION_NAME__OUCH_TO_NORMAL, fps)
	anim_on_screen.play(FACE_ANIMATION_NAME__OUCH_TO_NORMAL)

#

func set_current_health(arg_val, emit_health_breakpoint_signals : bool = true):
	if SingletonsAndConsts.current_game_result_manager.is_game_result_decided:
		return
	
	
	var old_val = _current_health
	_current_health = arg_val
	
	if _current_health < 0:
		_current_health = 0
	if _current_health >= _max_health:
		_current_health = _max_health
		
		emit_signal("health_fully_restored")
	
	
	if is_equal_approx(_current_health, 0):
		if !_is_dead:
			_is_dead = true
			emit_signal("all_health_lost")
		
	else:
		if _is_dead:
			_is_dead = false
			emit_signal("health_restored_from_zero")
		
		if emit_health_breakpoint_signals:
			var percent = _current_health * 100 / _max_health
			for hp_breakpoint in health_breakpoints:
				if old_val > _current_health:
					if percent <= hp_breakpoint:
						if !_health_breakpoints_emitted.has(hp_breakpoint):
							_health_breakpoints_emitted.append(hp_breakpoint)
							emit_signal("health_reached_breakpoint", hp_breakpoint, hp_breakpoint * _max_health / 100)
							break
					
				elif old_val < _current_health:
					if percent > hp_breakpoint:
						if _health_breakpoints_emitted.has(hp_breakpoint):
							_health_breakpoints_emitted.erase(hp_breakpoint)
							emit_signal("health_reached_breakpoint", hp_breakpoint, hp_breakpoint * _max_health / 100)
							break
	
	if _current_health != old_val or _current_health == 0:
		emit_signal("current_health_changed", _current_health)

func get_current_health():
	return _current_health



func set_max_health(arg_val):
	_max_health = arg_val
	

func get_max_health():
	return _max_health


func is_no_health():
	return _is_dead

##

func set_current_robot_health(arg_val):
	if SingletonsAndConsts.current_game_result_manager.is_game_result_decided:
		return
	
	
	var old_val = _current_robot_health
	_current_robot_health = arg_val
	
	if _current_robot_health > _max_robot_health:
		_current_robot_health = _max_robot_health
	
	if _current_robot_health <= 0:
		_current_robot_health = 0
		
		_is_robot_dead = true
	else:
		_is_robot_dead = false
	
	if old_val != _current_robot_health:
		emit_signal("current_robot_health_changed", _current_robot_health)

func get_current_robot_health() -> float:
	return _current_robot_health


func set_max_robot_health(arg_val):
	var old_val = _max_robot_health
	_max_robot_health = arg_val
	
	if _current_robot_health > _max_robot_health:
		set_current_robot_health(_max_robot_health)
	
	emit_signal("max_robot_health_changed", _max_robot_health)

func get_max_robot_health() -> float:
	return _max_robot_health

##

func get_momentum__using_linear_velocity() -> Vector2:
	return linear_velocity * last_calculated_object_mass

func get_momentum_mag__using_linear_velocity() -> float:
	return (linear_velocity * last_calculated_object_mass).length()

################

func set_current_player_capture_area_region(arg_area_region):
	if is_instance_valid(_current_player_capture_area_region):
		_disconnect_curr_area_region_signals()
	
	#####
	
	_current_player_capture_area_region = arg_area_region
	
	if is_instance_valid(_current_player_capture_area_region):
		if !arg_area_region.is_area_captured():
			if !arg_area_region.is_instant_capture():
				pca_progress_drawer.color_edge_to_use = arg_area_region.player_PCA_progress_drawer__outline_color
				pca_progress_drawer.color_fill_to_use = arg_area_region.player_PCA_progress_drawer__fill_color
				pca_progress_drawer.is_enabled = true
				_update_PCA_values_and_display()
				
				_start_draw_pca_progress_drawer()
				
				#
				
				if !arg_area_region.is_connected("duration_for_capture_left_changed", self, "_on_PCA_duration_for_capture_left_changed"):
					arg_area_region.connect("duration_for_capture_left_changed", self, "_on_PCA_duration_for_capture_left_changed")
				
				if !arg_area_region.is_connected("region_area_captured", self, "_on_PCA_region_area_captured"):
					arg_area_region.connect("region_area_captured", self, "_on_PCA_region_area_captured")
				
				if !arg_area_region.is_connected("region__body_exited_from_area", self, "_on_PCA_region__body_exited_from_area"):
					arg_area_region.connect("region__body_exited_from_area", self, "_on_PCA_region__body_exited_from_area")
				
			else:
				_on_PCA_region_area_captured()
				

func _disconnect_curr_area_region_signals():
	if _current_player_capture_area_region.is_connected("duration_for_capture_left_changed", self, "_on_PCA_duration_for_capture_left_changed"):
		_current_player_capture_area_region.disconnect("duration_for_capture_left_changed", self, "_on_PCA_duration_for_capture_left_changed")
	
	if _current_player_capture_area_region.is_connected("region_area_captured", self, "_on_PCA_region_area_captured"):
		_current_player_capture_area_region.disconnect("region_area_captured", self, "_on_PCA_region_area_captured")
	
	if _current_player_capture_area_region.is_connected("region__body_exited_from_area", self, "_on_PCA_region__body_exited_from_area"):
		_current_player_capture_area_region.disconnect("region__body_exited_from_area", self, "_on_PCA_region__body_exited_from_area")
	



func _start_draw_pca_progress_drawer():
	if !pca_progress_drawer.visible:
		var baseline_duration = _current_player_capture_area_region.get_baseline_duration_for_capture()
		var show_duration = 0.25
		if show_duration > baseline_duration:
			show_duration = baseline_duration
		
		pca_progress_drawer.modulate.a = 0
		pca_progress_drawer.visible = true
		
		var tweener = create_tween()
		tweener.tween_property(pca_progress_drawer, "modulate:a", 1.0, show_duration)
		

func _on_PCA_duration_for_capture_left_changed(arg_base_duration, arg_curr_val_left, delta, arg_is_from_rewind):
	_update_PCA_values_and_display()
	

func _update_PCA_values_and_display():
	var curr_val = _current_player_capture_area_region.get_current_duration_for_capture_left()
	var max_val = _current_player_capture_area_region.get_baseline_duration_for_capture()
	
	var ratio = curr_val / max_val
	
	pca_progress_drawer.set_ratio_filled(ratio)

func _on_PCA_region__body_exited_from_area(body):
	if body == self:
		_stop_pca_progress_drawer()

func _stop_pca_progress_drawer():
	pca_progress_drawer.visible = false
	pca_progress_drawer.set_is_enabled(false)
	
	if is_instance_valid(_current_player_capture_area_region):
		_disconnect_curr_area_region_signals()
	
	_current_player_capture_area_region = null


func _on_PCA_region_area_captured():
	_stop_pca_progress_drawer()
	



###################### 
# REWIND RELATED
#####################

export(bool) var is_rewindable : bool = true
var is_dead_but_reserved_for_rewind : bool

var _use_integ_forces_new_vals : bool

var _rewinded__angular_velocity
var _rewinded__linear_velocity
var _rewinded__sleeping
var _rewinded__transform : Transform2D

var _most_recent_rewind_state

#var _rewinded__current_player_left_right_move_speed
#var _rewinded__current_player_left_right_move_speed__from_last_integrate_forces


func _ready__include_relevant_objs_for_rewind():
	_include_obj_for_rewind_manager(block_player_move_left_and_right_cond_clauses)
	_include_obj_for_rewind_manager(block_rotate_cond_clause)
	_include_obj_for_rewind_manager(ignore_outside_induced_forces_cond_clauses)

func _include_obj_for_rewind_manager(arg_obj):
	SingletonsAndConsts.current_rewind_manager.add_to_rewindables(arg_obj)
	


func get_rewind_save_state():
	var state : Physics2DDirectBodyState = Physics2DServer.body_get_direct_state(get_rid())
	var save_state =  {
		"angular_velocity" : state.angular_velocity,
		#"linear_velocity" : _body_state_linear_velocity__without_modifications, 
		"linear_velocity" : state.linear_velocity,
		"sleeping" : state.sleeping,
		"transform" : state.transform,
		
		"current_player_left_right_move_speed" : _current_player_left_right_move_speed,
		"current_player_left_right_move_speed__from_last_integrate_forces" : _current_player_left_right_move_speed__from_last_integrate_forces,
		"current_excess_player_left_right_move_speed_to_fight_counter_speed" : _current_excess_player_left_right_move_speed_to_fight_counter_speed,
		
		#"current_player_left_right_move_speed" : 0,
		#"current_player_left_right_move_speed__from_last_integrate_forces" : 0,
		
		
		"is_moving_left" : _is_moving_left,
		"is_moving_right" : _is_moving_right,
		
		"player_prev_global_position" : _player_prev_global_position__for_rewind, 
		"player_pos_change_from_last_frame" : _player_pos_change_from_last_frame,
		"player_linear_velocity" : _player_linear_velocity,
		
		"apply_ground_repelling_force" : _apply_ground_repelling_force,
		"cancel_next_apply_ground_repelling_force" : _cancel_next_apply_ground_repelling_force,
		
		"flat_mass_id_to_amount_map" : _flat_mass_id_to_amount_map.duplicate(true),
		
		"all_nodes_to_rotate_with_cam" : _all_nodes_to_rotate_with_cam.duplicate(true),
		
		"objects_to_not_collide_with" : _objects_to_not_collide_with.duplicate(true),
		"objects_to_collide_with_after_exit" : _objects_to_collide_with_after_exit.duplicate(true),
		"objects_to_add_mask_layer_collision_after_exit" : _objects_to_add_mask_layer_collision_after_exit.duplicate(true),
		
		"is_player_modi_energy_set" : is_player_modi_energy_set,
		"player_modi__energy_save_state" : null,
		
		"no_energy_consecutive_duration" : _no_energy_consecutive_duration,
		
		"max_health" : _max_health,
		"current_health" : _current_health,
		#"is_dead" : _i
		
		"current_robot_health" : _current_robot_health,
		#"max_robot_health" : _max_robot_health,
		
		"rotating_for_floor_area_2d.rotation" : rotating_for_floor_area_2d.rotation
	}
	
	if is_player_modi_energy_set:
		save_state["player_modi__energy_save_state"] = player_modi__energy.get_rewind_save_state()
	
	
	return save_state


func load_into_rewind_save_state(arg_state):
	_rewinded__angular_velocity = arg_state["angular_velocity"]
	_rewinded__linear_velocity = arg_state["linear_velocity"]
	_rewinded__sleeping = arg_state["sleeping"]
	_rewinded__transform = arg_state["transform"]
	
	global_position = _rewinded__transform.origin
	
	##
	
	_most_recent_rewind_state = arg_state
	
	if arg_state["is_player_modi_energy_set"]:
		var modi_energy_load_state = arg_state["player_modi__energy_save_state"]
		player_modi__energy.load_into_rewind_save_state(modi_energy_load_state)
	
	_no_energy_consecutive_duration = arg_state["no_energy_consecutive_duration"]
	set_current_health(arg_state["current_health"])
	_max_health = arg_state["max_health"]
	
	set_current_robot_health(arg_state["current_robot_health"])


func destroy_from_rewind_save_state():
	print("PLAYER: destroy_from_rewind_save_state should never be reached...")
	

func restore_from_destroyed_from_rewind():
	pass
	

func stared_rewind():
	mode = RigidBody2D.MODE_STATIC
	collision_shape.set_deferred("disabled", true)
	floor_area_2d_coll_shape.set_deferred("disabled", true)
	rotating_for_floor_area_2d_coll_shape.set_deferred("disabled", true)
	

func ended_rewind():
	_ignore_next_current_player_left_right_move_reset = true
	
	#
	
	mode = RigidBody2D.MODE_CHARACTER
	collision_shape.set_deferred("disabled", false)
	floor_area_2d_coll_shape.set_deferred("disabled", false)
	rotating_for_floor_area_2d_coll_shape.set_deferred("disabled", false)
	
	_use_integ_forces_new_vals = true
	
	_use_prev_glob_pos_for_rewind = true
	
	##
	
	#_is_moving_left = false #_most_recent_rewind_state["is_moving_left"]
	#_is_moving_right = false #_most_recent_rewind_state["is_moving_right"]
	
	_player_prev_global_position = _most_recent_rewind_state["player_prev_global_position"]
	_player_pos_change_from_last_frame = _most_recent_rewind_state["player_pos_change_from_last_frame"]
	_player_linear_velocity = _most_recent_rewind_state["player_linear_velocity"]
	
	_current_player_left_right_move_speed = _most_recent_rewind_state["current_player_left_right_move_speed"]
	_current_player_left_right_move_speed__from_last_integrate_forces = _most_recent_rewind_state["current_player_left_right_move_speed__from_last_integrate_forces"]
	#_current_excess_player_left_right_move_speed_to_fight_counter_speed = _most_recent_rewind_state["current_excess_player_left_right_move_speed_to_fight_counter_speed"]
	
	_apply_ground_repelling_force = _most_recent_rewind_state["apply_ground_repelling_force"]
	_cancel_next_apply_ground_repelling_force = _most_recent_rewind_state["cancel_next_apply_ground_repelling_force"]
	
	_flat_mass_id_to_amount_map = _most_recent_rewind_state["flat_mass_id_to_amount_map"]
	_update_last_calculated_object_mass()
	
	_all_nodes_to_rotate_with_cam.clear()
	_all_nodes_to_rotate_with_cam.append_array(_most_recent_rewind_state["all_nodes_to_rotate_with_cam"])
	
	_objects_to_not_collide_with.clear()
	for obj in _most_recent_rewind_state["objects_to_not_collide_with"]:
		add_object_to_not_collide_with(obj)
	
	_objects_to_collide_with_after_exit.clear()
	for obj in _most_recent_rewind_state["objects_to_collide_with_after_exit"]:
		add_objects_to_collide_with_after_exit(obj)
	
	_objects_to_add_mask_layer_collision_after_exit.clear()
	for obj in _most_recent_rewind_state["objects_to_add_mask_layer_collision_after_exit"]:
		add_objects_to_add_mask_layer_collision_after_exit(obj)
	
	is_player_modi_energy_set = _most_recent_rewind_state["is_player_modi_energy_set"]
	
	rotating_for_floor_area_2d.rotation = _most_recent_rewind_state["rotating_for_floor_area_2d.rotation"]
	

func _on_rewind_manager__ended_rewind__iterated_over_all():
	_update_last_calc_can_move_left_and_right()
	_update_last_calc_is_rotate_ready()
	_update_last_calc_ignore_outside_induced_forces()
	
	
