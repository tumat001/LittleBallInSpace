extends MarginContainer


const VisualKeyPress = preload("res://MiscRelated/VisualsRelated/KeyPressVisual/Visual_KeyPress.gd")
const VisualKeyPress_Scene = preload("res://MiscRelated/VisualsRelated/KeyPressVisual/Visual_KeyPress.tscn")

#

const MOD_RED_FOR_ATTEMPT_USE = Color("#FE6D6F")
const MOD_NORMAL = VisualKeyPress.MODULATE_NORMAL

#

var all_vkps : Array = []

var key_to_vkp_map : Dictionary = {}
onready var vkp_container = $CenterMarginer/Marginer/VBoxContainer/BoxContainer/VKPContainer
onready var mouse_press_texture_rect = $CenterMarginer/Marginer/VBoxContainer/BoxContainer/MousePressTextureRect
onready var disabled_label = $CenterMarginer/Marginer/VBoxContainer/DisabledLabel
onready var background = $CenterMarginer/Background

var is_mouse_press_texture_visible : bool = false setget set_is_mouse_press_texture_visible


var _control_to_flicker_tweener_map : Dictionary
var _control_to_fade_to_normal_tweener_map : Dictionary

#

func set_is_mouse_press_texture_visible(arg_val):
	is_mouse_press_texture_visible = arg_val
	
	_update_disabled_label_vis()
	
#

func _ready():
	disabled_label.visible = false
	mouse_press_texture_rect.visible = false
	background.visible = false
	vkp_container.visible = false

#

func config_with_WSSS0104(arg_world_slice):
	for i in arg_world_slice.vkp_to_details_map_map.size():
		call_deferred("_deferred_add_vkp_to_container")
	
	arg_world_slice.connect("keys_banned_changed", self, "_on_world_keys_banned_changed")
	
	arg_world_slice.connect("attempted_key_pressed", self, "_on_world_slice_attempted_key_pressed")
	arg_world_slice.connect("attempted_key_released", self, "_on_world_slice_attempted_key_released")
	
	arg_world_slice.connect("attempted_mouse_motion", self, "_on_world_slice_attempted_mouse_motion")
	arg_world_slice.connect("mouse_movement_is_disabled_changed", self, "_on_world_slice_mouse_movement_is_disabled_changed")

func _deferred_add_vkp_to_container():
	var vkp = VisualKeyPress_Scene.instance()
	vkp.update_keypress_label_based_on_game_control = false
	vkp.visible = false
	
	vkp_container.add_child(vkp)
	all_vkps.append(vkp)

#

func config_to_game_front_hud(arg_game_front_hud):
	arg_game_front_hud.add_custom_control_in_container(self, 0)
	rect_position = Vector2(155, 420)
	rect_size = Vector2(650, 100)
	grow_horizontal = Control.GROW_DIRECTION_BOTH
	


#

func _on_world_slice_mouse_movement_is_disabled_changed(arg_is_banned):
	if arg_is_banned:
		set_is_mouse_press_texture_visible(true)
	else:
		set_is_mouse_press_texture_visible(false)
	

func _on_world_keys_banned_changed(arg_key, arg_is_banned):
	if arg_is_banned:
		_on_key_banned__update(arg_key)
	else:
		_on_key_unbanned__update(arg_key)
	


func _on_key_banned__update(arg_key):
	var vkp
	if key_to_vkp_map.has(arg_key):
		vkp = key_to_vkp_map[arg_key]
		
	else:
		vkp = _get_available_vkp()
		key_to_vkp_map[arg_key] = vkp
		vkp.plain_text = arg_key
	
	vkp.visible = true
	
	_update_disabled_label_vis()

func _get_available_vkp():
	for vkp in all_vkps:
		if !vkp.visible:
			return vkp
	
	return null



func _on_key_unbanned__update(arg_key):
	var vkp = key_to_vkp_map[arg_key]
	vkp.visible = false
	key_to_vkp_map.erase(arg_key)
	
	vkp.modulate = VisualKeyPress.MODULATE_NORMAL
	
	_update_disabled_label_vis()

#

func _update_disabled_label_vis():
	if !is_inside_tree():
		return
	
	#
	
	if is_mouse_press_texture_visible:
		disabled_label.visible = true
		background.visible = true
		mouse_press_texture_rect.visible = true
		
		for vkp_to_test in vkp_container.get_children():
			if vkp_to_test.visible:
				vkp_container.visible = true
				return
		
		vkp_container.visible = false
		return
	
	#
	
	for vkp_to_test in vkp_container.get_children():
		if vkp_to_test.visible:
			disabled_label.visible = true
			background.visible = true
			mouse_press_texture_rect.visible = false
			vkp_container.visible = true
			return
	
	#
	
	disabled_label.visible = false
	background.visible = false
	mouse_press_texture_rect.visible = false
	vkp_container.visible = false

#

func _on_world_slice_attempted_mouse_motion():
	_flicker_control_to_red_from_attempted_use(mouse_press_texture_rect)


func _flicker_control_to_red_from_attempted_use(arg_control : Control):
	arg_control.modulate = MOD_RED_FOR_ATTEMPT_USE
	#var tweener = create_tween()
	#tweener.tween_property(arg_control, "modulate", MOD_NORMAL, 0.5)
	_queue_for_flicker_control_to_red_from_use(arg_control)

func _queue_for_flicker_control_to_red_from_use(arg_control : Control):
	if _control_to_flicker_tweener_map.has(arg_control):
		var prev_tweener : SceneTreeTween = _control_to_flicker_tweener_map[arg_control]
		if prev_tweener.is_valid():
			prev_tweener.kill()
	
	var tweener = create_tween()
	tweener.tween_property(arg_control, "modulate", MOD_NORMAL, 0.5)
	
	_control_to_flicker_tweener_map[arg_control] = tweener


#

func _on_world_slice_attempted_key_pressed(arg_key_pressed):
	if key_to_vkp_map.has(arg_key_pressed):
		#_flicker_control_to_red_from_attempted_use(key_to_vkp_map[arg_key_pressed])
		var vkp = key_to_vkp_map[arg_key_pressed]
		vkp.modulate = MOD_RED_FOR_ATTEMPT_USE
		
		if _control_to_fade_to_normal_tweener_map.has(vkp):
			var tweener = _control_to_fade_to_normal_tweener_map[vkp]
			if tweener != null and tweener.is_valid():
				tweener.kill()
				
		

func _on_world_slice_attempted_key_released(arg_key_released):
	if key_to_vkp_map.has(arg_key_released):
		var control = key_to_vkp_map[arg_key_released]
		
		var tweener = create_tween()
		tweener.tween_property(control, "modulate", MOD_NORMAL, 0.5)
		_control_to_fade_to_normal_tweener_map[control] = tweener
	
