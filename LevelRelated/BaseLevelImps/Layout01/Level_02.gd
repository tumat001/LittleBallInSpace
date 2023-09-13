extends "res://LevelRelated/Classes/BaseLevel.gd"



func _init():
	anim_type_to_use_on_vic = StoreOfVicDefAnim.AnimTypes.ACTION
	anim_type_to_use_on_def = StoreOfVicDefAnim.AnimTypes.ACTION
	
	win_message_type = AbstractVicDefAnim.WinMessageType.VICTORY
	lose_messege_type = AbstractVicDefAnim.LoseMessageType.DEFEAT


#

func apply_modification_to_game_elements(arg_elements):
	.apply_modification_to_game_elements(arg_elements)
	
	arg_elements.world_manager.add_world_slice(StoreOfWorldSlices.WorldSliceIds.STAGE_01_02, Vector2(0, 0))
	arg_elements.game_result_manager.connect("game_result_decided", self, "_on_game_result_decided__lvlx")

func _on_game_result_decided__lvlx(arg_res):
	if game_elements.game_result_manager.is_game_result_win():
		GameSettingsManager.set_assist_mode_id_unlocked_status(GameSettingsManager.AssistModeId.ADDITIONAL_ENERGY_MODE, true)
		GameSettingsManager.set_assist_mode_id_unlocked_status(GameSettingsManager.AssistModeId.ENERGY_REDUC_MODE, true)
		GameSettingsManager.set_assist_mode_id_unlocked_status(GameSettingsManager.AssistModeId.PAUSE_AT_ESC_MODE, true)


############

func after_game_init():
	.after_game_init()


######################

