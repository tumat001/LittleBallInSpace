extends "res://AreaRegionRelated/Subs/PlayerDetectionAreaRegion/PlayerDetectionAreaRegion.gd"


export(bool) var hide_game_control_hud : bool = false
export(bool) var hide_game_control_hud__use_tween : bool = true
export(float) var hide_game_control_hud__duration : float = 0.75

export(bool) var stop_player_movement : bool = false
export(bool) var reset_cam_zoom_level : bool = true

export(bool) var force_action_natural_movement : bool = false

export(bool) var make_player_energy_undeductable : bool = false


export(bool) var force_action_natural_movement__right : bool = false


func _on_PDAR_Cinematic_player_entered_in_area():
	SingletonsAndConsts.current_game_elements.configure_game_state_for_cutscene_occurance(stop_player_movement, reset_cam_zoom_level)
	
	if hide_game_control_hud:
		SingletonsAndConsts.current_game_front_hud.set_control_container_visibility(false, hide_game_control_hud__use_tween, hide_game_control_hud__duration)
	
	var player = SingletonsAndConsts.current_game_elements.get_current_player()
	
	if force_action_natural_movement:
		if player.is_curr_mov_velocity__left():
			player.add_force_actions_flag_id(player.ForceActionFlagIds.LEFT)
		elif player.is_curr_mov_velocity__right():
			player.add_force_actions_flag_id(player.ForceActionFlagIds.RIGHT)
	
	if force_action_natural_movement__right:
		player.add_force_actions_flag_id(player.ForceActionFlagIds.RIGHT)
	
	if make_player_energy_undeductable:
		var player_modi_manager = SingletonsAndConsts.current_game_elements.player_modi_manager
		var energy_modi = player_modi_manager.get_modi_or_null(StoreOfPlayerModi.PlayerModiIds.ENERGY)
		if energy_modi != null:
			energy_modi.helper__set_clause_to_is_energy_not_deductable__PDAR_CINEMATIC(true)
	
	

