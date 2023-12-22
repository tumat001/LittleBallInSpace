extends "res://ObjectsRelated/Objects/BaseObject.gd"


#

var texture_to_use__fragment : Texture   #note: if err: this has been changed from atlastexture to texture

var tileset_id : int = -1
var object_fragment_representation_id : int = -1

#var player
#var _is_inside_player

var bodies_inside_self : Array
var _entering_velocity : Vector2

var _is_from_rewind__frame_count : int

#

var is_class_type_object_tile_fragment : bool = true

#const TOTAL_DURATION_TO_WAIT_BEFORE_DESPAWN : float = 30.0
#const WAIT_BEFORE_DESPAWN__TIME_INTERVAL_FOR_CHECK : float = 5.0
#const DIST_FROM_PLAYER_TO_INCREMENT_WAIT_DURATION : float = 1500.0
#var _curr_duration_of_wait_before_despawn : float

#

const PLAY_HIT_SOUND_COOLDOWN : float = 2.0
var _player_hit_sound_cooldown : float

#

var _collision_sound_list_initialized : bool
var _collision_sound_list

#

onready var player_soft_area_2d = $PlayerSoftArea2D
onready var player_soft_coll_shape = $PlayerSoftArea2D/CollisionShape2D

#var _current_delay_before_collidable_with_player : float = 2.5
#var _can_collide_with_player__from_delay : bool = true  # leave it this way


func _ready():
	_player_hit_sound_cooldown = PLAY_HIT_SOUND_COOLDOWN
	
	#
	
	if texture_to_use__fragment != null:
		var shape = set_texture_in_anim_sprite__first_time(texture_to_use__fragment, true)
		
		player_soft_coll_shape.set_deferred("shape", shape)
	
	block_can_collide_with_player_cond_clauses.attempt_insert_clause(BlockCollisionWithPlayerClauseIds.IS_TILE_FRAGMENT)
	
	#set_current_delay_before_collidable_with_player(_current_delay_before_collidable_with_player)
	
	add_to_group(SingletonsAndConsts.GROUP_NAME__OBJECT_TILE_FRAGMENT)
	
	#_ready__setup_for_rewind()

#func _process(delta):
#	set_current_delay_before_collidable_with_player(_current_delay_before_collidable_with_player - delta)
#
#
#func set_current_delay_before_collidable_with_player(arg_val):
#	_current_delay_before_collidable_with_player = arg_val
#
#	if _current_delay_before_collidable_with_player <= 0 and !_can_collide_with_player__from_delay:
#		_can_collide_with_player__from_delay = true
#		block_can_collide_with_player_cond_clauses.remove_clause(BlockCollisionWithPlayerClauseIds.TILE_FRAGMENT__DURATION_DELAY)
#
#	elif _current_delay_before_collidable_with_player > 0 and _can_collide_with_player__from_delay:
#		_can_collide_with_player__from_delay = false
#		block_can_collide_with_player_cond_clauses.attempt_insert_clause(BlockCollisionWithPlayerClauseIds.TILE_FRAGMENT__DURATION_DELAY)
#
#




func _on_PlayerSoftArea2D_body_entered(body):
	#if body.get("is_player"):
	#	#player = body
		if !bodies_inside_self.has(body):
			bodies_inside_self.append(body)
		
		
		if _is_from_rewind__frame_count == 0:
			var pushback = 2.5 * last_calculated_object_mass #75
			var dir = global_position.angle_to_point(body.global_position)
			var force = Vector2(pushback, 0).rotated(dir)
			
			var lin_vel : Vector2= body.linear_velocity
			lin_vel.limit_length(3.333 * last_calculated_object_mass)
			
			apply_central_impulse(force + lin_vel)
			
			#body.request_play_tile_fragment_sound(self)
			_attempt_play_colliding_sound()


func _attempt_play_colliding_sound():
	if _player_hit_sound_cooldown <= 0:
		_player_hit_sound_cooldown = PLAY_HIT_SOUND_COOLDOWN
		
		_attempt_init_collision_sound_list()
		
		if _collision_sound_list.size() != 0:
			var sound_id_to_play = _get_rand_sound_id_to_play()
			AudioManager.helper__play_sound_effect__2d(sound_id_to_play, global_position, 1, null, AudioManager.MaskLevel.Minor_SoundFX)

