extends "res://WorldRelated/AbstractWorldSlice.gd"


#

var background_music_playlist


var _memory_shader_holder : TextureRect
var _memory_shader_material : ShaderMaterial

var _memory_tweener : SceneTreeTween

#

onready var button_green = $ObjectContainer/ButtonGreen

onready var memory_flashback_01_container = $MemoryFlashback01
onready var tilemap_memory_energized = $MemoryFlashback01/TMMem_Energized

onready var pdar_memory_cinematic_start = $AreaRegionContainer/PDAR_Memory_CineStart

onready var env_event_elec_spark_in_memory_ship = $MiscContainer/EnvEvent_ElecSparks01

onready var misc_container = $MiscContainer

onready var tile_cloud_group_in_mem_ship = $MiscContainer/TileFragmentCloudInMemShip

##

func _init():
	can_spawn_player_when_no_current_player_in_GE = true
	


func _on_after_game_start_init():
	._on_after_game_start_init()
	
	memory_flashback_01_container.visible = false
	_init_tilemap_memory_energized()
	_init_pdar_memory_cinestart()
	
	background_music_playlist = StoreOfAudio.BGM_playlist__calm_01  ## does not matter since they affect the same bus
	
	if game_elements.is_game_front_hud_initialized:
		_on_GHF_initialized(game_elements.game_front_hud)
	else:
		game_elements.connect("game_front_hud_initialized", self, "_on_GHF_initialized", [], CONNECT_ONESHOT)

func as_test__override__do_insta_win():
	as_test__override__do_insta_win__template_capture_all_points()
	

####

func _init_tilemap_memory_energized():
	_update_tilemap_memory_energized_modulate()
	GameSettingsManager.connect("tile_color_config__tile_modulate__energized_changed", self, "_on_tile_color_config__tile_modulate__energized_changed")

func _update_tilemap_memory_energized_modulate():
	tilemap_memory_energized.modulate = GameSettingsManager.tile_color_config__tile_modulate__energized
	

func _on_tile_color_config__tile_modulate__energized_changed(arg_val):
	_update_tilemap_memory_energized_modulate()


########


func _on_GHF_initialized(arg_gfh):
	_init_memory_shader_holder()

func _init_memory_shader_holder():
	_memory_shader_holder = TextureRect.new()
	_memory_shader_holder.texture = preload("res://MiscRelated/ShadersRelated/Assets/ShaderImgTemplate_White1x1.png")
	_memory_shader_holder.rect_min_size = SingletonsAndConsts.current_master.screen_size
	_memory_shader_holder.stretch_mode = TextureRect.STRETCH_TILE
	
	_memory_shader_holder.visible = false
	_memory_shader_holder.mouse_filter = Control.MOUSE_FILTER_IGNORE
	
	#
	
	
	_init_memory_shader()
	_memory_shader_holder.material = _memory_shader_material
	
	#
	
	SingletonsAndConsts.current_game_front_hud.misc_center_container.add_child(_memory_shader_holder)
	

func _init_memory_shader():
	_memory_shader_material = ShaderMaterial.new()
	_memory_shader_material.shader = preload("res://MiscRelated/ShadersRelated/Shader_ScreenSaturation.tres")
	
	_memory_shader_material.set_shader_param("saturation", 0.3)
	
	#_memory_shader_material.shader = preload("res://MiscRelated/ShadersRelated/Shader_MemoryFlashback.tres")
	#var noise = _generate_noise_texture()
	#_memory_shader_material.set_shader_param("distortionTexture", noise)
	

#func _generate_noise_texture():
#	var simplex_noise = OpenSimplexNoise.new()
#	simplex_noise.octaves = 2
#	simplex_noise.period = 16.0
#
#	var noise_texture = NoiseTexture.new()
#	noise_texture.noise = simplex_noise
#	noise_texture.seamless = true
#	noise_texture.width = 220
#	noise_texture.height = 220
#
#	return noise_texture

#

func _init_pdar_memory_cinestart():
	pdar_memory_cinematic_start.is_disabled = true

func _on_ButtonGreen_pressed(arg_is_pressed) -> void:
	if is_instance_valid(pdar_memory_cinematic_start):
		pdar_memory_cinematic_start.is_disabled = !arg_is_pressed

#########

func _on_PDAR_Memory_CineStart_player_entered_and_cinematic_started() -> void:
	_begin_memory_01()

func _begin_memory_01():
	env_event_elec_spark_in_memory_ship.is_paused = true
	
	_memory_tweener = create_tween()
	_memory_tweener.tween_callback(self, "_show_memory_dimension")
	_memory_tweener.tween_interval(0.3)
	_memory_tweener.tween_callback(self, "_hide_memory_dimension")
	_memory_tweener.tween_interval(0.5)
	_memory_tweener.tween_callback(self, "_show_memory_dimension")
	

func _show_memory_dimension():
	_set_vis_of_memory_relateds__and_inverse_for_non_memory(true)

func _hide_memory_dimension():
	_set_vis_of_memory_relateds__and_inverse_for_non_memory(false)

#

func _set_vis_of_memory_relateds__and_inverse_for_non_memory(arg_vis_val):
	memory_flashback_01_container.visible = arg_vis_val
	_memory_shader_holder.visible = arg_vis_val
	
	tile_container.visible = !arg_vis_val
	area_region_container.visible = !arg_vis_val
	coins_container.visible = !arg_vis_val
	misc_container.visible = !arg_vis_val
	
	if arg_vis_val:  #is in memory lane:
		tile_cloud_group_in_mem_ship.force_set_all_fragment_mod_a(0.0)
		background_music_playlist.set_volume_db__bus_interal__using_ratio(0.5)
	else:
		tile_cloud_group_in_mem_ship.force_set_all_fragment_mod_a(1.0)
		background_music_playlist.set_volume_db__bus_interal__using_ratio(1.0)

###

func _on_PDAR_Memory_CineEnd_player_entered_and_cinematic_ended() -> void:
	_end_memory_01()

func _end_memory_01():
	env_event_elec_spark_in_memory_ship.is_paused = false
	
	if _memory_tweener != null and _memory_tweener.is_running():
		_memory_tweener.kill()
	_hide_memory_dimension()
	
	
	memory_flashback_01_container.queue_free()


