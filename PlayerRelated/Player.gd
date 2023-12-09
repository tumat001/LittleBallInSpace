extends RigidBody2D

const ConditionalClauses = preload("res://MiscRelated/ClauseRelated/ConditionalClauses.gd")

const BaseTileSet = preload("res://ObjectsRelated/TilesRelated/BaseTileSet.gd")
const BaseObject = preload("res://ObjectsRelated/Objects/BaseObject.gd")

const PlayerModi_Energy = preload("res://PlayerRelated/PlayerModi/Imps/EnergyRelated/PlayerModi_Energy.gd")

const AnimSpriteComponentPool = preload("res://MiscRelated/PoolRelated/Imps/AnimSpriteComponentPool.gd")

const PlayerParticle_HitTile_Scene = preload("res://PlayerRelated/PlayerParticles/HitTile/PlayerParticle_HitTile.tscn")

const LightTextureConstructor = preload("res://MiscRelated/Light2DRelated/LightTextureConstructor.gd")

const StoreOfTrailType = preload("res://MiscRelated/TrailRelated/StoreOfTrailType.gd")
const MultipleTrailsForNodeComponent = preload("res://MiscRelated/TrailRelated/MultipleTrailsForNodeComponent.gd")


#

signal break_all_player_game_actions__blocked_game_actions()
signal last_calc_block_player_game_actions_changed(arg_val)

signal last_calculated_object_mass_changed(arg_val)

signal unhandled_key_input_received(event)
signal unhandled_mouse_button_input_received(event)

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

signal can_capture_PCA_regions_changed(arg_val)

signal light_2d_mod_a_changed(arg_val)


signal pos_change__for_aesth_effects(curr_pos_mag, prev_pos_mag, diff, delta)
#state : Physics2DDirectBodyState
signal on_integ_forces(state)


signal on_ground_state_changed(arg_val)

#

var _base_player_size

#

enum BlockPlayerMoveLeftAndRightClauseIds {
	NOT_ON_GROUND = 0,
	NO_ENERGY = 1,
	NO_ROBOT_HEALTH = 2,
}

var block_player_move_left_and_right_cond_clauses : ConditionalClauses
var last_calc_can_player_move_left_and_right : bool

#

enum BlockPlayerGameActionsClauseIds {
	NO_ENERGY = 0,
	NO_ROBOT_HEALTH = 1,
}
var block_player_game_actions_cond_clauses : ConditionalClauses
var last_calc_block_player_game_actions : bool


#

var can_move_left__special_case : bool = true


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


var _tilesets_entered_to_cell_coords_entered_count_map : Dictionary = {}

var _last_cell_id
var _last_cell_autocoord
var _last_cell_global_pos
var _pos_change_caused_by_tile : bool

var _is_pos_change_potentially_from_tileset : bool
var _pos_change_potentially_from_tileset__diff

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
const PLAYER_MOV_MULTIPLER_ON_OPPOSITE_CURR_SPEED : float = 2.0 #1.5

var _current_player_left_right_move_speed : float
var _current_player_left_right_move_speed__from_last_integrate_forces : float
var _ignore_next_current_player_left_right_move_reset : bool
var _current_excess_player_left_right_move_speed_to_fight_counter_speed : Vector2


const COUNTER_FORCE_MULTIPLER__FOR_ANY_PURPOSE = PLAYER_MOV_MULTIPLER_ON_OPPOSITE_CURR_SPEED

#var _swapped_speed__by_rotating_by_PI : bool

#var _body_state_linear_velocity__without_modifications : Vector2

##

enum IgnoreOutsideInducedForcesClauseIds {
	IS_ON_GROUND = 1
}
var ignore_outside_induced_forces_cond_clauses : ConditionalClauses
var last_calc_ignore_outside_induced_forces : bool

var _all_outside_induced_forces_list : Array
var _all_inside_induced_forces_list : Array

#

var _static_base_objects_in_contact_with : Array

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

enum BlockHealthChangeClauseIds {
	IS_GAME_RESULT_DECIDED = 0,
	IN_CUTSCENE = 1,
	
	CUSTOM_DEFINED__01 = 10,
}
var block_health_change_cond_clauses : ConditionalClauses
var last_calculated_is_block_health_change : bool


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
var can_capture_PCA_regions : bool = true setget set_can_capture_PCA_regions

##

var is_player : bool = true

##

var _audio_player__capturing_point : AudioStreamPlayer

##

var player_hit_tile_particle_compo_pool : AnimSpriteComponentPool
var counterforce_blast_particle_compo_pool : AnimSpriteComponentPool

##

var ignore_effect_based_on_pos_change__next_frame_count : int

##

var is_show_lines_to_uncaptured_player_capture_regions : bool = false setget set_is_show_lines_to_uncaptured_player_capture_regions

#

var speed_trail_component : MultipleTrailsForNodeComponent
var _current_speed_trail
#var _current_speed_trail__duration : float

const SPEED_TRAIL_COLOR = Color("#66cccccc")
const SPEED_TRAIL_LENGTH_01 : int = 12
const SPEED_TRAIL_LENGTH_02 : int = 18
const SPEED_TRAIL_SPEED_TRIGGER : float = 200.0
const SPEED_TRAIL_SPEED_TRIGGER_02 : float = 280.0

#const SPEED_TRAIL__MIN_LENGTH : int = 10
#const SPEED_TRAIL__MAX_LENGTH : int = 20
#const SPEED_TRAIL__MIN_LENGTH__SPEED_TRIGGER : float = 220.0
#const SPEED_TRAIL__MAX_LENGTH__SPEED_TRIGGER : float = 400.0


###

const NO_ENERGY__INITIAL_HEALTH_LOSS_PER_SEC : float = 0.5
const NO_ENERGY__HEALTH_LOSS_PER_SEC_PER_SEC : float = 2.0
const NO_ENERGY__MAX_HEALTH_LOSS_PER_SEC : float = 10.5

###

const FACE_ANIMATION_NAME__NORMAL = "normal"
const FACE_ANIMATION_NAME__NORMAL_TO_OUCH = "normal_to_ouch"
const FACE_ANIMATION_NAME__OUCH = "ouch"
const FACE_ANIMATION_NAME__OUCH_TO_NORMAL = "ouch_to_normal"

#

const DEFAULT_LIGHT_TEX_REC_SIZE = Vector2(320, 320)

const DEFAULT_LIGHT_COLOR = Color("#feffa3")
var _light_color : Color = DEFAULT_LIGHT_COLOR

var _light_energy : float = 1.0
var _light_2d__target_mod_a : float = -1
const LIGHT_2D_MOD_A_PER_SEC : float = 0.4


#

enum DisablePlayerCollisionMarkClauseIds {
	REWINDING = 0,
	IS_ROBOT_DEAD = 1,
}
var disable_player_collision_cond_clauses : ConditionalClauses
var last_calc_is_player_collision_disabled : bool



#

onready var sprite_layer = $SpriteLayer

onready var collision_shape = $CollisionShape2D
onready var floor_area_2d = $FloorArea2D
onready var floor_area_2d_coll_shape = $FloorArea2D/CollisionShape2D

onready var rotating_for_floor_area_2d = $RotatingForFloorArea2D
onready var rotating_for_floor_area_2d_coll_shape = $RotatingForFloorArea2D/CollisionShape2D

#onready var face_screen = $SpriteLayer/FaceScreen
#onready var anim_on_screen = $SpriteLayer/AnimOnScreen
onready var main_body_sprite = $SpriteLayer/PlayerMainBody

onready var pca_progress_drawer = $PCAProgressDrawer
onready var pca_line_direction_drawer = $PCALineDirectionDrawer

onready var light_2d = $Light2D

onready var player_face = $SpriteLayer/PlayerFace

onready var pca_captured_drawer = $PCACapturedDrawer

#onready var remote_transform_2d = $RemoteTransform2D

#

