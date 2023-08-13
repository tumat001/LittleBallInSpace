extends MarginContainer

onready var button_resume = $MainPanel/Control/Button_Resume
onready var button_quit = $MainPanel/Control/Button_Quit

var all_buttons : Array



func _ready():
	all_buttons.append(button_resume)
	all_buttons.append(button_quit)
	
	_assign_button_neighbors()


func _assign_button_neighbors():
	var i = 0
	for button in all_buttons:
		var index_before = i - 1
		var index_after = i + 1
		
		if index_after >= all_buttons.size():
			index_after = 0
		
		button.set_focus_neighbour_top(all_buttons[index_before].get_texture_button())
		button.set_focus_neighbour_bottom(all_buttons[index_after].get_texture_button())
		
		i += 1





func _on_Button_Resume_button_pressed():
	control_tree.hide_control__and_traverse_thru_hierarchy__if_control(self, false)

func _on_Button_Quit_button_pressed():
	get_tree().notification(MainLoop.NOTIFICATION_WM_QUIT_REQUEST)
	


#############################################
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
