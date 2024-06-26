extends "res://WorldRelated/AbstractWorldSlice.gd"

#

const VIS_INS__ANIM_NAME__HIDE_ALL = "hide_all"
const VIS_INS__ANIM_NAME__HIDE_EXCEPT_MOUSE = "hide_except_mouse"


onready var portal_for_transition = $ObjectContainer/Portal

onready var PDAR_fast_checkpoint = $AreaRegionContainer/PlayerDetectionAreaRegion_FastCheckpoint
onready var fast_spawn_pos_2d = $MiscContainer/FastSpawnPos2D
onready var spawn_position_2d = $PlayerSpawnCoordsContainer/SpawnPosition2D

onready var vkp_hide_hud__all = $MiscContainer/VisIns_HideHud/VBoxContainer2/VKP_HideHud_All
onready var vkp_hide_hud__except_mouse = $MiscContainer/VisIns_HideHud/VBoxContainer2/VKP_HideHud_ExceptForMouse

onready var vis_ins_hide_hud = $MiscContainer/VisIns_HideHud
onready var vis_ins_hide_hud_anim_sprite : AnimatedSprite = vis_ins_hide_hud.anim_sprite_of_vis_ins


#onready var focus_mode_ins_container = $MiscContainer/FocusModeInsContainer
#onready var vkp_toggle_focus_mode = $MiscContainer/FocusModeInsContainer/VKP_ToggleFocusMode

#

var _is_first_time_playing_level__in_session


var triggered_cam_area : bool = false

#

func _init():
	can_spawn_player_when_no_current_player_in_GE = true
	

func as_test__override__do_insta_win():
	#as_test__override__do_insta_win__template_capture_all_points()
	#StoreOfLevels.unlock_stage_03__and_start_at_stage_03_01_on_level_finish__if_appropriate()
	#game_elements.game_result_manager.set_current_game_result_as_win__and_instant_end()
	
	#game_elements.get_current_player().global_position
	#game_elements.get_current_player().global_position = Vector2(-656, -368)
	portal_for_transition._on_Area2D_body_entered(game_elements.get_current_player())

func _on_after_game_start_init():
	._on_after_game_start_init()
	
	#focus_mode_ins_container.modulate.a = 0
	portal_for_transition.connect("player_entered__as_scene_transition", self, "_on_player_entered__as_scene_transition")


func _before_player_spawned_signal_emitted__chance_for_changes(arg_player):
	._before_player_spawned_signal_emitted__chance_for_changes(arg_player)
	
	if SingletonsAndConsts.if_level_id_has_restart_only_persisting_data(StoreOfLevels.LevelIds.LEVEL_06__STAGE_2__HARD):
		var is_fast_respawn = SingletonsAndConsts.get_restart_only_persisting_data_of_level_id(StoreOfLevels.LevelIds.LEVEL_06__STAGE_2__HARD)
		
		if is_fast_respawn:
			arg_player.global_position = fast_spawn_pos_2d.global_position
			vis_ins_hide_hud.start_display()
		
		_is_first_time_playing_level__in_session = false
		
	else:
		_is_first_time_playing_level__in_session = true

###################

func _on_player_entered__as_scene_transition(arg_player):
	SingletonsAndConsts.current_game_elements.configure_game_state_for_cutscene_occurance(true, true)
	
	#
	
	StoreOfLevels.unlock_stage_03__and_start_at_stage_03_01_on_level_finish__if_appropriate()
	
	#
	
	var tweener = create_tween()
	tweener.tween_callback(self, "_on_wait_after_portal_enter_done").set_delay(2.0)

func _on_wait_after_portal_enter_done():
	game_elements.game_result_manager.set_current_game_result_as_win__and_instant_end()
	
	


##

func _on_PlayerDetectionAreaRegion_FastCheckpoint_player_entered_in_area():
	#level_id_to_non_save_persisting_data[StoreOfLevels.LevelIds.LEVEL_06__STAGE_2__HARD] = true
	SingletonsAndConsts.set_restart_only_persisting_data_of_level_id(StoreOfLevels.LevelIds.LEVEL_06__STAGE_2__HARD, true)


##


func _on_PDAR_SpecialCamGiver_player_entered_in_area():
	if !triggered_cam_area:
		if CameraManager.is_at_default_zoom():
			CameraManager.start_camera_zoom_change__with_default_player_initialized_vals()
		
		triggered_cam_area = true
		
		
		if _is_first_time_playing_level__in_session:
			vis_ins_hide_hud.start_display()
			
#			vkp_toggle_focus_mode.any_control_action_name = "toggle_focus_mode"
#			
#			var vis_tweener = create_tween()
#			vis_tweener.tween_property(focus_mode_ins_container, "modulate:a", 1.0, 0.75)
#			vis_tweener.tween_interval(6.0)
#			vis_tweener.tween_property(focus_mode_ins_container, "modulate:a", 0.0, 1.25)

#

func _on_PDAR_SpecialCamAngleActiveArea_player_entered_in_area():
	pass # Replace with function body.
	

func _on_PDAR_SpecialCamAngleActiveArea_player_exited_in_area():
	pass # Replace with function body.
	

###########

func _ready() -> void:
	vis_ins_hide_hud_anim_sprite.connect("animation_finished", self, "_on_vis_ins_anim_finished")
	_swap_to_anim__hide_all()
	
	vkp_hide_hud__all.any_control_action_name = "toggle_hide_hud"
	vkp_hide_hud__except_mouse.any_control_action_name = "toggle_focus_mode" 


func _on_vis_ins_anim_finished():
	if vis_ins_hide_hud_anim_sprite.animation == VIS_INS__ANIM_NAME__HIDE_ALL:
		_swap_to_anim__hide_except_mouse()
	else:
		_swap_to_anim__hide_all()
		

func _swap_to_anim__hide_all():
	vis_ins_hide_hud_anim_sprite.animation = VIS_INS__ANIM_NAME__HIDE_ALL
	vkp_hide_hud__all.set_modulate_normal(Color("#F2F9BE"))
	vkp_hide_hud__except_mouse.set_modulate_normal(Color("#55cfcfcf"))

func _swap_to_anim__hide_except_mouse():
	vis_ins_hide_hud_anim_sprite.animation = VIS_INS__ANIM_NAME__HIDE_EXCEPT_MOUSE
	vkp_hide_hud__all.set_modulate_normal(Color("#55cfcfcf"))
	vkp_hide_hud__except_mouse.set_modulate_normal(Color("#F2F9BE"))

