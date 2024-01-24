extends MarginContainer

const AssistModeMainPanel = preload("res://GameSaveRelated/GUIs/GameSettingsRelated/AssistModePanel/Subs/AssistModeMainPanel/AssistModeMainPanel.gd")
const AssistModeMainPanel_Scene = preload("res://GameSaveRelated/GUIs/GameSettingsRelated/AssistModePanel/Subs/AssistModeMainPanel/AssistModeMainPanel.tscn")

#

const MODULATE__BANNED = Color("#F29797")
const MODULATE__NORMAL = Color("#bbbbbb")

#

var _assist_mode_main_panel : AssistModeMainPanel

#

var is_in_game : bool setget set_is_in_game

#

var control_tree

onready var main_button = $VBoxContainer/MainButton
onready var label_status = $VBoxContainer/LabelStatus

#

func _ready():
	_update_vis_based_on_if_anything_is_unlocked__from_ready()
	
	_update_status_based_on_configs()
	_update_connection_to_signals__based_on_states()


func _update_vis_based_on_if_anything_is_unlocked__from_ready():
	if GameSettingsManager.is_any_assist_mode_id_unlocked():
		_make_show_self__any_assist_mode_id_is_unlocked()
		
	else:
		visible = false
		GameSettingsManager.connect("assist_mode_id_unlock_status_changed", self, "_on_assist_mode_id_unlock_status_changed__for_vis_changes")
	

func _on_assist_mode_id_unlock_status_changed__for_vis_changes(arg_id, arg_val):
	if GameSettingsManager.is_any_assist_mode_id_unlocked():
		_make_show_self__any_assist_mode_id_is_unlocked()
		GameSettingsManager.disconnect("assist_mode_id_unlock_status_changed", self, "_on_assist_mode_id_unlock_status_changed__for_vis_changes")

func _make_show_self__any_assist_mode_id_is_unlocked():
	visible = true


#

func set_is_in_game(arg_val):
	is_in_game = arg_val
	
	_update_connection_to_signals__based_on_states()
	_update_status_based_on_configs()

func _update_status_based_on_configs():
	var is_disabled = false
	if SingletonsAndConsts.current_level_details != null:
		is_disabled = SingletonsAndConsts.current_level_details.ignore_assist_mode_modifications
	
	main_button.set_is_disabled(is_disabled)
	if is_disabled:
		label_status.text = "(Banned for This Level)"
		label_status.modulate = MODULATE__BANNED
		
	elif is_in_game:
		#print("from GE. %s" % self)
		if GameSettingsManager.current_assist_mode_is_active_at_current_game_elements__but_no_effect:
			label_status.text = "(Active, but No Effect)"
			label_status.modulate = GameSettingsManager.ASSIST_MODE__TEXT_MODULATE__LIGHT
		elif GameSettingsManager.current_assist_mode_is_active_at_current_game_elements:
			label_status.text = "(Active)"
			label_status.modulate = GameSettingsManager.ASSIST_MODE__TEXT_MODULATE__LIGHT
		else:
			label_status.text = "(Inactive)"
			label_status.modulate = MODULATE__NORMAL
		
	elif !is_in_game:
		#print("not from GE. %s" % self)
		_update_label_status__based_on_game_settings__not_for_current_GE()
		


func _update_connection_to_signals__based_on_states():
	if !is_in_game:
		if !GameSettingsManager.is_connected("any_game_modifying_assist_mode_settings_changed", self, "_on_any_game_modifying_assist_mode_settings_changed"):
			GameSettingsManager.connect("any_game_modifying_assist_mode_settings_changed", self, "_on_any_game_modifying_assist_mode_settings_changed")
	else:
		if GameSettingsManager.is_connected("any_game_modifying_assist_mode_settings_changed", self, "_on_any_game_modifying_assist_mode_settings_changed"):
			GameSettingsManager.disconnect("any_game_modifying_assist_mode_settings_changed", self, "_on_any_game_modifying_assist_mode_settings_changed")


func _on_any_game_modifying_assist_mode_settings_changed():
	_update_status_based_on_configs()
	#_update_label_status__based_on_game_settings__not_for_current_GE()


func _update_label_status__based_on_game_settings__not_for_current_GE():
	if GameSettingsManager.is_assist_mode_active:
		if !GameSettingsManager.is_any_game_modifying_assist_mode_can_make_changes_based_on_curr_vals():
			label_status.text = "(Active, but No Effect)"
			label_status.modulate = GameSettingsManager.ASSIST_MODE__TEXT_MODULATE__LIGHT
			
		else:
			label_status.text = "(Active)"
			label_status.modulate = GameSettingsManager.ASSIST_MODE__TEXT_MODULATE__LIGHT
			
		
	else:
		label_status.text = "(Inactive)"
		label_status.modulate = MODULATE__NORMAL
		


############

func _on_MainButton_button_pressed():
	if !is_instance_valid(_assist_mode_main_panel):
		_init_assist_mode_main_panel()
	
	_show_assist_mode_main_panel()

func _init_assist_mode_main_panel():
	_assist_mode_main_panel = AssistModeMainPanel_Scene.instance()
	_assist_mode_main_panel.is_in_game = is_in_game
	control_tree.add_control__but_dont_show(_assist_mode_main_panel)
	

func _show_assist_mode_main_panel():
	if GameSettingsManager.is_assist_mode_first_time_open:
		control_tree.attempt_add_control_to_current_hierarchy(_assist_mode_main_panel)
		_assist_mode_main_panel.request_show_assist_mode_about_cutscene()
		GameSettingsManager.is_assist_mode_first_time_open = false
		
	else:
		control_tree.show_control__and_add_if_unadded(_assist_mode_main_panel)
		
	


