extends Node2D


const MAX_LAUNCH_LINE_LENGTH : float = 200.0

const MOD_A_FOR_LINE_COLORS = 0.5
const MIN_LAUNCH_FORCE__LINE_COLOR := Color(78/255.0, 123/255.0, 253/255.0, MOD_A_FOR_LINE_COLORS)
const CHARGING_01_LAUNCH_FORCE__LINE_COLOR := Color(100/255.0, 253/255.0, 77/255.0, MOD_A_FOR_LINE_COLORS)
const MAX_LAUNCH_FORCE__LINE_COLOR := Color(255/255.0, 128/255.0, 0/255.0, MOD_A_FOR_LINE_COLORS)


const LINE_WIDTH__FOR_PLAYER :int = 8
const LINE_WIDTH__FOR_BALL : int = 4

#

signal aim_mode_changed(arg_mode)
signal can_change_aim_mode_changed(arg_val)

signal current_launch_force_changed(arg_val, is_min, is_max, strength_factor_from_0_to_2)

signal ended_launch_charge()

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

var _can_auto_change_launch_force_by_waiting : bool

#

var _current_color_to_use_for_draw : Color

#

var _node_to_follow : Node2D

var current_launch_force : float setget _set_current_launch_force
var last_calc_angle_of_node_to_mouse

var _is_charging_launch : bool setget set_is_charging_launch

#

var launch_ability setget set_launch_ability

#

var show_player_trajectory_line : bool

#

const CIRCLE_PARTITION = PI/16.0

enum AimMode {
	OMNI = 0,
	SNAP = 1,
}
var current_aim_mode : int = AimMode.OMNI setget set_current_aim_mode

var can_change_aim_mode : bool = true setget set_can_change_aim_mode

#

var is_override_mouse_angle : bool = false
var custom_mouse_angle : float
var is_modify_custom_mouse_angle_with_cam_manager_angle : bool = true

#

func set_can_change_aim_mode(arg_val):
	var old_val = can_change_aim_mode
	can_change_aim_mode = arg_val
	
	if old_val != can_change_aim_mode:
		emit_signal("can_change_aim_mode_changed", can_change_aim_mode)

#

func toggle_current_aim_mode():
	var index = AimMode.values().find(current_aim_mode)
	index += 1
	var list_size = AimMode.values().size()
	if list_size <= index:
		index = 0
	
	set_current_aim_mode(AimMode.values()[index])

func set_current_aim_mode(arg_mode):
	var old_val = current_aim_mode
	current_aim_mode = arg_mode
	
	if old_val != current_aim_mode:
		AudioManager.helper__play_sound_effect__plain(StoreOfAudio.AudioIds.SFX_LaunchBall_AimModeChanged, 1.0, null, AudioManager.MaskLevel.UI_SoundFX)
		emit_signal("aim_mode_changed", current_aim_mode)
		


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
	if _can_auto_change_launch_force_by_waiting:
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
				_has_reached_max_at_least_once = true
			
			_set_current_launch_force(current_launch_force)
	
	#
	
	update()
	
	###########
	
	if launch_ability != null:
		launch_ability.time_decreased(delta)


func _set_current_launch_force(arg_val):
	current_launch_force = arg_val
	
	if current_launch_force > _max_launch_force:
		current_launch_force = _max_launch_force
	elif current_launch_force < _starting_launch_force:
		current_launch_force = _starting_launch_force
	
	var is_min = current_launch_force == _starting_launch_force
	var is_max = current_launch_force == _max_launch_force
	var strength_factor_from_0_to_2 = get_launch_force_as_range_from_0_to_2()
	emit_signal("current_launch_force_changed", arg_val, is_min, is_max, strength_factor_from_0_to_2)

#

func increment_current_launch__from_using_mouse_wheel(arg_increment):
	_set_current_launch_force(current_launch_force + arg_increment)
	_can_auto_change_launch_force_by_waiting = false


#

func set_node_to_follow(arg_node : Node2D):
	_node_to_follow = arg_node
	

