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



func _on_selection_screen__prompt_entered_into_level(arg_currently_hovered_tile, arg_currently_hovered_layout_ele_id):
	var level_details = arg_currently_hovered_tile.level_details
	var transition = play_transition__using_id(level_details.transition_id__entering_level__out)
	transition.connect("transition_finished", self, "_on_transition_out__to_level_finished", [level_details, transition])


func _on_transition_out__to_level_finished(arg_level_details, arg_old_transition):
	if is_instance_valid(gui__level_selection_whole_screen):
		gui__level_selection_whole_screen.visible = false
		gui__level_selection_whole_screen.queue_free()
	
	var game_elements = GameElements_Scene.instance()
	game_elements_container.add_child(game_elements)
	
	arg_old_transition.queue_free()
	var transition = play_transition__using_id(arg_level_details.transition_id__entering_level__in)


#

func switch_to_level_selection_scene__from_game_elements__as_win():
	pass
	

func switch_to_level_selection_scene__from_game_elements__as_lose():
	pass
	

func switch_to_level_selection_scene__from_game_elements__from_quit():
	pass
	


###########

func play_transition__using_id(arg_id):
	var transition_sprite = StoreOfTransitionSprites.construct_transition_sprite(arg_id)
	return play_transition(transition_sprite)

func play_transition(arg_transition):
	transition_container.add_child(arg_transition)
	arg_transition.start_transition()
	
	return arg_transition


