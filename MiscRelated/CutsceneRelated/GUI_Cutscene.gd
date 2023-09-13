extends Control

#

const ConditionalClauses = preload("res://MiscRelated/ClauseRelated/ConditionalClauses.gd")


const GUI_CutscenePanel = preload("res://MiscRelated/CutsceneRelated/Subs/GUI_CutscenePanel/GUI_CutscenePanel.gd")
const GUI_CutscenePanel_Loading_Scene = preload("res://MiscRelated/CutsceneRelated/Subs/GUI_CutscenePanel_Loading/GUI_CutscenePanel_Loading.tscn")



const GUI_Cutscene_EndButton_Normal = preload("res://MiscRelated/CutsceneRelated/Assets/GUI_Cutscene_EndButton_Normal.png")
const GUI_Cutscene_EndButton_Highlighted = preload("res://MiscRelated/CutsceneRelated/Assets/GUI_Cutscene_EndButton_Highlighted.png")

const GUI_Cutscene_NextButton_Normal = preload("res://MiscRelated/CutsceneRelated/Assets/GUI_Cutscene_NextButton_Normal.png")
const GUI_Cutscene_NextButton_Highlighted = preload("res://MiscRelated/CutsceneRelated/Assets/GUI_Cutscene_NextButton_Highlighted.png")

#

signal display_loading_panel_on_end_of_cutscene_changed(arg_val)

signal cutscene_ended()

#

const PAGE_TRAVERSAL_BUTTON_TEXT__PREV = "Prev"
const PAGE_TRAVERSAL_BUTTON_TEXT__NEXT = "Next"
const PAGE_TRAVERSAL_BUTTON_TEXT__END = "End"

const PAGE_LABEL_TEXT_FORMAT = "%s / %s"

var _current_cutscene_panel_index : int = -1 setget set_current_cutscene_panel_index__and_start_transition_from_old_to_new
var _total_cutscene_panel_count : int

var _current_cutscene : GUI_CutscenePanel

#

var display_loading_panel_on_end_of_cutscene : bool = false setget set_display_loading_panel_on_end_of_cutscene
var _cutscene_panel_loading : GUI_CutscenePanel
var _is_currently_displaying_loading_panel : bool

const MIN_LOADING_PANEL_SHOW_DURATION_FOR_EXIT : float = 1.0
var _current_loading_panel_show_duration : float
var _requested_to_progress_thru_loading_panel_while_loading_while_below_min_show_duration : bool

#


enum BlockChangeCutsceneClauseId {
	CURR_CUTSCENE_NOT_ALL_CONTROLS_DISPLAYED__OR_NO_BLOCKING_ELEMENT = 0,
	CURR_CUTSCENE_TRANSITIONING = 1,
	
	IS_IN_LOADING_SCENE = 2,
}
var block_change_cutscene_panel_page_cond_clauses : ConditionalClauses
var last_calculated_can_change_cutscene_panel_page : bool

var _tweener_cutscene_changer_button_panel : SceneTreeTween

#

export(bool) var queue_free_on_cutscene_end : bool = true

#

var _ignore_inputs

#

onready var cutscene_container = $CutsceneContainer
onready var cutscene_loading_container = $CutsceneLoadingContainer

onready var left_button = $CutsceneChangerButtonPanel/LeftButton
onready var right_button = $CutsceneChangerButtonPanel/RightButton
onready var left_button_label = $CutsceneChangerButtonPanel/LeftButton/LabelContainer/Label
onready var right_button_label = $CutsceneChangerButtonPanel/RightButton/LabelContainer/Label
onready var left_button_tex_button = $CutsceneChangerButtonPanel/LeftButton/TextureButton
onready var right_button_tex_button = $CutsceneChangerButtonPanel/RightButton/TextureButton


onready var cutscene_changer_button_panel = $CutsceneChangerButtonPanel


onready var ftq_label_page_num_displayer = $CutsceneChangerButtonPanel/FTQLabel_PageDisplayer

#

