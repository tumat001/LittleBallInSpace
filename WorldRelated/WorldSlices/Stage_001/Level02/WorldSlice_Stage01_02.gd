extends "res://WorldRelated/AbstractWorldSlice.gd"



var _last_pcr_stuck_captured : bool
var _first_pcr_stuck_captured : bool

var _mod_tweener_for_stuck_label : SceneTreeTween

#

onready var vkp_rewind = $MessegesContainer/VBoxContainer/VKP_Rewind
onready var vkp_rewind_02 = $MessegesContainer/StuckLabelContainer/VKP_Rewind

onready var stuck_label_container = $MessegesContainer/StuckLabelContainer

onready var pdar_stuck_show_warning = $AreaRegionContainer/PDAR_StuckShowWarning

##

func _init():
	can_spawn_player_when_no_current_player_in_GE = true
	


func _on_after_game_start_init():
	._on_after_game_start_init()
	
	
	var orig_text_rewind = vkp_rewind.text_for_keypress
	vkp_rewind.text_for_keypress = orig_text_rewind % InputMap.get_action_list("rewind")[0].as_text()
	GameSaveManager.set_game_control_name_string__is_hidden("rewind", false)
	
	var orig_text_rewind_02 = vkp_rewind_02.text_for_keypress
	vkp_rewind_02.text_for_keypress = orig_text_rewind_02 % InputMap.get_action_list("rewind")[0].as_text()
	
	
	stuck_label_container.modulate.a = 0

##




func _on_PCAR_First_region_area_captured():
	_first_pcr_stuck_captured = true

func _on_PCAR_First_region_area_uncaptured():
	_first_pcr_stuck_captured = false

##

func _on_PCAR_LastStuck_region_area_captured():
	_last_pcr_stuck_captured = true

func _on_PCAR_LastStuck_region_area_uncaptured():
	_last_pcr_stuck_captured = false
	_attempt_tween_hide_stuck_warning()

#

func _on_PDAR_StuckShowWarning_player_entered_in_area():
	if _last_pcr_stuck_captured and !_first_pcr_stuck_captured:
		_attempt_tween_show_stuck_warning()



func _attempt_tween_show_stuck_warning():
	if _mod_tweener_for_stuck_label != null:
		_mod_tweener_for_stuck_label.kill()
	
	_mod_tweener_for_stuck_label = create_tween()
	_mod_tweener_for_stuck_label.tween_property(stuck_label_container, "modulate:a", 1.0, 0.5)


func _attempt_tween_hide_stuck_warning():
	if _mod_tweener_for_stuck_label != null:
		_mod_tweener_for_stuck_label.kill()
	
	_mod_tweener_for_stuck_label = create_tween()
	_mod_tweener_for_stuck_label.tween_property(stuck_label_container, "modulate:a", 0.0, 0.5)



