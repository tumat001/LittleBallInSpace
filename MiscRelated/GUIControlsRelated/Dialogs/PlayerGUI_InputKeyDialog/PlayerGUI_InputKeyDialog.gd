extends MarginContainer


signal ok_on_key_event_captured(arg_captured_event)
signal dialog_ended()

#

var associated_game_control_action_name : String setget set_associated_game_control_action_name
var _is_game_control : bool

var captured_event : InputEventKey

var censor_hidden_game_control_actions_name : bool = true

#

onready var associated_control_name_label = $DialogTemplate_Body_CBM/GridContainer/MidContainer/ContentContainer/MidContainer/MarginContainer/VBoxContainer/AssociatedControlNameLabel

onready var vkp_for_input = $DialogTemplate_Body_CBM/GridContainer/MidContainer/ContentContainer/MidContainer/MarginContainer/VBoxContainer/Container/VKPForInput

onready var invalid_hotkey_container = $DialogTemplate_Body_CBM/GridContainer/MidContainer/ContentContainer/MidContainer/MarginContainer/VBoxContainer/InvalidContainer

onready var conflicting_hotkeys_container = $DialogTemplate_Body_CBM/GridContainer/MidContainer/ContentContainer/MidContainer/MarginContainer/VBoxContainer/ConflictingHotkeysContainer
onready var conflicting_hotkeys_label = $DialogTemplate_Body_CBM/GridContainer/MidContainer/ContentContainer/MidContainer/MarginContainer/VBoxContainer/ConflictingHotkeysContainer/VBoxContainer/ConflictingLabel

onready var default_container = $DialogTemplate_Body_CBM/GridContainer/MidContainer/ContentContainer/MidContainer/MarginContainer/VBoxContainer/ResetToDefaultContainer

onready var button_ok = $DialogTemplate_Body_CBM/GridContainer/MidContainer/ContentContainer/MidContainer/MarginContainer/VBoxContainer/BottomChoiceContainer/HBoxContainer/Button_Ok
onready var button_cancel = $DialogTemplate_Body_CBM/GridContainer/MidContainer/ContentContainer/MidContainer/MarginContainer/VBoxContainer/BottomChoiceContainer/HBoxContainer/Button_Cancel
onready var button_default = $DialogTemplate_Body_CBM/GridContainer/MidContainer/ContentContainer/MidContainer/MarginContainer/VBoxContainer/ResetToDefaultContainer/Button_Default

#

func set_associated_game_control_action_name(arg_name):
	var old_val = associated_game_control_action_name
	associated_game_control_action_name = arg_name
	
	if GameSettingsManager.is_string_game_control_name(arg_name):
		_is_game_control = true


#

func _ready():
	vkp_for_input.update_keypress_label_based_on_game_control = false
	
	set_process_input(false)

#

func _on_button_pressed__ok():
	_do_ok_dialog()

func _on_button_pressed__cancel():
	cancel_dialog()

func _input(event):
	if event is InputEventKey:
		if !event.echo and event.pressed:
			_set_captured_input_event_key(event)
			
			#if event.is_action("ui_cancel"):
			#	cancel_dialog()
			#elif event.is_action("ui_accept"):
			#	_do_ok_dialog()
			#else:
			#	_set_captured_input_event_key(event)
		
		accept_event()


func _on_button_pressed__reset_to_default():
	_set_captured_input_event_key(GameSettingsManager.get_game_control_default(associated_game_control_action_name))
	


###

func start_capture():
	#modulate.a = 1
	#_set_captured_input_event_key(null)
	_update_display__for_associated_game_control()
	set_process_input(true)
	_connect_button_signals()

func _connect_button_signals():
	if !button_ok.is_connected("button_pressed", self, "_on_button_pressed__ok"):
		button_ok.connect("button_pressed", self, "_on_button_pressed__ok")
	if !button_cancel.is_connected("button_pressed", self, "_on_button_pressed__cancel"):
		button_cancel.connect("button_pressed", self, "_on_button_pressed__cancel")
	if !button_default.is_connected("button_pressed", self, "_on_button_pressed__reset_to_default"):
		button_default.connect("button_pressed", self, "_on_button_pressed__reset_to_default")
	

