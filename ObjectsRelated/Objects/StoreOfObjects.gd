extends Node

enum ObjectTypeIds {
	BALL = 0,
	TILE_FRAGMENT = 1,
	INTERACTABLE_BUTTON = 2,
}

var _object_type_id_to_file_path_map : Dictionary


func _init():
	_object_type_id_to_file_path_map[ObjectTypeIds.BALL] = "res://ObjectsRelated/Objects/Imps/Ball/Object_Ball.tscn"
	_object_type_id_to_file_path_map[ObjectTypeIds.TILE_FRAGMENT] = "res://ObjectsRelated/Objects/Imps/TileFragment/Object_TileFragment.tscn"
	_object_type_id_to_file_path_map[ObjectTypeIds.INTERACTABLE_BUTTON] = "res://ObjectsRelated/Objects/Imps/InteractableButton/Object_ButtonInteractable.tscn"
	

func construct_object(arg_id):
	var object = load(_object_type_id_to_file_path_map[arg_id]).instance()
	
	return object
