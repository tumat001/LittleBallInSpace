extends MarginContainer

const AssistModeMainPanel = preload("res://GameSaveRelated/GUIs/GameSettingsRelated/AssistModePanel/Subs/AssistModeMainPanel/AssistModeMainPanel.gd")
const AssistModeMainPanel_Scene = preload("res://GameSaveRelated/GUIs/GameSettingsRelated/AssistModePanel/Subs/AssistModeMainPanel/AssistModeMainPanel.tscn")

#

const MODULATE__BANNED = Color("#F29797")
const MODULATE__NORMAL = Color("#bbbbbb")

#

var _assist_mode_main_panel : AssistModeMainPanel

#

var is_in_game : bool

#

var control_tree

onready var main_button = $MainButton
onready var label_status = $VBoxContainer/LabelStatus

#

func _ready():
	var is_disabled = SingletonsAndConsts.current_base_level.ignore_assist_mode_modifications
	main_button.set_is_disabled(is_disabled, true)
	if is_disabled:
		label_status.text = "(Banned for this level)"
		label_status.modulate = MODULATE__BANNED
	else:
		
		if GameSettingsManager.current_assist_mode_is_active_at_current_game_elements__but_no_effect:
			label_status.text = "(Active, but No effect)"
			label_status.modulate = GameSettingsManager.ASSIST_MODE__TEXT_MODULATE__LIGHT
			
		elif GameSettingsManager.current_assist_mode_is_active_at_current_game_elements:
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
		
	else:
		control_tree.show_control__and_add_if_unadded(_assist_mode_main_panel)
		
		
	


