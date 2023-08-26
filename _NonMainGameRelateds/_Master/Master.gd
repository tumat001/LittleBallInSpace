extends Node

const GUI_LevelSelectionWholeScreen = preload("res://_NonMainGameRelateds/_LevelSelectionRelated/GUIRelateds/GUI_LevelSelectionWholeScreen/GUI_LevelSelectionWholeScreen.gd")
const GUI_LevelSelectionWholeScreen_Scene = preload("res://_NonMainGameRelateds/_LevelSelectionRelated/GUIRelateds/GUI_LevelSelectionWholeScreen/GUI_LevelSelectionWholeScreen.tscn")
const StoreOfTransitionSprites = preload("res://_NonMainGameRelateds/_Master/TransitionsRelated/StoreOfTransitionSprites.gd")

const GameElements = preload("res://GameElements/GameElements.gd")
const GameElements_Scene = preload("res://GameElements/GameElements.tscn")


const FirstTimeQuestionWSPanel = preload("res://_NonMainGameRelateds/_PreGameHUDRelated/FirstTimeQuestionWSPanel/FirstTimeQuestionWSPanel.gd")
const FirstTimeQuestionWSPanel_Scene = preload("res://_NonMainGameRelateds/_PreGameHUDRelated/FirstTimeQuestionWSPanel/FirstTimeQuestionWSPanel.tscn")

const EndingSummaryWSPanel = preload("res://_NonMainGameRelateds/_PreGameHUDRelated/EndingSummaryWSP/EndingSummaryWSP.gd")
const EndingSummaryWSPanel_Scene = preload("res://_NonMainGameRelateds/_PreGameHUDRelated/EndingSummaryWSP/EndingSummaryWSP.tscn")


#

const screen_size = Vector2(960, 540)

#

var gui__level_selection_whole_screen : GUI_LevelSelectionWholeScreen



var _level_id_to_mark_as_finish__and_display_win_vic_on
var _level_ids_to_mark_as_finish__as_additional__and_display_win_vic_on : Array

var _is_transitioning : bool
var _is_in_game_or_loading_to_game : bool
var _is_playing_victory_animations : bool

#

var first_time_question_ws_panel : FirstTimeQuestionWSPanel
var ending_summary_ws_panel : EndingSummaryWSPanel

#

onready var game_elements_container = $GameElementsContainer
onready var layout_selection_container = $LayoutSelectionContainer
onready var transition_container = $TransitionContainer

onready var master_menu_control_tree = $MasterMenuControlTree

#

func _enter_tree():
	SingletonsAndConsts.current_master = self


#

func _ready():
	#Temp for quick testing of lvls
	#todo
	if (true):
		#SingletonsAndConsts.current_base_level_id = StoreOfLevels.LevelIds.LEVEL_05__STAGE_4
		#SingletonsAndConsts.current_base_level_id = StoreOfLevels.LevelIds.TEST
		SingletonsAndConsts.current_base_level_id = StoreOfLevels.LevelIds.LEVEL_04
		
		SingletonsAndConsts.initialize_current_level_configs_based_on_current_id()
		
		var game_elements = GameElements_Scene.instance()
		game_elements_container.add_child(game_elements)
		return
	#
	
	if GameSaveManager.first_time_opening_game:
		_do_appropriate_action__for_first_time()
		
	else:
		load_and_show_layout_selection_whole_screen()
		


func _do_appropriate_action__for_first_time():
	#var first_stage_details = StoreOfLevels.generate_or_get_level_details_of_id(StoreOfLevels.LevelIds.LEVEL_01)
	#instant_start_game_elements__with_level_details(first_stage_details)
	#GameSaveManager.first_time_opening_game = false
	
	
	_show_first_time_question_ws_panel()


func load_and_show_layout_selection_whole_screen():
	gui__level_selection_whole_screen = GUI_LevelSelectionWholeScreen_Scene.instance()
	layout_selection_container.add_child(gui__level_selection_whole_screen)
	
	gui__level_selection_whole_screen.connect("prompt_entered_into_level", self, "_on_selection_screen__prompt_entered_into_level")
	gui__level_selection_whole_screen.show_level_layout__last_saved_in_save_manager()


###

func _on_selection_screen__prompt_entered_into_level(arg_currently_hovered_tile, arg_currently_hovered_layout_ele_id):
	if !_is_in_game_or_loading_to_game:
		var level_details = arg_currently_hovered_tile.level_details
		start_game_elements__with_level_details(level_details, arg_currently_hovered_tile.get_center_position())
		
		AudioManager.helper__play_sound_effect__plain__major(StoreOfAudio.AudioIds.SFX_LevelSelected_01, 1.0, null)
		

