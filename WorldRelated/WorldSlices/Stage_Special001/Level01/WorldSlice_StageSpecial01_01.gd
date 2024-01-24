extends "res://WorldRelated/AbstractWorldSlice.gd"

#

const StoreOfCutscenes = preload("res://MiscRelated/CutsceneRelated/Imps/Cutscenes/StoreOfCutscenes.gd")

#

var cutscene

#

func _init():
	can_spawn_player_when_no_current_player_in_GE = true
	

func as_test__override__do_insta_win():
	as_test__override__do_insta_win__template_capture_all_points()
	


func _on_after_game_start_init():
	._on_after_game_start_init()
	
	_attempt_show_cutscene()




## CUTSCENE

func _attempt_show_cutscene():
	if !SingletonsAndConsts.if_level_id_has_restart_only_persisting_data(StoreOfLevels.LevelIds.LEVEL_01__STAGE_SPECIAL_1):
		cutscene = StoreOfCutscenes.generate_cutscene_from_id(StoreOfCutscenes.CutsceneId.LSpecial01_Lvl01)
		SingletonsAndConsts.current_master.add_cutscene_to_container(cutscene)
		
		cutscene.start_display()
		
		
		SingletonsAndConsts.set_restart_only_persisting_data_of_level_id(StoreOfLevels.LevelIds.LEVEL_01__STAGE_SPECIAL_1, true)


#func _process(delta):
#	if is_instance_valid(cutscene):
#		print("vis: %s, mod_a: %s " % [cutscene.visible, cutscene.modulate.a])


