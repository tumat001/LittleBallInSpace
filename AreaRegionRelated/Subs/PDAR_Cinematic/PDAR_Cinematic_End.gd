extends "res://AreaRegionRelated/Subs/PlayerDetectionAreaRegion/PlayerDetectionAreaRegion.gd"

signal player_entered_and_cinematic_ended()


export(bool) var unhide_game_control_hud : bool = true
export(bool) var unhide_game_control_hud__use_tween : bool = true
export(bool) var unhide_game_control_hud__duration : float = 0.5

export(bool) var delete_rewind_history : bool = true


func _on_PDAR_Cinematic_player_entered_in_area():
	SingletonsAndConsts.current_game_elements.configure_game_state_for_end_of_cutscene_occurance(true)
	
	if unhide_game_control_hud:
		SingletonsAndConsts.current_game_front_hud.set_control_container_visibility(true, unhide_game_control_hud__use_tween, unhide_game_control_hud__duration)
	
	#
	var player = SingletonsAndConsts.current_game_elements.get_current_player()
	if player.has_force_action_id(player.ForceActionFlagIds.LEFT):
		player.remove_force_actions_flag_id(player.ForceActionFlagIds.LEFT)
	elif player.has_force_action_id(player.ForceActionFlagIds.RIGHT):
		player.remove_force_actions_flag_id(player.ForceActionFlagIds.RIGHT)
	
	#
	var player_modi_manager = SingletonsAndConsts.current_game_elements.player_modi_manager
	var energy_modi = player_modi_manager.get_modi_or_null(StoreOfPlayerModi.PlayerModiIds.ENERGY)
	if energy_modi != null:
		energy_modi.helper__set_clause_to_is_energy_not_deductable__PDAR_CINEMATIC(false)
	
	#
	if delete_rewind_history:
		SingletonsAndConsts.current_rewind_manager.prevent_rewind_up_to_this_time_point()
	
	
	#
	
	emit_signal("player_entered_and_cinematic_ended")
