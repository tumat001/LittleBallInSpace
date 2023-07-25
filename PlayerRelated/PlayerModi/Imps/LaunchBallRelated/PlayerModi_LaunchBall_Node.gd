extends Node2D


const MAX_LAUNCH_LINE_LENGTH : float = 200.0

const MIN_LAUNCH_FORCE__LINE_COLOR := Color(78/255.0, 123/255.0, 253/255.0)
const CHARGING_01_LAUNCH_FORCE__LINE_COLOR := Color(100/255.0, 253/255.0, 77/255.0)
const MAX_LAUNCH_FORCE__LINE_COLOR := Color(255/255.0, 128/255.0, 0/255.0)


const LINE_WIDTH__FOR_PLAYER :int = 8
const LINE_WIDTH__FOR_BALL : int = 4

#

var _starting_launch_force
var _launch_force_per_sec : float
var _max_launch_force : float
var _current_delay_before_increase_launch : float

var _launch_peak_wait_before_alternate
var _current_launch_peak_wait_before_alternate
#var _is_reducing_launch_force : bool = false

var _launch_neg_multiplier : float

var _has_reached_max_at_least_once : bool

#

var _node_to_follow : Node2D

var current_launch_force : float

var _is_charging_launch : bool setget set_is_charging_launch

#

var launch_ability setget set_launch_ability

#

func _ready():
	set_process(false)

#

func set_is_charging_launch(arg_val):
	_is_charging_launch = arg_val
	
	set_process(_is_charging_launch)

func is_charging_launch():
	return _is_charging_launch

#

func _process(delta):
	var effective_delta = delta
	if _current_delay_before_increase_launch > 0:
		_current_delay_before_increase_launch -= delta
		if _current_delay_before_increase_launch < 0:
			effective_delta += _current_delay_before_increase_launch
	
	
	#
	
	if _has_reached_max_at_least_once:
		if current_launch_force == _starting_launch_force:
			_current_launch_peak_wait_before_alternate -= delta
			
			if _current_launch_peak_wait_before_alternate <= 0:
				_launch_neg_multiplier = 1
				_current_launch_peak_wait_before_alternate = _launch_peak_wait_before_alternate
			
		elif current_launch_force == _max_launch_force:
			_current_launch_peak_wait_before_alternate -= delta
			
			if _current_launch_peak_wait_before_alternate <= 0:
				_launch_neg_multiplier = -1
				_current_launch_peak_wait_before_alternate = _launch_peak_wait_before_alternate
			
	
	#
	
	if _current_delay_before_increase_launch <= 0:
		current_launch_force += _launch_force_per_sec * effective_delta * _launch_neg_multiplier
		if current_launch_force > _max_launch_force:
			current_launch_force = _max_launch_force
			
			_has_reached_max_at_least_once = true
			
		elif current_launch_force < _starting_launch_force:
			current_launch_force = _starting_launch_force
			
			
	
	#
	
	update()
	
	###########
	
	if launch_ability != null:
		launch_ability.time_decreased(delta)
	

#


func set_node_to_follow(arg_node : Node2D):
	_node_to_follow = arg_node
	

func begin_launch_charge(arg_starting_launch_force : float, 
		arg_launch_force_per_sec : float, arg_max_launch_force : float,
		arg_initial_launch_force_delay_before_gain : float,
		arg_launch_peak_wait_before_alternate : float):
	
	_starting_launch_force = arg_starting_launch_force
	current_launch_force = arg_starting_launch_force
	_launch_force_per_sec = arg_launch_force_per_sec
	_max_launch_force = arg_max_launch_force
	_current_delay_before_increase_launch = arg_initial_launch_force_delay_before_gain
	_launch_peak_wait_before_alternate = arg_launch_peak_wait_before_alternate
	_current_launch_peak_wait_before_alternate = _launch_peak_wait_before_alternate
	
	_launch_neg_multiplier = 1
	#_is_reducing_launch_force = false
	_has_reached_max_at_least_once = false
	
	set_is_charging_launch(true)


func end_launch_charge():
	#_is_reducing_launch_force = false
	_has_reached_max_at_least_once = false
	
	set_is_charging_launch(false)
	update()

##

func _draw():
	if _is_charging_launch:
		var color_to_use = _get_color_to_use_based_on_current_launch_force()
		var mouse_pos = get_global_mouse_position()
		var node_pos = _node_to_follow.global_position
		
		##
		
		var line_length = current_launch_force * MAX_LAUNCH_LINE_LENGTH / _max_launch_force
		var line_end_pos = Vector2(line_length, 0)
		
		var angle_of_node_to_mouse = node_pos.angle_to_point(mouse_pos)
		var towards_mouse_line_end_pos = line_end_pos.rotated(angle_of_node_to_mouse) + node_pos
		
		var player_line_end_pos = line_end_pos.rotated(angle_of_node_to_mouse + PI) + node_pos
		
		#
		# BALL line
		draw_line(node_pos, towards_mouse_line_end_pos, color_to_use, LINE_WIDTH__FOR_PLAYER)
		# PLAYER line
		draw_line(node_pos, player_line_end_pos, color_to_use, LINE_WIDTH__FOR_BALL)


func _get_color_to_use_based_on_current_launch_force() -> Color:
	if is_equal_approx(current_launch_force, _starting_launch_force):
		return MIN_LAUNCH_FORCE__LINE_COLOR
		
	elif is_equal_approx(current_launch_force, _max_launch_force):
		return MAX_LAUNCH_FORCE__LINE_COLOR
		
	else:
		return CHARGING_01_LAUNCH_FORCE__LINE_COLOR
	


################

func set_launch_ability(arg_ability):
	launch_ability = arg_ability
	