func _init():
	block_change_cutscene_panel_page_cond_clauses = ConditionalClauses.new()
	block_change_cutscene_panel_page_cond_clauses.connect("clause_inserted", self, "_on_block_change_cutscene_panel_page_cond_clauses_updated")
	block_change_cutscene_panel_page_cond_clauses.connect("clause_removed", self, "_on_block_change_cutscene_panel_page_cond_clauses_updated")
	_update_last_calculated_block_change_cutscene_panel_page()

func _on_block_change_cutscene_panel_page_cond_clauses_updated(arg_clause_id):
	_update_last_calculated_block_change_cutscene_panel_page()
	

func _update_last_calculated_block_change_cutscene_panel_page():
	var old_val = last_calculated_can_change_cutscene_panel_page
	last_calculated_can_change_cutscene_panel_page = block_change_cutscene_panel_page_cond_clauses.is_passed
	
	if old_val != last_calculated_can_change_cutscene_panel_page:
		if is_inside_tree():
			_update_properties_based_on_can_change_cutscene_panel_page()

func _update_properties_based_on_can_change_cutscene_panel_page():
	if last_calculated_can_change_cutscene_panel_page:
		if _tweener_cutscene_changer_button_panel != null:
			_tweener_cutscene_changer_button_panel.kill()
		
		cutscene_changer_button_panel.modulate.a = 0
		cutscene_changer_button_panel.visible = true
		_tweener_cutscene_changer_button_panel = create_tween()
		_tweener_cutscene_changer_button_panel.set_parallel(false)
		
		_tweener_cutscene_changer_button_panel.tween_property(cutscene_changer_button_panel, "modulate:a", 1.0, 0.5)
		
	else:
		
		cutscene_changer_button_panel.visible = false
		



#

func _input(event):
	if event is InputEventKey:
		get_viewport().set_input_as_handled()


#

func _ready():
	set_process(false)
	set_process_input(false)
	
	initialize_cutscene()

##

func initialize_cutscene():
	_init_all_cutscene_panels()
	_update_properties_based_on_can_change_cutscene_panel_page()
	
	if display_loading_panel_on_end_of_cutscene:
		_initialize_cutscene_panel_loading()

func _init_all_cutscene_panels():
	for child in cutscene_container.get_children():
		pass
	
	_total_cutscene_panel_count = cutscene_container.get_child_count()


####

func start_display():
	set_process_input(true)
	_attempt_traverse_page__with_index_shift(1)
	

func reset_for_another_use():
	set_process_input(false)
	if is_instance_valid(_current_cutscene):
		_current_cutscene.instant_end_display()
	_current_cutscene_panel_index = -1

#######

func _on_LeftButton_button_pressed():
	_attempt_traverse_page__to_left()

func _on_RightButton_button_pressed():
	_attempt_traverse_page__to_right()

func _on_Button_pressed():
	_attempt_traverse_page__to_right()


#

func _attempt_traverse_page__to_left():
	_attempt_traverse_page__with_index_shift(-1)

func _attempt_traverse_page__to_right():
	#if _current_cutscene_panel_index == _total_cutscene_panel_count - 1:
	#	_attempt_end_cutscene()
	#	
	#else:
	_attempt_traverse_page__with_index_shift(1)
	

func _attempt_traverse_page__with_index_shift(arg_shift : int):
	if last_calculated_can_change_cutscene_panel_page:
		#if !_is_currently_blocked_by_current_cutscene():
		var is_finished = _attempt_finish_display_of_curr_cutscene__is_finished()
		#print("is_finished: %s" % is_finished)
		if is_finished:
			if _current_cutscene_panel_index + arg_shift >= _total_cutscene_panel_count:
				_attempt_end_cutscene()
			else:
				set_current_cutscene_panel_index__and_start_transition_from_old_to_new(_current_cutscene_panel_index + arg_shift)
	


#func _is_currently_blocked_by_current_cutscene():
#	if is_instance_valid(_current_cutscene):
#		return !_current_cutscene.last_calculated_can_progress_thru_cutscene
#	else:
#		return false

