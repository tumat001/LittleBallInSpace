extends PathFollow2D


export(float) var offset_per_second : float setget set_offset_per_second


var _main_child_to_move : Node2D

####

func set_offset_per_second(arg_val):
	offset_per_second = arg_val
	

#

func _ready():
	if get_child_count() == 1:
		set_child_to_move(get_children()[0])

#

func set_child_to_move(arg_node_2d):
	_main_child_to_move = arg_node_2d
	
	if _main_child_to_move.get_parent() == null:
		add_child(arg_node_2d)

func get_child_to_move():
	return _main_child_to_move

#

func _process(delta):
	if !SingletonsAndConsts.current_rewind_manager.is_rewinding:
		offset += (offset_per_second * delta)


###################### 
# REWIND RELATED
#####################

export(bool) var is_rewindable : bool = true
var is_dead_but_reserved_for_rewind : bool

#


func get_rewind_save_state():
	var save_state = {
		"transform" : transform
	}
	
	
	return save_state

func load_into_rewind_save_state(arg_state):
	transform = arg_state["transform"]
	

func destroy_from_rewind_save_state():
	pass
	# should not happen

func restore_from_destroyed_from_rewind():
	pass
	# should not happen


func started_rewind():
	pass
	

func ended_rewind():
	pass
	

