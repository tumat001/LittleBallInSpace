extends RigidBody2D

const PhysicsHelperClass = preload("res://MiscRelated/HelperClasses/PhysicsHelperClass.gd")

#

signal last_calculated_object_mass_changed(arg_val)

#

var base_object_mass : float = 20.0 setget set_base_object_mass
var _flat_mass_id_to_amount_map : Dictionary
var last_calculated_object_mass : float

#

onready var anim_sprite = $AnimatedSprite

onready var collision_shape = $CollisionShape2D

##

func _init():
	_update_last_calculated_object_mass()
	

#

func _ready():
	SingletonsAndConsts.current_rewind_manager.add_to_rewindables(self)

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

func add_player_coll_mask():
	set_collision_mask_bit(0, true)
	

func remove_player_coll_mask():
	set_collision_mask_bit(0, false)
	


####

func calculate_momentum():
	return linear_velocity * last_calculated_object_mass


####

func _on_BaseObject_body_entered(body):
	pass
	


###################### 
# REWIND RELATED
#####################

export(bool) var is_rewindable : bool = true

var _use_integ_forces_new_vals : bool

var _rewinded__angular_velocity
var _rewinded__linear_velocity
var _rewinded__sleeping
var _rewinded__transform : Transform2D

#

func queue_free():
	if SingletonsAndConsts.current_rewind_manager.is_obj_registered_in_rewindables(self):
		SingletonsAndConsts.current_rewind_manager.connect("obj_removed_from_rewindables", self, "_on_obj_removed_from_rewindables")
		
		collision_shape.set_deferred("disabled", true)
		visible = false
		
	else:
		.queue_free()
		

func _on_obj_removed_from_rewindables(arg_obj):
	if arg_obj == self:
		.queue_free()



func get_rewind_save_state():
	var state : Physics2DDirectBodyState = Physics2DServer.body_get_direct_state(get_rid())
	return {
		"angular_velocity" : state.angular_velocity,
		"linear_velocity" : state.linear_velocity,
		"sleeping" : state.sleeping,
		"transform" : state.transform
		
	}
	

func load_into_rewind_save_state(arg_state):
	_rewinded__angular_velocity = arg_state["angular_velocity"]
	_rewinded__linear_velocity = arg_state["linear_velocity"]
	_rewinded__sleeping = arg_state["sleeping"]
	_rewinded__transform = arg_state["transform"]
	
	
	#
	global_position = _rewinded__transform.origin


func destroy_from_rewind_save_state():
	.queue_free()
	


func stared_rewind():
	mode = RigidBody2D.MODE_STATIC
	collision_shape.set_deferred("disabled", true)
	

func ended_rewind():
	mode = RigidBody2D.MODE_RIGID
	collision_shape.set_deferred("disabled", false)
	
	_use_integ_forces_new_vals = true
	



func _integrate_forces(state):
	if _use_integ_forces_new_vals:
		state.angular_velocity = _rewinded__angular_velocity
		state.linear_velocity = _rewinded__linear_velocity
		state.sleeping = _rewinded__sleeping
		state.transform = _rewinded__transform
		
		_use_integ_forces_new_vals = false


