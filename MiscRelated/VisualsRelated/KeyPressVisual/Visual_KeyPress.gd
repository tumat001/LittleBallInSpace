tool
extends MarginContainer


const MODULATE_NORMAL = Color("#cfcfcf")
const MODULATE_WITH_CONFLICT = Color("#ff7777")


#export(String) var text_for_keypress : String = "%s" setget set_text_for_keypress, get_text_for_keypress
var game_control_action_name : String setget set_game_control_action_name
export(bool) var change_state_if_game_control_is_conflicting : bool = false setget set_change_state_if_game_control_is_conflicting
# expects to be set at start
export(bool) var update_keypress_label_based_on_game_control : bool = true


var input_event_key : InputEventKey setget set_input_event_key

export(String) var plain_text : String setget set_plain_text

#

var any_control_action_name : String setget set_any_control_action_name
var _all_key_char__of_any_control_name : Array
var _any_control_action_name_key_displayer__tweener : SceneTreeTween
var _curr_idx__any_control_action_name

#

var use_image_display_instead_of_text : bool = false setget set_use_image_display_instead_of_text

#

export(Color) var modulate_normal = MODULATE_NORMAL setget set_modulate_normal
export(Color) var label_modulate = Color("#dddddd") setget set_label_modulate

#

var key_press_sprite : Sprite

onready var key_press_label = $HBoxContainer/MiddleFillContainer/MarginContainer/KeyPressLabel
onready var main_margin_container = $HBoxContainer/MiddleFillContainer/MarginContainer

#

#func set_text_for_keypress(arg_val):
#	text_for_keypress = arg_val
#
#	if is_inside_tree() or Engine.editor_hint:
#		key_press_label.text = text_for_keypress
#
#
#func get_text_for_keypress():
#	return text_for_keypress


func set_use_image_display_instead_of_text(arg_val):
	use_image_display_instead_of_text = arg_val
	
	if arg_val and !is_instance_valid(key_press_sprite):
		key_press_sprite = Sprite.new()
		main_margin_container.add_child(key_press_sprite)

#

func set_modulate_normal(arg_mod : Color):
	modulate_normal = arg_mod
	
	if is_inside_tree():
		if Engine.editor_hint:
			modulate = modulate_normal
		else:
			set_change_state_if_game_control_is_conflicting(change_state_if_game_control_is_conflicting)

func set_label_modulate(arg_mod : Color):
	label_modulate = arg_mod
	
	if is_inside_tree():
		key_press_label.add_color_override("font_color", label_modulate)
		

#

func _ready():
	if !Engine.editor_hint:
		set_use_image_display_instead_of_text(use_image_display_instead_of_text)
		set_change_state_if_game_control_is_conflicting(change_state_if_game_control_is_conflicting)
	
	set_label_modulate(label_modulate)
	
	if plain_text.length() != 0:
		set_plain_text(plain_text)

#

func set_game_control_action_name(arg_val):
	var old_action_name = game_control_action_name
	game_control_action_name = arg_val
	
	if !GameSettingsManager.is_connected("game_control_hotkey_changed", self, "_on_game_control_hotkey_changed"):
		GameSettingsManager.connect("game_control_hotkey_changed", self, "_on_game_control_hotkey_changed")
	
	if old_action_name != arg_val:
		if is_inside_tree():
			if update_keypress_label_based_on_game_control:
				update_key_press_label__as_game_control()

func update_key_press_label__as_game_control():
	var key_char = GameSettingsManager.get_game_control_hotkey__as_string(game_control_action_name)
	
	key_press_label.text = key_char
	


func _on_game_control_hotkey_changed(arg_game_control_action, arg_old_hotkey, arg_new_hotkey):
	update_key_press_label__as_game_control()
	


##

func set_change_state_if_game_control_is_conflicting(arg_val):
	#var old_val = change_state_if_game_control_is_conflicting
	change_state_if_game_control_is_conflicting = arg_val
	
	if arg_val:
		if !GameSettingsManager.is_connected("conflicting_game_controls_hotkey_changed", self, "_on_conflicting_game_controls_hotkey_changed"):
			GameSettingsManager.connect("conflicting_game_controls_hotkey_changed", self, "_on_conflicting_game_controls_hotkey_changed")
		_update_modulate_based_on_control_conflicts()
		
	else:
		if GameSettingsManager.is_connected("conflicting_game_controls_hotkey_changed", self, "_on_conflicting_game_controls_hotkey_changed"):
			GameSettingsManager.disconnect("conflicting_game_controls_hotkey_changed", self, "_on_conflicting_game_controls_hotkey_changed")
		
		if is_inside_tree():
			modulate = modulate_normal


