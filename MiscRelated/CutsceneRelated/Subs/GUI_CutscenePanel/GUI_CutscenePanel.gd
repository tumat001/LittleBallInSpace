extends Control

#

const ConditionalClauses = preload("res://MiscRelated/ClauseRelated/ConditionalClauses.gd")

#

signal all_controls_displayed()
signal current_control_blocking_advance_to_next_finished_display(arg_blocking_param, arg_next_param)
signal started_display_of_new_control_with_param(arg_param)

signal fully_displayed__from_fade_in()
signal fully_undisplayed()

signal last_calculated_can_progress_thru_cutscene_changed(arg_val)

#

export(bool) var all_controls_force_visible : bool = false

##

var _current_tweener : SceneTreeTween

#

var has_at_least_one_child_visible_on_start : bool
var all_children_visible_at_start : bool

#

var _start_display_gen_params : Array

#

var finished_all_controls_displayed : bool = false setget _set_finished_all_controls_displayed
var _is_in_showing_or_hiding_transition : bool = false setget _set_is_in_showing_or_hiding_transition


enum BlockProgressThruCutsceneClauseIds {
	IN_SHOWING_OR_HIDING_TRANSITION = 0,
	NOT_FINISHED_ALL_CONTROLS_DISPLAYED = 1,
}
var block_progress_thru_cutscene_cond_clauses : ConditionalClauses
var last_calculated_can_progress_thru_cutscene : bool #setget ,get_last_calculated_can_progress_thru_cutscene

#

class StartDisplayGenParam:
	var control_to_show : Control
	var duration_of_fade_in_show : float
	var duration_additional_delay_before_finish : float
	var metadata
	
	var advance_to_next_display : bool = true
	
	
	const DURATION_DISPLAY__IMAGE = 0.5
	const DURATION_DELAY_BEFORE_FINISH__IMAGE__LONG = 5.0
	const DURATION_DELAY_BEFORE_FINISH__IMAGE__SHORT = 0.75
	
	const DURATION_DISPLAY__CUSTOM_LABEL = 2.5
	const DURATION_DELAY_BEFORE_FINISH__LABEL__LONG = 4.0
	const DURATION_DELAY_BEFORE_FINISH__LABEL__SHORT = 2.0
	
	func autofill_fields__as_ftq_image__long():
		duration_of_fade_in_show = DURATION_DISPLAY__IMAGE
		duration_additional_delay_before_finish = DURATION_DELAY_BEFORE_FINISH__IMAGE__LONG
	
	func autofill_fields__as_ftq_image__short():
		duration_of_fade_in_show = DURATION_DISPLAY__IMAGE
		duration_additional_delay_before_finish = DURATION_DELAY_BEFORE_FINISH__IMAGE__SHORT
	
	
	func autofill_fields__as_ftq_label__long():
		duration_of_fade_in_show = DURATION_DISPLAY__CUSTOM_LABEL
		duration_additional_delay_before_finish = DURATION_DELAY_BEFORE_FINISH__LABEL__LONG
	
	func autofill_fields__as_ftq_label__short():
		duration_of_fade_in_show = DURATION_DISPLAY__CUSTOM_LABEL
		duration_additional_delay_before_finish = DURATION_DELAY_BEFORE_FINISH__LABEL__SHORT



##################

func _init():
	block_progress_thru_cutscene_cond_clauses = ConditionalClauses.new()
	block_progress_thru_cutscene_cond_clauses.connect("clause_inserted", self, "_on_block_progress_thru_cutscene_cond_clauses_updated")
	block_progress_thru_cutscene_cond_clauses.connect("clause_removed", self, "_on_block_progress_thru_cutscene_cond_clauses_updated")
	_update_last_calculated_can_progress_thru_cutscene()

func _on_block_progress_thru_cutscene_cond_clauses_updated(arg_clause_id):
	_update_last_calculated_can_progress_thru_cutscene()
	

func _update_last_calculated_can_progress_thru_cutscene():
	var old_val = last_calculated_can_progress_thru_cutscene
	last_calculated_can_progress_thru_cutscene = block_progress_thru_cutscene_cond_clauses.is_passed
	
	if old_val != last_calculated_can_progress_thru_cutscene:
		emit_signal("last_calculated_can_progress_thru_cutscene_changed", last_calculated_can_progress_thru_cutscene)


func _set_finished_all_controls_displayed(arg_val):
	finished_all_controls_displayed = arg_val
	
	if arg_val:
		block_progress_thru_cutscene_cond_clauses.remove_clause(BlockProgressThruCutsceneClauseIds.NOT_FINISHED_ALL_CONTROLS_DISPLAYED)
	else:
		block_progress_thru_cutscene_cond_clauses.attempt_insert_clause(BlockProgressThruCutsceneClauseIds.NOT_FINISHED_ALL_CONTROLS_DISPLAYED)

func _set_is_in_showing_or_hiding_transition(arg_val):
	_is_in_showing_or_hiding_transition = arg_val
	
	if arg_val:
		block_progress_thru_cutscene_cond_clauses.attempt_insert_clause(BlockProgressThruCutsceneClauseIds.IN_SHOWING_OR_HIDING_TRANSITION)
	else:
		block_progress_thru_cutscene_cond_clauses.remove_clause(BlockProgressThruCutsceneClauseIds.IN_SHOWING_OR_HIDING_TRANSITION)


##

func _ready():
	_init_controls()
	
	modulate.a = 0