func _update_display__for_associated_game_control():
	if _is_game_control:
		if !GameSettingsManager.get_game_control_name__is_hidden(associated_game_control_action_name):
			associated_control_name_label.text = GameSettingsManager.GAME_CONTROLS_TO_NAME_MAP[associated_game_control_action_name]
		else:
			associated_control_name_label.text = GameSettingsManager.GAME_CONTROL_HIDDEN_PLACEHOLDER_NAME
		
		if GameSettingsManager.game_control_to_default_event.has(associated_game_control_action_name):
			default_container.visible = true
		else:
			default_container.visible = false
		
		#vkp_for_input.input_event_key = GameSettingsManager.get_game_control_input_key_event(associated_game_control_action_name)
		_set_captured_input_event_key(GameSettingsManager.get_game_control_input_key_event(associated_game_control_action_name))
		
	else:
		default_container.visible = false
		
		_set_captured_input_event_key(null)

#

func _set_captured_input_event_key(arg_captured_event : InputEventKey):
	captured_event = arg_captured_event
	_update_display_based_on_captured_event()

func _update_display_based_on_captured_event():
	vkp_for_input.input_event_key = captured_event
	
	_update_display__for_validity()
	_update_display__for_conflicts_if_any()
	_update_display__for_setting_default()


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
	button_ok.is_disabled = false

func _display_as_invalid_input():
	invalid_hotkey_container.visible = true
	button_ok.is_disabled = true

##

func _update_display__for_conflicts_if_any():
	if captured_event != null:
		if _is_game_control:
			var conflicting_game_controls = GameSettingsManager.calculate_game_control_name_conflicts_when_assigned_to_hotkey(associated_game_control_action_name, captured_event)
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
		return base_string % GameSettingsManager.convert_game_control_actions_into_names(arg_arr)
		
		
	else:
		var base_string = ""
		var arr_size = arg_arr.size()
		for i in arg_arr.size():
			base_string += "%s"
			if i != (arr_size - 1):
				base_string += "\n"
		
		var converted_name_arr = []
		for game_control_name in arg_arr:
			if GameSettingsManager.get_game_control_name__is_hidden(game_control_name):
				converted_name_arr.append(GameSettingsManager.GAME_CONTROL_HIDDEN_PLACEHOLDER_NAME)
			else:
				converted_name_arr.append(game_control_name)
		
		return base_string % GameSettingsManager.convert_game_control_actions_into_names(converted_name_arr)

##

func _update_display__for_setting_default():
	if GameSettingsManager.is_game_control_hotkey_default_for_action(associated_game_control_action_name, captured_event):
		button_default.is_disabled = true
	else:
		button_default.is_disabled = false


#######

func _do_ok_dialog():
	emit_signal("ok_on_key_event_captured", captured_event)
	cancel_dialog()

func cancel_dialog():#arg_do_transition : bool):
	control_tree.hide_control__and_traverse_thru_hierarchy__if_control(self, control_tree.use_mod_a_tweeners_for_traversing_hierarchy)
	
	#if arg_do_transition:
	#	_transition_end_dialog()

func _disconnect_button_signals():
	if button_ok.is_connected("button_pressed", self, "_on_button_pressed__ok"):
		button_ok.disconnect("button_pressed", self, "_on_button_pressed__ok")
	if button_cancel.is_connected("button_pressed", self, "_on_button_pressed__cancel"):
		button_cancel.disconnect("button_pressed", self, "_on_button_pressed__cancel")
	if button_default.is_connected("button_pressed", self, "_on_button_pressed__reset_to_default"):
		button_default.disconnect("button_pressed", self, "_on_button_pressed__reset_to_default")
	

#

#func _transition_end_dialog():
#	var tweener = create_tween()
#	tweener.set_parallel(false)
#	tweener.tween_property(self, "modulate:a", 0.0, 0.5)
#	tweener.tween_callback(self, "_on_end_of_end_transition")
#
#
##
#
#func _on_end_of_end_transition():
#	visible = false
#	set_process_input(false)
#	emit_signal("dialog_ended")



#############################################
# TREE ITEM Specific methods/vars

var control_tree


func on_control_received_focus():
	start_capture()
	

func on_control_fully_visible():
	pass

func on_control_lost_focus():
	_disconnect_button_signals()

func on_control_fully_invisible():
	set_process_input(false)
	emit_signal("dialog_ended")


############
# END OF TREE ITEM Specific methods/vars
###########


