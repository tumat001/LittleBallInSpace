extends Reference


var target_actual_position : Vector2
var origin_position : Vector2

var target_velocity : Vector2
var origin_velocity : Vector2

var lookahead_duration : float

var projectile_velocity : Vector2
var consider_projectile_velocity : bool = false


func get_calculated_angle_of_aim():
	var predicted_target_pos = target_actual_position + (target_velocity * lookahead_duration)
	var predicted_origin_pos = origin_position + (origin_velocity * lookahead_duration)
	
	if !consider_projectile_velocity:
		return predicted_origin_pos.angle_to_point(predicted_target_pos)
	
	#
	
	var predicted_distance_vel = predicted_origin_pos - predicted_target_pos
	var extra_duration = predicted_distance_vel / projectile_velocity
	
	predicted_target_pos += (target_velocity * (extra_duration))
	predicted_origin_pos += (origin_velocity * (extra_duration))
	
	return predicted_origin_pos.angle_to_point(predicted_target_pos) 
	

func get_calculated_position_of_aim():
	var predicted_target_pos = target_actual_position + (target_velocity * lookahead_duration)
	var predicted_origin_pos = origin_position + (origin_velocity * lookahead_duration)
	
	if !consider_projectile_velocity:
		return predicted_origin_pos.angle_to_point(predicted_target_pos)
	
	#
	
	var predicted_distance_vel = predicted_origin_pos - predicted_target_pos
	var extra_duration = predicted_distance_vel / projectile_velocity
	
	predicted_target_pos += (target_velocity * (extra_duration))
	
	return predicted_target_pos