func _attempt_finish_display_of_curr_cutscene__is_finished() -> bool:
	if is_instance_valid(_current_cutscene):
		if _current_cutscene.finished_all_controls_displayed:
			return true
		else:
			return _current_cutscene.finish_display_now()
		
	else:
		return true


#

func set_current_cutscene_panel_index__and_start_transition_from_old_to_new(arg_index):
	var old_val = _current_cutscene_panel_index
	_current_cutscene_panel_index = arg_index
	
	if _current_cutscene_panel_index < 0:
		_current_cutscene_panel_index = 0
	elif _current_cutscene_panel_index >= _total_cutscene_panel_count:
		_current_cutscene_panel_index = _total_cutscene_panel_count - 1
	
	if old_val != _current_cutscene_panel_index:
		_attempt_hide_and_finish_current_cutscene()
	
	


func _attempt_hide_and_finish_current_cutscene():
	if is_instance_valid(_current_cutscene):
		block_change_cutscene_panel_page_cond_clauses.attempt_insert_clause(BlockChangeCutsceneClauseId.CURR_CUTSCENE_TRANSITIONING)
		
		_current_cutscene.connect("fully_undisplayed", self, "_on_current_cutscene_start_fully_undisplayed", [], CONNECT_ONESHOT)
		
		if _current_cutscene.is_connected("fully_displayed__from_fade_in", self, "_on_curr_cutscene_fully_displayed__from_fade_in"):
			_current_cutscene.disconnect("fully_displayed__from_fade_in", self, "_on_curr_cutscene_fully_displayed__from_fade_in")
		if _current_cutscene.is_connected("all_controls_displayed", self, "_on_curr_cutscene_all_controls_displayed"):
			_current_cutscene.disconnect("all_controls_displayed", self, "_on_curr_cutscene_all_controls_displayed")
		if _current_cutscene.is_connected("current_control_blocking_advance_to_next_finished_display", self, "_on_curr_cutscene_current_control_blocking_advance_to_next_finished_display"):
			_current_cutscene.disconnect("current_control_blocking_advance_to_next_finished_display", self, "_on_curr_cutscene_current_control_blocking_advance_to_next_finished_display")
		if _current_cutscene.is_connected("started_display_of_new_control_with_param", self, "_on_curr_control_started_display_of_new_control_with_param"):
			_current_cutscene.disconnect("started_display_of_new_control_with_param", self, "_on_curr_control_started_display_of_new_control_with_param")
		
		_current_cutscene.start_end_display()
		
	else:
		_set_current_cutscene__to_curr_index()
		
	

func _on_current_cutscene_start_fully_undisplayed():
	#block_change_cutscene_panel_page_cond_clauses.remove_clause(BlockChangeCutsceneClauseId.CURR_CUTSCENE_TRANSITIONING)
	
	_set_current_cutscene__to_curr_index()



func _set_current_cutscene__to_curr_index():
	_set_current_cutscene__and_start_display(cutscene_container.get_children()[_current_cutscene_panel_index], _current_cutscene_panel_index)

