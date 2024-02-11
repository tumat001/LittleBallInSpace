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
	MouseNormalSpriteTypeId.INSPECT : Vector2(12.5, 12.5),
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


###

enum InputMouseModeReserveId {
	GAME_FRONT_HUD = 0,
	CUSTOM_FROM_WORLD_SLICE = 1,
}
var _input_mouse_reserve_id_to_mouse_mode_map : Dictionary
const input_mouse_mode_to_priority_map : Dictionary = {
	Input.MOUSE_MODE_VISIBLE : 0,
	Input.MOUSE_MODE_CONFINED : 1,
	Input.MOUSE_MODE_HIDDEN: 2,
	Input.MOUSE_MODE_CAPTURED : 3,
	
}


enum AlwaysMouseModeVisibleReserveId {
	SHOWING_GE_MENU = 0
	CUSTOM = 1
}
var _always_mouse_visible_reserve_id_list : Array = []
var last_calc_mouse_is_always_visible : bool = false

######

func _ready():
	_update_OS_mouse_normal_texture()
	_update_OS_mouse_ibeam_texture()

#

func _update_OS_mouse_normal_texture():
	var mouse_normal_id_to_use = _get_highest_priority_requested_mouse_normal_sprite()
	var texture = mouse_normal_sprite_type_id__to_img_res_map[mouse_normal_id_to_use]
	var offset_to_use = mouse_normal_sprite_type_id__to_offset_map[mouse_normal_id_to_use]
	
	Input.set_custom_mouse_cursor(texture, Input.CURSOR_ARROW, offset_to_use)
	
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


func remove_request_change_mouse_normal_id(arg_requester : Object):
	if _obj_requester_to_custom_requested_mouse_normal_id_map.has(arg_requester):
		_obj_requester_to_custom_requested_mouse_normal_id_map.erase(arg_requester)
		
		if arg_requester.has_signal("tree_exiting"):
			if arg_requester.is_connected("tree_exiting", self, "_on_node_requester_for_mouse_normal_id__tree_exiting"):
				arg_requester.disconnect("tree_exiting", self, "_on_node_requester_for_mouse_normal_id__tree_exiting")
		
		if arg_requester.has_signal("visibility_changed"):
			if arg_requester.is_connected("visibility_changed", self, "_on_node_requester_for_mouse_normal_id__visibility_changed"):
				arg_requester.disconnect("visibility_changed", self, "_on_node_requester_for_mouse_normal_id__visibility_changed")
		
		if arg_requester.has_signal("mouse_exited"):
			if arg_requester.is_connected("mouse_exited", self, "_on_node_requester_for_mouse_normal_id__mouse_exited"):
				arg_requester.disconnect("mouse_exited", self, "_on_node_requester_for_mouse_normal_id__mouse_exited")
		
		_update_OS_mouse_normal_texture()



func clear_all_requesters__for_mouse_normal_id():
	_obj_requester_to_custom_requested_mouse_normal_id_map.clear()
	_update_OS_mouse_normal_texture()

###

func _update_OS_mouse_ibeam_texture():
	Input.set_custom_mouse_cursor(CustomMouse_IBeam, Input.CURSOR_IBEAM)



######

#func generate_texture_rect_with_position_in_mouse_pos__of_mouse_normal_pointer():
#	var tex_rect = TextureRect.new()
#	tex_rect.texture = mouse_normal_sprite_type_id__to_img_res_map[_current_mouse_normal_id]
#	tex_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
#
#
#	var offset = mouse_normal_sprite_type_id__to_offset_map[_current_mouse_normal_id]
#	tex_rect.rect_position = get_viewport().get_mouse_position() + offset
#
#	return tex_rect

################### INPUT MOUSE MODE

func set_input_mouse_mode__via_reservation(arg_id, arg_mouse_mode):
	_input_mouse_reserve_id_to_mouse_mode_map[arg_id] = arg_mouse_mode
	_update_input_mouse_mode_based_on_reservation()

func remove_input_mouse_reservation_id(arg_id):
	if _input_mouse_reserve_id_to_mouse_mode_map.has(arg_id):
		_input_mouse_reserve_id_to_mouse_mode_map.erase(arg_id)
	_update_input_mouse_mode_based_on_reservation()

func remove_all_input_mouse_reservations():
	_input_mouse_reserve_id_to_mouse_mode_map.clear()
	_update_input_mouse_mode_based_on_reservation()

func _update_input_mouse_mode_based_on_reservation():
	if last_calc_mouse_is_always_visible:
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		return
	
	####
	
	var curr_prio = 0
	var curr_mouse_mode_id = input_mouse_mode_to_priority_map.keys()[curr_prio]
	
	for mode_id in _input_mouse_reserve_id_to_mouse_mode_map.values():
		var prio = input_mouse_mode_to_priority_map[mode_id]
		if curr_prio < prio:
			curr_prio = prio
			curr_mouse_mode_id = mode_id
	
	Input.mouse_mode = curr_mouse_mode_id



func add_always_mouse_visible_reserve_id_list(arg_id):
	if !_always_mouse_visible_reserve_id_list.has(arg_id):
		_always_mouse_visible_reserve_id_list.append(arg_id)
		last_calc_mouse_is_always_visible = true
		
		_update_input_mouse_mode_based_on_reservation()

func remove_always_mouse_visible_reserve_id_list(arg_id):
	if _always_mouse_visible_reserve_id_list.has(arg_id):
		_always_mouse_visible_reserve_id_list.erase(arg_id)
		last_calc_mouse_is_always_visible = _always_mouse_visible_reserve_id_list.size() != 0
		
		_update_input_mouse_mode_based_on_reservation()

func remove_all_always_mouse_visible_reserve_id():
	_always_mouse_visible_reserve_id_list.clear()
	last_calc_mouse_is_always_visible = false
	
	_update_input_mouse_mode_based_on_reservation()

