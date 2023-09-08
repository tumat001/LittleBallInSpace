extends MarginContainer


onready var visual_key_press = $HBoxContainer/Visual_KeyPress
onready var control_name_label = $HBoxContainer/ControlNameMarginer/ControlNameLabel


var control_identifier_string : String setget set_control_identifier_string


func set_control_identifier_string(arg_name):
	if !GameSaveManager.is_connected("game_control_is_hidden_changed", self, "_on_game_control_is_hidden_changed"):
		GameSaveManager.connect("game_control_is_hidden_changed", self, "_on_game_control_is_hidden_changed")
	
	control_identifier_string = arg_name
	
	if is_inside_tree():
		_update_display()
		

func _on_game_control_is_hidden_changed(arg_game_control_name, arg_is_hidden):
	if is_inside_tree():
		_update_display__hidden_related_properties()



func _update_display():
	_update_display__control_related_properties()
	_update_display__hidden_related_properties()
	

func _update_display__control_related_properties():
	control_name_label.text = GameSettingsManager.ALL_SAVABLE_GAME_CONTROLS_TO_NAME_MAP[control_identifier_string]
	#visual_key_press.text_for_keypress = InputMap.get_action_list(control_identifier_string)[0].as_text()
	visual_key_press.game_control_action_name = control_identifier_string

func _update_display__hidden_related_properties():
	var is_hidden = GameSettingsManager.get_game_control_name__is_hidden(control_identifier_string)
	if is_hidden:
		visible = false
	else:
		visible = true



func _ready():
	_update_display()
	
	

##



