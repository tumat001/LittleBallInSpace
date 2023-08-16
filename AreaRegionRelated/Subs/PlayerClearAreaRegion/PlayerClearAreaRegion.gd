extends "res://AreaRegionRelated/Subs/PlayerDetectionAreaRegion/PlayerDetectionAreaRegion.gd"


func _ready():
	color_of_region_to_use = Color(1, 1, 1, 0.15)
	color_outline_of_region_to_use = Color(1, 1, 1, 0.3)
	outine_width_of_region_to_use = 3
	
	connect("player_entered_in_area", self, "_on_player_entered_in_area__CAR")
	


func _on_player_entered_in_area__CAR():
	var cleared_at_least_one : bool = false
	
	var launch_ball_modi = game_elements.player_modi_manager.get_modi_or_null(StoreOfPlayerModi.PlayerModiIds.LAUNCH_BALL)
	if launch_ball_modi != null:
		if launch_ball_modi.get_current_ball_count() != 0:
			launch_ball_modi.set_current_ball_count(0)
			
			cleared_at_least_one = true
	
	
	if cleared_at_least_one:
		AudioManager.helper__play_sound_effect__2d__major(StoreOfAudio.AudioIds.SFX_AreaRegion_ClearPlayer, game_elements.get_current_player().global_position, 1.0, null)
		


