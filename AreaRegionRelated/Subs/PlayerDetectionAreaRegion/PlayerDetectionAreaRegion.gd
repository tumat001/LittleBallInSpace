extends "res://AreaRegionRelated/BaseAreaRegion.gd"



signal player_entered_in_area()
signal player_exited_in_area()

#

export(bool) var triggerable_only_once : bool = false
var _already_triggered__enter : bool = false
var _already_triggered__exit : bool

#

func _ready():
	is_rewindable = false
	
	connect("region__body_entered_in_area", self, "_on_region__body_entered_in_area__e")
	connect("region__body_exited_from_area", self, "_on_region__body_exited_from_area__e")


func _on_region__body_entered_in_area__e(body):
	if body.get("is_player"):
		if (triggerable_only_once and !_already_triggered__enter) or !triggerable_only_once:
			_already_triggered__enter = true
			emit_signal("player_entered_in_area")
		

func _on_region__body_exited_from_area__e(body):
	if body.get("is_player"):
		if (triggerable_only_once and !_already_triggered__exit) or !triggerable_only_once:
			_already_triggered__exit = true
			emit_signal("player_exited_in_area")
		
	

