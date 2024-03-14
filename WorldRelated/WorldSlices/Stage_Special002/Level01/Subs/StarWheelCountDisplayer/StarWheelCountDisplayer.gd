extends Node2D


const DELAY_FOR_NEXT_STAR_CREATION : float = 0.05

const DIST_OF_STAR_TRAVEL_FROM_CENTER : float = 250.0
const DURATION_OF_STAR_TRAVEL_FROM_CENTER : float = 0.75

const FILL_STAR_SLOT_TOTAL_DURATION : float = 1.50

const FILL_SHAKE_01_DURATION : float = 0.15
const FILL_SHAKE_02_DURATION : float = 0.1
const FILL_SHAKE_03_DURATION : float = 0.1
const FILL_SHAKE_04_DURATION : float = 0.1
const FILL_SHAKE_05_DURATION : float = 0.15


const STAR_REMOVAL__INWARD__DURATION : float = 1.0
const STAR_REMOVAL__INWARD__BRIEF_OUTWARD_DURATION : float = 0.5
const STAR_REMOVAL__INWARD__BRIEF_OUTWARD_DIST : float = 75.0

const STAR_REMOVAL__OUTWARD__DURATION : float = 2.0
const STAR_REMOVAL__OUTWARD__BRIEF_INWARD_DURATION : float = 0.3
const STAR_REMOVAL__OUTWARD__BRIEF_INWARD_SEQUENCE_DELAY_PER_STAR : float = 0.015
const STAR_REMOVAL__OUTWARD__BRIEF_INWARD_DIST : float = 55.0

#

signal display_of_last_phase_finished()
signal star_filled_in__lvl_and_index(arg_lvl_id, arg_i, arg_total_star_collected_count, arg_is_accelerating_uptick)

signal last_phase_star_removal__after_windup_main_removal_phase_started()
signal last_phase_star_removal_started()

#

var non_essential_rng : RandomNumberGenerator
var level_ids_for_counter : Array

#

enum LastPhaseIds_StarRemoval {
	INWARD = 0,
	OUTWARD = 1
}
var last_phase_id_star_removal : int = LastPhaseIds_StarRemoval.INWARD

#

var audio_pitch_shift_effect : AudioEffectPitchShift

##

onready var star_draw_node = $StarDrawNode

#######

func start_display():
	_init_commons()
	_start_phase__star_creation_and_location()

#

func _init_commons():
	non_essential_rng = SingletonsAndConsts.non_essential_rng
	
	audio_pitch_shift_effect = AudioManager.add_pitch_effect__to_bus(AudioManager.bus__sfx_pitch_shift_01_name)
	

#

func _start_phase__star_creation_and_location():
	var star_tweener = create_tween()
	star_tweener.set_parallel(true)
	
	var star_count = level_ids_for_counter.size()
	var i = 0
	for level_id in level_ids_for_counter:
		var draw_param = _draw_star__from_lvl_id__and_put_to_appropriate_location(level_id, i, star_count, star_tweener)
		
		i += 1
	
	star_tweener.connect("finished", self, "_on_star_tweener_all_stars_in_final_location", [], CONNECT_ONESHOT)
	

func _draw_star__from_lvl_id__and_put_to_appropriate_location(arg_lvl_id, i, arg_total, arg_star_tweener : SceneTreeTween):
	var draw_param = star_draw_node.DrawParams.new()
	draw_param.center_pos = Vector2(0, 0)
	draw_param.texture = preload("res://WorldRelated/WorldSlices/Stage_Special002/Level01/SpecificAssets/WSSS0201_Star_EmptySlot.png")
	star_draw_node.add_draw_param(draw_param)
	
	#
	
	var angle_of_travel = (2*PI)*(i/float(arg_total))
	
	var vec_of_travel = Vector2(DIST_OF_STAR_TRAVEL_FROM_CENTER, 0).rotated(angle_of_travel)
	var delay_before_action = DELAY_FOR_NEXT_STAR_CREATION * i
	
	arg_star_tweener.tween_property(draw_param, "center_pos", vec_of_travel + draw_param.center_pos, DURATION_OF_STAR_TRAVEL_FROM_CENTER).set_delay(delay_before_action).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	
	return draw_param

##

func _on_star_tweener_all_stars_in_final_location():
	_start_phase__start_filling_of_star_slots()

