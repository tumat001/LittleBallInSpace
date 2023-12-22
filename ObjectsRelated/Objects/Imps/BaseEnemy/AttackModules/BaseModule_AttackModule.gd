extends Node2D


const LASER_WIDTH__BASE = 2.0
const LASER_WIDTH__IN_FIRE__MIN = 2.0
const LASER_WIDTH__IN_FIRE__MAX = 8.0
const LASER_DURATION__CHARGING = 1.0

const LASER_DURATION__TO_MAX = 0.15
const LASER_DURATION__TO_MIN = 0.85

const LASER_DURATION__LOOKAHEAD_PREDICT = LASER_DURATION__CHARGING - 0.1


#

const LASER_LENGTH : float = 1400.0

#

var target_pos_to_draw_laser_to : Vector2 setget set_target_pos_to_draw_to
#var _rewind__target_pos_to_draw_laser_to__has_changes : bool = true
const REWIND_DATA__target_pos_to_draw_laser_to = "target_pos_to_draw_laser_to"


enum FireSequenceStateId {
	NONE = 0,
	CHARGING = 1,
	FIRE__TO_MAX = 2,
	FIRE__TO_MIN = 3,
}
var _fire_sequence_state : int = FireSequenceStateId.NONE
#var _rewind__fire_sequence_state__has_changes : bool = true
const REWIND_DATA__fire_sequence_state = "_fire_sequence_state"

#

var _current_duration_of_laser_completon__to_any : float
#var _rewind__current_duration_of_laser_completon__to_any__has_changes : bool = true
const REWIND_DATA__current_duration_of_laser_completon__to_any = "_current_duration_of_laser_completon__to_any"


var _current_laser_width : float = 0 setget _set_current_laser_width
#var _rewind__current_laser_width__has_changes : bool = true
const REWIND_DATA__current_laser_width = "_current_laser_width"


#

var _tweener_for_laser_length_to_use : SceneTreeTween
var laser_color : Color

#

var can_draw_laser : bool setget set_can_draw_laser
#var _rewind__can_draw_laser__has_changes : bool = true
const REWIND_DATA__can_draw_laser = "can_draw_laser"

#

func _ready():
	_tweener_for_laser_length_to_use = SceneTreeTween.new() #create_tween()
	

#

func set_can_draw_laser(arg_val):
	can_draw_laser = arg_val
	

func set_target_pos_to_draw_to(arg_val):
	target_pos_to_draw_laser_to = arg_val
	

func _set_current_laser_width(arg_val):
	_current_laser_width = arg_val
	#_rewind__current_laser_width__has_changes = true
	
	update()

#

func _draw():
	if can_draw_laser or is_in_fire_sequence():
		var origin_pos = Vector2.ZERO
		var shifted_pos = (target_pos_to_draw_laser_to - global_position)
		draw_line(origin_pos, shifted_pos, laser_color, _current_laser_width)

#

func is_in_fire_sequence():
	return _fire_sequence_state != FireSequenceStateId.NONE


func start_fire_sequence():
	_fire_sequence_state = FireSequenceStateId.CHARGING
	#_rewind__fire_sequence_state__has_changes = true
	
	_current_duration_of_laser_completon__to_any = 0
	#_rewind__current_duration_of_laser_completon__to_any__has_changes = true
	
	#AudioManager.helper__play_sound_effect__2d(StoreOfAudio.AudioIds.SFX_Laser_ChargeUp, global_position, 1, null, AudioManager.MaskLevel.Minor_SoundFX)

func _end_fire_sequence():
	_current_duration_of_laser_completon__to_any = 0
	_fire_sequence_state = FireSequenceStateId.NONE


#

func _calc_laser_width_to_currently_use():
	if is_in_fire_sequence():
		if _fire_sequence_state == FireSequenceStateId.FIRE__TO_MAX:
			#start to max
			var width_modifier = _tweener_for_laser_length_to_use.interpolate_value(LASER_WIDTH__IN_FIRE__MIN, (LASER_WIDTH__IN_FIRE__MAX - LASER_WIDTH__IN_FIRE__MIN), _current_duration_of_laser_completon__to_any, LASER_DURATION__TO_MAX, Tween.TRANS_CIRC, Tween.EASE_OUT)
			return width_modifier
			
		elif _fire_sequence_state == FireSequenceStateId.FIRE__TO_MIN:
			#start to min
			var width_modifier = _tweener_for_laser_length_to_use.interpolate_value(LASER_WIDTH__IN_FIRE__MAX, (LASER_WIDTH__IN_FIRE__MIN - LASER_WIDTH__IN_FIRE__MAX), _current_duration_of_laser_completon__to_any, LASER_DURATION__TO_MIN, Tween.TRANS_CIRC, Tween.EASE_OUT)
			return width_modifier
			
		elif _fire_sequence_state == FireSequenceStateId.CHARGING:
			return LASER_WIDTH__BASE
			
		
	else:
		return 0

