extends Node


func add_child(arg_child, arg_legible_name = false):
	.add_child(arg_child, arg_legible_name)
	
	if !arg_child.get("is_player"):
		move_child(arg_child, 0)
