extends "res://LevelRelated/Classes/BaseLevel.gd"

const StoreOfTransitionSprites = preload("res://_NonMainGameRelateds/_Master/TransitionsRelated/StoreOfTransitionSprites.gd")



func _init():
	anim_type_to_use_on_vic = StoreOfVicDefAnim.AnimTypes.ACTION
	anim_type_to_use_on_def = StoreOfVicDefAnim.AnimTypes.ACTION
	
	win_message_type = AbstractVicDefAnim.WinMessageType.VICTORY
	lose_messege_type = AbstractVicDefAnim.LoseMessageType.DEFEAT


#

func apply_modification_to_game_elements(arg_elements):
	.apply_modification_to_game_elements(arg_elements)
	
	arg_elements.world_manager.add_world_slice(StoreOfWorldSlices.WorldSliceIds.STAGE_01_01, Vector2(0, 0))
	

func apply_modification__before_game_elements_added():
	.apply_modification__before_game_elements_added()
	var first_time = GameSaveManager.first_time_opening_game
	GameSaveManager.first_time_opening_game = false
	
	if first_time:
		var transition = SingletonsAndConsts.current_master.construct_transition__using_id(StoreOfTransitionSprites.TransitionSpriteIds.OUT__STANDARD_CIRCLE__BLACK)
		transition.initial_ratio = 0.2
		transition.target_ratio = 1.0
		transition.wait_at_start = 1.0
		transition.duration = 2.0
		transition.trans_type = Tween.TRANS_BOUNCE
		SingletonsAndConsts.current_master.play_transition__alter_no_states(transition)
	


############

func after_game_init():
	.after_game_init()
	

######################

