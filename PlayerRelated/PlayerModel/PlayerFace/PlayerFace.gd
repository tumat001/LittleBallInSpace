extends Node2D

const EYE_ANIMATION_NAME__NORMAL = "normal"
const EYE_ANIMATION_NAME__NORMAL_TO_OUCH = "normal_to_ouch"
const EYE_ANIMATION_NAME__OUCH = "ouch"
const EYE_ANIMATION_NAME__OUCH_TO_NORMAL = "ouch_to_normal"

const MOUTH_ANIMATION_NAME__NORMAL = "normal"
const MOUTH_ANIMATION_NAME__CHARGING_BALL_01 = "charging_ball_01"
const MOUTH_ANIMATION_NAME__CHARGING_BALL_02 = "charging_ball_02"
const MOUTH_ANIMATION_NAME__CHARGING_BALL_03 = "charging_ball_03"
const MOUTH_ANIMATION_NAME__UPGRADING = "upgrading"
const MOUTH_ANIMATION_NAME__REWINDING = "rewinding"


##

enum _InternalFaceExpressionAnimId {
	NORMAL = 0,
	OUCH = 1,
	NORMAL_TO_OUCH = 2,
	OUCH_TO_NORMAL = 3,
	
	CHARGING_LAUNCH_BALL = 10,
	LAUNCHED_BALL = 11,
	UPGRADING = 20,
	REWINDING = 30,
}
var _current_FE_anim_id__for_left_eye : int
var _current_FE_anim_id__for_right_eye : int
var _current_FE_anim_id__for_mouth_piece : int


#

enum _InternalFaceExpressionNodePosId {
	NORMAL = 0,
	CHARGING_LAUNCH_BALL = 10,
	UPGRADING = 11,
	REWINDING = 12,
}
var _current_FE_pos_id__for_left_eye : int
var _current_FE_pos_id__for_right_eye : int
var _current_FE_pos_id__for_mouth_piece : int


const INTERNAL_FE_NODE_POS_ID_PRIORITY_MAP = {
	_InternalFaceExpressionNodePosId.UPGRADING : 2,
	_InternalFaceExpressionNodePosId.REWINDING : 2,
	_InternalFaceExpressionNodePosId.CHARGING_LAUNCH_BALL : 1,
	_InternalFaceExpressionNodePosId.NORMAL : 0,
}

var _left_eye__normal_position : Vector2
var _right_eye__normal_position : Vector2
var _mouth_piece__normal_position : Vector2


var _right_eye__CLB_low_position_modi : Vector2 = Vector2(1, 0)
var _right_eye__CLB_med_position_modi : Vector2 = Vector2(2, 0)
var _right_eye__CLB_high_position_modi : Vector2 = Vector2(3, 0)

var _mouth_piece__CLB_position : Vector2 = Vector2(0, 2)

var _mouth_piece__center_position : Vector2 = Vector2(0, 0)


var _left_eye_position_tweener : SceneTreeTween
var _right_eye_position_tweener : SceneTreeTween
var _mouth_piece_position_tweener : SceneTreeTween



##

enum _InternalFaceExpressionNodeOffsetId {
	NORMAL = 0,
	CHARGING_LAUNCH_BALL = 10,
}
const INTERNAL_FE_NODE_OFFSET_ID_PRIORITY_MAP = {
	_InternalFaceExpressionNodeOffsetId.CHARGING_LAUNCH_BALL : 1,
	_InternalFaceExpressionNodeOffsetId.NORMAL : 0,
}

var _left_eye_offset_tweener : SceneTreeTween
var _right_eye_offset_tweener : SceneTreeTween


var _left_eye__normal_offset : Vector2
var _right_eye__normal_offset : Vector2

var _left_eye__current_offset : Vector2
var _right_eye__current_offset : Vector2

var _current_FE_offset_id__for_left_eye : int
var _current_FE_offset_id__for_right_eye: int


var _current_x_perspective_axis_velocity : float

const MAX_OFFSET__SAME_SIDE_EYE : float = 3.0
const MAX_OFFSET__DIFF_SIDE_EYE : float = 4.5
const SPEED_TO_REACH_MAX_OFFSET : float = 300.0

#

