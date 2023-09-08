tool
extends MarginContainer


const MODULATE_NORMAL = Color(1, 1, 1, 1)
const MODULATE_WITH_CONFLICT = Color("#ff5555")


#export(String) var text_for_keypress : String = "%s" setget set_text_for_keypress, get_text_for_keypress
var game_control_action_name : String setget set_game_control_action_name
export(bool) var change_state_if_game_control_is_conflicting : bool = false setget set_change_state_if_game_control_is_conflicting
# expects to be set at start
export(bool) var update_keypress_label_based_on_game_control : bool = true


var input_event_key : InputEventKey setget set_input_event_key

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


func set_game_control_action_name(arg_val):
	var old_action_name = game_control_action_name
	game_control_action_name = arg_val
	
	if !GameSettingsManager.is_connected("game_control_hotkey_changed", self, "_on_game_control_hotkey_changed"):
		GameSettingsManager.connect("game_control_hotkey_changed", self, "_on_game_control_hotkey_changed")
	
	if old_action_name != arg_val:
		if is_inside_tree():
			if update_keypress_label_based_on_game_control:
				_update_key_press_label()

func _update_key_press_label():
#	var input_events = InputMap.get_action_list(game_control_action_name)
#	var key_char : String = ""
#	if input_events.size() > 0:
#		key_char = input_events[0].as_text()
#
	
	var key_char = GameSettingsManager.get_game_control_hotkey__as_string(game_control_action_name)
	
	key_press_label.text = key_char
	


func _on_game_control_hotkey_changed(arg_game_control_action, arg_old_hotkey, arg_new_hotkey):
	_update_key_press_label()
	


##

func set_change_state_if_game_control_is_conflicting(arg_val):
	var old_val = change_state_if_game_control_is_conflicting
	change_state_if_game_control_is_conflicting = arg_val
	
	if arg_val != old_val:
		if arg_val:
			if !GameSettingsManager.is_connected("conflicting_game_controls_hotkey_changed", self, "_on_conflicting_game_controls_hotkey_changed"):
				GameSettingsManager.connect("conflicting_game_controls_hotkey_changed", self, "_on_conflicting_game_controls_hotkey_changed")
			_update_modulate_based_on_control_conflicts()
			
		else:
			if GameSettingsManager.is_connected("conflicting_game_controls_hotkey_changed", self, "_on_conflicting_game_controls_hotkey_changed"):
				GameSettingsManager.disconnect("conflicting_game_controls_hotkey_changed", self, "_on_conflicting_game_controls_hotkey_changed")
			modulate = MODULATE_NORMAL
			

func _on_conflicting_game_controls_hotkey_changed(arg_last_calc_game_controls_in_conflicts):
	_update_modulate_based_on_control_conflicts()

func _update_modulate_based_on_control_conflicts():
	if GameSettingsManager.if_last_calc_game_control_has_conflicts(game_control_action_name):
		modulate = MODULATE_WITH_CONFLICT
	else:
		modulate = MODULATE_NORMAL
	

##

func set_input_event_key(arg_event):
	input_event_key = arg_event
	
	if !update_keypress_label_based_on_game_control:
		if input_event_key == null:
			key_press_label.text = "(none)"
		else:
			key_press_label.text = input_event_key.as_text()

