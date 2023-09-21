extends MarginContainer

const CurrControlSubPanel_SingleControl = preload("res://GameFrontHUDRelated/NonGameSubs/CurrentControlsPanel/Subs/CurrControlsSubPanel_SingleControl.gd")
const CurrControlSubPanel_SingleControl_Scene = preload("res://GameFrontHUDRelated/NonGameSubs/CurrentControlsPanel/Subs/CurrControlsSubPanel_SingleControl.tscn")


onready var controls_vbox = $VBoxContainer

onready var CCSP_SC__ToggleHideHud = $VBoxContainer/CCSP_SingleControl__ToggleHideHud
onready var CCSP_SC__Screenshot = $VBoxContainer/VBoxContainer/CCSP_SingleControl__ScreenShot

onready var screen_shot_label = $VBoxContainer/VBoxContainer/ScreenShotLabel

#

func _ready():
	_configure_ccsp_sc__common_template(CCSP_SC__ToggleHideHud)
	_configure_ccsp_sc__common_template(CCSP_SC__Screenshot)
	
	CCSP_SC__ToggleHideHud.control_identifier_string = "toggle_hide_hud"
	CCSP_SC__Screenshot.control_identifier_string = "printscreen"
	
	#
	
	_init_screen_shot_label_text()

func _configure_ccsp_sc__common_template(arg_ccsp : CurrControlSubPanel_SingleControl):
	arg_ccsp.set_button_is_clickable(false)

func _init_screen_shot_label_text():
	var orig_text = screen_shot_label.text
	screen_shot_label.text = orig_text % [GameSaveManager.get_absolute_path_of__user_dir__img_save_filepath()]
	


#func _ready():
#	for misc_control_action in GameSettingsManager.MISC_CONTROLS_TO_NAME_MAP.keys():
#		var misc_control_name = GameSettingsManager.MISC_CONTROLS_TO_NAME_MAP[misc_control_action]
#
#		var subpanel_single_control = CurrControlSubPanel_SingleControl_Scene.instance()
#		subpanel_single_control.control_identifier_string = misc_control_action
#		#subpanel_single_control.set_button_properties(true, null, CurrControlSubPanel_ButtonHoverBorder_Pic)
#		subpanel_single_control.set_button_is_clickable(false)
#
#		controls_vbox.add_child(subpanel_single_control)
#


#############################################
# TREE ITEM Specific methods/vars

var control_tree

func on_control_received_focus():
	pass

func on_control_fully_visible():
	pass

func on_control_lost_focus():
	pass

func on_control_fully_invisible():
	pass

############
# END OF TREE ITEM Specific methods/vars
###########

