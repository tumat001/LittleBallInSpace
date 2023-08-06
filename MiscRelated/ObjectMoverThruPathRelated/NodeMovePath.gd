extends Path2D


var _all_node_2ds_to_move : Array
var _all_base_tilesets_to_move : Array


func add_node_to_move_along_path(arg_node_2d : Node2D):
	pass
	


# use this to make this node addable in tilescontainer in GE
func get_all_base_tilesets_to_move() -> Array:
	return _all_base_tilesets_to_move


###################### 
# REWIND RELATED
#####################

export(bool) var is_rewindable : bool

#


func get_rewind_save_state():
	var save_state = {
		"" : ""
	}
	
	
	return save_state

func load_into_rewind_save_state(arg_state):
	pass

func destroy_from_rewind_save_state():
	.queue_free()
	

func restore_from_destroyed_from_rewind():
	pass

func stared_rewind():
	for node_2d in _all_node_2ds_to_move:
		pass
		


func ended_rewind():
	for node_2d in _all_node_2ds_to_move:
		pass
		
	