func _init_controls():
	for child in get_children():
		if child.cutscene_initially_visible or all_controls_force_visible:
			child.visible = true
			has_at_least_one_child_visible_on_start = true
			
		else:
			child.visible = false
			
	

#

func start_end_display():
	_set_is_in_showing_or_hiding_transition(true)
	_begin_end_display__fade_out()

func _begin_end_display__fade_out():
	_current_tweener = create_tween()
	_current_tweener.set_parallel(false)
	_current_tweener.tween_property(self, "modulate:a", 0.0, 0.5)
	_current_tweener.tween_callback(self, "_on_begin_end_display__fade_out__finished")

func _on_begin_end_display__fade_out__finished():
	visible = false
	_set_is_in_showing_or_hiding_transition(false)
	emit_signal("fully_undisplayed")

#

func start_display():
	_set_is_in_showing_or_hiding_transition(true)
	visible = true
	
	if _start_display_gen_params.size() != 0:
		_start_display__using_params()
	else:
		_start_display__default_defined()
		

func _start_display__default_defined():
	if all_children_visible_at_start:
		_set_is_in_showing_or_hiding_transition(false)
		_set_finished_all_controls_displayed(true)
	else:
		_set_finished_all_controls_displayed(false)
		_begin_display__fade_in__then_start_display__no_params()

func _begin_display__fade_in__then_start_display__no_params():
	modulate.a = 0.0
	
	_current_tweener = create_tween()
	_current_tweener.set_parallel(false)
	_current_tweener.tween_property(self, "modulate:a", 1.0, 0.5)
	_current_tweener.tween_callback(self, "_on_begin_display__fade_in__finished__no_param_queue")

func _on_begin_display__fade_in__finished__no_param_queue():
	_set_is_in_showing_or_hiding_transition(false)
	
	emit_signal("fully_displayed__from_fade_in")


#

func add_display_param(arg_param : StartDisplayGenParam):
	_start_display_gen_params.append(arg_param)
	

func _start_display__using_params():
	_set_finished_all_controls_displayed(false)
	
	#if has_at_least_one_child_visible_on_start:
	#	modulate.a = 1.0
	#	_start_display__using_param_queue()
	#else:
	_begin_display__fade_in__then_start_display__using_params()

func _begin_display__fade_in__then_start_display__using_params():
	modulate.a = 0.0
	
	_current_tweener = create_tween()
	_current_tweener.set_parallel(false)
	_current_tweener.tween_property(self, "modulate:a", 1.0, 0.5)
	_current_tweener.tween_callback(self, "_on_begin_display__fade_in__finished__with_param_queue")

func _on_begin_display__fade_in__finished__with_param_queue():
	_set_is_in_showing_or_hiding_transition(false)
	_start_display__using_param_queue()
	
	emit_signal("fully_displayed__from_fade_in")
	

#

func advance_current_display__params():
	if _start_display_gen_params.size() != 0:
		_start_display__using_param_queue()
		return true
		
	else:
		return false
		


func _start_display__using_param_queue():
	var param : StartDisplayGenParam = _start_display_gen_params.pop_front()
	var control = param.control_to_show
	
	_current_tweener = create_tween()
	_current_tweener.set_parallel(false)
	
	if control.get("is_class_type_ftq_custom_label"):
		_start_display__using_param__to_ftq_custom_label(param, control)
		
	elif control.get("is_class_type_ftq_image"):
		_start_display__using_param__to_ftq_image(param, control)
	
	emit_signal("started_display_of_new_control_with_param", param)


func _start_display__using_param__to_ftq_custom_label(arg_param : StartDisplayGenParam, arg_control : Control):
	arg_control.start_display_of_descs__all_chars(arg_param.duration_of_fade_in_show, arg_param.duration_additional_delay_before_finish)
	arg_control.connect("display_of_desc_finished", self, "_on_ftq_custom_label__display_of_desc_finished", [arg_param], CONNECT_ONESHOT)

func _start_display__using_param__to_ftq_image(arg_param : StartDisplayGenParam, arg_control : Control):
	arg_control.start_display(arg_param.duration_of_fade_in_show, arg_param.duration_additional_delay_before_finish)
	arg_control.connect("display_of_image_finished", self, "_on_ftq_image__display_of_image_finished", [arg_param], CONNECT_ONESHOT)




func _on_ftq_custom_label__display_of_desc_finished(custom_char_count_to_show_upto, arg_metadata, arg_param : StartDisplayGenParam):
	_on_control_display_finished(arg_param)

func _on_ftq_image__display_of_image_finished(arg_metadata, arg_param : StartDisplayGenParam):
	_on_control_display_finished(arg_param)


func _on_control_display_finished(arg_param : StartDisplayGenParam):
	if arg_param.advance_to_next_display:
		var has_next_param = advance_current_display__params()
		if !has_next_param:
			_set_finished_all_controls_displayed(true)
			emit_signal("all_controls_displayed")
		
	else:
		if _start_display_gen_params.size() == 0:
			_set_finished_all_controls_displayed(true)
			emit_signal("all_controls_displayed")
		else:
			emit_signal("current_control_blocking_advance_to_next_finished_display", arg_param, _start_display_gen_params.back())
		
	


##


func finish_display_now():
	if _current_tweener != null and _current_tweener.is_running():
		_current_tweener.custom_step(9999)
		


#func get_last_calculated_can_progress_thru_cutscene():
#	return finished_all_controls_displayed and !_is_in_showing_or_hiding_transition
#	