func _on_conflicting_game_controls_hotkey_changed(arg_last_calc_game_controls_in_conflicts):
	_update_modulate_based_on_control_conflicts()

func _update_modulate_based_on_control_conflicts():
	if is_inside_tree():
		
		if GameSettingsManager.if_last_calc_game_control_has_conflicts(game_control_action_name):
			modulate = MODULATE_WITH_CONFLICT
		else:
			modulate = modulate_normal
			

##

func set_input_event_key(arg_event):
	input_event_key = arg_event
	
	if !update_keypress_label_based_on_game_control and plain_text.length() == 0:
		if input_event_key == null:
			key_press_label.text = "(none)"
		else:
			key_press_label.text = input_event_key.as_text()

func set_plain_text(arg_text : String):
	plain_text = arg_text
	
	if !update_keypress_label_based_on_game_control and input_event_key == null:
		if is_inside_tree() or Engine.editor_hint:
			key_press_label.text = plain_text


############

func set_any_control_action_name(arg_name):
	any_control_action_name = arg_name
	
	if is_inside_tree():
		_curr_idx__any_control_action_name = 0
		_init_all_key_char__of_any_control()
		_update_key_press_label__as_any_control()
		

func _init_all_key_char__of_any_control():
	_all_key_char__of_any_control_name.clear()
	var input_events = InputMap.get_action_list(any_control_action_name)
	for event in input_events:
		_all_key_char__of_any_control_name.append(event.as_text())

func _update_key_press_label__as_any_control():
	if _all_key_char__of_any_control_name.size() > 1:
		if _any_control_action_name_key_displayer__tweener != null and _any_control_action_name_key_displayer__tweener.is_valid():
			_any_control_action_name_key_displayer__tweener.kill()
		
		_any_control_action_name_key_displayer__tweener = create_tween()
		_any_control_action_name_key_displayer__tweener.set_loops(0)
		_any_control_action_name_key_displayer__tweener.set_parallel(false)
		_any_control_action_name_key_displayer__tweener.tween_interval(5.0)
		_any_control_action_name_key_displayer__tweener.tween_callback(self, "_show_next_control_char__any_control")
	
	_show_next_control_char__any_control()


func _show_next_control_char__any_control():
	#key_press_label.text = _all_key_char__of_any_control_name[_curr_idx__any_control_action_name]
	var used_img : bool = false
	if use_image_display_instead_of_text:
		used_img = _set_keypress_label_img__any_supported_game_control_as_ui_directions(_all_key_char__of_any_control_name[_curr_idx__any_control_action_name])
	
	if !used_img:
		_set_keypress_label_text(_all_key_char__of_any_control_name[_curr_idx__any_control_action_name])
	
	_curr_idx__any_control_action_name += 1
	if _all_key_char__of_any_control_name.size() <= _curr_idx__any_control_action_name:
		_curr_idx__any_control_action_name = 0


#

func _set_keypress_label_text(arg_text : String):
	key_press_label.text = arg_text
	key_press_label.visible = true
	if is_instance_valid(key_press_sprite):
		key_press_sprite.visible = false


func _set_keypress_label_img__any_supported_game_control_as_ui_directions(arg_text : String):
	var is_used_img : bool = false
	match arg_text:
		"Up":
			_set_keypress_label_img(load("res://MiscRelated/VisualsRelated/MiscAssets/MiscVisuals_ArrowUp.png"))
			key_press_sprite.rotation = 0.0
			is_used_img = true
		"Down":
			_set_keypress_label_img(load("res://MiscRelated/VisualsRelated/MiscAssets/MiscVisuals_ArrowUp.png"))
			key_press_sprite.rotation = PI
			is_used_img = true
		"Left":
			_set_keypress_label_img(load("res://MiscRelated/VisualsRelated/MiscAssets/MiscVisuals_ArrowUp.png"))
			key_press_sprite.rotation = 3*PI/2
			is_used_img = true
		"Right":
			_set_keypress_label_img(load("res://MiscRelated/VisualsRelated/MiscAssets/MiscVisuals_ArrowUp.png"))
			key_press_sprite.rotation = PI/2
			is_used_img = true
	
	call_deferred("_update_sprite_pos")
	return is_used_img

func _update_sprite_pos():
	key_press_sprite.position = main_margin_container.rect_position + main_margin_container.rect_size/2
	

func _set_keypress_label_img(arg_img : Texture):
	key_press_label.visible = false
	if is_instance_valid(key_press_sprite):
		key_press_sprite.texture = arg_img
		key_press_sprite.visible = true
	


