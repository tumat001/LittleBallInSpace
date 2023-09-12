extends MarginContainer


const GUI_ChangeControlsHotkeyPanel = preload("res://GameSaveRelated/GUIs/GameSettingsRelated/ChangeControlsHotkeyPanel/GUI_ChangeControlsHotkeyPanel.gd")
const GUI_ChangeControlsHotkeyPanel_Scene = preload("res://GameSaveRelated/GUIs/GameSettingsRelated/ChangeControlsHotkeyPanel/GUI_ChangeControlsHotkeyPanel.tscn")


#

var _gui_change_controls_hotkeys_panel : GUI_ChangeControlsHotkeyPanel

#

onready var button_resume = $MainPanel/Control/Button_Resume
onready var button_quit = $MainPanel/Control/Button_Quit

onready var assist_mode_mini_summary_panel = $FreeFormControl/VBoxContainer/AssistModeMiniSummaryPanel

var all_buttons : Array



func _ready():
	all_buttons.append(button_resume)
	all_buttons.append(button_quit)
	
	_assign_button_neighbors()
	
	#
	
	assist_mode_mini_summary_panel.control_tree = control_tree
	assist_mode_mini_summary_panel.is_in_game = false

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
	accept_event()
	control_tree.hide_control__and_traverse_thru_hierarchy__if_control(self, false)

func _on_Button_Quit_button_pressed():
	accept_event()
	get_tree().notification(MainLoop.NOTIFICATION_WM_QUIT_REQUEST)
	



func _on_CurrentControlsPanel_requested_change_hotkeys():
	if !is_instance_valid(_gui_change_controls_hotkeys_panel):
		_init_gui_change_controls_hotkeys_panel()
	
	_show_gui_change_controls_hotkeys_panel()

func _init_gui_change_controls_hotkeys_panel():
	_gui_change_controls_hotkeys_panel = GUI_ChangeControlsHotkeyPanel_Scene.instance()
	control_tree.add_control__but_dont_show(_gui_change_controls_hotkeys_panel)


func _show_gui_change_controls_hotkeys_panel():
	control_tree.show_control__and_add_if_unadded(_gui_change_controls_hotkeys_panel)
	
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
