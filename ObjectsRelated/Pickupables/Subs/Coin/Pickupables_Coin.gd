tool
extends "res://ObjectsRelated/Pickupables/BasePickupables.gd"



var coin_id : int


func _on_player_entered_self(arg_player):
	._on_player_entered_self(arg_player)
	
	#GameSaveManager.set_player_coin_count(GameSaveManager.player_coin_count + 1)
	GameSaveManager.set_coin_id_in_level_as_collected(coin_id, SingletonsAndConsts.current_base_level_id, true)

func restore_from_destroyed_from_rewind():
	.restore_from_destroyed_from_rewind()
	
	#GameSaveManager.set_player_coin_count(GameSaveManager.player_coin_count - 1)
	GameSaveManager.set_coin_id_in_level_as_collected(coin_id, SingletonsAndConsts.current_base_level_id, false)

#