func _set_current_cutscene__and_start_display(arg_cutscene : GUI_CutscenePanel, arg_page_index : int):
	_current_cutscene = arg_cutscene
	
	block_change_cutscene_panel_page_cond_clauses.attempt_insert_clause(BlockChangeCutsceneClauseId.CURR_CUTSCENE_TRANSITIONING)
	
	if !_current_cutscene.is_connected("fully_displayed__from_fade_in", self, "_on_curr_cutscene_fully_displayed__from_fade_in"):
		_current_cutscene.connect("fully_displayed__from_fade_in", self, "_on_curr_cutscene_fully_displayed__from_fade_in")
	if !_current_cutscene.is_connected("all_controls_displayed", self, "_on_curr_cutscene_all_controls_displayed"):
		_current_cutscene.connect("all_controls_displayed", self, "_on_curr_cutscene_all_controls_displayed")
	if !_current_cutscene.is_connected("current_control_blocking_advance_to_next_finished_display", self, "_on_curr_cutscene_current_control_blocking_advance_to_next_finished_display"):
		_current_cutscene.connect("current_control_blocking_advance_to_next_finished_display", self, "_on_curr_cutscene_current_control_blocking_advance_to_next_finished_display")
	if !_current_cutscene.is_connected("started_display_of_new_control_with_param", self, "_on_curr_control_started_display_of_new_control_with_param"):
		_current_cutscene.connect("started_display_of_new_control_with_param", self, "_on_curr_control_started_display_of_new_control_with_param")
	
	#
	
	ftq_label_page_num_displayer.set_desc__and_hide_tooltip([
		[PAGE_LABEL_TEXT_FORMAT % [arg_page_index + 1, _total_cutscene_panel_count], []],
	])
	ftq_label_page_num_displayer.visible = true
	
	##
	
	if arg_page_index == _total_cutscene_panel_count - 1:
		_show_left_and_right_buttons__right_as_last()
		
	elif arg_page_index == 0:
		_show_right_button_only()
		
	else:
		_show_left_and_right_buttons__standard()
		
	
	##
	
	_current_cutscene.start_display()


func _show_left_and_right_buttons__right_as_last():
	left_button.visible = true
	left_button_tex_button.texture_normal = GUI_Cutscene_NextButton_Normal
	left_button_tex_button.texture_hover = GUI_Cutscene_NextButton_Highlighted
	left_button_label.text = PAGE_TRAVERSAL_BUTTON_TEXT__PREV
	
	#
	
	right_button.visible = true
	right_button_tex_button.texture_normal = GUI_Cutscene_EndButton_Normal
	right_button_tex_button.texture_hover = GUI_Cutscene_EndButton_Highlighted
	right_button_label.text = PAGE_TRAVERSAL_BUTTON_TEXT__END
	

func _show_right_button_only():
	left_button.visible = false
	
	#
	
	right_button.visible = true
	right_button_tex_button.texture_normal = GUI_Cutscene_NextButton_Normal
	right_button_tex_button.texture_hover = GUI_Cutscene_NextButton_Highlighted
	right_button_label.text = PAGE_TRAVERSAL_BUTTON_TEXT__NEXT
	

func _show_left_and_right_buttons__standard():
	left_button.visible = true
	left_button_tex_button.texture_normal = GUI_Cutscene_NextButton_Normal
	left_button_tex_button.texture_hover = GUI_Cutscene_NextButton_Highlighted
	left_button_label.text = PAGE_TRAVERSAL_BUTTON_TEXT__PREV
	
	#
	
	right_button.visible = true
	right_button_tex_button.texture_normal = GUI_Cutscene_NextButton_Normal
	right_button_tex_button.texture_hover = GUI_Cutscene_NextButton_Highlighted
	right_button_label.text = PAGE_TRAVERSAL_BUTTON_TEXT__NEXT
	

func _hide_left_and_right_buttons():
	left_button.visible = false
	right_button.visible = false


#

func _on_curr_cutscene_fully_displayed__from_fade_in():
	block_change_cutscene_panel_page_cond_clauses.remove_clause(BlockChangeCutsceneClauseId.CURR_CUTSCENE_TRANSITIONING)
	

func _on_curr_cutscene_all_controls_displayed():
	block_change_cutscene_panel_page_cond_clauses.remove_clause(BlockChangeCutsceneClauseId.CURR_CUTSCENE_NOT_ALL_CONTROLS_DISPLAYED__OR_NO_BLOCKING_ELEMENT)
	

func _on_curr_cutscene_current_control_blocking_advance_to_next_finished_display():
	block_change_cutscene_panel_page_cond_clauses.remove_clause(BlockChangeCutsceneClauseId.CURR_CUTSCENE_NOT_ALL_CONTROLS_DISPLAYED__OR_NO_BLOCKING_ELEMENT)
	

func _on_curr_control_started_display_of_new_control_with_param(arg_param):
	block_change_cutscene_panel_page_cond_clauses.attempt_insert_clause(BlockChangeCutsceneClauseId.CURR_CUTSCENE_NOT_ALL_CONTROLS_DISPLAYED__OR_NO_BLOCKING_ELEMENT)
	