enum _InternalSequenceId {
	OUCH = 1,
	LAUNCHING_BALL = 2,
	UPGRADING = 3,
	REWINDING = 4,
}
var _current_sequence_ids_active : Array
var _current_sequence_of_FE_tweener : SceneTreeTween

#

var player setget set_player

var _player_modi_launch_ball_node
var _curr_strength_factor_of_player_modi_launch_ball_node : int = -1

#

#var _left_eye_animation_tweener : SceneTreeTween
#var _right_eye_animation_tweener : SceneTreeTween
#var _mouth_piece_animation_tweener : SceneTreeTween

#

var _eye_sprite_frames : SpriteFrames

#

var FACE_ANIMATION_NAME__NORMAL_TO_OUCH__FRAME_COUNT : int
var FACE_ANIMATION_NAME__OUCH_TO_NORMAL__FRAME_COUNT : int

#

onready var left_eye = $LeftEye
onready var right_eye = $RightEye
onready var mouth_piece = $MouthPiece

onready var screen_face = $ScreenFace

var all_non_screen_face_parts : Array

#

func _ready():
	_init_all_non_screen_face_parts()
	_init_sprite_node_positions()
	
	_eye_sprite_frames = left_eye.frames
	_init_frame_counts()
	
	play_FE__normal(false, false, true)
	mouth_piece.modulate.a = 0


func _init_all_non_screen_face_parts():
	all_non_screen_face_parts.append(left_eye)
	all_non_screen_face_parts.append(right_eye)
	all_non_screen_face_parts.append(mouth_piece)

func _init_sprite_node_positions():
	_left_eye__normal_position = left_eye.position
	_right_eye__normal_position = right_eye.position
	_mouth_piece__normal_position = mouth_piece.position
	
	_left_eye__normal_offset = left_eye.offset
	_right_eye__normal_offset = right_eye.offset
	
	_left_eye__current_offset = left_eye.offset
	_right_eye__current_offset = right_eye.offset
	

func _init_frame_counts():
	FACE_ANIMATION_NAME__NORMAL_TO_OUCH__FRAME_COUNT = _eye_sprite_frames.get_frame_count(EYE_ANIMATION_NAME__NORMAL_TO_OUCH)
	FACE_ANIMATION_NAME__OUCH_TO_NORMAL__FRAME_COUNT = _eye_sprite_frames.get_frame_count(EYE_ANIMATION_NAME__OUCH_TO_NORMAL)

#

func set_player(arg_player):
	player = arg_player
	
	player.connect("pos_change__for_aesth_effects", self, "_on_pos_change__for_aesth_effects")
	SingletonsAndConsts.current_rewind_manager.connect("rewinding_started", self, "_on_rewinding_started")
	SingletonsAndConsts.current_rewind_manager.connect("done_ending_rewind", self, "_on_done_ending_rewind")
	player.connect("on_integ_forces", self, "_on_player_on_integ_forces")

##

func _on_pos_change__for_aesth_effects(curr_pos_mag, prev_pos_mag, diff, delta):
	if prev_pos_mag > curr_pos_mag:
		if diff > 450:
			play_sequence__ouch__long()
		elif diff > 300:
			play_sequence__ouch__medium()
		elif diff > 220:
			play_sequence__ouch__short()


func play_sequence__ouch__long():
	_start_new_FE_sequence(_InternalSequenceId.OUCH)
	_current_sequence_of_FE_tweener.set_parallel(false)
	_current_sequence_of_FE_tweener.tween_callback(self, "play_FE__normal_to_ouch", [0.5])
	_current_sequence_of_FE_tweener.tween_interval(0.5)
	_current_sequence_of_FE_tweener.tween_callback(self, "play_FE__ouch")
	_current_sequence_of_FE_tweener.tween_interval(0.95)
	_current_sequence_of_FE_tweener.tween_callback(self, "play_FE__ouch_to_normal", [0.95])
	_current_sequence_of_FE_tweener.tween_interval(0.95)
	_current_sequence_of_FE_tweener.tween_callback(self, "play_FE__normal")


