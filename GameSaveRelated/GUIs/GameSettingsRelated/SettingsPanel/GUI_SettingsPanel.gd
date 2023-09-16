extends MarginContainer


onready var checkbox_fullscreen = $DialogTemplate_Body_CBM/GridContainer/MidContainer/ContentContainer/VBoxContainer/Checkbox_Fullscreen
onready var spin_box_rotation_duration = $DialogTemplate_Body_CBM/GridContainer/MidContainer/ContentContainer/VBoxContainer/SpinBox_RotationDuration


func _ready():
	_init_setting__fullscreen()
	_init_setting__rotation_duration()

#

func _init_setting__fullscreen():
	GameSettingsManager.connect("settings_config__is_full_screen_changed", self, "_on_settings_config__is_full_screen_changed")
	checkbox_fullscreen.connect("pressed__intent_for_reactive", self, "_on_checkbox_fullscreen_pressed__intent_for_reactive")
	_update_checkbox_fullscreen_val()

func _on_settings_config__is_full_screen_changed(arg_val):
	_update_checkbox_fullscreen_val()

func _update_checkbox_fullscreen_val():
	checkbox_fullscreen.set_is_checked(GameSettingsManager.settings_config__is_full_screen, false)
	


func _on_checkbox_fullscreen_pressed__intent_for_reactive(arg_intent_check_val):
	GameSettingsManager.settings_config__is_full_screen = arg_intent_check_val
	

#

func _init_setting__rotation_duration():
	# no intent, so this is da way
	spin_box_rotation_duration.connect("value_changed", self, "_on_spin_box_rotation_duration_val_changed")
	
	spin_box_rotation_duration.adjust_min_spaces_of_spin_box_based_on_suffix = true
	spin_box_rotation_duration.spin_box_suffix = "seconds"
	
	#
	
	spin_box_rotation_duration.set_value(GameSettingsManager.settings_config__cam_rotation_duration, true)

func _on_spin_box_rotation_duration_val_changed(arg_val):
	GameSettingsManager.settings_config__cam_rotation_duration = arg_val
	


#

func _on_Button_ResetToDefault_button_pressed():
	spin_box_rotation_duration.set_value(GameSettingsManager.settings_config__cam_rotation_duration__default, false)




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

