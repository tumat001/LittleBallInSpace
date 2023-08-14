extends "res://WorldRelated/AbstractWorldSlice.gd"


const DISTANCE_IN_SECONDS : float = 3.0
const LINEAR_VELOCITY__STRAIGHT_DOWN = Vector2(0, 100)

var _linear_velocity_to_use : Vector2

##

onready var spawn_position_2d = $PlayerSpawnCoordsContainer/SpawnPosition2D
onready var target_position_2d = $MiscContainer/TargetPos2D

onready var PDAR_initial_convo_trigger = $MiscContainer/PDAR_InitialConvo

##

func _init():
	can_spawn_player_when_no_current_player_in_GE = true
	


func _on_after_game_start_init():
	._on_after_game_start_init()
	
	game_elements.connect("player_spawned", self, "_on_player_spawned", [], CONNECT_ONESHOT)
	
	PDAR_initial_convo_trigger.connect("player_entered_in_area", self, "_on_player_entered_in_area__PDAR_initial_convo", [], CONNECT_ONESHOT)

func _calculate_initial_linear_velocity_and_spawn_loc_pos():
	var linear_velocity_saved__and_first_time = GameSaveManager.get_metadata_of_level_id(StoreOfLevels.LevelIds.LEVEL_01__STAGE_2)
	
	if linear_velocity_saved__and_first_time[1]:
		_linear_velocity_to_use = linear_velocity_saved__and_first_time[0].rotated(PI/2)
		
		if _linear_velocity_to_use.y < 40:
			_linear_velocity_to_use = LINEAR_VELOCITY__STRAIGHT_DOWN
		
		var disp_from_target = -(_linear_velocity_to_use * DISTANCE_IN_SECONDS)
		spawn_position_2d.global_position = target_position_2d.global_position + disp_from_target
		
	else:
		spawn_position_2d.global_position = target_position_2d.global_position
		
	
	
	
	

func _on_player_spawned(arg_player):
	arg_player.apply_inside_induced_force(_linear_velocity_to_use * arg_player.last_calculated_object_mass)
	
	

#################

func _on_player_entered_in_area__PDAR_initial_convo(arg_player):
	pass
	
	


func _start_remote_dialog__01():
	var dialog_desc = [
		["Looks like you got sent really far away!", []],
		["You're in luck however. You landed on an interesting place. Just explore for now.", []],
		
	]
	
	SingletonsAndConsts.current_game_front_hud.game_dialog_panel.connect("display_of_desc_finished", self, "_on_display_of_desc_finished__01", [], CONNECT_ONESHOT)
	SingletonsAndConsts.current_game_front_hud.game_dialog_panel.start_display_of_descs(dialog_desc, 1.5, 0, null)
	SingletonsAndConsts.current_game_front_hud.game_dialog_panel.show_self()
	
	

func _on_display_of_desc_finished__01(arg_metadata):
	var timer_tweener = create_tween()
	timer_tweener.tween_callback(self, "_on_delay_after_displaying_desc_01").set_delay(5.0)

func _on_delay_after_displaying_desc_01():
	SingletonsAndConsts.current_game_front_hud.game_dialog_panel.hide_self()

#