func play_sequence__ouch__medium():
	_start_new_FE_sequence(_InternalSequenceId.OUCH)
	_current_sequence_of_FE_tweener.set_parallel(false)
	_current_sequence_of_FE_tweener.tween_callback(self, "play_FE__normal_to_ouch", [0.5])
	_current_sequence_of_FE_tweener.tween_interval(0.5)
	_current_sequence_of_FE_tweener.tween_callback(self, "play_FE__ouch")
	_current_sequence_of_FE_tweener.tween_interval(0.75)
	_current_sequence_of_FE_tweener.tween_callback(self, "play_FE__ouch_to_normal", [0.75])
	_current_sequence_of_FE_tweener.tween_interval(0.75)
	_current_sequence_of_FE_tweener.tween_callback(self, "play_FE__normal")


func play_sequence__ouch__short():
	_start_new_FE_sequence(_InternalSequenceId.OUCH)
	_current_sequence_of_FE_tweener.set_parallel(false)
	_current_sequence_of_FE_tweener.tween_callback(self, "play_FE__normal_to_ouch", [0.5])
	_current_sequence_of_FE_tweener.tween_interval(0.5)
	_current_sequence_of_FE_tweener.tween_callback(self, "play_FE__ouch")
	_current_sequence_of_FE_tweener.tween_interval(0.5)
	_current_sequence_of_FE_tweener.tween_callback(self, "play_FE__ouch_to_normal", [0.5])
	_current_sequence_of_FE_tweener.tween_interval(0.5)
	_current_sequence_of_FE_tweener.tween_callback(self, "play_FE__normal")


#func _start_new_FE_sequence__and_kill_old() -> SceneTreeTween:
#	if _current_sequence_of_FE_tweener != null and _current_sequence_of_FE_tweener.is_valid():
#		_current_sequence_of_FE_tweener.kill()
#
#	return _start_new_FE_sequence()

func _start_new_FE_sequence(arg_sequence_id_to_play : int, arg_always_kill_prev : bool = false, arg_is_only_for_mark : bool = false) -> SceneTreeTween:
	if !arg_is_only_for_mark:
		if _current_sequence_ids_active.has(arg_sequence_id_to_play) or arg_always_kill_prev:
			if _current_sequence_of_FE_tweener != null and _current_sequence_of_FE_tweener.is_valid():
				_current_sequence_of_FE_tweener.kill()
				_current_sequence_ids_active.erase(arg_sequence_id_to_play)
	
	#
	
	if !_current_sequence_ids_active.has(arg_sequence_id_to_play):
		_current_sequence_ids_active.append(arg_sequence_id_to_play)
	
	if !arg_is_only_for_mark:
		_current_sequence_of_FE_tweener = create_tween()
		_current_sequence_of_FE_tweener.connect("finished", self, "_on__current_sequence_of_FE_tweener_finished", [arg_sequence_id_to_play])
		return _current_sequence_of_FE_tweener
	else:
		return null

func _on__current_sequence_of_FE_tweener_finished(arg_sequence_id_to_play):
	_remove_FE_sequence_id(arg_sequence_id_to_play)

func _remove_FE_sequence_id(arg_sequence_id):
	_current_sequence_ids_active.erase(arg_sequence_id)


##

func play_FE__normal_to_ouch(arg_duration : float):
	_current_FE_anim_id__for_left_eye = _InternalFaceExpressionAnimId.NORMAL_TO_OUCH
	_current_FE_anim_id__for_right_eye = _InternalFaceExpressionAnimId.NORMAL_TO_OUCH
	
	var frame_count = FACE_ANIMATION_NAME__NORMAL_TO_OUCH__FRAME_COUNT
	var fps = frame_count / arg_duration
	
	_eye_sprite_frames.set_animation_speed(EYE_ANIMATION_NAME__NORMAL_TO_OUCH, fps)
	left_eye.frame = 0
	right_eye.frame = 0
	left_eye.play(EYE_ANIMATION_NAME__NORMAL_TO_OUCH)
	right_eye.play(EYE_ANIMATION_NAME__NORMAL_TO_OUCH)


