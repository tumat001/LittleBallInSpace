extends "res://WorldRelated/AbstractWorldSlice.gd"



var part_2_captured_areas_count_current : int = 0
const part_2_capture_count_total : int = 3
var _currently_blocking_leaving_part_2 : bool = true


var _mod_tweener_for_not_all_captured : SceneTreeTween

var _started_part_03_sequence : bool

#onready var label_rewind = $MessegesContainer/Label3Rewind
#onready var label_zoomout = $MessegesContainer/Label4Zoomout

onready var vkp_zoom_out = $MessegesContainer/VBoxContainer2/VKP_ZoomOut
onready var vkp_slow_down = $MessegesContainer/VBoxContainer3/VKPSlowDown

onready var vkp_zoom_out_container = $MessegesContainer/VBoxContainer2
onready var vkp_slow_down_container = $MessegesContainer/VBoxContainer3

onready var base_tileset_block_leaving_part_02 = $TileContainer/BaseTileSet_ToggleNotAllCapturedPart02

onready var label_not_all_areas_in_part_2_captured = $MessegesContainer/LabelNotAllAreasInPart2Captured

#

func _init():
	can_spawn_player_when_no_current_player_in_GE = true
	

func as_test__override__do_insta_win():
	as_test__override__do_insta_win__template_capture_all_points()
	
	GameSettingsManager.set_game_control_name_string__is_hidden("game_zoom_out", false)
	GameSettingsManager.set_game_control_name_string__is_hidden("game_down", false)
	


func _on_after_game_start_init():
	._on_after_game_start_init()
	
	#var orig_text_rewind = label_rewind.text
	#label_rewind.text = orig_text_rewind % InputMap.get_action_list("rewind")[0].as_text()
	 
	#var orig_text_rewind = vkp_rewind.text_for_keypress
	#vkp_rewind.text_for_keypress = orig_text_rewind % InputMap.get_action_list("rewind")[0].as_text()
	
	#var orig_text_zoomout = label_zoomout.text
	#label_zoomout.text = orig_text_zoomout % InputMap.get_action_list("game_zoom_out")[0].as_text()
	
	#var orig_text_zoomout = vkp_zoom_out.text_for_keypress
	#vkp_zoom_out.text_for_keypress = orig_text_zoomout % InputMap.get_action_list("game_zoom_out")[0].as_text()
	vkp_zoom_out.game_control_action_name = "game_zoom_out"
	
	#var orig_text_slowdown = vkp_slow_down.text_for_keypress
	#vkp_slow_down.text_for_keypress = orig_text_slowdown % InputMap.get_action_list("ui_down")[0].as_text()
	vkp_slow_down.game_control_action_name = "game_down"
	
	vkp_zoom_out_container.modulate.a = 0
	vkp_slow_down_container.modulate.a = 0
	
	
	label_not_all_areas_in_part_2_captured.modulate.a = 0
	_currently_blocking_leaving_part_2 = true

##


func _on_PDAR_ZoomAndSlow_player_entered_in_area():
	GameSettingsManager.set_game_control_name_string__is_hidden("game_zoom_out", false)
	GameSettingsManager.set_game_control_name_string__is_hidden("game_down", false)
	
	
	var vkp_zoom_out_tweener = create_tween()
	vkp_zoom_out_tweener.tween_property(vkp_zoom_out_container, "modulate:a", 1.0, 0.75)
	
	var vkp_slow_down_tweener = create_tween()
	vkp_slow_down_tweener.tween_property(vkp_slow_down_container, "modulate:a", 1.0, 0.75)




######

func _on_PlayerCaptureAreaRegion_Part02_01_region_area_captured():
	part_2_captured_areas_count_current += 1
	_update_block_for_part_2__check_for_if_all_is_captured()

func _on_PlayerCaptureAreaRegion_Part02_01_region_area_uncaptured():
	part_2_captured_areas_count_current -= 1
	_update_block_for_part_2__check_for_if_all_is_captured()



func _on_PlayerCaptureAreaRegion_Part02_02_region_area_captured():
	part_2_captured_areas_count_current += 1
	_update_block_for_part_2__check_for_if_all_is_captured()

func _on_PlayerCaptureAreaRegion_Part02_02_region_area_uncaptured():
	part_2_captured_areas_count_current -= 1
	_update_block_for_part_2__check_for_if_all_is_captured()



func _on_PlayerCaptureAreaRegion_Part02_03_region_area_captured():
	part_2_captured_areas_count_current += 1
	_update_block_for_part_2__check_for_if_all_is_captured()

func _on_PlayerCaptureAreaRegion_Part02_03_region_area_uncaptured():
	part_2_captured_areas_count_current -= 1
	_update_block_for_part_2__check_for_if_all_is_captured()



func _on_PDAR_NotAllAreasInPart2Captured_player_entered_in_area():
	if part_2_captured_areas_count_current != part_2_capture_count_total:
		_attempt_tween_show_not_all_captured_warning()
	


func _attempt_tween_show_not_all_captured_warning():
	if _mod_tweener_for_not_all_captured != null:
		_mod_tweener_for_not_all_captured.kill()
	
	_mod_tweener_for_not_all_captured = create_tween()
	_mod_tweener_for_not_all_captured.tween_property(label_not_all_areas_in_part_2_captured, "modulate:a", 1.0, 0.5)
	
	#print("show warning label")

func _attempt_tween_hide_not_all_captured_warning():
	if _mod_tweener_for_not_all_captured != null:
		_mod_tweener_for_not_all_captured.kill()
	
	_mod_tweener_for_not_all_captured = create_tween()
	_mod_tweener_for_not_all_captured.tween_property(label_not_all_areas_in_part_2_captured, "modulate:a", 0.0, 0.5)
	
	#print("hid warning label")


func _update_block_for_part_2__check_for_if_all_is_captured():
	if part_2_captured_areas_count_current >= part_2_capture_count_total:
		_attempt_tween_hide_not_all_captured_warning()
		if _currently_blocking_leaving_part_2:
			_currently_blocking_leaving_part_2 = false
			base_tileset_block_leaving_part_02.convert_all_filled_tiles_to_unfilled()
		
	else:
		#label_not_all_areas_in_part_2_captured.modulate.a = 1.0
		if !_currently_blocking_leaving_part_2:
			_currently_blocking_leaving_part_2 = true
			base_tileset_block_leaving_part_02.convert_all_unfilled_tiles_to_filled()
		
	


#####

func _on_PDAR_StartSequenceCapturePart03_player_entered_in_area():
	if !_started_part_03_sequence:
		_started_part_03_sequence = true
		
		#
		
		var wait_tween = create_tween()
		wait_tween.tween_callback(self, "_on_wait_tween_finished__for_part_03").set_delay(1.0)
		
		set_true__is_player_capture_area_style_one_at_a_time__in_node_order__from_not_ready()
		make_first_uncaptured_pca_region_visible()
		
		if CameraManager.is_at_default_zoom():
			CameraManager.start_camera_zoom_change__with_default_player_initialized_vals()
		
		
		game_elements.ban_rewind_manager_to_store_and_cast_rewind()

func _on_wait_tween_finished__for_part_03():
	SingletonsAndConsts.current_rewind_manager.prevent_rewind_up_to_this_time_point()
	game_elements.allow_rewind_manager_to_store_and_cast_rewind()
	
	game_elements.get_current_player().set_is_show_lines_to_uncaptured_player_capture_regions(true)
	

