extends MarginContainer

const StoreOfFonts = preload("res://MiscRelated/FontRelated/StoreOfFonts.gd")



onready var button_resume = $MainContainer/FreeFormControl/VBoxContainer/Button_Resume
onready var button_restart = $MainContainer/FreeFormControl/VBoxContainer/Button_Restart
onready var button_main_menu = $MainContainer/FreeFormControl/VBoxContainer/Button_MainMenu

onready var level_name_tooltip_body = $FreeFormControl/LevelNameTooltipBody


var all_buttons : Array

#

func _ready():
	all_buttons.append(button_resume)
	all_buttons.append(button_restart)
	all_buttons.append(button_main_menu)
	
	_assign_button_neighbors()
	
	##
	
	level_name_tooltip_body.font_id_to_use = StoreOfFonts.FontTypes.PIXEL_EMULATOR
	level_name_tooltip_body.bbcode_align_mode = level_name_tooltip_body.BBCodeAlignMode.CENTER
	
	level_name_tooltip_body.descriptions = SingletonsAndConsts.current_level_details.level_full_name
	level_name_tooltip_body.update_display()


#

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

##############

func _on_Button_Resume_button_pressed():
	control_tree.hide_control__and_traverse_thru_hierarchy__if_control(self, false)
	#control_tree.hide_current_control__and_traverse_thru_hierarchy(false)

func _on_Button_Restart_button_pressed():
	if !SingletonsAndConsts.current_game_elements.game_result_manager.is_game_result_decided:
		SingletonsAndConsts.switch_to_game_elements__from_game_elements__from_restart()


func _on_Button_MainMenu_button_pressed():
	if !SingletonsAndConsts.current_game_elements.game_result_manager.is_game_result_decided:
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