func play_FE__ouch_to_normal(arg_duration : float):
	_current_FE_anim_id__for_left_eye = _InternalFaceExpressionAnimId.OUCH_TO_NORMAL
	_current_FE_anim_id__for_right_eye = _InternalFaceExpressionAnimId.OUCH_TO_NORMAL
	
	var frame_count = FACE_ANIMATION_NAME__OUCH_TO_NORMAL__FRAME_COUNT
	var fps = frame_count / arg_duration
	
	_eye_sprite_frames.set_animation_speed(EYE_ANIMATION_NAME__OUCH_TO_NORMAL, fps)
	left_eye.frame = 0
	right_eye.frame = 0
	left_eye.play(EYE_ANIMATION_NAME__OUCH_TO_NORMAL)
	right_eye.play(EYE_ANIMATION_NAME__OUCH_TO_NORMAL)
	

func play_FE__ouch():
	_current_FE_anim_id__for_left_eye = _InternalFaceExpressionAnimId.OUCH
	_current_FE_anim_id__for_right_eye = _InternalFaceExpressionAnimId.OUCH
	left_eye.play(EYE_ANIMATION_NAME__OUCH)
	right_eye.play(EYE_ANIMATION_NAME__OUCH)

func play_FE__normal(arg_relocate_eyes_at_baseline : bool = false, arg_use_tweeners : bool = false, arg_change_eye_anim : bool = true):
	if arg_change_eye_anim:
		_current_FE_anim_id__for_left_eye = _InternalFaceExpressionAnimId.NORMAL
		_current_FE_anim_id__for_right_eye = _InternalFaceExpressionAnimId.NORMAL
		left_eye.play(EYE_ANIMATION_NAME__NORMAL)
		right_eye.play(EYE_ANIMATION_NAME__NORMAL)
	
	if arg_relocate_eyes_at_baseline:
		var duration = 0.25
		_intent__relocate_node__at_position(_InternalFaceExpressionNodePosId.NORMAL, "_current_FE_pos_id__for_left_eye", left_eye, _left_eye__normal_position, arg_use_tweeners, duration, "_left_eye_position_tweener")
		_intent__relocate_node__at_position(_InternalFaceExpressionNodePosId.NORMAL, "_current_FE_pos_id__for_right_eye", right_eye, _right_eye__normal_position, arg_use_tweeners, duration, "_right_eye_position_tweener")
	
	mouth_piece.modulate.a = 0
	
	# offset
	var duration = 0.25
	_intent__relocate_node__at_offset(_InternalFaceExpressionNodeOffsetId.NORMAL, "_current_FE_offset_id__for_left_eye", left_eye, _left_eye__current_offset, arg_use_tweeners, duration, "_left_eye_offset_tweener")
	_intent__relocate_node__at_offset(_InternalFaceExpressionNodeOffsetId.NORMAL, "_current_FE_offset_id__for_right_eye", right_eye, _right_eye__current_offset, arg_use_tweeners, duration, "_right_eye_offset_tweener")


func play_sequence__upgrading():
	_start_new_FE_sequence(_InternalSequenceId.UPGRADING, false, true)
	play_FE__upgrading()

func play_FE__upgrading():
	_current_FE_anim_id__for_left_eye = _InternalFaceExpressionAnimId.UPGRADING
	_current_FE_anim_id__for_right_eye = _InternalFaceExpressionAnimId.UPGRADING
	_current_FE_anim_id__for_mouth_piece = _InternalFaceExpressionAnimId.UPGRADING
	
	mouth_piece.play(MOUTH_ANIMATION_NAME__UPGRADING)
	
	var duration = 0.2
	_intent__relocate_node__at_position(_InternalFaceExpressionNodePosId.UPGRADING, "_current_FE_pos_id__for_mouth_piece", mouth_piece, _mouth_piece__center_position, true, duration, "_mouth_piece_position_tweener")
	
	left_eye.modulate.a = 0
	right_eye.modulate.a = 0
	mouth_piece.modulate.a = 1

func end_sequence__upgrading():
	_remove_FE_sequence_id(_InternalSequenceId.UPGRADING)
	left_eye.modulate.a = 1
	right_eye.modulate.a = 1
	mouth_piece.modulate.a = 0
	play_FE__normal(true, false, true)

###########

func _on_rewinding_started():
	play_sequence__rewinding()
	

func _on_done_ending_rewind():
	end_sequence__rewinding()
	



