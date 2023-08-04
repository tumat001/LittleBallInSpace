extends "res://AreaRegionRelated/BaseAreaRegion.gd"


func _ready():
	is_rewindable = false
	
	color_of_region_to_use = Color(192/255.0, 217/255.0, 2/255.0, 0.2)
	color_outline_of_region_to_use = Color(218/255.0, 164/255.0, 2/255.0, 0.2)
	outine_width_of_region_to_use = 3
	
	set_monitor_entities_remaining_in_area(true)
	
	connect("region__body_remained_in_area", self, "_on_region__body_remained_in_area__e")

func _pre_ready():
	._pre_ready()
	
	



func _on_region__body_remained_in_area__e(body, delta, tracked_delta):
	if body.get("is_player"):
		if body.is_player_modi_energy_set:
			var player_modi__energy = body.player_modi__energy
			player_modi__energy.inc_current_energy(player_modi__energy.get_max_energy() * body.IN_ENERGY_REGION__ENERGY_CHARGE_PER_SEC__PERCENT * delta)
			
	

