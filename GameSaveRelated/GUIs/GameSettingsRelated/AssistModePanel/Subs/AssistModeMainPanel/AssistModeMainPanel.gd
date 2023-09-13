extends MarginContainer


const PlayerGUI_HOptionSelection = preload("res://MiscRelated/GUIControlsRelated/PlayerGUI_HOptionSelector/PlayerGUI_HOptionSelector.gd")
const AssistModeDetailsHelper = preload("res://GameSaveRelated/GUIs/GameSettingsRelated/AssistModePanel/Data/AssistModeDetailsHelper.gd")


const AssistModeAbout_Cutscene_Scene = preload("res://MiscRelated/CutsceneRelated/Imps/Cutscenes/AssistModeAbout/AssistModeAbout_Cutscene.tscn")

#

var _ignore_inputs : bool

#

const MODULATE_HOPTION_LABEL__NO_EFFECT = Color(0.7, 0.7, 0.7, 0.8)
const MODULATE_HOPTION_LABEL__WITH_EFFECT = Color("#E9FC59")


const ENABLED_MODUALTE = Color(1, 1, 1, 1)
const DISABLED_MODULATE = Color(0.6, 0.6, 0.6, 0.75)


const ASSIST_MODE_TOGGLE__TEXT__IN_GAME = "For This Level Only:"
const ASSIST_MODE_TOGGLE__TEXT__NOT_IN_GAME = "For Next Level Only:"

#

var _assist_mode_about_cutscene

#

onready var label_addtional_energy = $Control/VBoxContainer/VBoxContainer/HBoxContainer/VBoxName/Label_AdditionalEnergy
onready var label_energy_reduc = $Control/VBoxContainer/VBoxContainer/HBoxContainer/VBoxName/Label_EnergyReduc
onready var label_additional_ball = $Control/VBoxContainer/VBoxContainer/HBoxContainer/VBoxName/Label_AdditionalLaunchBall
onready var label_pause_at_esc = $Control/VBoxContainer/VBoxContainer/HBoxContainer/VBoxName/Label_PauseAtESC

onready var hoption_additional_energy = $Control/VBoxContainer/VBoxContainer/HBoxContainer/VBoxHOption/HOption_AdditionalEnergy
onready var hoption_energy_reduc = $Control/VBoxContainer/VBoxContainer/HBoxContainer/VBoxHOption/HOption_EnergyReduc
onready var hoption_additional_ball = $Control/VBoxContainer/VBoxContainer/HBoxContainer/VBoxHOption/HOption_AdditionalLaunchBall
onready var hoption_pause_at_esc = $Control/VBoxContainer/VBoxContainer/HBoxContainer/VBoxHOption/HOption_PauseAtESC

onready var restart_label = $Control/RestartLabel

onready var is_assist_mode_active_checkbox = $Control/VBoxContainer/VBoxContainer/HBoxContainer2/EnableAssistModeCheckbox
onready var assist_mode_toggle_mode_checkbox = $Control/VBoxContainer/VBoxContainer/HBoxContainer2/AssistModeToggleCheckbox

onready var hbox_container_of_assist_mode_ids = $Control/VBoxContainer/VBoxContainer/HBoxContainer

onready var not_all_unlocked_label = $Control/NotAllUnlockedLabel


var _all_hoptions : Array

#

var is_in_game : bool

#

var assist_mode_id_to_label_and_hoption_map : Dictionary
var assist_mode_details_helper : AssistModeDetailsHelper

##

func _ready():
	assist_mode_details_helper = GameSettingsManager.assist_mode_details_helper
	_init_assist_mode_id_to_label_and_hoption_map()
	
	GameSettingsManager.connect("assist_mode_id_unlock_status_changed", self, "_on_assist_mode_id_unlock_status_changed")
	_update_options_visiblity_and_config_based_on_game_settings()
	_update_restart_label_vis()
	
	_init_assist_mode_is_active_all_relateds()
	_init_assist_mode_toggle_mode_all_relateds()
	
	_init_not_all_unlocked_label()
	

#

