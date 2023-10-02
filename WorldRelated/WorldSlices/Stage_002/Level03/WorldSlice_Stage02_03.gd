extends "res://WorldRelated/AbstractWorldSlice.gd"

const PlainTextFragment = preload("res://MiscRelated/TextInterpreterRelated/TextFragments/PlainTextFragment.gd")

#

var _is_in_special_cam_focus_mode : bool = false

onready var special_cam_focus_pos_2d = $MiscContainer/SpecialCamFocusPos

onready var focus_pos_01 = $MiscContainer/FocusPos01
onready var focus_pos_02 = $MiscContainer/FocusPos02

onready var spawn_pos = $PlayerSpawnCoordsContainer/SpawnPosition2D

#

onready var pca_last = $AreaRegionContainer/PCA_Last
onready var pca_semi_last = $AreaRegionContainer/PCA_SemiLast

##

func _init():
	can_spawn_player_when_no_current_player_in_GE = true
	is_player_capture_area_style_one_at_a_time__in_node_order = true

##

func _apply_modification_to_game_elements():
	if SingletonsAndConsts.if_level_id_has_restart_only_persisting_data(StoreOfLevels.LevelIds.LEVEL_03__STAGE_2):
		var is_not_first_time = SingletonsAndConsts.get_restart_only_persisting_data_of_level_id(StoreOfLevels.LevelIds.LEVEL_03__STAGE_2)
		
		if is_not_first_time:
			_make_node_special_cam_pos()
	else:
		_make_node_special_cam_pos()
	
	SingletonsAndConsts.set_restart_only_persisting_data_of_level_id(StoreOfLevels.LevelIds.LEVEL_03__STAGE_2, true)

func _make_node_special_cam_pos():
	_is_in_special_cam_focus_mode = true
	SingletonsAndConsts.current_game_elements.node_2d_to_receive_cam_focus__at_ready_start = special_cam_focus_pos_2d
	
	special_cam_focus_pos_2d.global_position = focus_pos_01.global_position

#

func _on_after_game_start_init():
	._on_after_game_start_init()
	
	pca_last.can_line_be_drawn_to_self_by_pca_line_dir_drawer = false
	
	game_elements.get_current_player().is_show_lines_to_uncaptured_player_capture_regions = true
	make_first_pca_region_visible()
	
	if _is_in_special_cam_focus_mode:
		_start_special_cam_sequence()
	else:
		do_start_of_game__or_end_of_tween__modifications()
	
#

func _start_special_cam_sequence():
	CameraManager.set_current_default_zoom_normal_vec(Vector2(0.5, 0.5), false)
	
	#
	game_elements.configure_game_state_for_cutscene_occurance(true, true)
	
	var tweener = create_tween()
	tweener.tween_interval(2.25)
	tweener.tween_callback(self, "tween_sequence__reset_cam_manager_zoom__and_go_to_focus_02", [CameraManager.ZOOM_OUT__DEFAULT__DURATION_OF_TRANSITION])
	tweener.tween_interval(CameraManager.ZOOM_OUT__DEFAULT__DURATION_OF_TRANSITION + 1.0)
	tweener.tween_property(special_cam_focus_pos_2d, "global_position", spawn_pos.global_position, 3.5).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN_OUT)
	tweener.tween_callback(self, "finished_tween_sequence")

func tween_sequence__reset_cam_manager_zoom__and_go_to_focus_02(arg_duration):
	CameraManager.set_current_default_zoom_normal_vec__to_default_zoom_normal_val(true)
	
	var tweener = create_tween()
	tweener.tween_property(special_cam_focus_pos_2d, "global_position", focus_pos_02.global_position, arg_duration).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN_OUT)

func finished_tween_sequence():
	game_elements.configure_game_state_for_end_of_cutscene_occurance(true)
	SingletonsAndConsts.current_rewind_manager.prevent_rewind_up_to_this_time_point()
	game_elements.give_camera_focus_and_follow_to_player()
	
	do_start_of_game__or_end_of_tween__modifications()


func do_start_of_game__or_end_of_tween__modifications():
	CameraManager.set_current_default_zoom_normal_vec__to_default_zoom_out_val(true)
	_start_dialog__01()

func _start_dialog__01():
	var plain_fragment__button = PlainTextFragment.new(PlainTextFragment.DESCRIPTION_TYPE.BUTTON, "button")
	var plain_fragment__ball_ammo = PlainTextFragment.new(PlainTextFragment.DESCRIPTION_TYPE.LAUNCH_BALL_AMMO__INFINITE, "Infinite ball ammo")
	
	
	var dialog_desc = [
		["The |0| is all the way on the other side.", [plain_fragment__button]],
		["Once you press that, obtain the |0| to return here.", [plain_fragment__ball_ammo]]
	]
	
	SingletonsAndConsts.current_game_front_hud.game_dialog_panel.connect("display_of_desc_finished", self, "_on_display_of_desc_finished__01", [], CONNECT_ONESHOT)
	SingletonsAndConsts.current_game_front_hud.game_dialog_panel.start_display_of_descs(dialog_desc, 3.5, 3.0, null)
	SingletonsAndConsts.current_game_front_hud.game_dialog_panel.show_self()

func _on_display_of_desc_finished__01(arg_metadata):
	var plain_fragment__capture_points = PlainTextFragment.new(PlainTextFragment.DESCRIPTION_TYPE.CAPTURE_AREA, "capture points")
	
	var dialog_desc = [
		["Follow the |0| leading to the special area.", [plain_fragment__capture_points]]
	]
	SingletonsAndConsts.current_game_front_hud.game_dialog_panel.connect("display_of_desc_finished", self, "_on_display_of_desc_finished__02", [], CONNECT_ONESHOT)
	SingletonsAndConsts.current_game_front_hud.game_dialog_panel.start_display_of_descs(dialog_desc, 3.5, 2.0, null)
	

func _on_display_of_desc_finished__02(arg_metadata):
	SingletonsAndConsts.current_game_front_hud.game_dialog_panel.hide_self()



func _on_PCA_SemiLast_region_area_captured():
	game_elements.ban_rewind_manager_to_store_and_cast_rewind()
	
	var wait_tween = create_tween()
	wait_tween.tween_interval(0.5)
	wait_tween.tween_callback(self, "_on_pca_semilast_captured_after_wait")

func _on_pca_semilast_captured_after_wait():
	SingletonsAndConsts.current_rewind_manager.prevent_rewind_up_to_this_time_point()
	game_elements.allow_rewind_manager_to_store_and_cast_rewind()
	
	var plain_fragment__button = PlainTextFragment.new(PlainTextFragment.DESCRIPTION_TYPE.BUTTON, "button")
	var plain_fragment__last_capture_point = PlainTextFragment.new(PlainTextFragment.DESCRIPTION_TYPE.CAPTURE_AREA, "last capture point")
	var dialog_desc = [
		["Good job! The |0| opened the blockading door to the |1|.", [plain_fragment__button, plain_fragment__last_capture_point]],
		["There are many ways and paths to go back.", []]
	]
	
	SingletonsAndConsts.current_game_front_hud.game_dialog_panel.connect("display_of_desc_finished", self, "_on_display_of_desc_finished__03", [], CONNECT_ONESHOT)
	SingletonsAndConsts.current_game_front_hud.game_dialog_panel.start_display_of_descs(dialog_desc, 3.0, 2.0, null)
	

func _on_display_of_desc_finished__03(arg_metadata):
	SingletonsAndConsts.current_game_front_hud.game_dialog_panel.hide_self()
	
