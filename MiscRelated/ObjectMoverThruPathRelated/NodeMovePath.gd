extends Path2D

const NodeMoverThruPath = preload("res://MiscRelated/ObjectMoverThruPathRelated/NodeMoverThruPath.gd")
const NodeMoverThruPath_Scene = preload("res://MiscRelated/ObjectMoverThruPathRelated/NodeMoverThruPath.tscn")

#

var _all_node_2ds_to_move : Array
var _all_base_tilesets_to_move : Array

#

func _ready():
	for child in get_children():
		if child is NodeMoverThruPath:
			_add_node_to_move_along_path__from_ready(child)
		


###

func _add_node_to_move_along_path__from_ready(arg_node_mover : NodeMoverThruPath):
	add_node_to_move_along_path(arg_node_mover.get_child_to_move())
	


##

func add_node_to_move_along_path(arg_node_2d : Node2D):
	if arg_node_2d.get("is_class_type_base_tileset"):
		_all_base_tilesets_to_move.append(arg_node_2d)
	
	_all_node_2ds_to_move.append(arg_node_2d)
	
	if !(arg_node_2d is NodeMoverThruPath):
		_construct_node_mover_thru_path_for_node__and_reparent(arg_node_2d)
		


func _construct_node_mover_thru_path_for_node__and_reparent(arg_node_2d : Node2D):
	arg_node_2d.is_responsible_for_own_movement__for_rewind = false
	
	var node_mover = NodeMoverThruPath_Scene.instance()
	add_child(node_mover)
	node_mover.set_child_to_move(arg_node_2d)
	

#######

# use this to make this node addable in tilescontainer in GE
func get_all_base_tilesets_to_move() -> Array:
	return _all_base_tilesets_to_move
	


