extends "res://WorldRelated/AbstractWorldSlice.gd"


const StoreOfCutscenes = preload("res://MiscRelated/CutsceneRelated/Imps/Cutscenes/StoreOfCutscenes.gd")

#

var _is_cdsu_module_custom_audio_picked_up : bool

onready var pickup_cdsu_module_custom_audio = $ObjectContainer/PickupCDSU_Module_CustomAudio


###

func _init():
	can_spawn_player_when_no_current_player_in_GE = true
	

func as_test__override__do_insta_win():
	_is_cdsu_module_custom_audio_picked_up = true
	#StoreOfLevels.unlock_stage_04__and_unhide_eles_to_layout_04()
	
	as_test__override__do_insta_win__template_capture_all_points()
	

func _on_after_game_start_init():
	._on_after_game_start_init()
	
	if GameSaveManager.can_config_custom_audio:
		pickup_cdsu_module_custom_audio.queue_free()
	else:
		init_all_module_x_pickup_related()


#

func _on_PlayerCaptureAreaRegion_region_area_captured():
	StoreOfLevels.unlock_stage_04__and_unhide_eles_to_layout_04()
	

#


func _on_PickupCDSU_Module_CustomAudio_player_entered_self__custom_defined():
	_is_cdsu_module_custom_audio_picked_up = true
	
	create_and_show_module_x_particle_pickup_particles__and_do_relateds(pickup_cdsu_module_custom_audio.global_position)


func _on_PickupCDSU_Module_CustomAudio_restored_from_destroyed_from_rewind():
	_is_cdsu_module_custom_audio_picked_up = false

func _on_game_result_decided__win__base():
	if _is_cdsu_module_custom_audio_picked_up:
		var old_val = GameSaveManager.can_config_custom_audio
		GameSaveManager.can_config_custom_audio = true
		
		if old_val != true:
			show_cutscene_id_at_GE_end(StoreOfCutscenes.CutsceneId.MOD_X_INFO__CUSTOM_AUDIO)