func _init():
	block_player_move_left_and_right_cond_clauses = ConditionalClauses.new()
	block_player_move_left_and_right_cond_clauses.connect("clause_inserted", self, "_on_block_move_left_and_right_cond_clauses_updated")
	block_player_move_left_and_right_cond_clauses.connect("clause_removed", self, "_on_block_move_left_and_right_cond_clauses_updated")
	block_player_move_left_and_right_cond_clauses.attempt_insert_clause(BlockPlayerMoveLeftAndRightClauseIds.NOT_ON_GROUND)
	
	block_player_game_actions_cond_clauses = ConditionalClauses.new()
	block_player_game_actions_cond_clauses.connect("clause_inserted", self, "_on_block_player_game_actions_cond_clauses_updated")
	block_player_game_actions_cond_clauses.connect("clause_removed", self, "_on_block_player_game_actions_cond_clauses_updated")
	_update_last_calc_block_player_game_actions()
	
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
	
	block_health_change_cond_clauses = ConditionalClauses.new()
	block_health_change_cond_clauses.connect("clause_inserted", self, "_on_block_health_change_cond_clauses_updated", [], CONNECT_PERSIST)
	block_health_change_cond_clauses.connect("clause_removed", self, "_on_block_health_change_cond_clauses_updated", [], CONNECT_PERSIST)
	_update_last_calculated_is_block_health_change()
	
	#
	
	player_hit_tile_particle_compo_pool = AnimSpriteComponentPool.new()
	player_hit_tile_particle_compo_pool.node_to_listen_for_queue_free = self
	player_hit_tile_particle_compo_pool.node_to_parent = SingletonsAndConsts.current_game_elements__other_node_hoster
	player_hit_tile_particle_compo_pool.func_name_for_create_resource = "_create_player_hit_tile_particle__for_pool"
	player_hit_tile_particle_compo_pool.source_of_create_resource = self
	
	#todo make conterforce blast particle compo soon
#	counterforce_blast_particle_compo_pool = AnimSpriteComponentPool.new()
#	counterforce_blast_particle_compo_pool.node_to_listen_for_queue_free = self
#	counterforce_blast_particle_compo_pool.node_to_parent = SingletonsAndConsts.current_game_elements__other_node_hoster
#	counterforce_blast_particle_compo_pool.func_name_for_create_resource = "_create_counterforce_blast_particle__for_pool"
#	counterforce_blast_particle_compo_pool.source_of_create_resource = self
	
	_update_last_calculated_object_mass()
	
	
	disable_player_collision_cond_clauses = ConditionalClauses.new()
	disable_player_collision_cond_clauses.connect("clause_inserted", self, "_on_disable_player_collision_cond_clauses_updated")
	disable_player_collision_cond_clauses.connect("clause_removed", self, "_on_disable_player_collision_cond_clauses_updated")
	_update_last_calc_is_player_collision_disabled()

#

func _on_block_move_left_and_right_cond_clauses_updated(arg_clause_id):
	_update_last_calc_can_move_left_and_right()
	

func _update_last_calc_can_move_left_and_right():
	last_calc_can_player_move_left_and_right = block_player_move_left_and_right_cond_clauses.is_passed


#

func _on_block_player_game_actions_cond_clauses_updated(arg_clause_id):
	_update_last_calc_block_player_game_actions()

func _update_last_calc_block_player_game_actions():
	var old_val = last_calc_block_player_game_actions
	last_calc_block_player_game_actions = !block_player_game_actions_cond_clauses.is_passed
	
	if last_calc_block_player_game_actions and (old_val != last_calc_block_player_game_actions):
		_break_all_player_game_actions__blocked_game_actions()
	
	emit_signal("last_calc_block_player_game_actions_changed", last_calc_block_player_game_actions)

func _break_all_player_game_actions__blocked_game_actions():
	_is_moving_left = false
	_is_moving_right = false
	_is_move_breaking = false
	
	emit_signal("break_all_player_game_actions__blocked_game_actions")

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

func _on_block_all_inputs_cond_clauses_updated(arg_clause_id):
	_update_last_calc_block_all_inputs()

func _update_last_calc_block_all_inputs():
	last_calc_block_all_inputs = !block_all_inputs_cond_clauses.is_passed

#

func _on_block_health_change_cond_clauses_updated(arg_clause_id):
	_update_last_calculated_is_block_health_change()

func _update_last_calculated_is_block_health_change():
	last_calculated_is_block_health_change = !block_health_change_cond_clauses.is_passed

#

func _update_last_calculated_object_mass():
	var total = _base_object_mass
	for mass in _flat_mass_id_to_amount_map:
		total += mass
	
	last_calculated_object_mass = total
	mass = last_calculated_object_mass
	emit_signal("last_calculated_object_mass_changed", last_calculated_object_mass)

#

func _on_disable_player_collision_cond_clauses_updated(arg_clause_id):
	_update_last_calc_is_player_collision_disabled()

func _update_last_calc_is_player_collision_disabled():
	var old_val = last_calc_is_player_collision_disabled
	last_calc_is_player_collision_disabled = !disable_player_collision_cond_clauses.is_passed
	
	if old_val != last_calc_is_player_collision_disabled:
		collision_shape.set_deferred("disabled", last_calc_is_player_collision_disabled)
		floor_area_2d_coll_shape.set_deferred("disabled", last_calc_is_player_collision_disabled)
		rotating_for_floor_area_2d_coll_shape.set_deferred("disabled", last_calc_is_player_collision_disabled)
	

#######

func _on_FloorArea2D_body_shape_entered(body_rid, body, body_shape_index, local_shape_index):
	if !has_object_to_not_collide_with(body):
		
		
		if body is BaseTileSet:
			if !_tilesets_entered_to_cell_coords_entered_count_map.has(body):
				_tilesets_entered_to_cell_coords_entered_count_map[body] = 0
			
			if _tilesets_entered_to_cell_coords_entered_count_map[body] < 0:
				_tilesets_entered_to_cell_coords_entered_count_map[body] = 0
			_tilesets_entered_to_cell_coords_entered_count_map[body] += 1
			_on_body_entered__tilemap(body_rid, body, body_shape_index, local_shape_index)
			
		elif body is BaseObject:
			_on_body_entered__base_object(body_rid, body, body_shape_index, local_shape_index)
			
	
	
	emit_signal("player_body_shape_entered", body_rid, body, body_shape_index, local_shape_index)



func _on_body_entered__tilemap(body_rid, body, body_shape_index, local_shape_index):
	
	if body.break_on_player_contact:
		var coordinate: Vector2 = Physics2DServer.body_get_shape_metadata(body.get_rid(), body_shape_index)
		
		#
		var tilemap : TileMap = body.tilemap
		var cell_id = tilemap.get_cellv(coordinate)
		var cell_autocoord = tilemap.get_cell_autotile_coord(coordinate.x, coordinate.y)
		
		var tile_local_pos_top_left = tilemap.map_to_world(coordinate)
		var tile_local_pos = tile_local_pos_top_left + (tilemap.cell_size / 2)
		var tile_global_pos = tilemap.to_global(tile_local_pos)
		
		var sound_id_of_break = TileConstants.get_sound_id_to_play_for_tile_break(cell_id, cell_autocoord)
		if sound_id_of_break != -1:
			AudioManager.helper__play_sound_effect__2d(sound_id_of_break, tile_global_pos, 1.0, null)
		
		#
		
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
				var old_cam_rotation = CameraManager.current_cam_rotation
				
				_attempt_remove_on_ground_count__with_any_identif(coordinate)
				_request_rotate(perpend_angle_with_lowest_distance, coordinate, tileset_energy_mode)
				
				if _ignore_next_current_player_left_right_move_reset:
					_ignore_next_current_player_left_right_move_reset = false
				else:
					
					_current_player_left_right_move_speed = 0
					_current_player_left_right_move_speed__from_last_integrate_forces = 0
					_current_excess_player_left_right_move_speed_to_fight_counter_speed = Vector2(0, 0)
					
					
