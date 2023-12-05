extends "res://WorldRelated/AbstractWorldSlice.gd"

const PlainTextFragment = preload("res://MiscRelated/TextInterpreterRelated/TextFragments/PlainTextFragment.gd")

#

var _is_first_time__do_cutscenes : bool



###

func _init():
	can_spawn_player_when_no_current_player_in_GE = true
	


func _on_after_game_start_init():
	._on_after_game_start_init()
	
	if SingletonsAndConsts.if_level_id_has_single_game_session_persisting_data(StoreOfLevels.LevelIds.LEVEL_01__STAGE_6):
		var is_fast_respawn = SingletonsAndConsts.get_single_game_session_persisting_data_of_level_id(StoreOfLevels.LevelIds.LEVEL_01__STAGE_6)
		
		if is_fast_respawn:
			_is_first_time__do_cutscenes = false
		else:
			_is_first_time__do_cutscenes = true
		
	else:
		_is_first_time__do_cutscenes = true
	
	



func _start_dialog__01():
	var dialog_desc = [
		["Unfortunately, there are many others that are missing...", []],
	]
	
	SingletonsAndConsts.current_game_front_hud.game_dialog_panel.connect("display_of_desc_finished", self, "_on_display_of_desc_finished__01", [], CONNECT_ONESHOT)
	SingletonsAndConsts.current_game_front_hud.game_dialog_panel.start_display_of_descs(dialog_desc, 2.0, 0, null)
	SingletonsAndConsts.current_game_front_hud.game_dialog_panel.show_self()



func _on_display_of_desc_finished__01():
	_start_dialog__02()

func _start_dialog__02():
	var dialog_desc = [
		["We must go back in space, and locate the lost.", []],
	]
	
	SingletonsAndConsts.current_game_front_hud.game_dialog_panel.connect("display_of_desc_finished", self, "_on_display_of_desc_finished__02", [], CONNECT_ONESHOT)
	SingletonsAndConsts.current_game_front_hud.game_dialog_panel.start_display_of_descs(dialog_desc, 2.0, 0, null)
	SingletonsAndConsts.current_game_front_hud.game_dialog_panel.show_self()

func _on_display_of_desc_finished__02():
	SingletonsAndConsts.current_game_front_hud.game_dialog_panel.hide_self()
	

#todo continue this


