extends "res://WorldRelated/AbstractWorldSlice.gd"

const PlainTextFragment = preload("res://MiscRelated/TextInterpreterRelated/TextFragments/PlainTextFragment.gd")

const StoreOfCutscenes = preload("res://MiscRelated/CutsceneRelated/Imps/Cutscenes/StoreOfCutscenes.gd")


#

var _is_cdsu_module_stats_picked_up : bool

var _is_in_special_cam_focus_mode : bool = false

onready var special_cam_focus_pos_2d = $MiscContainer/SpecialCamFocusPos

onready var focus_pos_01 = $MiscContainer/FocusPos01
onready var focus_pos_02 = $MiscContainer/FocusPos02

onready var spawn_pos = $PlayerSpawnCoordsContainer/SpawnPosition2D


onready var pca_last = $AreaRegionContainer/PCA_Last
onready var pca_semi_last = $AreaRegionContainer/PCA_SemiLast


onready var pickup_cdsu_module_stats = $ObjectContainer/PickupCDSU_Module_Stats

##

func _init():
	can_spawn_player_when_no_current_player_in_GE = true
	is_player_capture_area_style_one_at_a_time__in_node_order = true

func as_test__override__do_insta_win():
	_is_cdsu_module_stats_picked_up = true
	as_test__override__do_insta_win__template_capture_all_points()
	

##

func _apply_modification_to_game_elements():
	if SingletonsAndConsts.if_level_id_has_restart_only_persisting_data(StoreOfLevels.LevelIds.LEVEL_03__STAGE_2):
		pass
		#_make_node_special_cam_pos()
	else:
		_make_node_special_cam_pos()
	
	SingletonsAndConsts.set_restart_only_persisting_data_of_level_id(StoreOfLevels.LevelIds.LEVEL_03__STAGE_2, true)

func _make_node_special_cam_pos():
	_is_in_special_cam_focus_mode = true
	SingletonsAndConsts.current_game_elements.node_2d_to_receive_cam_focus__at_ready_start = special_cam_focus_pos_2d
	
	special_cam_focus_pos_2d.global_position = focus_pos_01.global_position
	
	if game_elements.is_game_front_hud_initialized:
		_do_action_for_hud__on_special_cam_pos_action()
	else:
		SingletonsAndConsts.current_game_elements.connect("game_front_hud_initialized", self, "_on_game_front_hud_initialized__for_hiding", [], CONNECT_ONESHOT)

func _on_game_front_hud_initialized__for_hiding(arg_hud):
	_do_action_for_hud__on_special_cam_pos_action()

func _do_action_for_hud__on_special_cam_pos_action():
	SingletonsAndConsts.current_game_front_hud.set_control_container_visibility(false)

#

func _on_after_game_start_init():
	._on_after_game_start_init()
	
	pca_last.can_line_be_drawn_to_self_by_pca_line_dir_drawer = false
	pca_last.visible = true
	
	game_elements.get_current_player().is_show_lines_to_uncaptured_player_capture_regions = true
	make_first_pca_region_visible()
	
	if _is_in_special_cam_focus_mode:
		_start_special_cam_sequence()
	else:
		do_start_of_game__or_end_of_tween__modifications()
	
	
	if GameSaveManager.can_view_game_stats:
		pickup_cdsu_module_stats.queue_free()
	else:
		init_all_module_x_pickup_related()

#

func _start_special_cam_sequence():
	#CameraManager.start_camera_zoom_change(Vector2(0.5, 0.5), 0.2)
	CameraManager.set_current_default_zoom_normal_vec(Vector2(0.5, 0.5), false)
	
	#
	game_elements.configure_game_state_for_cutscene_occurance(true, true)
	
	var tweener = create_tween()
	tweener.tween_interval(2.50)
	tweener.tween_callback(self, "tween_sequence__reset_cam_manager_zoom__and_go_to_focus_02", [CameraManager.ZOOM_OUT__DEFAULT__DURATION_OF_TRANSITION])
	tweener.tween_interval(CameraManager.ZOOM_OUT__DEFAULT__DURATION_OF_TRANSITION + 1.5)
	tweener.tween_property(special_cam_focus_pos_2d, "global_position", spawn_pos.global_position, 3.5).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN_OUT)
	tweener.tween_callback(self, "finished_tween_sequence")

func tween_sequence__reset_cam_manager_zoom__and_go_to_focus_02(arg_duration):
	#CameraManager.start_camera_zoom_change(Vector2(1, 1), CameraManager.ZOOM_IN_FROM_OUT__DEFAULT__DURATION_OF_TRANSITION)
	CameraManager.set_current_default_zoom_normal_vec(Vector2(1, 1), true)
	
	var tweener = create_tween()
	tweener.tween_property(special_cam_focus_pos_2d, "global_position", focus_pos_02.global_position, arg_duration).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN_OUT)

func finished_tween_sequence():
	game_elements.configure_game_state_for_end_of_cutscene_occurance(true)
	game_elements.give_camera_focus_and_follow_to_player()
	SingletonsAndConsts.current_rewind_manager.prevent_rewind_up_to_this_time_point()
	SingletonsAndConsts.current_game_front_hud.set_control_container_visibility(true)
	
	do_start_of_game__or_end_of_tween__modifications()


func do_start_of_game__or_end_of_tween__modifications():
	CameraManager.start_camera_zoom_change(Vector2(2, 2), CameraManager.ZOOM_IN_FROM_OUT__DEFAULT__DURATION_OF_TRANSITION)

#

func _on_PDAR_EnteringSpecialArea_player_entered_in_area():
	CameraManager.reset_camera_zoom_level()
	

#

func _on_PCA_SemiLast_region_area_captured():
	pca_last.can_line_be_drawn_to_self_by_pca_line_dir_drawer = true
	
#	game_elements.ban_rewind_manager_to_store_and_cast_rewind()
#
	var wait_tween = create_tween()
	wait_tween.tween_interval(2.5)
	wait_tween.tween_callback(self, "_on_pca_semilast_captured_after_wait")

func _on_pca_semilast_captured_after_wait():
	if CameraManager.is_at_default_zoom():
		CameraManager.start_camera_zoom_change__with_default_player_initialized_vals()

#####

func _on_PickupCDSU_Module_Stats_player_entered_self__custom_defined():
	#GameSaveManager.can_view_game_stats = true
	_is_cdsu_module_stats_picked_up = true
	
	create_and_show_module_x_particle_pickup_particles__and_do_relateds(pickup_cdsu_module_stats.global_position)

func _on_PickupCDSU_Module_Stats_restored_from_destroyed_from_rewind():
	_is_cdsu_module_stats_picked_up = false
	

func _on_game_result_decided__win__base():
	if _is_cdsu_module_stats_picked_up:
		var old_val = GameSaveManager.can_view_game_stats
		GameSaveManager.can_view_game_stats = true
		
		if old_val != true:
			show_cutscene_id_at_GE_end(StoreOfCutscenes.CutsceneId.MOD_X_INFO__STATS)
#		SingletonsAndConsts.interrupt_return_to_screen_layout_panel__for_any_ending_cutscene = true
#		SingletonsAndConsts.cutscene_id_to_show__after_interrupt_return_to_screen_layout_panel__for_ending_cutscene = StoreOfCutscenes.CutsceneId.MOD_X_INFO__STATS
		

