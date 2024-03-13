extends "res://WorldRelated/AbstractWorldSlice.gd"

const PlainTextFragment = preload("res://MiscRelated/TextInterpreterRelated/TextFragments/PlainTextFragment.gd")
const StoreOfTransitionSprites = preload("res://_NonMainGameRelateds/_Master/TransitionsRelated/StoreOfTransitionSprites.gd")


#

var _is_first_time__do_cutscenes : bool

#

onready var fast_respawn_position_2d = $MiscContainer/FastRespawnPos2D

onready var frag_cloud_group__hostile_ship_01 = $MiscContainer/FragCloudGroup_Hostile01

###

func _init():
	can_spawn_player_when_no_current_player_in_GE = true
	

func as_test__override__do_insta_win():
	as_test__override__do_insta_win__template_capture_all_points()
	


func _before_player_spawned_signal_emitted__chance_for_changes(arg_player):
	._before_player_spawned_signal_emitted__chance_for_changes(arg_player)
	
	#arg_player.global_position = fast_respawn_position_2d.global_position
	#return
	
	if SingletonsAndConsts.if_level_id_has_single_game_session_persisting_data(StoreOfLevels.LevelIds.LEVEL_01__STAGE_6):
		var is_fast_respawn = SingletonsAndConsts.get_single_game_session_persisting_data_of_level_id(StoreOfLevels.LevelIds.LEVEL_01__STAGE_6)
		
		if is_fast_respawn:
			arg_player.global_position = fast_respawn_position_2d.global_position
			_is_first_time__do_cutscenes = false
			
		else:
			_is_first_time__do_cutscenes = true
		
		
	else:
		_is_first_time__do_cutscenes = true


func _on_after_game_start_init():
	._on_after_game_start_init()
	
	
	if _is_first_time__do_cutscenes:
		SingletonsAndConsts.set_single_game_session_persisting_data_of_level_id(StoreOfLevels.LevelIds.LEVEL_01__STAGE_6, true)
		
		
		var transition = SingletonsAndConsts.current_master.construct_transition__using_id(StoreOfTransitionSprites.TransitionSpriteIds.OUT__STANDARD_CIRCLE__BLACK)
		transition.initial_ratio = 0.2
		transition.target_ratio = 1.0
		transition.wait_at_start = 1.0
		transition.duration = 1 #2.0
		transition.trans_type = Tween.TRANS_BOUNCE
		SingletonsAndConsts.current_master.play_transition__alter_no_states(transition)
		transition.modulate.a = 0.8
		
		transition.connect("transition_finished", self, "_on_transition_finished", [], CONNECT_ONESHOT)
		
		
		#game_elements.configure_game_state_for_cutscene_occurance(true, true)
		
		

func _on_transition_finished():
	pass
	#_start_dialog__01()
	
	#game_elements.configure_game_state_for_end_of_cutscene_occurance(true)
	



#
#func _start_dialog__01():
#	var dialog_desc = [
#		["Unfortunately, there are many others that are missing...", []],
#	]
#
#	SingletonsAndConsts.current_game_front_hud.game_dialog_panel.connect("display_of_desc_finished", self, "_on_display_of_desc_finished__01", [], CONNECT_ONESHOT)
#	SingletonsAndConsts.current_game_front_hud.game_dialog_panel.start_display_of_descs(dialog_desc, 2.0, 0, null)
#	SingletonsAndConsts.current_game_front_hud.game_dialog_panel.show_self()
#
#
#
#func _on_display_of_desc_finished__01(arg_val):
#	_start_dialog__02()
#
#func _start_dialog__02():
#	var dialog_desc = [
#		["We must go back in space, and locate the lost.", []],
#	]
#
#	SingletonsAndConsts.current_game_front_hud.game_dialog_panel.connect("display_of_desc_finished", self, "_on_display_of_desc_finished__02", [], CONNECT_ONESHOT)
#	SingletonsAndConsts.current_game_front_hud.game_dialog_panel.start_display_of_descs(dialog_desc, 2.0, 0, null)
#	SingletonsAndConsts.current_game_front_hud.game_dialog_panel.show_self()
#
#func _on_display_of_desc_finished__02(arg_val):
#	SingletonsAndConsts.current_game_front_hud.game_dialog_panel.hide_self()
#
#



####

func _on_PCAR_03_region_area_captured():
	SingletonsAndConsts.queue_free_all_glass_fragments()
	
	for frag_cloud in frag_cloud_group__hostile_ship_01.get_children():
		frag_cloud.summon_particles(3.0)