func _init_assist_mode_id_to_label_and_hoption_map():
	assist_mode_id_to_label_and_hoption_map[GameSettingsManager.AssistModeId.ADDITIONAL_ENERGY_MODE] = [
		label_addtional_energy, hoption_additional_energy
	]
	assist_mode_id_to_label_and_hoption_map[GameSettingsManager.AssistModeId.ENERGY_REDUC_MODE] = [
		label_energy_reduc, hoption_energy_reduc
	]
	assist_mode_id_to_label_and_hoption_map[GameSettingsManager.AssistModeId.ADDITIONAL_LAUNCH_BALL_MODE] = [
		label_additional_ball, hoption_additional_ball
	]
	assist_mode_id_to_label_and_hoption_map[GameSettingsManager.AssistModeId.PAUSE_AT_ESC_MODE] = [
		label_pause_at_esc, hoption_pause_at_esc
	]
	
	
	_all_hoptions.append(hoption_additional_energy)
	_all_hoptions.append(hoption_energy_reduc)
	_all_hoptions.append(hoption_additional_ball)
	_all_hoptions.append(hoption_pause_at_esc)
	

#

func _update_options_visiblity_and_config_based_on_game_settings():
	for id in GameSettingsManager.AssistModeId.values():
		var is_unlocked = GameSettingsManager.is_assist_mode_id_unlocked(id)
		_update_visibility_of_options_of_id(id, is_unlocked)
		
		var hoption = assist_mode_id_to_label_and_hoption_map[id][1]
		_config_signals_of_hoption(id, hoption)
		_init_and_update_hoption_val(id, hoption)

func _on_assist_mode_id_unlock_status_changed(arg_id, arg_is_unlocked):
	_update_visibility_of_options_of_id(arg_id, arg_is_unlocked)
	

func _update_visibility_of_options_of_id(arg_id, arg_is_unlocked):
	var make_controls_vis : bool = false
	if arg_is_unlocked:
		make_controls_vis = true
	
	for control in assist_mode_id_to_label_and_hoption_map[arg_id]:
		control.visible = make_controls_vis
	
	_update_not_all_unlocked_label_status()



func _config_signals_of_hoption(arg_id, arg_hoption_control : PlayerGUI_HOptionSelection):
	arg_hoption_control.connect("pressed__intent_for_reactive", self, "_on_hoption_assist_mode_pressed__intent_for_reactive", [arg_id])
	


func _init_and_update_hoption_val(arg_id, arg_hoption_control):
	if arg_id == GameSettingsManager.AssistModeId.ADDITIONAL_ENERGY_MODE:
		_init_hoption__additional_energy_mode(arg_id, arg_hoption_control)
		
	elif arg_id == GameSettingsManager.AssistModeId.ENERGY_REDUC_MODE:
		_init_hoption__energy_reduc_mode(arg_id, arg_hoption_control)
		
	elif arg_id == GameSettingsManager.AssistModeId.ADDITIONAL_LAUNCH_BALL_MODE:
		_init_hoption__additional_ball_mode(arg_id, arg_hoption_control)
		
	elif arg_id == GameSettingsManager.AssistModeId.PAUSE_AT_ESC_MODE:
		_init_hoption__pause_at_esc_mode(arg_id, arg_hoption_control)
		
	else:
		print("ASSIST MODE MAIN PANEL -- Unaccounted assist mode id: %s" % arg_id)


func _init_hoption__additional_energy_mode(arg_id, arg_hoption_control : PlayerGUI_HOptionSelection):
	_init_hoption__any_template(arg_id, arg_hoption_control)

func _init_hoption__energy_reduc_mode(arg_id, arg_hoption_control : PlayerGUI_HOptionSelection):
	_init_hoption__any_template(arg_id, arg_hoption_control)

func _init_hoption__additional_ball_mode(arg_id, arg_hoption_control : PlayerGUI_HOptionSelection):
	_init_hoption__any_template(arg_id, arg_hoption_control)

func _init_hoption__pause_at_esc_mode(arg_id, arg_hoption_control : PlayerGUI_HOptionSelection):
	_init_hoption__any_template(arg_id, arg_hoption_control)
	


