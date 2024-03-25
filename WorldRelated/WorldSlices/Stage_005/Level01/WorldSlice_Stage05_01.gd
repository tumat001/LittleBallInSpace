extends "res://WorldRelated/AbstractWorldSlice.gd"

const PlainTextFragment = preload("res://MiscRelated/TextInterpreterRelated/TextFragments/PlainTextFragment.gd")

#

var _speed_for_break

#

const TILE_MAP_NAME__ENERGIZED = "TMMem_Energized"

var tilemap_memory_energized

#

onready var toughened_glass_tileset = $TileContainer/BaseTileSet_StrongGlass

onready var cdsu_mega_battery = $ObjectContainer/CDSU_MegaBattery

onready var god_rays_sprite = $MiscContainer/GodRays

onready var vis_transition_fog_circ = $MiscContainer/VisTransitionFog_Circ

onready var memory_flashback_container_01_for_TMM = $MemoryFlashbackContainer01_TMM
onready var shader_memory_container_01 = $ShaderMemoryContainer01

#

func _init():
	can_spawn_player_when_no_current_player_in_GE = true
	

func as_test__override__do_insta_win():
	#as_test__override__do_insta_win__template_capture_all_points()
	
	StoreOfLevels.unlock_and_goto_stage_05_level_02_on_win()
	game_elements.game_result_manager.set_current_game_result_as_win__and_instant_end()


func _on_after_game_start_init():
	._on_after_game_start_init()
	
	
	_set_modulate_a_for_memory_containers(0.0)
	_init_tilemap_memories()
	
	
	shader_memory_container_01.visible = true
	memory_flashback_container_01_for_TMM.visible = true

#########


func _on_PDAR_ZoomOutForArea_player_entered_in_area():
	_zoom_out_camera_for_area()


func _zoom_out_camera_for_area():
	#var plain_fragment__speed_to_break = PlainTextFragment.new(PlainTextFragment.DESCRIPTION_TYPE.SPEED, "%s speed" % (_speed_for_break))
	
	if CameraManager.is_at_default_zoom():
		CameraManager.start_camera_zoom_change__with_default_player_initialized_vals()
	

##############

#


func _on_CDSU_MegaBattery_player_entered_self__custom_defined():
	var player_pos = game_elements.get_current_player().global_position
	
	var param = PickupImportantItemCutsceneParam.new()
	param.item_texture = cdsu_mega_battery.sprite.texture
	param.staring_pos = cdsu_mega_battery.global_position
	param.ending_pos = player_pos
	
	helper__start_cutscene_of_pickup_important_item(param, self, "_on_item_cutscene_end", null)


func _on_item_cutscene_end(arg_param):
	_start_hide_god_rays()
	_on_pickup_mega_battery()
	SingletonsAndConsts.current_game_front_hud.template__start_focus_on_energy_panel__with_glow_up(0.4, self, "_finished_energy_panel_brief_focus_and_glow_up", null)

func _finished_energy_panel_brief_focus_and_glow_up(arg_param):
	SingletonsAndConsts.current_rewind_manager.prevent_rewind_up_to_this_time_point()
	call_deferred("_deferred_finish_battery_desc_display_01")


func _deferred_finish_battery_desc_display_01():
	game_elements.configure_game_state_for_end_of_cutscene_occurance(true)
	
	SingletonsAndConsts.current_game_front_hud.game_dialog_panel.hide_self()


func _on_pickup_mega_battery():
	var energy_modi = game_elements.player_modi_manager.get_modi_or_null(StoreOfPlayerModi.PlayerModiIds.ENERGY)
	energy_modi.set_properties__as_mega_battery(false)

func _start_hide_god_rays():
	var tweener = create_tween()
	tweener.set_parallel(false)
	tweener.tween_property(god_rays_sprite, "modulate:a", 0.0, 2.0)
	tweener.tween_callback(self, "_make_god_rays_sprite_invisible")

func _make_god_rays_sprite_invisible():
	god_rays_sprite.visible = false


