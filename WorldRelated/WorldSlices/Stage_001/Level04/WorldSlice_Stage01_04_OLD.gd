extends "res://WorldRelated/AbstractWorldSlice.gd"


onready var button_green = $ObjectContainer/ButtonGreen

onready var memory_flashback_01_container = $MemoryFlashback01
onready var tilemap_memory_energized = $MemoryFlashback01/TileMapMemory_Energized


##

func _init():
	can_spawn_player_when_no_current_player_in_GE = true
	


func _on_after_game_start_init():
	._on_after_game_start_init()
	
	_config_and_connect_tilemap_memory_energized()

func as_test__override__do_insta_win():
	as_test__override__do_insta_win__template_capture_all_points()
	

####

func _config_and_connect_tilemap_memory_energized():
	_update_tilemap_memory_energized_modulate()
	GameSettingsManager.connect("tile_color_config__tile_modulate__energized_changed", self, "_on_tile_color_config__tile_modulate__energized_changed")

func _update_tilemap_memory_energized_modulate():
	tilemap_memory_energized.modulate = GameSettingsManager.tile_color_config__tile_modulate__energized
	

func _on_tile_color_config__tile_modulate__energized_changed(arg_val):
	_update_tilemap_memory_energized_modulate()


########


func _on_PDAR_Memory_CineStart_player_entered_and_cinematic_started() -> void:
	pass # Replace with function body.
	



func _on_ButtonGreen_pressed(arg_is_pressed) -> void:
	pass # Replace with function body.
