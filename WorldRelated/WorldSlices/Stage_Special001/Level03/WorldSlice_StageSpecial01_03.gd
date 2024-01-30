extends "res://WorldRelated/AbstractWorldSlice.gd"


const StoreOfCutscenes = preload("res://MiscRelated/CutsceneRelated/Imps/Cutscenes/StoreOfCutscenes.gd")

#

func _init():
	can_spawn_player_when_no_current_player_in_GE = true
	

func as_test__override__do_insta_win():
	as_test__override__do_insta_win__template_capture_all_points()
	

func _on_after_game_start_init():
	._on_after_game_start_init()
	
	_attempt_show_cutscene()
	
	_helper__conn_to_GRM_on_win_attempt_unlock_to_spec_layout_02()

## CUTSCENE

func _attempt_show_cutscene():
	if !SingletonsAndConsts.if_level_id_has_restart_only_persisting_data(StoreOfLevels.LevelIds.LEVEL_03__STAGE_SPECIAL_1):
		var cutscene = StoreOfCutscenes.generate_cutscene_from_id(StoreOfCutscenes.CutsceneId.LSpecial01_Lvl03)
		SingletonsAndConsts.current_master.add_cutscene_to_container(cutscene)
		
		cutscene.start_display()
		
		
		SingletonsAndConsts.set_restart_only_persisting_data_of_level_id(StoreOfLevels.LevelIds.LEVEL_03__STAGE_SPECIAL_1, true)


