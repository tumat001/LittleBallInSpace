extends "res://MiscRelated/AttackSpriteRelated/AttackSprite.gd"


##

signal reached_center_pos_of_basis()


var center_pos_of_basis : Vector2

var override__initial_pos : Vector2
var use_override__initial_pos : bool = false

export(float) var initial_speed_towards_center : float
export(float) var speed_accel_towards_center : float
var current_speed_towards_center : float

export(float) var min_speed_towards_center : float = -9999.0
export(float) var max_speed_towards_center : float = 9999.0

export(float) var min_starting_distance_from_center : float
export(float) var max_starting_distance_from_center : float

export(float) var min_starting_angle : float = 0
export(float) var max_starting_angle : float = 359

export(bool) var is_enabled_mov_toward_center : bool = true

var non_essential_rng : RandomNumberGenerator

var _emitted_reached_center_pos_of_basis : bool = false

#

var reset_for_another_use_on_ready : bool = true

#

func _init():
	non_essential_rng = StoreOfRNG.get_rng(StoreOfRNG.RNGSource.NON_ESSENTIAL)


func _ready():
	if reset_for_another_use_on_ready:
		reset_for_another_use()


func reset_for_another_use():
	current_speed_towards_center = initial_speed_towards_center
	_emitted_reached_center_pos_of_basis = false
	
	randomize_position_based_on_properties()

func randomize_position_based_on_properties():
	var starting_distance : float = non_essential_rng.randi_range(min_starting_distance_from_center, max_starting_distance_from_center)
	var angle = non_essential_rng.randi_range(min_starting_angle, max_starting_angle)
	
	var rand_vector := Vector2(starting_distance, 0).rotated(deg2rad(angle))
	
	
	if use_override__initial_pos:
		global_position = override__initial_pos
	else:
		global_position = center_pos_of_basis + rand_vector



#

func _process(delta):
	if is_enabled_mov_toward_center:
		global_position = global_position.move_toward(center_pos_of_basis, delta * current_speed_towards_center)
		
		current_speed_towards_center += speed_accel_towards_center * delta
		
		if current_speed_towards_center < min_speed_towards_center:
			current_speed_towards_center = min_speed_towards_center
		elif current_speed_towards_center > max_speed_towards_center:
			current_speed_towards_center = max_speed_towards_center
		
		if !_emitted_reached_center_pos_of_basis and global_position == center_pos_of_basis:
			emit_signal("reached_center_pos_of_basis")
			_emitted_reached_center_pos_of_basis = true
		
		
		#print("curr_speed : %s. speed accel: %s" % [current_speed_towards_center, speed_accel_towards_center])