#					if (is_equal_approx(abs(perpend_angle_with_lowest_distance - old_cam_rotation), PI)):
#						_current_player_left_right_move_speed = _current_player_left_right_move_speed
#						print("swapped speed")
#						_current_player_left_right_move_speed__from_last_integrate_forces = 0
#						_current_excess_player_left_right_move_speed_to_fight_counter_speed = Vector2(0, 0)
#
#						_swapped_speed__by_rotating_by_PI = true
#					else:
#						print("removed speed")
#						_current_player_left_right_move_speed = 0
#						_current_player_left_right_move_speed__from_last_integrate_forces = 0
#						_current_excess_player_left_right_move_speed_to_fight_counter_speed = Vector2(0, 0)
#
#						_swapped_speed__by_rotating_by_PI = false
				
				clear_all_inside_induced_forces()
				clear_all_outside_induced_forces()
				_cancel_next_apply_ground_repelling_force = false
				
				_pos_change_caused_by_tile = true
				
				
				AudioManager.helper__play_sound_effect__2d(StoreOfAudio.AudioIds.SFX_Rotate_Standard_01, global_position, 0.65, null)
				
			
		else:
			_attempt_add_on_ground_count__with_any_indentif(coordinate, tileset_energy_mode)
			clear_all_outside_induced_forces()
			clear_all_inside_induced_forces()
			_cancel_next_apply_ground_repelling_force = false
		
		###############
		
		
		###
		
		var cell_id = tilemap.get_cellv(coordinate)
		var cell_autocoord = tilemap.get_cell_autotile_coord(coordinate.x, coordinate.y)
		_last_cell_id = cell_id
		_last_cell_autocoord = cell_autocoord
		_last_cell_global_pos = tile_global_pos
		
		if _is_pos_change_potentially_from_tileset:
			_play_tile_hit_sound__and_show_particles(_pos_change_potentially_from_tileset__diff)

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
		
		var perfected_angle = _clean_up_angle__perfect_translated_for_circle_partition(perpend_angle)
		
		segments_and_midpoint.append([a, b, mid_point, perfected_angle])
		
	
	return segments_and_midpoint

func _clean_up_angle__perfect_translated_for_circle_partition(arg_angle):
	var translated = arg_angle / CIRCLE_PARTITION
	var perfected_translated = round(translated)
	return perfected_translated * CIRCLE_PARTITION
	

##

func _on_FloorArea2D_body_shape_exited(body_rid, body, body_shape_index, local_shape_index):
	if body is BaseTileSet:
		if _tilesets_entered_to_cell_coords_entered_count_map.has(body):
			var count = _tilesets_entered_to_cell_coords_entered_count_map[body]
			_tilesets_entered_to_cell_coords_entered_count_map[body] -= 1
			
			#print("count on exit: %s" % count)
			
			if count > 0:
				if !body.break_on_player_contact: #and !body.changing_colls__from_fill_and_unfilled:
					if body.has_tile_by_body_shape_index(body_shape_index):
						
						var coordinate: Vector2 = Physics2DServer.body_get_shape_metadata(body.get_rid(), body_shape_index)
						
						_attempt_remove_on_ground_count__with_any_identif(coordinate)
			
		
		#if !body.changing_colls__from_fill_and_unfilled:
		#	body.changing_colls__from_fill_and_unfilled = false
	
	if body is BaseObject:
		_on_body_exited__base_object(body_rid, body, body_shape_index, local_shape_index)
	
	emit_signal("player_body_shape_exited", body_rid, body, body_shape_index, local_shape_index)

func remove_on_ground_count_with_identif__from_breakable_tile__before_breaking(arg_coordinate, arg_tilemap):
	
	var result = _attempt_remove_on_ground_count__with_any_identif(arg_coordinate)
	if result:
		if _tilesets_entered_to_cell_coords_entered_count_map.has(arg_tilemap):
			_tilesets_entered_to_cell_coords_entered_count_map[arg_tilemap] -= 1
	

func remove_on_ground_count_with_identif__from_any_purpose__changing_tiles__before_change(arg_coordinate, arg_tilemap):
	var result = _attempt_remove_on_ground_count__with_any_identif(arg_coordinate)
	if result:
		if _tilesets_entered_to_cell_coords_entered_count_map.has(arg_tilemap):
			_tilesets_entered_to_cell_coords_entered_count_map[arg_tilemap] -= 1
		



func _on_body_exited__base_object(body_rid, body, body_shape_index, local_shape_index):
	if _objects_to_collide_with_after_exit.has(body):
		remove_objects_to_not_collide_with(body)
		remove_objects_to_collide_with_after_exit(body)
	
	if _objects_to_add_mask_layer_collision_after_exit.has(body):
		remove_objects_to_add_mask_layer_collision_after_exit(body)
	
	attempt_remove_static_base_objects_in_contact_with(body)

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
		
		return true
	
	return false



func _update_is_on_ground__and_update_others():
	var old_val = _is_on_ground
	
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
	
	if old_val != _is_on_ground:
		emit_signal("on_ground_state_changed", _is_on_ground)

##

func _unhandled_key_input(event):
	# NOTE:
	# IF making a persisting action (ex: moving left while holding),
	# update method: stop_all_persisting_actions to include reversal of those actions
	
	
	if !last_calc_block_all_inputs:
		#if !SingletonsAndConsts.current_rewind_manager.is_rewinding:
		var is_consumed = false
		
		if event.is_action_released("game_left"):
			_is_moving_left = false
			
		elif event.is_action_released("game_right"):
			_is_moving_right = false
			
		elif event.is_action_released("game_down"):
			_is_move_breaking = false
			sleeping = false
			
		else:
			if event.is_action("game_left"):
				if can_move_left__special_case and !last_calc_block_player_game_actions:
					_is_moving_left = true
			elif event.is_action("game_right"):
				if !last_calc_block_player_game_actions:
					_is_moving_right = true
			elif event.is_action("game_down") and !GameSettingsManager.get_game_control_name__is_hidden("game_down"):
				if !last_calc_block_player_game_actions:
					_is_move_breaking = true
				
			
		
		if !SingletonsAndConsts.current_rewind_manager.is_rewinding:
			if event.is_action_pressed("game_zoom_out") and !GameSettingsManager.get_game_control_name__is_hidden("game_zoom_out"):
				if CameraManager.is_at_default_zoom():
					CameraManager.start_camera_zoom_change__with_default_player_initialized_vals()
				else:
					CameraManager.reset_camera_zoom_level()
				
				is_consumed = true
				
		
		
#			elif event.is_action_released("game_zoom_out"):
#				CameraManager.reset_camera_zoom_level()
#				is_consumed = true
#
			
			
			if !is_consumed:
				emit_signal("unhandled_key_input_received", event)

