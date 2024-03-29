extends "res://WorldRelated/AbstractWorldSlice.gd"


const DISTANCE_IN_SECONDS : float = 4.5
const LINEAR_VELOCITY__STRAIGHT_DOWN = Vector2(0, 100)

var _linear_velocity_to_use : Vector2
var _pos_to_put_player : Vector2

##

onready var spawn_position_2d = $PlayerSpawnCoordsContainer/SpawnPosition2D
onready var target_position_2d = $MiscContainer/TargetPos2D

##

func _init():
	can_spawn_player_when_no_current_player_in_GE = true
	

func as_test__override__do_insta_win():
	as_test__override__do_insta_win__template_capture_all_points()
	


func _on_after_game_start_init():
	._on_after_game_start_init()
	
	call_deferred("_connect_signals_with_energy_modi")
	
	#
	
	CameraManager.start_camera_zoom_change(CameraManager.ZOOM_OUT__DEFAULT__ZOOM_LEVEL, 0.0)


func _connect_signals_with_energy_modi():
	var energy_modi = game_elements.player_modi_manager.get_modi_or_null(StoreOfPlayerModi.PlayerModiIds.ENERGY)
	if energy_modi != null:
		var player = game_elements.get_current_player()
		player.block_health_change_cond_clauses.attempt_insert_clause(player.BlockHealthChangeClauseIds.IN_CUTSCENE)
		
		energy_modi.connect("recharged_from_no_energy", self, "_on_player_recharged_from_no_energy__at_game_start", [], CONNECT_ONESHOT)



func _on_player_recharged_from_no_energy__at_game_start():
	var player = game_elements.get_current_player()
	player.block_health_change_cond_clauses.remove_clause(player.BlockHealthChangeClauseIds.IN_CUTSCENE)
	



func _before_player_spawned_signal_emitted__chance_for_changes(arg_player):
	._before_player_spawned_signal_emitted__chance_for_changes(arg_player)
	
	_calculate_initial_linear_velocity_and_spawn_loc_pos()
	arg_player.apply_inside_induced_force(_linear_velocity_to_use)
	arg_player.global_position = _pos_to_put_player


func _calculate_initial_linear_velocity_and_spawn_loc_pos():
	var linear_velocity_saved__and_first_time = GameSaveManager.get_metadata_of_level_id(StoreOfLevels.LevelIds.LEVEL_01__STAGE_2)
	
	if linear_velocity_saved__and_first_time != null and linear_velocity_saved__and_first_time[2]:
		var x = linear_velocity_saved__and_first_time[0]
		var y = linear_velocity_saved__and_first_time[1]
		_linear_velocity_to_use = Vector2(x, y).rotated(PI/2)
		
		if _linear_velocity_to_use.y < 40:
			_linear_velocity_to_use = LINEAR_VELOCITY__STRAIGHT_DOWN
		
		var disp_from_target = -(_linear_velocity_to_use * DISTANCE_IN_SECONDS)
		spawn_position_2d.global_position = target_position_2d.global_position + disp_from_target
		
	else:
		spawn_position_2d.global_position = target_position_2d.global_position
	
	_pos_to_put_player = spawn_position_2d.global_position
	

func _on_player_spawned(arg_player):
	arg_player.apply_inside_induced_force(_linear_velocity_to_use)


#################

func _on_PDAR_OnLand_player_entered_in_area() -> void:
	CameraManager.reset_camera_zoom_level()
