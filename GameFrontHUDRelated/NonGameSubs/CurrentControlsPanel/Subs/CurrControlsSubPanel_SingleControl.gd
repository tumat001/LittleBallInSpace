extends MarginContainer


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

onready var visual_key_press = $HBoxContainer/Visual_KeyPress
onready var control_name_label = $HBoxContainer/ControlNameMarginer/ControlNameLabel

onready var button = $Button

#

func set_control_identifier_string(arg_name):
	if !GameSaveManager.is_connected("game_control_is_hidden_changed", self, "_on_game_control_is_hidden_changed"):
		GameSaveManager.connect("game_control_is_hidden_changed", self, "_on_game_control_is_hidden_changed")
	
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
		control_name_label.text = GameSettingsManager.GAME_CONTROLS_TO_NAME_MAP[control_identifier_string]
	else:
		control_name_label.text = GameSettingsManager.GAME_CONTROL_HIDDEN_PLACEHOLDER_NAME
	
	visual_key_press.game_control_action_name = control_identifier_string

func _update_display__hidden_related_properties():
	var is_hidden = GameSettingsManager.get_game_control_name__is_hidden(control_identifier_string)
	
	if hidden_display_mode == HiddenDisplayModeId.VISIBILITY:
		visible = !is_hidden
		
	else:
		visible = true
	


func _ready():
	_update_display()
	_update_button_based_on_clickable_state()

###########


func set_button_properties(arg_is_clickable, arg_normal_img : Texture, arg_hover_img : Texture):
	_is_clickable = arg_is_clickable
	_button__normal_image = arg_normal_img
	_button__hover_image = arg_hover_img
	
	if is_inside_tree():
		_update_button_based_on_clickable_state()

func _update_button_based_on_clickable_state():
	if _is_clickable:
		button.texture_normal = _button__normal_image
		button.texture_hover = _button__normal_image
		if !button.is_connected("pressed", self, "_on_button_pressed"):
			button.connect("pressed", self, "_on_button_pressed")
		
	else:
		button.texture_normal = null
		button.texture_hover = null
		if button.is_connected("pressed", self, "_on_button_pressed"):
			button.disconnect("pressed", self, "_on_button_pressed")
		


func _on_button_pressed():
	emit_signal("pressed", control_identifier_string)
	



