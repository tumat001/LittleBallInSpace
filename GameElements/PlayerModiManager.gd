extends Node

const AbstractPlayerModi = preload("res://PlayerRelated/PlayerModi/AbstractPlayerModi.gd")

#

signal before_modi_is_configured(arg_modi)
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
	
	emit_signal("before_modi_is_configured", arg_modi)
	
	arg_modi.apply_modification_to_player_and_game_elements(current_player, game_elements)
	
	if arg_modi.modi_id == StoreOfPlayerModi.PlayerModiIds.ENERGY:
		current_player.set_player_modi_energy__from_modi_manager(arg_modi)
	
	emit_signal("modi_added_to_player", arg_modi)


func has_modi(arg_modi_id):
	for modi in _all_modis:
		if modi.modi_id == arg_modi_id:
			return true
	
	return false

func get_modi_or_null(arg_modi_id):
	for modi in _all_modis:
		if modi.modi_id == arg_modi_id:
			return modi
	
	return null



