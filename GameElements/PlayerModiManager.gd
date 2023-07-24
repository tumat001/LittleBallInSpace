extends Node

const AbstractPlayerModi = preload("res://PlayerRelated/PlayerModi/AbstractPlayerModi.gd")



var game_elements
var current_player setget set_current_player


var _all_modis : Array

#

func set_current_player(arg_player):
	current_player = arg_player
	


#######

func add_modi_to_player(arg_modi : AbstractPlayerModi):
	arg_modi.apply_modification_to_player_and_game_elements(current_player, game_elements)
	_all_modis.append(arg_modi)

