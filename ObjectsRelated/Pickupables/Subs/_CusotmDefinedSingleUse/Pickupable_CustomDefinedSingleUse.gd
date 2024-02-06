extends "res://ObjectsRelated/Pickupables/BasePickupables.gd"


var is_destroy_self_on_player_entered : bool = true

signal player_entered_self__custom_defined()
signal restored_from_destroyed_from_rewind()

func _on_player_entered_self(arg_player):
	._on_player_entered_self(arg_player)
	
	emit_signal("player_entered_self__custom_defined")
	
	if is_destroy_self_on_player_entered:
		_destroy_self__on_consume_by_player()


func restore_from_destroyed_from_rewind():
	.restore_from_destroyed_from_rewind()
	
	emit_signal("restored_from_destroyed_from_rewind")
