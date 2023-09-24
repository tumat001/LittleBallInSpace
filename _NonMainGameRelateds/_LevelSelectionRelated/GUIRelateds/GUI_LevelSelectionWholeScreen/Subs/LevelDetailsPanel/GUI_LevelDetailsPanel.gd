extends MarginContainer


const Flag_Green = preload("res://_NonMainGameRelateds/_LevelSelectionRelated/GUIRelateds/GUI_LevelSelectionWholeScreen/Assets/GUI_LevelSelectionWholeScreen_Flag_Green.png")
const Flag_Gray = preload("res://_NonMainGameRelateds/_LevelSelectionRelated/GUIRelateds/GUI_LevelSelectionWholeScreen/Assets/GUI_LevelSelectionWholeScreen_Flag_Gray.png")
const Flag_Transparent = preload("res://_NonMainGameRelateds/_LevelSelectionRelated/GUIRelateds/GUI_LevelSelectionWholeScreen/Assets/GUI_LevelSelectionWholeScreen_Flag_Transparent.png")
const Flag_HalfGrayGreen = preload("res://_NonMainGameRelateds/_LevelSelectionRelated/GUIRelateds/GUI_LevelSelectionWholeScreen/Assets/GUI_LevelSelectionWholeScreen_Flag_HalfGrayGreen.png")


#

var level_details setget set_level_details

#

onready var coins_panel = $DetailsContainer/VBoxContainer/CoinsPanel
onready var level_status_label = $DetailsContainer/VBoxContainer/LevelStatusPanel/HBoxContainer/LevelStatusLabel
onready var level_status_tex_rect = $DetailsContainer/VBoxContainer/LevelStatusPanel/HBoxContainer/LevelStatusTexRect
onready var details_container = $DetailsContainer

onready var assist_mode_disabled_panel = $DetailsContainer/VBoxContainer/AssistModeDisabledPanel
onready var level_completion_additional_panel = $DetailsContainer/VBoxContainer/LevelCompletionAdditonalPanel

#

func _ready():
	coins_panel.instant_change_tweener_transition = true
	GameSaveManager.connect("level_id_completion_status_changed", self, "_on_level_id_completion_status_changed")


func _on_level_id_completion_status_changed(arg_id, arg_status):
	if level_details != null:
		if arg_id == level_details.level_id:
			_update_display()

#

func set_level_details(arg_details):
	level_details = arg_details
	
	if level_details != null:
		_update_display()
	else:
		hide_contents()


func hide_contents():
	details_container.visible = false


func _update_display():
	var arg_id = level_details.level_id
	
	if StoreOfLevels.is_level_id_exists(arg_id):
		details_container.visible = true
		coins_panel.configure_self_to_monitor_coin_status_for_level(arg_id, false)
		
		var level_status_of_id = GameSaveManager.get_level_id_status_completion(arg_id)
		if level_status_of_id == GameSaveManager.LEVEL_OR_LAYOUT_COMPLETION_STATUS__FINISHED:
			level_status_label.text = "Completed"
			level_status_tex_rect.texture = Flag_Green
			
		elif level_status_of_id == GameSaveManager.LEVEL_OR_LAYOUT_COMPLETION_STATUS__HALF_FINISHED:
			level_status_label.text = "Half"
			level_status_tex_rect.texture = Flag_HalfGrayGreen
			
		elif level_status_of_id == GameSaveManager.LEVEL_OR_LAYOUT_COMPLETION_STATUS__LOCKED:
			level_status_label.text = "Locked"
			level_status_tex_rect.texture = Flag_Transparent
			
		elif level_status_of_id == GameSaveManager.LEVEL_OR_LAYOUT_COMPLETION_STATUS__UNLOCKED:
			level_status_label.text = "Unlocked"
			level_status_tex_rect.texture = Flag_Gray
		
		#
		
		level_completion_additional_panel.visible = level_details.has_additional_level_ids_to_mark_as_complete()
		assist_mode_disabled_panel.visible = level_details.ignore_assist_mode_modifications
		
	else:
		hide_contents()
		

