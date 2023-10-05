extends "res://MiscRelated/ControlTreeRelated/ControlTree.gd"



onready var gsm_per_level_panel = $ControlContainer/GSM_PerLevel_Panel

#

func _ready():
	pause_tree_on_show = false
	use_mod_a_tweeners_for_traversing_hierarchy = false
	can_show_settings_button_on_first_hierarchy = false
	show_info_button = false
	
	connect("hierarchy_advanced_forwards", self, "_on_hierarchy_advanced_forwards__MMCT")

#

func show_gsm_level_panel(arg_level_id):
	gsm_per_level_panel.set_level_id_to_display_for(arg_level_id)
	show_control__and_add_if_unadded(gsm_per_level_panel, use_mod_a_tweeners_for_traversing_hierarchy)

########

func _on_hierarchy_advanced_forwards__MMCT(arg_control):
	if is_control_first_in_current_hierarchy(arg_control):
		AudioManager.helper__play_sound_effect__plain(StoreOfAudio.AudioIds.SFX_GUI_InGamePauseMenu_OrMainMenu_Open, 1.0, null)
		
	else:
		pass
		