func begin_launch_charge(arg_starting_launch_force : float, 
		arg_launch_force_per_sec : float, arg_max_launch_force : float,
		arg_initial_launch_force_delay_before_gain : float,
		arg_launch_peak_wait_before_alternate : float):
	
	_starting_launch_force = arg_starting_launch_force
	_max_launch_force = arg_max_launch_force
	#current_launch_force = arg_starting_launch_force
	_set_current_launch_force(arg_starting_launch_force)
	_launch_force_per_sec = arg_launch_force_per_sec
	_current_delay_before_increase_launch = arg_initial_launch_force_delay_before_gain
	_launch_peak_wait_before_alternate = arg_launch_peak_wait_before_alternate
	_current_launch_peak_wait_before_alternate = _launch_peak_wait_before_alternate
	
	_launch_neg_multiplier = 1
	#_is_reducing_launch_force = false
	_has_reached_max_at_least_once = false
	_can_auto_change_launch_force_by_waiting = true
	
	set_is_charging_launch(true)


func end_launch_charge():
	#_is_reducing_launch_force = false
	_has_reached_max_at_least_once = false
	
	set_is_charging_launch(false)
	update()
	
	emit_signal("ended_launch_charge")

##

func _draw():
	if _is_charging_launch:
		var color_to_use = _get_color_to_use_based_on_current_launch_force()
		var node_pos = _node_to_follow.global_position
		
		
		_current_color_to_use_for_draw = color_to_use
		
		##
		
		var line_length = current_launch_force * MAX_LAUNCH_LINE_LENGTH * 0.66 / _max_launch_force
		var line_end_pos = Vector2(line_length, 0)
		
		update_last_calc_angle_of_node_to_mouse()
		var towards_mouse_line_end_pos = line_end_pos.rotated(last_calc_angle_of_node_to_mouse) + node_pos
		
		##
		
		var player_line_length = current_launch_force * MAX_LAUNCH_LINE_LENGTH / _max_launch_force
		var player_line_end_pos = Vector2(player_line_length, 0)
		
		player_line_end_pos = player_line_end_pos.rotated(last_calc_angle_of_node_to_mouse + PI) + node_pos
		
		##
		if show_player_trajectory_line:
			# PLAYER line
			draw_line(node_pos, towards_mouse_line_end_pos, color_to_use, LINE_WIDTH__FOR_PLAYER)
		
		# BALL line
		draw_line(node_pos, player_line_end_pos, color_to_use, LINE_WIDTH__FOR_BALL)


func update_last_calc_angle_of_node_to_mouse():
	last_calc_angle_of_node_to_mouse = calculate_angle_of_node_to_mouse()

func calculate_angle_of_node_to_mouse():
	if is_override_mouse_angle:
		var angle = custom_mouse_angle
		if is_modify_custom_mouse_angle_with_cam_manager_angle:
			angle += CameraManager.camera.rotation
		
		return angle
	
	var mouse_pos = get_global_mouse_position()
	var node_pos = _node_to_follow.global_position
	
	#
	var angle_of_node_to_mouse
	
	if current_aim_mode == AimMode.OMNI:
		angle_of_node_to_mouse = node_pos.angle_to_point(mouse_pos)
	elif current_aim_mode == AimMode.SNAP:
		angle_of_node_to_mouse = node_pos.angle_to_point(mouse_pos)
		angle_of_node_to_mouse = _clean_up_angle__perfect_translated_for_circle_partition(angle_of_node_to_mouse)
	
	return angle_of_node_to_mouse

func _get_color_to_use_based_on_current_launch_force() -> Color:
	if is_equal_approx(current_launch_force, _starting_launch_force):
		return MIN_LAUNCH_FORCE__LINE_COLOR
		
	elif is_equal_approx(current_launch_force, _max_launch_force):
		return MAX_LAUNCH_FORCE__LINE_COLOR
		
	else:
		return CHARGING_01_LAUNCH_FORCE__LINE_COLOR
	

func get_launch_force_as_range_from_0_to_2():
	if _current_color_to_use_for_draw == MAX_LAUNCH_FORCE__LINE_COLOR:
		return 2
	elif _current_color_to_use_for_draw == CHARGING_01_LAUNCH_FORCE__LINE_COLOR:
		return 1
	else:
		return 0



func _clean_up_angle__perfect_translated_for_circle_partition(arg_angle):
	var translated = arg_angle / CIRCLE_PARTITION
	var perfected_translated = round(translated)
	return perfected_translated * CIRCLE_PARTITION
	

################

func set_launch_ability(arg_ability):
	launch_ability = arg_ability
	


