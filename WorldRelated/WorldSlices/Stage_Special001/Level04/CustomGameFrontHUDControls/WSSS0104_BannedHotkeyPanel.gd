extends MarginContainer


const VisualKeyPress = preload("res://MiscRelated/VisualsRelated/KeyPressVisual/Visual_Keypress.gd")
const VisualKeyPress_Scene = preload("res://MiscRelated/VisualsRelated/KeyPressVisual/Visual_Keypress.tscn")

#

const MOD_RED_FOR_ATTEMPT_USE = Color("#DA0205")
const MOD_NORMAL = VisualKeyPress.MODULATE_NORMAL

#

var key_to_vkp_map : Dictionary = {}
onready var vkp_container = $VBoxContainer/BoxContainer/VKPContainer
onready var mouse_press_texture_rect = $VBoxContainer/BoxContainer/MousePressTextureRect
onready var disabled_label = $VBoxContainer/DisabledLabel

var is_mouse_press_texture_visible : bool = false setget set_is_mouse_press_texture_visible

#

func set_is_mouse_press_texture_visible(arg_val):
	is_mouse_press_texture_visible = arg_val
	
	_update_disabled_label_vis()
	
#

func _ready():
	disabled_label.visible = false
	mouse_press_texture_rect.visible = false

#

func config_with_WSSS0104(arg_world_slice):
	for i in arg_world_slice.vkp_to_details_map_map.size():
		call_deferred("_deferred_add_vkp_to_container")
	
	arg_world_slice.connect("keys_banned_changed", self, "_on_world_keys_banned_changed")
	
	arg_world_slice.connect("attempted_key_pressed", self, "_on_world_slice_attempted_key_pressed")
	arg_world_slice.connect("attempted_mouse_motion", self, "_on_world_slice_attempted_mouse_motion")

func _deferred_add_vkp_to_container():
	var vkp = VisualKeyPress_Scene.instance()
	vkp.update_keypress_label_based_on_game_control = false
	vkp.visible = false
	
	vkp_container.add_child(vkp)
	

#

func config_to_game_front_hud(arg_game_front_hud):
	arg_game_front_hud.add_custom_control_in_container(self, 0)
	rect_position = Vector2(155, 420)
	rect_size = Vector2(650, 100)
	grow_horizontal = Control.GROW_DIRECTION_BOTH

#

func _on_world_keys_banned_changed(arg_key, arg_is_banned):
	if arg_is_banned:
		_on_key_banned__update(arg_key)
	else:
		_on_key_unbanned__update(arg_key)
	


func _on_key_banned__update(arg_key):
	var vkp = key_to_vkp_map[arg_key]
	vkp.visible = true
	
	_update_disabled_label_vis()

func _on_key_unbanned__update(arg_key):
	var vkp = key_to_vkp_map[arg_key]
	vkp.visible = false
	
	_update_disabled_label_vis()

#

func _update_disabled_label_vis():
	if !is_inside_tree():
		return
	
	#
	
	if is_mouse_press_texture_visible:
		disabled_label.visible = true
		return
	
	#
	
	for vkp_to_test in vkp_container.get_children():
		if vkp_to_test.visible:
			disabled_label.visible = true
			return
	
	disabled_label.visible = false
	

#

func _on_world_slice_attempted_key_pressed(arg_key_pressed):
	if key_to_vkp_map.has(arg_key_pressed):
		_flicker_control_to_red_from_attempted_use(key_to_vkp_map[arg_key_pressed])

func _on_world_slice_attempted_mouse_motion():
	_flicker_control_to_red_from_attempted_use(mouse_press_texture_rect)


func _flicker_control_to_red_from_attempted_use(arg_control : Control):
	arg_control.modulate = MOD_RED_FOR_ATTEMPT_USE
	var tweener = create_tween()
	tweener.tween_property(arg_control, "modulate", MOD_NORMAL, 0.5)


