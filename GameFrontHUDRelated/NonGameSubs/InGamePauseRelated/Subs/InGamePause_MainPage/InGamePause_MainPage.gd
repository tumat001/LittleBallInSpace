extends MarginContainer


onready var button_resume = $FreeFormControl/VBoxContainer/Button_Resume
onready var button_restart = $FreeFormControl/VBoxContainer/Button_Restart
onready var button_main_menu = $FreeFormControl/VBoxContainer/Button_MainMenu

var all_buttons : Array

#

func _ready():
	all_buttons.append(button_resume)
	all_buttons.append(button_restart)
	all_buttons.append(button_main_menu)

##############

func _on_Button_Resume_button_pressed():
	control_tree.hide_control__and_traverse_thru_hierarchy__if_control(self, true)


func _on_Button_Restart_button_pressed():
	SingletonsAndConsts.switch_to_game_elements__from_game_elements__from_restart()


func _on_Button_MainMenu_button_pressed():
	SingletonsAndConsts.switch_to_level_selection_scene__from_game_elements__from_quit()



##########
# TREE ITEM Specific methods/vars

var control_tree


func on_control_received_focus():
	pass
	

func on_control_fully_visible():
	button_resume.grab_focus()
	

func on_control_lost_focus():
	for button in all_buttons:
		button.lose_focus()
	

func on_control_fully_invisible():
	pass
	

############
# END OF TREE ITEM Specific methods/vars
###########