func play_sequence__rewinding():
	_start_new_FE_sequence(_InternalSequenceId.REWINDING, false, true)
	play_FE__rewinding()

func play_FE__rewinding():
	_current_FE_anim_id__for_left_eye = _InternalFaceExpressionAnimId.REWINDING
	_current_FE_anim_id__for_right_eye = _InternalFaceExpressionAnimId.REWINDING
	_current_FE_anim_id__for_mouth_piece = _InternalFaceExpressionAnimId.REWINDING
	
	mouth_piece.play(MOUTH_ANIMATION_NAME__REWINDING)
	
	_intent__relocate_node__at_position(_InternalFaceExpressionNodePosId.REWINDING, "_current_FE_pos_id__for_mouth_piece", mouth_piece, _mouth_piece__center_position, false)
	
	left_eye.modulate.a = 0
	right_eye.modulate.a = 0
	mouth_piece.modulate.a = 1

func end_sequence__rewinding():
	_remove_FE_sequence_id(_InternalSequenceId.REWINDING)
	
	left_eye.modulate.a = 1
	right_eye.modulate.a = 1
	mouth_piece.modulate.a = 0
	play_FE__normal(true, false, true)


##########

func play_sequence__charging_launch_ball():
	_init_player_modi_launch_ball_node()
	
	#var tweener = _start_new_FE_sequence(_InternalSequenceId.LAUNCHING_BALL)
	#if !tweener.is_connected("finished", self, "_on_sequence_finished__charging_launch_ball"):
	#	tweener.connect("finished", self, "_on_sequence_finished__charging_launch_ball")
	
	_start_new_FE_sequence(_InternalSequenceId.LAUNCHING_BALL, false, true)
	_connect_signals_with__player_modi_launch_ball_node()
	_play_FE__charging_launch_ball__with_strength_factor(-1)
	
	_intent__relocate_node__at_offset(_InternalFaceExpressionNodeOffsetId.CHARGING_LAUNCH_BALL, "_current_FE_offset_id__for_left_eye", left_eye, _left_eye__normal_offset, false)
	_intent__relocate_node__at_offset(_InternalFaceExpressionNodeOffsetId.CHARGING_LAUNCH_BALL, "_current_FE_offset_id__for_right_eye", right_eye, _right_eye__normal_offset, false)
	

func _init_player_modi_launch_ball_node():
	if !is_instance_valid(_player_modi_launch_ball_node):
		_player_modi_launch_ball_node = SingletonsAndConsts.current_game_elements.player_modi_manager.get_modi_or_null(StoreOfPlayerModi.PlayerModiIds.LAUNCH_BALL).player_modi_launch_ball_node


func _connect_signals_with__player_modi_launch_ball_node():
	if !_player_modi_launch_ball_node.is_connected("current_launch_force_changed", self, "_on_player_launch_ball_modi__current_launch_force_changed"):
		_player_modi_launch_ball_node.connect("current_launch_force_changed", self, "_on_player_launch_ball_modi__current_launch_force_changed")
		_player_modi_launch_ball_node.connect("ended_launch_charge", self, "_on_ended_launch_charge")

func _disconnect_signals_with__player_modi_launch_ball_node():
	if _player_modi_launch_ball_node.is_connected("current_launch_force_changed", self, "_on_player_launch_ball_modi__current_launch_force_changed"):
		_player_modi_launch_ball_node.disconnect("current_launch_force_changed", self, "_on_player_launch_ball_modi__current_launch_force_changed")
		_player_modi_launch_ball_node.disconnect("ended_launch_charge", self, "_on_ended_launch_charge")


func _on_ended_launch_charge():
	_finish_sequence__charging_launch_ball()

func _finish_sequence__charging_launch_ball():
	_curr_strength_factor_of_player_modi_launch_ball_node = -1
	_disconnect_signals_with__player_modi_launch_ball_node()
	_remove_FE_sequence_id(_InternalSequenceId.LAUNCHING_BALL)
	
	
	#TO reset
	_current_FE_pos_id__for_left_eye = _InternalFaceExpressionNodePosId.NORMAL
	_current_FE_pos_id__for_right_eye = _InternalFaceExpressionNodePosId.NORMAL
	_current_FE_offset_id__for_left_eye = _InternalFaceExpressionNodeOffsetId.NORMAL
	_current_FE_offset_id__for_right_eye = _InternalFaceExpressionNodeOffsetId.NORMAL
	play_FE__normal(true, true, false)

