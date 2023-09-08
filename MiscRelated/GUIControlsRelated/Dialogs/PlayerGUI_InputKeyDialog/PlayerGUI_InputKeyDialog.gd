extends MarginContainer


signal dialog_ended()

#

var associated_game_control_action_name : String setget set_associated_game_control_action_name
var _is_game_control : bool

var captured_event : InputEventKey

var censor_hidden_game_control_actions_name : bool = true

#

onready var associated_control_name_label = $VBoxContainer/MidContainer/MarginContainer/VBoxContainer/AssociatedControlNameLabel

onready var vkp_for_input = $VBoxContainer/MidContainer/MarginContainer/VBoxContainer/Container/VKPForInput

onready var invalid_hotkey_container = $VBoxContainer/MidContainer/MarginContainer/VBoxContainer/InvalidContainer

onready var conflicting_hotkeys_container = $VBoxContainer/MidContainer/MarginContainer/VBoxContainer/ConflictingHotkeysContainer
onready var conflicting_hotkeys_label = $VBoxContainer/MidContainer/MarginContainer/VBoxContainer/ConflictingHotkeysContainer/VBoxContainer/ConflictingLabel

onready var default_container = $VBoxContainer/MidContainer/MarginContainer/VBoxContainer/ResetToDefaultContainer

onready var button_ok = $VBoxContainer/MidContainer/MarginContainer/VBoxContainer/BottomChoiceContainer/HBoxContainer/Button_Ok
onready var button_cancel = $VBoxContainer/MidContainer/MarginContainer/VBoxContainer/BottomChoiceContainer/HBoxContainer/Button_Cancel
onready var button_default = $VBoxContainer/MidContainer/MarginContainer/VBoxContainer/ResetToDefaultContainer/Button_Default

#

func set_associated_game_control_action_name(arg_name):
	var old_val = associated_game_control_action_name
	associated_game_control_action_name = arg_name
	
	if GameSettingsManager.is_string_game_control_name(arg_name):
		_is_game_control = true


#

func _ready():
	set_process_input(false)

#

func _on_button_pressed__ok():
	_do_ok_dialog()

func _on_button_pressed__cancel():
	cancel_dialog()

func _input(event):
	if event is InputEventKey:
		if !event.echo and event.pressed:
			if captured_event == null:
				_set_captured_input_event_key(event)
			else:
				if event.is_action("ui_cancel"):
					cancel_dialog()
				elif event.is_action("ui_accept"):
					_do_ok_dialog()
		
		accept_event()

#todo
func _on_button_pressed__reset_to_default():
	pass

#

func start_capture():
	modulate.a = 1
	_set_captured_input_event_key(null)
	_update_display__for_associated_game_control()
	set_process_input(true)
	_connect_button_signals()

func _connect_button_signals():
	if !button_ok.is_connected("button_pressed", self, "_on_button_pressed__ok"):
		button_ok.connect("button_pressed", self, "_on_button_pressed__ok")
	if !button_cancel.is_connected("button_pressed", self, "_on_button_pressed__cancel"):
		button_cancel.connect("button_pressed", self, "_on_button_pressed__cancel")


func _update_display__for_associated_game_control():
	associated_control_name_label.text = associated_game_control_action_name
	
	if GameSettingsManager.game_control_to_default_event.has(associated_game_control_action_name):
		default_container.visible = true
	else:
		default_container.visible = false


#

func _set_captured_input_event_key(arg_captured_event : InputEventKey):
	captured_event = arg_captured_event
	_update_display_based_on_captured_event()

func _update_display_based_on_captured_event():
	_update_display__for_validity()
	_update_display__for_conflicts_if_any()
	


#

func _update_display__for_validity():
	var is_valid = _check_if_captured_event_is_valid()
	if is_valid:
		_display_as_valid_input()
		
	else:
		_display_as_invalid_input()
		

func _check_if_captured_event_is_valid():
	if captured_event == null:
		return false
	
	if _is_game_control:
		return GameSettingsManager.allow_hotkey_to_be_assigned_to_game_control__ignoring_conflicts(captured_event, associated_game_control_action_name)
		
	else:
		return true
	

func _display_as_valid_input():
	invalid_hotkey_container.visible = false
	button_ok.visible = true

func _display_as_invalid_input():
	invalid_hotkey_container.visible = true
	button_ok.visible = false

#

func _update_display__for_conflicts_if_any():
	if captured_event != null:
		if _is_game_control:
			var conflicting_game_controls = GameSettingsManager.get_last_calc_game_control_conflicting_inputs_with_other_controls(associated_game_control_action_name)
			if conflicting_game_controls.size() != 0:
				conflicting_hotkeys_label.text = _convert_game_controls_in_arr_into_multiline_string(conflicting_game_controls)
				conflicting_hotkeys_container.visible = true
				
			else:
				conflicting_hotkeys_container.visible = false
			
		else:
			conflicting_hotkeys_container.visible = false
		
	else:
		conflicting_hotkeys_container.visible = false


func _convert_game_controls_in_arr_into_multiline_string(arg_arr : Array):
	if !censor_hidden_game_control_actions_name:
		var base_string = ""
		for i in arg_arr.size():
			base_string += "%s\n"
		return base_string % arg_arr
		
		
	else:
		var base_string = ""
		for i in arg_arr.size():
			base_string += "%s\n"
		
		var converted_name_arr = []
		for game_control_name in arg_arr:
			if GameSettingsManager.get_game_control_name__is_hidden(game_control_name):
				converted_name_arr.append(GameSettingsManager.GAME_CONTROL_HIDDEN_PLACEHOLDER_NAME)
			else:
				converted_name_arr.append(game_control_name)
		
		return base_string % converted_name_arr


##

func _do_ok_dialog():
	GameSettingsManager.set_game_control_new_hotkey__using_captured_event(associated_game_control_action_name, captured_event)
	_transition_end_dialog()

func cancel_dialog():
	_transition_end_dialog()


#

func _transition_end_dialog():
	_disconnect_button_signals()
	
	var tweener = create_tween()
	tweener.set_parallel(false)
	tweener.tween_property(self, "modulate:a", 0.0, 0.5)
	tweener.tween_callback(self, "_on_end_of_end_transition")

func _disconnect_button_signals():
	if button_ok.is_connected("button_pressed", self, "_on_button_pressed__ok"):
		button_ok.disconnect("button_pressed", self, "_on_button_pressed__ok")
	if button_cancel.is_connected("button_pressed", self, "_on_button_pressed__cancel"):
		button_cancel.disconnect("button_pressed", self, "_on_button_pressed__cancel")


#

func _on_end_of_end_transition():
	visible = false
	set_process_input(false)
	emit_signal("dialog_ended")


