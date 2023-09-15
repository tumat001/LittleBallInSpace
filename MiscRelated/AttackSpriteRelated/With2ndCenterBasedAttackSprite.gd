extends "res://MiscRelated/AttackSpriteRelated/CenterBasedAttackSprite.gd"



signal reached_final_destination()
signal request_beam_attachment()


var _finished_with_first_center : bool = false
var _can_auto_change_to_secondary_center : bool = true
var _is_doing_angle_change : bool = false


var secondary_center : Vector2
var secondary_speed_accel_towards_center : float
var secondary_initial_speed_towards_center : float

#

var _angle_to_secondary_center : float
var _angle_per_sec : float

var _angle_per_sec_val_mag_sign : int
var _angle_magnitude_min : float
var _angle_magnitude_max : float

var _angle_modi

var _current_total_angle_turn_amount : float
var _target_total_angle_turn_amount : float

#

func _ready():
	has_lifetime = false
	queue_free_at_end_of_lifetime = false
	
	min_starting_distance_from_center = 8
	max_starting_distance_from_center = 15


func reset_for_another_use():
	.reset_for_another_use()
	
	#_lifetime_from_zero = 0
	#max_speed_towards_center = 0
	#min_speed_towards_center = -9999
	
	_angle_modi = 0
	
	secondary_initial_speed_towards_center = 0
	secondary_speed_accel_towards_center = 0
	#_can_auto_change_to_secondary_center = true
	
	#_delta_passed_on_zero_speed = 0
	
	current_speed_towards_center = initial_speed_towards_center
	_finished_with_first_center = false
	
	_can_auto_change_to_secondary_center = true
	_is_doing_angle_change = false
	
	is_enabled_mov_toward_center = true
	
	



func _process(delta):
	if !_finished_with_first_center and current_speed_towards_center == 0:
		if _can_auto_change_to_secondary_center:
			_configure_self_to_change_to_secondary_center()
			
		else:
			_do_prep_on_finished_with_first_center()
		
		_finished_with_first_center = true
	
	if _is_doing_angle_change:
		var turn_amount = _angle_per_sec * delta
		rotation += turn_amount
		_current_total_angle_turn_amount += abs(turn_amount)
		
		if _current_total_angle_turn_amount >= _target_total_angle_turn_amount:
			rotation = _angle_to_secondary_center
			_is_doing_angle_change = false
			_configure_self_to_change_to_secondary_center()
	
#	_lifetime_from_zero += delta
#
#	if _lifetime_from_z__to_start_center_change >= _lifetime_from_zero and !_finished_with_first_center:
#		_finished_with_first_center = true
#
#		center_pos_of_basis = secondary_center
#		emit_signal("center_pos_of_basis_changed")
#

func _configure_self_to_change_to_secondary_center():
	_is_doing_angle_change = false
	center_pos_of_basis = secondary_center
	
	max_speed_towards_center = 9999
	min_speed_towards_center = 0
	
	rotation = global_position.angle_to_point(center_pos_of_basis) + _angle_modi
	
	current_speed_towards_center = secondary_initial_speed_towards_center
	speed_accel_towards_center = secondary_speed_accel_towards_center
	
	if !is_connected("reached_center_pos_of_basis", self, "_on_reached_center_pos_of_basis"):
		call_deferred("_connect_reached_to_center_deferred")


func _connect_reached_to_center_deferred():
	connect("reached_center_pos_of_basis", self, "_on_reached_center_pos_of_basis", [], CONNECT_ONESHOT)
	_emitted_reached_center_pos_of_basis = false

#

func _randomize_angle_per_sec_sign_and_magnitude(arg_mag_min, arg_mag_max):
	var angle_per_sec_val_is_positive = non_essential_rng.randi_range(0, 1) == 1
	_angle_per_sec_val_mag_sign = 1
	
	if !angle_per_sec_val_is_positive:
		_angle_per_sec_val_mag_sign = -1
	
	_angle_magnitude_min = arg_mag_min * _angle_per_sec_val_mag_sign
	_angle_magnitude_max = arg_mag_max * _angle_per_sec_val_mag_sign

#


func _do_prep_on_finished_with_first_center():
	_angle_to_secondary_center = global_position.angle_to_point(secondary_center) + PI
	_angle_modi = PI
	
	_angle_per_sec = non_essential_rng.randf_range(_angle_magnitude_min, _angle_magnitude_max)
	var _curr_angle = rotation
	
	_current_total_angle_turn_amount = 0
	
	if _angle_per_sec_val_mag_sign == 1:  # clockwise
		_target_total_angle_turn_amount = _angle_to_secondary_center - _curr_angle
		
		if abs(_target_total_angle_turn_amount) > 2 * PI:
			_target_total_angle_turn_amount = fposmod(_target_total_angle_turn_amount, (2*PI))
		
		if _target_total_angle_turn_amount < 0:
			_target_total_angle_turn_amount += 2 * PI
		
	else:  # counter clockwise
		_target_total_angle_turn_amount = _curr_angle - _angle_to_secondary_center
		
		if abs(_target_total_angle_turn_amount) > 2 * PI:
			_target_total_angle_turn_amount = fposmod(_target_total_angle_turn_amount, (2*PI))
		
		if _target_total_angle_turn_amount < 0:
			_target_total_angle_turn_amount += 2 * PI
		
	
	#
	_is_doing_angle_change = true


##

func _on_reached_center_pos_of_basis():
	configure_self_on_reached_end_of_lifetime()
	is_enabled_mov_toward_center = false
	
	emit_signal("reached_final_destination")