#######################

func set_display_loading_panel_on_end_of_cutscene(arg_val):
	var old_val = display_loading_panel_on_end_of_cutscene
	display_loading_panel_on_end_of_cutscene = arg_val
	
	if old_val != display_loading_panel_on_end_of_cutscene:
		if display_loading_panel_on_end_of_cutscene:
			_initialize_cutscene_panel_loading()
			
		else:
			_attempt_end_cutscene_loading_panel()
		
		emit_signal("display_loading_panel_on_end_of_cutscene_changed", display_loading_panel_on_end_of_cutscene)

func _initialize_cutscene_panel_loading():
	if is_inside_tree():
		if !is_instance_valid(_cutscene_panel_loading):
			_cutscene_panel_loading = GUI_CutscenePanel_Loading_Scene.instance()
			_cutscene_panel_loading.visible = false
			#cutscene_loading_container.add_child(_cutscene_panel_loading)
			cutscene_loading_container.call_deferred("add_child", _cutscene_panel_loading)


##

func _attempt_end_cutscene():
	if display_loading_panel_on_end_of_cutscene:
		_show_loading_panel()
		
	else:
		_end_cutscene__thru_transition()


#

func _show_loading_panel():
	_is_currently_displaying_loading_panel = true
	set_process(true)
	_hide_left_and_right_buttons()
	block_change_cutscene_panel_page_cond_clauses.attempt_insert_clause(BlockChangeCutsceneClauseId.IS_IN_LOADING_SCENE)
	
	_cutscene_panel_loading.start_display()

func _attempt_end_cutscene_loading_panel():
	if _is_currently_displaying_loading_panel:
		if _current_loading_panel_show_duration >= MIN_LOADING_PANEL_SHOW_DURATION_FOR_EXIT:
			_end_cutscene_loading_panel__thru_transition()
		else:
			_requested__end_cutscene_loading_panel__thru_transition()
			


func _requested__end_cutscene_loading_panel__thru_transition():
	_requested_to_progress_thru_loading_panel_while_loading_while_below_min_show_duration = true


func _process(delta):
	if _is_currently_displaying_loading_panel: 
		_current_loading_panel_show_duration += delta
		
		if _requested_to_progress_thru_loading_panel_while_loading_while_below_min_show_duration:
			_end_cutscene_loading_panel__thru_transition()

#

func _end_cutscene_loading_panel__thru_transition():
	set_process(false)
	_cutscene_panel_loading.connect("fully_undisplayed", self, "_on_curr_loading_panel__fully_undisplayed", [], CONNECT_ONESHOT)
	_cutscene_panel_loading.start_end_display()

func _on_curr_loading_panel__fully_undisplayed():
	_is_currently_displaying_loading_panel = false
	_current_loading_panel_show_duration = 0
	_requested_to_progress_thru_loading_panel_while_loading_while_below_min_show_duration = 0
	_end_cutscene__thru_transition()



func _end_cutscene__thru_transition():
	var tweener = create_tween()
	tweener.set_parallel(false)
	tweener.tween_property(self, "modulate:a", 0.0, 0.5)
	tweener.tween_callback(self, "_on_end_of_cutscene__fade_out_finished")

func _on_end_of_cutscene__fade_out_finished():
	visible = false
	set_process_input(false)
	
	if queue_free_on_cutscene_end:
		queue_free()
	
	emit_signal("cutscene_ended")



func is_currently_displaying_loading_panel():
	return _is_currently_displaying_loading_panel


#############################################
# TREE ITEM Specific methods/vars

var control_tree
var is_unbackable = true

func on_control_received_focus():
	_ignore_inputs = true

func on_control_fully_visible():
	_ignore_inputs = false

func on_control_lost_focus():
	_ignore_inputs = true

func on_control_fully_invisible():
	_ignore_inputs = true
	

############
# END OF TREE ITEM Specific methods/vars
###########


