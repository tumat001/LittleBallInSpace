extends MarginContainer



#############################################
# TREE ITEM Specific methods/vars

var control_tree setget set_control_tree

var _old_control_tree_modulate : Color
const COLOR_FOR_CONTROL_TREE = Color("f5ffffff")

func on_control_received_focus():
	_old_control_tree_modulate = control_tree.background_texture_rect_modulate
	control_tree.set_background_texture_rect_modulate(COLOR_FOR_CONTROL_TREE)

func on_control_fully_visible():
	pass

func on_control_lost_focus():
	control_tree.set_background_texture_rect_modulate(_old_control_tree_modulate)

func on_control_fully_invisible():
	pass

func set_control_tree(arg_tree):
	control_tree = arg_tree
	

############
# END OF TREE ITEM Specific methods/vars
###########
