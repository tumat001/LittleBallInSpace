extends RigidBody2D


const ConditionalClauses = preload("res://MiscRelated/ClauseRelated/ConditionalClauses.gd")

#

signal destroyed_self_caused_by_destroying_area_region(arg_area_region)

signal last_calculated_object_mass_changed(arg_val)

signal body_mode_changed__not_from_rewind(arg_new_mode)

#

var base_object_mass : float = 20.0 setget set_base_object_mass
var _flat_mass_id_to_amount_map : Dictionary
var last_calculated_object_mass : float


enum BlockCollisionWithPlayerClauseIds {
	BLOCK_UNTIL_EXIT_PLAYER = 1
	TILE_FRAGMENT__DURATION_DELAY = 2
	IS_TILE_FRAGMENT = 3
}
var block_can_collide_with_player_cond_clauses : ConditionalClauses
var last_calculated_can_collide_with_player : bool

#

enum BodyMode {
	RIGID = RigidBody2D.MODE_RIGID,
	STATIC = RigidBody2D.MODE_STATIC,
	CHARACTER = RigidBody2D.MODE_CHARACTER,
	KINEMATIC = RigidBody2D.MODE_KINEMATIC,
}
export(BodyMode) var body_mode_to_use : int = RigidBody2D.MODE_RIGID setget set_body_mode_to_use 

#

var is_class_type_base_object : bool = true

#


var has_finite_lifespan : bool = false
# determined at start (before ready)
var current_lifespan : float = -1

#

onready var anim_sprite = $AnimatedSprite

onready var collision_shape = $CollisionShape2D

##

func set_body_mode_to_use(arg_mode):
	body_mode_to_use = arg_mode
	
	if is_inside_tree():
		if !SingletonsAndConsts.current_rewind_manager.is_rewinding:
			mode = body_mode_to_use
			emit_signal("body_mode_changed__not_from_rewind", mode)

#

func _init():
	_update_last_calculated_object_mass()
	_init_block_can_collide_with_player_cond_clauses()

func _init_block_can_collide_with_player_cond_clauses():
	block_can_collide_with_player_cond_clauses = ConditionalClauses.new()
	block_can_collide_with_player_cond_clauses.connect("clause_inserted", self, "_on_block_can_collide_with_player_cond_clauses_updated")
	block_can_collide_with_player_cond_clauses.connect("clause_removed", self, "_on_block_can_collide_with_player_cond_clauses_updated")
	_update_last_calculated_can_collide_with_player()


func _on_block_can_collide_with_player_cond_clauses_updated(arg_clause):
	_update_last_calculated_can_collide_with_player()

func _update_last_calculated_can_collide_with_player():
	last_calculated_can_collide_with_player = block_can_collide_with_player_cond_clauses.is_passed
	
	if last_calculated_can_collide_with_player:
		set_collision_mask_bit(0, true)
	else:
		set_collision_mask_bit(0, false)



#

func _ready():
	SingletonsAndConsts.current_rewind_manager.add_to_rewindables(self)
	
	set_body_mode_to_use(body_mode_to_use)

#

func set_base_object_mass(arg_mass):
	base_object_mass = arg_mass
	_update_last_calculated_object_mass()


func _update_last_calculated_object_mass():
	var total = base_object_mass
	for amount_mass in _flat_mass_id_to_amount_map:
		total += amount_mass
	
	last_calculated_object_mass = total
	mass = last_calculated_object_mass
	emit_signal("last_calculated_object_mass_changed", last_calculated_object_mass)

#

func set_texture_in_anim_sprite__first_time(arg_texture : Texture, arg_create_shape : bool):
	anim_sprite.frames = SpriteFrames.new()
	anim_sprite.frames.add_frame("default", arg_texture)
	
	var shape = RectangleShape2D.new()
	shape.extents = arg_texture.get_size() / 2
	collision_shape.set_deferred("shape", shape)
	
	return shape

#

#func add_player_coll_mask():
#	set_collision_mask_bit(0, true)
#
#
#func remove_player_coll_mask():
#	set_collision_mask_bit(0, false)
#


####

func calculate_momentum():
	return linear_velocity * last_calculated_object_mass


####

func _on_BaseObject_body_entered(body):
	pass
	

####

func destroy_self_caused_by_destroying_area_region(arg_region):
	emit_signal("destroyed_self_caused_by_destroying_area_region", arg_region)
	
	queue_free()


func _process(delta):
	if !SingletonsAndConsts.current_rewind_manager.is_rewinding:
		if has_finite_lifespan:
			current_lifespan -= delta
			
			if current_lifespan <= 0 and !is_dead_but_reserved_for_rewind:
				queue_free()
		

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
var _rewinded__block_can_collide_with_player_cond_clauses_save_state

#

func queue_free():
	if SingletonsAndConsts.current_rewind_manager.is_obj_registered_in_rewindables(self):
		if !is_dead_but_reserved_for_rewind:
			if !SingletonsAndConsts.current_rewind_manager.is_connected("obj_removed_from_rewindables", self, "_on_obj_removed_from_rewindables"):
				SingletonsAndConsts.current_rewind_manager.connect("obj_removed_from_rewindables", self, "_on_obj_removed_from_rewindables")
			
			collision_shape.set_deferred("disabled", true)
			visible = false
			is_dead_but_reserved_for_rewind = true
		
	else:
		if !is_queued_for_deletion():
			.queue_free()
		

func _on_obj_removed_from_rewindables(arg_obj):
	if arg_obj == self:
		if !is_queued_for_deletion():
			.queue_free()



func get_rewind_save_state():
	var state : Physics2DDirectBodyState = Physics2DServer.body_get_direct_state(get_rid())
	return {
		"angular_velocity" : state.angular_velocity,
		"linear_velocity" : state.linear_velocity,
		"sleeping" : state.sleeping,
		"transform" : state.transform,
		
		"block_can_collide_with_player_cond_clauses_save_state" : block_can_collide_with_player_cond_clauses.get_rewind_save_state(),
		
		"current_lifespan" : current_lifespan,
	}
	

func load_into_rewind_save_state(arg_state):
	_rewinded__angular_velocity = arg_state["angular_velocity"]
	_rewinded__linear_velocity = arg_state["linear_velocity"]
	_rewinded__sleeping = arg_state["sleeping"]
	_rewinded__transform = arg_state["transform"]
	_rewinded__block_can_collide_with_player_cond_clauses_save_state = arg_state["block_can_collide_with_player_cond_clauses_save_state"]
	
	current_lifespan = arg_state["current_lifespan"]
	
	#
	global_position = _rewinded__transform.origin


func destroy_from_rewind_save_state():
	.queue_free()
	

func restore_from_destroyed_from_rewind():
	#collision_shape.set_deferred("disabled", false)
	visible = true
	is_dead_but_reserved_for_rewind = false


func stared_rewind():
	mode = RigidBody2D.MODE_STATIC
	collision_shape.set_deferred("disabled", true)
	

func ended_rewind():
	if !is_dead_but_reserved_for_rewind:
		mode = body_mode_to_use
		
		block_can_collide_with_player_cond_clauses.load_into_rewind_save_state(_rewinded__block_can_collide_with_player_cond_clauses_save_state)
		
		collision_shape.set_deferred("disabled", false)
		
		_use_integ_forces_new_vals = true
	



func _integrate_forces(state):
	if _use_integ_forces_new_vals:
		state.angular_velocity = _rewinded__angular_velocity
		state.linear_velocity = _rewinded__linear_velocity
		state.sleeping = _rewinded__sleeping
		state.transform = _rewinded__transform
		
		_use_integ_forces_new_vals = false


