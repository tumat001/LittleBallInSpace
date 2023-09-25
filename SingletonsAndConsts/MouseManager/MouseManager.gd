extends Node


const CustomMouse_Normal = preload("res://MiscRelated/MouseAssets/CustomMouse_Normal.png")
const CustomMouse_TargetReticle = preload("res://MiscRelated/MouseAssets/CustomMouse_TargetReticle.png")
const CustomMouse_Inspect = preload("res://MiscRelated/MouseAssets/CustomMouse_Inspect.png")

const CustomMouse_IBeam = preload("res://MiscRelated/MouseAssets/CustomMouse_IBeam.png")

enum MouseNormalSpriteTypeId {
	NORMAL = 0,
	TARGET_RETICLE = 1,
	INSPECT = 2,
}
var mouse_normal_sprite_type_id__to_offset_map : Dictionary = {
	MouseNormalSpriteTypeId.NORMAL : Vector2(0, 0),
	MouseNormalSpriteTypeId.TARGET_RETICLE : CustomMouse_TargetReticle.get_size() / 2,
	MouseNormalSpriteTypeId.INSPECT : Vector2(5, 5),
}
const mouse_normal_sprite_type_id__hierarchy = {
	MouseNormalSpriteTypeId.TARGET_RETICLE : 2,
	MouseNormalSpriteTypeId.INSPECT : 1,
	MouseNormalSpriteTypeId.NORMAL : 0,
}
const mouse_normal_sprite_type_id__to_img_res_map : Dictionary = {
	MouseNormalSpriteTypeId.NORMAL : CustomMouse_Normal,
	MouseNormalSpriteTypeId.TARGET_RETICLE : CustomMouse_TargetReticle,
	MouseNormalSpriteTypeId.INSPECT : CustomMouse_Inspect,
}


var _obj_requester_to_custom_requested_mouse_normal_id_map : Dictionary = {}

var _current_mouse_normal_id : int

######

func _ready():
	_update_OS_mouse_normal_texture()
	_update_OS_mouse_ibeam_texture()

#

func _update_OS_mouse_normal_texture():
	var mouse_normal_id_to_use = _get_highest_priority_requested_mouse_normal_sprite()
	var texture = mouse_normal_sprite_type_id__to_img_res_map[mouse_normal_id_to_use]
	var offset_to_use = mouse_normal_sprite_type_id__to_offset_map[mouse_normal_id_to_use]
	
	Input.set_custom_mouse_cursor(texture)
	
	_current_mouse_normal_id = mouse_normal_id_to_use

func _get_highest_priority_requested_mouse_normal_sprite():
	var highest_id = MouseNormalSpriteTypeId.NORMAL
	for mouse_normal_id in _obj_requester_to_custom_requested_mouse_normal_id_map.values():
		if mouse_normal_sprite_type_id__hierarchy[highest_id] < mouse_normal_sprite_type_id__hierarchy[mouse_normal_id]:
			highest_id = mouse_normal_id
	
	return highest_id

#

func request_change_mouse_normal_id(arg_requester, arg_mouse_normal_id):
	_obj_requester_to_custom_requested_mouse_normal_id_map[arg_requester] = arg_mouse_normal_id
	_update_OS_mouse_normal_texture()
	

func signal__requester_remove_request_on__tree_exiting(arg_requester : Node):
	if !arg_requester.is_connected("tree_exiting", self, "_on_node_requester_for_mouse_normal_id__tree_exiting"):
		arg_requester.connect("tree_exiting", self, "_on_node_requester_for_mouse_normal_id__tree_exiting", [arg_requester])

func signal__requester_remove_request_on__visibility_changed(arg_requester):
	if !arg_requester.is_connected("visibility_changed", self, "_on_node_requester_for_mouse_normal_id__visibility_changed"):
		arg_requester.connect("visibility_changed", self, "_on_node_requester_for_mouse_normal_id__visibility_changed", [arg_requester])

func signal__requester_remove_request_on__mouse_exited(arg_requester):
	if !arg_requester.is_connected("mouse_exited", self, "_on_node_requester_for_mouse_normal_id__mouse_exited"):
		arg_requester.connect("mouse_exited", self, "_on_node_requester_for_mouse_normal_id__mouse_exited", [arg_requester])



func _on_node_requester_for_mouse_normal_id__tree_exiting(arg_requester : Node):
	remove_request_change_mouse_normal_id(arg_requester)

func _on_node_requester_for_mouse_normal_id__visibility_changed(arg_requester):
	remove_request_change_mouse_normal_id(arg_requester)

func _on_node_requester_for_mouse_normal_id__mouse_exited(arg_requester):
	remove_request_change_mouse_normal_id(arg_requester)


func remove_request_change_mouse_normal_id(arg_requester):
	if _obj_requester_to_custom_requested_mouse_normal_id_map.has(arg_requester):
		_obj_requester_to_custom_requested_mouse_normal_id_map.erase(arg_requester)
		
		if arg_requester.is_connected("tree_exiting", self, "_on_node_requester_for_mouse_normal_id__tree_exiting"):
			arg_requester.disconnect("tree_exiting", self, "_on_node_requester_for_mouse_normal_id__tree_exiting")



###

func _update_OS_mouse_ibeam_texture():
	Input.set_custom_mouse_cursor(CustomMouse_IBeam, Input.CURSOR_IBEAM)