#

static func extend_vector_to_length(arg_origin : Vector2, arg_vec : Vector2, arg_length : float):
	var norm_disp = arg_origin.direction_to(arg_vec)
	norm_disp *= arg_length
	norm_disp += arg_origin
	
	return norm_disp

#

func cancel_all_windups_and_charges__on_wielder_death():
	_end_fire_sequence()
	



###################### 
# REWIND RELATED
#####################

export(bool) var is_rewindable : bool = true
var is_dead_but_reserved_for_rewind : bool


func get_rewind_save_state():
	var save_dat = {}
	
	#if _rewind__can_draw_laser__has_changes:
	save_dat[REWIND_DATA__can_draw_laser] = can_draw_laser
	#	_rewind__can_draw_laser__has_changes = false
	
	#if _rewind__target_pos_to_draw_laser_to__has_changes:
	save_dat[REWIND_DATA__target_pos_to_draw_laser_to] = target_pos_to_draw_laser_to
	#	_rewind__target_pos_to_draw_laser_to__has_changes = false
	
	#if _rewind__fire_sequence_state__has_changes:
	save_dat[REWIND_DATA__fire_sequence_state] = _fire_sequence_state
	#	_rewind__fire_sequence_state__has_changes = false
	
#	if _rewind__is_in_fire_sequence__has_changes:
#		save_dat[REWIND_DATA__is_in_fire_sequence] = is_in_fire_sequence
#
#	if _rewind__is_in_fire_sequence__to_max__has_changes:
#		save_dat[REWIND_DATA__is_in_fire_sequence__to_max] = _is_in_fire_sequence__to_max
	
	#if _rewind__current_duration_of_laser_completon__to_any__has_changes:
	save_dat[REWIND_DATA__current_duration_of_laser_completon__to_any] = _current_duration_of_laser_completon__to_any
	#	_rewind__current_duration_of_laser_completon__to_any__has_changes = false
	
	#if _rewind__current_laser_width__has_changes:
	save_dat[REWIND_DATA__current_laser_width] = _current_laser_width
	#	_rewind__current_laser_width__has_changes = false
	
	return save_dat

func load_into_rewind_save_state(arg_state : Dictionary):
	#if arg_state.has(REWIND_DATA__can_draw_laser):
	can_draw_laser = arg_state[REWIND_DATA__can_draw_laser]
	
	#if arg_state.has(REWIND_DATA__target_pos_to_draw_laser_to):
	target_pos_to_draw_laser_to = arg_state[REWIND_DATA__target_pos_to_draw_laser_to]
	
	#if arg_state.has(REWIND_DATA__fire_sequence_state):
	_fire_sequence_state = arg_state[REWIND_DATA__fire_sequence_state]
	
#	if arg_state.has(REWIND_DATA__is_in_fire_sequence):
#		is_in_fire_sequence = arg_state[REWIND_DATA__is_in_fire_sequence]
#
#	if arg_state.has(REWIND_DATA__is_in_fire_sequence__to_max):
#		_is_in_fire_sequence__to_max = arg_state[REWIND_DATA__is_in_fire_sequence__to_max]
	
	#if arg_state.has(REWIND_DATA__current_duration_of_laser_completon__to_any):
	_current_duration_of_laser_completon__to_any = arg_state[REWIND_DATA__current_duration_of_laser_completon__to_any]
	
	#if arg_state.has(REWIND_DATA__current_laser_width):
	_current_laser_width = arg_state[REWIND_DATA__current_laser_width]
	
	
	update()


func destroy_from_rewind_save_state():
	pass
	

func restore_from_destroyed_from_rewind():
	pass


func started_rewind():
	pass

func ended_rewind():
	pass

