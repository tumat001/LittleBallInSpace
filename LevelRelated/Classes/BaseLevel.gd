extends Reference

const StoreOfVicDefAnim = preload("res://GameFrontHUDRelated/NonGameSubs/VicDefAnimRelated/StoreOfVicDefAnim.gd")
const AbstractVicDefAnim = preload("res://GameFrontHUDRelated/NonGameSubs/VicDefAnimRelated/AbstractVicDefAnim.gd")


#

var game_elements

var anim_type_to_use_on_vic
var anim_type_to_use_on_def

var win_message_type
var lose_messege_type

var level_id


####

func apply_modification_to_game_elements(arg_elements):
	game_elements = arg_elements
	

func after_game_init():
	pass
	


#

func get_anim_instance_to_play__on_victory():
	var anim_id = StoreOfVicDefAnim.get_random_anim_id(true, anim_type_to_use_on_vic)
	return StoreOfVicDefAnim.get_instance_of_anim_id(anim_id)
	

func get_anim_instance_to_play__on_defeat():
	var anim_id = StoreOfVicDefAnim.get_random_anim_id(false, anim_type_to_use_on_vic)
	return StoreOfVicDefAnim.get_instance_of_anim_id(anim_id)
	
