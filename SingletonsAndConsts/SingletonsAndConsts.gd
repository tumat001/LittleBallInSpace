extends Node

#

signal current_rewind_manager_changed(arg_manager)
signal current_game_elements_changed(arg_elements)

#

var current_base_level
var current_base_level_id
var current_level_details

var current_level_layout_id

#

var current_master

var current_game_elements setget set_current_game_elements
var current_game_elements__other_node_hoster
var current_game_front_hud
var current_rewind_manager setget set_current_rewind_manager
var current_game_result_manager


#

var interrupt_return_to_screen_layout_panel__go_directly_to_level : bool = false
var level_id_to_go_directly_to__after_interrupt_to_return_to_screen_layout_panel

#

func set_current_game_elements(arg_elements):
	current_game_elements = arg_elements
	
	emit_signal("current_game_elements_changed", arg_elements)

func set_current_rewind_manager(arg_manager):
	current_rewind_manager = arg_manager
	
	emit_signal("current_rewind_manager_changed", arg_manager)

#

# called from GE
func initialize_current_level_configs_based_on_current_id():
	if !StoreOfLevels.is_level_id_exists(current_base_level_id):
		current_base_level_id = StoreOfLevels.DEFAULT_LEVEL_ID_FOR_EMPTY
		
	
	current_base_level = StoreOfLevels.generate_base_level_imp_new(current_base_level_id)
	current_base_level.level_id = current_base_level_id
	current_level_details = StoreOfLevels.generate_or_get_level_details_of_id(current_base_level_id)


########

func add_child_to_game_elements__other_node_hoster(arg_node):
	current_game_elements__other_node_hoster.add_child(arg_node)

func deferred_add_child_to_game_elements__other_node_hoster(arg_node):
	current_game_elements__other_node_hoster.call_deferred("add_child", arg_node)


##################################


func switch_to_level_selection_scene__from_game_elements__as_win():
	current_master.switch_to_level_selection_scene__from_game_elements__as_win()

func switch_to_level_selection_scene__from_game_elements__as_lose():
	current_master.switch_to_level_selection_scene__from_game_elements__as_lose()

func switch_to_level_selection_scene__from_game_elements__from_quit():
	current_master.switch_to_level_selection_scene__from_game_elements__from_quit()

func switch_to_game_elements__from_game_elements__from_restart():
	current_master.switch_to_game_elements__from_game_elements__from_restart()



