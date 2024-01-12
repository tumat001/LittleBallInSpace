extends Position2D


export(Array, NodePath) var all_position_links
var id : int

func _init():
	all_position_links = []

func randomly_choose_position_link(arg_link_to_exclude):
	var duplicate_of_all = all_position_links.duplicate()
	duplicate_of_all.erase(arg_link_to_exclude)
	
	return StoreOfRNG.randomly_select_one_element(duplicate_of_all, SingletonsAndConsts.non_essential_rng)
	


