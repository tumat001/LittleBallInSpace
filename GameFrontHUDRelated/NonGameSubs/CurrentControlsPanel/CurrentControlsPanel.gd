extends MarginContainer

const CurrControlSubPanel_SingleControl = preload("res://GameFrontHUDRelated/NonGameSubs/CurrentControlsPanel/Subs/CurrControlsSubPanel_SingleControl.gd")
const CurrControlSubPanel_SingleControl_Scene = preload("res://GameFrontHUDRelated/NonGameSubs/CurrentControlsPanel/Subs/CurrControlsSubPanel_SingleControl.tscn")

#

signal requested_change_hotkeys()

#

onready var curr_controls_container = $VBoxContainer2/CurrControlsContainer


func _ready():
	for control_string in GameSettingsManager.GAME_CONTROLS_TO_NAME_MAP.keys():
		var subpanel_single_control = CurrControlSubPanel_SingleControl_Scene.instance()
		subpanel_single_control.control_identifier_string = control_string
		
		curr_controls_container.add_child(subpanel_single_control)
		
	
	


################

func _on_ChangeHotkeysButton_button_pressed():
	emit_signal("requested_change_hotkeys")