func _unhandled_input(event):
	if event is InputEventMouseButton:
		var is_consumed = false
		
		if !is_consumed:
			emit_signal("unhandled_mouse_button_input_received", event)



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
		
		#var counter_dir = Vector2(1, 0).rotated(CameraManager.current_cam_rotation)
		if last_calc_can_player_move_left_and_right: #and !_is_any_static_body_impeding_movement(linear_velocity):
			if _is_moving_left:
				#print("moving left: %s" % _current_player_left_right_move_speed)
				
				#if is_zero_approx(linear_velocity.x) and is_zero_approx(linear_velocity.y):
				#	var counter_dir = Vector2(1, 0).rotated(CameraManager.current_cam_rotation)
				#	if _is_any_static_body_impeding_movement(counter_dir):
				#		_current_excess_player_left_right_move_speed_to_fight_counter_speed = Vector2(0, 0)
				
				#var intent_mov = Vector2(-1, 0)
				#var intent_mov = Vector2(1, 0).rotated(CameraManager.current_cam_rotation)
				#if !_is_any_static_body_impeding_movement(intent_mov):
				#print("building speed left")
				
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
						
						var counter_mov = -mov_of_excess * excess_scale
						_current_excess_player_left_right_move_speed_to_fight_counter_speed = counter_mov
						#if !_is_any_static_body_impeding_movement(counter_mov):
						#	print("adding counter mov left")
						#	_current_excess_player_left_right_move_speed_to_fight_counter_speed = counter_mov
						#else:
						#	_current_excess_player_left_right_move_speed_to_fight_counter_speed = Vector2(0, 0)
						
					else:
						_current_excess_player_left_right_move_speed_to_fight_counter_speed = Vector2(0, 0)
					
				#else:
				#	#_current_excess_player_left_right_move_speed_to_fight_counter_speed = Vector2(0, 0)
				#	#pass
				#	#_current_player_left_right_move_speed = 0
				
			elif _is_moving_right:
				#print("moving right: %s" % _current_player_left_right_move_speed)
				
				#if is_zero_approx(linear_velocity.x) and is_zero_approx(linear_velocity.y):
				#	var counter_dir = Vector2(1, 0).rotated(CameraManager.current_cam_rotation)
				#	if _is_any_static_body_impeding_movement(counter_dir):
				#		_current_excess_player_left_right_move_speed_to_fight_counter_speed = Vector2(0, 0)
				
				#var intent_mov = Vector2(-1, 0).rotated(CameraManager.current_cam_rotation)
				#if !_is_any_static_body_impeding_movement(intent_mov):
				#	
				#	print("building speed right")
			
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
						
						var counter_mov = -mov_of_excess * excess_scale
						_current_excess_player_left_right_move_speed_to_fight_counter_speed = counter_mov
						
						#if !_is_any_static_body_impeding_movement(counter_mov):
						#	print("adding counter mov right")
						#	_current_excess_player_left_right_move_speed_to_fight_counter_speed = counter_mov
						#else:
						#	_current_excess_player_left_right_move_speed_to_fight_counter_speed = Vector2(0, 0)
						
						
					else:
						_current_excess_player_left_right_move_speed_to_fight_counter_speed = Vector2(0, 0)
					
				
				#else:
				#	#pass
				#	_current_excess_player_left_right_move_speed_to_fight_counter_speed = Vector2(0, 0)
				#	#_current_player_left_right_move_speed = 0
				
			elif _is_move_breaking:
				
				if !is_zero_approx(linear_velocity.x) or !is_zero_approx(linear_velocity.y):
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
			_use_prev_glob_pos_for_rewind = false
		
		
		var prev_pos_change_from_last_frame = _player_pos_change_from_last_frame
		_player_pos_change_from_last_frame = global_position - _player_prev_global_position
		_player_linear_velocity = _player_pos_change_from_last_frame / delta
		_player_prev_global_position = global_position
		
		
		if ignore_effect_based_on_pos_change__next_frame_count <= 0:
			ignore_effect_based_on_pos_change__next_frame_count = 0
			_do_effects_based_on_pos_changes(prev_pos_change_from_last_frame, _player_pos_change_from_last_frame, delta)
		else:
			#ignore_effect_based_on_pos_change__next_frame = false
			ignore_effect_based_on_pos_change__next_frame_count -= 1

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
	#print("lin_vel: %s, curr_speed: %s, extra_counter force: %s" % [linear_velocity, _current_player_left_right_move_speed, _current_excess_player_left_right_move_speed_to_fight_counter_speed])
	
	if !SingletonsAndConsts.current_rewind_manager.is_rewinding:
		
		if _use_integ_forces_new_vals:
			state.angular_velocity = _rewinded__angular_velocity
			state.linear_velocity = _rewinded__linear_velocity
			state.sleeping = _rewinded__sleeping
			state.transform = _rewinded__transform
			
			_use_integ_forces_new_vals = false
			
		
		
		########################
		
		#
		
#		var dir = Vector2(1, 0).rotated(CameraManager.current_cam_rotation)
#		if _is_any_static_body_impeding_movement(dir):
#			#_current_player_left_right_move_speed = 0
#			#_current_player_left_right_move_speed__from_last_integrate_forces = 0
#			print("setted to zero")
#			_current_excess_player_left_right_move_speed_to_fight_counter_speed = Vector2(0, 0)
		
		
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
				#print("made x zero")
			elif vel.y != 0:
				make_y_zero = true
				#print("made y zero")
			
			_apply_ground_repelling_force = false
		
		#
		
		var undeltad_mov_speed = _current_player_left_right_move_speed
		var undeltad_mov = Vector2(undeltad_mov_speed, 0)
		undeltad_mov = undeltad_mov.rotated(CameraManager.current_cam_rotation)
		
		#_body_state_linear_velocity__without_modifications = state.linear_velocity - undeltad_mov
		
		#
		
		if _is_move_breaking:
			if !is_zero_approx(state.linear_velocity.x) or !is_zero_approx(state.linear_velocity.y):
				var mov_length = state.linear_velocity.length()
				if mov_length < 5.0:
					make_x_zero = true
					make_y_zero = true
					sleeping = true
					#_current_player_left_right_move_speed = 0
					#_current_player_left_right_move_speed__from_last_integrate_forces = 0
					#_current_excess_player_left_right_move_speed_to_fight_counter_speed = Vector2(0, 0)
					
		
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
		
		#
		
		if !SingletonsAndConsts.current_rewind_manager.is_rewinding:
			if GameStatsManager.is_started_GE_record_stats():
				var rec_speed = GameStatsManager.current_GE__highest_speed
				var curr_speed = linear_velocity.length()
				if rec_speed < curr_speed:
					GameStatsManager.current_GE__highest_speed = curr_speed
		
		#state : Physics2DDirectBodyState
		emit_signal("on_integ_forces", state)
		
	else:
		pass


func _process(delta):
	if !SingletonsAndConsts.current_rewind_manager.is_rewinding:
		if is_player_modi_energy_set:
			if is_robot_alive():
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
				
		
		if !is_equal_approx(_light_2d__target_mod_a, -1):
			var mod_a_per_sec = LIGHT_2D_MOD_A_PER_SEC * delta
			if light_2d.color.a > _light_2d__target_mod_a:
				mod_a_per_sec *= -1
			
			var final_val = light_2d.color.a + mod_a_per_sec
			final_val = light_energy_mod_a__get_cleaned_val(final_val)
			set_light_energy_mod_a(final_val)
			
			if is_equal_approx(final_val, _light_2d__target_mod_a):
				_light_2d__target_mod_a = -1

#############

func _ready():
	_base_player_size = main_body_sprite.get_body_texture().get_size()
	
	#
	
	_calculate_and_store_ground_attracting_velocity_at_cam_angle(CameraManager.current_cam_rotation)
	
	#
	
	_player_prev_global_position = global_position
	
	
	player_face.player = self
	
	#_make_node_rotate_with_cam(sprite_layer)
	#_make_node_rotate_with_cam(face_screen)
	#_make_node_rotate_with_cam(anim_on_screen)
	_make_node_rotate_with_cam(player_face)
	_make_node_rotate_with_cam(pca_progress_drawer)
	_make_node_rotate_with_cam(main_body_sprite)
	
	CameraManager.connect("cam_visual_rotation_changed", self, "_rotate_nodes_to_rotate_with_cam", [], CONNECT_PERSIST)
	
	mode = RigidBody2D.MODE_CHARACTER
	
	########
	
	SingletonsAndConsts.current_rewind_manager.connect("done_ending_rewind", self, "_on_rewind_manager__ended_rewind__iterated_over_all", [], CONNECT_PERSIST)
	SingletonsAndConsts.current_rewind_manager.add_to_rewindables(self)
	CameraManager.connect("current_cam_rotation_changed", self, "_on_cam_manager_rotation_changed", [], CONNECT_PERSIST)
	#_ready__include_relevant_objs_for_rewind()
	
	##
	
	SingletonsAndConsts.current_game_elements.game_result_manager.connect("game_result_decided", self, "_on_game_result_decided")
	
	_initialize_player_light()
	_initialize_speed_trail_component()

#

func _make_node_rotate_with_cam(arg_node):
	_all_nodes_to_rotate_with_cam.append(arg_node)
	

#

func _on_game_result_decided(arg_result):
	block_health_change_cond_clauses.attempt_insert_clause(BlockHealthChangeClauseIds.IS_GAME_RESULT_DECIDED)

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
		#if !_swapped_speed__by_rotating_by_PI:
		#	_current_player_left_right_move_speed = 0
		#else:
		#	_swapped_speed__by_rotating_by_PI = false
		
		_current_player_left_right_move_speed = 0
		_current_player_left_right_move_speed__from_last_integrate_forces = 0
		_current_excess_player_left_right_move_speed_to_fight_counter_speed = Vector2(0, 0)
		
		if GameStatsManager.is_started_GE_record_stats():
			GameStatsManager.current_GE__rotation_count += 1
	
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