func _on_player_launch_ball_modi__current_launch_force_changed(arg_val, is_min, is_max, strength_factor_from_0_to_2):
	_play_FE__charging_launch_ball__with_strength_factor(strength_factor_from_0_to_2)


func _play_FE__charging_launch_ball__with_strength_factor(strength_factor_from_0_to_2):
	var old_val = _curr_strength_factor_of_player_modi_launch_ball_node
	_curr_strength_factor_of_player_modi_launch_ball_node = strength_factor_from_0_to_2
	
	mouth_piece.modulate.a = 1
	
	if old_val != _curr_strength_factor_of_player_modi_launch_ball_node:
		if strength_factor_from_0_to_2 == 0:
			play_FE__charging_launch_ball__low(old_val)
		elif strength_factor_from_0_to_2 == 1:
			play_FE__charging_launch_ball__med(old_val)
		elif strength_factor_from_0_to_2 == 2:
			play_FE__charging_launch_ball__high(old_val)

func play_FE__charging_launch_ball__low(arg_old_str_val):
	var duration = 0.25
	var right_eye_final_pos = _right_eye__normal_position + _right_eye__CLB_low_position_modi
	var left_eye_final_pos = _left_eye__normal_position - _right_eye__CLB_low_position_modi
	_intent__relocate_node__at_position(_InternalFaceExpressionNodePosId.CHARGING_LAUNCH_BALL, "_current_FE_pos_id__for_left_eye", left_eye, left_eye_final_pos, true, duration, "_left_eye_position_tweener")
	_intent__relocate_node__at_position(_InternalFaceExpressionNodePosId.CHARGING_LAUNCH_BALL, "_current_FE_pos_id__for_right_eye", right_eye, right_eye_final_pos, true, duration, "_right_eye_position_tweener")
	
	#
	
	_current_FE_anim_id__for_mouth_piece = _InternalFaceExpressionAnimId.CHARGING_LAUNCH_BALL
	if arg_old_str_val == -1:  # from none
		mouth_piece.play(MOUTH_ANIMATION_NAME__CHARGING_BALL_01)
		
		# only here, since the pos is the same
		_intent__relocate_node__at_position(_InternalFaceExpressionNodePosId.CHARGING_LAUNCH_BALL, "_current_FE_pos_id__for_mouth_piece", mouth_piece, _mouth_piece__CLB_position, true, duration, "_mouth_piece_position_tweener")
		
	elif arg_old_str_val == 1:  # from med
		mouth_piece.play(MOUTH_ANIMATION_NAME__CHARGING_BALL_01)
	

func play_FE__charging_launch_ball__med(arg_old_str_val):
	var duration = 0.25
	var right_eye_final_pos = _right_eye__normal_position + _right_eye__CLB_med_position_modi
	var left_eye_final_pos = _left_eye__normal_position - _right_eye__CLB_med_position_modi
	_intent__relocate_node__at_position(_InternalFaceExpressionNodePosId.CHARGING_LAUNCH_BALL, "_current_FE_pos_id__for_left_eye", left_eye, left_eye_final_pos, true, duration, "_left_eye_position_tweener")
	_intent__relocate_node__at_position(_InternalFaceExpressionNodePosId.CHARGING_LAUNCH_BALL, "_current_FE_pos_id__for_right_eye", right_eye, right_eye_final_pos, true, duration, "_right_eye_position_tweener")
	
	_current_FE_anim_id__for_mouth_piece = _InternalFaceExpressionAnimId.CHARGING_LAUNCH_BALL
	if arg_old_str_val == 1:  # from low
		mouth_piece.play(MOUTH_ANIMATION_NAME__CHARGING_BALL_02)
	elif arg_old_str_val == 3:  # from high
		mouth_piece.play(MOUTH_ANIMATION_NAME__CHARGING_BALL_02)
	

