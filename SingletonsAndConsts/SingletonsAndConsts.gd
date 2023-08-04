extends Node


var current_base_level
var current_base_level_id
var current_level_details

#

var current_root_of_game_elements
var current_game_elements
var current_game_elements__other_node_hoster
var current_game_front_hud
var current_rewind_manager
var current_game_result_manager


#

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


func switch_to_level_selection_scene__from_game_elements():
	#todo
	print("Yayy end")
	