func cancel_next_apply_ground_repelling_force__from_portal():
	_cancel_next_apply_ground_repelling_force = true


func is_on_ground():
	return _is_on_ground



func apply_inside_induced_force__with_counterforce_speed_if_applicable(arg_vector : Vector2):
	apply_inside_induced_force(arg_vector)
	
#	if _is_directions_significantly_different(linear_velocity, arg_vector):
#		var new_vector = _increase_multiply_counterforce_vector(arg_vector)
#		apply_inside_induced_force(new_vector)
#
#		#_play_particle_effect__counter_force_from_any_source(arg_vector)
#
#		print("applid new vec counter: %s, orig: %s" % [new_vector, arg_vector])
#
#	else:
#		apply_inside_induced_force(arg_vector)
#

# also used in Portal class. 
# DO NOT COPY PASTE as values are different
func _is_directions_significantly_different(arg_dir_01 : Vector2, arg_dir_02 : Vector2):
	if (is_zero_approx(arg_dir_01.x) and is_zero_approx(arg_dir_01.y)) or (is_zero_approx(arg_dir_02.x) and is_zero_approx(arg_dir_02.y)):
		return false
		
	else:
		if abs(angle_to_angle(arg_dir_01.angle(), arg_dir_02.angle())) > (PI)/2:
			return true
		else:
			return false

static func angle_to_angle(from, to):
	return fposmod(to-from + PI, PI*2) - PI


func _increase_multiply_counterforce_vector(arg_vector : Vector2):
	var x_to_use = _increase_multiply_counterforce_vector_axis(arg_vector.x, linear_velocity.x)
	var y_to_use = _increase_multiply_counterforce_vector_axis(arg_vector.y, linear_velocity.y)
	
	x_to_use = _clean_up_angle__perfect_translated_for_circle_partition(x_to_use)
	y_to_use = _clean_up_angle__perfect_translated_for_circle_partition(y_to_use)
	
	return Vector2(x_to_use, y_to_use)

func _increase_multiply_counterforce_vector_axis(arg_vector_axis : float, arg_lin_vel_axis : float) -> float:
	var multiplied_lin = arg_lin_vel_axis * COUNTER_FORCE_MULTIPLER__FOR_ANY_PURPOSE
	var excess_from_arg = arg_vector_axis
	if abs(multiplied_lin) > arg_lin_vel_axis:
		excess_from_arg = multiplied_lin + (arg_vector_axis * COUNTER_FORCE_MULTIPLER__FOR_ANY_PURPOSE)
	
	#print("mul: %s, excess: %s" % [multiplied_lin, excess_from_arg])
	
	return (multiplied_lin - excess_from_arg) * -1
	
#	var multiplied_lin = arg_lin_vel_axis * COUNTER_FORCE_MULTIPLER__FOR_ANY_PURPOSE
#	if abs(multiplied_lin) >= arg_vector_axis and multiplied_lin < arg_vector_axis:
#		multiplied_lin = arg_vector_axis * COUNTER_FORCE_MULTIPLER__FOR_ANY_PURPOSE
#
#	var excess_from_arg = (arg_vector_axis + multiplied_lin) / COUNTER_FORCE_MULTIPLER__FOR_ANY_PURPOSE
#	return multiplied_lin + excess_from_arg
	
#	var multiplied_lin = arg_lin_vel_axis * COUNTER_FORCE_MULTIPLER__FOR_ANY_PURPOSE
#	var excess_from_arg = (arg_vector_axis + multiplied_lin) / COUNTER_FORCE_MULTIPLER__FOR_ANY_PURPOSE
#
#	return multiplied_lin - excess_from_arg






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

#

#func _play_particle_effect__counter_force_from_any_source(arg_applied_force_vec : Vector2):
#	var mag = arg_applied_force_vec.length()
#


#

func _on_body_entered__base_object(body_rid, body, body_shape_index, local_shape_index):
	var base_object : BaseObject = body
	
	if base_object.mode == MODE_STATIC:
		add_static_base_object_in_contact_with(base_object)
	
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
	
	if SingletonsAndConsts.current_game_elements.is_game_front_hud_initialized:
		_do_current_hud_actions__for_energy_init()
	else:
		SingletonsAndConsts.current_game_elements.connect("game_front_hud_initialized", self, "_on_game_front_hud_initialized__for_energy_panel", [], CONNECT_ONESHOT)
		
	

func _on_game_front_hud_initialized__for_energy_panel(arg_front_hud):
	_do_current_hud_actions__for_energy_init()

func _do_current_hud_actions__for_energy_init():
	SingletonsAndConsts.current_game_front_hud.energy_panel.set_player_modi__energy(player_modi__energy)
	
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
	block_player_game_actions_cond_clauses.attempt_insert_clause(BlockPlayerGameActionsClauseIds.NO_ENERGY)
	
	main_body_sprite.tween_modulate_of_basis(SingletonsAndConsts.PLAYER_MODULATE__ANY_PART__ENERGY_OFF, SingletonsAndConsts.PLAYER_MODULATE__ANY_PART__TRANSITION_DURATION)
	
	player_face.on_energy_discharged_to_zero()
	
	set_light_energy_mod_a__gradual(0.0)

func _update_self_based_on_has_energy__has_energy():
	block_player_move_left_and_right_cond_clauses.remove_clause(BlockPlayerMoveLeftAndRightClauseIds.NO_ENERGY)
	block_player_game_actions_cond_clauses.remove_clause(BlockPlayerGameActionsClauseIds.NO_ENERGY)
	
	main_body_sprite.tween_modulate_of_basis(SingletonsAndConsts.PLAYER_MODULATE__ANY_PART__ENERGY_ON, SingletonsAndConsts.PLAYER_MODULATE__ANY_PART__TRANSITION_DURATION)
	
	player_face.on_energy_restored_from_zero()
	
	set_light_energy_mod_a__gradual(1.0)


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
	
	if _is_pos_change_potentially_from_tileset:
		set_deferred("_is_pos_change_potentially_from_tileset", false)
	
	#print("diff: %s" % [(prev_pos_mag - curr_pos_mag) / delta])
	var diff = (prev_pos_mag - curr_pos_mag) / delta
	
	if prev_pos_mag > curr_pos_mag:  # from fast to slow
		#print("_pos_change_caused_by_tile: %s" % _pos_change_caused_by_tile)
		
		# for tiles
		if _pos_change_caused_by_tile:
			_play_tile_hit_sound__and_show_particles(diff)
		else:
			_is_pos_change_potentially_from_tileset = true
			_pos_change_potentially_from_tileset__diff = diff
		
		# for camera
		if diff > 220:
			var stress = diff / 220
			CameraManager.camera.add_stress(stress)
		
		#_use_prev_glob_pos_for_rewind = false
	
	
	_play_or_kill_speed_trail_based_on_curr_state(delta)
	
	emit_signal("pos_change__for_aesth_effects", curr_pos_mag, prev_pos_mag, diff, delta)


func _convert_num_to_ratio_using_num_range(arg_num, arg_min, arg_max, arg_minimum_ratio):
	var diff = arg_max - arg_min
	
	return max((arg_num - arg_min) / diff, arg_minimum_ratio)



#func _play_normal_to_ouch(arg_duration : float):
#	#var frame_count = anim_on_screen.frames.get_frame_count(FACE_ANIMATION_NAME__NORMAL_TO_OUCH)
#	#var fps = frame_count / arg_duration
#
#	#anim_on_screen.frames.set_animation_speed(FACE_ANIMATION_NAME__NORMAL_TO_OUCH, fps)
#	#anim_on_screen.play(FACE_ANIMATION_NAME__NORMAL_TO_OUCH)
#
#func _play_ouch_to_normal(arg_duration : float):
#	#var frame_count = anim_on_screen.frames.get_frame_count(FACE_ANIMATION_NAME__OUCH_TO_NORMAL)
#	#var fps = frame_count / arg_duration
#
#	#anim_on_screen.frames.set_animation_speed(FACE_ANIMATION_NAME__OUCH_TO_NORMAL, fps)
#	#anim_on_screen.play(FACE_ANIMATION_NAME__OUCH_TO_NORMAL)

