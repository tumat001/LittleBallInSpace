extends Reference

#

signal attempted_ping(arg_success)
signal pinged_target_successfully(arg_actual_distance, arg_threshold_distance, arg_refresh_rate, arg_pos_target, arg_angle, arg_target)

#

var _detection_range_arr__HtoL : Array
#var _rewind__detection_range_arr__HtoL__has_changes : bool
#const REWIND_DATA__detection_range_arr__HtoL = "_detection_range_arr__HtoL"

var _detection_range_to_ping_rate_map : Dictionary
#var _rewind__detection_range_to_ping_rate_map__has_changes : bool
#const REWIND_DATA__detection_range_to_ping_rate_map = "_detection_range_to_ping_rate_map"

var _detection_range_for_successful_ping : float
#var _rewind__detection_range_for_successful_ping__has_changes : bool
#const REWIND_DATA__detection_range_for_successful_ping = "_detection_range_for_successful_ping"

var default_ping_rate_for_outside_most_outer_detection_range : float = 3.5

#
# must be set at ready ()
var current_target_node_or_pos_changes_at_any_point : bool = false


var _current_target_node : Node2D
#var _rewind__current_target_node__has_changes : bool
const REWIND_DATA__current_target_node = "_current_target_node"

var _current_target_node_is_player : bool


var _current_target_pos : Vector2
#var _rewind__current_target_pos__has_changes : bool
const REWIND_DATA__current_target_pos = "_current_target_pos"

var _current_target_func_to_use : String
#var _rewind__current_target_func_to_use__has_changes : bool
const REWIND_DATA__current_target_func_to_use = "_current_target_func_to_use"

#
# must be set at ready ()
var current_origin_node_or_pos_changes_at_any_point : bool = false


var _origin_node : Node2D
#var _rewind__origin_node__has_changes : bool
const REWIND_DATA__origin_node = "_origin_node"

var _origin : Vector2
#var _rewind__origin__has_changes : bool
const REWIND_DATA__origin = "_origin"

var _origin_func_to_use : String
#var _rewind__origin_func_to_use__has_changes : bool
const REWIND_DATA__origin_func_to_use = "_origin_func_to_use"

#

var _current_update_delay_before_ping_attempt : float
const REWIND_DATA__current_update_delay_before_ping_attempt = "_current_update_delay_before_ping_attempt"
# no need for check because we will always mark this
#var _rewind__current_update_delay_before_ping_attempt__has_changes : bool


#

#var aim_occluder_module

#

func set_origin_node(arg_node : Node2D):
	_origin_node = arg_node
	_origin_func_to_use = "_get_origin__from_node"
	
	#_rewind__origin_node__has_changes = true
	#_rewind__origin_func_to_use__has_changes = true

func set_origin(arg_vec : Vector2):
	_origin = arg_vec
	_origin_func_to_use = "_get_origin"
	
	#_rewind__origin__has_changes = true
	#_rewind__origin_func_to_use__has_changes = true


func _get_origin__from_node() -> Vector2:
	return _origin_node.global_position
	

func _get_origin() -> Vector2:
	return _origin
	

#

func add_detection_range_to_ping_rate_entry(arg_range, arg_ping_rate, arg_is_successful, arg_update_sort = true):
	_detection_range_arr__HtoL.append(arg_range)
	
	if arg_update_sort:
		_detection_range_arr__HtoL.sort_custom(self, "_sort__highest_to_lowest")
	
	_detection_range_to_ping_rate_map[arg_range] = arg_ping_rate
	
	if arg_is_successful:
		_detection_range_for_successful_ping = arg_range
	
	##
	
#	_rewind__detection_range_arr__HtoL__has_changes = true
#	_rewind__detection_range_to_ping_rate_map__has_changes = true
#	if arg_is_successful:
#		_rewind__detection_range_for_successful_ping__has_changes = true
	

static func _sort__highest_to_lowest(a, b):
	return a > b


#

func register_to_GE__and_activate():
	#_current_target_to_monitor = SingletonsAndConsts.current_game_elements.get_current_player()
	if !SingletonsAndConsts.current_game_elements.is_connected("phy_process__sig", self, "_on_GE_phy_process__sig"):
		SingletonsAndConsts.current_game_elements.connect("phy_process__sig", self, "_on_GE_phy_process__sig")

func unregister_to_GE__and_deactivate():
	#_current_target_to_monitor = SingletonsAndConsts.current_game_elements.get_current_player()
	if SingletonsAndConsts.current_game_elements.is_connected("phy_process__sig", self, "_on_GE_phy_process__sig"):
		SingletonsAndConsts.current_game_elements.disconnect("phy_process__sig", self, "_on_GE_phy_process__sig")

#

func set_current_target__to_player():
	_current_target_node = SingletonsAndConsts.current_game_elements.get_current_player()
	_current_target_func_to_use = "_get_current_target_pos__from_node"
	
	_current_target_node_is_player = true
	
	#_rewind__current_target_node__has_changes = true
	#_rewind__current_target_func_to_use__has_changes = true

func set_current_target_pos(arg_pos):
	_current_target_pos = arg_pos
	_current_target_func_to_use = "_get_current_target_pos__from_pos"
	
	#_rewind__current_target_pos__has_changes = true
	#_rewind__current_target_func_to_use__has_changes = true


func _get_current_target_pos__from_node() -> Vector2:
	return _current_target_node.global_position

func _get_current_target_pos__from_pos() -> Vector2:
	return _current_target_pos


###

func _on_GE_phy_process__sig(delta):
	if !SingletonsAndConsts.current_rewind_manager.is_rewinding:
		_current_update_delay_before_ping_attempt -= delta
		# no need to mark for rewind
		
		if _current_update_delay_before_ping_attempt <= 0:
			_attempt_ping_curr_target()
		


