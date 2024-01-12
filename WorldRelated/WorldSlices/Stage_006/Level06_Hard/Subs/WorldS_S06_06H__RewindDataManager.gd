extends Reference

const PositionLink2D = preload("res://WorldRelated/WorldSlices/Stage_006/Level06_Hard/Subs/PositionLink2D.gd")

#

var _interpolate_tweener : SceneTreeTween

#

var is_activated__marker_data : bool = false

var _current_poslink_to_path_to : PositionLink2D
var _prev_poslink_to_path_to : PositionLink2D

#var _prev_glob_pos : Vector2
var _last_calc_dist_of_prev_to_curr : float
var _last_calc_angle_of_prev_to_curr : float

var duration_per_travel : float
var _curr_duration : float

#

var rewinded_decided_poslinks : Array = []

#

func _init():
	_interpolate_tweener = SceneTreeTween.new()

#

func set_curr_poslink_and_prev_poslink(arg_poslink : PositionLink2D, arg_prev_poslink : PositionLink2D):
	_current_poslink_to_path_to = arg_poslink
	_prev_poslink_to_path_to = arg_prev_poslink
	
	_update_last_calcs_based_on_poslink_and_prev()

func get_current_poslink_to_path_to():
	return _current_poslink_to_path_to

func get_prev_poslink_to_path_to():
	return _prev_poslink_to_path_to

func _update_last_calcs_based_on_poslink_and_prev():
	if is_instance_valid(_current_poslink_to_path_to):
		_last_calc_dist_of_prev_to_curr = _prev_poslink_to_path_to.global_position.distance_to(_current_poslink_to_path_to.global_position)
		_last_calc_angle_of_prev_to_curr = (_current_poslink_to_path_to.global_position.angle_to_point(_prev_poslink_to_path_to.global_position)) #round(_prev_glob_pos.angle_to_point(_current_poslink_to_path_to.global_position))
		
		#print("curr poslink pos: %s. prev: %s" % [_current_poslink_to_path_to.global_position, _prev_poslink_to_path_to.global_position])


func get_final_pos_based_on_curr_path_duration():
	var dist = _interpolate_tweener.interpolate_value(0, _last_calc_dist_of_prev_to_curr, _curr_duration, duration_per_travel, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	
	#print("dist: %s, angle: %s. currpos to go: %s, _prev pos: %s" % [dist, rad2deg(_last_calc_angle_of_prev_to_curr), (_current_poslink_to_path_to.global_position), _prev_poslink_to_path_to.global_position])
	
	var vec = Vector2(dist, 0).rotated(_last_calc_angle_of_prev_to_curr)
	
	return _prev_poslink_to_path_to.global_position + vec

#return excess duration
func delta_update(arg_delta : float) -> float:
	_curr_duration += arg_delta
	
	var excess = _curr_duration - duration_per_travel
	if excess >= 0:
		_curr_duration = 0
		return excess
	else:
		return -1.0


#

func get_next_poslink_to_path_to():
	if rewinded_decided_poslinks.size() != 0:
		return rewinded_decided_poslinks.pop_back()
	
	return _current_poslink_to_path_to.randomly_choose_position_link(get_prev_poslink_to_path_to())

func get_latest_in_rewinded_decided_poslinks__or_arg(arg_poslink):
	if rewinded_decided_poslinks.size() != 0:
		return rewinded_decided_poslinks.pop_back()
	
	return arg_poslink

###################### 
# REWIND RELATED
#####################

export(bool) var is_rewindable : bool = true
var is_dead_but_reserved_for_rewind : bool

var _rewinded__current_poslink_to_path_to

#

func get_rewind_save_state():
	return {
		"_current_poslink_to_path_to" : _current_poslink_to_path_to,
		"_prev_poslink_to_path_to" : _prev_poslink_to_path_to,
		
		"_curr_duration" : _curr_duration,
		
		"is_activated__marker_data" : is_activated__marker_data,
	}
	

func load_into_rewind_save_state(arg_state):
	_current_poslink_to_path_to = arg_state["_current_poslink_to_path_to"]
	_prev_poslink_to_path_to = arg_state["_prev_poslink_to_path_to"]
	_curr_duration = arg_state["_curr_duration"]
	is_activated__marker_data = arg_state["is_activated__marker_data"]
	
	if is_instance_valid(_rewinded__current_poslink_to_path_to) and _rewinded__current_poslink_to_path_to != _current_poslink_to_path_to:
		rewinded_decided_poslinks.append(_rewinded__current_poslink_to_path_to)
	
	_rewinded__current_poslink_to_path_to = _current_poslink_to_path_to


func destroy_from_rewind_save_state():
	pass

func restore_from_destroyed_from_rewind():
	pass

func started_rewind():
	_rewinded__current_poslink_to_path_to = null

func ended_rewind():
	_rewinded__current_poslink_to_path_to = null
	_update_last_calcs_based_on_poslink_and_prev()
	