func start_game_elements__with_level_details(level_details, arg_circle_pos):
	_is_in_game_or_loading_to_game = true
	
	#var transition = play_transition__using_id(level_details.transition_id__entering_level__out)
	var transition = construct_transition__using_id(level_details.transition_id__entering_level__out)
	transition.circle_center = arg_circle_pos #arg_currently_hovered_tile.get_center_position()
	transition.connect("transition_finished", self, "_on_transition_out__to_level_finished", [level_details, transition, transition.circle_center])
	play_transition(transition)
	

func _on_transition_out__to_level_finished(arg_level_details, arg_old_transition, arg_center_pos):
	arg_old_transition.queue_free()
	
	instant_start_game_elements__with_level_details(arg_level_details, arg_center_pos)
#	if is_instance_valid(gui__level_selection_whole_screen):
#		gui__level_selection_whole_screen.visible = false
#		gui__level_selection_whole_screen.queue_free()
#
#	var game_elements = GameElements_Scene.instance()
#	game_elements_container.add_child(game_elements)
#
#	arg_old_transition.queue_free()
#	#var transition = play_transition__using_id(arg_level_details.transition_id__entering_level__in)
#	var transition = construct_transition__using_id(arg_level_details.transition_id__entering_level__in)
#	transition.circle_center = arg_center_pos
#	transition.queue_free_on_end_of_transition = true
#	play_transition(transition)


func instant_start_game_elements__with_level_details(level_details, arg_circle_pos = screen_size/2):
	SingletonsAndConsts.current_base_level_id = level_details.level_id
	_is_in_game_or_loading_to_game = true
	SingletonsAndConsts.initialize_current_level_configs_based_on_current_id()
	
	#
	
	var curr_level = SingletonsAndConsts.current_base_level
	curr_level.apply_modification__before_game_elements_added()
	
	#
	
	## playlist/audio related
	var BGM_playlist_id_to_play = level_details.BGM_playlist_id_to_use__on_level_start
	if !StoreOfAudio.is_BGM_playlist_id_playing(BGM_playlist_id_to_play):
		StoreOfAudio.BGM_playlist_catalog.start_play_audio_play_list(BGM_playlist_id_to_play)
	
	#
	
	if is_instance_valid(gui__level_selection_whole_screen):
		gui__level_selection_whole_screen.visible = false
		gui__level_selection_whole_screen.queue_free()
	
	#TODO make use of asyncloader eventually
	var game_elements = GameElements_Scene.instance()
	game_elements_container.add_child(game_elements)
	
	var transition = construct_transition__using_id(level_details.transition_id__entering_level__in)
	transition.circle_center = arg_circle_pos
	transition.queue_free_on_end_of_transition = true
	play_transition(transition)


###

func switch_to_level_selection_scene__from_game_elements__as_win():
	_is_in_game_or_loading_to_game = false
	_level_id_to_mark_as_finish__and_display_win_vic_on = SingletonsAndConsts.current_base_level_id
	_level_ids_to_mark_as_finish__as_additional__and_display_win_vic_on = SingletonsAndConsts.current_level_details.additional_level_ids_to_mark_as_complete.duplicate()
	SingletonsAndConsts.attempt_remove_restart_only_persisting_data_of_level_id(SingletonsAndConsts.current_base_level_id)
	GameSaveManager.clear_coin_ids_in_tentative()
	
	var transition_id = SingletonsAndConsts.current_level_details.transition_id__exiting_level__out
	var transition = play_transition__using_id(transition_id)
	
	var next_transition_id = SingletonsAndConsts.current_level_details.transition_id__exiting_level__in
	transition.connect("transition_finished", self, "_on_transition_out__from_GE__finished", [next_transition_id, transition, true])


func switch_to_level_selection_scene__from_game_elements__as_lose():
	_is_in_game_or_loading_to_game = false
	SingletonsAndConsts.attempt_remove_restart_only_persisting_data_of_level_id(SingletonsAndConsts.current_base_level_id)
	GameSaveManager.remove_official_coin_ids_collected_from_tentative()
	
	var transition_id = SingletonsAndConsts.current_level_details.transition_id__exiting_level__out__for_lose
	var transition = play_transition__using_id(transition_id)
	
	var next_transition_id = SingletonsAndConsts.current_level_details.transition_id__exiting_level__in__for_lose
	transition.connect("transition_finished", self, "_on_transition_out__from_GE__finished", [next_transition_id, transition, false])

