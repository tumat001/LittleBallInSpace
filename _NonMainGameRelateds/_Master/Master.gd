extends Node

const GUI_LevelSelectionWholeScreen = preload("res://_NonMainGameRelateds/_LevelSelectionRelated/GUIRelateds/GUI_LevelSelectionWholeScreen/GUI_LevelSelectionWholeScreen.gd")
const GUI_LevelSelectionWholeScreen_Scene = preload("res://_NonMainGameRelateds/_LevelSelectionRelated/GUIRelateds/GUI_LevelSelectionWholeScreen/GUI_LevelSelectionWholeScreen.tscn")
const StoreOfTransitionSprites = preload("res://_NonMainGameRelateds/_Master/TransitionsRelated/StoreOfTransitionSprites.gd")

const GameElements = preload("res://GameElements/GameElements.gd")
const GameElements_Scene = preload("res://GameElements/GameElements.tscn")


#

var gui__level_selection_whole_screen : GUI_LevelSelectionWholeScreen

#

onready var game_elements_container = $GameElementsContainer
onready var layout_selection_container = $LayoutSelectionContainer
onready var transition_container = $TransitionContainer

#

func _enter_tree():
	SingletonsAndConsts.current_master = self


#

func _ready():
	#TODO Temp for quick testing of lvls
	if (false):
		SingletonsAndConsts.current_base_level_id = StoreOfLevels.LevelIds.LEVEL_05
		
		var game_elements = GameElements_Scene.instance()
		game_elements_container.add_child(game_elements)
		return
	#
	
	if GameSaveManager.first_time_opening_game:
		_do_appropriate_action__for_first_time()
		
	else:
		load_and_show_layout_selection_whole_screen()
		


# go straight to very first stage
func _do_appropriate_action__for_first_time():
	#TODO change this eventually
	load_and_show_layout_selection_whole_screen()
	


func load_and_show_layout_selection_whole_screen():
	gui__level_selection_whole_screen = GUI_LevelSelectionWholeScreen_Scene.instance()
	layout_selection_container.add_child(gui__level_selection_whole_screen)
	
	gui__level_selection_whole_screen.connect("prompt_entered_into_level", self, "_on_selection_screen__prompt_entered_into_level")
	gui__level_selection_whole_screen.show_level_layout__last_saved_in_save_manager()


###

func _on_selection_screen__prompt_entered_into_level(arg_currently_hovered_tile, arg_currently_hovered_layout_ele_id):
	var level_details = arg_currently_hovered_tile.level_details
	SingletonsAndConsts.current_base_level_id = level_details.level_id
	#var transition = play_transition__using_id(level_details.transition_id__entering_level__out)
	var transition = construct_transition__using_id(level_details.transition_id__entering_level__out)
	transition.circle_center = arg_currently_hovered_tile.get_center_position()
	transition.connect("transition_finished", self, "_on_transition_out__to_level_finished", [level_details, transition, transition.circle_center])
	play_transition(transition)

func _on_transition_out__to_level_finished(arg_level_details, arg_old_transition, arg_center_pos):
	if is_instance_valid(gui__level_selection_whole_screen):
		gui__level_selection_whole_screen.visible = false
		gui__level_selection_whole_screen.queue_free()
	
	#TODO make use of asyncloader eventually
	var game_elements = GameElements_Scene.instance()
	game_elements_container.add_child(game_elements)
	
	arg_old_transition.queue_free()
	#var transition = play_transition__using_id(arg_level_details.transition_id__entering_level__in)
	var transition = construct_transition__using_id(arg_level_details.transition_id__entering_level__in)
	transition.circle_center = arg_center_pos
	transition.queue_free_on_end_of_transition = true
	play_transition(transition)

##

func switch_to_level_selection_scene__from_game_elements__as_win():
	var transition_id = SingletonsAndConsts.current_level_details.transition_id__exiting_level__out
	var transition = play_transition__using_id(transition_id)
	
	var next_transition_id = SingletonsAndConsts.current_level_details.transition_id__exiting_level__in
	transition.connect("transition_finished", self, "_on_transition_out__from_GE__finished", [next_transition_id, transition])

func switch_to_level_selection_scene__from_game_elements__as_lose():
	var transition_id = SingletonsAndConsts.current_level_details.transition_id__exiting_level__out__for_lose
	var transition = play_transition__using_id(transition_id)
	
	var next_transition_id = SingletonsAndConsts.current_level_details.transition_id__exiting_level__in__for_lose
	transition.connect("transition_finished", self, "_on_transition_out__from_GE__finished", [next_transition_id, transition])

func switch_to_level_selection_scene__from_game_elements__from_quit():
	var transition_id = SingletonsAndConsts.current_level_details.transition_id__exiting_level__out__for_quit
	var transition = play_transition__using_id(transition_id)
	
	var next_transition_id = SingletonsAndConsts.current_level_details.transition_id__exiting_level__in__for_quit
	transition.connect("transition_finished", self, "_on_transition_out__from_GE__finished", [next_transition_id, transition])


func _on_transition_out__from_GE__finished(arg_next_transition_id, arg_curr_transition):
	SingletonsAndConsts.current_game_elements.queue_free()
	
	load_and_show_layout_selection_whole_screen()
	
	arg_curr_transition.queue_free()
	var transition = play_transition__using_id(arg_next_transition_id)
	transition.queue_free_on_end_of_transition = true


###########

func play_transition__using_id(arg_id):
	var transition_sprite = StoreOfTransitionSprites.construct_transition_sprite(arg_id)
	return play_transition(transition_sprite)


func construct_transition__using_id(arg_id):
	return StoreOfTransitionSprites.construct_transition_sprite(arg_id)

func play_transition(arg_transition):
	transition_container.add_child(arg_transition)
	arg_transition.start_transition()
	
	return arg_transition


