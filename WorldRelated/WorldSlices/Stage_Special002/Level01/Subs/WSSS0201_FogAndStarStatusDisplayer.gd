extends Control

#

const StoreOfTransitionSprites = preload("res://_NonMainGameRelateds/_Master/TransitionsRelated/StoreOfTransitionSprites.gd")

#

signal display_completed__and_queuing_free()
signal main_fog_lifting_star_removal_phase_started()

#

const FOG_SUCCESSFUL__LIFT_DURATION : float = 0.75

const FOG_INITIAL_RATIO = 0.0
const FOG_FAIL__MAX_ATTEMPT_RATIO : float = 0.3
const FOG_FAIL__FINAL_RATIO_TO_LEAVE_ON : float = 0.1
const FOG_FAIL__ATTEMPT_LIFT_BOUNCE_DURATION : float = 1.0
const FOG_FAIL__ATTEMPT_LIFT_RECEED_DURATION : float = 1.0


#

var _is_unlock_fog_attempt_success : bool

#

var _threshold_val
var _curr_val

#

var _transition_sprite

onready var star_wheel_count_displayer = $StarWheelCountDisplayer
onready var star_counter_big_panel = $StarCounterBigPanel

#

func _ready() -> void:
	star_wheel_count_displayer.global_position = star_counter_big_panel.get_center_pos_of_star_icon()
	

#

func init_with_vals(arg_threshold_count : int, arg_lvl_ids_for_stars : Array):
	star_counter_big_panel.set_threshold_count(arg_threshold_count)
	star_wheel_count_displayer.level_ids_for_counter = arg_lvl_ids_for_stars
	
	_threshold_val = arg_threshold_count

#

func start_display__as_successful_unlock():
	_is_unlock_fog_attempt_success = true
	star_wheel_count_displayer.last_phase_id_star_removal = star_wheel_count_displayer.LastPhaseIds_StarRemoval.OUTWARD
	star_wheel_count_displayer.is_attempt_unlock_fail = false
	_start_display__common_actions()
	

func start_display__as_failed_unlock():
	_is_unlock_fog_attempt_success = false
	star_wheel_count_displayer.last_phase_id_star_removal = star_wheel_count_displayer.LastPhaseIds_StarRemoval.INWARD
	star_wheel_count_displayer.is_attempt_unlock_fail = true
	_start_display__common_actions()
	

func _start_display__common_actions():
	_construct_fog_transition_sprite()
	
	_connect_signals_with_star_counter_big_panel()
	_connect_signals_with_star_wheel_counter()
	
	star_counter_big_panel.start_display()

#

func _construct_fog_transition_sprite():
	_transition_sprite = SingletonsAndConsts.current_master.construct_transition__using_id(StoreOfTransitionSprites.TransitionSpriteIds.IN__STANDARD_CIRCLE__BLACK)
	
	_transition_sprite.is_custom_controlled__avoid_auto_tweens = true
	
	_transition_sprite.initial_ratio = FOG_INITIAL_RATIO
	_transition_sprite.target_ratio = FOG_INITIAL_RATIO
	_transition_sprite.wait_at_start = 0.0
	_transition_sprite.duration = 1
	_transition_sprite.trans_type = Tween.TRANS_LINEAR
	#SingletonsAndConsts.current_master.play_transition__alter_no_states(_transition_sprite)
	
	_transition_sprite.queue_free_on_end_of_transition = false
	#SingletonsAndConsts.add_child_to_game_elements__other_node_hoster(_transition_sprite)
	
	
	SingletonsAndConsts.current_game_front_hud.add_node_to_other_hosters(_transition_sprite)
	_transition_sprite.start_transition()
	_transition_sprite.modulate.a = 1.0


func _connect_signals_with_star_counter_big_panel():
	star_counter_big_panel.connect("start_display_completed", self, "_on_star_counter_big_panel_starting_display_completed")

func _on_star_counter_big_panel_starting_display_completed():
	_start_star_wheel_count_displayer()