#

func _play_tile_hit_sound__and_show_particles(diff):
	_pos_change_caused_by_tile = false
	_is_pos_change_potentially_from_tileset = false
	
	var cell_hit_sound_id = -1
	var volume_ratio : float
	if diff >= 100 and diff < 320:
		cell_hit_sound_id = TileConstants.get_sound_id_to_play_for_tile_hit(_last_cell_id, _last_cell_autocoord, false)
		volume_ratio = _convert_num_to_ratio_using_num_range(diff, 100, 320, 0.50)
		
	elif diff >= 320:
		cell_hit_sound_id = TileConstants.get_sound_id_to_play_for_tile_hit(_last_cell_id, _last_cell_autocoord, true)
		volume_ratio = 1
	
	
	#print("cell id: %s. sound_id: %s. vol_ratio: %s, diff: %s" % [_last_cell_id, cell_hit_sound_id, volume_ratio, diff])
	if cell_hit_sound_id != -1 and volume_ratio != 0:
		AudioManager.helper__play_sound_effect__2d(cell_hit_sound_id, _last_cell_global_pos, volume_ratio, null)
	
	##################
	
	_attempt_play_player_hit_particle(diff)

func _attempt_play_player_hit_particle(diff):
	if diff >= 100:
		var particle = player_hit_tile_particle_compo_pool.get_or_create_resource_from_pool()
		_configure_particle_position(particle)


func _configure_particle_position(arg_particle : AnimatedSprite):
	var curr_pos = global_position
	var tile_pos = _last_cell_global_pos
	
	var dist_to_edge = _base_player_size.x / 2  #or y, does not matter
	var particle_half_size = arg_particle.frames.get_frame("medium", 0).get_size()
	
	var pos_modification = Vector2(0, (dist_to_edge - particle_half_size.y))
	
	
	var cleaned_up_angle = _clean_up_angle__perfect_translated_for_circle_partition(curr_pos.angle_to_point(tile_pos)) + (PI/2)
	pos_modification = pos_modification.rotated(cleaned_up_angle)
	
	arg_particle.global_position = global_position + pos_modification
	arg_particle.rotation = cleaned_up_angle
	

# Particles related

func _create_player_hit_tile_particle__for_pool():
	var particle = PlayerParticle_HitTile_Scene.instance()
	particle.modulate.a = 0.8
	
	return particle

#func _create_counterforce_blast_particle__for_pool():
#	var particle #= 
#	particle.modulate.a = 0.8
#
#	return particle


#

func set_current_health(arg_val, emit_health_breakpoint_signals : bool = true):
	#if SingletonsAndConsts.current_game_result_manager.is_game_result_decided:
	#	return
	
	if last_calculated_is_block_health_change:
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
	
	
	if old_val != _current_robot_health:
		_update_self_based_on_has_robot_health()
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



func is_robot_alive() -> bool:
	return !_is_robot_dead #!is_zero_approx(_current_robot_health)

#

func _update_self_based_on_has_robot_health():
	if _current_robot_health <= 0:
		if !_is_robot_dead:
			_is_robot_dead = true
			stop_player_movement()
			_deferred_create_break_fragments()
		
		visible = false
		
		block_player_move_left_and_right_cond_clauses.attempt_insert_clause(BlockPlayerMoveLeftAndRightClauseIds.NO_ROBOT_HEALTH)
		block_player_game_actions_cond_clauses.attempt_insert_clause(BlockPlayerGameActionsClauseIds.NO_ROBOT_HEALTH)
		
		disable_player_collision_cond_clauses.attempt_insert_clause(DisablePlayerCollisionMarkClauseIds.IS_ROBOT_DEAD)
		
	else:
		_is_robot_dead = false
		visible = true
		
		block_player_move_left_and_right_cond_clauses.remove_clause(BlockPlayerMoveLeftAndRightClauseIds.NO_ROBOT_HEALTH)
		block_player_game_actions_cond_clauses.remove_clause(BlockPlayerGameActionsClauseIds.NO_ROBOT_HEALTH)
		
		disable_player_collision_cond_clauses.remove_clause(DisablePlayerCollisionMarkClauseIds.IS_ROBOT_DEAD)
		


#todoimp continue player break fragments. after testing for baseenemy
func _deferred_create_break_fragments():
	pass
	
	

func _init_break_fragments__from_body():
	pass
	

func _init_break_fragments__from_screen_face():
	pass
	
	



##

func get_momentum__using_linear_velocity() -> Vector2:
	return linear_velocity * last_calculated_object_mass

func get_momentum_mag__using_linear_velocity() -> float:
	return (linear_velocity * last_calculated_object_mass).length()

################

func set_can_capture_PCA_regions(arg_val):
	var old_val = can_capture_PCA_regions
	can_capture_PCA_regions = arg_val
	
	if old_val != can_capture_PCA_regions:
		emit_signal("can_capture_PCA_regions_changed", can_capture_PCA_regions)


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
				
				
				_start_audio_player__capturing_point()
				
			else:
				_on_PCA_region_area_captured()
				
		
	else:
		_attempt_end_audio_player__capturing_point()

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
		_attempt_end_audio_player__capturing_point()

func _stop_pca_progress_drawer():
	pca_progress_drawer.visible = false
	pca_progress_drawer.set_is_enabled(false)
#
#	if is_instance_valid(_current_player_capture_area_region):
#		_disconnect_curr_area_region_signals()
#
#	_current_player_capture_area_region = null


func _on_PCA_region_area_captured():
	_stop_pca_progress_drawer()
	pca_captured_drawer.play_captured_anim__for_PCA(_current_player_capture_area_region)
	
	set_current_player_capture_area_region(null)
	
	#
	
	AudioManager.helper__play_sound_effect__plain(StoreOfAudio.AudioIds.SFX_CapturePoint_Captured_02, 1.0, null)

##

func _start_audio_player__capturing_point():
	var play_adv_param = AudioManager.construct_play_adv_params()
	play_adv_param.is_audio_looping = true
	
	_audio_player__capturing_point = AudioManager.helper__play_sound_effect__plain(StoreOfAudio.AudioIds.SFX_CapturePoint_Capturing, 1.0, play_adv_param)
	if !can_capture_PCA_regions:
		_audio_player__capturing_point.volume_db = AudioManager.DECIBEL_VAL__INAUDIABLE

func _attempt_end_audio_player__capturing_point():
	if _audio_player__capturing_point != null and _audio_player__capturing_point.playing:
		AudioManager.stop_stream_player_and_mark_as_inactive(_audio_player__capturing_point)
		_audio_player__capturing_point = null



func _attempt_linear_mute_capture_pca_region_audio_player():
	if is_instance_valid(_audio_player__capturing_point):
		AudioManager.helper__linearly_set_current_player_db_to_inaudiable(_audio_player__capturing_point, 0.5)

func _attempt_linear_unmute_capture_pca_region_audio_player():
	if is_instance_valid(_audio_player__capturing_point):
		AudioManager.helper__linearly_set_player_db_to_audiable(_audio_player__capturing_point, StoreOfAudio.AudioIds.SFX_CapturePoint_Capturing, 0.5)
	


#

func set_light_color(arg_color):
	_light_color = arg_color
	if is_inside_tree():
		light_2d.color = _light_color

func _initialize_player_light():
	#var light_gradient : Gradient = LightTextureConstructor.construct_or_get_gradient_two_color(Color(1, 1, 1, 0.5), Color(1, 1, 1, 0.0), false)
	
	var color_light = Color(1, 1, 1, 0.32)
	var color_light_dim = Color(1, 1, 1, 0.16)
	var color_none = Color(0, 0, 0, 0)
	var arr = [color_light, color_light, color_light_dim, color_none, color_none]
	var light_gradient = LightTextureConstructor.construct_or_get_gradient_x_color__no_save(arr)
	
	var light_texture_rect : GradientTexture2D = LightTextureConstructor.construct_or_get_rect_gradient_texture(DEFAULT_LIGHT_TEX_REC_SIZE, false)
	
	light_texture_rect.gradient = light_gradient
	light_2d.texture = light_texture_rect
	
	##
	
	set_light_color(_light_color)
	set_light_energy(_light_energy)



