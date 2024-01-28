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

onready var key_press_label = $HBoxContainer/MiddleFillContainer/MarginContainer/KeyPressLabel

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


func _ready():
	if !Engine.editor_hint:
		set_change_state_if_game_control_is_conflicting(change_state_if_game_control_is_conflicting)
	
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
				_update_key_press_label__as_game_control()

func _update_key_press_label__as_game_control():
	var key_char = GameSettingsManager.get_game_control_hotkey__as_string(game_control_action_name)
	
	key_press_label.text = key_char
	


func _on_game_control_hotkey_changed(arg_game_control_action, arg_old_hotkey, arg_new_hotkey):
	_update_key_press_label__as_game_control()
	


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
			modulate = MODULATE_NORMAL


func _on_conflicting_game_controls_hotkey_changed(arg_last_calc_game_controls_in_conflicts):
	_update_modulate_based_on_control_conflicts()

func _update_modulate_based_on_control_conflicts():
	if is_inside_tree():
		
		if GameSettingsManager.if_last_calc_game_control_has_conflicts(game_control_action_name):
			modulate = MODULATE_WITH_CONFLICT
		else:
			modulate = MODULATE_NORMAL
			

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
	key_press_label.text = _all_key_char__of_any_control_name[_curr_idx__any_control_action_name]
	
	_curr_idx__any_control_action_name += 1
	if _all_key_char__of_any_control_name.size() <= _curr_idx__any_control_action_name:
		_curr_idx__any_control_action_name = 0


