extends "res://WorldRelated/AbstractWorldSlice.gd"


const StoreOfTransitionSprites = preload("res://_NonMainGameRelateds/_Master/TransitionsRelated/StoreOfTransitionSprites.gd")


##

func _init():
	can_spawn_player_when_no_current_player_in_GE = true
	

func as_test__override__do_insta_win():
	as_test__override__do_insta_win__template_capture_all_points()
	



func _on_after_game_start_init():
	._on_after_game_start_init()
	
	
	var _is_first_time__do_cutscenes : bool = false
	if SingletonsAndConsts.if_level_id_has_single_game_session_persisting_data(StoreOfLevels.LevelIds.LEVEL_01__STAGE_3):
		var is_fast_respawn = SingletonsAndConsts.get_single_game_session_persisting_data_of_level_id(StoreOfLevels.LevelIds.LEVEL_01__STAGE_3)
		
		if !is_fast_respawn:
			_is_first_time__do_cutscenes = true
		
	else:
		_is_first_time__do_cutscenes = true
	
	if _is_first_time__do_cutscenes:
		SingletonsAndConsts.set_single_game_session_persisting_data_of_level_id(StoreOfLevels.LevelIds.LEVEL_01__STAGE_3, true)
		
		
		var transition = SingletonsAndConsts.current_master.construct_transition__using_id(StoreOfTransitionSprites.TransitionSpriteIds.OUT__STANDARD_CIRCLE__BLACK)
		transition.initial_ratio = 0.2
		transition.target_ratio = 1.0
		transition.wait_at_start = 1.0
		transition.duration = 2.0
		transition.trans_type = Tween.TRANS_BOUNCE
		SingletonsAndConsts.current_master.play_transition__alter_no_states(transition)
		transition.modulate.a = 0.6
		
		#transition.set_is_transition_paused(true)


