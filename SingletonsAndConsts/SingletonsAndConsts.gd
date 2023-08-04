extends Node


var current_game_elements
var current_game_elements__other_node_hoster

var current_game_front_hud

var current_rewind_manager

var current_game_result_manager



func add_child_to_game_elements__other_node_hoster(arg_node):
	current_game_elements__other_node_hoster.add_child(arg_node)

func deferred_add_child_to_game_elements__other_node_hoster(arg_node):
	current_game_elements__other_node_hoster.call_deferred("add_child", arg_node)


