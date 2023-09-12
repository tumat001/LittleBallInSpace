extends MarginContainer


const PlayerGUI_HOptionSelection = preload("res://MiscRelated/GUIControlsRelated/PlayerGUI_HOptionSelector/PlayerGUI_HOptionSelector.gd")
const AssistModeDetailsHelper = preload("res://GameSaveRelated/GUIs/GameSettingsRelated/AssistModePanel/Data/AssistModeDetailsHelper.gd")


#

const MODULATE_HOPTION_LABEL__NO_EFFECT = Color(0.8, 0.8, 0.8, 0.8)
const MODULATE_HOPTION_LABEL__WITH_EFFECT = Color("#F6FEBA")

#

onready var label_addtional_energy = $Control/VBoxContainer/HBoxContainer/VBoxName/Label_AdditionalEnergy
onready var label_energy_reduc = $Control/VBoxContainer/HBoxContainer/VBoxName/Label_EnergyReduc
onready var label_additional_ball = $Control/VBoxContainer/HBoxContainer/VBoxName/Label_AdditionalLaunchBall
onready var label_pause_at_esc = $Control/VBoxContainer/HBoxContainer/VBoxName/Label_PauseAtESC

onready var hoption_additional_energy = $Control/VBoxContainer/HBoxContainer/VBoxHOption/HOption_AdditionalEnergy
onready var hoption_energy_reduc = $Control/VBoxContainer/HBoxContainer/VBoxHOption/HOption_EnergyReduc
onready var hoption_additional_ball = $Control/VBoxContainer/HBoxContainer/VBoxHOption/HOption_AdditionalLaunchBall
onready var hoption_pause_at_esc = $Control/VBoxContainer/HBoxContainer/VBoxHOption/HOption_PauseAtESC

onready var restart_label = $Control/VBoxContainer/RestartLabel

var assist_mode_id_to_label_and_hoption_map : Dictionary
var assist_mode_details_helper : AssistModeDetailsHelper

##

func _ready():
	assist_mode_details_helper = GameSettingsManager.assist_mode_details_helper
	_init_assist_mode_id_to_label_and_hoption_map()
	
	GameSettingsManager.connect("assist_mode_id_unlock_status_changed", self, "_on_assist_mode_id_unlock_status_changed")
	_update_options_visiblity_and_config_based_on_game_settings()
	_update_restart_label_vis()

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
	arg_hoption_control.set_selector_items(select_items, selected_item_id, false)


#

func _on_hoption_assist_mode_pressed__intent_for_reactive(arg_intent_item, arg_intent_item_id, arg_assist_mode_id):
	GameSettingsManager.set_curr_val_of_assist_mode_id(arg_assist_mode_id, arg_intent_item_id)



func _on_assist_mode_x_changed__for_hoption(arg_val, arg_assist_mode_id, arg_hoption_control : PlayerGUI_HOptionSelection):
	var no_effect_id = GameSettingsManager.get_no_effect_val_of_assist_mode_id(arg_assist_mode_id)
	if arg_val == no_effect_id:
		arg_hoption_control.set_modulate_for_label(MODULATE_HOPTION_LABEL__NO_EFFECT)
		
	else:
		arg_hoption_control.set_modulate_for_label(MODULATE_HOPTION_LABEL__WITH_EFFECT)
		
	
	arg_hoption_control.


#####

func _on_last_calc_is_any_difference_from_assist_mode_config_to_curr_GE_config_changed(arg_val):
	_update_restart_label_vis()
	

func _update_restart_label_vis():
	restart_label.visible = GameSettingsManager.last_calc_is_any_difference_from_assist_mode_config_to_curr_GE_config
	



##########
