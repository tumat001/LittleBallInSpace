extends "res://AreaRegionRelated/BaseAreaRegion.gd"


#

export(bool) var is_hidden_and_silent : bool = false

#

func _ready():
	is_rewindable = false
	
	if !is_hidden_and_silent:
		color_of_region_to_use = Color(255/255.0, 128/255.0, 0/255.0, 0.2)
		color_outline_of_region_to_use = Color(146/255.0, 55/255.0, 2/255.0, 0.2)
		outine_width_of_region_to_use = 3
	
	connect("region__body_entered_in_area", self, "_on_region__body_entered_in_area_o")


func _on_region__body_entered_in_area_o(body):
	if body.get("is_class_type_base_object"):
		if !is_hidden_and_silent:
			AudioManager.helper__play_sound_effect__2d(StoreOfAudio.AudioIds.SFX_AreaRegion_ObjectDestroyed, body.global_position, 1.5, null)
		
		#body.queue_free()
		body.destroy_self_caused_by_destroying_area_region(self)
