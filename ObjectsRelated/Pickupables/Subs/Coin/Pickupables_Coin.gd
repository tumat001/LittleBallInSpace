tool
extends "res://ObjectsRelated/Pickupables/BasePickupables.gd"


signal collected_by_player()
signal uncollected_by_player()


var coin_id : String


func _on_player_entered_self(arg_player):
	._on_player_entered_self(arg_player)
	
	#GameSaveManager.set_player_coin_count(GameSaveManager.player_coin_count + 1)
	#GameSaveManager.set_coin_id_in_level_as_collected(coin_id, SingletonsAndConsts.current_base_level_id, true)
	GameSaveManager.set_tentative_coin_id_collected_in_curr_level(coin_id, true)
	
	emit_signal("collected_by_player")
	
	#AudioManager.helper__play_sound_effect__2d(StoreOfAudio.AudioIds.SFX_Pickupable_Star_01, global_position, 1.0, null)
	
	_destroy_self__on_consume_by_player()

func restore_from_destroyed_from_rewind():
	.restore_from_destroyed_from_rewind()
	
	emit_signal("uncollected_by_player")
	
	#GameSaveManager.set_player_coin_count(GameSaveManager.player_coin_count - 1)
	#GameSaveManager.set_coin_id_in_level_as_collected(coin_id, SingletonsAndConsts.current_base_level_id, false)
	GameSaveManager.set_tentative_coin_id_collected_in_curr_level(coin_id, false)

#

