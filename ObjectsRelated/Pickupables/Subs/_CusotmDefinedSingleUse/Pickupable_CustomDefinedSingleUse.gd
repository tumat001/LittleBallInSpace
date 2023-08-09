extends "res://ObjectsRelated/Pickupables/BasePickupables.gd"

signal player_entered_self__custom_defined()


func _on_player_entered_self(arg_player):
	._on_player_entered_self(arg_player)
	
	emit_signal("player_entered_self__custom_defined")
	
	_destroy_self__on_consume_by_player()


