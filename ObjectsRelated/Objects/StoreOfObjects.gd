extends Node

enum ObjectTypeIds {
	BALL = 0
}

var _object_type_id_to_file_path_map : Dictionary


func _init():
	_object_type_id_to_file_path_map[ObjectTypeIds.BALL] = "res://ObjectsRelated/Objects/Imps/Ball/Object_Ball.tscn"


func construct_object(arg_id):
	var object = load(_object_type_id_to_file_path_map[arg_id]).instance()
	
	return object