func play_FE__charging_launch_ball__high(arg_old_str_val):
	var duration = 0.25
	var right_eye_final_pos = _right_eye__normal_position + _right_eye__CLB_high_position_modi
	var left_eye_final_pos = _left_eye__normal_position - _right_eye__CLB_high_position_modi
	_intent__relocate_node__at_position(_InternalFaceExpressionNodePosId.CHARGING_LAUNCH_BALL, "_current_FE_pos_id__for_left_eye", left_eye, left_eye_final_pos, true, duration, "_left_eye_position_tweener")
	_intent__relocate_node__at_position(_InternalFaceExpressionNodePosId.CHARGING_LAUNCH_BALL, "_current_FE_pos_id__for_right_eye", right_eye, right_eye_final_pos, true, duration, "_right_eye_position_tweener")
	
	_current_FE_anim_id__for_mouth_piece = _InternalFaceExpressionAnimId.CHARGING_LAUNCH_BALL
	mouth_piece.play(MOUTH_ANIMATION_NAME__CHARGING_BALL_03)



###########

func _intent__relocate_node__at_position(arg_intent_pos_id : int, arg_pos_id_var_name : String, arg_node_part : Node2D, 
		arg_pos : Vector2, arg_use_tweeners : bool, arg_duration : float = 0.5, arg_position_tweener_name_of_node : String = "",
		arg_trans : int = Tween.TRANS_QUAD, arg_ease : int = Tween.EASE_OUT) -> SceneTreeTween:
	
	
	if _is_pos_id_a_node_pos_priority_higher_or_equal_to_pos_id_b(arg_intent_pos_id, get(arg_pos_id_var_name)):
		set(arg_pos_id_var_name, arg_intent_pos_id)
		
		var arg_position_tweener_of_node = get(arg_position_tweener_name_of_node)
		
		if arg_position_tweener_of_node != null and arg_position_tweener_of_node.is_valid():
			arg_position_tweener_of_node.kill()
		
		if !arg_use_tweeners:
			arg_node_part.position = arg_pos
		else:
			var tween = create_tween()
			tween.tween_property(arg_node_part, "position", arg_pos, arg_duration).set_trans(arg_trans).set_ease(arg_ease)
			set(arg_position_tweener_name_of_node, tween)
			
			return tween
		
		return null
		
	else:
		return null

func _is_pos_id_a_node_pos_priority_higher_or_equal_to_pos_id_b(arg_pos_id__a, arg_pos_id__b):
	var prio_of_a = INTERNAL_FE_NODE_POS_ID_PRIORITY_MAP[arg_pos_id__a]
	var prio_of_b = INTERNAL_FE_NODE_POS_ID_PRIORITY_MAP[arg_pos_id__b]
	
	return prio_of_a >= prio_of_b




func _intent__relocate_node__at_offset(arg_intent_offset_id : int, arg_offset_id_var_name : String, arg_node_part, 
		arg_offset : Vector2, arg_use_tweeners : bool, arg_duration : float = 0.5, arg_offset_tweener_name_of_node : String = "",
		arg_trans : int = Tween.TRANS_QUAD, arg_ease : int = Tween.EASE_OUT) -> SceneTreeTween:
	
	
	if _is_pos_id_a_node_offset_priority_higher_or_equal_to_pos_id_b(arg_intent_offset_id, get(arg_offset_id_var_name)):
		set(arg_offset_id_var_name, arg_intent_offset_id)
		
		var arg_offset_tweener_of_node = get(arg_offset_tweener_name_of_node)
		
		if arg_offset_tweener_of_node != null and arg_offset_tweener_of_node.is_valid():
			arg_offset_tweener_of_node.kill()
		
		if !arg_use_tweeners:
			arg_node_part.offset = arg_offset
		else:
			var tween = create_tween()
			tween.tween_property(arg_node_part, "offset", arg_offset, arg_duration).set_trans(arg_trans).set_ease(arg_ease)
			set(arg_offset_tweener_name_of_node, tween)
			
			return tween
		
		return null
		
	else:
		return null

