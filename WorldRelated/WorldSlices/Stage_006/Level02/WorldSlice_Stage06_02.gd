extends "res://WorldRelated/AbstractWorldSlice.gd"


onready var vis_transition_fog_circ = $MiscContainer/VisTransitionFog_Circ

onready var base_enemy_01 = $ObjectContainer/BaseEnemy1
onready var base_enemy_02 = $ObjectContainer/BaseEnemy2

onready var fast_respawn_position_2d = $MiscContainer/FastRespawnPosition2D


onready var pickupable_star = $CoinsContainer/Pickupables_Coin

#

var _lifted_fog : bool = false
onready var base_enemies = [base_enemy_01, base_enemy_02]


#

func _init():
	can_spawn_player_when_no_current_player_in_GE = true
	

func as_test__override__do_insta_win():
	as_test__override__do_insta_win__template_capture_all_points()
	


func _on_after_game_start_init():
	._on_after_game_start_init()
	
	CameraManager.set_current_default_zoom_out_vec(Vector2(1, 1))
	
	for enemy in base_enemies:
		if is_instance_valid(enemy):
			enemy.prevent_draw_enemy_range_cond_clause.attempt_insert_clause(enemy.PreventDrawEnemyRangeClauseId.CUSTOM_WORLD_SLICE)


#######

#note: can be triggered more than once
func _on_PDAR_ForFastRespawn_player_entered_in_area():
	var data := []
	data.append(true)
	data.append(GameSaveManager.is_all_coins_collected_in_curr_level__tentative())
	
	SingletonsAndConsts.set_restart_only_persisting_data_of_level_id(StoreOfLevels.LevelIds.LEVEL_02__STAGE_6, data)


func _before_player_spawned_signal_emitted__chance_for_changes(arg_player):
	._before_player_spawned_signal_emitted__chance_for_changes(arg_player)
	
	if SingletonsAndConsts.if_level_id_has_restart_only_persisting_data(StoreOfLevels.LevelIds.LEVEL_02__STAGE_6):
		var data : Array = SingletonsAndConsts.get_restart_only_persisting_data_of_level_id(StoreOfLevels.LevelIds.LEVEL_02__STAGE_6)
		var is_fast_respawn : bool = data[0]
		var is_star_collected : bool = data[1]
		
		if is_fast_respawn:
			arg_player.global_position = fast_respawn_position_2d.global_position
			
		else:
			pass
			
		
		if is_star_collected:
			pickupable_star.collect_by_player()
			
		else:
			pass
			
		
	else:
		pass


############

func _on_Button_AntiFog_pressed(arg_is_pressed):
	if !_lifted_fog and arg_is_pressed:
		_lifted_fog = true
		
		vis_transition_fog_circ.lift_and_end_fog(2.0)
		vis_transition_fog_circ.deactivate_monitor_for_player()
		
		SingletonsAndConsts.current_rewind_manager.prevent_rewind_up_to_this_time_point()
		
		CameraManager.set_current_default_zoom_out_vec(CameraManager.ZOOM_OUT__DEFAULT__ZOOM_LEVEL)
		
		for enemy in base_enemies:
			if is_instance_valid(enemy):
				enemy.prevent_draw_enemy_range_cond_clause.remove_clause(enemy.PreventDrawEnemyRangeClauseId.CUSTOM_WORLD_SLICE)
		
		
		GameSettingsManager.set_custom_audio_id__unlocked_status(GameSettingsManager.CustomAudioIds.ENEMY__COMBAT__TAKE_DAMAGE, true)
		GameSettingsManager.set_custom_audio_id__unlocked_status(GameSettingsManager.CustomAudioIds.ENEMY__COMBAT__DESTROYED, true)
		



