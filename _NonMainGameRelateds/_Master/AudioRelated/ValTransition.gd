extends Reference

signal target_val_reached()

const VALUE_UNSET : float = -99504.55

enum ValueIncrementMode {
	LINEAR = 0,
	QUADRATIC = 1,
}

enum QuadraticValueIncMode {
	START_FROM_0 = 0,
	START_FROM_MAX = 1,
}

var _initial_val : float
var _current_val : float
var _target_val : float

var _time_to_reach_target_val : float = VALUE_UNSET
var _val_inc_per_sec : float = VALUE_UNSET
var _val_inc_mode : int

var _final_val_inc_per_sec : float

var _final_time_before_finish : float
var _current_time : float

var _instant_val_transition : bool  # if _time_to_reach is 0

#

var quad_preserve_current_accel : bool = false
#var quad_val_increment_mode : int = QuadraticValueIncMode.START_FROM_0

var initial_accel : float
var _current_val_accel : float
var _target_accel : float

var _final_accel_val_inc_per_sec : float

#

# returns true if target val has been reached (by setting arg_time_to_reach_target_val to 0)
func configure_self(arg_initial_val : float, arg_curr_val : float,
		arg_target_val : float,
		arg_time_to_reach_target_val : float,
		arg_val_inc_per_sec : float,
		arg_val_inc_mode : int) -> bool:
	
	_instant_val_transition = false
	
	_initial_val = arg_initial_val
	_current_val = arg_curr_val
	_target_val = arg_target_val
	
	_time_to_reach_target_val = arg_time_to_reach_target_val
	_val_inc_per_sec = arg_val_inc_per_sec
	
	if !quad_preserve_current_accel:
		_current_val_accel = 0
	else:
		initial_accel = _current_val_accel
	
	if _time_to_reach_target_val != VALUE_UNSET:
		_instant_val_transition = _time_to_reach_target_val <= 0
		
		_final_val_inc_per_sec = _get_calculated_final_val_inc_per_sec_based_on_properties()
		_calculate_accel_vals_based_on_properties()
		
		_final_time_before_finish = _time_to_reach_target_val
		
	elif _val_inc_per_sec != VALUE_UNSET:
		_final_val_inc_per_sec = _val_inc_per_sec
		_current_val_accel = 0
		
		_final_time_before_finish = abs((_target_val - _initial_val) / _val_inc_per_sec)
		
		_instant_val_transition = _final_time_before_finish <= 0
	
	_current_time = 0
	
	if _instant_val_transition:
		_reach_target_val()
	return _instant_val_transition

func _get_calculated_final_val_inc_per_sec_based_on_properties():
	if _time_to_reach_target_val <= 0:
		return (_target_val - _initial_val)  # just to prevent crash. but this means nothing since we're using _instant_val_transition bool check
	
	if _val_inc_mode == ValueIncrementMode.LINEAR:
		return (_target_val - _initial_val) / _time_to_reach_target_val
		
	else:
		return _initial_val

func _calculate_accel_vals_based_on_properties():
	if _val_inc_mode == ValueIncrementMode.QUADRATIC:
		_target_accel = (2 * ((_target_val - _initial_val) - (_initial_val * _time_to_reach_target_val))) / (_time_to_reach_target_val * _time_to_reach_target_val)
		_target_accel -= initial_accel
		
		_current_val_accel = initial_accel
		
		_final_accel_val_inc_per_sec = (_target_accel - initial_accel) / _time_to_reach_target_val
		
	else:
		initial_accel = 0
		_current_val_accel = 0
		_target_accel = 0


#

# returns true if target val has been reached
func delta_pass(arg_delta) -> bool:
	if _instant_val_transition:
		_reach_target_val()
		return true
	
	_current_val += _final_val_inc_per_sec * arg_delta
	_final_val_inc_per_sec += _current_val_accel * arg_delta
	
	_current_val_accel += _final_accel_val_inc_per_sec * arg_delta
	
	_current_time += arg_delta
	
	if (_current_time >= _final_time_before_finish):
		_reach_target_val()
		return true
	
	return false

func _reach_target_val():
	_current_val = _target_val
	
	emit_signal("target_val_reached")


func instantly_finish_transition():
	_reach_target_val()

###

func get_current_val():
	return _current_val


