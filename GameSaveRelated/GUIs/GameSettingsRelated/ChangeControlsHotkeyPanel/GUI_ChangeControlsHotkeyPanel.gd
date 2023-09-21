extends MarginContainer


const CurrControlSubPanel_SingleControl = preload("res://GameFrontHUDRelated/NonGameSubs/CurrentControlsPanel/Subs/CurrControlsSubPanel_SingleControl.gd")
const CurrControlSubPanel_SingleControl_Scene = preload("res://GameFrontHUDRelated/NonGameSubs/CurrentControlsPanel/Subs/CurrControlsSubPanel_SingleControl.tscn")

const PlayerGUI_InputKeyDialog = preload("res://MiscRelated/GUIControlsRelated/Dialogs/PlayerGUI_InputKeyDialog/PlayerGUI_InputKeyDialog.gd")
const PlayerGUI_InputKeyDialog_Scene = preload("res://MiscRelated/GUIControlsRelated/Dialogs/PlayerGUI_InputKeyDialog/PlayerGUI_InputKeyDialog.tscn")

const MiscControlsHotkeyPanel = preload("res://GameSaveRelated/GUIs/GameSettingsRelated/MiscControlsHotkeyPanel/MiscControlsHotkeyPanel.gd")
const MiscControlsHotkeyPanel_Scene = preload("res://GameSaveRelated/GUIs/GameSettingsRelated/MiscControlsHotkeyPanel/MiscControlsHotkeyPanel.tscn")

#const CurrControlSubPanel_ButtonHoverBorder_Pic = preload("res://GameSaveRelated/GUIs/GameSettingsRelated/ChangeControlsHotkeyPanel/Assets/ChangeControlsHotkeyPanel_ButtonHoverBorder.png")


#

var _input_key_dialog : PlayerGUI_InputKeyDialog

var _misc_controls_hotkey_panel : MiscControlsHotkeyPanel

#

var _is_current_control_in_tree : bool

onready var has_hidden_container = $DialogTemplate_Body_CBM/GridContainer/MidContainer/ContentContainer/MarginContainer/ContentContainer/VBoxContainer/HasHiddenContainer
onready var controls_vbox = $DialogTemplate_Body_CBM/GridContainer/MidContainer/ContentContainer/MarginContainer/ContentContainer/VBoxContainer/ControlsContainerMarginer/ControlsVBox

onready var label_has_hidden_msg = $DialogTemplate_Body_CBM/GridContainer/MidContainer/ContentContainer/MarginContainer/ContentContainer/VBoxContainer/HasHiddenContainer/LabelHasHidden

#

func _ready():
	for control_string in GameSettingsManager.GAME_CONTROLS_TO_NAME_MAP.keys():
		var subpanel_single_control = CurrControlSubPanel_SingleControl_Scene.instance()
		subpanel_single_control.control_identifier_string = control_string
		subpanel_single_control.hidden_display_mode = CurrControlSubPanel_SingleControl.HiddenDisplayModeId.CENSOR
		#subpanel_single_control.set_button_properties(true, null, CurrControlSubPanel_ButtonHoverBorder_Pic)
		subpanel_single_control.set_button_is_clickable(true)
		subpanel_single_control.connect("pressed", self, "_on_subpanel_single_control_pressed")
		
		controls_vbox.add_child(subpanel_single_control)
		
		subpanel_single_control.visual_key_press.change_state_if_game_control_is_conflicting = true
		
	
	##
	
	var orig_text_of_label_has_hidden_msg = label_has_hidden_msg.text
	label_has_hidden_msg.text = orig_text_of_label_has_hidden_msg % GameSettingsManager.GAME_CONTROL_HIDDEN_PLACEHOLDER_NAME
	

func _on_subpanel_single_control_pressed(arg_control_action_name):
	if _is_current_control_in_tree:
		if !is_instance_valid(_input_key_dialog):
			_initialize_input_key_dialog()
		
		_show_input_key_dialog(arg_control_action_name)
	



func _initialize_input_key_dialog():
	_input_key_dialog = PlayerGUI_InputKeyDialog_Scene.instance()
	_input_key_dialog.connect("dialog_ended", self, "_on_input_key_dialog__dialog_ended")
	control_tree.add_control__but_dont_show(_input_key_dialog)

func _on_input_key_dialog__dialog_ended():
	_disconnect_input_key_dialog_event_cap_signal()
	

func _disconnect_input_key_dialog_event_cap_signal():
	if _input_key_dialog.is_connected("ok_on_key_event_captured", self, "_on_input_key_dialog_ok_on_key_event_captured"):
		_input_key_dialog.disconnect("ok_on_key_event_captured", self, "_on_input_key_dialog_ok_on_key_event_captured")


func _show_input_key_dialog(arg_control_action_name : String):
	_disconnect_input_key_dialog_event_cap_signal()
	_input_key_dialog.connect("ok_on_key_event_captured", self, "_on_input_key_dialog_ok_on_key_event_captured", [arg_control_action_name])
	
	_input_key_dialog.associated_game_control_action_name = arg_control_action_name
	control_tree.show_control__and_add_if_unadded(_input_key_dialog)
	


func _on_input_key_dialog_ok_on_key_event_captured(arg_captured_event, arg_control_action_name):
	GameSettingsManager.set_game_control_new_hotkey__using_captured_event(arg_control_action_name, arg_captured_event)
	

#

func _update_display__on_show():
	if GameSettingsManager.is_any_game_control_name_hidden():
		has_hidden_container.visible = true
		
	else:
		has_hidden_container.visible = false
		
	

#

func _on_ViewMiscControlsButton_button_pressed():
	if !is_instance_valid(_misc_controls_hotkey_panel):
		_init_misc_controls_hotkey_panel()
	
	control_tree.show_control__and_add_if_unadded(_misc_controls_hotkey_panel)

func _init_misc_controls_hotkey_panel():
	_misc_controls_hotkey_panel = MiscControlsHotkeyPanel_Scene.instance()
	control_tree.add_control__but_dont_show(_misc_controls_hotkey_panel)
	

#############################################
# TREE ITEM Specific methods/vars

var control_tree


func on_control_received_focus():
	_is_current_control_in_tree = true
	_update_display__on_show()

func on_control_fully_visible():
	pass

func on_control_lost_focus():
	_is_current_control_in_tree = false

func on_control_fully_invisible():
	pass

############
# END OF TREE ITEM Specific methods/vars
###########

