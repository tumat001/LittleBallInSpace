extends "res://LevelRelated/Classes/BaseLevel.gd"



func _init():
	anim_type_to_use_on_vic = StoreOfVicDefAnim.AnimTypes.ACTION
	anim_type_to_use_on_def = StoreOfVicDefAnim.AnimTypes.ACTION
	
	win_message_type = AbstractVicDefAnim.WinMessageType.VICTORY
	lose_messege_type = AbstractVicDefAnim.LoseMessageType.DEFEAT


#

func apply_modification_to_game_elements(arg_elements):
	.apply_modification_to_game_elements(arg_elements)
	
	arg_elements.world_manager.add_world_slice(StoreOfWorldSlices.WorldSliceIds.STAGE_01_01, Vector2(0, 0))
	


############

func after_game_init():
	.after_game_init()


######################