func _attempt_ping_curr_target():
	var pos_of_origin_to_use : Vector2 = call(_origin_func_to_use)
	var pos_of_target : Vector2 = call(_current_target_func_to_use) #_current_target_to_monitor.global_position
	
	var dist = pos_of_origin_to_use.distance_to(pos_of_target)
	var threshold_dist = dist
	
	var should_emit_signal : bool = false
	var setted_delay_at_least_once : bool = false
	
	var do_threshold_test_dist : bool = true
	
	if _current_target_node_is_player:
		if !_current_target_node.is_robot_alive():
			do_threshold_test_dist = false
			should_emit_signal = false
	
	#if aim_occluder_module != null:
	#	if aim_occluder_module
	
	if do_threshold_test_dist:
		for test_dist in _detection_range_arr__HtoL:
			if test_dist >= dist:
				# note: NOT +=
				_current_update_delay_before_ping_attempt = _detection_range_to_ping_rate_map[test_dist]
				setted_delay_at_least_once = true
				
				if _detection_range_for_successful_ping >= test_dist:
					should_emit_signal = true
				
				threshold_dist = test_dist
	
	if !setted_delay_at_least_once:
		_current_update_delay_before_ping_attempt = default_ping_rate_for_outside_most_outer_detection_range
	
	if should_emit_signal:
		emit_signal("attempted_ping", true)
		emit_signal("pinged_target_successfully", dist, threshold_dist, _current_update_delay_before_ping_attempt, pos_of_target, pos_of_origin_to_use.angle_to_point(pos_of_target), _current_target_node)
	else:
		emit_signal("attempted_ping", false)


###################### 
# REWIND RELATED
#####################

export(bool) var is_rewindable : bool = false
var is_dead_but_reserved_for_rewind : bool


func get_rewind_save_state():
	var save_dat = {}
	
#	if _rewind__detection_range_arr__HtoL__has_changes:
#		save_dat[REWIND_DATA__detection_range_arr__HtoL] = _detection_range_arr__HtoL.duplicate(true)
#
#	if _rewind__detection_range_to_ping_rate_map__has_changes:
#		save_dat[REWIND_DATA__detection_range_to_ping_rate_map] = _detection_range_to_ping_rate_map.duplicate(true)
#
#	if _rewind__detection_range_for_successful_ping__has_changes:
#		save_dat[REWIND_DATA__detection_range_for_successful_ping] = _detection_range_for_successful_ping
	
	#
	
	if current_target_node_or_pos_changes_at_any_point:
		#if _rewind__current_target_node__has_changes:
		save_dat[REWIND_DATA__current_target_node] = _current_target_node
		
		#if _rewind__current_target_pos__has_changes:
		save_dat[REWIND_DATA__current_target_pos] = _current_target_pos
		
		#if _rewind__current_target_func_to_use__has_changes:
		save_dat[REWIND_DATA__current_target_func_to_use] = _current_target_func_to_use
	
	#
	
	if current_origin_node_or_pos_changes_at_any_point:
		#if _rewind__origin_node__has_changes:
		save_dat[REWIND_DATA__origin_node] = _origin_node
		
		#if _rewind__origin__has_changes:
		save_dat[REWIND_DATA__origin] = _origin
		
		#if _rewind__origin_func_to_use__has_changes:
		save_dat[REWIND_DATA__origin_func_to_use] = _origin_func_to_use
	
	#
	
	save_dat[REWIND_DATA__current_update_delay_before_ping_attempt] = _current_update_delay_before_ping_attempt
	
	return save_dat

func load_into_rewind_save_state(arg_state : Dictionary):
#	if arg_state.has(REWIND_DATA__detection_range_arr__HtoL):
#		_detection_range_arr__HtoL.clear()
#		_detection_range_arr__HtoL.append_array(arg_state[REWIND_DATA__detection_range_arr__HtoL])
#
#	if arg_state.has(REWIND_DATA__detection_range_to_ping_rate_map):
#		_detection_range_to_ping_rate_map.clear()
#		var map_to_copy_from : Dictionary = arg_state[REWIND_DATA__detection_range_to_ping_rate_map]
#		for key in map_to_copy_from.keys():
#			var val = map_to_copy_from[key]
#
#			_detection_range_to_ping_rate_map[key] = val
#
#	if arg_state.has(REWIND_DATA__detection_range_for_successful_ping):
#		_detection_range_for_successful_ping = arg_state[REWIND_DATA__detection_range_for_successful_ping]
	
	#
	
	if arg_state.has(REWIND_DATA__current_target_node):
		_current_target_node = arg_state[REWIND_DATA__current_target_node]
	
	if arg_state.has(REWIND_DATA__current_target_pos):
		_current_target_pos = arg_state[REWIND_DATA__current_target_pos]
	
	if arg_state.has(REWIND_DATA__current_target_func_to_use):
		_current_target_func_to_use = arg_state[REWIND_DATA__current_target_func_to_use]
	
	#
	
	if arg_state.has(REWIND_DATA__origin_node):
		_origin_node = arg_state[REWIND_DATA__origin_node]
	
	if arg_state.has(REWIND_DATA__origin):
		_origin = arg_state[REWIND_DATA__origin]
	
	if arg_state.has(REWIND_DATA__origin_func_to_use):
		_origin_func_to_use = arg_state[REWIND_DATA__origin_func_to_use]
	
	#
	
	_current_update_delay_before_ping_attempt = arg_state[REWIND_DATA__current_update_delay_before_ping_attempt]
	


func destroy_from_rewind_save_state():
	pass
	

func restore_from_destroyed_from_rewind():
	pass


func started_rewind():
	pass

func ended_rewind():
	pass



