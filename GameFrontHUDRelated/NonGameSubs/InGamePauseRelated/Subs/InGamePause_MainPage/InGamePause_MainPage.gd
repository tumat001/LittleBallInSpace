extends MarginContainer


onready var button_resume = $MainContainer/FreeFormControl/VBoxContainer/Button_Resume
onready var button_restart = $MainContainer/FreeFormControl/VBoxContainer/Button_Restart
onready var button_main_menu = $MainContainer/FreeFormControl/VBoxContainer/Button_MainMenu

var all_buttons : Array

#

func _ready():
	all_buttons.append(button_resume)
	all_buttons.append(button_restart)
	all_buttons.append(button_main_menu)
	
	var i = 0
	for button in all_buttons:
		var index_before = i - 1
		var index_after = i + 1
		
		if index_after >= all_buttons.size():
			index_after = 0
		
		button.set_focus_neighbour_top(all_buttons[index_before].get_texture_button())
		button.set_focus_neighbour_bottom(all_buttons[index_after].get_texture_button())
		
		i += 1

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