func _start_phase__start_filling_of_star_slots():
	#var star_tweener = create_tween()
	
	var lvl_ids_with_stars_collected : Array = _get_lvls_with_collected_stars_from_counter()
	var i = 0
	var all_star_draw_params = star_draw_node.get_all_draw_params()
	
	for lvl_id in lvl_ids_with_stars_collected:
		var draw_param = all_star_draw_params[i]
		var tweener = _fill_star_draw_param__based_on_params(lvl_id, i, lvl_ids_with_stars_collected.size(), draw_param)
		
		#
		i += 1
		
		if i == lvl_ids_with_stars_collected.size():
			_listen_for_tween_finished__from_fill_phase__to_next_phase(tweener)


func _get_lvls_with_collected_stars_from_counter():
	var bucket = []
	for lvl_id in level_ids_for_counter:
		if GameSaveManager.is_all_coins_collected_in_level(lvl_id):
			bucket.append(lvl_id)
	
	return bucket

func _fill_star_draw_param__based_on_params(arg_lvl_id, i, arg_total_star_collected_count, arg_draw_param):
	var indiv_star_tweener = create_tween()
	var delay = indiv_star_tweener.interpolate_value(0.0, FILL_STAR_SLOT_TOTAL_DURATION, i, arg_total_star_collected_count, Tween.TRANS_QUAD, Tween.EASE_OUT_IN)
	indiv_star_tweener.tween_interval(delay)
	
	var rand_angle_intensity = non_essential_rng.randf_range(PI/8, PI/4)
	
	var is_accelerating_uptick = (i / float(arg_total_star_collected_count)) <= 0.5
	
	######
	
	var texture_to_use = preload("res://WorldRelated/WorldSlices/Stage_Special002/Level01/SpecificAssets/WSSS0201_Star_Normal.png")
	
	#
	
	##########shake 01
	indiv_star_tweener.set_parallel(true)
	indiv_star_tweener.tween_property(arg_draw_param, "angle", (rand_angle_intensity/2), FILL_SHAKE_01_DURATION).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
	indiv_star_tweener.set_parallel(false)
	indiv_star_tweener.tween_interval(FILL_SHAKE_01_DURATION)
	###########shake 02
	indiv_star_tweener.set_parallel(true)
	indiv_star_tweener.tween_property(arg_draw_param, "angle", (-rand_angle_intensity), FILL_SHAKE_02_DURATION).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	indiv_star_tweener.set_parallel(false)
	indiv_star_tweener.tween_interval(FILL_SHAKE_02_DURATION)
	############shake 03
	indiv_star_tweener.set_parallel(true)
	indiv_star_tweener.tween_property(arg_draw_param, "angle", (rand_angle_intensity), FILL_SHAKE_03_DURATION).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	indiv_star_tweener.tween_callback(self, "_tween_callback_method__set_star_draw_param_texture", [arg_draw_param, texture_to_use])
	indiv_star_tweener.tween_callback(self, "_tween_callback_method__star_filled_in", [arg_lvl_id, i, arg_total_star_collected_count, is_accelerating_uptick])
	indiv_star_tweener.set_parallel(false)
	indiv_star_tweener.tween_interval(FILL_SHAKE_03_DURATION)
	#############shake 04
	indiv_star_tweener.set_parallel(true)
	indiv_star_tweener.tween_property(arg_draw_param, "angle", (-rand_angle_intensity), FILL_SHAKE_04_DURATION).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	indiv_star_tweener.set_parallel(false)
	indiv_star_tweener.tween_interval(FILL_SHAKE_04_DURATION)
	#############shake 05
	indiv_star_tweener.set_parallel(true)
	indiv_star_tweener.tween_property(arg_draw_param, "angle", (0.0), FILL_SHAKE_05_DURATION).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	indiv_star_tweener.set_parallel(false)
	indiv_star_tweener.tween_interval(FILL_SHAKE_05_DURATION)
	
	return indiv_star_tweener

func _tween_callback_method__set_star_draw_param_texture(arg_draw_param, arg_texture : Texture):
	arg_draw_param.texture = arg_texture

