extends "res://WorldRelated/AbstractWorldSlice.gd"



var _is_cdsu_module_tile_colors_picked_up : bool

onready var pickup_cdsu_module_tile_colors = $ObjectContainer/PickupCDSU_Module_TileColors

#

func _init():
	can_spawn_player_when_no_current_player_in_GE = true
	


func _on_after_game_start_init():
	._on_after_game_start_init()
	
	if GameSaveManager.can_edit_tile_colors:
		pickup_cdsu_module_tile_colors.queue_free()
	else:
		init_all_module_x_pickup_related()



func _on_PickupCDSU_Module_Stats_player_entered_self__custom_defined():
	_is_cdsu_module_tile_colors_picked_up = true
	
	create_and_show_module_x_particle_pickup_particles__and_do_relateds(pickup_cdsu_module_tile_colors.global_position)

func _on_PickupCDSU_Module_Stats_restored_from_destroyed_from_rewind():
	_is_cdsu_module_tile_colors_picked_up = false


func _on_game_result_decided__win__base():
	if _is_cdsu_module_tile_colors_picked_up:
		GameSaveManager.can_edit_tile_colors = true