func _init_hoption__any_template(arg_id, arg_hoption_control : PlayerGUI_HOptionSelection):
	var signal_name_of_assist_mode_changed = GameSettingsManager.get_val_changed_signal_name_of_assist_mode_id(arg_id)
	GameSettingsManager.connect(signal_name_of_assist_mode_changed, self, "_on_assist_mode_x_changed__for_hoption", [arg_id, arg_hoption_control])
	
	var select_items = assist_mode_details_helper.get_select_item_list_of_assist_mode_id(arg_id)
	var selected_item_id = GameSettingsManager.get_curr_val_of_assist_mode_id(arg_id)
	arg_hoption_control.set_selector_items__use_id_for_selected(select_items, selected_item_id, false)
	
	_update_hoption_label_modulate(selected_item_id, arg_id, arg_hoption_control)
	

#

func _on_hoption_assist_mode_pressed__intent_for_reactive(arg_intent_item, arg_intent_item_id, arg_assist_mode_id):
	if !_ignore_inputs:
		
		#print("intent: %s, %s, assist_mode_id: %s" % [arg_intent_item.display_value, arg_intent_item_id, arg_assist_mode_id])
		GameSettingsManager.set_curr_val_of_assist_mode_id(arg_assist_mode_id, arg_intent_item_id)



func _on_assist_mode_x_changed__for_hoption(arg_val, arg_assist_mode_id, arg_hoption_control : PlayerGUI_HOptionSelection):
	_update_hoption_label_modulate(arg_val, arg_assist_mode_id, arg_hoption_control)
	
	#print("setted val: %s" % arg_val)
	arg_hoption_control.set_selected_item__using_id(arg_val)

func _update_hoption_label_modulate(arg_val, arg_assist_mode_id, arg_hoption_control):
	var no_effect_id = GameSettingsManager.get_no_effect_val_of_assist_mode_id(arg_assist_mode_id)
	if arg_val == no_effect_id:
		arg_hoption_control.set_modulate_for_label(MODULATE_HOPTION_LABEL__NO_EFFECT)
	else:
		arg_hoption_control.set_modulate_for_label(MODULATE_HOPTION_LABEL__WITH_EFFECT)
	
	

#####

func _on_last_calc_is_any_difference_from_assist_mode_config_to_curr_GE_config_changed(arg_val):
	_update_restart_label_vis()
	

func _update_restart_label_vis():
	restart_label.visible = GameSettingsManager.last_calc_is_any_difference_from_assist_mode_config_to_curr_GE_config
	

##########

func _init_assist_mode_is_active_all_relateds():
	GameSettingsManager.connect("is_assist_mode_active_changed", self, "_on_is_assist_mode_active_changed")
	_update_display_based_on_is_assist_mode_active()

func _on_is_assist_mode_active_changed(arg_val):
	_update_display_based_on_is_assist_mode_active()

func _update_display_based_on_is_assist_mode_active():
	if GameSettingsManager.is_assist_mode_active:
		for hoption in _all_hoptions:
			hoption.set_is_disabled(false, false)
		#	hoption.modulate = ENABLED_MODUALTE
		assist_mode_toggle_mode_checkbox.set_is_disabled(false, false)
		assist_mode_toggle_mode_checkbox.modulate = ENABLED_MODUALTE
		is_assist_mode_active_checkbox.set_is_checked(true)
		hbox_container_of_assist_mode_ids.modulate = ENABLED_MODUALTE
		
	else:
		for hoption in _all_hoptions:
			hoption.set_is_disabled(true, false)
		#	hoption.modulate = DISABLED_MODULATE
		assist_mode_toggle_mode_checkbox.set_is_disabled(true, false)
		assist_mode_toggle_mode_checkbox.modulate = DISABLED_MODULATE
		is_assist_mode_active_checkbox.set_is_checked(false)
		hbox_container_of_assist_mode_ids.modulate = DISABLED_MODULATE
	

#