func set_light_energy(arg_val):
	_light_energy = arg_val
	
	light_2d.energy = _light_energy

func set_light_energy__tween(arg_val, arg_duration):
	_light_energy = arg_val
	
	var tween = create_tween()
	tween.tween_property(light_2d, "energy", _light_energy, arg_duration)


func light_energy_mod_a__get_cleaned_val(arg_val):
	if arg_val > 1:
		arg_val = 1
	if arg_val < 0:
		arg_val = 0
	
	return arg_val


func set_light_energy_mod_a__gradual(arg_val):
	_light_2d__target_mod_a = arg_val

func set_light_energy_mod_a(arg_val):
	if !is_equal_approx(_light_2d__target_mod_a, -1):
		light_2d.color.a = arg_val
		
		emit_signal("light_2d_mod_a_changed", arg_val)

func get_light_energy_mod_a():
	return light_2d.color.a

#

func add_static_base_object_in_contact_with(arg_obj):
	if !_static_base_objects_in_contact_with.has(arg_obj):
		#print("added static in contact with")
		_static_base_objects_in_contact_with.append(arg_obj)
		
		if !arg_obj.is_connected("body_mode_changed__not_from_rewind", self, "_on_body_mode_changed__not_from_rewind"):
			arg_obj.connect("body_mode_changed__not_from_rewind", self, "_on_body_mode_changed__not_from_rewind", [arg_obj])

func _on_body_mode_changed__not_from_rewind(arg_mode, arg_body):
	if arg_body.mode != MODE_RIGID:
		attempt_remove_static_base_objects_in_contact_with(arg_body)


func attempt_remove_static_base_objects_in_contact_with(arg_obj):
	if _static_base_objects_in_contact_with.has(arg_obj):
		#print("removed static in contact with")
		
		_static_base_objects_in_contact_with.erase(arg_obj)
		
		if arg_obj.is_connected("body_mode_changed__not_from_rewind", self, "_on_body_mode_changed__not_from_rewind"):
			arg_obj.disconnect("body_mode_changed__not_from_rewind", self, "_on_body_mode_changed__not_from_rewind")


#func _is_any_static_body_impeding_movement(arg_mov : Vector2):
##	if linear_velocity.length() < 1.0:
##		if _static_base_objects_in_contact_with.size() != 0:
##			return true
#
#	if arg_mov.length() > 0.0:
#		var direction_of_counter_mov : Vector2 = arg_mov#.rotated(PI)#.normalized()
#
#		for body in _static_base_objects_in_contact_with:
#			var angle_to_body : float = global_position.angle_to_point(body.global_position)
#
#			print("angle to body: %s, %s, %s" % [(abs(direction_of_counter_mov.angle() - angle_to_body)), direction_of_counter_mov.angle(), angle_to_body])
#
#			var diff = abs(direction_of_counter_mov.angle() - angle_to_body)
#			if diff <= PI/12 or diff >= 13*2*PI/14:
#				print("true")
#				return true
#
#	#print("ret false. lin_vel_is_zero: %s, length: %s" % [is_zero_approx(linear_velocity.length()), linear_velocity.length()])
#	return false

#

func set_is_show_lines_to_uncaptured_player_capture_regions(arg_val):
	is_show_lines_to_uncaptured_player_capture_regions = arg_val
	
	pca_line_direction_drawer.is_show_lines_to_uncaptured_player_capture_regions = arg_val



#

func get_base_player_size():
	return _base_player_size

func get_player_radius():
	return _base_player_size.x


##################

func _initialize_speed_trail_component():
	speed_trail_component = MultipleTrailsForNodeComponent.new()
	speed_trail_component.node_to_host_trails = SingletonsAndConsts.current_game_elements.player_container
	speed_trail_component.trail_type_id = StoreOfTrailType.BASIC_TRAIL
	speed_trail_component.connect("on_trail_before_attached_to_node", self, "_speed_trail_before_attached_to_self")
	#speed_trail_component.custom_func_name_for_adding_trail_as_child = "_add_speed_trail__as_child"
	
	_attempt_create_curr_speed_trail()

#func _add_speed_trail__as_child(arg_trail):
#	add_child(arg_trail)
#	#move_child(arg_trail, 0)

func _attempt_create_curr_speed_trail():
	if !is_instance_valid(_current_speed_trail):
		_current_speed_trail = speed_trail_component.create_trail_for_node(self)
	

func _speed_trail_before_attached_to_self(arg_trail, arg_self):
	arg_trail.max_trail_length = SPEED_TRAIL_LENGTH_01
	arg_trail.trail_color = SPEED_TRAIL_COLOR
	arg_trail.width = 34
	
	_current_speed_trail = arg_trail


func _play_or_kill_speed_trail_based_on_curr_state(delta):
	var speed = linear_velocity.length()
	if speed >= SPEED_TRAIL_SPEED_TRIGGER:
		_attempt_create_curr_speed_trail()
		_current_speed_trail.can_add_points = true
		
		#var length_variation = round(1 * sin(_current_speed_trail__duration))
		
		if speed >= SPEED_TRAIL_SPEED_TRIGGER_02:
			_current_speed_trail.max_trail_length = SPEED_TRAIL_LENGTH_02 #+ length_variation 
		else:
			_current_speed_trail.max_trail_length = SPEED_TRAIL_LENGTH_01 #+ length_variation
		
		#_current_speed_trail__duration += delta
		
	else:
		if is_instance_valid(_current_speed_trail):
			_current_speed_trail.max_trail_length = 0
			_current_speed_trail.can_add_points = false
		#_attempt_destroy_current_speed_trail()

func _attempt_destroy_current_speed_trail():
	if is_instance_valid(_current_speed_trail):
		_current_speed_trail.queue_free()
	


######
## tile fragment sound
#
#func request_play_tile_fragment_sound(arg_tile_fragment : Node2D):
#	pass
#


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

var _rewinded__block_player_move_left_and_right_cond_clauses
var _rewinded__block_player_game_actions_cond_clauses
var _rewinded__block_rotate_cond_clause
var _rewinded__ignore_outside_induced_forces_cond_clauses

var _rewinded__can_capture_PCA_regions

var _most_recent_rewind_state


# FOR stage02 special
var _save_rewind_save_state_of_any_nodes : bool = true

#var _override__all_nodes_to_rotate_with_cam : Array
#var _override__objects_to_not_collide_with : Array
#var _override__objects_to_collide_with_after_exit : Array
#var _override__objects_to_add_mask_layer_collision_after_exit : Array


#var _rewinded__current_player_left_right_move_speed
#var _rewinded__current_player_left_right_move_speed__from_last_integrate_forces