func _attempt_init_collision_sound_list():
	if !_collision_sound_list_initialized:
		_collision_sound_list_initialized = true
		
		if tileset_id != -1:
			_collision_sound_list = TileConstants.get_tile_id_to_fragment_collision_sound_list(tileset_id)
		elif object_fragment_representation_id != -1:
			_collision_sound_list = StoreOfObjects.get_object_id_to_fragment_collision_sound_list(object_fragment_representation_id)
		else:
			_collision_sound_list = []

func _get_rand_sound_id_to_play():
	var rng = SingletonsAndConsts.non_essential_rng
	return StoreOfRNG.randomly_select_one_element(_collision_sound_list, rng)
	

#

func _physics_process(delta):
#	if _is_inside_player:
#		var dist = global_position.distance_to(player.global_position)
#		#var pushback = 40000 + (80000 * (1 - _convert_result_into_ratio_using_num_range(dist, 0, player.get_player_radius())))
#		var pushback = (5 / 30.0) * last_calculated_object_mass #5 #+ (5 * (1 - _convert_result_into_ratio_using_num_range(dist, 0, player.get_player_radius())))
#
#		var dir = global_position.angle_to_point(player.global_position)
#		var force = Vector2(pushback, 0).rotated(dir)
#		add_central_force(force)
#
#		#print(force)
#		#print("--")
	
	if _is_from_rewind__frame_count > 0:
		_is_from_rewind__frame_count -= 1
	elif _is_from_rewind__frame_count < 0:
		_is_from_rewind__frame_count = 0
	
	
	if _player_hit_sound_cooldown > 0:
		_player_hit_sound_cooldown -= delta


#

func _convert_ratio_using_num_range(arg_ratio, arg_min, arg_max):
	var diff = arg_max - arg_min
	
	return arg_min + (diff * arg_ratio)

func _convert_result_into_ratio_using_num_range(arg_result, arg_min, arg_max):
	return (arg_result - arg_min) / (arg_max - arg_min)


####

func _on_PlayerSoftArea2D_body_exited(body):
	#if body.get("is_player"):
	#	_is_inside_player = false
	if bodies_inside_self.has(body):
		bodies_inside_self.erase(body)
		

###################### 
# REWIND RELATED
#####################

#var _rewinded__curr_duration_of_wait_before_despawn

# we need to listen for queue free of this thing so no

#var _lin_vel_on_rewind_started : Vector2
#var _rotation_on_rewind_started : float
#
#func _init():
#	is_rewindable = false
#
#func _init_rewind_variable_history():
#	is_rewindable = false
#
#
#
#func _ready__setup_for_rewind():
#	var rewind_manager = SingletonsAndConsts.current_rewind_manager
#	rewind_manager.connect("rewinding_started", self, "_on_rewinding_started__tf")
#	rewind_manager.connect("done_ending_rewind", self, "_on_done_ending_rewind__tf")
#
#
#func _on_rewinding_started__tf():
#	player_soft_coll_shape.set_deferred("disabled", true)
#
#	_lin_vel_on_rewind_started = linear_velocity
#	_rotation_on_rewind_started = rotation
#
#	linear_velocity = Vector2(0, 0)
#
#func _on_done_ending_rewind__tf():
#	collision_shape.set_deferred("disabled", false)
#
#	linear_velocity = _lin_vel_on_rewind_started
#	rotation = _rotation_on_rewind_started



func queue_free():
	#force_queue_free_past_rewind_rules()
	.queue_free()
	
	if SingletonsAndConsts.current_rewind_manager.is_obj_registered_in_rewindables(self):
		player_soft_coll_shape.set_deferred("disabled", true)



func started_rewind():
	.started_rewind()

	player_soft_coll_shape.set_deferred("disabled", true)


func ended_rewind():
	#.ended_rewind()
	if !is_dead_but_reserved_for_rewind:
		mode = body_mode_to_use
		
		collision_shape.set_deferred("disabled", false)
		
		#_use_integ_forces_new_vals = true
		
		player_soft_coll_shape.set_deferred("disabled", false)
	
	_is_from_rewind__frame_count = 2





func get_rewind_save_state():
	return {
		"current_lifespan" : current_lifespan,
	}


func load_into_rewind_save_state(arg_state):
	current_lifespan = arg_state["current_lifespan"]



