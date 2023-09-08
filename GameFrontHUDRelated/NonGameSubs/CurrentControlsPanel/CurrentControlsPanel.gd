extends MarginContainer

const CurrControlSubPanel_SingleControl = preload("res://GameFrontHUDRelated/NonGameSubs/CurrentControlsPanel/Subs/CurrControlsSubPanel_SingleControl.gd")
const CurrControlSubPanel_SingleControl_Scene = preload("res://GameFrontHUDRelated/NonGameSubs/CurrentControlsPanel/Subs/CurrControlsSubPanel_SingleControl.tscn")


onready var vbox_container = $VBoxContainer


func _ready():
	for control_string in GameSettingsManager.ALL_SAVABLE_GAME_CONTROLS_TO_NAME_MAP.keys():
		var subpanel_single_control = CurrControlSubPanel_SingleControl_Scene.instance()
		subpanel_single_control.control_identifier_string = control_string
		
		vbox_container.add_child(subpanel_single_control)
		
	
	