func _is_pos_id_a_node_offset_priority_higher_or_equal_to_pos_id_b(arg_pos_id__a, arg_pos_id__b):
	var prio_of_a = INTERNAL_FE_NODE_OFFSET_ID_PRIORITY_MAP[arg_pos_id__a]
	var prio_of_b = INTERNAL_FE_NODE_OFFSET_ID_PRIORITY_MAP[arg_pos_id__b]
	
	return prio_of_a >= prio_of_b


##########
# ENERGY

func on_energy_discharged_to_zero():
	screen_face.texture = preload("res://PlayerRelated/PlayerModel/Assets/PlayerModel_FaceScreen_NoEnergy.png")
	for part in all_non_screen_face_parts:
		part.visible = false
	mouth_piece.visible = false

func on_energy_restored_from_zero():
	screen_face.texture = preload("res://PlayerRelated/PlayerModel/Assets/PlayerModel_FaceScreen.png")
	for part in all_non_screen_face_parts:
		part.visible = true
	mouth_piece.visible = true


####

func _on_player_on_integ_forces(arg_state : Physics2DDirectBodyState):
	var lin_velocity = arg_state.linear_velocity
	var curr_cam_angle = CameraManager.current_cam_rotation
	var old_val = _current_x_perspective_axis_velocity
	_current_x_perspective_axis_velocity = lin_velocity.rotated(curr_cam_angle).x
	if is_equal_approx(curr_cam_angle, PI/2) or is_equal_approx(curr_cam_angle, -PI/2):
		_current_x_perspective_axis_velocity = -_current_x_perspective_axis_velocity
	
	print(curr_cam_angle)
	
	var calced_offset_x__for_right = _calculate_offset_mag__for_right_eye()
	var calced_offset_x__for_left = _calculate_offset_mag__for_left_eye()
	_left_eye__current_offset = Vector2(calced_offset_x__for_left, 0)
	_right_eye__current_offset = Vector2(calced_offset_x__for_right, 0)
	
	
	var diff = old_val - _current_x_perspective_axis_velocity
	if diff > 50:
		var duration = 0.20
		_intent__relocate_node__at_offset(_InternalFaceExpressionNodeOffsetId.NORMAL, "_current_FE_offset_id__for_left_eye", left_eye, _left_eye__current_offset, true, duration, "_left_eye_offset_tweener")
		_intent__relocate_node__at_offset(_InternalFaceExpressionNodeOffsetId.NORMAL, "_current_FE_offset_id__for_right_eye", right_eye, _right_eye__current_offset, true, duration, "_right_eye_offset_tweener")
		
	else:
		_intent__relocate_node__at_offset(_InternalFaceExpressionNodeOffsetId.NORMAL, "_current_FE_offset_id__for_left_eye", left_eye, _left_eye__current_offset, false)
		_intent__relocate_node__at_offset(_InternalFaceExpressionNodeOffsetId.NORMAL, "_current_FE_offset_id__for_right_eye", right_eye, _right_eye__current_offset, false)
	

func _calculate_offset_mag__for_right_eye():
	if _current_x_perspective_axis_velocity > 0:
		return _convert_result_into_ratio_using_num_range(_current_x_perspective_axis_velocity, 0, SPEED_TO_REACH_MAX_OFFSET) * MAX_OFFSET__SAME_SIDE_EYE
	elif _current_x_perspective_axis_velocity < 0:
		return _convert_result_into_ratio_using_num_range(_current_x_perspective_axis_velocity, 0, SPEED_TO_REACH_MAX_OFFSET) * MAX_OFFSET__DIFF_SIDE_EYE
	else:
		return 0

func _calculate_offset_mag__for_left_eye():
	if _current_x_perspective_axis_velocity > 0:
		return _convert_result_into_ratio_using_num_range(_current_x_perspective_axis_velocity, 0, SPEED_TO_REACH_MAX_OFFSET) * MAX_OFFSET__DIFF_SIDE_EYE
	elif _current_x_perspective_axis_velocity < 0:
		return _convert_result_into_ratio_using_num_range(_current_x_perspective_axis_velocity, 0, SPEED_TO_REACH_MAX_OFFSET) * MAX_OFFSET__SAME_SIDE_EYE
	else:
		return 0


func _convert_result_into_ratio_using_num_range(arg_result, arg_min, arg_max):
	return (arg_result - arg_min) / (arg_max - arg_min)