#####

func _on_Portal_player_entered__as_scene_transition(arg_player):
	SingletonsAndConsts.current_game_elements.configure_game_state_for_cutscene_occurance(true, true)
	
	StoreOfLevels.unlock_and_goto_stage_05_level_02_on_win()
	
	var tweener = create_tween()
	tweener.tween_callback(self, "_on_wait_after_portal_enter_done").set_delay(2.0)

func _on_wait_after_portal_enter_done():
	game_elements.game_result_manager.set_current_game_result_as_win__and_instant_end()
	
	


########################################

func _on_PDAR_InitForMemory_player_entered_in_area() -> void:
	vis_transition_fog_circ.activate_monitor_for_player()
	_init_shader_memories_01_pulsate()


func _on_VisTransitionFog_Circ_progress_one_to_zero_ratio_changed(arg_ratio) -> void:
	_set_modulate_a_for_memory_containers(arg_ratio)

func _set_modulate_a_for_memory_containers(arg_ratio):
	memory_flashback_container_01_for_TMM.modulate.a = arg_ratio
	shader_memory_container_01.modulate.a = arg_ratio
	

#

func _init_tilemap_memories():
	tilemap_memory_energized = memory_flashback_container_01_for_TMM.get_node(TILE_MAP_NAME__ENERGIZED)
	
	#
	
	_update_tilemap_memory_energized_modulate()
	GameSettingsManager.connect("tile_color_config__tile_modulate__energized_changed", self, "_on_tile_color_config__tile_modulate__energized_changed")
	_update_tilemap_memory_normal_modulate()
	GameSettingsManager.connect("tile_color_config__tile_modulate__normal_changed", self, "_on_tile_color_config__tile_modulate__normal_changed")

func _update_tilemap_memory_energized_modulate():
	tilemap_memory_energized.modulate = GameSettingsManager.tile_color_config__tile_modulate__energized

func _on_tile_color_config__tile_modulate__energized_changed(arg_val):
	_update_tilemap_memory_energized_modulate()


func _update_tilemap_memory_normal_modulate():
	for tilemap in memory_flashback_container_01_for_TMM.get_children():
		if tilemap != tilemap_memory_energized:
			tilemap.modulate = GameSettingsManager.tile_color_config__tile_modulate__normal

func _on_tile_color_config__tile_modulate__normal_changed(arg_val):
	_update_tilemap_memory_normal_modulate()


#

func _init_shader_memories_01_pulsate():
	for texture_rect_shader_holder in shader_memory_container_01.get_children():
		var orig_size = texture_rect_shader_holder.rect_size
		var expanded_size = orig_size * 1.3
		
		var orig_position = texture_rect_shader_holder.rect_position
		var expanded_new_position = orig_position - (expanded_size - orig_size)/2
		
		var half_pulse_duration = SingletonsAndConsts.non_essential_rng.randf_range(2.0, 4.0)
		
		var rand_initial_delay = SingletonsAndConsts.non_essential_rng.randf_range(0.5, 2.0)
		
		var pulsate_tweener = create_tween()
		pulsate_tweener.tween_interval(rand_initial_delay)
		pulsate_tweener.set_loops()
		pulsate_tweener.set_parallel(true)
		pulsate_tweener.tween_property(texture_rect_shader_holder, "rect_size", expanded_size, half_pulse_duration).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN_OUT)
		pulsate_tweener.tween_property(texture_rect_shader_holder, "rect_position", expanded_new_position, half_pulse_duration).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN_OUT)
		pulsate_tweener.set_parallel(false)
		pulsate_tweener.tween_interval(half_pulse_duration)
		pulsate_tweener.set_parallel(true)
		pulsate_tweener.tween_property(texture_rect_shader_holder, "rect_size", orig_size, half_pulse_duration).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN_OUT)
		pulsate_tweener.tween_property(texture_rect_shader_holder, "rect_position", orig_position, half_pulse_duration).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN_OUT)
		


