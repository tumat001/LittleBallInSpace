extends MarginContainer


const PlayerGUI_HOptionSelection = preload("res://MiscRelated/GUIControlsRelated/PlayerGUI_HOptionSelector/PlayerGUI_HOptionSelector.gd")


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


##

func _ready():
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
		_init_and_update_hoption_val(id, assist_mode_id_to_label_and_hoption_map[id][1])

func _on_assist_mode_id_unlock_status_changed(arg_id, arg_is_unlocked):
	_update_visibility_of_options_of_id(arg_id, arg_is_unlocked)
	

func _update_visibility_of_options_of_id(arg_id, arg_is_unlocked):
	var make_controls_vis : bool = false
	if arg_is_unlocked:
		make_controls_vis = true
	
	for control in assist_mode_id_to_label_and_hoption_map[arg_id]:
		control.visible = make_controls_vis
	
	



func _init_and_update_hoption_val(arg_id, arg_hoption_control):
	if arg_id == GameSettingsManager.AssistModeId.ADDITIONAL_ENERGY_MODE:
		_init_hoption__additional_energy_mode(arg_hoption_control)
		
	elif arg_id == GameSettingsManager.AssistModeId.ENERGY_REDUC_MODE:
		pass
		
	elif arg_id == GameSettingsManager.AssistModeId.ADDITIONAL_LAUNCH_BALL_MODE:
		pass
		
	elif arg_id == GameSettingsManager.AssistModeId.PAUSE_AT_ESC_MODE:
		pass
		
	else:
		print("ASSIST MODE MAIN PANEL -- Unaccounted assist mode id: %s" % arg_id)


func _init_hoption__additional_energy_mode(arg_hoption_control):
	pass
	




#####

func _on_last_calc_is_any_difference_from_assist_mode_config_to_curr_GE_config_changed(arg_val):
	_update_restart_label_vis()
	

func _update_restart_label_vis():
	restart_label.visible = GameSettingsManager.last_calc_is_any_difference_from_assist_mode_config_to_curr_GE_config
	



##########

func _on_HOption_AdditionalEnergy_pressed__intent_for_reactive(arg_intent_item, arg_intent_item_id):
	pass # Replace with function body.


func _on_HOption_EnergyReduc_pressed__intent_for_reactive(arg_intent_item, arg_intent_item_id):
	pass # Replace with function body.


func _on_HOption_AdditionalLaunchBall_pressed__intent_for_reactive(arg_intent_item, arg_intent_item_id):
	pass # Replace with function body.


func _on_HOption_PauseAtESC_pressed__intent_for_reactive(arg_intent_item, arg_intent_item_id):
	pass # Replace with function body.



