extends MarginContainer

const GUI_SingleCustomAudioPanel = preload("res://GameSaveRelated/GUIs/GameSettingsRelated/CustomAudioPanel/Subs/GUI_SingleCustomAudioPanel/GUI_SingleCustomAudioPanel.gd")
const GUI_SingleCustomAudioPanel_Scene = preload("res://GameSaveRelated/GUIs/GameSettingsRelated/CustomAudioPanel/Subs/GUI_SingleCustomAudioPanel/GUI_SingleCustomAudioPanel.tscn")

#

var _is_init_all : bool = false

#

onready var vbox_for_SCAP = $VBoxContainer/MarginerForMainScroll/ScrollContainerForMain/MainContainer/VBoxMain/VBoxForSCAP

onready var not_all_unlocked_label = $VBoxContainer/ExtraActionsContainer/VBoxContainer/NotAllUnlockedLabel

onready var is_enabled_checkbox = $VBoxContainer/ExtraActionsContainer/VBoxContainer/MarginContainer/IsEnabledCheckbox

#

func get_all_SCAP():
	return vbox_for_SCAP.get_children()

func _attempt_init():
	if _is_init_all:
		return
	
	##
	
	_is_init_all = true
	
	var at_least_one_locked : bool = false
	for custom_audio_id in GameSettingsManager.CustomAudioIds.values():
		var gui_scap : GUI_SingleCustomAudioPanel = _create_SCAP_for_custom_audio_id(custom_audio_id)
		
		gui_scap.enable()
		
		if !GameSettingsManager.is_custom_audio_unlocked(custom_audio_id):
			at_least_one_locked = true
	
	not_all_unlocked_label.visible = at_least_one_locked
	
	##
	
	_config_with_GSM__is_enabled()


func _create_SCAP_for_custom_audio_id(arg_custom_audio_id):
	var gui_scap = GUI_SingleCustomAudioPanel_Scene.instance()
	
	vbox_for_SCAP.add_child(gui_scap)
	
	gui_scap.attempt_configure_self_details_using_custom_audio_id(arg_custom_audio_id)
	
	return gui_scap

#

func _config_with_GSM__is_enabled():
	_update_is_enabled_checkbox_disp()
	GameSettingsManager.connect("custom_audio_enabled_changed", self, "_on_custom_audio_enabled_changed")

func _on_custom_audio_enabled_changed(arg_val):
	_update_is_enabled_checkbox_disp()

func _update_is_enabled_checkbox_disp():
	is_enabled_checkbox.set_is_checked(GameSettingsManager.custom_audio_config__is_enabled)


#

func _on_IsEnabledCheckbox_pressed__intent_for_reactive(arg_intent_check_val):
	GameSettingsManager.set_custom_audio_config__is_enabled(arg_intent_check_val)

#####


func _on_RefreshButton_button_pressed():
	GameSettingsManager.custom_audio_config__refresh_list_files_in_filesys__all()
	
	_refresh_display()

func _refresh_display():
	for scap in get_all_SCAP():
		scap.refresh_display_of_all__based_on_precalcs()


#############################################
# TREE ITEM Specific methods/vars

var control_tree setget set_control_tree

var _old_control_tree_modulate : Color
const COLOR_FOR_CONTROL_TREE = Color("f5ffffff")

func on_control_received_focus():
	_old_control_tree_modulate = control_tree.background_texture_rect_modulate
	control_tree.set_background_texture_rect_modulate(COLOR_FOR_CONTROL_TREE)
	
	call_deferred("_attempt_init")

func on_control_fully_visible():
	for scap in get_all_SCAP():
		var id = scap.get_custom_audio_id()
		if id != -1:
			scap.attempt_configure_self_details_using_custom_audio_id(id)
			scap.enable()
		
		not_all_unlocked_label.visible = GameSettingsManager.is_at_least_one_custom_audio_is_locked()
		
		scap.refresh_display_of_all__based_on_precalcs()


func on_control_lost_focus():
	control_tree.set_background_texture_rect_modulate(_old_control_tree_modulate)
	for scap in get_all_SCAP():
		scap.disable()
		scap.terminate_all_actions()

func on_control_fully_invisible():
	pass
	

func set_control_tree(arg_tree):
	control_tree = arg_tree
	

############
# END OF TREE ITEM Specific methods/vars
###########