func switch_to_level_selection_scene__from_game_elements__from_quit():
	_is_in_game_or_loading_to_game = false
	SingletonsAndConsts.attempt_remove_restart_only_persisting_data_of_level_id(SingletonsAndConsts.current_base_level_id)
	GameSaveManager.remove_official_coin_ids_collected_from_tentative()
	
	var transition_id = SingletonsAndConsts.current_level_details.transition_id__exiting_level__out__for_quit
	var transition = play_transition__using_id(transition_id)
	
	var next_transition_id = SingletonsAndConsts.current_level_details.transition_id__exiting_level__in__for_quit
	transition.connect("transition_finished", self, "_on_transition_out__from_GE__finished", [next_transition_id, transition, false])

func switch_to_game_elements__from_game_elements__from_restart():
	GameSaveManager.remove_official_coin_ids_collected_from_tentative()
	
	#_on_transition_out__from_GE__finished__for_restart()
	
	AudioManager.helper__play_sound_effect__plain__major(StoreOfAudio.AudioIds.SFX_Restart_01, 1.0, null)
	
	var transition_id = SingletonsAndConsts.current_level_details.transition_id__exiting_level__out__for_quit
	var transition = play_transition__using_id(transition_id)
	transition.queue_free_on_end_of_transition = true
	
	var next_transition_id = SingletonsAndConsts.current_level_details.transition_id__exiting_level__in__for_quit
	transition.connect("transition_finished", self, "_on_transition_out__from_GE__finished__for_restart", [next_transition_id, transition])
	
	


func _on_transition_out__from_GE__finished(arg_next_transition_id, arg_curr_transition, arg_is_win : bool):
	if SingletonsAndConsts.interrupt_return_to_screen_layout_panel__go_directly_to_level:
		SingletonsAndConsts.current_game_elements.connect("tree_exited", self, "_on_curr_game_elements_tree_exited")
	
	SingletonsAndConsts.current_game_elements.queue_free()
	
	
	if !SingletonsAndConsts.show_end_game_result_pre_hud:
		if !SingletonsAndConsts.interrupt_return_to_screen_layout_panel__go_directly_to_level:
			load_and_show_layout_selection_whole_screen()
			
			arg_curr_transition.queue_free()
			var transition = play_transition__using_id(arg_next_transition_id)
			transition.queue_free_on_end_of_transition = true
			
			if arg_is_win and !GameSaveManager.is_level_id_finished(SingletonsAndConsts.current_base_level_id):
				call_deferred("_attempt_unlock_and_play_anim_on_victory__on_level_id")
			
		else:
			arg_curr_transition.queue_free()
			
			if !GameSaveManager.is_level_id_finished(SingletonsAndConsts.current_base_level_id):
				_make_level_id_mark_as_finished(_level_id_to_mark_as_finish__and_display_win_vic_on)
		
		
	else:
		arg_curr_transition.queue_free()
		
		if !GameSaveManager.is_level_id_finished(SingletonsAndConsts.current_base_level_id):
			_make_level_id_mark_as_finished(_level_id_to_mark_as_finish__and_display_win_vic_on)
		
		#_show_ending_summary_wsp()
	
	SingletonsAndConsts.interrupt_return_to_screen_layout_panel__go_directly_to_level = false
	

func _on_curr_game_elements_tree_exited():
	var level_details = StoreOfLevels.generate_or_get_level_details_of_id(SingletonsAndConsts.level_id_to_go_directly_to__after_interrupt_to_return_to_screen_layout_panel)
	#instant_start_game_elements__with_level_details(level_details)
	call_deferred("instant_start_game_elements__with_level_details", level_details)
	
	



func _attempt_unlock_and_play_anim_on_victory__on_level_id():
	if _level_id_to_mark_as_finish__and_display_win_vic_on != -1:
		call_deferred("_unlock_and_play_anim_on_victory__on_level_id")
		

func _unlock_and_play_anim_on_victory__on_level_id():
	var is_playing_anim = gui__level_selection_whole_screen.play_victory_animation_on_level_id(_level_id_to_mark_as_finish__and_display_win_vic_on)
	
	if is_playing_anim:
		_is_playing_victory_animations = true
		gui__level_selection_whole_screen.connect("triggered_circular_burst_on_curr_ele_for_victory", self, "_on_triggered_circular_burst_on_curr_ele_for_victory", [], CONNECT_ONESHOT)
		if !gui__level_selection_whole_screen.is_connected("_on_triggered_circular_burst_on_curr_ele_for_victory__as_additionals", self, "_on_triggered_circular_burst_on_curr_ele_for_victory__as_additionals"):
			gui__level_selection_whole_screen.connect("_on_triggered_circular_burst_on_curr_ele_for_victory__as_additionals", self, "_on_triggered_circular_burst_on_curr_ele_for_victory__as_additionals", [], CONNECT_ONESHOT)
	else:
		#AudioManager.helper__play_sound_effect__plain__major(StoreOfAudio.AudioIds.SFX_LevelUnlock_Burst_01, 1.0, null)
		_make_level_id_mark_as_finished(_level_id_to_mark_as_finish__and_display_win_vic_on)
		_level_id_to_mark_as_finish__and_display_win_vic_on = -1
	
	#_level_id_to_mark_as_finish__and_display_win_vic_on = -1


