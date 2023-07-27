extends Node

const AbstractPlayerModi = preload("res://PlayerRelated/PlayerModi/AbstractPlayerModi.gd")

#

signal modi_added_to_player(arg_modi)

#

var game_elements
var current_player setget set_current_player


var _all_modis : Array

#

func set_current_player(arg_player):
	current_player = arg_player
	


#######

func add_modi_to_player(arg_modi : AbstractPlayerModi):
	_all_modis.append(arg_modi)
	
	arg_modi.apply_modification_to_player_and_game_elements(current_player, game_elements)
	
	if arg_modi.modi_id == StoreOfPlayerModi.PlayerModiIds.ENERGY:
		current_player.set_player_modi_energy__from_modi_manager(arg_modi)
	
	emit_signal("modi_added_to_player", arg_modi)

