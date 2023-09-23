extends MarginContainer


const ChangeControlsHotkeyPanel_HoverLineBorder_Pic = preload("res://GameSaveRelated/GUIs/GameSettingsRelated/ChangeControlsHotkeyPanel/Assets/ChangeControlsHotkeyPanel_HoverLineBorder.png")

#

signal pressed(arg_control_action_name)

#

var control_identifier_string : String setget set_control_identifier_string

enum HiddenDisplayModeId {
	VISIBILITY = 0,
	CENSOR = 1,
	NONE = 2
}
var hidden_display_mode : int = HiddenDisplayModeId.VISIBILITY setget set_hidden_display_mode


var _is_clickable : bool = false
var _button__normal_image : Texture
var _button__hover_image : Texture

#

var _is_mouse_inside : bool

#

onready var visual_key_press = $DialogTemplate_Body_LineBox/ContentContainer/HBoxContainer/Visual_KeyPress
onready var control_name_label = $DialogTemplate_Body_LineBox/ContentContainer/HBoxContainer/ControlNameMarginer/ControlNameLabel

onready var button = $DialogTemplate_Body_LineBox/ContentContainer/Button

onready var dialog_template_body_linebox = $DialogTemplate_Body_LineBox

#

func set_control_identifier_string(arg_name):
	if !GameSettingsManager.is_connected("game_control_is_hidden_changed", self, "_on_game_control_is_hidden_changed"):
		GameSettingsManager.connect("game_control_is_hidden_changed", self, "_on_game_control_is_hidden_changed")
	
	control_identifier_string = arg_name
	
	if is_inside_tree():
		_update_display()

func _on_game_control_is_hidden_changed(arg_game_control_name, arg_is_hidden):
	if is_inside_tree():
		#_update_display__hidden_related_properties()
		_update_display()

func set_hidden_display_mode(arg_val):
	hidden_display_mode = arg_val
	
	if is_inside_tree():
		_update_display()
		#_update_display__hidden_related_properties()


##

func _update_display():
	_update_display__control_related_properties()
	_update_display__hidden_related_properties()
	

func _update_display__control_related_properties():
	if hidden_display_mode != HiddenDisplayModeId.CENSOR:
		if GameSettingsManager.GAME_CONTROLS_TO_NAME_MAP.has(control_identifier_string):
			control_name_label.text = GameSettingsManager.GAME_CONTROLS_TO_NAME_MAP[control_identifier_string]
		elif GameSettingsManager.MISC_CONTROLS_TO_NAME_MAP.has(control_identifier_string):
			control_name_label.text = GameSettingsManager.MISC_CONTROLS_TO_NAME_MAP[control_identifier_string]
		
	else:
		if GameSettingsManager.get_game_control_name__is_hidden(control_identifier_string):
			control_name_label.text = GameSettingsManager.GAME_CONTROL_HIDDEN_PLACEHOLDER_NAME
		else:
			control_name_label.text = GameSettingsManager.GAME_CONTROLS_TO_NAME_MAP[control_identifier_string]
	
	visual_key_press.game_control_action_name = control_identifier_string

func _update_display__hidden_related_properties():
	if GameSettingsManager.GAME_CONTROLS_TO_NAME_MAP.has(control_identifier_string):
		var is_hidden = GameSettingsManager.get_game_control_name__is_hidden(control_identifier_string)
		
		if hidden_display_mode == HiddenDisplayModeId.VISIBILITY:
			visible = !is_hidden
			
		else:
			visible = true
		
	else:
		visible = true


func _ready():
	_update_display()
	_update_button_based_on_clickable_state()

###########


#func set_button_properties(arg_is_clickable, arg_normal_img : Texture, arg_hover_img : Texture):
#	_is_clickable = arg_is_clickable
#	_button__normal_image = arg_normal_img
#	_button__hover_image = arg_hover_img
#
#	if is_inside_tree():
#		_update_button_based_on_clickable_state()


func set_button_is_clickable(arg_clickable):
	_is_clickable = arg_clickable
	
	if is_inside_tree():
		_update_button_based_on_clickable_state()

func _update_button_based_on_clickable_state():
	if _is_clickable:
		#button.texture_normal = _button__normal_image
		#button.texture_hover = _button__hover_image
		dialog_template_body_linebox.border_texture = ChangeControlsHotkeyPanel_HoverLineBorder_Pic
		#dialog_template_body_linebox.content_container_omni_margin = 6
		dialog_template_body_linebox.content_container_margin_bottom = 6
		dialog_template_body_linebox.content_container_margin_left = 12
		dialog_template_body_linebox.content_container_margin_right = 12
		dialog_template_body_linebox.content_container_margin_top = 6
		
		_connect_button_signals()
		
	else:
		#button.texture_normal = null
		#button.texture_hover = null
		dialog_template_body_linebox.border_texture = null
		#dialog_template_body_linebox.content_container_omni_margin = 0
		dialog_template_body_linebox.content_container_margin_bottom = 0
		dialog_template_body_linebox.content_container_margin_left = 0
		dialog_template_body_linebox.content_container_margin_right = 0
		dialog_template_body_linebox.content_container_margin_top = 0
		
		_disconnect_button_signals()
	
	_update_button_display_based_on_properties()



func _update_button_display_based_on_properties():
	if _is_clickable:
		if _is_mouse_inside:
			dialog_template_body_linebox.border_modulate = Color(1, 1, 1, 1.0)
			
		else:
			dialog_template_body_linebox.border_modulate = Color(1, 1, 1, 0.0)
			
	

#

func _connect_button_signals():
	if !button.is_connected("pressed", self, "_on_button_pressed"):
		button.connect("pressed", self, "_on_button_pressed")
	if !button.is_connected("mouse_entered", self, "_on_button_mouse_entered"):
		button.connect("mouse_entered", self, "_on_button_mouse_entered")
	if !button.is_connected("mouse_exited", self, "_on_button_mouse_exited"):
		button.connect("mouse_exited", self, "_on_button_mouse_exited")

func _disconnect_button_signals():
	if button.is_connected("pressed", self, "_on_button_pressed"):
		button.disconnect("pressed", self, "_on_button_pressed")
	if button.is_connected("mouse_entered", self, "_on_button_mouse_entered"):
		button.disconnect("mouse_entered", self, "_on_button_mouse_entered")
	if button.is_connected("mouse_exited", self, "_on_button_mouse_exited"):
		button.disconnect("mouse_exited", self, "_on_button_mouse_exited")
	
	_is_mouse_inside = false


###

func _on_button_pressed():
	emit_signal("pressed", control_identifier_string)
	

func _on_button_mouse_entered():
	_is_mouse_inside = true
	AudioManager.helper__play_sound_effect__plain(StoreOfAudio.AudioIds.SFX_GUI_Button_Hover, 1.0, null)
	_update_button_display_based_on_properties()

func _on_button_mouse_exited():
	_is_mouse_inside = false
	_update_button_display_based_on_properties()


func _on_CurrControlsSubPanel_SingleControl_visibility_changed():
	_is_mouse_inside = false
	_update_button_display_based_on_properties()

