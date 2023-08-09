extends "res://LevelRelated/Classes/BaseLevel.gd"



func _init():
	anim_type_to_use_on_vic = StoreOfVicDefAnim.AnimTypes.ACTION
	anim_type_to_use_on_def = StoreOfVicDefAnim.AnimTypes.ACTION
	
	win_message_type = AbstractVicDefAnim.WinMessageType.VICTORY
	lose_messege_type = AbstractVicDefAnim.LoseMessageType.DEFEAT


#

func apply_modification_to_game_elements(arg_elements):
	.apply_modification_to_game_elements(arg_elements)
	
	arg_elements.world_manager.add_world_slice(StoreOfWorldSlices.WorldSliceIds.STAGE_01_05, Vector2(0, 0))



######

func after_game_init():
	.after_game_init()
	
	_add_energy_modi()

func _add_energy_modi():
	var modi = StoreOfPlayerModi.load_modi(StoreOfPlayerModi.PlayerModiIds.ENERGY)
	modi.set_max_energy(15)
	modi.set_current_energy(15)
	
	game_elements.player_modi_manager.add_modi_to_player(modi)


######################