#func _ready__include_relevant_objs_for_rewind():
#	_include_obj_for_rewind_manager(block_player_move_left_and_right_cond_clauses)
#	_include_obj_for_rewind_manager(block_rotate_cond_clause)
#	_include_obj_for_rewind_manager(ignore_outside_induced_forces_cond_clauses)
#
#func _include_obj_for_rewind_manager(arg_obj):
#	SingletonsAndConsts.current_rewind_manager.add_to_rewindables(arg_obj)
#


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
		
		"is_player_modi_energy_set" : is_player_modi_energy_set,
		"player_modi__energy_save_state" : null,
		
		"no_energy_consecutive_duration" : _no_energy_consecutive_duration,
		
		"max_health" : _max_health,
		"current_health" : _current_health,
		#"is_dead" : _i
		
		"current_robot_health" : _current_robot_health,
		#"max_robot_health" : _max_robot_health,
		
		"rotating_for_floor_area_2d.rotation" : rotating_for_floor_area_2d.rotation,
		
		###
		
		"block_player_move_left_and_right_cond_clauses" : block_player_move_left_and_right_cond_clauses.get_rewind_save_state(),
		"block_player_game_actions_cond_clauses" : block_player_game_actions_cond_clauses.get_rewind_save_state(),
		"block_rotate_cond_clause" : block_rotate_cond_clause.get_rewind_save_state(),
		"ignore_outside_induced_forces_cond_clauses" : ignore_outside_induced_forces_cond_clauses.get_rewind_save_state(),
		
		"can_capture_PCA_regions" : can_capture_PCA_regions,
		"_light_2d__target_mod_a" : _light_2d__target_mod_a,
		
		#"all_nodes_to_rotate_with_cam" : _all_nodes_to_rotate_with_cam.duplicate(true),
		#"objects_to_not_collide_with" : _objects_to_not_collide_with.duplicate(true),
		#"objects_to_collide_with_after_exit" : _objects_to_collide_with_after_exit.duplicate(true),
		#"objects_to_add_mask_layer_collision_after_exit" : _objects_to_add_mask_layer_collision_after_exit.duplicate(true),
		
	}
	
	if is_player_modi_energy_set:
		save_state["player_modi__energy_save_state"] = player_modi__energy.get_rewind_save_state()
	
	
	save_state["_save_rewind_save_state_of_any_nodes"] = _save_rewind_save_state_of_any_nodes
	
	if _save_rewind_save_state_of_any_nodes:
		#"all_nodes_to_rotate_with_cam" : _all_nodes_to_rotate_with_cam.duplicate(true),
		#"objects_to_not_collide_with" : _objects_to_not_collide_with.duplicate(true),
		#"objects_to_collide_with_after_exit" : _objects_to_collide_with_after_exit.duplicate(true),
		#"objects_to_add_mask_layer_collision_after_exit" : _objects_to_add_mask_layer_collision_after_exit.duplicate(true),
		save_state["_all_nodes_to_rotate_with_cam"] = _all_nodes_to_rotate_with_cam.duplicate(true)
		save_state["_objects_to_not_collide_with"] = _objects_to_not_collide_with.duplicate(true)
		save_state["_objects_to_collide_with_after_exit"] = _objects_to_collide_with_after_exit.duplicate(true)
		save_state["_objects_to_add_mask_layer_collision_after_exit"] = _objects_to_add_mask_layer_collision_after_exit.duplicate(true)
		
	else:
		save_state["_all_nodes_to_rotate_with_cam"] = []
		save_state["_objects_to_not_collide_with"] = []
		save_state["_objects_to_collide_with_after_exit"] = []
		save_state["_objects_to_add_mask_layer_collision_after_exit"] = []
		
	
	return save_state

# FOR Special01_02
func __remove_nodes_from_save_state(save_state : Dictionary):
	save_state["_all_nodes_to_rotate_with_cam"].clear()
	save_state["_objects_to_not_collide_with"].clear()
	save_state["_objects_to_collide_with_after_exit"].clear()
	save_state["_objects_to_add_mask_layer_collision_after_exit"].clear()

func __map_save_state_map_nodes_with_own_nodes(save_state : Dictionary):
	save_state["_all_nodes_to_rotate_with_cam"] = _all_nodes_to_rotate_with_cam.duplicate(true)
	save_state["_objects_to_not_collide_with"] = _objects_to_not_collide_with.duplicate(true)
	save_state["_objects_to_collide_with_after_exit"] = _objects_to_collide_with_after_exit.duplicate(true)
	save_state["_objects_to_add_mask_layer_collision_after_exit"] = _objects_to_add_mask_layer_collision_after_exit.duplicate(true)
	

# END Of FOR Special01_02

func load_into_rewind_save_state(arg_state):
	_rewinded__angular_velocity = arg_state["angular_velocity"]
	_rewinded__linear_velocity = arg_state["linear_velocity"]
	_rewinded__sleeping = arg_state["sleeping"]
	_rewinded__transform = arg_state["transform"]
	
	_rewinded__block_player_move_left_and_right_cond_clauses = arg_state["block_player_move_left_and_right_cond_clauses"]
	_rewinded__block_player_game_actions_cond_clauses = arg_state["block_player_game_actions_cond_clauses"]
	_rewinded__block_rotate_cond_clause = arg_state["block_rotate_cond_clause"]
	_rewinded__ignore_outside_induced_forces_cond_clauses = arg_state["ignore_outside_induced_forces_cond_clauses"]
	
	_rewinded__can_capture_PCA_regions = arg_state["can_capture_PCA_regions"]
	
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
	
	set_light_energy_mod_a(arg_state["_light_2d__target_mod_a"])


func destroy_from_rewind_save_state():
	print("PLAYER: destroy_from_rewind_save_state should never be reached...")
	

func restore_from_destroyed_from_rewind():
	pass
	

func started_rewind():
	mode = RigidBody2D.MODE_STATIC
	#collision_shape.set_deferred("disabled", true)
	#floor_area_2d_coll_shape.set_deferred("disabled", true)
	#rotating_for_floor_area_2d_coll_shape.set_deferred("disabled", true)
	disable_player_collision_cond_clauses.attempt_insert_clause(DisablePlayerCollisionMarkClauseIds.REWINDING)
	
	_attempt_destroy_current_speed_trail()

func ended_rewind():
	_ignore_next_current_player_left_right_move_reset = true
	
	#
	
	mode = RigidBody2D.MODE_CHARACTER
	#collision_shape.set_deferred("disabled", false)
	#floor_area_2d_coll_shape.set_deferred("disabled", false)
	#rotating_for_floor_area_2d_coll_shape.set_deferred("disabled", false)
	disable_player_collision_cond_clauses.remove_clause(DisablePlayerCollisionMarkClauseIds.REWINDING)
	
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
	
	
	###
	
	var override_specific_nodes = _most_recent_rewind_state["_save_rewind_save_state_of_any_nodes"]
	#if !override_specific_nodes:
	_all_nodes_to_rotate_with_cam.clear()
	_all_nodes_to_rotate_with_cam.append_array(_most_recent_rewind_state["_all_nodes_to_rotate_with_cam"])
	
	_objects_to_not_collide_with.clear()
	for obj in _most_recent_rewind_state["_objects_to_not_collide_with"]:
		add_object_to_not_collide_with(obj)
	
	_objects_to_collide_with_after_exit.clear()
	for obj in _most_recent_rewind_state["_objects_to_collide_with_after_exit"]:
		add_objects_to_collide_with_after_exit(obj)
	
	_objects_to_add_mask_layer_collision_after_exit.clear()
	for obj in _most_recent_rewind_state["_objects_to_add_mask_layer_collision_after_exit"]:
		add_objects_to_add_mask_layer_collision_after_exit(obj)
	
	
#	else:
#		_all_nodes_to_rotate_with_cam.clear()
#		_all_nodes_to_rotate_with_cam.append(_override__all_nodes_to_rotate_with_cam)
#
#		_objects_to_not_collide_with.clear()
#		for obj in _override__objects_to_not_collide_with:
#			add_object_to_not_collide_with(obj)
#
#		_objects_to_collide_with_after_exit.clear()
#		for obj in _override__objects_to_collide_with_after_exit:
#			add_objects_to_collide_with_after_exit(obj)
#
#		_objects_to_add_mask_layer_collision_after_exit.clear()
#		for obj in _override__objects_to_add_mask_layer_collision_after_exit:
#			add_objects_to_add_mask_layer_collision_after_exit(obj)
#
	
	###
	
	is_player_modi_energy_set = _most_recent_rewind_state["is_player_modi_energy_set"]
	
	rotating_for_floor_area_2d.rotation = _most_recent_rewind_state["rotating_for_floor_area_2d.rotation"]
	
	#
	
	block_player_move_left_and_right_cond_clauses.load_into_rewind_save_state(_rewinded__block_player_move_left_and_right_cond_clauses)
	block_player_game_actions_cond_clauses.load_into_rewind_save_state(_rewinded__block_player_game_actions_cond_clauses)
	block_rotate_cond_clause.load_into_rewind_save_state(_rewinded__block_rotate_cond_clause)
	ignore_outside_induced_forces_cond_clauses.load_into_rewind_save_state(_rewinded__ignore_outside_induced_forces_cond_clauses)
	
	can_capture_PCA_regions = _rewinded__can_capture_PCA_regions

func _on_rewind_manager__ended_rewind__iterated_over_all():
	_update_last_calc_can_move_left_and_right()
	_update_last_calc_is_rotate_ready()
	_update_last_calc_ignore_outside_induced_forces()
	
	