func _init_assist_mode_toggle_mode_all_relateds():
	GameSettingsManager.connect("assist_mode_toggle_active_mode_changed", self, "_on_assist_mode_toggle_active_mode_changed")
	_update_display_based_on_assist_mode_toggle_mode()
	
	if is_in_game:
		assist_mode_toggle_mode_checkbox.label_text = ASSIST_MODE_TOGGLE__TEXT__IN_GAME
	else:
		assist_mode_toggle_mode_checkbox.label_text = ASSIST_MODE_TOGGLE__TEXT__NOT_IN_GAME


func _on_assist_mode_toggle_active_mode_changed(arg_val):
	_update_display_based_on_assist_mode_toggle_mode()

func _update_display_based_on_assist_mode_toggle_mode():
	if GameSettingsManager.assist_mode_toggle_active_mode_id == GameSettingsManager.AssistMode_ToggleActiveModeId.FOR_THIS_LEVEL_ONLY:
		assist_mode_toggle_mode_checkbox.set_is_checked(true)
		
	else:
		assist_mode_toggle_mode_checkbox.set_is_checked(false)
		


####

func _on_EnableAssistModeCheckbox_pressed__intent_for_reactive(arg_intent_check_val):
	if !_ignore_inputs:
		GameSettingsManager.is_assist_mode_active = arg_intent_check_val


func _on_AssistModeToggleCheckbox_pressed__intent_for_reactive(arg_intent_check_val):
	if !_ignore_inputs:
		if arg_intent_check_val:
			GameSettingsManager.assist_mode_toggle_active_mode_id = GameSettingsManager.AssistMode_ToggleActiveModeId.FOR_THIS_LEVEL_ONLY
		else:
			GameSettingsManager.assist_mode_toggle_active_mode_id = GameSettingsManager.AssistMode_ToggleActiveModeId.FOR_ALL_LEVELS
	

#

func _init_not_all_unlocked_label():
	_update_not_all_unlocked_label_status()

func _update_not_all_unlocked_label_status():
	if GameSettingsManager.is_all_assist_mode_ids_unlocked():
		not_all_unlocked_label.visible = false
	else:
		not_all_unlocked_label.visible = true


#############################################
# TREE ITEM Specific methods/vars

var control_tree setget set_control_tree


func on_control_received_focus():
	_ignore_inputs = true

func on_control_fully_visible():
	_ignore_inputs = false

func on_control_lost_focus():
	_ignore_inputs = true

func on_control_fully_invisible():
	_ignore_inputs = true


func set_control_tree(arg_tree):
	control_tree = arg_tree
	
	#print('setted control tree')
	var button : TextureButton = control_tree.create_texture_button__with_info_textures()
	button.connect("pressed", self, "_on_assist_about_button_pressed")
	control_tree.add_custom_top_right_button__and_associate_with_control(button, self)


func _on_assist_about_button_pressed():
	request_show_assist_mode_about_cutscene()

func request_show_assist_mode_about_cutscene():
	if !is_instance_valid(_assist_mode_about_cutscene):
		_init_assist_mode_about_cutscene()
	_show_assist_mode_about_cutscene()

func _init_assist_mode_about_cutscene():
	_assist_mode_about_cutscene = AssistModeAbout_Cutscene_Scene.instance()
	control_tree.add_control__but_dont_show(_assist_mode_about_cutscene)

func _show_assist_mode_about_cutscene():
	control_tree.show_control__and_add_if_unadded(_assist_mode_about_cutscene)
	_assist_mode_about_cutscene.reset_for_another_use()
	_assist_mode_about_cutscene.start_display()
	
	if !_assist_mode_about_cutscene.is_connected("cutscene_ended", self, "_on_assist_mode_aboout_cutscene_ended"):
		_assist_mode_about_cutscene.connect("cutscene_ended", self, "_on_assist_mode_aboout_cutscene_ended")

func _on_assist_mode_aboout_cutscene_ended():
	control_tree.hide_current_control__and_traverse_thru_hierarchy(true)
	


############
# END OF TREE ITEM Specific methods/vars
###########