func _start_star_wheel_count_displayer():
	star_wheel_count_displayer.start_display()



func _connect_signals_with_star_wheel_counter():
	star_wheel_count_displayer.connect("star_filled_in__lvl_and_index", self, "_on_star_wheel_disp__star_filled_in__lvl_and_index")
	#star_wheel_count_displayer.connect("display_of_last_phase_finished", self, "_on_star_wheel_display_of_last_phase_finished")
	star_wheel_count_displayer.connect("last_phase_star_removal_started", self, "_on_star_wheel_disp__last_phase_star_removal_started")
	star_wheel_count_displayer.connect("last_phase_star_removal__after_windup_main_removal_phase_started", self, "_on_star_wheel_last_phase_star_removal__after_windup_main_removal_phase_started")

func _on_star_wheel_disp__star_filled_in__lvl_and_index(arg_lvl_id, arg_i, arg_total_star_collected_count, arg_is_accelerating_uptick):
	star_counter_big_panel.set_curr_count(arg_i + 1, (arg_total_star_collected_count - 1 == arg_i))
	_curr_val = arg_i + 1


func _on_star_wheel_disp__last_phase_star_removal_started():
	pass

func _on_star_wheel_last_phase_star_removal__after_windup_main_removal_phase_started():
	if _is_unlock_fog_attempt_success:
		_lift_fog()
	else:
		_attempt_but_fail_to_lift_fog()
	
	emit_signal("main_fog_lifting_star_removal_phase_started")

	if _is_unlock_fog_attempt_success:
		_on_star_wheel_last_phase_finished__as_unlock_attempt_success()
	else:
		_on_star_wheel_last_phase_finished__as_unlock_attempt_fail()
	
	

#

func _lift_fog():
	var tweener = create_tween()
	tweener.tween_method(_transition_sprite, "set_circle_ratio", _transition_sprite.initial_ratio, 1.0, FOG_SUCCESSFUL__LIFT_DURATION).set_trans(Tween.TRANS_BOUNCE)
	tweener.tween_callback(_transition_sprite, "queue_free")

func _attempt_but_fail_to_lift_fog():
	var final_max_ratio_before_fail = convert_ratio_using_num_range(_curr_val / float(_threshold_val), FOG_INITIAL_RATIO, FOG_FAIL__MAX_ATTEMPT_RATIO)
	
	var tweener = create_tween()
	tweener.tween_method(_transition_sprite, "set_circle_ratio", _transition_sprite.initial_ratio, final_max_ratio_before_fail, FOG_FAIL__ATTEMPT_LIFT_BOUNCE_DURATION).set_trans(Tween.TRANS_BOUNCE)
	tweener.tween_method(_transition_sprite, "set_circle_ratio", final_max_ratio_before_fail, FOG_FAIL__FINAL_RATIO_TO_LEAVE_ON, FOG_FAIL__ATTEMPT_LIFT_RECEED_DURATION).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)

#arg_ratio at 0 -> min.. 1 -> max
func convert_ratio_using_num_range(arg_ratio, arg_min, arg_max):
	var diff = arg_max - arg_min
	
	return arg_min + (diff * arg_ratio)


#

func _on_star_wheel_last_phase_finished__as_unlock_attempt_success():
	_on_star_wheel_last_phase_finished__common_actions()
	star_counter_big_panel.end_display(star_counter_big_panel.EndDisplayTypeId.FADE_OUT)

func _on_star_wheel_last_phase_finished__as_unlock_attempt_fail():
	_on_star_wheel_last_phase_finished__common_actions()
	star_counter_big_panel.end_display(star_counter_big_panel.EndDisplayTypeId.FADE_OUT)


func _on_star_wheel_last_phase_finished__common_actions():
	star_counter_big_panel.connect("end_display_completed", self, "_on_star_counter_big_panel_end_display_completed")

func _on_star_counter_big_panel_end_display_completed():
	emit_signal("display_completed__and_queuing_free")
	queue_free()