func _tween_callback_method__star_filled_in(arg_lvl_id, i, arg_total_star_collected_count, arg_is_accelerating_uptick):
	emit_signal("star_filled_in__lvl_and_index", arg_lvl_id, i, arg_total_star_collected_count, arg_is_accelerating_uptick)


func _listen_for_tween_finished__from_fill_phase__to_next_phase(arg_tweener : SceneTreeTween):
	arg_tweener.connect("finished", self, "_on_last_tweener_in_from_fill_phase_finished")

func _on_last_tweener_in_from_fill_phase_finished():
	_start_phase__last_phase_star_removal()


########

func _start_phase__last_phase_star_removal():
	var star_tweener : SceneTreeTween
	match last_phase_id_star_removal:
		LastPhaseIds_StarRemoval.INWARD:
			star_tweener = _start_phase__last_phase_star_removal__as_inward()
		LastPhaseIds_StarRemoval.OUTWARD:
			star_tweener = _start_phase__last_phase_star_removal__as_outward()
	
	star_tweener.connect("finished", self, "_on_last_phase_star_tweener_finished", [], CONNECT_ONESHOT)
	
	emit_signal("last_phase_star_removal_started")

func _start_phase__last_phase_star_removal__as_inward():
	var star_tweener = create_tween()
	
	#01: brief outward
	star_tweener.set_parallel(true)
	for draw_param in star_draw_node.get_all_draw_params():
		var angle_for_travel = draw_param.center_pos.angle()
		var vec_for_travel = Vector2(STAR_REMOVAL__INWARD__BRIEF_OUTWARD_DIST, 0).rotated(angle_for_travel)
		
		star_tweener.tween_property(draw_param, "center_pos", draw_param.center_pos + vec_for_travel, STAR_REMOVAL__INWARD__BRIEF_OUTWARD_DURATION).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	
	star_tweener.set_parallel(false)
	star_tweener.tween_interval(STAR_REMOVAL__INWARD__BRIEF_OUTWARD_DURATION)
	#02: inward
	star_tweener.tween_callback(self, "_emit_last_phase_star_removal__after_windup_main_removal_phase_started")
	star_tweener.set_parallel(true)
	for draw_param in star_draw_node.get_all_draw_params():
		star_tweener.tween_property(draw_param, "center_pos", Vector2.ZERO, STAR_REMOVAL__INWARD__BRIEF_OUTWARD_DURATION).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
		
	
	return star_tweener

func _emit_last_phase_star_removal__after_windup_main_removal_phase_started():
	emit_signal("last_phase_star_removal__after_windup_main_removal_phase_started")


func _start_phase__last_phase_star_removal__as_outward():
	var star_tweener = create_tween()
	
	#01: brief inward -- sequencial
	var i = 0
	star_tweener.set_parallel(true)
	for draw_param in star_draw_node.get_all_draw_params():
		var angle_for_travel = draw_param.center_pos.angle()
		var vec_for_travel = Vector2(-STAR_REMOVAL__OUTWARD__BRIEF_INWARD_DIST, 0).rotated(angle_for_travel)
		
		star_tweener.tween_property(draw_param, "center_pos", draw_param.center_pos + vec_for_travel, STAR_REMOVAL__OUTWARD__BRIEF_INWARD_DURATION).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT).set_delay(i * STAR_REMOVAL__OUTWARD__BRIEF_INWARD_SEQUENCE_DELAY_PER_STAR)
		
		##
		i += 1
	#
	star_tweener.set_parallel(false)
	star_tweener.tween_interval(i * STAR_REMOVAL__OUTWARD__BRIEF_INWARD_SEQUENCE_DELAY_PER_STAR)
	
	##
	#02: outward
	star_tweener.tween_callback(self, "_emit_last_phase_star_removal__after_windup_main_removal_phase_started")
	star_tweener.set_parallel(true)
	for draw_param in star_draw_node.get_all_draw_params():
		var angle_for_travel = draw_param.center_pos.angle()
		var vec_for_travel = Vector2(800, 0).rotated(angle_for_travel)
		
		star_tweener.tween_property(draw_param, "center_pos", draw_param.center_pos + vec_for_travel, STAR_REMOVAL__OUTWARD__DURATION).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	
	
	return star_tweener


#

func _on_last_phase_star_tweener_finished():
	star_draw_node.remove_all_draw_params()
	
	emit_signal("display_of_last_phase_finished")
	