func _on_triggered_circular_burst_on_curr_ele_for_victory__as_additionals(arg_tile_eles):
	AudioManager.helper__play_sound_effect__plain__major(StoreOfAudio.AudioIds.SFX_LevelUnlock_Burst_01, 1.0, null)
	
	for ele in arg_tile_eles:
		_make_level_id_mark_as_finished(ele.level_details.level_id)
	_level_ids_to_mark_as_finish__as_additional__and_display_win_vic_on = []
	
	_is_playing_victory_animations = false

func _on_triggered_circular_burst_on_curr_ele_for_victory(arg_tile_ele_for_playing_victory_animation_for, arg_level_details):
	AudioManager.helper__play_sound_effect__plain__major(StoreOfAudio.AudioIds.SFX_LevelUnlock_Burst_01, 1.0, null)
	_make_level_id_mark_as_finished(arg_level_details.level_id)
	_level_id_to_mark_as_finish__and_display_win_vic_on = -1
	
	if _level_ids_to_mark_as_finish__as_additional__and_display_win_vic_on.size() == 0:
		_is_playing_victory_animations = false
	else:
		gui__level_selection_whole_screen.play_victory_animation_on_level_ids__as_additonals(_level_ids_to_mark_as_finish__as_additional__and_display_win_vic_on)

func _make_level_id_mark_as_finished(arg_level_id):
	GameSaveManager.set_level_id_status_completion(arg_level_id, GameSaveManager.LEVEL_OR_LAYOUT_COMPLETION_STATUS__FINISHED)
	
	



func _on_transition_out__from_GE__finished__for_restart(arg_next_transition_id, arg_curr_transition):
	if is_instance_valid(SingletonsAndConsts.current_game_elements):
		SingletonsAndConsts.current_game_elements.attempt_quit_game__by_queue_freeing()
	
	start_game_elements__with_level_details(SingletonsAndConsts.current_level_details, screen_size / 2)
	


###########

func play_transition__using_id(arg_id):
	var transition_sprite = StoreOfTransitionSprites.construct_transition_sprite(arg_id)
	return play_transition(transition_sprite)


func construct_transition__using_id(arg_id):
	return StoreOfTransitionSprites.construct_transition_sprite(arg_id)

func play_transition(arg_transition):
	_is_transitioning = true
	transition_container.add_child(arg_transition)
	arg_transition.start_transition()
	arg_transition.connect("transition_finished", self, "_on_transition_finished__for_state_tracking")
	
	return arg_transition

func _on_transition_finished__for_state_tracking():
	_is_transitioning = false

#

func play_transition__alter_no_states(arg_transition, arg_queue_free_at_end : bool = true):
	arg_transition.queue_free_on_end_of_transition = arg_queue_free_at_end
	
	transition_container.add_child(arg_transition)
	arg_transition.start_transition()
	

#


func is_playing_any_transition():
	return _is_transitioning

##########

func _unhandled_key_input(event):
	if !_is_transitioning:
		if !is_instance_valid(SingletonsAndConsts.current_game_elements):
			if event.is_action_pressed("ui_cancel"):
				master_menu_control_tree.show_main_page()
				get_viewport().set_input_as_handled()


################################################

func _show_first_time_question_ws_panel():
	first_time_question_ws_panel = FirstTimeQuestionWSPanel_Scene.instance()
	add_child(first_time_question_ws_panel)
	move_child(first_time_question_ws_panel, 0)
	
	first_time_question_ws_panel.connect("question_panel_finished", self, "_on_question_panel_finished")

func _on_question_panel_finished():
	first_time_question_ws_panel.queue_free()
	
	var first_stage_details = StoreOfLevels.generate_or_get_level_details_of_id(StoreOfLevels.LevelIds.LEVEL_01)
	instant_start_game_elements__with_level_details(first_stage_details)
	#GameSaveManager.first_time_opening_game = false
	


##

func can_level_layout_move_cursor():
	return !_is_transitioning and !_is_playing_victory_animations and !_is_in_game_or_loading_to_game
	


#################

func show_ending_summary_wsp():
	if !is_instance_valid(ending_summary_ws_panel):
		ending_summary_ws_panel = EndingSummaryWSPanel_Scene.instance()
		
		add_child(ending_summary_ws_panel)
		move_child(ending_summary_ws_panel, 0)
		
		ending_summary_ws_panel.connect("ending_panel_finished", self, "_on_question_panel_finished")




