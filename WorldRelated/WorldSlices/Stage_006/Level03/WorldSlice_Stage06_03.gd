extends "res://WorldRelated/AbstractWorldSlice.gd"



const PlainTextFragment = preload("res://MiscRelated/TextInterpreterRelated/TextFragments/PlainTextFragment.gd")
const StoreOfTransitionSprites = preload("res://_NonMainGameRelateds/_Master/TransitionsRelated/StoreOfTransitionSprites.gd")


#

onready var fast_respawn_position_2d = $Node/FastRespawnPos2D

#

var _is_first_time__do_cutscenes : bool

##

func _init():
	can_spawn_player_when_no_current_player_in_GE = true
	is_player_capture_area_style_one_at_a_time__in_node_order = true




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


#todoimp think how to make enemies target seeking at the right time (checkpoints?)

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
		
	
	##
	
	var player = SingletonsAndConsts.current_game_elements.get_current_player()
	player.is_show_lines_to_uncaptured_player_capture_regions = true


func _on_transition_finished():
	pass
	#_start_dialog__01()
	#game_elements.configure_game_state_for_end_of_cutscene_occurance(true)
	




func _on_PDAR_DialogTrigger_player_entered_in_area():
	_start_dialog__01()


func _start_dialog__01():
	var plain_fragment__enemies = PlainTextFragment.new(PlainTextFragment.DESCRIPTION_TYPE.ENEMY, "enemies")
	
	var dialog_desc = [
		["Be careful up ahead. There are many |0| in the way, but you do not need to destroy them all.", [plain_fragment__enemies]],
		["Follow the guide and make it through the other side.", []],
	]
	
	SingletonsAndConsts.current_game_front_hud.game_dialog_panel.connect("display_of_desc_finished", self, "_on_display_of_desc_finished__01", [], CONNECT_ONESHOT)
	SingletonsAndConsts.current_game_front_hud.game_dialog_panel.start_display_of_descs(dialog_desc, 3.0, 1.0, null)
	SingletonsAndConsts.current_game_front_hud.game_dialog_panel.show_self()


####


