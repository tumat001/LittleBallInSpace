extends "res://AreaRegionRelated/BaseAreaRegion.gd"


func _ready():
	is_rewindable = false
	
	color_of_region_to_use = Color(255/255.0, 128/255.0, 0/255.0, 0.2)
	color_outline_of_region_to_use = Color(146/255.0, 55/255.0, 2/255.0, 0.2)
	outine_width_of_region_to_use = 3
	
	connect("region__body_entered_in_area", self, "_on_region__body_entered_in_area_o")


func _on_region__body_entered_in_area_o(body):
	if body.get("is_class_type_base_object"):
		body.queue_free()
	
