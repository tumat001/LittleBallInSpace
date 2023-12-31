extends Node


enum PickupablesTypeIds {
	BATTERY = 0,
	BALL = 1,
	WRENCH = 2,
}

var _pickupable_type_id_to_file_path_map : Dictionary


func _init():
	_pickupable_type_id_to_file_path_map[PickupablesTypeIds.BATTERY] = "res://ObjectsRelated/Pickupables/Subs/Battery/Pickupable_Battery.tscn"
	_pickupable_type_id_to_file_path_map[PickupablesTypeIds.BALL] = "res://ObjectsRelated/Pickupables/Subs/LaunchBalls/Pickupable_LaunchBall.tscn"
	_pickupable_type_id_to_file_path_map[PickupablesTypeIds.WRENCH] = "res://ObjectsRelated/Pickupables/Subs/Wrench/Pickupable_Wrench.tscn"
	

func construct_pickupable(arg_id):
	var object = load(_pickupable_type_id_to_file_path_map[arg_id]).instance()
	
	return object
