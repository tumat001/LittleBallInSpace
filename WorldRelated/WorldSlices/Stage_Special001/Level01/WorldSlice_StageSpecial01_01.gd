extends "res://WorldRelated/AbstractWorldSlice.gd"

#

const StoreOfCutscenes = preload("res://MiscRelated/CutsceneRelated/Imps/Cutscenes/StoreOfCutscenes.gd")

#

var cutscene

#

func _init():
	can_spawn_player_when_no_current_player_in_GE = true
	

func _on_after_game_start_init():
	._on_after_game_start_init()
	
	_show_cutscene()


## CUTSCENE

func _show_cutscene():
	cutscene = StoreOfCutscenes.generate_cutscene_from_id(StoreOfCutscenes.CutsceneId.LSpecial01_Lvl01)
	SingletonsAndConsts.current_master.add_cutscene_to_container(cutscene)
	
	cutscene.start_display()


#func _process(delta):
#	if is_instance_valid(cutscene):
#		print("vis: %s, mod_a: %s " % [cutscene.visible, cutscene.modulate.a])


