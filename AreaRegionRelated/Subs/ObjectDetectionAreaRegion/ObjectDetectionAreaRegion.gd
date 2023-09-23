extends "res://AreaRegionRelated/BaseAreaRegion.gd"


signal object_entered_in_area(arg_obj)
signal object_exited_in_area(arg_obj)


func _ready():
	is_rewindable = false
	
	connect("region__body_entered_in_area", self, "_on_region__body_entered_in_area_o")
	connect("region__body_exited_from_area", self, "_on_region__body_exited_from_area_o")

func _on_region__body_entered_in_area_o(body):
	if body.get("is_class_type_base_object"):
		emit_signal("object_entered_in_area", body)
		

func _on_region__body_exited_from_area_o(body):
	if body.get("is_class_type_base_object"):
		emit_signal("object_exited_in_area", body)
		

