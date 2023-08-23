extends "res://AreaRegionRelated/Subs/PlayerDetectionAreaRegion/PlayerDetectionAreaRegion.gd"


func _ready():
	connect("player_entered_in_area", self, "_on_player_entered_area__pdar_queue_free_tile_fragments")
	

func _on_player_entered_area__pdar_queue_free_tile_fragments():
	SingletonsAndConsts.queue_free_all_glass_fragments()
	

