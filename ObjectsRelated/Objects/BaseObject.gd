extends RigidBody2D


signal last_calculated_object_mass_changed(arg_val)

#

var base_object_mass : float = 20.0 setget set_base_object_mass
var _flat_mass_id_to_amount_map : Dictionary
var last_calculated_object_mass : float

#

onready var anim_sprite = $AnimatedSprite

##

func _init():
	_update_last_calculated_object_mass()
	


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




